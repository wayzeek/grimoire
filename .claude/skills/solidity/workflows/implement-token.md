# Implement Token Standards

Implement ERC-20, ERC-721, or ERC-1155 token contracts following best practices.

## Process

1. **Clarify Requirements**
   - Which standard? (ERC-20, ERC-721, ERC-1155)
   - Extensions needed? (Burnable, Pausable, Votes, Permit, etc.)
   - Supply: Fixed, capped, or unlimited?
   - Access control: Ownable or AccessControl?
   - Any custom functionality?

2. **Choose Base Implementation**
   - Refer to `../references/token-standards.md` for preferences
   - OpenZeppelin (battle-tested, modular)
   - Solmate (gas-optimized)
   - Solady (highly optimized)

3. **Implement Contract**
   - Import base contracts
   - Add required extensions
   - Implement custom logic
   - Set up proper access control
   - Add events for important state changes

4. **Add NatSpec Documentation**
   - Contract-level documentation
   - Function-level documentation
   - Parameter descriptions
   - Keep it concise and clear

5. **Write Comprehensive Tests**
   - Test standard compliance
   - Test all extensions
   - Test access control
   - Test edge cases (zero address, zero amount, etc.)
   - Test custom functionality
   - Test failure scenarios

6. **Security Checks**
   - Check for common vulnerabilities (see `../references/security-patterns.md`)
   - Verify access control on privileged functions
   - Test for reentrancy if applicable
   - Check integer overflow/underflow handling
   - Verify events are emitted correctly

## Example Structure (ERC-20)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    constructor() ERC20("MyToken", "MTK") Ownable(msg.sender) {
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
```

## Output
- Fully implemented token contract
- Comprehensive test suite
- Deployment script
- Documentation
