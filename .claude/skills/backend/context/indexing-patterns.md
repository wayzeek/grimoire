# Blockchain Indexing Patterns

## Event Listening

```typescript
import { createPublicClient, http, parseAbiItem } from 'viem'

const client = createPublicClient({
  chain: mainnet,
  transport: http(process.env.RPC_URL),
})

// Watch events in real-time
client.watchEvent({
  address: '0x...',
  event: parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)'),
  onLogs: async (logs) => {
    for (const log of logs) {
      await processTransfer(log)
    }
  },
})
```

## Historical Backfill

```typescript
async function backfill(fromBlock: bigint, toBlock: bigint, batchSize = 10000n) {
  for (let start = fromBlock; start <= toBlock; start += batchSize) {
    const end = start + batchSize - 1n > toBlock ? toBlock : start + batchSize - 1n

    const logs = await client.getLogs({
      address: '0x...',
      event: parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)'),
      fromBlock: start,
      toBlock: end,
    })

    await processLogs(logs)
    await saveCheckpoint(end)
  }
}
```

## Reorg Handling

```typescript
const CONFIRMATION_BLOCKS = 12n

async function processWithConfirmations() {
  const latestBlock = await client.getBlockNumber()
  const safeBlock = latestBlock - CONFIRMATION_BLOCKS

  // Only process confirmed blocks
  await backfill(lastProcessedBlock, safeBlock)
}
```

## Rate Limiting

```typescript
import pLimit from 'p-limit'

const limit = pLimit(10) // Max 10 concurrent requests

const promises = addresses.map((address) =>
  limit(() => fetchTokenData(address))
)
await Promise.all(promises)
```
