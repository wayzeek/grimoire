# Security Patterns

Security best practices for Solana/Anchor program development.

## Table of Contents

1. [Safe Arithmetic](#safe-arithmetic)
2. [Rent Exemption](#rent-exemption)
3. [Signer Validation](#signer-validation)
4. [Account Closure Safety](#account-closure-safety)
5. [Token Operations](#token-operations)

## Safe Arithmetic

```rust
use std::ops::{Add, Sub, Mul, Div};

// Always use checked arithmetic for financial operations
pub fn calculate_reward(stake_amount: u64, duration: i64, rate: u64) -> Result<u64> {
    let reward = (stake_amount as u128)
        .checked_mul(duration as u128)
        .ok_or(ErrorCode::Overflow)?
        .checked_mul(rate as u128)
        .ok_or(ErrorCode::Overflow)?
        .checked_div(RATE_PRECISION as u128)
        .ok_or(ErrorCode::Overflow)?;

    u64::try_from(reward).map_err(|_| error!(ErrorCode::Overflow))
}

// Use saturating arithmetic when appropriate
pub fn safe_add(a: u64, b: u64) -> u64 {
    a.saturating_add(b)
}
```

## Rent Exemption

```rust
pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
    let rent = Rent::get()?;
    let account_size = 8 + Vault::INIT_SPACE;

    require!(
        ctx.accounts.vault.to_account_info().lamports() >= rent.minimum_balance(account_size),
        ErrorCode::NotRentExempt
    );

    // Initialize account
    Ok(())
}
```

## Signer Validation

```rust
#[derive(Accounts)]
pub struct SecureOperation<'info> {
    // Always require Signer<'info> for authority operations
    #[account(mut)]
    pub authority: Signer<'info>,

    // Validate the signer relationship
    #[account(
        mut,
        has_one = authority @ ErrorCode::Unauthorized,
    )]
    pub vault: Account<'info, Vault>,
}

// In instruction
pub fn secure_operation(ctx: Context<SecureOperation>) -> Result<()> {
    // Additional runtime check if needed
    require!(
        ctx.accounts.authority.key() == ctx.accounts.vault.authority,
        ErrorCode::Unauthorized
    );

    Ok(())
}
```

## Account Closure Safety

```rust
pub fn close_account(ctx: Context<CloseAccount>) -> Result<()> {
    let dest_starting_lamports = ctx.accounts.destination.lamports();

    // Transfer all lamports
    **ctx.accounts.destination.lamports.borrow_mut() = dest_starting_lamports
        .checked_add(ctx.accounts.account_to_close.to_account_info().lamports())
        .ok_or(ErrorCode::Overflow)?;

    // Zero out the closed account
    **ctx.accounts.account_to_close.to_account_info().lamports.borrow_mut() = 0;

    // Zero out data
    let mut data = ctx.accounts.account_to_close.to_account_info().data.borrow_mut();
    data.fill(0);

    Ok(())
}
```

## Token Operations

```rust
use anchor_spl::token::{self, Transfer, Mint, Token, TokenAccount};

pub fn transfer_tokens(ctx: Context<TransferTokens>, amount: u64) -> Result<()> {
    // Validate before transfer
    require!(
        ctx.accounts.from.amount >= amount,
        ErrorCode::InsufficientFunds
    );

    require!(
        ctx.accounts.from.mint == ctx.accounts.to.mint,
        ErrorCode::MintMismatch
    );

    // Use CPI for token transfer
    let cpi_accounts = Transfer {
        from: ctx.accounts.from.to_account_info(),
        to: ctx.accounts.to.to_account_info(),
        authority: ctx.accounts.authority.to_account_info(),
    };

    let cpi_ctx = CpiContext::new(
        ctx.accounts.token_program.to_account_info(),
        cpi_accounts,
    );

    token::transfer(cpi_ctx, amount)?;

    Ok(())
}
```
