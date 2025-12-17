# Grimoire

<img width="821" height="354" alt="image" src="https://github.com/user-attachments/assets/aa08726e-c2e9-45fc-8afc-074de4deffd5" />

## What's Included

**Skills:**
- **Solidity** - Smart contract development with Foundry/Forge for EVM chains
- **Solana** - Solana program development using Anchor framework
- **Rust** - General Rust development for CLI tools, services, and system utilities
- **Frontend** - Full-stack frontend development with React, TypeScript, Vite, and web3 integration
- **Backend** - Full-stack backend development with Node.js/Bun and Django/Python
- **Security** - Security auditing and vulnerability detection for smart contracts and applications

## Installation

Run the interactive manager:

```bash
./grimoire.sh
```

This launches an interactive menu where you can:
- Browse and install skills
- Manage CLAUDE.md configuration files
- View skill descriptions and status

Or install manually:

```bash
# Copy all skills
cp -r .claude/skills/* ~/.claude/skills/

# Copy CLAUDE.md configuration (optional)
cp CLAUDE.md ~/.claude/CLAUDE.md
```

## Requirements

- Claude Code CLI
- Gum: `brew install gum`

Optional tools for specific skills:
- **Solidity**: Foundry (Forge, Cast, Anvil)
- **Solana**: Solana CLI + Anchor framework
- **Rust**: Rust toolchain (rustup, cargo, rustfmt, clippy)
- **Frontend**: Bun/Node.js, Vite, React, TypeScript
- **Backend**: Bun/Node.js (Express/Fastify) or Python (Django/FastAPI)

## Usage

Skills activate automatically based on file context and specific triggers mentioned in their descriptions.

### Hybrid Development Approach

The **Frontend** and **Backend** skills are designed for hybrid development:

- **Frontend**: Supports both traditional web apps (React, TypeScript, Vite) and web3 dApps (Viem, Wagmi, RainbowKit)
- **Backend**: Supports both traditional APIs (REST/GraphQL) and blockchain-specific services (indexers, event processors)

This allows seamless development across web2 and web3 projects within the same codebase.

## CLAUDE.md Configuration

Grimoire includes a refined CLAUDE.md template with best practices for working with Claude Code:

- **Communication**: Ask clarifying questions upfront to eliminate ambiguity
- **Documentation**: Keep READMEs concise and human-like
- **Commits**: Follow Conventional Commits, verify builds/linters before committing
- **Code Quality**: Regular cleanup of unused and deprecated code
- **Package Manager**: Auto-detect pnpm/yarn/bun from lockfiles (never npm)

Use `./grimoire.sh` to:
- View project or global CLAUDE.md files
- Copy grimoire's template to `~/.claude/CLAUDE.md` (global)
- Sync between project and global configurations
- Remove CLAUDE.md files when needed

## License

MIT
