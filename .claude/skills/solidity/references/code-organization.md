# Code Organization

File structure, import ordering, and contract layout standards.

## Table of Contents

1. [Directory Structure](#directory-structure)
2. [File Naming](#file-naming)
3. [One Contract Per File](#one-contract-per-file)
4. [Import Standards](#import-standards)
5. [Contract Layout](#contract-layout)
6. [Function Visibility Order](#function-visibility-order)

## Directory Structure

```
src/
├── interfaces/
│   ├── IERC20.sol
│   ├── IUniswapV2Router.sol
│   └── IOracle.sol
├── libraries/
│   ├── SafeTransfer.sol
│   └── Math.sol
├── abstract/
│   ├── Ownable.sol
│   └── ReentrancyGuard.sol
├── Token.sol              # One contract per file
├── Staking.sol
└── Treasury.sol

test/
├── Token.t.sol
├── Staking.t.sol
└── Treasury.t.sol

script/
├── Deploy.s.sol
└── Upgrade.s.sol
```

## File Naming

- **Contracts:** Match contract name exactly (`Token.sol` for `contract Token`)
- **Interfaces:** Prefix with `I` (`IERC20.sol` for `interface IERC20`)
- **Libraries:** Descriptive names (`SafeTransfer.sol`, `Math.sol`)
- **Abstract:** Descriptive names (`Ownable.sol`, `Pausable.sol`)
- **Tests:** Contract name + `.t.sol` (`Token.t.sol`)
- **Scripts:** Purpose + `.s.sol` (`Deploy.s.sol`)

## One Contract Per File

```solidity
// BAD: Multiple contracts in one file
// Token.sol
contract Token { }
contract TokenSale { }
contract Vesting { }

// GOOD: Separate files
// Token.sol
contract Token { }

// TokenSale.sol
contract TokenSale { }

// Vesting.sol
contract Vesting { }
```

## Import Standards

### Import Order

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// 1. External dependencies (alphabetical)
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// 2. Internal interfaces
import {IStaking} from "./interfaces/IStaking.sol";
import {IOracle} from "./interfaces/IOracle.sol";

// 3. Internal libraries
import {Math} from "./libraries/Math.sol";
import {SafeTransfer} from "./libraries/SafeTransfer.sol";
```

### Named Imports

**Always use named imports, never wildcards**

```solidity
// BAD
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// GOOD
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// GOOD: Multiple imports from same path
import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
```

## Contract Layout

Follow the Solidity style guide order:

```solidity
contract Token is ERC20, Ownable, ReentrancyGuard {
    // 1. Type declarations
    struct StakeInfo { }
    enum Status { }

    // 2. State variables
    // 2a. Constants
    uint256 public constant MAX_SUPPLY = 1_000_000e18;

    // 2b. Immutables
    address public immutable WETH_ADDRESS;

    // 2c. Public storage
    uint256 public totalStaked;

    // 2d. Private storage
    uint256 private _nonce;

    // 3. Events
    event Staked(address indexed user, uint256 amount);

    // 4. Errors
    error InsufficientBalance(uint256 available, uint256 required);

    // 5. Modifiers
    modifier whenNotPaused() { }

    // 6. Constructor
    constructor(address weth) { }

    // 7. Receive/Fallback
    receive() external payable { }

    // 8. External functions
    function stake(uint256 amount) external { }

    // 9. Public functions
    function getStakeInfo(uint256 id) public view returns (...) { }

    // 10. Internal functions
    function _mint(address to, uint256 amount) internal { }

    // 11. Private functions
    function _updateRewards() private { }
}
```

## Function Visibility Order

```solidity
// 1. External functions (most restrictive first)
function adminFunction() external onlyOwner { }
function publicFunction() external { }

// 2. Public functions
function getInfo() public view returns (...) { }

// 3. Internal functions
function _internalHelper() internal { }

// 4. Private functions
function _privateHelper() private { }
```
