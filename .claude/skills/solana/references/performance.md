# Performance Optimization

Performance optimization patterns for Solana/Anchor programs.

## Table of Contents

1. [Minimize Compute Units](#minimize-compute-units)
2. [Batch Operations](#batch-operations)
3. [Optimize Account Size](#optimize-account-size)
4. [Reuse Accounts](#reuse-accounts)

## Minimize Compute Units

```rust
// Avoid unnecessary allocations
// BAD: Creates new Vec
let items: Vec<_> = (0..100).collect();
for item in items.iter() {
    process(item);
}

// GOOD: Use iterator directly
for item in 0..100 {
    process(item);
}

// Avoid cloning when possible
// BAD
let vault_copy = vault.clone();
process(&vault_copy);

// GOOD
process(&vault);
```

## Batch Operations

```rust
// Process multiple items in one transaction when possible
pub fn batch_claim(ctx: Context<BatchClaim>, stake_ids: Vec<u64>) -> Result<()> {
    require!(stake_ids.len() <= MAX_BATCH_SIZE, ErrorCode::BatchTooLarge);

    for stake_id in stake_ids {
        claim_single(&ctx, stake_id)?;
    }

    Ok(())
}
```

## Optimize Account Size

```rust
// Use smallest types possible
#[account]
pub struct CompactStake {
    pub amount: u64,        // 8 bytes (up to 18.4 ETH worth at $1000/ETH)
    pub start_time: i64,    // 8 bytes (Unix timestamp)
    pub duration: u32,      // 4 bytes (up to 136 years)
    pub claimed: bool,      // 1 byte
    pub bump: u8,           // 1 byte
    // Total: 22 bytes vs 41 bytes if using u128/u64 everywhere
}
```

## Reuse Accounts

```rust
// Instead of creating new accounts, update existing ones
pub fn update_stake(ctx: Context<UpdateStake>, additional_amount: u64) -> Result<()> {
    let stake = &mut ctx.accounts.stake;

    stake.amount = stake.amount
        .checked_add(additional_amount)
        .ok_or(ErrorCode::Overflow)?;

    stake.last_update = Clock::get()?.unix_timestamp;

    Ok(())
}
```
