// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * ONSRegistry (v1)
 * - Registers .onchain names on-demand
 * - Enforces time-bound registration (annual)
 * - Enforces category-based pricing at protocol level
 * - Forwards payments to a payout address
 *
 * Notes:
 * - This is NOT a resolver. It only handles ownership + expiry.
 * - Names are represented internally; we store by labelhash (keccak256 of normalized label).
 */
contract ONSRegistry {
    // ====== Config ======
    uint256 public constant REGISTRATION_PERIOD = 365 days;

    address public owner;          // admin (can set payout + premium list + prices)
    address public payout;         // where funds go

    // Pricing in wei (set these to your desired $ ranges later)
    uint256 public priceRandom;    // e.g., ~$2-5 in ETH terms (you set this)
    uint256 public priceWord;      // e.g., ~$10-20
    uint256 public pricePremium;   // e.g., ~$200-1000+

    // ====== Storage ======
    struct NameRecord {
        address holder;
        uint64  expires; // unix timestamp
    }

    // labelhash => record
    mapping(bytes32 => NameRecord) private records;

    // Explicit premium overrides (labelhash => true)
    mapping(bytes32 => bool) public isPremium;

    // Optional explicit “word” overrides (labelhash => true)
    // (You can start empty. Later you can set curated word list or heuristic rules.)
    mapping(bytes32 => bool) public isWord;

    // ====== Events ======
    event Registered(string label, bytes32 indexed labelhash, address indexed holder, uint64 expires, uint256 pricePaid);
    event Renewed(string label, bytes32 indexed labelhash, uint64 expires, uint256 pricePaid);
    event Transfer(string label, bytes32 indexed labelhash, address indexed from, address indexed to);

    event PayoutUpdated(address indexed payout);
    event PricesUpdated(uint256 randomPrice, uint256 wordPrice, uint256 premiumPrice);
    event PremiumSet(bytes32 indexed labelhash, bool isPremium);
    event WordSet(bytes32 indexed labelhash, bool isWord);

    // ====== Modifiers ======
    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor(address _payout) {
        owner = msg.sender;
        payout = _payout;

        // Default placeholder prices (set real values right after deploy)
        priceRandom  = 0.001 ether;
        priceWord    = 0.005 ether;
        pricePremium = 0.05 ether;
    }

    // ====== Admin ======
    function setPayout(address _payout) external onlyOwner {
        require(_payout != address(0), "bad payout");
        payout = _payout;
        emit PayoutUpdated(_payout);
    }

    function setPrices(uint256 _random, uint256 _word, uint256 _premium) external onlyOwner {
        require(_random > 0 && _word > 0 && _premium > 0, "bad price");
        priceRandom = _random;
        priceWord = _word;
        pricePremium = _premium;
        emit PricesUpdated(_random, _word, _premium);
    }

    function setPremium(string calldata label, bool value) external onlyOwner {
        bytes32 h = _labelhash(label);
        isPremium[h] = value;
        emit PremiumSet(h, value);
    }

    function setWord(string calldata label, bool value) external onlyOwner {
        bytes32 h = _labelhash(label);
        isWord[h] = value;
        emit WordSet(h, value);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "bad owner");
        owner = newOwner;
    }

    // ====== Public Views ======
    function labelhashOf(string calldata label) external pure returns (bytes32) {
        return keccak256(bytes(_normalize(label)));
    }

    function ownerOf(string calldata label) external view returns (address) {
        bytes32 h = _labelhash(label);
        if (_isExpired(h)) return address(0);
        return records[h].holder;
    }

    function expiresAt(string calldata label) external view returns (uint64) {
        return records[_labelhash(label)].expires;
    }

    function available(string calldata label) external view returns (bool) {
        return _isExpired(_labelhash(label));
    }

    function priceFor(string calldata label) public view returns (uint256) {
        bytes32 h = _labelhash(label);
        if (isPremium[h]) return pricePremium;
        if (isWord[h]) return priceWord;

        // Default “random” pricing. Later we can add heuristics (length, charset, etc.)
        return priceRandom;
    }

    // ====== Core Actions ======
    function register(string calldata label) external payable {
        bytes32 h = _labelhash(label);
        require(_validLabel(label), "invalid label");

        // must be available
        require(_isExpired(h), "already registered");

        uint256 price = priceFor(label);
        require(msg.value >= price, "insufficient payment");

        uint64 newExpiry = uint64(block.timestamp + REGISTRATION_PERIOD);
        records[h] = NameRecord({ holder: msg.sender, expires: newExpiry });

        _forwardFunds();

        // If they overpaid, refund the difference
        if (msg.value > price) {
            (bool ok, ) = msg.sender.call{value: msg.value - price}("");
            require(ok, "refund failed");
        }

        emit Registered(label, h, msg.sender, newExpiry, price);
    }

    function renew(string calldata label) external payable {
        bytes32 h = _labelhash(label);
        require(_validLabel(label), "invalid label");

        // Only current holder can renew (if expired, it must be re-registered)
        require(!_isExpired(h), "expired");
        require(records[h].holder == msg.sender, "not holder");

        uint256 price = priceFor(label);
        require(msg.value >= price, "insufficient payment");

        uint64 current = records[h].expires;
        uint64 base = current > block.timestamp ? current : uint64(block.timestamp);
        uint64 newExpiry = uint64(base + REGISTRATION_PERIOD);
        records[h].expires = newExpiry;

        _forwardFunds();

        if (msg.value > price) {
            (bool ok, ) = msg.sender.call{value: msg.value - price}("");
            require(ok, "refund failed");
        }

        emit Renewed(label, h, newExpiry, price);
    }

    function transferName(string calldata label, address to) external {
        require(to != address(0), "bad to");
        bytes32 h = _labelhash(label);
        require(!_isExpired(h), "expired");
        require(records[h].holder == msg.sender, "not holder");

        address from = records[h].holder;
        records[h].holder = to;

        emit Transfer(label, h, from, to);
    }

    // ====== Internals ======
    function _forwardFunds() internal {
        // Forward contract balance to payout
        uint256 bal = address(this).balance;
        if (bal > 0) {
            (bool ok, ) = payout.call{value: bal}("");
            require(ok, "payout failed");
        }
    }

    function _isExpired(bytes32 h) internal view returns (bool) {
        return records[h].expires < block.timestamp;
    }

    function _labelhash(string calldata label) internal pure returns (bytes32) {
        return keccak256(bytes(_normalize(label)));
    }

    function _normalize(string calldata label) internal pure returns (string memory) {
        // Minimal normalization v1:
        // - trim not handled
        // - lowercases A-Z
        // - no unicode support in v1 (ASCII only)
        bytes memory b = bytes(label);
        bytes memory out = new bytes(b.length);
        for (uint256 i = 0; i < b.length; i++) {
            uint8 c = uint8(b[i]);
            if (c >= 65 && c <= 90) { // A-Z
                out[i] = bytes1(c + 32);
            } else {
                out[i] = b[i];
            }
        }
        return string(out);
    }

    function _validLabel(string calldata label) internal pure returns (bool) {
        bytes memory b = bytes(label);
        if (b.length < 1 || b.length > 63) return false; // DNS-style
        for (uint256 i = 0; i < b.length; i++) {
            uint8 c = uint8(b[i]);

            // allow: a-z, 0-9, hyphen
            bool ok =
                (c >= 97 && c <= 122) || // a-z
                (c >= 48 && c <= 57)  || // 0-9
                (c == 45);               // -

            // also allow uppercase because we normalize (but still reject weird chars)
            if (!ok) {
                if (c >= 65 && c <= 90) ok = true;
            }

            if (!ok) return false;
        }
        // no leading/trailing hyphen
        if (b[0] == "-" || b[b.length - 1] == "-") return false;
        return true;
    }

    receive() external payable {}
}
