# Common Vulnerabilities Reference

See solidity skill's `context/security-patterns.md` for detailed patterns.

## Top 10 Smart Contract Vulnerabilities

1. **Reentrancy** - External calls before state updates
2. **Access Control** - Missing or incorrect permissions
3. **Integer Overflow/Underflow** - Unsafe type casting
4. **Unchecked External Calls** - Ignored return values
5. **Oracle Manipulation** - Using manipulable price feeds
6. **Front-Running** - MEV exploitation
7. **DoS** - Unbounded loops, gas limits
8. **Delegate Call** - Unsafe delegatecall usage
9. **Signature Replay** - Missing nonce/expiry
10. **Timestamp Dependence** - Using block.timestamp unsafely

## Resources
- SWC Registry: https://swcregistry.io/
- ConsenSys Diligence Best Practices: https://consensysdiligence.github.io/smart-contract-best-practices/
- Rekt News: https://rekt.news/
