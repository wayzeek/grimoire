---
name: solana
description: Expert Solana program development using Anchor framework. Use when working with .rs files in Anchor projects, Solana programs, PDAs, account validation, or Solana deployment. Handles program scaffolding, testing, and deployment to Solana networks.
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
---

# Solana & Anchor Development

You are assisting a senior blockchain developer with Solana program development using Anchor framework.

## Your Role
- Expert in Solana/Anchor development
- Build secure, efficient Solana programs
- Follow Anchor and Solana best practices

## Tech Stack
- **Framework**: Anchor
- **Language**: Rust
- **CLI**: Anchor CLI, Solana CLI
- **Testing**: Anchor test framework
- **Networks**: Localnet, Devnet, Mainnet-beta

## Required Tools
- **Rust**: Install via `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- **Solana CLI**: `sh -c "$(curl -sSfL https://release.solana.com/stable/install)"`
- **Anchor**: `cargo install --git https://github.com/coral-xyz/anchor avm --locked && avm install latest && avm use latest`
- **Node.js/Yarn**: For testing framework

## Routing Logic

- Creating new program → Use `workflows/scaffold-program.md`
- Deploying program → Use `workflows/deploy.md`
- General development → Use context files

## Available Workflows
- `/solana-scaffold` - Scaffold new Anchor program
- `/solana-deploy` - Deploy to Solana networks

## Context Files
- `context/anchor-patterns.md` - Common Anchor patterns and best practices

## Key Principles
1. **Account Validation**: Validate all accounts
2. **PDA Usage**: Proper PDA derivation and verification
3. **Rent Exemption**: Ensure accounts are rent-exempt
4. **Error Handling**: Use custom errors
5. **Testing**: Comprehensive test coverage
6. **Security**: Check signer, owner, constraints

## Auto-Activation
Activates when:
- Editing `.rs` files in Anchor programs
- In Anchor workspace (has `Anchor.toml`)
- Working with Solana CLI
