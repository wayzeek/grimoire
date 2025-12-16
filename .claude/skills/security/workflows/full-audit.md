# Full Security Audit

Comprehensive security review - for deep analysis, invoke the **auditor agent**.

## Pre-Audit

1. Understand the system
2. Map attack surface
3. Identify critical functions
4. Review documentation

## Automated Tools

```bash
slither .
aderyn .
forge coverage
```

## Manual Review Checklist

Use `../context/checklist.md` for detailed checklist.

### Critical Areas
- Access control
- Reentrancy
- Integer arithmetic
- External calls
- Oracle manipulation
- Flash loan attacks
- Front-running/MEV
- Upgradeability
- Event emission
- Input validation

## Report Structure

1. **Executive Summary**
2. **Critical Issues** (immediate fix)
3. **High Severity** (fix before deployment)
4. **Medium Severity** (should fix)
5. **Low Severity** (nice to have)
6. **Gas Optimizations**
7. **Informational**

## Invoke Auditor Agent

For comprehensive analysis:
- Complex DeFi protocols
- Pre-mainnet deployment
- External audit preparation
- Post-incident review

The auditor agent provides:
- Systematic security review
- Detailed vulnerability analysis
- Severity ratings
- Fix recommendations
- Attack scenarios
