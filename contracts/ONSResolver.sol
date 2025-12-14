// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IONSRegistry {
    function ownerOf(string calldata label) external view returns (address);
}

/**
 * ONSResolver (v1)
 * - Stores one primary EVM address per chainId for a name
 * - Stores text records (including "avatar")
 * - Requires current ownership from ONSRegistry
 *
 * Notes:
 * - For Solana/BTC-style addresses (non-EVM), add bytes-based records in v1.1
 */
contract ONSResolver {
    IONSRegistry public immutable registry;

    // labelhash -> chainId -> primary EVM address
    mapping(bytes32 => mapping(uint256 => address)) private primary;

    // labelhash -> key -> value (avatar is key "avatar")
    mapping(bytes32 => mapping(string => string)) private texts;

    event PrimarySet(bytes32 indexed labelhash, uint256 indexed chainId, address addr);
    event TextSet(bytes32 indexed labelhash, string indexed key, string value);

    constructor(address registryAddress) {
        require(registryAddress != address(0), "BAD_REGISTRY");
        registry = IONSRegistry(registryAddress);
    }

    modifier onlyNameOwner(string calldata label) {
        require(registry.ownerOf(label) == msg.sender, "NOT_NAME_OWNER");
        _;
    }

    // ---------------- Addresses ----------------

    function setPrimary(
        string calldata label,
        uint256 chainId,
        address addr
    ) external onlyNameOwner(label) {
        require(addr != address(0), "BAD_ADDRESS");
        bytes32 h = _labelhash(label);
        primary[h][chainId] = addr;
        emit PrimarySet(h, chainId, addr);
    }

    function getPrimary(
        string calldata label,
        uint256 chainId
    ) external view returns (address) {
        return primary[_labelhash(label)][chainId];
    }

    // ---------------- Text records ----------------
    // avatar usage: setText(label, "avatar", "<url or nft ref>")

    function setText(
        string calldata label,
        string calldata key,
        string calldata value
    ) external onlyNameOwner(label) {
        bytes32 h = _labelhash(label);
        texts[h][key] = value;
        emit TextSet(h, key, value);
    }

    function getText(
        string calldata label,
        string calldata key
    ) external view returns (string memory) {
        return texts[_labelhash(label)][key];
    }

    // ---------------- Internals ----------------

    function _labelhash(string calldata label) internal pure returns (bytes32) {
        return keccak256(bytes(_normalize(label)));
    }

    function _normalize(string calldata label) internal pure returns (string memory) {
        bytes memory b = bytes(label);
        bytes memory out = new bytes(b.length);
        for (uint256 i = 0; i < b.length; i++) {
            uint8 c = uint8(b[i]);
            out[i] = (c >= 65 && c <= 90) ? bytes1(c + 32) : b[i];
        }
        return string(out);
    }
}
