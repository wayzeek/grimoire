# Connect to Smart Contracts

Integrate smart contracts into your frontend using Viem and Wagmi with full type safety.

## Prerequisites

- Wagmi and Viem installed
- Contract deployed with known address
- Contract ABI available

## Steps

### 1. Organize Contract Files

Create directory structure:

```
src/lib/contracts/
├── abis/
│   ├── MyToken.ts
│   └── MyNFT.ts
└── addresses.ts
```

### 2. Add Contract ABI

Export ABI from your contract project (Foundry):

```bash
# In your contract directory
forge build
cat out/MyToken.sol/MyToken.json | jq '.abi' > abi.json
```

Copy to frontend and create `src/lib/contracts/abis/MyToken.ts`:

```ts
export const MyTokenABI = [
  {
    "inputs": [],
    "name": "totalSupply",
    "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [{ "internalType": "address", "name": "account", "type": "address" }],
    "name": "balanceOf",
    "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
    "stateMutability": "view",
    "type": "function"
  },
  // ... rest of ABI
] as const // Important: 'as const' for type inference
```

### 3. Add Contract Addresses

Create `src/lib/contracts/addresses.ts`:

```ts
import { Address } from 'viem'

export const contracts = {
  MyToken: {
    1: '0x...' as Address, // Mainnet
    11155111: '0x...' as Address, // Sepolia
  },
  MyNFT: {
    1: '0x...' as Address,
    11155111: '0x...' as Address,
  },
} as const

export type ContractName = keyof typeof contracts
export type SupportedChainId = keyof typeof contracts.MyToken
```

### 4. Read from Contract

Use `useReadContract` hook:

```tsx
import { useReadContract, useAccount } from 'wagmi'
import { MyTokenABI } from '@/lib/contracts/abis/MyToken'
import { contracts } from '@/lib/contracts/addresses'

export function TokenBalance() {
  const { address, chainId } = useAccount()

  const { data: balance, isLoading, error } = useReadContract({
    address: contracts.MyToken[chainId as keyof typeof contracts.MyToken],
    abi: MyTokenABI,
    functionName: 'balanceOf',
    args: [address!],
    query: {
      enabled: !!address && !!chainId,
    },
  })

  if (isLoading) return <p>Loading balance...</p>
  if (error) return <p>Error loading balance</p>

  return (
    <div>
      <p>Balance: {balance?.toString()}</p>
    </div>
  )
}
```

### 5. Write to Contract

Use `useWriteContract` hook:

```tsx
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi'
import { parseEther } from 'viem'
import { MyTokenABI } from '@/lib/contracts/abis/MyToken'
import { contracts } from '@/lib/contracts/addresses'

export function TransferTokens() {
  const { chainId } = useAccount()

  const {
    data: hash,
    writeContract,
    isPending,
    error,
  } = useWriteContract()

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  })

  const handleTransfer = async (to: string, amount: string) => {
    writeContract({
      address: contracts.MyToken[chainId as keyof typeof contracts.MyToken],
      abi: MyTokenABI,
      functionName: 'transfer',
      args: [to as `0x${string}`, parseEther(amount)],
    })
  }

  return (
    <div>
      <button
        onClick={() => handleTransfer('0x...', '1.0')}
        disabled={isPending || isConfirming}
        className="px-4 py-2 bg-blue-500 text-white rounded disabled:opacity-50"
      >
        {isPending ? 'Confirming...' : isConfirming ? 'Processing...' : 'Transfer'}
      </button>

      {hash && <p>Transaction Hash: {hash}</p>}
      {isSuccess && <p>Transaction confirmed!</p>}
      {error && <p>Error: {error.message}</p>}
    </div>
  )
}
```

### 6. Watch Contract Events

