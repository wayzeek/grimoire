# Frontend Tech Stack Reference

## Core Stack

### Runtime
- **Bun**: Preferred for speed and developer experience
- **Node.js**: Alternative if needed for compatibility

### Build Tool
- **Vite**: Fast, modern build tool with HMR
- Better than Create React App or Webpack for new projects

### Framework
- **React 18+**: Component library
- **TypeScript**: Type safety and better DX

### Styling
- **Tailwind CSS**: Utility-first CSS framework
- Avoid CSS-in-JS libraries for performance
- Use Tailwind's built-in utilities instead of custom CSS when possible

## Web3 Libraries

### Ethereum Interaction
- **Viem**: Preferred library for Ethereum
  - TypeScript-first
  - Lightweight and modular
  - Better performance than ethers.js
  - Strong typing with ABIs

### React Hooks
- **Wagmi**: React hooks for Ethereum
  - Built on Viem
  - Handles caching, deduplication, persistence
  - Great developer experience

### Wallet Connection
- **RainbowKit**: Beautiful wallet connection UI
  - Supports major wallets
  - Customizable themes
  - Great UX out of the box
  - Built on Wagmi

### Alternatives (not preferred)
- ~~ethers.js~~: Use Viem instead
- ~~web3.js~~: Use Viem instead
- ~~useDApp~~: Use Wagmi instead

## State Management

### When to Use State Management

**Don't need it for**:
- Simple apps with local state
- Data already cached by Wagmi/React Query

**Use when**:
- Complex global state
- Cross-component data sharing
- Client-side caching beyond Wagmi

### Recommended Libraries

**Zustand** (preferred for simplicity):
```tsx
import { create } from 'zustand'

const useStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}))
```

**Jotai** (for atomic state):
```tsx
import { atom, useAtom } from 'jotai'

const countAtom = atom(0)

function Counter() {
  const [count, setCount] = useAtom(countAtom)
}
```

**TanStack Query** (already included with Wagmi):
- Server state caching
- Background refetching
- Use for API data

**Avoid**:
- Redux (too much boilerplate)
- MobX (overkill for most cases)
- Context API for global state (performance issues)

## Routing

### React Router
```bash
bun add react-router-dom
```

```tsx
import { BrowserRouter, Routes, Route } from 'react-router-dom'

<BrowserRouter>
  <Routes>
    <Route path="/" element={<Home />} />
    <Route path="/dashboard" element={<Dashboard />} />
  </Routes>
</BrowserRouter>
```

## UI Components

### Headless UI Libraries (recommended)

**Radix UI** (preferred):
- Accessible primitives
- Unstyled, works great with Tailwind
- Production-ready

```bash
bun add @radix-ui/react-dialog @radix-ui/react-dropdown-menu
```

**shadcn/ui**:
- Copy-paste components
- Built on Radix + Tailwind
- Customizable

### Component Libraries (use sparingly)

- Material-UI: Heavy, not ideal for web3
- Chakra UI: Okay but not preferred
- Ant Design: Too opinionated

**Prefer**: Build custom with Tailwind + Radix

## Icons

**Lucide React** (preferred):
```bash
bun add lucide-react
```

```tsx
import { Wallet, ChevronDown } from 'lucide-react'

<Wallet className="w-5 h-5" />
```

**Alternatives**:
- Heroicons
- React Icons

## Form Handling

**React Hook Form** (recommended):
```bash
bun add react-hook-form
```

```tsx
import { useForm } from 'react-hook-form'

const { register, handleSubmit, formState: { errors } } = useForm()
```

**Zod** for validation:
```bash
bun add zod @hookform/resolvers
```

```tsx
import { z } from 'zod'
import { zodResolver } from '@hookform/resolvers/zod'

const schema = z.object({
  address: z.string().regex(/^0x[a-fA-F0-9]{40}$/),
})
```

## Testing

### Unit/Integration Testing

**Vitest** (preferred over Jest):
```bash
bun add -D vitest @testing-library/react @testing-library/jest-dom
```

### E2E Testing

**Playwright** (for E2E with wallet):
```bash
bun add -D @playwright/test
```

Can test MetaMask interactions with Playwright.

## Performance

### Code Splitting

```tsx
import { lazy, Suspense } from 'react'

const Dashboard = lazy(() => import('./pages/Dashboard'))

<Suspense fallback={<Loading />}>
  <Dashboard />
</Suspense>
```

### Optimization

- Use `React.memo` for expensive components
- `useMemo` and `useCallback` sparingly
- Keep components small and focused
- Lazy load routes and heavy components

## Development Tools

### Required

- **TypeScript**: Type safety
- **ESLint**: Linting
- **Prettier**: Code formatting

### Optional but Useful

- **TypeScript ESLint**: TS-specific linting
- **Tailwind Prettier Plugin**: Sort classes

## Package Manager

**Bun** (preferred):
- Faster than npm/yarn/pnpm
- Built-in test runner
- Compatible with npm packages

```bash
bun install
bun run dev
bun test
```

## Environment Variables

Use `.env.local` for secrets:

```bash
VITE_WALLET_CONNECT_PROJECT_ID=...
VITE_ALCHEMY_API_KEY=...
```

Access with:
```ts
import.meta.env.VITE_WALLET_CONNECT_PROJECT_ID
```

## Deployment

### Vercel (recommended for frontend)
- Easy setup
- Great DX
- Auto-deploy on push

### Netlify (alternative)
### Cloudflare Pages (alternative)

## Don't Use

- Create React App (deprecated, use Vite)
- Webpack directly (use Vite)
- Class components (use hooks)
- PropTypes (use TypeScript)
- CSS Modules (use Tailwind)
- Styled Components (performance, use Tailwind)
- Emotion (same as above)

## File Naming Conventions

```
PascalCase: Components (Button.tsx, UserProfile.tsx)
camelCase: Hooks (useAuth.ts, useContract.ts)
camelCase: Utils (formatAddress.ts, validateInput.ts)
kebab-case: Routes/pages (user-profile.tsx) - optional
```

## Import Order

1. React imports
2. Third-party libraries
3. Wagmi/Viem imports
4. Internal components
5. Internal hooks
6. Utils/helpers
7. Types
8. Styles

```tsx
import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { useAccount } from 'wagmi'
import { Button } from '@/components/Button'
import { useToken } from '@/hooks/useToken'
import { formatAddress } from '@/lib/utils'
import type { Token } from '@/types'
```
