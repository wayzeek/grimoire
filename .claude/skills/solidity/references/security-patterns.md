# Security Patterns & Common Vulnerabilities

Essential security knowledge for smart contract development.

## Critical Vulnerabilities

### Reentrancy
**Problem**: External calls can call back into the contract before state is updated.

**Bad**:
```solidity
function withdraw() external {
    uint256 amount = balances[msg.sender];
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success);
    balances[msg.sender] = 0; // State update AFTER external call
}
```

**Good**:
```solidity
function withdraw() external nonReentrant {
    uint256 amount = balances[msg.sender];
    balances[msg.sender] = 0; // State update BEFORE external call
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success);
}
```

### Access Control
**Problem**: Missing or incorrect access control on privileged functions.

**Bad**:
```solidity
function setAdmin(address newAdmin) external {
    admin = newAdmin; // Anyone can call!
}
```

**Good**:
```solidity
function setAdmin(address newAdmin) external onlyOwner {
    require(newAdmin != address(0), "Zero address");
    admin = newAdmin;
}
```

### Integer Overflow/Underflow
**Note**: Solidity ^0.8.0 has built-in protection, but watch for:
- Unsafe casts: `uint256 -> uint8`
- Assembly code bypassing checks
- Downcasting in general

```solidity
// Dangerous
uint8 small = uint8(largeNumber); // Can overflow

// Safe
require(largeNumber <= type(uint8).max);
uint8 small = uint8(largeNumber);
```

### Unchecked External Calls
**Problem**: Not checking return values of external calls.

**Bad**:
```solidity
token.transfer(recipient, amount); // Return value ignored
```

**Good**:
```solidity
require(token.transfer(recipient, amount), "Transfer failed");
// Or use SafeERC20
token.safeTransfer(recipient, amount);
```

### Front-Running / MEV
**Problem**: Transactions visible in mempool before execution.

**Mitigations**:
- Slippage protection
- Deadlines
- Commit-reveal schemes
- Private mempools (Flashbots)

```solidity
function swap(uint256 amountIn, uint256 minAmountOut, uint256 deadline) external {
    require(block.timestamp <= deadline, "Expired");
    uint256 amountOut = _swap(amountIn);
    require(amountOut >= minAmountOut, "Slippage");
}
```

### Oracle Manipulation
**Problem**: Price oracles can be manipulated, especially spot prices.

**Bad**:
```solidity
// Using spot price from DEX
uint256 price = pair.getReserves();
```

**Good**:
```solidity
// Use Chainlink or TWAP
uint256 price = priceFeed.latestAnswer();
require(price > 0, "Invalid price");
```

### DoS Attacks
**Problem**: Unbounded loops, gas limits, external call failures.

**Bad**:
```solidity
function distributeRewards(address[] memory users) external {
    for (uint256 i = 0; i < users.length; i++) {
        payable(users[i]).transfer(reward);
    }
}
```

**Good**:
```solidity
// Pull over push pattern
mapping(address => uint256) public rewards;

function claimReward() external {
    uint256 reward = rewards[msg.sender];
    rewards[msg.sender] = 0;
    payable(msg.sender).transfer(reward);
}
```

## Best Practices

### CEI Pattern
**Checks-Effects-Interactions**: Always follow this order.

```solidity
function transfer(address to, uint256 amount) external {
    // Checks
    require(to != address(0));
    require(balances[msg.sender] >= amount);

    // Effects
    balances[msg.sender] -= amount;
    balances[to] += amount;

    // Interactions
    emit Transfer(msg.sender, to, amount);
}
```

### Input Validation
```solidity
require(address != address(0), "Zero address");
require(amount > 0, "Zero amount");
require(array.length <= MAX_SIZE, "Array too large");
```

### Safe Math Libraries
```solidity
// Use SafeERC20 for token interactions
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
using SafeERC20 for IERC20;

token.safeTransfer(recipient, amount);
token.safeTransferFrom(sender, recipient, amount);
```

### Events for Transparency
```solidity
event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

function setAdmin(address newAdmin) external onlyOwner {
    address oldAdmin = admin;
    admin = newAdmin;
    emit AdminChanged(oldAdmin, newAdmin);
}
```

## Testing for Security

### Invariant Tests
```solidity
// Total supply should never change unexpectedly
function invariant_totalSupply() public {
    assertEq(token.totalSupply(), INITIAL_SUPPLY);
}

// Sum of balances equals total supply
function invariant_balanceSum() public {
    uint256 sum = 0;
    for (uint256 i = 0; i < users.length; i++) {
        sum += token.balanceOf(users[i]);
    }
    assertEq(sum, token.totalSupply());
}
```

### Fuzz Testing
```solidity
function testFuzz_transfer(address to, uint256 amount) public {
    vm.assume(to != address(0));
    vm.assume(amount <= token.balanceOf(address(this)));

    token.transfer(to, amount);
    assertEq(token.balanceOf(to), amount);
}
```

## Tools
- **Slither**: Static analysis
- **Aderyn**: Rust-based security tool
- **Mythril**: Symbolic execution
- **Echidna**: Fuzz testing
- **Certora**: Formal verification
- **Foundry**: Testing framework with fuzzing and invariants

## References
- [SWC Registry](https://swcregistry.io/)
- [ConsenSys Diligence Smart Contract Best Practices](https://consensysdiligence.github.io/smart-contract-best-practices/)
