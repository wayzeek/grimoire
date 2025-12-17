# Blockchain Indexing Patterns

Common patterns for indexing blockchain events, handling reorgs, and processing on-chain data efficiently.

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

## Database Storage Patterns

### Store Event Data

```typescript
import { Pool } from 'pg'

const pool = new Pool({ connectionString: process.env.DATABASE_URL })

interface TransferEvent {
  transactionHash: string
  blockNumber: bigint
  from: string
  to: string
  value: bigint
  timestamp: number
}

async function storeTransfer(event: TransferEvent) {
  await pool.query(
    `INSERT INTO transfers (tx_hash, block_number, from_address, to_address, value, timestamp)
     VALUES ($1, $2, $3, $4, $5, $6)
     ON CONFLICT (tx_hash, from_address, to_address) DO NOTHING`,
    [
      event.transactionHash,
      event.blockNumber.toString(),
      event.from.toLowerCase(),
      event.to.toLowerCase(),
      event.value.toString(),
      event.timestamp,
    ]
  )
}
```

### Query Indexed Data

```typescript
// Get user transfer history
async function getUserTransfers(address: string, limit = 100) {
  const result = await pool.query(
    `SELECT * FROM transfers
     WHERE from_address = $1 OR to_address = $1
     ORDER BY block_number DESC, timestamp DESC
     LIMIT $2`,
    [address.toLowerCase(), limit]
  )
  return result.rows
}

// Get token holders
async function getTopHolders(limit = 100) {
  const result = await pool.query(
    `SELECT to_address as holder, SUM(value::numeric) as balance
     FROM transfers
     GROUP BY to_address
     ORDER BY balance DESC
     LIMIT $1`,
    [limit]
  )
  return result.rows
}
```

## Complete Indexer Example

### Input: Smart Contract Events
```solidity
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
```

### Output: Processed and Stored Data
```typescript
import { createPublicClient, http, parseAbiItem, formatUnits } from 'viem'
import { mainnet } from 'viem/chains'

class TokenIndexer {
  private client
  private lastProcessedBlock: bigint = 0n
  private readonly BATCH_SIZE = 5000n
  private readonly CONFIRMATIONS = 12n

  constructor(
    private contractAddress: `0x${string}`,
    private startBlock: bigint
  ) {
    this.client = createPublicClient({
      chain: mainnet,
      transport: http(process.env.RPC_URL),
    })
  }

  async start() {
    console.log('Starting indexer...')

    // Restore from checkpoint
    this.lastProcessedBlock = await this.getCheckpoint() || this.startBlock

    // Backfill historical data
    await this.backfill()

    // Watch for new events
    this.watch()
  }

  private async backfill() {
    const currentBlock = await this.client.getBlockNumber()
    const safeBlock = currentBlock - this.CONFIRMATIONS

    console.log(`Backfilling from ${this.lastProcessedBlock} to ${safeBlock}`)

    for (
      let start = this.lastProcessedBlock;
      start <= safeBlock;
      start += this.BATCH_SIZE
    ) {
      const end = start + this.BATCH_SIZE - 1n > safeBlock
        ? safeBlock
        : start + this.BATCH_SIZE - 1n

      console.log(`Processing blocks ${start} to ${end}`)

      const logs = await this.client.getLogs({
        address: this.contractAddress,
        event: parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)'),
        fromBlock: start,
        toBlock: end,
      })

      await this.processLogs(logs)
      await this.saveCheckpoint(end)
      this.lastProcessedBlock = end

      // Avoid rate limiting
      await new Promise(resolve => setTimeout(resolve, 100))
    }

    console.log('Backfill complete')
  }

  private watch() {
    console.log('Watching for new events...')

    this.client.watchEvent({
      address: this.contractAddress,
      event: parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)'),
      onLogs: async (logs) => {
        console.log(`Received ${logs.length} new events`)
        await this.processLogs(logs)
      },
    })
  }

  private async processLogs(logs: any[]) {
    for (const log of logs) {
      const block = await this.client.getBlock({ blockNumber: log.blockNumber })

      await storeTransfer({
        transactionHash: log.transactionHash,
        blockNumber: log.blockNumber,
        from: log.args.from,
        to: log.args.to,
        value: log.args.value,
        timestamp: Number(block.timestamp),
      })
    }
  }

  private async getCheckpoint(): Promise<bigint | null> {
    const result = await pool.query(
      'SELECT block_number FROM indexer_checkpoint WHERE indexer_name = $1',
      ['token_indexer']
    )
    return result.rows[0] ? BigInt(result.rows[0].block_number) : null
  }

  private async saveCheckpoint(blockNumber: bigint) {
    await pool.query(
      `INSERT INTO indexer_checkpoint (indexer_name, block_number, updated_at)
       VALUES ($1, $2, NOW())
       ON CONFLICT (indexer_name)
       DO UPDATE SET block_number = $2, updated_at = NOW()`,
      ['token_indexer', blockNumber.toString()]
    )
  }
}

// Usage
const indexer = new TokenIndexer(
  '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', // USDC
  17000000n // Start block
)

indexer.start()
```

### Expected Database Schema
```sql
CREATE TABLE transfers (
  id SERIAL PRIMARY KEY,
  tx_hash VARCHAR(66) NOT NULL,
  block_number BIGINT NOT NULL,
  from_address VARCHAR(42) NOT NULL,
  to_address VARCHAR(42) NOT NULL,
  value NUMERIC(78, 0) NOT NULL,
  timestamp INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE (tx_hash, from_address, to_address)
);

CREATE INDEX idx_transfers_from ON transfers(from_address);
CREATE INDEX idx_transfers_to ON transfers(to_address);
CREATE INDEX idx_transfers_block ON transfers(block_number);

CREATE TABLE indexer_checkpoint (
  indexer_name VARCHAR(100) PRIMARY KEY,
  block_number BIGINT NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW()
);
```

## Error Handling

```typescript
async function robustEventProcessing(log: any, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      await processLog(log)
      return
    } catch (error) {
      console.error(`Attempt ${i + 1} failed:`, error)

      if (i === retries - 1) {
        // Log to dead letter queue
        await pool.query(
          'INSERT INTO failed_events (log_data, error, attempts) VALUES ($1, $2, $3)',
          [JSON.stringify(log), error.message, retries]
        )
        throw error
      }

      // Exponential backoff
      await new Promise(resolve => setTimeout(resolve, 1000 * Math.pow(2, i)))
    }
  }
}
```

## Performance Tips

1. **Batch database inserts** instead of individual queries
2. **Use indexes** on frequently queried columns (addresses, block numbers)
3. **Process blocks in parallel** with rate limiting
4. **Cache RPC calls** for block data
5. **Use materialized views** for complex aggregations
6. **Partition tables** by block range for large datasets
7. **Monitor RPC quota usage** and implement backoff
