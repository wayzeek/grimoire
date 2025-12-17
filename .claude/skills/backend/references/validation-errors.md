# Validation and Error Handling

Validation schemas and error hierarchies using Zod for backend development.
## Validation and Error Handling

### Error Hierarchy

```typescript
// GOOD: Custom error classes
export class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string,
    public details?: Record<string, any>
  ) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

export class ValidationError extends AppError {
  constructor(message: string, details?: Record<string, any>) {
    super(StatusCodes.UNPROCESSABLE_ENTITY, 'VALIDATION_ERROR', message, details);
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string, id?: string) {
    super(
      StatusCodes.NOT_FOUND,
      'NOT_FOUND',
      `${resource}${id ? ` with id ${id}` : ''} not found`
    );
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Not authenticated') {
    super(StatusCodes.UNAUTHORIZED, 'UNAUTHORIZED', message);
  }
}

export class ForbiddenError extends AppError {
  constructor(message = 'Not authorized') {
    super(StatusCodes.FORBIDDEN, 'FORBIDDEN', message);
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super(StatusCodes.CONFLICT, 'CONFLICT', message);
  }
}

// Usage
async function getUserById(id: string) {
  const user = await db.user.findUnique({ where: { id } });
  if (!user) {
    throw new NotFoundError('User', id);
  }
  return user;
}

async function createUser(data: CreateUserInput) {
  const existing = await db.user.findUnique({ where: { email: data.email } });
  if (existing) {
    throw new ConflictError('User with this email already exists');
  }
  return db.user.create({ data });
}
```

### Global Error Handler

```typescript
// GOOD: Centralized error handling
import { Request, Response, NextFunction } from 'express';
import { logger } from './logger';

export function errorHandler(
  error: Error,
  req: Request,
  res: Response,
  next: NextFunction
) {
  // Log error with context
  logger.error('Request failed', {
    error: {
      name: error.name,
      message: error.message,
      stack: error.stack,
    },
    request: {
      method: req.method,
      path: req.path,
      query: req.query,
      body: req.body,
      ip: req.ip,
      userAgent: req.get('user-agent'),
    },
  });

  // Handle known errors
  if (error instanceof AppError) {
    return res.status(error.statusCode).json({
      success: false,
      error: {
        code: error.code,
        message: error.message,
        details: error.details,
      },
    });
  }

  // Handle Prisma errors
  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    if (error.code === 'P2002') {
      return res.status(StatusCodes.CONFLICT).json({
        success: false,
        error: {
          code: 'DUPLICATE_ENTRY',
          message: 'A record with this value already exists',
        },
      });
    }
  }

  // Handle unexpected errors
  res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message: process.env.NODE_ENV === 'production'
        ? 'An unexpected error occurred'
        : error.message,
    },
  });
}

// Mount at the end of middleware chain
app.use(errorHandler);
```

### Async Error Handling

```typescript
// GOOD: Async wrapper utility
export function asyncHandler<T>(
  fn: (req: Request, res: Response, next: NextFunction) => Promise<T>
) {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

// Usage
app.get('/api/v1/users/:id', asyncHandler(async (req, res) => {
  const user = await getUserById(req.params.id);
  res.json({ success: true, data: user });
}));

// Or use express-async-errors package
import 'express-async-errors';

app.get('/api/v1/users/:id', async (req, res) => {
  const user = await getUserById(req.params.id);
  res.json({ success: true, data: user });
});
```

