# Full Security Audit

Comprehensive security review across all components of the application.

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

## Reporting

Generate a structured security report with:
- Systematic security review findings
- Detailed vulnerability analysis
- Severity ratings (Critical, High, Medium, Low)
- Fix recommendations with code examples
- Attack scenarios and mitigation strategies
