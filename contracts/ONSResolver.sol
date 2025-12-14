// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IONSRegistry {
    function ownerOf(string calldata label) external view returns (address);
}

/**
 * ONSResolver (v1)
 * - Stores addresses per chain for a name
 * - Enforces one primary address per chain
 * - Requires ownership from ONSRegistry
 */
contract ONSResolver {
    IONSRegistry public registry;

    // labelhash => chainId => list of addresses
    mapping(bytes32 => mapping(uint256 => address[])) private addresses;

    // labelhash => chainId => primary address
    mapping(bytes32 => mapping(uint256 => address)) private primary;

    event AddressAdded(bytes32 indexed labelhash, uint256 indexed chainId, address addr);
    event PrimarySet(bytes32 indexed labelhash, uint256 indexed chainId, address addr);

    constructor(address registryAddress) {
        registry = IONSRegistry(registryAddress);
    }

    modifier onlyNameOwner(string calldata label) {
        require(registry.ownerOf(label) == msg.sender, "not name owner");
        _;
    }

    function addAddress(
        string calldata label,
        uint256 chainId,
        address addr
    ) external onlyNameOwner(label) {
        require(addr != address(0), "bad address");
        bytes32 h = keccak256(bytes(label));
        addresses[h][chainId].push(addr);
        emit AddressAdded(h, chainId, addr);
    }

    function setPrimary(
        string calldata label,
        uint256 chainId,
        address addr
    ) external onlyNameOwner(label) {
        bytes32 h = keccak256(bytes(label));
        primary[h][chainId] = addr;
        emit PrimarySet(h, chainId, addr);
    }

    function getPrimary(
        string calldata label,
        uint256 chainId
    ) external view returns (address) {
        return primary[keccak256(bytes(label))][chainId];
    }

    function getAll(
        string calldata label,
        uint256 chainId
    ) external view returns (address[] memory) {
        return addresses[keccak256(bytes(label))][chainId];
    }
}
