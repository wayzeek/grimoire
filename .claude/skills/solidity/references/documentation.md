# Documentation Standards

NatSpec and code documentation standards for Solidity smart contracts.

## Table of Contents

1. [Contract-Level NatSpec](#contract-level-natspec)
2. [Function Documentation](#function-documentation)
3. [Event Documentation](#event-documentation)
4. [Error Documentation](#error-documentation)
5. [Complex Logic Comments](#complex-logic-comments)

## Contract-Level NatSpec

```solidity
/// @title ERC20 Token with Staking
/// @author Your Name
/// @notice This contract implements an ERC20 token with staking functionality
/// @dev Inherits from OpenZeppelin's ERC20 and implements custom staking logic
/// @custom:security-contact security@example.com
contract StakingToken is ERC20 {
```

## Function Documentation

```solidity
/// @notice Stakes tokens for a specified duration to earn rewards
/// @dev Transfers tokens from caller and creates stake record
/// @param amount The amount of tokens to stake (in wei)
/// @param duration The staking duration in seconds (must be between MIN and MAX)
/// @return stakeId The unique identifier for this stake
/// @custom:throws InsufficientBalance if caller balance is too low
/// @custom:throws InvalidDuration if duration is out of bounds
function stake(uint256 amount, uint256 duration)
    external
    returns (uint256 stakeId)
{
    // Implementation
}
```

## Event Documentation

```solidity
/// @notice Emitted when tokens are staked
/// @param user The address of the staker
/// @param amount The amount of tokens staked (in wei)
/// @param duration The staking duration in seconds
/// @param stakeId The unique identifier for this stake
event Staked(
    address indexed user,
    uint256 amount,
    uint256 duration,
    uint256 indexed stakeId
);
```

## Error Documentation

```solidity
/// @notice Thrown when caller has insufficient balance for operation
/// @param available The caller's current balance
/// @param required The amount needed for the operation
error InsufficientBalance(uint256 available, uint256 required);
```

## Complex Logic Comments

```solidity
function calculateReward(uint256 stakeAmount, uint256 duration)
    internal
    pure
    returns (uint256)
{
    // Reward calculation:
    // 1. Base reward = stakeAmount * duration * BASE_RATE / YEAR
    // 2. Duration bonus: +10% for >30 days, +25% for >90 days
    // 3. Amount bonus: +5% for >10k tokens, +15% for >100k tokens

    uint256 baseReward = stakeAmount * duration * BASE_RATE / SECONDS_PER_YEAR;

    // Apply duration multiplier
    uint256 durationMultiplier = 100;  // 100% = no bonus
    if (duration > 90 days) durationMultiplier = 125;
    else if (duration > 30 days) durationMultiplier = 110;

    // Apply amount multiplier
    uint256 amountMultiplier = 100;
    if (stakeAmount > 100_000e18) amountMultiplier = 115;
    else if (stakeAmount > 10_000e18) amountMultiplier = 105;

    return baseReward * durationMultiplier * amountMultiplier / 10_000;
}
```
