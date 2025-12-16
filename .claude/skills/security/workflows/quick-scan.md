# Quick Security Scan

Fast security check using automated tools.

## Run Tools

```bash
# Slither
slither . --print human-summary

# Aderyn
aderyn .

# Coverage
forge coverage --report summary
```

## Quick Manual Checks

```solidity
// 1. Access control on all critical functions?
function mint() external onlyOwner { }

// 2. CEI pattern followed?
function withdraw() external {
    uint256 amount = balances[msg.sender];
    balances[msg.sender] = 0;  // Effect
    (bool success,) = msg.sender.call{value: amount}("");  // Interaction
}

// 3. Input validation?
require(address != address(0));
require(amount > 0);

// 4. SafeERC20 used?
token.safeTransfer(to, amount);

// 5. Events emitted?
emit Transfer(from, to, amount);
```

## Common Red Flags

- Missing access control
- State changes after external calls
- Unchecked return values
- Unbounded loops
- Hardcoded addresses
- Missing zero checks
- No event emissions
