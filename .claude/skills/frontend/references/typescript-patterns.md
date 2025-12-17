# TypeScript Patterns

Advanced TypeScript patterns for React development.

## Table of Contents

1. [Discriminated Unions](#discriminated-unions)
2. [Utility Types](#utility-types)
3. [Generic Components](#generic-components)
4. [Type Guards](#type-guards)

## TypeScript Patterns

### Discriminated Unions

```typescript
// GOOD: Type-safe state handling
type TransactionState =
  | { status: 'idle' }
  | { status: 'pending'; hash: string }
  | { status: 'success'; hash: string; blockNumber: bigint }
  | { status: 'error'; error: Error };

function TransactionStatus({ state }: { state: TransactionState }) {
  // TypeScript narrows the type
  switch (state.status) {
    case 'idle':
      return <div>Ready to send</div>;
    case 'pending':
      return <div>Transaction pending: {state.hash}</div>;
    case 'success':
      return <div>Success! Block: {state.blockNumber.toString()}</div>;
    case 'error':
      return <div>Error: {state.error.message}</div>;
  }
}
```

### Utility Types

```typescript
// Extract props from component
type ButtonProps = React.ComponentProps<'button'>;

// Make all properties optional
type PartialConfig = Partial<ContractConfig>;

// Make all properties required
type RequiredConfig = Required<ContractConfig>;

// Pick specific properties
type AddressAndChain = Pick<WalletState, 'address' | 'chainId'>;

// Omit specific properties
type PublicWallet = Omit<Wallet, 'privateKey'>;

// GOOD: Reusable async state type
type AsyncState<T, E = Error> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: E };

// Usage
const [tokenData, setTokenData] = useState<AsyncState<TokenInfo>>({
  status: 'idle'
});
```

### Generic Components

```typescript
// GOOD: Type-safe generic components
interface DataTableProps<T> {
  data: T[];
  columns: Column<T>[];
  onRowClick?: (row: T) => void;
}

function DataTable<T extends { id: string }>({
  data,
  columns,
  onRowClick
}: DataTableProps<T>) {
  return (
    <table>
      <tbody>
        {data.map((row) => (
          <tr key={row.id} onClick={() => onRowClick?.(row)}>
            {columns.map((col) => (
              <td key={col.key}>{col.render(row)}</td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}

// Usage with full type safety
interface Transaction {
  id: string;
  hash: string;
  amount: bigint;
}

function TransactionList() {
  const columns: Column<Transaction>[] = [
    { key: 'hash', render: (tx) => tx.hash },
    { key: 'amount', render: (tx) => formatEther(tx.amount) },
  ];

  return <DataTable data={transactions} columns={columns} />;
}
```

### Type Guards

```typescript
// GOOD: Runtime type checking
function isAddress(value: unknown): value is Address {
  return typeof value === 'string' && /^0x[a-fA-F0-9]{40}$/.test(value);
}

function isTransactionReceipt(obj: unknown): obj is TransactionReceipt {
  return (
    typeof obj === 'object' &&
    obj !== null &&
    'transactionHash' in obj &&
    'blockNumber' in obj
  );
}

// Usage
function processInput(input: unknown) {
  if (isAddress(input)) {
    // TypeScript knows input is Address
    return getBalance(input);
  }
}
```
