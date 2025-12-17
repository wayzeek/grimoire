# Performance Optimization

Performance optimization techniques for React applications.

## Table of Contents

1. [Memoization](#memoization)
2. [Virtualization](#virtualization)
3. [Debouncing](#debouncing)
4. [Code Splitting](#code-splitting)

## Performance Optimization

### Memoization

```typescript
// BAD: Recreates object on every render
function TokenCard({ token }: { token: Token }) {
  const config = {
    address: token.address,
    abi: erc20Abi,
  }; // ❌ New object every render

  return <ContractInteraction config={config} />;
}

// GOOD: Memoized object
function TokenCard({ token }: { token: Token }) {
  const config = useMemo(
    () => ({
      address: token.address,
      abi: erc20Abi,
    }),
    [token.address]
  );

  return <ContractInteraction config={config} />;
}

// GOOD: Memoized component
const TokenCardMemo = memo(TokenCard, (prev, next) => {
  return prev.token.address === next.token.address;
});
```

### Virtualization

```typescript
// GOOD: Virtualize long lists
import { useVirtualizer } from '@tanstack/react-virtual';

function TransactionList({ transactions }: { transactions: Transaction[] }) {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: transactions.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50,
    overscan: 5,
  });

  return (
    <div ref={parentRef} className={styles.scrollContainer}>
      <div
        style={{
          height: `${virtualizer.getTotalSize()}px`,
          position: 'relative',
        }}
      >
        {virtualizer.getVirtualItems().map((virtualRow) => {
          const tx = transactions[virtualRow.index];
          return (
            <div
              key={virtualRow.key}
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                width: '100%',
                height: `${virtualRow.size}px`,
                transform: `translateY(${virtualRow.start}px)`,
              }}
            >
              <TransactionRow transaction={tx} />
            </div>
          );
        })}
      </div>
    </div>
  );
}
```

### Debouncing

```typescript
// GOOD: Debounced search
import { useDebouncedValue } from '@mantine/hooks';

function TokenSearch() {
  const [search, setSearch] = useState('');
  const [debouncedSearch] = useDebouncedValue(search, 300);

  // Only queries when user stops typing
  const { data: results } = useQuery({
    queryKey: ['tokens', debouncedSearch],
    queryFn: () => searchTokens(debouncedSearch),
    enabled: debouncedSearch.length > 0,
  });

  return (
    <input
      value={search}
      onChange={(e) => setSearch(e.target.value)}
      placeholder="Search tokens..."
    />
  );
}
```

### Code Splitting

```typescript
// GOOD: Lazy load heavy components
import { lazy, Suspense } from 'react';

const TransactionHistory = lazy(() => import('./TransactionHistory'));
const ChartView = lazy(() => import('./ChartView'));

function Dashboard() {
  const [activeTab, setActiveTab] = useState<'overview' | 'history' | 'charts'>('overview');

  return (
    <div>
      <Tabs value={activeTab} onChange={setActiveTab} />

      <Suspense fallback={<LoadingSpinner />}>
        {activeTab === 'history' && <TransactionHistory />}
        {activeTab === 'charts' && <ChartView />}
      </Suspense>
    </div>
  );
}
```
