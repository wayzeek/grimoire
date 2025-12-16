# Node.js/Bun Backend Patterns

## Express API Structure

```typescript
import express from 'express'
import { z } from 'zod'

const app = express()
app.use(express.json())

// Validation middleware
const validateBody = (schema: z.ZodSchema) => (req, res, next) => {
  try {
    req.body = schema.parse(req.body)
    next()
  } catch (error) {
    res.status(400).json({ error: error.errors })
  }
}

// Route with validation
const createUserSchema = z.object({
  address: z.string().regex(/^0x[a-fA-F0-9]{40}$/),
  name: z.string().min(1),
})

app.post('/users', validateBody(createUserSchema), async (req, res) => {
  const user = await createUser(req.body)
  res.json(user)
})
```

## Error Handling

```typescript
class AppError extends Error {
  constructor(public statusCode: number, message: string) {
    super(message)
  }
}

app.use((err, req, res, next) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({ error: err.message })
  }
  console.error(err)
  res.status(500).json({ error: 'Internal server error' })
})
```

## Blockchain Integration

```typescript
import { createPublicClient, http } from 'viem'
import { mainnet } from 'viem/chains'

const client = createPublicClient({
  chain: mainnet,
  transport: http(process.env.RPC_URL),
})

app.get('/token/:address', async (req, res) => {
  const { address } = req.params

  const [name, symbol, totalSupply] = await Promise.all([
    client.readContract({
      address,
      abi: erc20Abi,
      functionName: 'name',
    }),
    client.readContract({
      address,
      abi: erc20Abi,
      functionName: 'symbol',
    }),
    client.readContract({
      address,
      abi: erc20Abi,
      functionName: 'totalSupply',
    }),
  ])

  res.json({ name, symbol, totalSupply: totalSupply.toString() })
})
```

## Database (Drizzle ORM)

```typescript
import { drizzle } from 'drizzle-orm/node-postgres'
import { pgTable, text, bigint } from 'drizzle-orm/pg-core'
import pg from 'pg'

const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL })
const db = drizzle(pool)

const users = pgTable('users', {
  id: bigint('id', { mode: 'number' }).primaryKey().generatedAlwaysAsIdentity(),
  address: text('address').notNull().unique(),
  name: text('name').notNull(),
})

// Query
const allUsers = await db.select().from(users)
const user = await db.select().from(users).where(eq(users.address, '0x...'))

// Insert
await db.insert(users).values({ address: '0x...', name: 'Alice' })

// Update
await db.update(users).set({ name: 'Bob' }).where(eq(users.id, 1))
```

## Caching with Redis

```typescript
import { createClient } from 'redis'

const redis = createClient({ url: process.env.REDIS_URL })
await redis.connect()

async function getWithCache(key: string, fetcher: () => Promise<any>, ttl = 3600) {
  const cached = await redis.get(key)
  if (cached) return JSON.parse(cached)

  const data = await fetcher()
  await redis.setEx(key, ttl, JSON.stringify(data))
  return data
}
```
