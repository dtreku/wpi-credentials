// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ImpactVerifier
 * @author WPI FinTech Lab
 * @notice Verifies project impact claims using Chainlink Functions.
 * @dev Queries external data sources (World Bank, EPA, partner APIs) to
 *      cross-check impact claims made by student project teams. Returns
 *      a verification result that is recorded in the credential on-chain.
 *
 *      Flow:
 *        1. Faculty submits impact claim with project data
 *        2. Contract sends a Chainlink Functions request
 *        3. Off-chain JavaScript queries external API
 *        4. Result returned on-chain via fulfillRequest callback
 *        5. Verification status recorded for credential system
 */
contract ImpactVerifier is FunctionsClient, Ownable {
    using FunctionsRequest for FunctionsRequest.Request;

    // ──────────────────────────────────────────────
    //  State
    // ──────────────────────────────────────────────

    /// @notice Chainlink Functions subscription ID
    uint64 public subscriptionId;

    /// @notice Gas limit for Functions callback
    uint32 public callbackGasLimit = 300_000;

    /// @notice DON ID for the Chainlink Functions network
    bytes32 public donId;

    struct VerificationRequest {
        uint256 credentialTokenId;
        string claimedMetric;
        string claimedValue;
        string dataSourceUrl;
        bool fulfilled;
        bool verified;
        uint8 verifiedScore;
        bytes rawResponse;
    }

    /// @notice Verification requests indexed by Chainlink request ID
    mapping(bytes32 => VerificationRequest) public verificationRequests;

    /// @notice Mapping from credential token ID to its latest verification request ID
    mapping(uint256 => bytes32) public credentialToRequestId;

    /// @notice Address of the WPICredentialRegistry contract
    address public credentialRegistry;

    // ──────────────────────────────────────────────
    //  Events
    // ──────────────────────────────────────────────

    event VerificationRequested(
        bytes32 indexed requestId,
        uint256 indexed credentialTokenId,
        string claimedMetric,
        string claimedValue
    );

    event VerificationFulfilled(
        bytes32 indexed requestId,
        uint256 indexed credentialTokenId,
        bool verified,
        uint8 verifiedScore
    );

    // ──────────────────────────────────────────────
    //  Errors
    // ──────────────────────────────────────────────

    error UnexpectedRequestId(bytes32 requestId);

    // ──────────────────────────────────────────────
    //  Constructor
    // ──────────────────────────────────────────────

    /// @param router Chainlink Functions router address (network-specific)
    /// @param _subscriptionId Chainlink Functions subscription ID
    /// @param _donId DON ID for the target Chainlink Functions network
    constructor(
        address router,
        uint64 _subscriptionId,
        bytes32 _donId
    ) FunctionsClient(router) Ownable(msg.sender) {
        subscriptionId = _subscriptionId;
        donId = _donId;
    }

    // ──────────────────────────────────────────────
    //  Configuration
    // ──────────────────────────────────────────────

    /// @notice Set the credential registry address
    function setCredentialRegistry(address _registry) external onlyOwner {
        credentialRegistry = _registry;
    }

    /// @notice Update Chainlink Functions configuration
    function updateConfig(
        uint64 _subscriptionId,
        uint32 _callbackGasLimit,
        bytes32 _donId
    ) external onlyOwner {
        subscriptionId = _subscriptionId;
        callbackGasLimit = _callbackGasLimit;
        donId = _donId;
    }

    // ──────────────────────────────────────────────
    //  Verification Request
    // ──────────────────────────────────────────────

    /// @notice Submit an impact claim for oracle verification
    /// @param credentialTokenId Token ID in the credential registry
    /// @param claimedMetric The metric being claimed (e.g., "water_quality_improvement")
    /// @param claimedValue The claimed value (e.g., "30_percent_reduction")
    /// @param dataSourceUrl External API endpoint to query for verification
    /// @param source JavaScript source code for Chainlink Functions to execute
    /// @return requestId The Chainlink Functions request ID
    function requestVerification(
        uint256 credentialTokenId,
        string calldata claimedMetric,
        string calldata claimedValue,
        string calldata dataSourceUrl,
        string calldata source
    ) external onlyOwner returns (bytes32 requestId) {
        // Build the Chainlink Functions request
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source);

        // Pass the claim data as arguments to the Functions script
        string[] memory args = new string[](3);
        args[0] = claimedMetric;
        args[1] = claimedValue;
        args[2] = dataSourceUrl;
        req.setArgs(args);

        // Send the request
        requestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            callbackGasLimit,
            donId
        );

        // Store the request details
        verificationRequests[requestId] = VerificationRequest({
            credentialTokenId: credentialTokenId,
            claimedMetric: claimedMetric,
            claimedValue: claimedValue,
            dataSourceUrl: dataSourceUrl,
            fulfilled: false,
            verified: false,
            verifiedScore: 0,
            rawResponse: ""
        });

        credentialToRequestId[credentialTokenId] = requestId;

        emit VerificationRequested(
            requestId,
            credentialTokenId,
            claimedMetric,
            claimedValue
        );
    }

    // ──────────────────────────────────────────────
    //  Chainlink Functions Callback
    // ──────────────────────────────────────────────

    /// @dev Called by the Chainlink Functions router when the off-chain
    ///      computation completes. Decodes the response and records the
    ///      verification result.
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        VerificationRequest storage vr = verificationRequests[requestId];
        if (vr.credentialTokenId == 0 && bytes(vr.claimedMetric).length == 0) {
            revert UnexpectedRequestId(requestId);
        }

        vr.fulfilled = true;
        vr.rawResponse = response;

        // If no error and response is non-empty, decode verification result
        if (err.length == 0 && response.length > 0) {
            // Response format: abi.encode(bool verified, uint8 score)
            (bool verified, uint8 score) = abi.decode(response, (bool, uint8));
            vr.verified = verified;
            vr.verifiedScore = score;
        }

        emit VerificationFulfilled(
            requestId,
            vr.credentialTokenId,
            vr.verified,
            vr.verifiedScore
        );
    }

    // ──────────────────────────────────────────────
    //  View Functions
    // ──────────────────────────────────────────────

    /// @notice Get the verification status for a credential
    /// @param credentialTokenId Token ID in the credential registry
    /// @return fulfilled Whether the oracle has responded
    /// @return verified Whether the claim was verified
    /// @return score The verified impact score
    function getVerificationStatus(
        uint256 credentialTokenId
    ) external view returns (bool fulfilled, bool verified, uint8 score) {
        bytes32 reqId = credentialToRequestId[credentialTokenId];
        VerificationRequest memory vr = verificationRequests[reqId];
        return (vr.fulfilled, vr.verified, vr.verifiedScore);
    }
}
