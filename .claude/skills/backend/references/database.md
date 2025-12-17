# Database Patterns

Repository pattern, transactions, and optimization for backend databases.
## Database Patterns

### Repository Pattern

```typescript
// GOOD: Repository abstraction
interface Repository<T> {
  findById(id: string): Promise<T | null>;
  findMany(filter?: any): Promise<T[]>;
  create(data: any): Promise<T>;
  update(id: string, data: any): Promise<T>;
  delete(id: string): Promise<void>;
}

export class UserRepository implements Repository<User> {
  constructor(private db: PrismaClient) {}

  async findById(id: string): Promise<User | null> {
    return this.db.user.findUnique({ where: { id } });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.db.user.findUnique({ where: { email } });
  }

  async findMany(filter: UserFilter = {}): Promise<User[]> {
    return this.db.user.findMany({
      where: this.buildWhereClause(filter),
      skip: filter.offset,
      take: filter.limit,
      orderBy: filter.orderBy,
    });
  }

  async create(data: CreateUserInput): Promise<User> {
    return this.db.user.create({ data });
  }

  async update(id: string, data: UpdateUserInput): Promise<User> {
    return this.db.user.update({
      where: { id },
      data,
    });
  }

  async delete(id: string): Promise<void> {
    await this.db.user.delete({ where: { id } });
  }

  private buildWhereClause(filter: UserFilter) {
    const where: any = {};

    if (filter.search) {
      where.OR = [
        { email: { contains: filter.search, mode: 'insensitive' } },
        { name: { contains: filter.search, mode: 'insensitive' } },
      ];
    }

    if (filter.role) {
      where.role = filter.role;
    }

    return where;
  }
}
```

### Transaction Management

```typescript
// GOOD: Transaction wrapper
export async function withTransaction<T>(
  callback: (tx: Prisma.TransactionClient) => Promise<T>
): Promise<T> {
  return db.$transaction(callback, {
    maxWait: 5000,
    timeout: 10000,
  });
}

// Usage example
export async function transferTokens(
  fromUserId: string,
  toUserId: string,
  amount: number
) {
  return withTransaction(async (tx) => {
    // Deduct from sender
    await tx.user.update({
      where: { id: fromUserId },
      data: { balance: { decrement: amount } },
    });

    // Add to receiver
    await tx.user.update({
      where: { id: toUserId },
      data: { balance: { increment: amount } },
    });

    // Create transaction record
    const transaction = await tx.transaction.create({
      data: {
        fromUserId,
        toUserId,
        amount,
        type: 'TRANSFER',
      },
    });

    return transaction;
  });
}
```

### Query Optimization

```typescript
// BAD: N+1 query problem
const users = await db.user.findMany();
for (const user of users) {
  const posts = await db.post.findMany({ where: { userId: user.id } });
  user.posts = posts; // N queries
}

// GOOD: Use includes
const users = await db.user.findMany({
  include: {
    posts: true,
  },
});

// GOOD: Pagination with cursor
export async function getPaginatedPosts(cursor?: string, limit = 20) {
  return db.post.findMany({
    take: limit + 1, // Fetch one extra to check if there's more
    cursor: cursor ? { id: cursor } : undefined,
    orderBy: { createdAt: 'desc' },
    include: {
      author: {
        select: { id: true, name: true, avatar: true },
      },
    },
  });
}

// GOOD: Select only needed fields
const users = await db.user.findMany({
  select: {
    id: true,
    email: true,
    name: true,
    // Don't fetch password, sessions, etc.
  },
});
```

### Database Connection Management

```typescript
// GOOD: Singleton Prisma client
import { PrismaClient } from '@prisma/client';

declare global {
  var prisma: PrismaClient | undefined;
}

export const db = global.prisma || new PrismaClient({
  log: process.env.NODE_ENV === 'development'
    ? ['query', 'error', 'warn']
    : ['error'],
});

if (process.env.NODE_ENV !== 'production') {
  global.prisma = db;
}

// Graceful shutdown
process.on('beforeExit', async () => {
  await db.$disconnect();
});
```

