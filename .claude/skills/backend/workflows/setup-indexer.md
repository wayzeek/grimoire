# Setup Blockchain Indexer

Create an indexer to listen for blockchain events and store data in a database.

## Node.js/Bun Indexer

### Install Dependencies

```bash
bun add viem
bun add pg drizzle-orm
```

### Create Event Listener

`src/services/indexer.ts`:

```typescript
import { createPublicClient, http, parseAbiItem } from 'viem'
import { mainnet } from 'viem/chains'

const client = createPublicClient({
  chain: mainnet,
  transport: http(process.env.RPC_URL),
})

// Listen for Transfer events
const unwatch = client.watchEvent({
  address: '0x...', // Contract address
  event: parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)'),
  onLogs: (logs) => {
    logs.forEach(async (log) => {
      await saveTransferEvent(log)
    })
  },
})

async function saveTransferEvent(log: any) {
  // Save to database
  const { from, to, value } = log.args
  await db.insert(transfers).values({
    from,
    to,
    value: value.toString(),
    blockNumber: log.blockNumber,
    transactionHash: log.transactionHash,
  })
}
```

### Backfill Historical Events

```typescript
async function backfillEvents(fromBlock: bigint, toBlock: bigint) {
  const logs = await client.getLogs({
    address: '0x...',
    event: parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)'),
    fromBlock,
    toBlock,
  })

  for (const log of logs) {
    await saveTransferEvent(log)
  }
}
```

### Database Schema (Drizzle)

`src/db/schema.ts`:

```typescript
import { pgTable, text, bigint, timestamp } from 'drizzle-orm/pg-core'

export const transfers = pgTable('transfers', {
  id: bigint('id', { mode: 'number' }).primaryKey().generatedAlwaysAsIdentity(),
  from: text('from').notNull(),
  to: text('to').notNull(),
  value: text('value').notNull(),
  blockNumber: bigint('block_number', { mode: 'bigint' }).notNull(),
  transactionHash: text('transaction_hash').notNull(),
  timestamp: timestamp('timestamp').defaultNow(),
})
```

## Using Subgraphs (The Graph)

### Install Graph CLI

```bash
npm install -g @graphprotocol/graph-cli
```

### Initialize Subgraph

```bash
graph init --from-contract <CONTRACT_ADDRESS>
```

### Define Schema

`schema.graphql`:

```graphql
type Transfer @entity {
  id: ID!
  from: Bytes!
  to: Bytes!
  value: BigInt!
  blockNumber: BigInt!
  timestamp: BigInt!
}
```

### Map Events

`src/mapping.ts`:

```typescript
import { Transfer as TransferEvent } from '../generated/Contract/Contract'
import { Transfer } from '../generated/schema'

export function handleTransfer(event: TransferEvent): void {
  let transfer = new Transfer(event.transaction.hash.toHex())
  transfer.from = event.params.from
  transfer.to = event.params.to
  transfer.value = event.params.value
  transfer.blockNumber = event.block.number
  transfer.timestamp = event.block.timestamp
  transfer.save()
}
```

## Using DipDup (Python)

### Install DipDup

```bash
pip install dipdup
```

### Configure

`dipdup.yaml`:

```yaml
spec_version: 2.0
package: my_indexer

database:
  kind: postgres
  host: localhost
  port: 5432
  user: user
  password: password
  database: indexer

contracts:
  my_contract:
    address: 0x...
    typename: ERC20

indexes:
  my_index:
    kind: evm.events
    datasource: ethereum
    handlers:
      - callback: on_transfer
        contract: my_contract
        name: Transfer
```

### Handler

`handlers/on_transfer.py`:

```python
from dipdup.context import HandlerContext
from dipdup.models.evm import EvmEvent

async def on_transfer(
    ctx: HandlerContext,
    event: EvmEvent,
) -> None:
    # Save to database
    pass
```

## Best Practices

1. **Error Handling**: Handle RPC errors, retries
2. **Block Confirmations**: Wait for confirmations before considering events final
3. **Reorg Handling**: Handle blockchain reorganizations
4. **Checkpointing**: Save last indexed block
5. **Rate Limiting**: Respect RPC rate limits
6. **Monitoring**: Track indexing progress
7. **Parallelization**: Index multiple contracts in parallel

## Output
- Working event indexer
- Database schema for events
- Historical data backfill
- Real-time event processing
