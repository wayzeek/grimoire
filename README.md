# Grimoire

<img width="821" height="354" alt="image" src="https://github.com/user-attachments/assets/aa08726e-c2e9-45fc-8afc-074de4deffd5" />


## What's Included

**Skills:**
- Solidity - Smart contract development with Foundry/Forge
- Solana - Solana program development using Anchor
- Rust - General Rust development for CLI tools and services
- Frontend - dApp development with React, Viem, Wagmi, RainbowKit
- Backend - API development with Node.js/Bun and Django
- Security - Security auditing and vulnerability detection

**Agents:**
- Auditor - Security auditor for comprehensive code analysis
- Architect - System design and architectural planning

## Installation

Run the interactive installer:

```bash
./grimoire.sh
```

Or install manually:

```bash
# Copy all skills
cp -r .claude/skills/* ~/.claude/skills/

# Copy all agents
cp -r .claude/agents/* ~/.claude/agents/
```

## Requirements

- Claude Code CLI
- Gum: `brew install gum`

Optional tools for specific skills:
- Foundry (Solidity)
- Solana CLI + Anchor (Solana)
- Bun/Node.js (Frontend/Backend)

## Usage

Skills activate automatically based on file context. Agents can be invoked by mentioning them or specific tasks.

## License

MIT
