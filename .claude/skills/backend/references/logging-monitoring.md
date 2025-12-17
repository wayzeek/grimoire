# Logging and Monitoring

Winston and structured logging patterns for backend applications.
## Logging and Monitoring

### Structured Logging

```typescript
// GOOD: Winston structured logging
import winston from 'winston';

const logFormat = winston.format.combine(
  winston.format.timestamp(),
  winston.format.errors({ stack: true }),
  winston.format.json()
);

export const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: logFormat,
  defaultMeta: {
    service: 'api',
    environment: process.env.NODE_ENV,
  },
  transports: [
    // Console transport
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      ),
    }),

    // File transport for errors
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error',
    }),

    // File transport for all logs
    new winston.transports.File({
      filename: 'logs/combined.log',
    }),
  ],
});

// Request logging middleware
export function requestLogger(req: Request, res: Response, next: NextFunction) {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;

    logger.info('Request completed', {
      requestId: req.id,
      method: req.method,
      path: req.path,
      statusCode: res.statusCode,
      duration,
      ip: req.ip,
      userAgent: req.get('user-agent'),
      userId: req.user?.userId,
    });
  });

  next();
}

// Usage in application
app.use(requestLogger);

// Log in controllers
logger.info('User created', {
  userId: user.id,
  email: user.email,
  role: user.role,
});

logger.error('Failed to process transaction', {
  error: error.message,
  stack: error.stack,
  transactionId: txId,
  userId: user.id,
});
```

### Performance Tracking

```typescript
// GOOD: Track slow queries and operations
export async function trackPerformance<T>(
  operation: string,
  fn: () => Promise<T>,
  threshold = 1000
): Promise<T> {
  const start = Date.now();

  try {
    const result = await fn();
    const duration = Date.now() - start;

    if (duration > threshold) {
      logger.warn('Slow operation detected', {
        operation,
        duration,
        threshold,
      });
    }

    return result;
  } catch (error) {
    const duration = Date.now() - start;
    logger.error('Operation failed', {
      operation,
      duration,
      error: error instanceof Error ? error.message : String(error),
    });
    throw error;
  }
}

// Usage
const users = await trackPerformance(
  'getUsersWithPosts',
  () => db.user.findMany({ include: { posts: true } }),
  500 // Warn if takes longer than 500ms
);
```

### Health Checks

```typescript
// GOOD: Comprehensive health check endpoint
app.get('/health', async (req, res) => {
  const health = {
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    checks: {
      database: await checkDatabase(),
      redis: await checkRedis(),
      memory: checkMemory(),
    },
  };

  const isHealthy = Object.values(health.checks).every(check => check.status === 'ok');

  res.status(isHealthy ? StatusCodes.OK : StatusCodes.SERVICE_UNAVAILABLE)
    .json(health);
});

async function checkDatabase() {
  try {
    await db.$queryRaw`SELECT 1`;
    return { status: 'ok' };
  } catch (error) {
    return { status: 'error', message: error.message };
  }
}

async function checkRedis() {
  try {
    await redis.ping();
    return { status: 'ok' };
  } catch (error) {
    return { status: 'error', message: error.message };
  }
}

function checkMemory() {
  const usage = process.memoryUsage();
  const mb = (bytes: number) => Math.round(bytes / 1024 / 1024);

  return {
    status: 'ok',
    heapUsed: `${mb(usage.heapUsed)}MB`,
    heapTotal: `${mb(usage.heapTotal)}MB`,
    rss: `${mb(usage.rss)}MB`,
  };
}
```

