# Scaffold New Forge Project

Create a new Solidity project with Foundry/Forge following best practices.

## Steps

1. **Initialize Forge project**
   ```bash
   forge init <project-name>
   cd <project-name>
   ```

2. **Configure foundry.toml**
   - Use settings from `../context/forge-config.md`
   - Set Solidity version (latest stable)
   - Configure optimizer settings
   - Set up remappings for dependencies

3. **Install dependencies**
   ```bash
   forge install OpenZeppelin/openzeppelin-contracts
   forge install transmissions11/solmate
   # Add others as needed
   ```

4. **Set up directory structure**
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

5. **Create .env.example**
   ```
   PRIVATE_KEY=
   RPC_URL_MAINNET=
   RPC_URL_SEPOLIA=
   ETHERSCAN_API_KEY=
   ```

6. **Create .gitignore**
   ```
   cache/
   out/
   .env
   broadcast/
   ```

7. **Set up deployment script template**
   - Create basic deployment script in `script/Deploy.s.sol`
   - Use Forge's scripting system

8. **Create initial test**
   - Set up test file with basic structure
   - Include setUp() function

9. **Verify setup**
   ```bash
   forge build
   forge test
   ```

## Output
- Fully configured Forge project
- Ready for contract development
- Includes deployment and testing infrastructure
