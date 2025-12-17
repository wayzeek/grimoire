# Authentication and Authorization

JWT, Web3 auth, and RBAC patterns for backend security.
## Authentication and Authorization

### JWT Authentication

```typescript
// GOOD: Secure JWT implementation
import jwt from 'jsonwebtoken';
import { Request, Response, NextFunction } from 'express';

interface JwtPayload {
  userId: string;
  email: string;
  role: string;
}

// Generate tokens
export function generateTokens(payload: JwtPayload) {
  const accessToken = jwt.sign(
    payload,
    process.env.JWT_ACCESS_SECRET!,
    { expiresIn: '15m' }
  );

  const refreshToken = jwt.sign(
    { userId: payload.userId },
    process.env.JWT_REFRESH_SECRET!,
    { expiresIn: '7d' }
  );

  return { accessToken, refreshToken };
}

// Verify token middleware
export function authenticate(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith('Bearer ')) {
    throw new UnauthorizedError('No token provided');
  }

  const token = authHeader.substring(7);

  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_ACCESS_SECRET!
    ) as JwtPayload;

    req.user = decoded;
    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      throw new UnauthorizedError('Token expired');
    }
    if (error instanceof jwt.JsonWebTokenError) {
      throw new UnauthorizedError('Invalid token');
    }
    throw error;
  }
}

// Refresh token endpoint
app.post('/api/v1/auth/refresh', async (req, res) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    throw new UnauthorizedError('Refresh token required');
  }

  try {
    const decoded = jwt.verify(
      refreshToken,
      process.env.JWT_REFRESH_SECRET!
    ) as { userId: string };

    const user = await getUserById(decoded.userId);
    const tokens = generateTokens({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    res.json({ success: true, data: tokens });
  } catch (error) {
    throw new UnauthorizedError('Invalid refresh token');
  }
});
```

### Web3 Signature Authentication

```typescript
// GOOD: Verify wallet signatures
import { verifyMessage } from 'viem';

interface NonceStore {
  get(address: string): Promise<string | null>;
  set(address: string, nonce: string, ttl: number): Promise<void>;
  delete(address: string): Promise<void>;
}

// Generate nonce for signing
app.post('/api/v1/auth/nonce', async (req, res) => {
  const { address } = req.body;

  if (!isAddress(address)) {
    throw new ValidationError('Invalid address');
  }

  const nonce = crypto.randomBytes(32).toString('hex');
  await nonceStore.set(address.toLowerCase(), nonce, 600); // 10 min TTL

  res.json({
    success: true,
    data: { nonce, message: `Sign this message to authenticate: ${nonce}` },
  });
});

// Verify signature and issue token
app.post('/api/v1/auth/verify', async (req, res) => {
  const { address, signature } = req.body;

  if (!isAddress(address) || !signature) {
    throw new ValidationError('Address and signature required');
  }

  const nonce = await nonceStore.get(address.toLowerCase());
  if (!nonce) {
    throw new UnauthorizedError('Nonce expired or not found');
  }

  const message = `Sign this message to authenticate: ${nonce}`;
  const isValid = await verifyMessage({
    address: address as `0x${string}`,
    message,
    signature: signature as `0x${string}`,
  });

  if (!isValid) {
    throw new UnauthorizedError('Invalid signature');
  }

  // Delete used nonce
  await nonceStore.delete(address.toLowerCase());

  // Get or create user
  let user = await db.user.findUnique({ where: { address: address.toLowerCase() } });
  if (!user) {
    user = await db.user.create({ data: { address: address.toLowerCase() } });
  }

  // Generate tokens
  const tokens = generateTokens({
    userId: user.id,
    email: user.address,
    role: user.role,
  });

  res.json({ success: true, data: { ...tokens, user } });
});
```

### Role-Based Access Control

```typescript
// GOOD: Flexible RBAC system
export enum Role {
  USER = 'user',
  ADMIN = 'admin',
  MODERATOR = 'moderator',
}

export enum Permission {
  READ_USER = 'read:user',
  WRITE_USER = 'write:user',
  DELETE_USER = 'delete:user',
  READ_ADMIN = 'read:admin',
  WRITE_ADMIN = 'write:admin',
}

const rolePermissions: Record<Role, Permission[]> = {
  [Role.USER]: [Permission.READ_USER],
  [Role.MODERATOR]: [Permission.READ_USER, Permission.WRITE_USER],
  [Role.ADMIN]: Object.values(Permission),
};

// Check role
export function requireRole(...roles: Role[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      throw new UnauthorizedError();
    }

    if (!roles.includes(req.user.role as Role)) {
      throw new ForbiddenError('Insufficient permissions');
    }

    next();
  };
}

// Check permission
export function requirePermission(...permissions: Permission[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      throw new UnauthorizedError();
    }

    const userPermissions = rolePermissions[req.user.role as Role] || [];
    const hasPermission = permissions.every(p => userPermissions.includes(p));

    if (!hasPermission) {
      throw new ForbiddenError('Insufficient permissions');
    }

    next();
  };
}

// Usage
app.get('/api/v1/admin/users',
  authenticate,
  requireRole(Role.ADMIN),
  async (req, res) => {
    const users = await getAllUsers();
    res.json({ success: true, data: users });
  }
);

app.delete('/api/v1/users/:id',
  authenticate,
  requirePermission(Permission.DELETE_USER),
  async (req, res) => {
    await deleteUser(req.params.id);
    res.status(StatusCodes.NO_CONTENT).send();
  }
);
```

