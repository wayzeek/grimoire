# PDA Patterns

Program Derived Address conventions and patterns for Solana/Anchor development.

## Table of Contents

1. [Seed Naming](#seed-naming)
2. [Always Store Bump Seeds](#always-store-bump-seeds)
3. [Common PDA Patterns](#common-pda-patterns)

## Seed Naming

**Rule:** Use descriptive const byte strings in snake_case

```rust
// Define seeds as constants
pub const VAULT_SEED: &[u8] = b"vault";
pub const USER_STAKE_SEED: &[u8] = b"user_stake";
pub const ESCROW_SEED: &[u8] = b"escrow";
pub const CONFIG_SEED: &[u8] = b"config";
pub const AUTHORITY_SEED: &[u8] = b"authority";

// Use in PDA derivation
let (vault_pda, vault_bump) = Pubkey::find_program_address(
    &[VAULT_SEED, mint.key().as_ref()],
    ctx.program_id
);
```

## Always Store Bump Seeds

```rust
#[account]
pub struct Vault {
    pub bump: u8,              // Always store the bump
    pub authority: Pubkey,
    pub mint: Pubkey,
    pub total_staked: u64,
}

// Initialize with bump
#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(
        init,
        payer = authority,
        space = 8 + Vault::INIT_SPACE,
        seeds = [VAULT_SEED, mint.key().as_ref()],
        bump,
    )]
    pub vault: Account<'info, Vault>,
}

// Verify bump in other instructions
#[account(
    seeds = [VAULT_SEED, mint.key().as_ref()],
    bump = vault.bump,
)]
pub vault: Account<'info, Vault>,
```

## Common PDA Patterns

```rust
// Pattern 1: Global singleton PDA
seeds = [CONFIG_SEED]

// Pattern 2: Per-user PDA
seeds = [USER_STAKE_SEED, user.key().as_ref()]

// Pattern 3: Per-mint PDA
seeds = [VAULT_SEED, mint.key().as_ref()]

// Pattern 4: Composite PDA
seeds = [
    ESCROW_SEED,
    user.key().as_ref(),
    mint.key().as_ref(),
    &escrow_id.to_le_bytes()
]
```
