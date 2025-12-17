# Security Patterns

Security best practices and patterns for Solidity smart contracts.

## Table of Contents

1. [Checks-Effects-Interactions (CEI)](#checks-effects-interactions-cei)
2. [Two-Step Ownership Transfer](#two-step-ownership-transfer)
3. [Pull over Push Payments](#pull-over-push-payments)
4. [Safe External Calls](#safe-external-calls)
5. [Input Validation](#input-validation)

## Checks-Effects-Interactions (CEI)

```solidity
// BAD: Vulnerable to reentrancy
function withdraw() external {
    uint256 amount = balances[msg.sender];
    (bool success,) = msg.sender.call{value: amount}("");  // Interaction first
    require(success);
    balances[msg.sender] = 0;  // Effect after interaction
}

// GOOD: CEI pattern
function withdraw() external nonReentrant {
    // Checks
    uint256 amount = balances[msg.sender];
    require(amount > 0, "No balance");

    // Effects
    balances[msg.sender] = 0;

    // Interactions
    (bool success,) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
}
```

## Two-Step Ownership Transfer

```solidity
// BAD: Single-step transfer (risky)
function transferOwnership(address newOwner) external onlyOwner {
    owner = newOwner;
}

// GOOD: Two-step transfer (safe)
address private _pendingOwner;

function transferOwnership(address newOwner) external onlyOwner {
    require(newOwner != address(0), "Invalid address");
    _pendingOwner = newOwner;
    emit OwnershipTransferInitiated(owner, newOwner);
}

function acceptOwnership() external {
    require(msg.sender == _pendingOwner, "Not pending owner");
    address oldOwner = owner;
    owner = _pendingOwner;
    _pendingOwner = address(0);
    emit OwnershipTransferred(oldOwner, owner);
}
```

## Pull over Push Payments

```solidity
// BAD: Push payments (DoS risk)
function distributeRewards() external {
    for (uint i = 0; i < users.length; i++) {
        payable(users[i]).transfer(rewards[i]);  // Can fail if one user reverts
    }
}

// GOOD: Pull payments
mapping(address => uint256) public claimableRewards;

function accrueRewards() external {
    for (uint i = 0; i < users.length; i++) {
        claimableRewards[users[i]] += calculateReward(users[i]);
    }
}

function claimRewards() external {
    uint256 amount = claimableRewards[msg.sender];
    claimableRewards[msg.sender] = 0;
    payable(msg.sender).transfer(amount);
}
```

## Safe External Calls

```solidity
// Check return values
(bool success, bytes memory data) = token.call(
    abi.encodeWithSelector(IERC20.transfer.selector, recipient, amount)
);
require(success && (data.length == 0 || abi.decode(data, (bool))), "Transfer failed");

// Or use SafeERC20 library
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

using SafeERC20 for IERC20;

token.safeTransfer(recipient, amount);
```

## Input Validation

```solidity
function stake(uint256 amount, uint256 duration) external {
    // Validate all inputs
    require(amount > 0, "Zero amount");
    require(amount <= MAX_STAKE_AMOUNT, "Amount too large");
    require(duration >= MIN_DURATION, "Duration too short");
    require(duration <= MAX_DURATION, "Duration too long");

    // Validate state
    require(totalStaked + amount <= TOTAL_STAKE_CAP, "Cap exceeded");

    // Validate msg.sender isn't a contract (if needed)
    require(msg.sender == tx.origin, "No contracts");

    // Continue with logic
}
```
