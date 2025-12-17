# API Design

REST API conventions and response format standards for backend development.
## API Design Patterns

### REST Conventions

```typescript
// GOOD: RESTful endpoint structure
// Resource-based URLs (nouns, not verbs)
GET    /api/v1/users              // List users
GET    /api/v1/users/:id          // Get user
POST   /api/v1/users              // Create user
PUT    /api/v1/users/:id          // Update user (full)
PATCH  /api/v1/users/:id          // Update user (partial)
DELETE /api/v1/users/:id          // Delete user

// Nested resources
GET    /api/v1/users/:id/posts    // User's posts
POST   /api/v1/users/:id/posts    // Create post for user

// Actions (when REST doesn't fit)
POST   /api/v1/users/:id/verify   // Verify user
POST   /api/v1/orders/:id/cancel  // Cancel order

// BAD: Verb-based URLs
POST   /api/v1/createUser
GET    /api/v1/getUserById
POST   /api/v1/verifyUserEmail
```

### Response Format Standards

```typescript
// GOOD: Consistent response structure
interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: Record<string, any>;
  };
  meta?: {
    timestamp: string;
    requestId: string;
  };
}

// Success response
{
  "success": true,
  "data": {
    "id": "123",
    "name": "John Doe",
    "email": "john@example.com"
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "requestId": "req_abc123"
  }
}

// Error response
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "email": "Invalid email format"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "requestId": "req_abc123"
  }
}

// Paginated response
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "requestId": "req_abc123"
  }
}
```

### Status Code Usage

```typescript
// GOOD: Appropriate HTTP status codes
import { StatusCodes } from 'http-status-codes';

// Success
200 OK                    // Successful GET, PUT, PATCH
201 Created              // Successful POST
204 No Content           // Successful DELETE

// Client Errors
400 Bad Request          // Invalid input
401 Unauthorized         // Not authenticated
403 Forbidden            // Not authorized
404 Not Found            // Resource doesn't exist
409 Conflict             // Duplicate resource
422 Unprocessable Entity // Validation error
429 Too Many Requests    // Rate limit exceeded

// Server Errors
500 Internal Server Error
503 Service Unavailable

// Example implementation
app.post('/api/v1/users', async (req, res) => {
  try {
    const user = await createUser(req.body);
    return res.status(StatusCodes.CREATED).json({
      success: true,
      data: user,
    });
  } catch (error) {
    if (error instanceof ValidationError) {
      return res.status(StatusCodes.UNPROCESSABLE_ENTITY).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: error.message,
          details: error.details,
        },
      });
    }

    if (error instanceof DuplicateError) {
      return res.status(StatusCodes.CONFLICT).json({
        success: false,
        error: {
          code: 'DUPLICATE_RESOURCE',
          message: 'User already exists',
        },
      });
    }

    throw error; // Let error handler catch it
  }
});
```

### Request Validation

```typescript
// GOOD: Middleware-based validation
import { z } from 'zod';
import { Request, Response, NextFunction } from 'express';

// Define schemas
const createUserSchema = z.object({
  body: z.object({
    email: z.string().email(),
    password: z.string().min(8),
    name: z.string().min(1).max(100),
    role: z.enum(['user', 'admin']).optional().default('user'),
  }),
});

const getUserSchema = z.object({
  params: z.object({
    id: z.string().uuid(),
  }),
  query: z.object({
    include: z.array(z.string()).optional(),
  }),
});

// Validation middleware
function validate<T extends z.ZodType>(schema: T) {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      const validated = await schema.parseAsync({
        body: req.body,
        query: req.query,
        params: req.params,
      });

      // Replace with validated data
      req.body = validated.body;
      req.query = validated.query;
      req.params = validated.params;

      next();
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(StatusCodes.UNPROCESSABLE_ENTITY).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Invalid request data',
            details: error.errors,
          },
        });
      }
      next(error);
    }
  };
}

// Usage
app.post('/api/v1/users', validate(createUserSchema), async (req, res) => {
  // req.body is now typed and validated
  const user = await createUser(req.body);
  res.json({ success: true, data: user });
});
```

