# Performance Optimization

Caching and optimization patterns for backend applications.
## Performance Optimization

### Caching

```typescript
// GOOD: Redis caching layer
import { createClient } from 'redis';

const redis = createClient({ url: process.env.REDIS_URL });

export async function cached<T>(
  key: string,
  ttl: number,
  fn: () => Promise<T>
): Promise<T> {
  // Try to get from cache
  const cached = await redis.get(key);
  if (cached) {
    return JSON.parse(cached);
  }

  // Execute function and cache result
  const result = await fn();
  await redis.setEx(key, ttl, JSON.stringify(result));

  return result;
}

// Usage
export async function getUserById(id: string) {
  return cached(
    `user:${id}`,
    3600, // 1 hour
    () => db.user.findUnique({ where: { id } })
  );
}

// Invalidate cache
export async function updateUser(id: string, data: UpdateUserInput) {
  const user = await db.user.update({ where: { id }, data });
  await redis.del(`user:${id}`);
  return user;
}
```

### Response Compression

```typescript
// GOOD: Compress responses
import compression from 'compression';

app.use(compression({
  filter: (req, res) => {
    if (req.headers['x-no-compression']) {
      return false;
    }
    return compression.filter(req, res);
  },
  level: 6,
  threshold: 1024, // Only compress responses > 1KB
}));
```

### Database Connection Pooling

```typescript
// GOOD: Configure connection pool
const db = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
  // Connection pool configuration
  // Note: Prisma handles this automatically, but these env vars control it:
  // DATABASE_URL="postgresql://user:password@localhost:5432/db?connection_limit=20"
});
```
