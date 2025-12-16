# Deploy Anchor Program

## Local Deployment

```bash
# Start local validator
solana-test-validator

# Deploy
anchor deploy
```

## Devnet Deployment

```bash
# Configure for devnet
solana config set --url devnet

# Airdrop SOL
solana airdrop 2

# Deploy
anchor deploy --provider.cluster devnet

# Verify
solana program show <PROGRAM_ID>
```

## Mainnet Deployment

```bash
# Configure
solana config set --url mainnet-beta

# Deploy (requires SOL for deployment)
anchor deploy --provider.cluster mainnet-beta

# Verify
anchor verify <PROGRAM_ID>
```

## Update Program

```bash
# Build
anchor build

# Upgrade
anchor upgrade <PROGRAM_ID> --provider.cluster <CLUSTER> --program-keypair <PATH>
```
