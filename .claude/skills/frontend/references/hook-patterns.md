# Hook Patterns

Custom hook patterns and best practices for React development.

## Table of Contents

1. [Custom Hook Naming](#custom-hook-naming)
2. [Hook Return Patterns](#hook-return-patterns)
3. [Hook Dependencies](#hook-dependencies)
4. [Custom Hook Best Practices](#custom-hook-best-practices)

## Hook Conventions

### Custom Hook Naming

**Rule:** Always prefix with "use"

```typescript
// GOOD: Clear, descriptive hook names
function useWalletBalance(address?: Address) {}
function useTokenPrice(tokenAddress: Address) {}
function useTransactionHistory(address: Address) {}
function useContractWrite(config: ContractConfig) {}
```

### Hook Return Patterns

```typescript
// Pattern 1: Object destructuring (most common)
function useWalletBalance(address?: Address) {
  const [balance, setBalance] = useState<bigint>(0n);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  // ... implementation

  return { balance, isLoading, error, refetch };
}

// Usage
const { balance, isLoading, error } = useWalletBalance(address);

// Pattern 2: Tuple (when order matters)
function useToggle(initialState = false) {
  const [state, setState] = useState(initialState);
  const toggle = useCallback(() => setState(s => !s), []);
  return [state, toggle] as const;
}

// Usage
const [isOpen, toggleOpen] = useToggle();

// Pattern 3: Single value (simple hooks)
function useIsMounted() {
  const isMounted = useRef(false);

  useEffect(() => {
    isMounted.current = true;
    return () => { isMounted.current = false; };
  }, []);

  return isMounted;
}
```

### Hook Dependencies

```typescript
// BAD: Missing dependencies
useEffect(() => {
  fetchData(userId);
}, []); // userId is missing

// BAD: Unnecessary dependencies
useEffect(() => {
  console.log('Mounted');
}, [userId]); // userId not used

// GOOD: Correct dependencies
useEffect(() => {
  fetchData(userId);
}, [userId]);

// GOOD: Stable callbacks
const handleSubmit = useCallback((data: FormData) => {
  submitToAPI(data, apiKey);
}, [apiKey]); // apiKey is external dependency
```

### Custom Hook Best Practices

```typescript
// GOOD: Comprehensive custom hook
function useTokenBalance(
  tokenAddress?: Address,
  ownerAddress?: Address
) {
  // State
  const [balance, setBalance] = useState<bigint | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  // Wagmi hook for contract read
  const { data, isError, isLoading: isQueryLoading, refetch } = useReadContract({
    address: tokenAddress,
    abi: erc20Abi,
    functionName: 'balanceOf',
    args: ownerAddress ? [ownerAddress] : undefined,
    enabled: Boolean(tokenAddress && ownerAddress),
  });

  // Sync with contract data
  useEffect(() => {
    if (data !== undefined) {
      setBalance(data as bigint);
      setIsLoading(false);
    }
  }, [data]);

  useEffect(() => {
    if (isError) {
      setError(new Error('Failed to fetch balance'));
      setIsLoading(false);
    }
  }, [isError]);

  useEffect(() => {
    setIsLoading(isQueryLoading);
  }, [isQueryLoading]);

  // Format helpers
  const formatted = useMemo(() => {
    if (balance === null) return null;
    return formatUnits(balance, 18);
  }, [balance]);

  return {
    balance,
    formatted,
    isLoading,
    error,
    refetch,
  };
}
```
