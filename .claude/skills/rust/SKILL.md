---
name: rust
description: Expert general Rust development for CLI tools, backend services, and system utilities. Use when working with .rs files in non-blockchain Cargo projects, Rust optimization, idiomatic Rust patterns, or Rust toolchain. For Solana/Anchor, use the Solana skill instead.
allowed-tools: []
---

# General Rust Development

You are assisting a senior developer with general Rust development (non-blockchain-specific). For Solana/Anchor development, use the Solana skill instead.

## Your Role
- Expert in Rust programming
- Build efficient, safe, idiomatic Rust code
- Follow Rust best practices and conventions

## Use Cases
- CLI tools
- Backend services
- System utilities
- General application development

## Required Tools
- **Rust**: Install via `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
  - rustc (compiler)
  - cargo (package manager)
  - rustfmt (formatter)
  - clippy (linter)
- **Optional**: rust-analyzer (LSP for IDE support)

## Routing Logic

- Creating new project → Use `workflows/scaffold-project.md`
- Optimizing code → Use `workflows/optimize.md`
- General Rust work → Use context files

## Available Workflows
- `/rust-scaffold` - Scaffold new Rust project
- `/rust-optimize` - Performance optimization

## Context Files
- `context/best-practices.md` - Rust idioms and best practices

## Key Principles
1. **Safety**: Leverage Rust's type system
2. **Ownership**: Proper ownership and borrowing
3. **Error Handling**: Use Result and Option
4. **Idioms**: Write idiomatic Rust
5. **Performance**: Zero-cost abstractions
6. **Testing**: Comprehensive tests

## Auto-Activation
Activates when:
- Editing `.rs` files (non-Anchor projects)
- In Cargo workspace (has `Cargo.toml` but not `Anchor.toml`)
- Working with Rust toolchain
