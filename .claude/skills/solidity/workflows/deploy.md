# Deploy Smart Contracts

Deploy contracts to local, testnet, or mainnet using Forge scripts.

## Pre-Deployment Checklist

1. **Security**
   - Run security audit (use `/solidity-audit`)
   - Review test coverage
   - Check for known vulnerabilities

2. **Configuration**
   - Verify `.env` has required variables
   - Check network RPC URLs
   - Verify deployer has sufficient funds

3. **Contract Verification**
   - Ensure contract compiles
   - Run all tests: `forge test`
   - Check gas estimates

## Deployment Process

### 1. Local Deployment (Anvil)

```bash
# Start local node
anvil

# Deploy
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

### 2. Testnet Deployment

```bash
# Deploy to testnet (e.g., Sepolia)
forge script script/Deploy.s.sol \
  --rpc-url $RPC_URL_SEPOLIA \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

### 3. Mainnet Deployment

```bash
# Simulate first
forge script script/Deploy.s.sol --rpc-url $RPC_URL_MAINNET

# Deploy (requires confirmation)
forge script script/Deploy.s.sol \
  --rpc-url $RPC_URL_MAINNET \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

## Deployment Script Template

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/YourContract.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        YourContract contract = new YourContract();

        vm.stopBroadcast();

        console.log("Contract deployed at:", address(contract));
    }
}
```

## Post-Deployment

1. **Verify Contract**
   - Ensure Etherscan verification succeeded
   - Manual verification if needed: `forge verify-contract`

2. **Save Deployment Info**
   - Save contract addresses
   - Save deployment transaction hashes
   - Update frontend/backend configs with new addresses

3. **Test Deployed Contract**
   - Interact using Cast
   - Verify state is correct
   - Test key functions

4. **Update Documentation**
   - Update README with deployed addresses
   - Document any deployment-specific configuration

## Network-Specific Notes

### Local (Anvil)
- Fast iteration
- No gas costs
- Use for quick testing

### Testnet (Sepolia, etc.)
- Staging environment
- Get testnet ETH from faucets
- Test full integration with frontend

### Mainnet
- Production deployment
- Double-check everything
- Consider multi-sig for ownership
- Monitor gas prices

## Common Commands

```bash
# Check deployment status
cast block-number --rpc-url $RPC_URL

# Verify contract manually
forge verify-contract <address> src/Contract.sol:ContractName --etherscan-api-key $ETHERSCAN_API_KEY

# Interact with deployed contract
cast call <address> "functionName()" --rpc-url $RPC_URL
cast send <address> "functionName()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```
