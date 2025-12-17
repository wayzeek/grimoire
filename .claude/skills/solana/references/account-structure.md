# Account Structure

Account space calculation and validation methods for Solana/Anchor programs.

## Table of Contents

1. [Space Calculation](#space-calculation)
2. [Validation Methods](#validation-methods)
3. [Vec and Dynamic Data](#vec-and-dynamic-data)

## Space Calculation

```rust
#[account]
pub struct Vault {
    pub authority: Pubkey,        // 32
    pub mint: Pubkey,             // 32
    pub total_staked: u64,        // 8
    pub reward_rate: u64,         // 8
    pub last_update: i64,         // 8
    pub bump: u8,                 // 1
    pub paused: bool,             // 1
    // Total: 90 bytes + 8 byte discriminator = 98 bytes
}

impl Vault {
    pub const INIT_SPACE: usize = 8 + 32 + 32 + 8 + 8 + 8 + 1 + 1;
}

// Use in initialization
#[account(
    init,
    payer = payer,
    space = 8 + Vault::INIT_SPACE,  // 8 for discriminator
    seeds = [VAULT_SEED],
    bump,
)]
pub vault: Account<'info, Vault>,
```

## Validation Methods

```rust
impl Vault {
    pub fn is_initialized(&self) -> bool {
        self.authority != Pubkey::default()
    }

    pub fn validate_authority(&self, authority: &Pubkey) -> Result<()> {
        require_keys_eq!(
            *authority,
            self.authority,
            ErrorCode::Unauthorized
        );
        Ok(())
    }

    pub fn is_active(&self, clock: &Clock) -> bool {
        !self.paused && clock.unix_timestamp >= self.start_time
    }
}

// Usage in instruction
pub fn update_vault(ctx: Context<UpdateVault>, new_rate: u64) -> Result<()> {
    let vault = &mut ctx.accounts.vault;

    vault.validate_authority(&ctx.accounts.authority.key())?;
    vault.reward_rate = new_rate;

    Ok(())
}
```

## Vec and Dynamic Data

```rust
#[account]
pub struct DynamicAccount {
    pub authority: Pubkey,      // 32
    pub count: u32,             // 4
    pub items: Vec<Item>,       // 4 (vec length) + count * Item::SIZE
}

#[derive(AnchorSerialize, AnchorDeserialize, Clone)]
pub struct Item {
    pub id: u64,                // 8
    pub value: u64,             // 8
    pub timestamp: i64,         // 8
}

impl Item {
    pub const SIZE: usize = 8 + 8 + 8;
}

impl DynamicAccount {
    pub fn space(max_items: u32) -> usize {
        8 + 32 + 4 + 4 + (max_items as usize * Item::SIZE)
    }
}

// Initialize with max capacity
#[account(
    init,
    payer = payer,
    space = DynamicAccount::space(100),  // Max 100 items
)]
pub account: Account<'info, DynamicAccount>,
```
