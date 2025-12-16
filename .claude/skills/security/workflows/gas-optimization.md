# Gas Optimization

Reduce gas costs without compromising security.

## Common Optimizations

### 1. Use `unchecked` for Safe Math
```solidity
for (uint256 i = 0; i < length;) {
    // ... logic
    unchecked { ++i; }  // Save gas
}
```

### 2. Pack Storage Variables
```solidity
// Bad: 3 slots
uint256 a;
uint128 b;
uint128 c;

// Good: 2 slots
uint256 a;
uint128 b;
uint128 c;  // Packed with b
```

### 3. Use `calldata` Instead of `memory`
```solidity
function process(uint256[] calldata data) external {
    // Cheaper than memory for external functions
}
```

### 4. Cache Storage Reads
```solidity
uint256 total = totalSupply;  // Cache
for (uint256 i = 0; i < length; i++) {
    total += amounts[i];
}
totalSupply = total;  // Single write
```

### 5. Use Custom Errors
```solidity
error InsufficientBalance();

if (balance < amount) revert InsufficientBalance();
// Cheaper than: require(balance >= amount, "Insufficient balance");
```

## Tools

```bash
forge test --gas-report
forge snapshot
```
