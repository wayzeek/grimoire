# Web3 Integration

Web3 integration patterns using Wagmi and Viem.

## Table of Contents

1. [Wagmi Hooks Pattern](#wagmi-hooks-pattern)
2. [Transaction State Management](#transaction-state-management)
3. [Network Switching](#network-switching)
4. [Error Handling](#error-handling)

## Web3 Integration

### Wagmi Hooks Pattern

```typescript
// GOOD: Proper Wagmi hook usage
import { useAccount, useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { parseEther } from 'viem';

function TokenTransfer() {
  const { address } = useAccount();

  // Read contract state
  const { data: balance } = useReadContract({
    address: TOKEN_ADDRESS,
    abi: erc20Abi,
    functionName: 'balanceOf',
    args: address ? [address] : undefined,
    enabled: Boolean(address),
  });

  // Write contract
  const { data: hash, writeContract, isPending } = useWriteContract();

  // Wait for confirmation
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  const handleTransfer = async (recipient: Address, amount: string) => {
    try {
      await writeContract({
        address: TOKEN_ADDRESS,
        abi: erc20Abi,
        functionName: 'transfer',
        args: [recipient, parseEther(amount)],
      });
    } catch (error) {
      console.error('Transfer failed:', error);
    }
  };

  return (
    <div>
      <p>Balance: {balance ? formatEther(balance) : '0'}</p>
      <button
        onClick={() => handleTransfer(RECIPIENT, '1.0')}
        disabled={isPending || isConfirming}
      >
        {isPending ? 'Sending...' : isConfirming ? 'Confirming...' : 'Send'}
      </button>
      {isSuccess && <p>Transfer successful!</p>}
    </div>
  );
}
```

### Transaction State Management

```typescript
// GOOD: Comprehensive transaction handling
function useTokenTransfer(tokenAddress: Address) {
  const [state, setState] = useState<TransactionState>({ status: 'idle' });
  const { writeContract } = useWriteContract();

  const transfer = useCallback(async (to: Address, amount: bigint) => {
    setState({ status: 'preparing' });

    try {
      // Simulate gas estimation
      setState({ status: 'estimating' });

      // Write transaction
      setState({ status: 'signing' });
      const hash = await writeContract({
        address: tokenAddress,
        abi: erc20Abi,
        functionName: 'transfer',
        args: [to, amount],
      });

      setState({ status: 'pending', hash });

      // Wait for confirmation
      const receipt = await waitForTransaction({ hash });

      setState({
        status: 'success',
        hash,
        blockNumber: receipt.blockNumber
      });

      return receipt;
    } catch (error) {
      setState({
        status: 'error',
        error: error as Error
      });
      throw error;
    }
  }, [tokenAddress, writeContract]);

  const reset = useCallback(() => {
    setState({ status: 'idle' });
  }, []);

  return { transfer, reset, state };
}
```

### Network Switching

```typescript
// GOOD: Handle network changes
import { useSwitchChain, useChainId } from 'wagmi';
import { mainnet, polygon } from 'wagmi/chains';

function NetworkSwitcher() {
  const chainId = useChainId();
  const { switchChain, isPending } = useSwitchChain();

  const supportedChains = [mainnet, polygon];
  const currentChain = supportedChains.find(c => c.id === chainId);

  const handleSwitchNetwork = async (targetChainId: number) => {
    try {
      await switchChain({ chainId: targetChainId });
    } catch (error) {
      if ((error as any).code === 4902) {
        // Chain not added to wallet
        toast.error('Please add this network to your wallet');
      } else {
        toast.error('Failed to switch network');
      }
    }
  };

  return (
    <select
      value={chainId}
      onChange={(e) => handleSwitchNetwork(Number(e.target.value))}
      disabled={isPending}
    >
      {supportedChains.map((chain) => (
        <option key={chain.id} value={chain.id}>
          {chain.name}
        </option>
      ))}
    </select>
  );
}
```

### Error Handling

```typescript
// GOOD: User-friendly error messages
import { BaseError, ContractFunctionRevertedError } from 'viem';

function parseContractError(error: unknown): string {
  if (error instanceof BaseError) {
    const revertError = error.walk(err => err instanceof ContractFunctionRevertedError);

    if (revertError instanceof ContractFunctionRevertedError) {
      const errorName = revertError.data?.errorName;

      // Map contract errors to user-friendly messages
      switch (errorName) {
        case 'InsufficientBalance':
          return 'You do not have enough tokens for this transaction';
        case 'Unauthorized':
          return 'You are not authorized to perform this action';
        case 'InvalidAmount':
          return 'Please enter a valid amount';
        default:
          return revertError.data?.args?.toString() || 'Transaction failed';
      }
    }
  }

  // User rejected transaction
  if (error instanceof Error && error.message.includes('User rejected')) {
    return 'Transaction was cancelled';
  }

  return 'An unexpected error occurred';
}

// Usage
function TransferButton() {
  const [error, setError] = useState<string | null>(null);

  const handleTransfer = async () => {
    try {
      await transfer(recipient, amount);
    } catch (err) {
      setError(parseContractError(err));
    }
  };

  return (
    <>
      <button onClick={handleTransfer}>Transfer</button>
      {error && <ErrorMessage>{error}</ErrorMessage>}
    </>
  );
}
```
