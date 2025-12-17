# Scaffold New Forge Project

Create a new Solidity project with Foundry/Forge following best practices.

## Checklist

- [ ] Initialize Forge project
- [ ] Configure foundry.toml with optimizer settings
- [ ] Install OpenZeppelin and Solmate dependencies
- [ ] Set up directory structure (interfaces, libraries, test folders)
- [ ] Create .env.example with required variables
- [ ] Create .gitignore for Forge artifacts
- [ ] Set up deployment script template
- [ ] Create initial test file with setUp()
- [ ] Verify setup: `forge build && forge test`

## Steps

### 1. Initialize Forge project
```bash
forge init <project-name>
cd <project-name>
```

**Error Handling:**
- If `forge: command not found`: Install Foundry via `curl -L https://foundry.paradigm.xyz | bash && foundryup`
- If directory exists: Use `forge init --force` or choose different name

### 2. Configure foundry.toml
Use settings from `../context/forge-config.md`:
- Set Solidity version (latest stable: ^0.8.20)
- Configure optimizer settings (runs = 200)
- Set up remappings for dependencies

### 3. Install dependencies
```bash
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge install transmissions11/solmate --no-commit
```

**Error Handling:**
- If git errors occur: Initialize git first with `git init`
- If submodule issues: Use `--no-commit` flag

### 4. Set up directory structure
```bash
mkdir -p src/interfaces src/libraries
mkdir -p test/unit test/integration test/invariant
```

Expected structure:
```
src/
├── interfaces/
├── libraries/
└── <YourContract>.sol
test/
├── unit/
├── integration/
└── invariant/
script/
└── Deploy.s.sol
```

### 5. Create .env.example
```bash
cat > .env.example << 'EOF'
PRIVATE_KEY=
RPC_URL_MAINNET=
RPC_URL_SEPOLIA=
ETHERSCAN_API_KEY=
EOF
```

### 6. Create .gitignore
```bash
cat > .gitignore << 'EOF'
cache/
out/
.env
broadcast/
lib/
EOF
```

### 7. Set up deployment script template
Create `script/Deploy.s.sol` with basic Forge script structure:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
        // Deploy contracts here
        vm.stopBroadcast();
    }
}
```

### 8. Create initial test
Set up test file with basic structure including setUp() function.

### 9. Verify setup
```bash
forge build && forge test
```

**Expected Output:**
- Build completes successfully
- All tests pass (including default Counter test)

**Error Handling:**
- If build fails: Check Solidity version compatibility
- If tests fail: Review test setup and dependencies

## Success Criteria
- ✅ `forge build` completes without errors
- ✅ `forge test` shows passing tests
- ✅ All directories created
- ✅ Dependencies installed correctly
- ✅ Ready for contract development
