# Modern Solidity Patterns

Contemporary Solidity coding patterns and best practices.

## Table of Contents

1. [Custom Errors over require()](#custom-errors-over-require)
2. [Named Return Values](#named-return-values)
3. [Explicit over Implicit](#explicit-over-implicit)
4. [Modern Syntax](#modern-syntax)

## Custom Errors over require()

```solidity
// BAD (junior)
require(balance >= amount, "Insufficient balance");
require(msg.sender == owner, "Not owner");

// GOOD (senior)
error InsufficientBalance(uint256 available, uint256 required);
error Unauthorized(address caller);

if (balance < amount) revert InsufficientBalance(balance, amount);
if (msg.sender != owner) revert Unauthorized(msg.sender);
```

**Benefits:** Gas efficient, type-safe, better error context

## Named Return Values

```solidity
// GOOD: Self-documenting
function getStakeInfo(uint256 id) external view returns (
    uint256 amount,
    uint256 startTime,
    uint256 duration,
    bool claimed
) {
    StakeInfo memory stake = stakes[id];
    return (stake.amount, stake.startTime, stake.duration, stake.claimed);
}
```

## Explicit over Implicit

```solidity
// BAD: Implicit visibility
uint256 balance;  // Defaults to internal

// GOOD: Explicit visibility
uint256 public balance;
uint256 private _nonce;

// BAD: Implicit return
function add(uint256 a, uint256 b) external pure returns (uint256) {
    return a + b;  // Return type implicit
}

// GOOD: Named returns when helpful
function calculateReward(uint256 stakeAmount)
    external
    view
    returns (uint256 reward)
{
    reward = stakeAmount * rewardRate / BASIS_POINTS;
}
```

## Modern Syntax

```solidity
// Use underscores for readability
uint256 constant MAX_SUPPLY = 1_000_000e18;
uint256 amount = 100_000;

// Use override keyword
function transfer(address to, uint256 amount)
    public
    override
    returns (bool)
{
    // Implementation
}

// Use virtual for inheritance
function _beforeTokenTransfer(address from, address to, uint256 amount)
    internal
    virtual
{
    // Hook for child contracts
}
```
