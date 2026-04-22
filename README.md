# WPI Credential System: Oracle-Verified Blockchain Credentials for Project-Based Education

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.24-blue.svg)](https://soliditylang.org/)
[![Chainlink](https://img.shields.io/badge/Chainlink-Functions%20%7C%20CCIP-375BD2.svg)](https://chain.link/)
[![Network](https://img.shields.io/badge/Network-Sepolia%20Testnet-green.svg)](https://sepolia.etherscan.io/)

A soulbound, oracle-verified credential system that transforms university project outcomes into portable, independently verifiable records on the blockchain. Built at [Worcester Polytechnic Institute](https://www.wpi.edu/) (WPI) using Chainlink Functions for impact verification.

---

## The Problem

Universities produce millions of project outcomes each year, but academic credentials remain opaque. A transcript shows a grade — it says nothing verifiable about what a student built, what skills they demonstrated, or whether their work left its stakeholders better off. Employers cannot independently verify project claims. Funders cannot confirm impact. The credential system is built on institutional authority, not evidence.

## The Solution

This system issues **soulbound (non-transferable) NFT credentials** that encode structured project metadata — skills, deliverables, partner organizations, and impact assessments — conforming to the [W3C Verifiable Credentials 2.0](https://www.w3.org/TR/vc-data-model-2.0/) standard and [Open Badges 3.0](https://www.imsglobal.org/spec/ob/v3p0) specification.

What makes this different from existing digital badge platforms: **Chainlink Functions** queries external data sources (World Bank Open Data, EPA, partner-organization APIs) to **independently verify impact claims** before they are recorded on-chain. The credential carries oracle-attested evidence, not just institutional assertion.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    WPI FinTech Lab                       │
│                                                         │
│  ┌─────────────┐    ┌──────────────┐    ┌────────────┐ │
│  │   Faculty    │───▶│  Admin       │───▶│  Credential│ │
│  │   Advisor    │    │  Dashboard   │    │  Registry  │ │
│  │   Reviews    │    │  (Next.js)   │    │  (ERC-721) │ │
│  └─────────────┘    └──────────────┘    └─────┬──────┘ │
│                                               │        │
│  ┌─────────────┐    ┌──────────────┐    ┌─────▼──────┐ │
│  │  External   │◀───│  Chainlink   │◀───│  Impact    │ │
│  │  Data APIs  │    │  Functions   │    │  Verifier  │ │
│  │  (WB, EPA)  │───▶│  (Oracle)    │───▶│  Contract  │ │
│  └─────────────┘    └──────────────┘    └────────────┘ │
│                                                         │
│  ┌─────────────┐    ┌──────────────┐                   │
│  │   IPFS      │◀───│  Project     │                   │
│  │   (Pinata)  │    │  Reports     │                   │
│  └─────────────┘    └──────────────┘                   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                  Public Verification                     │
│                                                         │
│  ┌─────────────┐    ┌──────────────┐    ┌────────────┐ │
│  │  Employer   │───▶│  Verification│───▶│  On-Chain   │ │
│  │  or Funder  │    │  Portal      │    │  Query      │ │
│  │             │◀───│  (Next.js)   │◀───│  (ethers.js)│ │
│  └─────────────┘    └──────────────┘    └────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## Repository Structure

```
wpi-credentials/
├── contracts/
│   ├── WPICredentialRegistry.sol    # Soulbound ERC-721 credential token
│   └── ImpactVerifier.sol           # Chainlink Functions impact verification
├── test/
│   ├── WPICredentialRegistry.test.js
│   └── ImpactVerifier.test.js
├── scripts/
│   ├── deploy.js                    # Deployment script for Sepolia
│   └── issue-credential.js          # Example credential issuance
├── docs/
│   ├── ARCHITECTURE.md              # Technical architecture deep-dive
│   ├── CREDENTIAL_SCHEMA.md         # Credential metadata specification
│   ├── IMPACT_FRAMEWORK.md          # Impact assessment methodology
│   ├── DEPLOYMENT_GUIDE.md          # Step-by-step deployment instructions
│   └── FERPA_COMPLIANCE.md          # Privacy and regulatory considerations
├── frontend/                        # Verification portal (Next.js) [coming]
├── .github/
│   ├── ISSUE_TEMPLATE/
│   └── CONTRIBUTING.md
├── hardhat.config.js
├── package.json
├── .env.example
├── .gitignore
└── LICENSE
```

## Quick Start

### Prerequisites

- Node.js v18+
- MetaMask browser extension
- Free Sepolia testnet ETH ([Chainlink Faucet](https://faucets.chain.link/))

### Installation

```bash
git clone https://github.com/[your-username]/wpi-credentials.git
cd wpi-credentials
npm install
cp .env.example .env
# Add your Alchemy URL and private key to .env
```

### Compile and Test

```bash
npx hardhat compile
npx hardhat test
npx hardhat coverage
```

### Deploy to Sepolia

```bash
npx hardhat run scripts/deploy.js --network sepolia
```

### Issue a Credential

```bash
npx hardhat run scripts/issue-credential.js --network sepolia
```

## Credential Schema

Each credential token stores the following on-chain metadata:

| Field | Type | Description |
|-------|------|-------------|
| `projectTitle` | string | Name of the MQP/IQP project |
| `ipfsHash` | string | IPFS CID linking to the full project report |
| `skillsTags` | string | Comma-separated skill taxonomy tags |
| `sdgAlignment` | string | UN SDG target numbers (e.g., "SDG6,SDG9") |
| `impactScore` | uint8 | Verified impact score (0–100) |
| `issuedAt` | uint256 | Block timestamp of issuance |
| `oracleVerified` | bool | Whether Chainlink Functions confirmed impact claims |

Full schema specification: [`docs/CREDENTIAL_SCHEMA.md`](docs/CREDENTIAL_SCHEMA.md)

## Chainlink Integration

### Chainlink Functions

Used to verify impact claims against external data sources. The verification flow:

1. Project team submits structured impact data via the admin dashboard
2. The Impact Verifier contract triggers a Chainlink Functions request
3. Functions executes custom JavaScript off-chain, querying external APIs
4. Verification result is returned on-chain and recorded in the credential
5. Credential is minted with `oracleVerified: true`

### Chainlink CCIP (Planned)

Cross-chain credential portability — ensuring credentials issued on one network are verifiable across ecosystems.

### Chainlink Automation (Planned)

Time-based triggers for batch credential issuance at term end and periodic impact re-verification.

## Impact Assessment Framework

Credentials are scored across five dimensions:

| Dimension | Weight | Description |
|-----------|--------|-------------|
| Stakeholder Reach | 20% | Populations directly affected |
| Outcome Evidence | 30% | Measurable, attributable change |
| SDG Alignment | 15% | Mapping to UN SDG targets |
| Sustainability | 20% | Post-project persistence |
| Unintended Effects | 15% | Honest accounting of trade-offs |

Full methodology: [`docs/IMPACT_FRAMEWORK.md`](docs/IMPACT_FRAMEWORK.md)

## Regulatory Context

- **GENIUS Act** (signed July 18, 2025): First federal stablecoin regulatory framework. Provides regulatory clarity for institutional blockchain experimentation.
- **FERPA Compliance**: No personally identifiable information stored on-chain. Students opt in and control their own credential wallets. See [`docs/FERPA_COMPLIANCE.md`](docs/FERPA_COMPLIANCE.md).
- **W3C VC 2.0 / Open Badges 3.0**: International credential standards ensuring interoperability.

## Institutional Context

WPI is the only U.S. undergraduate institution requiring every student to complete both an industry-sponsored technical capstone (MQP) and a community-impact project (IQP) — producing 1,100+ projects annually with real stakeholders and measurable outcomes. This system instruments that existing pipeline with oracle-verified, blockchain-anchored accountability.

## Roadmap

| Phase | Timeline | Status |
|-------|----------|--------|
| Phase 0: Foundation | Summer 2026 | **In progress** |
| Phase 1: Build (smart contracts, frontend) | Fall 2026 | Planned |
| Phase 2: Pilot (20–30 credentials) | Spring 2027 | Planned |
| Phase 3: Scale (production L2, 100+ credentials) | AY 2027–28 | Planned |

## Contributing

We welcome contributions from the WPI community and the broader Chainlink ecosystem. See [CONTRIBUTING.md](.github/CONTRIBUTING.md) for guidelines.

## Team

- **Daniel [Last Name], Ph.D.** — Project Lead, Assistant Teaching Professor, WPI Business School
- **WPI FinTech Lab** — Institutional home
- **WPI Blockchain Club** — Student developer community
- **MQP/IQP Teams AY 2026–27** — Development teams (recruiting)

## Acknowledgments

This project is developed in partnership with [Chainlink Labs](https://chain.link/) through the Community Grant Program. Built with [OpenZeppelin Contracts](https://www.openzeppelin.com/contracts), [Hardhat](https://hardhat.org/), and [Alchemy](https://www.alchemy.com/).

## License

MIT License. See [LICENSE](LICENSE) for details.
