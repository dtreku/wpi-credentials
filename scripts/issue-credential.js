const hre = require("hardhat");

/**
 * Example script: Issue a credential to a student wallet.
 *
 * Usage:
 *   npx hardhat run scripts/issue-credential.js --network sepolia
 *
 * Before running:
 *   1. Deploy the contract (scripts/deploy.js)
 *   2. Set REGISTRY_ADDRESS below to your deployed contract address
 *   3. Set STUDENT_ADDRESS to the recipient's wallet address
 */

// ──── Configuration ────
const REGISTRY_ADDRESS = "0x_YOUR_DEPLOYED_CONTRACT_ADDRESS";
const STUDENT_ADDRESS = "0x_STUDENT_WALLET_ADDRESS";

const credential = {
  projectTitle: "Water Filtration System for Namibia — C2027 IQP",
  ipfsHash: "QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco",
  skillsTags: "IoT,Water-Treatment,Sustainability,Embedded-Systems,Project-Management",
  sdgAlignment: "SDG6,SDG9",
  impactScore: 85,
  oracleVerified: false, // Set to true after Chainlink Functions verification
};

async function main() {
  console.log("Issuing WPI Learning Token credential...\n");

  // Connect to deployed contract
  const Registry = await hre.ethers.getContractFactory("WPICredentialRegistry");
  const registry = Registry.attach(REGISTRY_ADDRESS);

  // Issue the credential
  const tx = await registry.issueCredential(
    STUDENT_ADDRESS,
    credential.projectTitle,
    credential.ipfsHash,
    credential.skillsTags,
    credential.sdgAlignment,
    credential.impactScore,
    credential.oracleVerified
  );

  const receipt = await tx.wait();
  console.log("Transaction hash:", receipt.hash);

  // Get the token ID from the event
  const event = receipt.logs.find(
    (log) => log.fragment && log.fragment.name === "CredentialIssued"
  );

  if (event) {
    const tokenId = event.args[0];
    console.log(`\nCredential issued successfully!`);
    console.log(`  Token ID:        ${tokenId}`);
    console.log(`  Student:         ${STUDENT_ADDRESS}`);
    console.log(`  Project:         ${credential.projectTitle}`);
    console.log(`  Impact Score:    ${credential.impactScore}/100`);
    console.log(`  Oracle Verified: ${credential.oracleVerified}`);
    console.log(`  IPFS Report:     https://gateway.pinata.cloud/ipfs/${credential.ipfsHash}`);
    console.log(`\nView on Etherscan: https://sepolia.etherscan.io/tx/${receipt.hash}`);
  }

  // Verify the credential was stored correctly
  const totalIssued = await registry.totalIssued();
  console.log(`\nTotal credentials issued: ${totalIssued}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