```tsx
import { useWatchContractEvent } from 'wagmi'
import { MyTokenABI } from '@/lib/contracts/abis/MyToken'
import { contracts } from '@/lib/contracts/addresses'

export function TransferEvents() {
  const { chainId } = useAccount()
  const [events, setEvents] = useState<any[]>([])

  useWatchContractEvent({
    address: contracts.MyToken[chainId as keyof typeof contracts.MyToken],
    abi: MyTokenABI,
    eventName: 'Transfer',
    onLogs(logs) {
      setEvents((prev) => [...prev, ...logs])
    },
  })

  return (
    <div>
      <h3>Recent Transfers</h3>
      {events.map((event, i) => (
        <div key={i}>
          <p>From: {event.args.from}</p>
          <p>To: {event.args.to}</p>
          <p>Amount: {event.args.value.toString()}</p>
        </div>
      ))}
    </div>
  )
}
```

### 7. Simulate Contract Write (Optional)

Test transactions before sending:

```tsx
import { useSimulateContract, useWriteContract } from 'wagmi'

const { data: simulateData } = useSimulateContract({
  address: contracts.MyToken[chainId],
  abi: MyTokenABI,
  functionName: 'transfer',
  args: [to, amount],
})

const { writeContract } = useWriteContract()

// Use simulation result
if (simulateData?.request) {
  writeContract(simulateData.request)
}
```

### 8. Handle Multiple Chains

Create helper hook:

```tsx
import { useAccount } from 'wagmi'
import { contracts, ContractName } from '@/lib/contracts/addresses'

export function useContractAddress(contractName: ContractName) {
  const { chainId } = useAccount()

  if (!chainId) return undefined

  return contracts[contractName][chainId as keyof typeof contracts[typeof contractName]]
}

// Usage
const tokenAddress = useContractAddress('MyToken')
```

### 9. Format Values

Use Viem formatting utilities:

```tsx
import { formatEther, formatUnits, parseEther, parseUnits } from 'viem'

// Format Wei to Ether
const ethAmount = formatEther(weiAmount) // "1.234"

// Format with custom decimals
const tokenAmount = formatUnits(rawAmount, 18)

// Parse Ether to Wei
const weiAmount = parseEther("1.5") // 1500000000000000000n

// Parse with custom decimals
const rawAmount = parseUnits("1.5", 6) // For USDC
```

### 10. Error Handling

```tsx
import { BaseError } from 'wagmi'
import { UserRejectedRequestError } from 'viem'

try {
  await writeContract({...})
} catch (error) {
  if (error instanceof BaseError) {
    if (error.walk((e) => e instanceof UserRejectedRequestError)) {
      console.log('User rejected transaction')
    } else {
      console.error('Contract error:', error.shortMessage)
    }
  }
}
```

## Best Practices

### Type Safety

Always use `as const` on ABIs for proper type inference:

```ts
export const ABI = [...] as const
```

### Contract Hooks

Create reusable hooks for contracts:

```ts
// src/hooks/useMyToken.ts
import { useReadContract } from 'wagmi'
import { MyTokenABI } from '@/lib/contracts/abis/MyToken'
import { useContractAddress } from './useContractAddress'

export function useTokenBalance(address?: `0x${string}`) {
  const tokenAddress = useContractAddress('MyToken')

  return useReadContract({
    address: tokenAddress,
    abi: MyTokenABI,
    functionName: 'balanceOf',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address && !!tokenAddress,
    },
  })
}
```

### Loading States

Always handle loading and error states:

```tsx
if (isLoading) return <Spinner />
if (error) return <ErrorMessage error={error} />
if (!data) return <NoData />
return <DataDisplay data={data} />
```

### Refetch on Block

Auto-update data on new blocks:

```tsx
useReadContract({
  // ... config
  query: {
    refetchInterval: 12000, // Refetch every 12 seconds (avg block time)
  },
})
```

## Monorepo Integration

If contracts are in the same monorepo:

```bash
# Symlink or reference contract artifacts
# In package.json
"scripts": {
  "update-abis": "cp ../contracts/out/MyToken.sol/MyToken.json src/lib/contracts/abis/"
}
```

Or use workspace dependencies to import directly from contract package.

## Output
- Full contract integration with type safety
- Reusable contract hooks
- Proper error handling and loading states
- Multi-chain support
