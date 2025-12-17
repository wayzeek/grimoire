# Program Architecture

Program organization and structure patterns for Solana/Anchor development.

## Table of Contents

1. [Instruction Organization](#instruction-organization)
2. [Parameter Structs](#parameter-structs)

## Instruction Organization

```rust
// lib.rs
use anchor_lang::prelude::*;

declare_id!("YourProgramIDHere111111111111111111111111111");

pub mod instructions;
pub mod state;
pub mod errors;
pub mod constants;

use instructions::*;

#[program]
pub mod staking_program {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>, params: InitializeParams) -> Result<()> {
        instructions::initialize::handler(ctx, params)
    }

    pub fn stake(ctx: Context<Stake>, amount: u64, duration: i64) -> Result<()> {
        instructions::stake::handler(ctx, amount, duration)
    }
}

// instructions/mod.rs
pub mod initialize;
pub mod stake;
pub mod unstake;
pub mod claim;

pub use initialize::*;
pub use stake::*;
pub use unstake::*;
pub use claim::*;

// instructions/stake.rs
use anchor_lang::prelude::*;
use crate::state::*;
use crate::errors::*;

#[derive(Accounts)]
pub struct Stake<'info> {
    // Account definitions
}

pub fn handler(ctx: Context<Stake>, amount: u64, duration: i64) -> Result<()> {
    // Implementation
}

// state/mod.rs
pub mod vault;
pub mod user_stake;

pub use vault::*;
pub use user_stake::*;

// errors.rs
use anchor_lang::prelude::*;

#[error_code]
pub enum ErrorCode {
    // All errors
}

// constants.rs
pub const VAULT_SEED: &[u8] = b"vault";
pub const MIN_DURATION: i64 = 86400; // 1 day
pub const RATE_PRECISION: u64 = 1_000_000;
```

## Parameter Structs

```rust
// Use structs for complex parameters
#[derive(AnchorSerialize, AnchorDeserialize, Clone)]
pub struct InitializeParams {
    pub reward_rate: u64,
    pub min_stake_amount: u64,
    pub max_stake_amount: u64,
    pub min_duration: i64,
    pub max_duration: i64,
}

pub fn initialize(ctx: Context<Initialize>, params: InitializeParams) -> Result<()> {
    // Validate all parameters
    require!(params.reward_rate > 0, ErrorCode::InvalidRate);
    require!(params.min_stake_amount < params.max_stake_amount, ErrorCode::InvalidRange);

    let vault = &mut ctx.accounts.vault;
    vault.reward_rate = params.reward_rate;
    vault.min_stake_amount = params.min_stake_amount;
    // ... set other fields

    Ok(())
}
```
