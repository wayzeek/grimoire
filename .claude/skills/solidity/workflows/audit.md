# Security Audit Workflow

Comprehensive security audit checklist for smart contracts. For deep security analysis, invoke the **auditor agent**.

## Quick Security Scan

Run automated tools first:

```bash
# Slither (static analysis)
slither .

# Aderyn (Rust-based analyzer)
aderyn .

# Forge test with coverage
forge coverage
```

## Manual Audit Checklist

Refer to `../context/security-patterns.md` for detailed patterns. Key areas:

### 1. Access Control
- [ ] All privileged functions have proper access control
- [ ] No functions accidentally left public
- [ ] Owner/admin can't be zero address
- [ ] Consider using AccessControl over Ownable for complex permissions
- [ ] Check for missing access control on critical functions

### 2. Reentrancy
- [ ] CEI pattern (Checks-Effects-Interactions) followed
- [ ] External calls are at the end of functions
- [ ] State changes before external calls
- [ ] Consider ReentrancyGuard for complex functions
- [ ] Check for cross-function reentrancy

### 3. Integer Safety
- [ ] Using Solidity ^0.8.0 (built-in overflow protection)
- [ ] Check for unsafe casts
- [ ] Division before multiplication avoided
- [ ] Rounding issues considered

### 4. External Calls
- [ ] Return values of external calls checked
- [ ] Low-level calls (.call, .delegatecall) used safely
- [ ] Pull over push for payments
- [ ] Gas limits considered for loops with external calls

### 5. Input Validation
- [ ] Zero address checks
- [ ] Zero amount checks
- [ ] Array bounds checked
- [ ] Valid state transitions enforced

### 6. Token Handling
- [ ] Use safeTransfer/safeTransferFrom
- [ ] Handle fee-on-transfer tokens if applicable
- [ ] Check for ERC20 return value handling
- [ ] Approve race condition mitigation

### 7. Gas Optimization & DoS
- [ ] No unbounded loops
- [ ] Storage vs memory usage optimized
- [ ] Avoid DoS via gas limits
- [ ] Consider gas griefing attacks

### 8. Oracle & Price Manipulation
- [ ] Price oracles can't be manipulated
- [ ] Use TWAP or Chainlink for prices
- [ ] Flash loan attack resistant

### 9. Front-Running
- [ ] MEV/front-running risks identified
- [ ] Slippage protection implemented
- [ ] Commit-reveal if needed

### 10. Upgradeability (if applicable)
- [ ] Storage layout safe for upgrades
- [ ] Initialize functions protected
- [ ] No selfdestruct or delegatecall to user input

### 11. Events & Transparency
- [ ] Critical state changes emit events
- [ ] Events have proper indexing
- [ ] Events emitted before external calls

### 12. Testing
- [ ] High test coverage (>90%)
- [ ] Edge cases tested
- [ ] Failure scenarios tested
- [ ] Fork tests for integrations
- [ ] Invariant tests for critical properties

## Run Security Tools

```bash
# Install if needed
pip install slither-analyzer
cargo install aderyn

# Run tools
slither . --print human-summary
aderyn .
forge test --gas-report
```

## Generate Audit Report

Document findings:
1. Critical issues (immediate fix required)
2. High severity (fix before deployment)
3. Medium severity (should fix)
4. Low severity / Gas optimizations (nice to have)
5. Informational

## When to Invoke Auditor Agent

For comprehensive security review, invoke the **auditor agent**:
- Deep security analysis needed
- Pre-mainnet deployment
- Complex DeFi protocols
- After major contract changes
- External audit preparation

The auditor agent will:
- Perform thorough security analysis
- Check all common vulnerability patterns
- Review business logic for flaws
- Provide detailed security report
- Suggest fixes and improvements
