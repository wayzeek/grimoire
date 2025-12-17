# Testing Standards

Testing standards and patterns for Solana/Anchor programs.

## Table of Contents

1. [Test Organization](#test-organization)
2. [Integration Tests](#integration-tests)

## Test Organization

```typescript
import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { StakingProgram } from "../target/types/staking_program";
import { PublicKey, Keypair, LAMPORTS_PER_SOL } from "@solana/web3.js";
import { assert } from "chai";

describe("staking-program", () => {
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const program = anchor.workspace.StakingProgram as Program<StakingProgram>;

  let authority: Keypair;
  let user: Keypair;
  let mint: PublicKey;
  let vaultPda: PublicKey;
  let vaultBump: number;

  before(async () => {
    // Setup: create keypairs, mint, etc.
    authority = Keypair.generate();
    user = Keypair.generate();

    await airdrop(provider.connection, authority.publicKey, 10 * LAMPORTS_PER_SOL);
    await airdrop(provider.connection, user.publicKey, 10 * LAMPORTS_PER_SOL);

    // Create mint
    mint = await createMint(
      provider.connection,
      authority,
      authority.publicKey,
      null,
      6
    );

    [vaultPda, vaultBump] = PublicKey.findProgramAddressSync(
      [Buffer.from("vault"), mint.toBuffer()],
      program.programId
    );
  });

  describe("initialize", () => {
    it("successfully initializes vault", async () => {
      await program.methods
        .initialize({
          rewardRate: new anchor.BN(1000),
          minStakeAmount: new anchor.BN(100),
          maxStakeAmount: new anchor.BN(1000000),
          minDuration: new anchor.BN(86400),
          maxDuration: new anchor.BN(31536000),
        })
        .accounts({
          vault: vaultPda,
          authority: authority.publicKey,
          mint,
          systemProgram: anchor.web3.SystemProgram.programId,
        })
        .signers([authority])
        .rpc();

      const vaultAccount = await program.account.vault.fetch(vaultPda);
      assert.equal(vaultAccount.authority.toBase58(), authority.publicKey.toBase58());
      assert.equal(vaultAccount.bump, vaultBump);
      assert.equal(vaultAccount.rewardRate.toNumber(), 1000);
    });

    it("fails when called by non-authority", async () => {
      try {
        await program.methods
          .initialize(/* params */)
          .accounts({
            authority: user.publicKey,
            // ...
          })
          .signers([user])
          .rpc();

        assert.fail("Expected error");
      } catch (err) {
        assert.include(err.toString(), "Unauthorized");
      }
    });
  });

  describe("stake", () => {
    it("successfully stakes tokens", async () => {
      const amount = new anchor.BN(1000);
      const duration = new anchor.BN(86400);

      const [userStakePda] = PublicKey.findProgramAddressSync(
        [Buffer.from("user_stake"), user.publicKey.toBuffer()],
        program.programId
      );

      await program.methods
        .stake(amount, duration)
        .accounts({
          user: user.publicKey,
          vault: vaultPda,
          userStake: userStakePda,
          // ...
        })
        .signers([user])
        .rpc();

      const userStakeAccount = await program.account.userStake.fetch(userStakePda);
      assert.equal(userStakeAccount.amount.toNumber(), amount.toNumber());
    });

    it("fails with insufficient balance", async () => {
      const largeAmount = new anchor.BN(1000000000);

      try {
        await program.methods
          .stake(largeAmount, new anchor.BN(86400))
          .accounts({ /* ... */ })
          .signers([user])
          .rpc();

        assert.fail("Expected error");
      } catch (err) {
        assert.include(err.toString(), "InsufficientFunds");
      }
    });
  });
});

// Helper functions
async function airdrop(connection: Connection, pubkey: PublicKey, amount: number) {
  const sig = await connection.requestAirdrop(pubkey, amount);
  await connection.confirmTransaction(sig);
}
```

## Integration Tests

```typescript
describe("integration: stake and claim flow", () => {
  it("allows user to stake, wait, and claim rewards", async () => {
    // 1. Stake tokens
    await program.methods.stake(amount, duration)
      .accounts({ /* ... */ })
      .signers([user])
      .rpc();

    // 2. Fast forward time (devnet/localnet only)
    await sleep(duration * 1000);

    // 3. Claim rewards
    const tx = await program.methods.claim()
      .accounts({ /* ... */ })
      .signers([user])
      .rpc();

    // 4. Verify rewards received
    const userTokenAccount = await getAccount(connection, userTokenAccountPubkey);
    assert.isTrue(userTokenAccount.amount > initialAmount);
  });
});
```
