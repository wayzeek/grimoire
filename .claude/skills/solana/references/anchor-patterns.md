# Anchor Patterns

## Account Validation

```rust
#[derive(Accounts)]
pub struct Transfer<'info> {
    #[account(mut)]
    pub from: Account<'info, TokenAccount>,
    #[account(mut)]
    pub to: Account<'info, TokenAccount>,
    pub authority: Signer<'info>,
}
```

## PDA (Program Derived Address)

```rust
#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(
        init,
        payer = user,
        space = 8 + 32 + 8,
        seeds = [b"vault", user.key().as_ref()],
        bump
    )]
    pub vault: Account<'info, Vault>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}
```

## Error Handling

```rust
#[error_code]
pub enum ErrorCode {
    #[msg("Insufficient funds")]
    InsufficientFunds,
    #[msg("Unauthorized")]
    Unauthorized,
}

// Usage
require!(amount > 0, ErrorCode::InsufficientFunds);
```

## Testing

```typescript
import * as anchor from "@coral-xyz/anchor";

describe("my_program", () => {
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);
  const program = anchor.workspace.MyProgram;

  it("Initializes", async () => {
    const tx = await program.methods.initialize().rpc();
    console.log("Tx signature:", tx);
  });
});
```
