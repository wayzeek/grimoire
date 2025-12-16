# Scaffold New dApp Frontend

Create a new frontend project with Bun + Vite + React + TypeScript + Tailwind + Web3.

## Steps

### 1. Initialize Project

```bash
# Create Vite project with React + TypeScript
bun create vite <project-name> --template react-ts
cd <project-name>

# Install dependencies
bun install
```

### 2. Install Core Dependencies

```bash
# Web3 libraries
bun add viem wagmi @tanstack/react-query

# RainbowKit for wallet UI
bun add @rainbow-me/rainbowkit

# Tailwind CSS
bun add -D tailwindcss postcss autoprefixer
bunx tailwindcss init -p
```

### 3. Configure Tailwind

Update `tailwind.config.js`:

```js
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

Update `src/index.css`:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

### 4. Set Up Project Structure

```
src/
├── components/        # Reusable UI components
├── hooks/            # Custom React hooks
├── lib/              # Utilities and configurations
│   ├── contracts/    # Contract ABIs and addresses
│   └── config.ts     # App configuration
├── pages/            # Page components
├── App.tsx
└── main.tsx
```

### 5. Configure TypeScript

Update `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

### 6. Update Vite Config

Update `vite.config.ts`:

```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
```

### 7. Create Environment Files

`.env.example`:

```bash
VITE_WALLET_CONNECT_PROJECT_ID=
VITE_ALCHEMY_API_KEY=
```

`.env.local`:

```bash
# Get WalletConnect project ID from https://cloud.walletconnect.com/
VITE_WALLET_CONNECT_PROJECT_ID=your_project_id

# Optional: Alchemy API key for RPC
VITE_ALCHEMY_API_KEY=your_api_key
```

### 8. Update .gitignore

```
# dependencies
node_modules/

# production
dist/

# environment
.env
.env.local

# IDE
.vscode/
.idea/

# OS
.DS_Store
```

### 9. Set Up Web3 (if needed now)

If integrating web3 immediately, use `/frontend-wallet` workflow.

### 10. Create Basic App Structure

Update `src/App.tsx`:

```tsx
function App() {
  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto py-6 px-4">
          <h1 className="text-3xl font-bold text-gray-900">
            My dApp
          </h1>
        </div>
      </header>
      <main className="max-w-7xl mx-auto py-6 px-4">
        <p className="text-gray-600">Welcome to your dApp</p>
      </main>
    </div>
  )
}

export default App
```

### 11. Verify Setup

```bash
# Run dev server
bun run dev

# Build for production
bun run build

# Preview production build
bun run preview
```

## Additional Setup (Optional)

### ESLint + Prettier

```bash
bun add -D eslint prettier eslint-config-prettier
bun add -D @typescript-eslint/eslint-plugin @typescript-eslint/parser
```

### Testing

```bash
bun add -D vitest @testing-library/react @testing-library/jest-dom
```

### Path Aliases

Already configured with `@/*` pointing to `src/*`.

## Output
- Fully configured frontend project
- Bun + Vite + React + TypeScript + Tailwind
- Ready for Web3 integration
- Development and build scripts working
