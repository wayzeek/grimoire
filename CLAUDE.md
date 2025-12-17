# Communication & Context Gathering

- IMPORTANT: When requirements are ambiguous, ask ALL clarifying questions upfront in a single message
- Never guess at user intent or make assumptions about unclear specifications
- Gather all necessary context through questions to eliminate ambiguity

# Documentation Standards

- Keep README files concise, brief, and human-like
- Avoid verbose or "AI slop" documentation style
- Only create documentation when explicitly requested

# Project Documentation

- For complex project-specific patterns, create `docs/` or `agent_docs/` folder
- Keep root CLAUDE.md under 100 lines; move detailed guides to separate files

# Commit Workflow

- Follow Conventional Commits format for all commit messages
- Never mention tools, assistants, or third-party services in commit messages
- Never auto-commit; always ask user before creating commits
- Before any commit, verify:
  - Build succeeds (check package manager from lockfile: pnpm-lock.yaml → pnpm, yarn.lock → yarn, bun.lockb → bun)
  - Linters pass (ESLint, Prettier for frontend; Ruff, Black for Python)
  - Basic sanity checks complete (tests run if available)
- Create commits only when features are successfully completed or bugs are fixed

# Code Quality

- Regularly clean up unused, deprecated, or experimental/debug code after finding solutions
- Remove dead code before implementing new features
- Keep codebase maintainable and lean

# Package Manager Detection

- NEVER use npm commands
- Always check lockfile to determine package manager:
  - `pnpm-lock.yaml` → use pnpm
  - `yarn.lock` → use yarn
  - `bun.lockb` → use bun
- Apply to all commands: install, run, build, test, etc.

# Project-Specific Rules

- When user states "for this project always X" or similar project-specific rules, automatically create or update the project's `CLAUDE.md` file
- If no project CLAUDE.md exists and context suggests one would help, ask user if they want to create one
