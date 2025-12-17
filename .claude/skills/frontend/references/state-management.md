# State Management

State management patterns using Zustand for React applications.

## Table of Contents

1. [Zustand Patterns](#zustand-patterns)
2. [Local vs Global State](#local-vs-global-state)
3. [Derived State](#derived-state)

## State Management

### Zustand Patterns

```typescript
// store/walletStore.ts
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface WalletState {
  // State
  address: Address | null;
  chainId: number | null;
  isConnected: boolean;

  // Actions
  setAddress: (address: Address | null) => void;
  setChainId: (chainId: number | null) => void;
  reset: () => void;
}

// GOOD: Typed store with middleware
export const useWalletStore = create<WalletState>()(
  devtools(
    persist(
      (set) => ({
        // Initial state
        address: null,
        chainId: null,
        isConnected: false,

        // Actions
        setAddress: (address) => set({ address, isConnected: Boolean(address) }),
        setChainId: (chainId) => set({ chainId }),
        reset: () => set({ address: null, chainId: null, isConnected: false }),
      }),
      {
        name: 'wallet-storage',
        // Only persist specific fields
        partialize: (state) => ({ address: state.address, chainId: state.chainId }),
      }
    )
  )
);

// GOOD: Selector pattern (prevents unnecessary re-renders)
function WalletDisplay() {
  // Only re-renders when address changes
  const address = useWalletStore((state) => state.address);

  return <div>{address}</div>;
}

// GOOD: Actions-only selector
function DisconnectButton() {
  const reset = useWalletStore((state) => state.reset);

  return <button onClick={reset}>Disconnect</button>;
}
```

### Local vs Global State

```typescript
// BAD: Everything in global state
const useAppStore = create((set) => ({
  modalOpen: false, // ❌ UI state should be local
  formData: {},     // ❌ Form state should be local
  userAddress: null, // ✅ Global state appropriate
}));

// GOOD: Appropriate state boundaries
// Global state (shared across app)
const useWeb3Store = create((set) => ({
  address: null,
  chainId: null,
  provider: null,
}));

// Local state (component-specific)
function TransferForm() {
  const [amount, setAmount] = useState('');
  const [recipient, setRecipient] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);

  const address = useWeb3Store((state) => state.address);

  // Component logic
}
```

### Derived State

```typescript
// BAD: Storing derived state
const [balance, setBalance] = useState(0n);
const [formattedBalance, setFormattedBalance] = useState('0'); // ❌ Derived

useEffect(() => {
  setFormattedBalance(formatUnits(balance, 18));
}, [balance]);

// GOOD: Compute derived state
const [balance, setBalance] = useState(0n);
const formattedBalance = useMemo(
  () => formatUnits(balance, 18),
  [balance]
);

// GOOD: Zustand with computed properties
interface TokenStore {
  balance: bigint;
  decimals: number;
  // Computed in selector
}

const useTokenStore = create<TokenStore>((set) => ({
  balance: 0n,
  decimals: 18,
}));

// Use selector for computation
function BalanceDisplay() {
  const formatted = useTokenStore(
    (state) => formatUnits(state.balance, state.decimals)
  );

  return <div>{formatted}</div>;
}
```
