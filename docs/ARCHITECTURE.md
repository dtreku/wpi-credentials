# Architecture

## System Overview

The WPI Credential System consists of four layers:

### 1. Smart Contract Layer (On-Chain)

**WPICredentialRegistry** — A soulbound ERC-721 contract that stores credential metadata and enforces non-transferability. Each credential is a token bound permanently to the student's wallet.

**ImpactVerifier** — A Chainlink Functions consumer contract that accepts impact verification requests, executes off-chain JavaScript via the Chainlink DON, and records the verification result on-chain.

### 2. Oracle Layer (Chainlink)

**Chainlink Functions** — Executes custom JavaScript off-chain to query external data sources (World Bank Open Data API, EPA Environmental Data Gateway, partner-organization APIs). Returns structured verification results to the ImpactVerifier contract.

**Chainlink CCIP** (Planned) — Enables cross-chain credential verification. A credential issued on Polygon should be verifiable from Ethereum mainnet or any CCIP-supported chain.

**Chainlink Automation** (Planned) — Automates batch credential issuance at the end of each academic term and periodic impact re-verification for longitudinal tracking.

### 3. Storage Layer (Off-Chain)

**IPFS (Pinata)** — Full project reports, evidence documents, and supplementary data are stored on IPFS. The on-chain credential stores only the IPFS content identifier (CID), ensuring immutability without blockchain storage costs.

### 4. Application Layer (Frontend)

**Admin Dashboard** — Next.js application for WPI faculty and staff. Used to initiate credential issuance, review impact assessments, and manage the issuance pipeline.

**Verification Portal** — Public-facing Next.js application. Employers, graduate schools, or funders enter a token ID or scan a QR code to verify a credential. Queries the blockchain directly via ethers.js — no backend server required.

## Data Flow

```
Student completes project
        │
        ▼
Faculty advisor reviews and grades (existing WPI process)
        │
        ▼
Team submits Impact Assessment Report (IAR)
        │
        ▼
Admin dashboard submits IAR data to ImpactVerifier contract
        │
        ▼
ImpactVerifier triggers Chainlink Functions request
        │
        ▼
Functions JavaScript queries external APIs
        │
        ▼
Verification result returned on-chain
        │
        ▼
WPICredentialRegistry mints soulbound token
        │
        ▼
Student receives credential in wallet
        │
        ▼
Employer verifies via public portal
```

## Security Considerations

- **Access control**: Only authorized issuers (faculty, lab admin) can mint credentials or update impact scores. Owner can add/revoke issuers.
- **Soulbound enforcement**: Transfer function overridden to revert on all transfers except minting. Students cannot sell or trade credentials.
- **No PII on-chain**: Student names, IDs, and other FERPA-protected data are never stored on the blockchain.
- **Input validation**: Impact scores are bounded (0–100). Custom errors provide clear revert reasons.
- **Oracle trust**: Chainlink Functions provides decentralized off-chain computation. Verification results are cryptographically attested.

## Contract Dependencies

- OpenZeppelin Contracts v5.x (ERC-721, Ownable)
- Chainlink Contracts v1.1.x (FunctionsClient, FunctionsRequest)
