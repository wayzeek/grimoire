# Testing Standards

Comprehensive testing standards for Solidity smart contracts using Foundry.

## Table of Contents

1. [File Organization](#file-organization)
2. [Test Categories](#test-categories)
3. [Fuzzing](#fuzzing)
4. [Invariant Testing](#invariant-testing)

## File Organization

```solidity
// Token.t.sol
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {
    Token public token;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address treasury = makeAddr("treasury");

    function setUp() public {
        token = new Token("Test", "TST");

        // Setup initial state
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
    }

    // Test naming: test_Function_Condition
    function test_Transfer_Success() public { }

    function test_Transfer_RevertsWhen_InsufficientBalance() public { }

    function testFuzz_Transfer(address to, uint256 amount) public { }
}
```

## Test Categories

```solidity
// 1. Constructor tests
function test_Constructor_SetsInitialValues() public {
    assertEq(token.name(), "Test");
    assertEq(token.symbol(), "TST");
    assertEq(token.decimals(), 18);
}

// 2. Success cases
function test_Mint_Success() public {
    vm.prank(owner);
    token.mint(alice, 100e18);

    assertEq(token.balanceOf(alice), 100e18);
    assertEq(token.totalSupply(), 100e18);
}

// 3. Revert cases
function test_Mint_RevertsWhen_NotOwner() public {
    vm.expectRevert(abi.encodeWithSelector(Unauthorized.selector, alice));
    vm.prank(alice);
    token.mint(bob, 100e18);
}

// 4. Event emission
function test_Mint_EmitsEvent() public {
    vm.expectEmit(true, true, false, true);
    emit Transfer(address(0), alice, 100e18);

    vm.prank(owner);
    token.mint(alice, 100e18);
}

// 5. State changes
function test_Burn_UpdatesState() public {
    vm.startPrank(owner);
    token.mint(alice, 100e18);

    uint256 supplyBefore = token.totalSupply();
    uint256 balanceBefore = token.balanceOf(alice);

    vm.stopPrank();
    vm.prank(alice);
    token.burn(50e18);

    assertEq(token.totalSupply(), supplyBefore - 50e18);
    assertEq(token.balanceOf(alice), balanceBefore - 50e18);
}
```

## Fuzzing

```solidity
function testFuzz_Transfer(address to, uint256 amount) public {
    // Assume valid inputs
    vm.assume(to != address(0));
    vm.assume(to != alice);
    vm.assume(amount <= 1000e18);

    // Setup
    token.mint(alice, 1000e18);

    // Execute
    vm.prank(alice);
    token.transfer(to, amount);

    // Assert
    assertEq(token.balanceOf(to), amount);
    assertEq(token.balanceOf(alice), 1000e18 - amount);
}
```

## Invariant Testing

```solidity
contract TokenInvariantTest is Test {
    Token token;
    TokenHandler handler;

    function setUp() public {
        token = new Token();
        handler = new TokenHandler(token);

        targetContract(address(handler));
    }

    // Invariant: total supply equals sum of balances
    function invariant_TotalSupplyEqualsBalances() public {
        assertEq(
            token.totalSupply(),
            handler.sumOfBalances()
        );
    }

    // Invariant: balance never exceeds total supply
    function invariant_BalanceNeverExceedsTotalSupply() public {
        assertTrue(
            handler.maxBalance() <= token.totalSupply()
        );
    }
}
```
