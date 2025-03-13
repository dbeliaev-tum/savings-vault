# SavingsVault Smart Contract

## Overview

**SavingsVault** is a decentralized savings smart contract built on Ethereum using Solidity. This contract allows users to securely deposit funds with a time lock, preventing withdrawals until the specified period has elapsed. The contract is designed for demonstration purposes, showcasing Solidity skills and fundamental DeFi concepts.

## Features

-   **Time-Locked Deposits:** Users can deposit funds and set a lock duration.
-   **Secure Withdrawals:** Funds become available only after the lock period ends.
-   **Deposits control functionality:** Users can review all deposited funds and monitor their unlock times.
-   **Owner Privileges:** Contract ownership is managed via OpenZeppelin's `Ownable`.

## Implemented Gas Optimization Techniques

The `SavingsVault` smart contract incorporates several gas optimization techniques to reduce transaction costs:

1. **Efficient Storage with `Deposit[]`**
- User deposits are stored in `mapping(address => Deposit[])`, rather than separate mappings for amounts and unlock times, reducing storage access costs.

2. **Using `storage` Instead of `memory` for Structs**
- In functions like `getMyDeposits`, `withdraw`, and `getLockedBalance`, the contract uses `Deposit[] storage deposits = userDeposits[msg.sender];`, which allows direct access to storage data instead of copying it to memory, reducing gas costs.

3. **Using `++i` Instead of `i++`**
- Prefix increment (`++i`) is used instead of postfix (`i++`) in loops, as it is slightly cheaper in gas usage in the EVM.

4. **Optimized Element Removal in `withdraw`**
- Instead of shifting elements in the array when removing unlocked deposits, the last element replaces the removed one (`deposits[i] = deposits[length - 1];`), followed by `pop()`, significantly reducing gas costs.

5. **Storing `block.timestamp` in a Local Variable**
- Functions `getMyDeposits` and `getLockedBalance` store `block.timestamp` in `currentTimestamp`, avoiding multiple redundant calls.

6. **Using `call` Instead of `transfer` or `send`**
- The withdrawal function uses `call{value: totalAmount}("")` instead of `transfer`, avoiding the 2300 gas stipend limit and increasing compatibility with different contract interactions.

These optimizations improve the contract’s efficiency and reduce gas fees for user interactions.


## Prerequisites

To interact with the smart contract, ensure you have:

-   Node.js (for Hardhat or Foundry setup)
-   Solidity Compiler (Solc v0.8.20)
-   Metamask or a Web3 Wallet
-   An Ethereum Testnet (Goerli, Sepolia, etc.) for Testing

## Deployment

To deploy the contract, follow these steps:

1.  Clone the repository:

    ```bash
    git clone [https://github.com/dbeliaev-tum/savings-vault.git](https://github.com/your-repo/savings-vault.git)
    cd savings-vault
    ```

2.  Install dependencies (if using Hardhat):

    ```bash
    npm install
    ```

3.  Compile the contract:

    ```bash
    npx hardhat compile
    ```


4. Deploy the contract:

   If using **Hardhat**, ensure you have a deployment script (`scripts/deploy.js`). Then run:

    ```bash
    npx hardhat run scripts/deploy.js --network goerli
    ```

   If using **Foundry**, deploy with:

    ```bash
    forge create --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> src/SavingsVault.sol:SavingsVault --constructor-args <OWNER_ADDRESS>
    ```

   Alternatively, you can deploy manually using **Remix**.

## Usage

### Deposit Funds

To deposit ETH with a lock time:

```solidity
savingsVault.deposit{value: 1 ether}(86400); // Lock for 1 day (86400 seconds)
```

### View Deposits

To retrieve your deposits:

```solidity
(uint256[] memory amounts, uint256[] memory timeLeft) = savingsVault.getMyDeposits();
```

### Withdraw Funds

To withdraw available funds:

```solidity
savingsVault.withdraw();
```

### Check Locked Balance

To check the total locked balance:

```solidity
uint256 lockedBalance = savingsVault.getLockedBalance();
```

## Testing

To run tests using Hardhat:

```bash
npx hardhat test
```

Ensure you have unit tests covering:
- Deposits with valid/invalid lock times
- Withdrawals after lock expiration
- Unauthorized access prevention

## Security Considerations

- **Reentrancy Protection:** Uses `call` with proper security checks.
- **Gas Optimization:** Uses storage caching to minimize costs.
- **Immutable Ownership:** The contract uses OpenZeppelin's Ownable.

## License

This project is licensed under the **MIT License.**

## Potential Use Cases

The **SavingsVault** smart contract can be utilized in various real-world scenarios, demonstrating its practical value in DeFi and beyond.

### 1. **Personal Savings Management**
- Users can lock funds for a specific period to enforce self-discipline in savings.
- Prevents impulsive spending by making funds inaccessible until a predefined unlock time.

### 2. **Time-Locked Payments**
- Employers or organizations can set up future payments for employees or contractors.
- Escrow-like functionality where payments are automatically released after a lock period.

### 3. **DeFi Yield Strategies**
- Can be integrated into staking mechanisms where users commit funds for a fixed period in exchange for rewards.
- Could be used alongside interest-bearing protocols to automate locked savings growth.

### 4. **Token Vesting for Projects**
- Startups can utilize **SavingsVault** to time-lock team or investor funds, ensuring fair token distribution.
- Reduces the risk of premature sell-offs by enforcing vesting periods.

### 5. **Decentralized Subscriptions**
- Users deposit funds for a locked duration to gain access to premium services (e.g., decentralized storage, VPNs, content platforms).
- It could help engage and retain customers.
- Funds are released automatically after the subscription period ends.

## Contact

For inquiries or contributions, reach out via **GitHub Issues** or **linkedin.com/in/denis-beliaev**.

---

_This repository is for **educational and demonstration purposes only**. Do not use it for storing real funds._