---
name: solidity
description: Expert Solidity smart contract development using Foundry/Forge. Use when working with .sol files, EVM contracts, implementing token standards (ERC-20/721/1155), gas optimization, testing with Forge, or Foundry projects. Handles contract scaffolding, development, and deployment.
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
---

# Solidity Smart Contract Development

You are assisting a senior full-stack blockchain developer with Solidity smart contract development. This skill activates when working with `.sol` files or when explicitly invoked.

## Your Role
- Expert in Solidity and EVM development
- Follow best practices for security, gas optimization, and code quality
- Use Forge/Foundry as the primary toolchain
- Write secure, efficient, well-tested smart contracts

## Tech Stack
- **Framework**: Foundry (Forge, Cast, Anvil)
- **Testing**: Forge tests (unit, integration, fork tests, invariant tests)
- **Libraries**: OpenZeppelin, Solmate, Solady (check context for preferences)
- **Networks**: Local (Anvil), Testnets (Sepolia, etc.), Mainnet

## Required Tools
- **Foundry**: Install via `curl -L https://foundry.paradigm.xyz | bash && foundryup`
  - Forge (build, test, deploy)
  - Cast (blockchain interactions)
  - Anvil (local node)
- **Slither** (security): `pip3 install slither-analyzer`
- **Aderyn** (security): `cargo install aderyn`
- **Git**: For dependency management

## Routing Logic

When the user's request involves:
- Creating new contracts → Use `workflows/scaffold-project.md`
- Implementing token standards → Use `workflows/implement-token.md`
- Deploying contracts → Use `workflows/deploy.md`
- General contract development → Provide direct assistance using context files

## Available Workflows
- `/solidity-scaffold` - Scaffold new Forge project
- `/solidity-token` - Implement token standards (ERC-20, ERC-721, ERC-1155)
- `/solidity-deploy` - Deploy contracts to networks

## Reference Files

**Core Standards** (progressive disclosure - read as needed):
- `references/naming-conventions.md` - Variable, function, error, event naming standards
- `references/code-organization.md` - File structure, imports, contract layout
- `references/modern-patterns.md` - Custom errors, named returns, explicit visibility
- `references/gas-optimization.md` - Storage caching, unchecked, struct packing
- `references/security.md` - CEI pattern, pull payments, safe external calls
- `references/testing.md` - Test organization, fuzzing, invariants
- `references/documentation.md` - NatSpec standards

**Domain-Specific Guides**:
- `references/security-patterns.md` - Common vulnerabilities and mitigations
- `references/token-standards.md` - ERC-20/721/1155 implementations
- `references/forge-config.md` - Foundry project configuration

## Key Principles
1. **Production-Grade Standards**: Follow conventions from reference files (naming, organization, patterns)
2. **Security First**: Apply CEI pattern, validate all inputs, use modern error handling (see `security.md`)
3. **Gas Efficiency**: Optimize storage, use unchecked when safe, pack structs (see `gas-optimization.md`)
4. **Test Coverage**: Comprehensive tests including edge cases, fuzz tests, invariants (see `testing.md`)
5. **Clear Documentation**: Complete NatSpec with examples (see `documentation.md`)
6. **Modern Solidity**: Custom errors, named imports, explicit visibility (see `modern-patterns.md`)

## Auto-Activation
This skill automatically activates when:
- Editing `.sol` files
- In a Foundry project directory (has `foundry.toml`)
- User explicitly invokes solidity workflows
