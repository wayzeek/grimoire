# Error Handling

Error definitions and handling patterns for Solana/Anchor programs.

## Table of Contents

1. [Comprehensive Error Definitions](#comprehensive-error-definitions)
2. [Error Usage](#error-usage)
3. [Custom Require Macros](#custom-require-macros)

## Comprehensive Error Definitions

```rust
#[error_code]
pub enum ErrorCode {
    // Use descriptive names with context
    #[msg("Unauthorized: caller is not the authority")]
    Unauthorized,

    #[msg("Insufficient funds: available {0}, required {1}")]
    InsufficientFunds,

    #[msg("Invalid timestamp: current must be >= start")]
    InvalidTimestamp,

    #[msg("Amount exceeds maximum allowed")]
    AmountTooLarge,

    #[msg("Duration out of bounds: min {0}s, max {1}s")]
    InvalidDuration,

    #[msg("Stake not yet matured")]
    StakeNotMatured,

    #[msg("Rewards already claimed")]
    AlreadyClaimed,

    #[msg("Mathematical overflow occurred")]
    Overflow,

    #[msg("Invalid account state")]
    InvalidState,

    #[msg("Mint decimals must be 6")]
    InvalidDecimals,

    #[msg("Token account mint mismatch")]
    MintMismatch,

    #[msg("Account not rent exempt")]
    NotRentExempt,
}
```

## Error Usage

```rust
// Validate inputs with custom errors
require!(
    amount > 0,
    ErrorCode::AmountTooLarge
);

require_gte!(
    user_balance,
    amount,
    ErrorCode::InsufficientFunds
);

// Use ? operator for Result types
let new_balance = old_balance
    .checked_add(amount)
    .ok_or(ErrorCode::Overflow)?;

// Constraint errors in account validation
#[account(
    constraint = vault.is_initialized() @ ErrorCode::NotInitialized,
    constraint = Clock::get()?.unix_timestamp >= vault.start_time @ ErrorCode::InvalidTimestamp,
)]
pub vault: Account<'info, Vault>,
```

## Custom Require Macros

```rust
// Create domain-specific require macros
macro_rules! require_gte {
    ($left:expr, $right:expr, $err:expr) => {
        if $left < $right {
            return Err(error!($err));
        }
    };
}

macro_rules! require_keys_eq {
    ($left:expr, $right:expr, $err:expr) => {
        if $left != $right {
            return Err(error!($err));
        }
    };
}

// Usage
require_gte!(balance, amount, ErrorCode::InsufficientFunds);
require_keys_eq!(vault.authority, authority.key(), ErrorCode::Unauthorized);
```
