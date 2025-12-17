# Wallet Connection Patterns

Common patterns for wallet integration, error handling, and user experience.

## Basic Wallet Integration

### Connect Button

```tsx
import { ConnectButton } from '@rainbow-me/rainbowkit'

// Basic usage
<ConnectButton />

// Custom button
<ConnectButton.Custom>
  {({
    account,
    chain,
    openAccountModal,
    openChainModal,
    openConnectModal,
    mounted,
  }) => {
    const connected = mounted && account && chain

    return (
      <div>
        {!connected ? (
          <button onClick={openConnectModal}>Connect Wallet</button>
        ) : (
          <div>
            <button onClick={openChainModal}>{chain.name}</button>
            <button onClick={openAccountModal}>
              {account.displayName}
            </button>
          </div>
        )}
      </div>
    )
  }}
</ConnectButton.Custom>
```

### Check Connection Status

```tsx
import { useAccount } from 'wagmi'

function Component() {
  const { address, isConnected, isConnecting, isDisconnected } = useAccount()

  if (isConnecting) return <p>Connecting...</p>
  if (isDisconnected) return <p>Disconnected</p>
  if (isConnected) return <p>Connected: {address}</p>
}
```

## Protected Routes

### Require Wallet Connection

```tsx
import { useAccount } from 'wagmi'
import { ConnectButton } from '@rainbow-me/rainbowkit'
import { Navigate } from 'react-router-dom'

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { isConnected } = useAccount()

  if (!isConnected) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen">
        <h2 className="text-2xl mb-4">Connect Your Wallet</h2>
        <ConnectButton />
      </div>
    )
  }

  return <>{children}</>
}

// Usage
<Route
  path="/dashboard"
  element={
    <ProtectedRoute>
      <Dashboard />
    </ProtectedRoute>
  }
/>
```

### Require Specific Network

```tsx
import { useChainId, useSwitchChain } from 'wagmi'
import { mainnet } from 'wagmi/chains'

function RequireMainnet({ children }: { children: React.ReactNode }) {
  const chainId = useChainId()
  const { switchChain } = useSwitchChain()

  if (chainId !== mainnet.id) {
    return (
      <div className="text-center">
        <p>Please switch to Mainnet</p>
        <button onClick={() => switchChain({ chainId: mainnet.id })}>
          Switch Network
        </button>
      </div>
    )
  }

  return <>{children}</>
}
```

## Network Handling

### Display Current Network

```tsx
import { useChainId } from 'wagmi'
import { mainnet, sepolia } from 'wagmi/chains'

const chainNames = {
  [mainnet.id]: 'Mainnet',
  [sepolia.id]: 'Sepolia',
}

function NetworkBadge() {
  const chainId = useChainId()

  return (
    <span className="px-2 py-1 bg-gray-200 rounded">
      {chainNames[chainId] || 'Unknown Network'}
    </span>
  )
}
```

### Switch Networks

```tsx
import { useSwitchChain } from 'wagmi'
import { mainnet, sepolia } from 'wagmi/chains'

function NetworkSwitcher() {
  const { switchChain, isPending } = useSwitchChain()

  return (
    <div className="flex gap-2">
      <button
        onClick={() => switchChain({ chainId: mainnet.id })}
        disabled={isPending}
      >
        Mainnet
      </button>
      <button
        onClick={() => switchChain({ chainId: sepolia.id })}
        disabled={isPending}
      >
        Sepolia
      </button>
    </div>
  )
}
```

## Transaction Patterns

### Send Transaction

```tsx
import { useSendTransaction, useWaitForTransactionReceipt } from 'wagmi'
import { parseEther } from 'viem'

function SendEther() {
  const { data: hash, sendTransaction, isPending } = useSendTransaction()

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  })

  const handleSend = () => {
    sendTransaction({
      to: '0x...',
      value: parseEther('0.01'),
    })
  }

  return (
    <div>
      <button onClick={handleSend} disabled={isPending || isConfirming}>
        {isPending ? 'Confirming...' : isConfirming ? 'Processing...' : 'Send'}
      </button>

      {hash && <p>Tx Hash: {hash}</p>}
      {isSuccess && <p>Success!</p>}
    </div>
  )
}
```

### Transaction with Loading States

```tsx
function TransactionButton() {
  const [txState, setTxState] = useState<'idle' | 'signing' | 'pending' | 'success' | 'error'>('idle')
  const { writeContract } = useWriteContract()

  const handleTransaction = async () => {
    try {
      setTxState('signing')
      const hash = await writeContract({...})

      setTxState('pending')
      // Wait for confirmation
      await waitForTransaction({ hash })

      setTxState('success')
    } catch (error) {
      setTxState('error')
      console.error(error)
    }
  }

  const buttonText = {
    idle: 'Submit Transaction',
    signing: 'Confirm in wallet...',
    pending: 'Processing...',
    success: 'Success!',
    error: 'Try Again',
  }

  return (
    <button
      onClick={handleTransaction}
      disabled={txState === 'signing' || txState === 'pending'}
      className={txState === 'success' ? 'bg-green-500' : 'bg-blue-500'}
    >
      {buttonText[txState]}
    </button>
  )
}
```

## Error Handling

### Handle Transaction Errors

