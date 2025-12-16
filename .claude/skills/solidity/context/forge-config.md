# Standard Foundry Configuration

## foundry.toml

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc = "0.8.23"  # Use latest stable
optimizer = true
optimizer_runs = 200
via_ir = false

# Increased limits for complex contracts
bytecode_hash = "none"
evm_version = "paris"

# RPC endpoints
[rpc_endpoints]
mainnet = "${RPC_URL_MAINNET}"
sepolia = "${RPC_URL_SEPOLIA}"
local = "http://localhost:8545"

# Etherscan API keys
[etherscan]
mainnet = { key = "${ETHERSCAN_API_KEY}" }
sepolia = { key = "${ETHERSCAN_API_KEY}" }

# Formatting
[fmt]
line_length = 120
tab_width = 4
bracket_spacing = true
int_types = "long"
multiline_func_header = "attributes_first"
quote_style = "double"
number_underscore = "thousands"

# Testing
[fuzz]
runs = 256
max_test_rejects = 65536

[invariant]
runs = 256
depth = 15
fail_on_revert = true

# Gas reports
gas_reports = ["*"]
```

## Remappings

Create `remappings.txt`:

```
@openzeppelin/=lib/openzeppelin-contracts/
@solmate/=lib/solmate/src/
@solady/=lib/solady/src/
forge-std/=lib/forge-std/src/
```

## Common Dependencies

```bash
# OpenZeppelin Contracts
forge install OpenZeppelin/openzeppelin-contracts

# Solmate (gas-optimized)
forge install transmissions11/solmate

# Solady (highly optimized)
forge install Vectorized/solady

# Forge Standard Library (testing)
forge install foundry-rs/forge-std
```

## .gitignore

```
# Compiler output
cache/
out/

# Environment
.env

# Deployment broadcasts
broadcast/

# IDE
.vscode/
.idea/

# OS
.DS_Store
```

## .env.example

```bash
# Private key (NEVER commit .env!)
PRIVATE_KEY=

# RPC URLs
RPC_URL_MAINNET=https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY
RPC_URL_SEPOLIA=https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY

# Block explorers
ETHERSCAN_API_KEY=

# Optional: Tenderly
TENDERLY_ACCESS_KEY=
TENDERLY_PROJECT=
```

## Common Forge Commands

```bash
# Build
forge build
forge build --sizes  # Show contract sizes

# Test
forge test
forge test -vvv  # Verbose (show traces)
forge test --match-test testSpecific
forge test --match-contract ContractTest
forge test --gas-report

# Coverage
forge coverage
forge coverage --report lcov

# Format
forge fmt
forge fmt --check

# Deploy
forge script script/Deploy.s.sol --rpc-url sepolia --broadcast

# Verify
forge verify-contract <address> src/Contract.sol:ContractName --etherscan-api-key $ETHERSCAN_API_KEY

# Clean
forge clean

# Update dependencies
forge update
```

## Cast Commands (Interaction)

```bash
# Read
cast call <address> "balanceOf(address)(uint256)" <address> --rpc-url mainnet

# Write
cast send <address> "transfer(address,uint256)" <to> <amount> --rpc-url sepolia --private-key $PRIVATE_KEY

# Get block
cast block latest --rpc-url mainnet

# Get transaction
cast tx <tx_hash> --rpc-url mainnet

# Get gas price
cast gas-price --rpc-url mainnet

# Convert units
cast to-wei 1 ether
cast from-wei 1000000000000000000

# Encode calldata
cast calldata "transfer(address,uint256)" <to> <amount>

# Decode data
cast 4byte <selector>
cast 4byte-decode <calldata>
```

## Optimization Tips

### Gas Optimization Settings
```toml
# For production (higher optimization)
[profile.production]
optimizer_runs = 1000000  # Optimize for runtime gas
via_ir = true  # Enable IR optimizer (more optimizations)

# For deployment cost optimization
[profile.deploy]
optimizer_runs = 1  # Optimize for deployment cost
```

### When to use via_ir
- Enable for complex contracts with many optimizer runs
- Can reduce runtime gas but increase compile time
- Test thoroughly as it can change behavior in edge cases

## Profile-Specific Configs

```toml
[profile.ci]
fuzz = { runs = 10000 }
invariant = { runs = 1000 }

[profile.lite]
optimizer = false
fuzz = { runs = 10 }
```

Run with: `forge test --profile ci`

## Additional Foundry Tools

```bash
# Anvil (local node)
anvil
anvil --fork-url $RPC_URL_MAINNET  # Fork mainnet

# Chisel (Solidity REPL)
chisel

# Cast wallet
cast wallet new  # Generate new wallet
cast wallet address --private-key $PRIVATE_KEY
```
