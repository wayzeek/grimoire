# Component Patterns

Component organization and structure standards for React/TypeScript development.

## Table of Contents

1. [Co-location Pattern](#co-location-pattern)
2. [Component Naming](#component-naming)
3. [Component Structure](#component-structure)
4. [Composition over Props Drilling](#composition-over-props-drilling)

## Component Organization

### Co-location Pattern

**Rule:** Keep related files together

```
components/
├── Button/
│   ├── Button.tsx
│   ├── Button.test.tsx
│   ├── Button.stories.tsx
│   ├── Button.module.css
│   └── index.ts
├── WalletConnect/
│   ├── WalletConnect.tsx
│   ├── WalletConnect.test.tsx
│   ├── useWalletConnect.ts
│   ├── types.ts
│   └── index.ts
```

### Component Naming

```typescript
// BAD: Generic, unclear naming
function Component() {}
function MyComponent() {}

// GOOD: Descriptive, specific naming
function WalletConnectButton() {}
function TokenBalanceDisplay() {}
function TransactionHistoryTable() {}
```

### Component Structure

```typescript
// GOOD: Consistent component structure
interface WalletConnectButtonProps {
  onConnect?: (address: string) => void;
  className?: string;
}

export function WalletConnectButton({
  onConnect,
  className
}: WalletConnectButtonProps) {
  // 1. Hooks (always at the top)
  const { connect, isConnecting, address } = useWallet();
  const [error, setError] = useState<Error | null>(null);

  // 2. Derived state
  const isConnected = Boolean(address);
  const buttonText = isConnected ? 'Connected' : 'Connect Wallet';

  // 3. Event handlers
  const handleConnect = useCallback(async () => {
    try {
      setError(null);
      const result = await connect();
      onConnect?.(result.address);
    } catch (err) {
      setError(err as Error);
    }
  }, [connect, onConnect]);

  // 4. Effects
  useEffect(() => {
    if (error) {
      toast.error(error.message);
    }
  }, [error]);

  // 5. Early returns
  if (!window.ethereum) {
    return <InstallMetaMaskPrompt />;
  }

  // 6. Main render
  return (
    <button
      onClick={handleConnect}
      disabled={isConnecting}
      className={cn(styles.button, className)}
    >
      {isConnecting ? <Spinner /> : buttonText}
    </button>
  );
}
```

### Composition over Props Drilling

```typescript
// BAD: Props drilling
function App() {
  const user = useUser();
  return <Dashboard user={user} />;
}

function Dashboard({ user }: { user: User }) {
  return <Sidebar user={user} />;
}

function Sidebar({ user }: { user: User }) {
  return <UserMenu user={user} />;
}

// GOOD: Context + hooks
const UserContext = createContext<User | null>(null);

function App() {
  const user = useUser();
  return (
    <UserContext.Provider value={user}>
      <Dashboard />
    </UserContext.Provider>
  );
}

function UserMenu() {
  const user = useContext(UserContext);
  // Use user directly
}
```
