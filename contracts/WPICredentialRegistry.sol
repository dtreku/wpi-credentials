// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title WPICredentialRegistry
 * @author WPI FinTech Lab
 * @notice Soulbound ERC-721 credential token for verified project outcomes.
 * @dev Non-transferable by design. Once minted, credentials cannot be moved
 *      between wallets. This ensures the credential remains bound to the
 *      student who earned it.
 *
 *      Conforms to:
 *        - W3C Verifiable Credentials Data Model 2.0
 *        - 1EdTech Open Badges 3.0
 *
 *      Metadata is stored on-chain for immutability. Full project reports
 *      are stored on IPFS and linked via content hash.
 */
contract WPICredentialRegistry is ERC721, Ownable {
    // ──────────────────────────────────────────────
    //  State
    // ──────────────────────────────────────────────

    uint256 private _tokenIdCounter;

    struct Credential {
        string projectTitle;
        string ipfsHash;
        string skillsTags;
        string sdgAlignment;
        uint8 impactScore;
        uint256 issuedAt;
        bool oracleVerified;
        address verifierContract;
    }

    /// @notice Credential metadata indexed by token ID
    mapping(uint256 => Credential) public credentials;

    /// @notice Addresses authorized to issue credentials (faculty, lab admin)
    mapping(address => bool) public authorizedIssuers;

    // ──────────────────────────────────────────────
    //  Events
    // ──────────────────────────────────────────────

    event CredentialIssued(
        uint256 indexed tokenId,
        address indexed student,
        string projectTitle,
        uint8 impactScore,
        bool oracleVerified
    );

    event IssuerAuthorized(address indexed issuer);
    event IssuerRevoked(address indexed issuer);
    event ImpactScoreUpdated(uint256 indexed tokenId, uint8 newScore, bool oracleVerified);

    // ──────────────────────────────────────────────
    //  Errors
    // ──────────────────────────────────────────────

    error NotAuthorizedIssuer();
    error TokenDoesNotExist();
    error SoulboundNonTransferable();
    error InvalidImpactScore();

    // ──────────────────────────────────────────────
    //  Modifiers
    // ──────────────────────────────────────────────

    modifier onlyIssuer() {
        if (!authorizedIssuers[msg.sender] && msg.sender != owner()) {
            revert NotAuthorizedIssuer();
        }
        _;
    }

    modifier tokenExists(uint256 tokenId) {
        if (tokenId >= _tokenIdCounter) revert TokenDoesNotExist();
        _;
    }

    // ──────────────────────────────────────────────
    //  Constructor
    // ──────────────────────────────────────────────

    constructor() ERC721("WPI Learning Token", "WPILT") Ownable(msg.sender) {
        authorizedIssuers[msg.sender] = true;
    }

    // ──────────────────────────────────────────────
    //  Issuer Management
    // ──────────────────────────────────────────────

    /// @notice Authorize an address to issue credentials
    /// @param issuer Address to authorize (e.g., faculty advisor, lab admin)
    function authorizeIssuer(address issuer) external onlyOwner {
        authorizedIssuers[issuer] = true;
        emit IssuerAuthorized(issuer);
    }

    /// @notice Revoke issuer authorization
    /// @param issuer Address to revoke
    function revokeIssuer(address issuer) external onlyOwner {
        authorizedIssuers[issuer] = false;
        emit IssuerRevoked(issuer);
    }

    // ──────────────────────────────────────────────
    //  Credential Issuance
    // ──────────────────────────────────────────────

    /// @notice Issue a new soulbound credential to a student
    /// @param student Wallet address of the credential recipient
    /// @param projectTitle Name of the MQP/IQP project
    /// @param ipfsHash IPFS CID of the full project report
    /// @param skillsTags Comma-separated skill taxonomy tags
    /// @param sdgAlignment UN SDG target numbers (e.g., "SDG6,SDG9")
    /// @param impactScore Verified impact score (0-100)
    /// @param oracleVerified Whether Chainlink Functions confirmed impact
    /// @return tokenId The ID of the newly minted credential
    function issueCredential(
        address student,
        string calldata projectTitle,
        string calldata ipfsHash,
        string calldata skillsTags,
        string calldata sdgAlignment,
        uint8 impactScore,
        bool oracleVerified
    ) external onlyIssuer returns (uint256) {
        if (impactScore > 100) revert InvalidImpactScore();

        uint256 tokenId = _tokenIdCounter++;
        _safeMint(student, tokenId);

        credentials[tokenId] = Credential({
            projectTitle: projectTitle,
            ipfsHash: ipfsHash,
            skillsTags: skillsTags,
            sdgAlignment: sdgAlignment,
            impactScore: impactScore,
            issuedAt: block.timestamp,
            oracleVerified: oracleVerified,
            verifierContract: address(0)
        });

        emit CredentialIssued(tokenId, student, projectTitle, impactScore, oracleVerified);
        return tokenId;
    }

    // ──────────────────────────────────────────────
    //  Impact Score Updates (Oracle Callback)
    // ──────────────────────────────────────────────

    /// @notice Update impact score after oracle verification completes
    /// @dev Called by the ImpactVerifier contract or an authorized issuer
    /// @param tokenId Credential to update
    /// @param newScore Updated impact score from oracle verification
    function updateImpactScore(
        uint256 tokenId,
        uint8 newScore
    ) external onlyIssuer tokenExists(tokenId) {
        if (newScore > 100) revert InvalidImpactScore();

        credentials[tokenId].impactScore = newScore;
        credentials[tokenId].oracleVerified = true;
        credentials[tokenId].verifierContract = msg.sender;

        emit ImpactScoreUpdated(tokenId, newScore, true);
    }

    // ──────────────────────────────────────────────
    //  Soulbound Enforcement
    // ──────────────────────────────────────────────

    /// @dev Override to prevent all transfers except minting (from == address(0))
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override returns (address) {
        address from = _ownerOf(tokenId);
        if (from != address(0)) {
            revert SoulboundNonTransferable();
        }
        return super._update(to, tokenId, auth);
    }

    // ──────────────────────────────────────────────
    //  View Functions
    // ──────────────────────────────────────────────

    /// @notice Retrieve full credential metadata
    /// @param tokenId Token ID to query
    /// @return Credential struct with all metadata
    function getCredential(
        uint256 tokenId
    ) external view tokenExists(tokenId) returns (Credential memory) {
        return credentials[tokenId];
    }

    /// @notice Check if a credential has been oracle-verified
    /// @param tokenId Token ID to query
    /// @return True if Chainlink Functions has verified the impact claims
    function isOracleVerified(
        uint256 tokenId
    ) external view tokenExists(tokenId) returns (bool) {
        return credentials[tokenId].oracleVerified;
    }

    /// @notice Total number of credentials issued
    /// @return Count of all credentials ever minted
    function totalIssued() external view returns (uint256) {
        return _tokenIdCounter;
    }
}
