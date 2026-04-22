# Credential Schema

## On-Chain Metadata

Each WPI Learning Token stores the following struct on-chain:

```solidity
struct Credential {
    string projectTitle;       // Name of the MQP/IQP project
    string ipfsHash;           // IPFS CID linking to full report
    string skillsTags;         // Comma-separated skill taxonomy
    string sdgAlignment;       // UN SDG target numbers
    uint8 impactScore;         // Verified impact score (0-100)
    uint256 issuedAt;          // Block timestamp of issuance
    bool oracleVerified;       // Chainlink Functions verification status
    address verifierContract;  // Address of the verifier (if oracle-verified)
}
```

## Field Specifications

### projectTitle
Full title of the project as it appears in WPI's project database.
- Format: Free text
- Example: `"Water Filtration System for Namibia — C2027 IQP"`

### ipfsHash
Content identifier (CID) for the project report stored on IPFS.
- Format: IPFS CIDv1 string
- Example: `"QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco"`
- Retrieval: `https://gateway.pinata.cloud/ipfs/{ipfsHash}`

### skillsTags
Skills and competencies demonstrated in the project.
- Format: Comma-separated, no spaces after commas
- Taxonomy: Aligned with ESCO (European Skills, Competences, Qualifications and Occupations) where possible
- Example: `"IoT,Water-Treatment,Sustainability,Embedded-Systems,Project-Management"`

### sdgAlignment
United Nations Sustainable Development Goals addressed by the project.
- Format: Comma-separated SDG identifiers
- Reference: https://sdgs.un.org/goals
- Example: `"SDG6,SDG9"` (Clean Water and Sanitation; Industry, Innovation and Infrastructure)

### impactScore
Aggregate impact assessment score based on the five-dimension rubric.
- Range: 0–100 (uint8)
- Thresholds: ≥80 = "Verified High Impact"; 60–79 = "Verified Impact"; <60 = "Impact Assessment Completed"
- See: docs/IMPACT_FRAMEWORK.md

### oracleVerified
Whether the impact claims were independently verified by Chainlink Functions.
- `true`: At least one impact claim was cross-checked against an external data source
- `false`: Impact assessment was advisor-verified only

## W3C Verifiable Credentials Mapping

The on-chain credential maps to the W3C VC Data Model 2.0 as follows:

| W3C VC Field | WPI Implementation |
|---|---|
| `issuer` | WPI FinTech Lab (contract owner address) |
| `credentialSubject.id` | Student's Ethereum wallet address |
| `credentialSubject.achievement` | projectTitle + skillsTags |
| `credentialSubject.evidence` | IPFS link (ipfsHash) |
| `issuanceDate` | issuedAt (block timestamp) |
| `proof` | On-chain transaction + oracle attestation |

## Open Badges 3.0 Mapping

| Open Badges Field | WPI Implementation |
|---|---|
| `Achievement.name` | projectTitle |
| `Achievement.criteria` | Linked via IPFS report |
| `Achievement.tag` | skillsTags (parsed to array) |
| `Result.value` | impactScore |
| `Evidence` | IPFS report + oracle verification record |
