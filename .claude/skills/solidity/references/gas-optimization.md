# Gas Optimization

Gas-efficient coding patterns for Solidity smart contracts.

## Table of Contents

1. [Cache Storage Reads](#cache-storage-reads)
2. [Unchecked Arithmetic](#unchecked-arithmetic)
3. [Struct Packing](#struct-packing)
4. [Calldata for Read-Only Arrays](#calldata-for-read-only-arrays)
5. [Short-Circuit Optimization](#short-circuit-optimization)

## Cache Storage Reads

```solidity
// BAD: Multiple storage reads
function process() external {
    for (uint i = 0; i < users.length; i++) {
        totalBalance += balances[users[i]];  // reads totalBalance every loop
    }
}

// GOOD: Cache in memory
function process() external {
    uint256 _totalBalance = totalBalance;  // Single storage read
    for (uint i = 0; i < users.length; i++) {
        _totalBalance += balances[users[i]];
    }
    totalBalance = _totalBalance;  // Single storage write
}
```

## Unchecked Arithmetic

```solidity
// Use unchecked when overflow is impossible
for (uint256 i = 0; i < length;) {
    // ... process items[i]

    unchecked {
        ++i;  // i cannot overflow in realistic scenarios
    }
}

// Use unchecked for safe math
function calculateFee(uint256 amount) internal pure returns (uint256) {
    uint256 fee = amount * FEE_RATE / BASIS_POINTS;
    unchecked {
        return amount - fee;  // Safe: fee < amount by definition
    }
}
```

## Struct Packing

```solidity
// BAD: 3 storage slots
struct Stake {
    uint256 amount;      // 32 bytes - slot 0
    uint256 startTime;   // 32 bytes - slot 1
    bool claimed;        // 1 byte   - slot 2 (wastes 31 bytes)
}

// GOOD: 2 storage slots
struct Stake {
    uint128 amount;      // 16 bytes - slot 0
    uint64 startTime;    // 8 bytes  - slot 0
    uint64 duration;     // 8 bytes  - slot 0
    bool claimed;        // 1 byte   - slot 1
}
```

## Calldata for Read-Only Arrays

```solidity
// BAD: Copies to memory
function processBatch(uint256[] memory ids) external {
    for (uint256 i = 0; i < ids.length; i++) {
        process(ids[i]);
    }
}

// GOOD: Uses calldata directly
function processBatch(uint256[] calldata ids) external {
    for (uint256 i = 0; i < ids.length; i++) {
        process(ids[i]);
    }
}
```

## Short-Circuit Optimization

```solidity
// Order conditions by gas cost (cheapest first)
require(
    amount > 0 &&                    // Cheap: parameter check
    amount <= MAX_AMOUNT &&          // Cheap: constant check
    balances[msg.sender] >= amount   // Expensive: storage read
);
```
