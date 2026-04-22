# Deployment Guide

## Prerequisites

- Node.js v18 or later
- MetaMask browser extension
- Free Sepolia testnet ETH
- Free Alchemy account

## Step 1: Clone and Install

```bash
git clone https://github.com/wpi-fintech-lab/wpi-credentials.git
cd wpi-credentials
npm install
```

## Step 2: Configure Environment

```bash
cp .env.example .env
```

Edit `.env` with your values:
- `ALCHEMY_URL`: Create a free app at alchemy.com on the Sepolia network
- `PRIVATE_KEY`: Export from MetaMask (Account Details > Show Private Key)
- `ETHERSCAN_API_KEY`: Register at etherscan.io/apis

## Step 3: Get Free Testnet ETH

Visit one of these faucets:
- Chainlink Faucet: https://faucets.chain.link/
- Google Cloud Faucet: https://cloud.google.com/application/web3/faucet
- Alchemy Faucet: https://www.alchemy.com/faucets/ethereum-sepolia

You need approximately 0.05 Sepolia ETH for deployment and testing.

## Step 4: Compile

```bash
npx hardhat compile
```

## Step 5: Test

```bash
npx hardhat test
npx hardhat coverage  # Check coverage report
```

## Step 6: Deploy to Sepolia

```bash
npx hardhat run scripts/deploy.js --network sepolia
```

Save the deployed contract address from the output.

## Step 7: Verify on Etherscan

```bash
npx hardhat verify --network sepolia YOUR_CONTRACT_ADDRESS
```

## Step 8: Issue a Test Credential

1. Edit `scripts/issue-credential.js`:
   - Set `REGISTRY_ADDRESS` to your deployed address
   - Set `STUDENT_ADDRESS` to a test wallet

2. Run:
```bash
npx hardhat run scripts/issue-credential.js --network sepolia
```

## Total Cost

| Item | Cost |
|------|------|
| All software and tools | $0 |
| Sepolia testnet ETH | $0 (faucet) |
| Alchemy RPC access | $0 (free tier) |
| Etherscan verification | $0 (free tier) |
| **Total** | **$0** |
