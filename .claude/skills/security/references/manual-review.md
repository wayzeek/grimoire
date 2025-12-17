# Manual Review Techniques

Manual code review techniques for security audits.
## Manual Review Techniques

### Control Flow Analysis

```markdown
# Control Flow Checklist

## Function Entry Points
- [ ] Public/external functions identified
- [ ] Access control verified
- [ ] Input validation checked
- [ ] State preconditions validated

## State Changes
- [ ] All state changes documented
- [ ] Order of operations verified
- [ ] Atomicity guaranteed
- [ ] Rollback behavior correct

## External Interactions
- [ ] All external calls identified
- [ ] Return values handled
- [ ] Failure modes considered
- [ ] Reentrancy implications assessed

## Exit Points
- [ ] All return paths identified
- [ ] Postconditions verified
- [ ] Events emitted correctly
- [ ] State consistency maintained
```

### Data Flow Analysis

```markdown
# Data Flow Checklist

## Input Validation
- [ ] Type checking
- [ ] Range validation
- [ ] Format verification
- [ ] Sanitization applied

## Data Transformations
- [ ] Mathematical operations safe
- [ ] Type conversions correct
- [ ] Encoding/decoding verified
- [ ] Precision maintained

## Storage Operations
- [ ] Write operations authorized
- [ ] Read operations safe
- [ ] Storage slots correct
- [ ] Collision prevention verified

## Output Validation
- [ ] Return values correct
- [ ] Events accurate
- [ ] Side effects documented
```

### Invariant Checking

```solidity
// Document and verify protocol invariants

// Invariant 1: Total supply equals sum of balances
// VERIFICATION:
function verifySupplyInvariant() internal view {
    uint256 sumOfBalances = 0;
    for (uint i = 0; i < holders.length; i++) {
        sumOfBalances += balances[holders[i]];
    }
    assert(totalSupply == sumOfBalances);
}

// Invariant 2: Contract value equals total deposits
// VERIFICATION:
function verifyValueInvariant() internal view {
    assert(address(this).balance == totalDeposits);
}

// Invariant 3: User balance never exceeds total supply
// VERIFICATION:
function verifyBalanceBound(address user) internal view {
    assert(balances[user] <= totalSupply);
}
```

