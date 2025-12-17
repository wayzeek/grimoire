# Testing Standards

Testing patterns and standards for backend applications.
## Testing Standards

### Unit Tests

```typescript
// GOOD: Comprehensive unit tests
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { UserService } from './user.service';
import { NotFoundError, ConflictError } from './errors';

describe('UserService', () => {
  let userService: UserService;
  let mockRepository: any;

  beforeEach(() => {
    mockRepository = {
      findById: vi.fn(),
      findByEmail: vi.fn(),
      create: vi.fn(),
      update: vi.fn(),
      delete: vi.fn(),
    };
    userService = new UserService(mockRepository);
  });

  describe('getUserById', () => {
    it('returns user when found', async () => {
      const user = { id: '123', email: 'test@example.com', name: 'Test' };
      mockRepository.findById.mockResolvedValue(user);

      const result = await userService.getUserById('123');

      expect(result).toEqual(user);
      expect(mockRepository.findById).toHaveBeenCalledWith('123');
    });

    it('throws NotFoundError when user not found', async () => {
      mockRepository.findById.mockResolvedValue(null);

      await expect(userService.getUserById('123'))
        .rejects.toThrow(NotFoundError);
    });
  });

  describe('createUser', () => {
    it('creates user successfully', async () => {
      const input = { email: 'test@example.com', password: 'password123', name: 'Test' };
      const created = { id: '123', ...input };

      mockRepository.findByEmail.mockResolvedValue(null);
      mockRepository.create.mockResolvedValue(created);

      const result = await userService.createUser(input);

      expect(result).toEqual(created);
      expect(mockRepository.create).toHaveBeenCalledWith(
        expect.objectContaining({ email: input.email })
      );
    });

    it('throws ConflictError when email exists', async () => {
      const input = { email: 'existing@example.com', password: 'password123', name: 'Test' };
      mockRepository.findByEmail.mockResolvedValue({ id: '456', email: input.email });

      await expect(userService.createUser(input))
        .rejects.toThrow(ConflictError);
    });

    it('hashes password before creating user', async () => {
      const input = { email: 'test@example.com', password: 'password123', name: 'Test' };
      mockRepository.findByEmail.mockResolvedValue(null);
      mockRepository.create.mockResolvedValue({ id: '123', ...input });

      await userService.createUser(input);

      expect(mockRepository.create).toHaveBeenCalledWith(
        expect.objectContaining({
          password: expect.not.stringContaining('password123'),
        })
      );
    });
  });
});
```

### Integration Tests

```typescript
// GOOD: Integration tests with real database
import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest';
import request from 'supertest';
import { app } from '../app';
import { db } from '../db';

describe('User API', () => {
  beforeAll(async () => {
    // Setup test database
    await db.$connect();
  });

  afterAll(async () => {
    await db.$disconnect();
  });

  beforeEach(async () => {
    // Clean database before each test
    await db.user.deleteMany();
  });

  describe('POST /api/v1/users', () => {
    it('creates a new user', async () => {
      const input = {
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
      };

      const response = await request(app)
        .post('/api/v1/users')
        .send(input)
        .expect(StatusCodes.CREATED);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toMatchObject({
        email: input.email,
        name: input.name,
      });
      expect(response.body.data.password).toBeUndefined();

      // Verify in database
      const user = await db.user.findUnique({
        where: { email: input.email },
      });
      expect(user).toBeTruthy();
    });

    it('returns 409 for duplicate email', async () => {
      const input = {
        email: 'duplicate@example.com',
        password: 'password123',
        name: 'Test User',
      };

      // Create first user
      await request(app).post('/api/v1/users').send(input);

      // Try to create duplicate
      const response = await request(app)
        .post('/api/v1/users')
        .send(input)
        .expect(StatusCodes.CONFLICT);

      expect(response.body.success).toBe(false);
      expect(response.body.error.code).toBe('CONFLICT');
    });
  });

  describe('GET /api/v1/users/:id', () => {
    it('returns user by id', async () => {
      const user = await db.user.create({
        data: {
          email: 'test@example.com',
          password: 'hashed',
          name: 'Test User',
        },
      });

      const response = await request(app)
        .get(`/api/v1/users/${user.id}`)
        .expect(StatusCodes.OK);

      expect(response.body.data).toMatchObject({
        id: user.id,
        email: user.email,
        name: user.name,
      });
    });

    it('returns 404 for non-existent user', async () => {
      const response = await request(app)
        .get('/api/v1/users/non-existent-id')
        .expect(StatusCodes.NOT_FOUND);

      expect(response.body.error.code).toBe('NOT_FOUND');
    });
  });
});
```

