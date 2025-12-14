// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ONSRegistry {
    uint256 public constant REGISTRATION_PERIOD = 365 days;

    address public owner;
    address public treasury;

    uint256 public priceRandom;   // 5+ chars
    uint256 public priceWord;     // 4 chars
    uint256 public pricePremium;  // 3 chars OR manually premium

    struct NameRecord {
        address holder;
        uint64 expires;
    }

    mapping(bytes32 => NameRecord) private records;
    mapping(bytes32 => bool) public isPremium;

    event Registered(string label, bytes32 indexed hash, address indexed holder, uint64 expires, uint256 price);
    event Renewed(string label, bytes32 indexed hash, uint64 expires, uint256 price);
    event Transferred(string label, bytes32 indexed hash, address indexed from, address indexed to);

    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    constructor(address _treasury) {
        require(_treasury != address(0), "BAD_TREASURY");
        owner = msg.sender;
        treasury = _treasury;

        // Placeholder defaults – update after deploy
        priceRandom = 0.001 ether;
        priceWord = 0.01 ether;
        pricePremium = 0.1 ether;
    }

    // ---------------- ADMIN ----------------

    function setPrices(uint256 random, uint256 word, uint256 premium) external onlyOwner {
        priceRandom = random;
        priceWord = word;
        pricePremium = premium;
    }

    function setPremium(string calldata label, bool value) external onlyOwner {
        isPremium[_labelhash(label)] = value;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "BAD_OWNER");
        owner = newOwner;
    }

    // ---------------- VIEWS ----------------

    function ownerOf(string calldata label) external view returns (address) {
        bytes32 h = _labelhash(label);
        if (_isExpired(h)) return address(0);
        return records[h].holder;
    }

    function available(string calldata label) external view returns (bool) {
        return _isExpired(_labelhash(label));
    }

    function priceFor(string calldata label) public view returns (uint256) {
        bytes32 h = _labelhash(label);
        uint256 len = bytes(_normalize(label)).length;

        if (isPremium[h] || len == 3) return pricePremium;
        if (len == 4) return priceWord;
        return priceRandom;
    }

    // ---------------- CORE ----------------

    function register(string calldata label) external payable {
        string memory norm = _normalize(label);
        require(_validLabel(norm), "INVALID_LABEL");

        bytes32 h = keccak256(bytes(norm));
        require(_isExpired(h), "TAKEN");

        uint256 price = priceFor(norm);
        require(msg.value == price, "EXACT_PAYMENT_REQUIRED");

        records[h] = NameRecord({
            holder: msg.sender,
            expires: uint64(block.timestamp + REGISTRATION_PERIOD)
        });

        _payTreasury(price);

        emit Registered(norm, h, msg.sender, records[h].expires, price);
    }

    function renew(string calldata label) external payable {
        string memory norm = _normalize(label);
        bytes32 h = keccak256(bytes(norm));

        require(!_isExpired(h), "EXPIRED");
        require(records[h].holder == msg.sender, "NOT_HOLDER");

        uint256 price = priceFor(norm);
        require(msg.value == price, "EXACT_PAYMENT_REQUIRED");

        records[h].expires = uint64(
            (records[h].expires > block.timestamp ? records[h].expires : block.timestamp)
            + REGISTRATION_PERIOD
        );

        _payTreasury(price);

        emit Renewed(norm, h, records[h].expires, price);
    }

    function transferName(string calldata label, address to) external {
        require(to != address(0), "BAD_TO");
        bytes32 h = _labelhash(label);
        require(records[h].holder == msg.sender, "NOT_HOLDER");
        require(!_isExpired(h), "EXPIRED");

        address from = records[h].holder;
        records[h].holder = to;

        emit Transferred(label, h, from, to);
    }

    // ---------------- INTERNAL ----------------

    function _payTreasury(uint256 amount) internal {
        (bool ok,) = treasury.call{value: amount}("");
        require(ok, "TREASURY_PAY_FAILED");
    }

    function _isExpired(bytes32 h) internal view returns (bool) {
        return records[h].expires < block.timestamp;
    }

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

    function _validLabel(string memory label) internal pure returns (bool) {
        bytes memory b = bytes(label);
        if (b.length < 3 || b.length > 63) return false;
        if (b[0] == 45 || b[b.length - 1] == 45) return false;

        for (uint256 i = 0; i < b.length; i++) {
            uint8 c = uint8(b[i]);
            bool ok =
                (c >= 97 && c <= 122) ||
                (c >= 48 && c <= 57) ||
                (c == 45);
            if (!ok) return false;
        }
        return true;
    }

    receive() external payable {}
}
