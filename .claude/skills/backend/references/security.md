# Security Patterns

Rate limiting, CORS, and security headers for backend applications.
## Rate Limiting and Security

### Rate Limiting

```typescript
// GOOD: Redis-backed rate limiting
import { createClient } from 'redis';
import { Request, Response, NextFunction } from 'express';

const redis = createClient({ url: process.env.REDIS_URL });

interface RateLimitOptions {
  windowMs: number;
  max: number;
  keyGenerator?: (req: Request) => string;
}

export function rateLimit(options: RateLimitOptions) {
  const { windowMs, max, keyGenerator = (req) => req.ip } = options;

  return async (req: Request, res: Response, next: NextFunction) => {
    const key = `ratelimit:${keyGenerator(req)}`;
    const now = Date.now();
    const windowStart = now - windowMs;

    try {
      // Remove old entries and add current request
      await redis.zRemRangeByScore(key, 0, windowStart);
      await redis.zAdd(key, { score: now, value: now.toString() });
      await redis.expire(key, Math.ceil(windowMs / 1000));

      // Count requests in window
      const count = await redis.zCard(key);

      res.setHeader('X-RateLimit-Limit', max);
      res.setHeader('X-RateLimit-Remaining', Math.max(0, max - count));

      if (count > max) {
        throw new AppError(
          StatusCodes.TOO_MANY_REQUESTS,
          'RATE_LIMIT_EXCEEDED',
          'Too many requests, please try again later'
        );
      }

      next();
    } catch (error) {
      next(error);
    }
  };
}

// Usage
app.use('/api/v1/auth', rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 requests per window
}));

app.use('/api/v1', rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 100, // 100 requests per minute
  keyGenerator: (req) => req.user?.userId || req.ip,
}));
```

### Security Middleware

```typescript
// GOOD: Security hardening
import helmet from 'helmet';
import cors from 'cors';
import mongoSanitize from 'express-mongo-sanitize';

// Helmet for security headers
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true,
  },
}));

// CORS configuration
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || [],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// NoSQL injection prevention
app.use(mongoSanitize());

// Request size limits
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request ID for tracking
app.use((req, res, next) => {
  req.id = crypto.randomUUID();
  res.setHeader('X-Request-ID', req.id);
  next();
});
```

### Input Sanitization

```typescript
// GOOD: Sanitize user input
import DOMPurify from 'isomorphic-dompurify';

export function sanitizeHtml(dirty: string): string {
  return DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
    ALLOWED_ATTR: ['href'],
  });
}

export function sanitizeObject<T extends Record<string, any>>(obj: T): T {
  const sanitized = {} as T;

  for (const [key, value] of Object.entries(obj)) {
    if (typeof value === 'string') {
      sanitized[key as keyof T] = sanitizeHtml(value) as T[keyof T];
    } else if (Array.isArray(value)) {
      sanitized[key as keyof T] = value.map(v =>
        typeof v === 'string' ? sanitizeHtml(v) : v
      ) as T[keyof T];
    } else if (typeof value === 'object' && value !== null) {
      sanitized[key as keyof T] = sanitizeObject(value);
    } else {
      sanitized[key as keyof T] = value;
    }
  }

  return sanitized;
}
```

