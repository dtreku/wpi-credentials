const hre = require("hardhat");

async function main() {
  console.log("Deploying WPI Credential System to", hre.network.name, "...\n");

  // Deploy Credential Registry
  const Registry = await hre.ethers.getContractFactory("WPICredentialRegistry");
  const registry = await Registry.deploy();
  await registry.waitForDeployment();
  const registryAddress = await registry.getAddress();
  console.log("WPICredentialRegistry deployed to:", registryAddress);

  // Log deployment info
  const totalIssued = await registry.totalIssued();
  const name = await registry.name();
  const symbol = await registry.symbol();
  console.log(`  Name: ${name}`);
  console.log(`  Symbol: ${symbol}`);
  console.log(`  Total issued: ${totalIssued}`);
  console.log(`  Owner: ${await registry.owner()}\n`);

  // Verify on Etherscan (if not localhost)
  if (hre.network.name !== "hardhat" && hre.network.name !== "localhost") {
    console.log("Waiting for block confirmations before verification...");
    // Wait for a few blocks for Etherscan to index
    await new Promise((resolve) => setTimeout(resolve, 30000));

    try {
      await hre.run("verify:verify", {
        address: registryAddress,
        constructorArguments: [],
      });
      console.log("Contract verified on Etherscan.");
    } catch (error) {
      console.log("Verification failed (may already be verified):", error.message);
    }
  }

  console.log("\n--- Deployment Summary ---");
  console.log(`Network:              ${hre.network.name}`);
  console.log(`CredentialRegistry:   ${registryAddress}`);
  console.log(`\nNext steps:`);
  console.log(`  1. Verify on Etherscan: npx hardhat verify --network ${hre.network.name} ${registryAddress}`);
  console.log(`  2. Issue a credential:  npx hardhat run scripts/issue-credential.js --network ${hre.network.name}`);
  console.log(`  3. View on Etherscan:   https://sepolia.etherscan.io/address/${registryAddress}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
