# Integrate Wallet Connection

Set up Viem + Wagmi + RainbowKit for wallet connection and Ethereum interactions.

## Prerequisites

Project should have React + TypeScript set up.

## Steps

### 1. Install Dependencies

```bash
bun add viem wagmi @tanstack/react-query @rainbow-me/rainbowkit
```

### 2. Get WalletConnect Project ID

1. Go to https://cloud.walletconnect.com/
2. Create a new project
3. Copy the Project ID
4. Add to `.env.local`:

```bash
VITE_WALLET_CONNECT_PROJECT_ID=your_project_id_here
```

### 3. Create Wagmi Config

Create `src/lib/wagmi.ts`:

```ts
import { getDefaultConfig } from '@rainbow-me/rainbowkit'
import { mainnet, sepolia } from 'wagmi/chains'

export const wagmiConfig = getDefaultConfig({
  appName: 'My dApp',
  projectId: import.meta.env.VITE_WALLET_CONNECT_PROJECT_ID,
  chains: [mainnet, sepolia],
  ssr: false,
})
```

### 4. Set Up Providers

Update `src/main.tsx`:

```tsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import { WagmiProvider } from 'wagmi'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { RainbowKitProvider } from '@rainbow-me/rainbowkit'
import { wagmiConfig } from './lib/wagmi'
import App from './App'
import './index.css'
import '@rainbow-me/rainbowkit/styles.css'

const queryClient = new QueryClient()

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>
          <App />
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  </React.StrictMode>
)
```

### 5. Add Connect Button

Update `src/App.tsx`:

```tsx
import { ConnectButton } from '@rainbow-me/rainbowkit'

function App() {
  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto py-6 px-4 flex justify-between items-center">
          <h1 className="text-3xl font-bold text-gray-900">My dApp</h1>
          <ConnectButton />
        </div>
      </header>
      <main className="max-w-7xl mx-auto py-6 px-4">
        <p className="text-gray-600">Connect your wallet to get started</p>
      </main>
    </div>
  )
}

export default App
```

### 6. Use Wagmi Hooks (Examples)

Create `src/components/WalletInfo.tsx`:

```tsx
import { useAccount, useBalance, useEnsName } from 'wagmi'

export function WalletInfo() {
  const { address, isConnected } = useAccount()
  const { data: balance } = useBalance({ address })
  const { data: ensName } = useEnsName({ address })

  if (!isConnected) {
    return <p>Not connected</p>
  }

  return (
    <div className="space-y-2">
      <p className="text-sm">
        <span className="font-medium">Address:</span> {ensName || address}
      </p>
      {balance && (
        <p className="text-sm">
          <span className="font-medium">Balance:</span>{' '}
          {parseFloat(balance.formatted).toFixed(4)} {balance.symbol}
        </p>
      )}
    </div>
  )
}
```

### 7. Advanced Configuration (Optional)

#### Custom Chains

```ts
import { defineChain } from 'viem'

const customChain = defineChain({
  id: 1234,
  name: 'Custom Chain',
  nativeCurrency: {
    decimals: 18,
    name: 'Ether',
    symbol: 'ETH',
  },
  rpcUrls: {
    default: {
      http: ['https://rpc.custom-chain.com'],
    },
  },
  blockExplorers: {
    default: {
      name: 'Explorer',
      url: 'https://explorer.custom-chain.com',
    },
  },
})

// Add to chains array in wagmiConfig
```

#### Custom RPC URLs

```ts
import { http } from 'viem'
import { mainnet, sepolia } from 'viem/chains'
import { createConfig } from 'wagmi'

export const wagmiConfig = createConfig({
  chains: [mainnet, sepolia],
  transports: {
    [mainnet.id]: http(`https://eth-mainnet.g.alchemy.com/v2/${import.meta.env.VITE_ALCHEMY_API_KEY}`),
    [sepolia.id]: http(`https://eth-sepolia.g.alchemy.com/v2/${import.meta.env.VITE_ALCHEMY_API_KEY}`),
  },
})
```

#### Custom RainbowKit Theme

```tsx
import { RainbowKitProvider, darkTheme } from '@rainbow-me/rainbowkit'

<RainbowKitProvider theme={darkTheme()}>
  <App />
</RainbowKitProvider>
```

## Common Wagmi Hooks

```tsx
import {
  useAccount,          // Get connected account
  useBalance,          // Get account balance
  useConnect,          // Connect wallet
  useDisconnect,       // Disconnect wallet
  useEnsName,          // Get ENS name
  useEnsAvatar,        // Get ENS avatar
  useChainId,          // Get current chain ID
  useSwitchChain,      // Switch network
  useReadContract,     // Read from contract
  useWriteContract,    // Write to contract
  useWaitForTransactionReceipt, // Wait for transaction receipt
  useWatchContractEvent, // Watch contract events
} from 'wagmi'
```

## Error Handling

```tsx
import { useAccount } from 'wagmi'
import { ConnectButton } from '@rainbow-me/rainbowkit'

function ProtectedComponent() {
  const { isConnected } = useAccount()

  if (!isConnected) {
    return (
      <div className="text-center">
        <p className="mb-4">Please connect your wallet</p>
        <ConnectButton />
      </div>
    )
  }

  return <div>{/* Your component */}</div>
}
```

## Testing Wallet Integration

1. Install MetaMask or another wallet
2. Run `bun run dev`
3. Click "Connect Wallet"
4. Select wallet and approve connection
5. Verify wallet info displays correctly
6. Test network switching

## Output
- Full wallet integration with RainbowKit UI
- Wagmi hooks ready to use
- Multi-chain support configured
- Professional wallet connection UX
