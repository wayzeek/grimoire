# Token Standards Implementation Guide

## Library Preferences

### OpenZeppelin
**Best for**: Production contracts, compliance, battle-tested code
- Most audited and widely used
- Modular and extensible
- Comprehensive documentation
- Regular security updates

### Solmate
**Best for**: Gas optimization, simpler implementations
- More gas-efficient than OpenZeppelin
- Less abstraction, easier to audit
- Lighter weight

### Solady
**Best for**: Maximum gas optimization
- Highly optimized assembly
- Cutting-edge gas savings
- Use when gas is critical

**Default choice**: OpenZeppelin for most cases, Solmate for gas-sensitive applications.

## ERC-20 Implementations

### Basic ERC-20
```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }
}
```

### ERC-20 with Common Extensions
```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, ERC20Burnable, ERC20Permit, Ownable {
    constructor()
        ERC20("MyToken", "MTK")
        ERC20Permit("MyToken")
        Ownable(msg.sender)
    {
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
```

### Common Extensions
- **ERC20Burnable**: Add burn functionality
- **ERC20Permit**: Gasless approvals (EIP-2612)
- **ERC20Votes**: Governance voting power
- **ERC20Snapshot**: Historical balance queries
- **ERC20Pausable**: Emergency pause mechanism
- **ERC20Capped**: Maximum supply cap

## ERC-721 (NFT) Implementations

### Basic ERC-721
```solidity
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {
    uint256 private _tokenIdCounter;

    constructor() ERC721("MyNFT", "MNFT") Ownable(msg.sender) {}

    function mint(address to) external onlyOwner {
        _tokenIdCounter++;
        _safeMint(to, _tokenIdCounter);
    }
}
```

### ERC-721 with Metadata
```solidity
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;

    constructor() ERC721("MyNFT", "MNFT") Ownable(msg.sender) {}

    function mint(address to, string memory uri) external onlyOwner {
        _tokenIdCounter++;
        _safeMint(to, _tokenIdCounter);
        _setTokenURI(_tokenIdCounter, uri);
    }
}
```

### Common Extensions
- **ERC721URIStorage**: Per-token metadata URIs
- **ERC721Enumerable**: Token enumeration (expensive)
- **ERC721Burnable**: Burn functionality
- **ERC721Pausable**: Pause transfers
- **ERC721Royalty**: EIP-2981 royalty standard

## ERC-1155 (Multi-Token) Implementations

### Basic ERC-1155
```solidity
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyMultiToken is ERC1155, Ownable {
    constructor() ERC1155("https://api.example.com/metadata/{id}.json") Ownable(msg.sender) {}

    function mint(address to, uint256 id, uint256 amount) external onlyOwner {
        _mint(to, id, amount, "");
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts)
        external
        onlyOwner
    {
        _mintBatch(to, ids, amounts, "");
    }
}
```

### Common Extensions
- **ERC1155Burnable**: Burn functionality
- **ERC1155Supply**: Track total supply per token ID
- **ERC1155Pausable**: Pause transfers

## Access Control Patterns

### Simple Ownership
```solidity
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyContract is Ownable {
    constructor() Ownable(msg.sender) {}
}
```

### Role-Based Access Control
```solidity
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MyContract is AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
}
```

## Supply Models

### Fixed Supply
```solidity
constructor() {
    _mint(msg.sender, TOTAL_SUPPLY);
}
```

### Mintable (Unlimited)
```solidity
function mint(address to, uint256 amount) external onlyOwner {
    _mint(to, amount);
}
```

### Capped Supply
```solidity
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

contract MyToken is ERC20Capped {
    constructor() ERC20Capped(1_000_000 * 10 ** decimals()) {}
}
```

## Testing Token Contracts

### Essential Tests
```solidity
// Basic functionality
function test_mint() public
function test_transfer() public
function test_approve() public
function test_transferFrom() public

// Access control
function testFail_mintUnauthorized() public
function test_onlyOwnerCanMint() public

// Edge cases
function test_transferZeroAddress() public
function test_transferInsufficientBalance() public
function test_burnReducesSupply() public

// ERC-20 specific
function test_decimals() public
function test_totalSupply() public

// ERC-721 specific
function test_tokenURI() public
function test_ownerOf() public
function test_safeTransfer() public

// ERC-1155 specific
function test_balanceOfBatch() public
function test_safeBatchTransferFrom() public
```

## Common Pitfalls

1. **Not using SafeERC20**: Always use `safeTransfer` and `safeTransferFrom`
2. **Missing zero address checks**: Validate recipient addresses
3. **Approval race condition**: Use `permit` or `increaseAllowance`/`decreaseAllowance`
4. **Gas griefing in loops**: Avoid unbounded loops
5. **Missing events**: Emit events for all state changes
6. **Metadata immutability**: Consider if metadata should be frozen
7. **Reentrancy in callbacks**: Be careful with `_safeMint` and `_safeTransfer`

## Resources
- [OpenZeppelin Contracts Wizard](https://wizard.openzeppelin.com/)
- [EIP-20 (ERC-20)](https://eips.ethereum.org/EIPS/eip-20)
- [EIP-721 (ERC-721)](https://eips.ethereum.org/EIPS/eip-721)
- [EIP-1155 (ERC-1155)](https://eips.ethereum.org/EIPS/eip-1155)