```tsx
import { BaseError, UserRejectedRequestError, ContractFunctionExecutionError } from 'viem'

function TransactionComponent() {
  const [error, setError] = useState<string | null>(null)

  const handleError = (err: unknown) => {
    if (err instanceof BaseError) {
      // User rejected
      if (err.walk((e) => e instanceof UserRejectedRequestError)) {
        setError('Transaction rejected')
        return
      }

      // Contract error
      if (err instanceof ContractFunctionExecutionError) {
        setError(`Contract error: ${err.shortMessage}`)
        return
      }

      // Generic error
      setError(err.shortMessage || 'Transaction failed')
    } else {
      setError('Unknown error occurred')
    }
  }

  return (
    <div>
      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
          {error}
        </div>
      )}
    </div>
  )
}
```

### Connection Errors

```tsx
import { useConnect } from 'wagmi'

function ConnectWallet() {
  const { connectors, connect, error } = useConnect()

  return (
    <div>
      {connectors.map((connector) => (
        <button key={connector.id} onClick={() => connect({ connector })}>
          {connector.name}
        </button>
      ))}

      {error && <p className="text-red-500">{error.message}</p>}
    </div>
  )
}
```

## Display Patterns

### Format Address

```tsx
function formatAddress(address: string) {
  return `${address.slice(0, 6)}...${address.slice(-4)}`
}

// Usage
<p>{formatAddress('0x1234567890123456789012345678901234567890')}</p>
// Output: 0x1234...7890
```

### Display Balance

```tsx
import { useBalance } from 'wagmi'
import { formatEther } from 'viem'

function Balance({ address }: { address: `0x${string}` }) {
  const { data, isLoading } = useBalance({ address })

  if (isLoading) return <span>Loading...</span>

  return (
    <span>
      {parseFloat(formatEther(data?.value || 0n)).toFixed(4)} {data?.symbol}
    </span>
  )
}
```

### ENS Integration

```tsx
import { useEnsName, useEnsAvatar } from 'wagmi'

function UserDisplay({ address }: { address: `0x${string}` }) {
  const { data: ensName } = useEnsName({ address })
  const { data: ensAvatar } = useEnsAvatar({ name: ensName })

  return (
    <div className="flex items-center gap-2">
      {ensAvatar && (
        <img src={ensAvatar} alt="Avatar" className="w-8 h-8 rounded-full" />
      )}
      <span>{ensName || formatAddress(address)}</span>
    </div>
  )
}
```

## Signing Messages

### Sign Message

```tsx
import { useSignMessage } from 'wagmi'

function SignMessage() {
  const { signMessage, data: signature, error } = useSignMessage()

  return (
    <div>
      <button onClick={() => signMessage({ message: 'Hello World' })}>
        Sign Message
      </button>

      {signature && <p>Signature: {signature}</p>}
      {error && <p>Error: {error.message}</p>}
    </div>
  )
}
```

### Verify Signature

```tsx
import { verifyMessage } from 'viem'

const isValid = await verifyMessage({
  address: '0x...',
  message: 'Hello World',
  signature: '0x...',
})
```

## Advanced Patterns

### Multi-Wallet Support

RainbowKit handles this automatically, but you can customize:

```tsx
import { getDefaultConfig } from '@rainbow-me/rainbowkit'
import { metaMaskWallet, coinbaseWallet, walletConnectWallet } from '@rainbow-me/rainbowkit/wallets'

const config = getDefaultConfig({
  wallets: [
    {
      groupName: 'Recommended',
      wallets: [metaMaskWallet, coinbaseWallet],
    },
    {
      groupName: 'Others',
      wallets: [walletConnectWallet],
    },
  ],
  // ... other config
})
```

### Auto-Connect

```tsx
import { useEffect } from 'react'
import { useAccount, useConnect } from 'wagmi'

function AutoConnect() {
  const { isConnected } = useAccount()
  const { connect, connectors } = useConnect()

  useEffect(() => {
    // Auto-connect to last used connector
    const lastConnector = localStorage.getItem('lastConnector')
    if (!isConnected && lastConnector) {
      const connector = connectors.find((c) => c.id === lastConnector)
      if (connector) {
        connect({ connector })
      }
    }
  }, [isConnected, connect, connectors])

  return null
}
```

### Persist Connection

```tsx
import { useAccount, useDisconnect } from 'wagmi'

function useAutoSaveConnector() {
  const { connector } = useAccount()
  const { disconnect } = useDisconnect()

  useEffect(() => {
    if (connector) {
      localStorage.setItem('lastConnector', connector.id)
    }
  }, [connector])

  const handleDisconnect = () => {
    localStorage.removeItem('lastConnector')
    disconnect()
  }

  return { disconnect: handleDisconnect }
}
```

## Best Practices

1. **Always handle loading states**: Show spinners or disabled buttons
2. **Provide clear error messages**: User-friendly, actionable errors
3. **Validate network**: Check user is on correct chain
4. **Handle wallet not installed**: Guide users to install
5. **Use optimistic updates**: Update UI before transaction confirms
6. **Show transaction links**: Link to block explorer
7. **Implement retry logic**: Allow users to retry failed transactions
8. **Save gas estimates**: Show users estimated gas costs
9. **Use deadlines**: Prevent transactions from being mined too late
10. **Test thoroughly**: Test on testnets with different wallets

## Common Pitfalls

- Not handling wallet rejection
- Not validating network
- Not showing loading states
- Blocking UI during transactions
- Not handling insufficient funds
- Ignoring gas price spikes
- Not providing transaction receipts
- Poor mobile wallet UX
