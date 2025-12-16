# Security Audit Checklist

Comprehensive checklist for smart contract audits. See solidity skill's `context/security-patterns.md` for implementation details.

## Access Control
- [ ] All privileged functions have modifiers
- [ ] No accidentally public functions
- [ ] Owner can't be zero address
- [ ] Two-step ownership transfer for critical contracts

## Reentrancy
- [ ] CEI pattern followed
- [ ] ReentrancyGuard on sensitive functions
- [ ] No state changes after external calls

## Integer Safety
- [ ] Solidity ^0.8.0 or SafeMath
- [ ] No unsafe downcasting
- [ ] Division after multiplication

## External Calls
- [ ] Return values checked
- [ ] Pull over push pattern
- [ ] SafeERC20 for token transfers

## Input Validation
- [ ] Zero address checks
- [ ] Array length bounds
- [ ] Amount validations

## Events
- [ ] Critical operations emit events
- [ ] Events before external calls
- [ ] Indexed parameters

## Testing
- [ ] >90% coverage
- [ ] Edge cases tested
- [ ] Invariant tests
- [ ] Fork tests for integrations

## Documentation
- [ ] NatSpec on public functions
- [ ] README with deployment info
- [ ] Known limitations documented
