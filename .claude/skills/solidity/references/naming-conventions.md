# Naming Conventions

Comprehensive naming standards for Solidity development.

## Table of Contents

1. [Constants and Immutables](#constants-and-immutables)
2. [Storage Variables](#storage-variables)
3. [Private/Internal Variables](#privateinternal-variables)
4. [Function Parameters](#function-parameters)
5. [Custom Errors](#custom-errors)
6. [Events](#events)
7. [Structs and Enums](#structs-and-enums)

## Constants and Immutables

**Rule:** ALL_CAPS with underscores

```solidity
// Constants: compile-time values
uint256 public constant MAX_SUPPLY = 1_000_000e18;
uint256 private constant BASIS_POINTS = 10_000;
bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

// Immutables: set once in constructor
address public immutable WETH_ADDRESS;
address public immutable FACTORY_ADDRESS;
uint256 public immutable INITIAL_TIMESTAMP;
uint8 public immutable DECIMALS;
```

## Storage Variables

**Rule:** camelCase without prefix

```solidity
uint256 public totalSupply;
uint256 public lastUpdateTime;
address public treasury;
mapping(address => uint256) public balanceOf;
mapping(address => mapping(address => uint256)) public allowance;
```

## Private/Internal Variables

**Rule:** underscore prefix

```solidity
uint256 private _nonce;
uint256 private _totalShares;
mapping(address => bool) private _isAdmin;
mapping(bytes32 => bool) private _usedHashes;

function _mint(address to, uint256 amount) internal {
    // Internal function also uses underscore
}
```

## Function Parameters

**Rule:** camelCase, descriptive names

```solidity
function transfer(
    address recipient,
    uint256 amount
) external returns (bool);

function updateConfig(
    uint256 newFeeRate,
    address newTreasury,
    uint256 minStakeAmount
) external onlyOwner;
```

## Custom Errors

**Rule:** PascalCase with descriptive verb/noun

```solidity
error InsufficientBalance(uint256 available, uint256 required);
error UnauthorizedAccess(address caller, address required);
error InvalidTimestamp(uint256 current, uint256 expected);
error TransferFailed(address token, address to, uint256 amount);
error StalePrice(uint256 age, uint256 maxAge);
error SlippageExceeded(uint256 amountOut, uint256 minAmountOut);
```

## Events

**Rule:** PascalCase, past tense or noun form

```solidity
event TokensMinted(address indexed to, uint256 amount);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event ConfigUpdated(uint256 oldValue, uint256 newValue);
event Staked(address indexed user, uint256 amount, uint256 indexed stakingId);
```

## Structs and Enums

**Rule:** PascalCase

```solidity
struct StakeInfo {
    uint256 amount;
    uint256 startTime;
    uint256 duration;
    bool claimed;
}

enum OrderStatus {
    Pending,
    Executed,
    Cancelled,
    Expired
}
```
