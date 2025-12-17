# Accessibility Patterns

Accessibility (A11y) best practices for React applications.

## Table of Contents

1. [Semantic HTML](#semantic-html)
2. [ARIA Attributes](#aria-attributes)
3. [Keyboard Navigation](#keyboard-navigation)
4. [Focus Management](#focus-management)

## Accessibility Patterns

### Semantic HTML

```typescript
// BAD: Divs for everything
<div onClick={handleClick}>Click me</div>
<div className="heading">Title</div>

// GOOD: Semantic elements
<button onClick={handleClick}>Click me</button>
<h1>Title</h1>
<nav>
  <ul>
    <li><a href="/">Home</a></li>
  </ul>
</nav>
```

### ARIA Attributes

```typescript
// GOOD: Proper ARIA labels
function WalletButton({ isConnected, address }: WalletButtonProps) {
  return (
    <button
      aria-label={isConnected ? `Connected: ${address}` : 'Connect wallet'}
      aria-pressed={isConnected}
    >
      {isConnected ? 'Connected' : 'Connect'}
    </button>
  );
}

// GOOD: Loading states
function TransactionStatus({ isPending }: { isPending: boolean }) {
  return (
    <div role="status" aria-live="polite" aria-busy={isPending}>
      {isPending ? 'Processing transaction...' : 'Transaction complete'}
    </div>
  );
}

// GOOD: Modal accessibility
function Modal({ isOpen, onClose, children }: ModalProps) {
  return (
    <dialog
      open={isOpen}
      aria-modal="true"
      role="dialog"
      aria-labelledby="modal-title"
    >
      <h2 id="modal-title">Modal Title</h2>
      {children}
      <button onClick={onClose} aria-label="Close modal">
        ×
      </button>
    </dialog>
  );
}
```

### Keyboard Navigation

```typescript
// GOOD: Keyboard-accessible custom components
function Dropdown({ options, onSelect }: DropdownProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [focusedIndex, setFocusedIndex] = useState(0);

  const handleKeyDown = (e: KeyboardEvent<HTMLDivElement>) => {
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        setFocusedIndex((prev) => Math.min(prev + 1, options.length - 1));
        break;
      case 'ArrowUp':
        e.preventDefault();
        setFocusedIndex((prev) => Math.max(prev - 1, 0));
        break;
      case 'Enter':
      case ' ':
        e.preventDefault();
        onSelect(options[focusedIndex]);
        setIsOpen(false);
        break;
      case 'Escape':
        e.preventDefault();
        setIsOpen(false);
        break;
    }
  };

  return (
    <div onKeyDown={handleKeyDown} role="combobox" aria-expanded={isOpen}>
      {/* Implementation */}
    </div>
  );
}
```

### Focus Management

```typescript
// GOOD: Focus trap for modals
import { useFocusTrap } from '@mantine/hooks';

function Modal({ isOpen, onClose, children }: ModalProps) {
  const focusTrapRef = useFocusTrap(isOpen);

  useEffect(() => {
    if (!isOpen) return;

    // Store previously focused element
    const previouslyFocused = document.activeElement as HTMLElement;

    // Return focus on close
    return () => {
      previouslyFocused?.focus();
    };
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div ref={focusTrapRef} role="dialog">
      {children}
    </div>
  );
}
```
