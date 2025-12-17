# Testing Standards

Testing patterns and best practices for React applications.

## Table of Contents

1. [Component Testing](#component-testing)
2. [Hook Testing](#hook-testing)
3. [Integration Testing](#integration-testing)
4. [Error Boundaries](#error-boundaries)
5. [Form Validation](#form-validation)

## Testing Standards

### Component Testing

```typescript
// GOOD: Comprehensive component tests
import { render, screen, waitFor, userEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';

describe('WalletConnectButton', () => {
  it('renders connect button when disconnected', () => {
    render(<WalletConnectButton />);
    expect(screen.getByRole('button', { name: /connect/i })).toBeInTheDocument();
  });

  it('shows loading state while connecting', async () => {
    const { rerender } = render(<WalletConnectButton isConnecting={false} />);

    const button = screen.getByRole('button');
    await userEvent.click(button);

    rerender(<WalletConnectButton isConnecting={true} />);
    expect(screen.getByRole('button')).toBeDisabled();
  });

  it('displays address when connected', () => {
    const address = '0x1234567890123456789012345678901234567890';
    render(<WalletConnectButton address={address} />);
    expect(screen.getByText(/0x1234/)).toBeInTheDocument();
  });

  it('calls onConnect callback with address', async () => {
    const onConnect = vi.fn();
    render(<WalletConnectButton onConnect={onConnect} />);

    const button = screen.getByRole('button');
    await userEvent.click(button);

    await waitFor(() => {
      expect(onConnect).toHaveBeenCalledWith(expect.stringMatching(/^0x/));
    });
  });
});
```

### Hook Testing

```typescript
// GOOD: Test custom hooks
import { renderHook, waitFor } from '@testing-library/react';
import { describe, it, expect } from 'vitest';

describe('useTokenBalance', () => {
  it('returns null balance initially', () => {
    const { result } = renderHook(() =>
      useTokenBalance(TOKEN_ADDRESS, USER_ADDRESS)
    );

    expect(result.current.balance).toBeNull();
    expect(result.current.isLoading).toBe(true);
  });

  it('fetches and formats balance', async () => {
    const { result } = renderHook(() =>
      useTokenBalance(TOKEN_ADDRESS, USER_ADDRESS)
    );

    await waitFor(() => {
      expect(result.current.isLoading).toBe(false);
      expect(result.current.balance).toBe(1000000000000000000n);
      expect(result.current.formatted).toBe('1.0');
    });
  });

  it('handles errors gracefully', async () => {
    const { result } = renderHook(() =>
      useTokenBalance(INVALID_ADDRESS, USER_ADDRESS)
    );

    await waitFor(() => {
      expect(result.current.error).toBeTruthy();
      expect(result.current.balance).toBeNull();
    });
  });
});
```

### Integration Testing

```typescript
// GOOD: Test user flows
describe('Token Transfer Flow', () => {
  it('allows user to transfer tokens', async () => {
    const user = userEvent.setup();

    render(
      <WagmiProvider config={config}>
        <TokenTransferPage />
      </WagmiProvider>
    );

    // 1. Connect wallet
    await user.click(screen.getByRole('button', { name: /connect/i }));
    await waitFor(() => {
      expect(screen.getByText(/connected/i)).toBeInTheDocument();
    });

    // 2. Enter transfer details
    await user.type(screen.getByLabelText(/recipient/i), RECIPIENT_ADDRESS);
    await user.type(screen.getByLabelText(/amount/i), '10');

    // 3. Submit transfer
    await user.click(screen.getByRole('button', { name: /transfer/i }));

    // 4. Wait for confirmation
    await waitFor(() => {
      expect(screen.getByText(/success/i)).toBeInTheDocument();
    }, { timeout: 5000 });
  });
});
```

## Error Handling

### Error Boundaries

```typescript
// GOOD: Component-level error boundary
import { ErrorBoundary } from 'react-error-boundary';

function ErrorFallback({ error, resetErrorBoundary }: FallbackProps) {
  return (
    <div role="alert">
      <h2>Something went wrong</h2>
      <pre style={{ color: 'red' }}>{error.message}</pre>
      <button onClick={resetErrorBoundary}>Try again</button>
    </div>
  );
}

function App() {
  return (
    <ErrorBoundary
      FallbackComponent={ErrorFallback}
      onError={(error, info) => {
        console.error('Error caught by boundary:', error, info);
        // Log to error tracking service
      }}
      onReset={() => {
        // Reset app state
      }}
    >
      <WalletProvider>
        <Dashboard />
      </WalletProvider>
    </ErrorBoundary>
  );
}
```

### Async Error Handling

```typescript
// GOOD: Consistent async error pattern
async function safeAsyncOperation<T>(
  operation: () => Promise<T>,
  options?: {
    onError?: (error: Error) => void;
    fallback?: T;
  }
): Promise<T | null> {
  try {
    return await operation();
  } catch (error) {
    const err = error instanceof Error ? error : new Error(String(error));

    console.error('Operation failed:', err);
    options?.onError?.(err);

    return options?.fallback ?? null;
  }
}

// Usage
const balance = await safeAsyncOperation(
  () => fetchTokenBalance(address),
  {
    onError: (err) => toast.error(err.message),
    fallback: 0n,
  }
);
```

### Form Validation

```typescript
// GOOD: Type-safe form validation with Zod
import { z } from 'zod';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

const transferSchema = z.object({
  recipient: z.string().regex(/^0x[a-fA-F0-9]{40}$/, 'Invalid address'),
  amount: z.string()
    .refine((val) => !isNaN(Number(val)) && Number(val) > 0, 'Amount must be positive')
    .transform((val) => parseEther(val)),
});

type TransferFormData = z.infer<typeof transferSchema>;

function TransferForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<TransferFormData>({
    resolver: zodResolver(transferSchema),
  });

  const onSubmit = async (data: TransferFormData) => {
    await transfer(data.recipient as Address, data.amount);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('recipient')} placeholder="0x..." />
      {errors.recipient && <span>{errors.recipient.message}</span>}

      <input {...register('amount')} placeholder="0.0" />
      {errors.amount && <span>{errors.amount.message}</span>}

      <button type="submit" disabled={isSubmitting}>
        Transfer
      </button>
    </form>
  );
}
```
