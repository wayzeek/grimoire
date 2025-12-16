# GraphQL API Patterns

## Schema Design

```graphql
type Token {
  id: ID!
  address: String!
  name: String!
  symbol: String!
  totalSupply: BigInt!
  holders: [Holder!]!
}

type Holder {
  id: ID!
  address: String!
  balance: BigInt!
  token: Token!
}

type Query {
  token(address: String!): Token
  tokens(limit: Int = 10, offset: Int = 0): [Token!]!
  holder(address: String!, tokenAddress: String!): Holder
}

scalar BigInt
```

## DataLoader Pattern

```typescript
import DataLoader from 'dataloader'

const tokenLoader = new DataLoader(async (addresses: string[]) => {
  const tokens = await db.select().from(tokensTable).where(inArray(tokensTable.address, addresses))
  return addresses.map((addr) => tokens.find((t) => t.address === addr))
})

// Use in resolver
const token = await tokenLoader.load(address)
```

## Pagination

```typescript
type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}

type TokenConnection {
  edges: [TokenEdge!]!
  pageInfo: PageInfo!
}

type TokenEdge {
  node: Token!
  cursor: String!
}
```
