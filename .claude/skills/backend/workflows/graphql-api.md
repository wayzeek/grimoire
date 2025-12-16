# Create GraphQL API

Set up GraphQL API for blockchain or web2 data.

## Node.js (Apollo Server)

### Install

```bash
bun add @apollo/server graphql
```

### Create Server

```typescript
import { ApolloServer } from '@apollo/server'
import { startStandaloneServer } from '@apollo/server/standalone'

const typeDefs = `#graphql
  type Token {
    id: ID!
    address: String!
    name: String!
    symbol: String!
    totalSupply: String!
  }

  type Query {
    token(address: String!): Token
    tokens: [Token!]!
  }
`

const resolvers = {
  Query: {
    token: async (_: any, { address }: { address: string }) => {
      // Fetch from DB or blockchain
      return await getTokenInfo(address)
    },
    tokens: async () => {
      return await getAllTokens()
    },
  },
}

const server = new ApolloServer({ typeDefs, resolvers })
const { url } = await startStandaloneServer(server, { listen: { port: 4000 } })
console.log(`GraphQL server ready at ${url}`)
```

## Python (Strawberry)

### Install

```bash
pip install strawberry-graphql[fastapi]
```

### Create Schema

```python
import strawberry
from fastapi import FastAPI
from strawberry.fastapi import GraphQLRouter

@strawberry.type
class Token:
    id: str
    address: str
    name: str
    symbol: str
    total_supply: str

@strawberry.type
class Query:
    @strawberry.field
    async def token(self, address: str) -> Token:
        # Fetch token data
        return get_token_info(address)

    @strawberry.field
    async def tokens(self) -> list[Token]:
        return get_all_tokens()

schema = strawberry.Schema(query=Query)
graphql_app = GraphQLRouter(schema)

app = FastAPI()
app.include_router(graphql_app, prefix="/graphql")
```

## Output
- GraphQL API endpoint
- Type-safe queries
- Documentation via GraphiQL
