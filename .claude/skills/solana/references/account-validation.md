# Account Validation

Comprehensive account validation patterns for Solana/Anchor programs.

## Table of Contents

1. [Comprehensive Constraints](#comprehensive-constraints)
2. [has_one Constraint](#has_one-constraint)
3. [Close Account Safety](#close-account-safety)

## Comprehensive Constraints

```rust
#[derive(Accounts)]
pub struct Stake<'info> {
    // Signer validation
    #[account(mut)]
    pub user: Signer<'info>,

    // PDA validation with bump
    #[account(
        mut,
        seeds = [VAULT_SEED, mint.key().as_ref()],
        bump = vault.bump,
    )]
    pub vault: Account<'info, Vault>,

    // Account ownership and relationship validation
    #[account(
        mut,
        constraint = user_stake.authority == user.key() @ ErrorCode::Unauthorized,
        constraint = user_stake.vault == vault.key() @ ErrorCode::InvalidVault,
        seeds = [USER_STAKE_SEED, user.key().as_ref()],
        bump = user_stake.bump,
    )]
    pub user_stake: Account<'info, UserStake>,

    // Token account validation
    #[account(
        mut,
        constraint = user_token_account.owner == user.key() @ ErrorCode::InvalidTokenAccount,
        constraint = user_token_account.mint == mint.key() @ ErrorCode::MintMismatch,
        constraint = user_token_account.amount >= amount @ ErrorCode::InsufficientFunds,
    )]
    pub user_token_account: Account<'info, TokenAccount>,

    // Mint validation
    #[account(
        constraint = mint.decimals == 6 @ ErrorCode::InvalidDecimals,
    )]
    pub mint: Account<'info, Mint>,

    pub token_program: Program<'info, Token>,
    pub system_program: Program<'info, System>,
}
```

## has_one Constraint

```rust
// Use has_one for ownership checks
#[account]
pub struct Vault {
    pub authority: Pubkey,
    pub mint: Pubkey,
}

#[derive(Accounts)]
pub struct UpdateVault<'info> {
    #[account(
        mut,
        has_one = authority @ ErrorCode::Unauthorized,  // Checks vault.authority == authority.key()
    )]
    pub vault: Account<'info, Vault>,

    pub authority: Signer<'info>,
}
```

## Close Account Safety

```rust
#[derive(Accounts)]
pub struct CloseStake<'info> {
    #[account(
        mut,
        close = authority,  // Rent goes to authority
        has_one = authority,
        constraint = stake.claimed @ ErrorCode::NotClaimed,
    )]
    pub stake: Account<'info, Stake>,

    #[account(mut)]
    pub authority: Signer<'info>,
}
```
