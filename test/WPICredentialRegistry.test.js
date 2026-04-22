const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("WPICredentialRegistry", function () {
  let registry, owner, student1, student2, issuer;

  beforeEach(async function () {
    [owner, student1, student2, issuer] = await ethers.getSigners();
    const Registry = await ethers.getContractFactory("WPICredentialRegistry");
    registry = await Registry.deploy();
  });

  // ──────────────────────────────────────────────
  //  Deployment
  // ──────────────────────────────────────────────

  describe("Deployment", function () {
    it("Should set correct name and symbol", async function () {
      expect(await registry.name()).to.equal("WPI Learning Token");
      expect(await registry.symbol()).to.equal("WPILT");
    });

    it("Should set deployer as owner", async function () {
      expect(await registry.owner()).to.equal(owner.address);
    });

    it("Should authorize owner as issuer", async function () {
      expect(await registry.authorizedIssuers(owner.address)).to.be.true;
    });

    it("Should start with zero credentials", async function () {
      expect(await registry.totalIssued()).to.equal(0);
    });
  });

  // ──────────────────────────────────────────────
  //  Issuer Management
  // ──────────────────────────────────────────────

  describe("Issuer Management", function () {
    it("Should authorize a new issuer", async function () {
      await registry.authorizeIssuer(issuer.address);
      expect(await registry.authorizedIssuers(issuer.address)).to.be.true;
    });

    it("Should emit IssuerAuthorized event", async function () {
      await expect(registry.authorizeIssuer(issuer.address))
        .to.emit(registry, "IssuerAuthorized")
        .withArgs(issuer.address);
    });

    it("Should revoke an issuer", async function () {
      await registry.authorizeIssuer(issuer.address);
      await registry.revokeIssuer(issuer.address);
      expect(await registry.authorizedIssuers(issuer.address)).to.be.false;
    });

    it("Should prevent non-owner from authorizing issuers", async function () {
      await expect(
        registry.connect(student1).authorizeIssuer(issuer.address)
      ).to.be.revertedWithCustomError(registry, "OwnableUnauthorizedAccount");
    });
  });

  // ──────────────────────────────────────────────
  //  Credential Issuance
  // ──────────────────────────────────────────────

  describe("Credential Issuance", function () {
    const projectData = {
      title: "Water Filtration System for Namibia IQP",
      ipfsHash: "QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco",
      skills: "IoT,Water-Treatment,Sustainability,Embedded-Systems",
      sdg: "SDG6,SDG9",
      score: 85,
      verified: true,
    };

    it("Should issue a credential with correct metadata", async function () {
      await registry.issueCredential(
        student1.address,
        projectData.title,
        projectData.ipfsHash,
        projectData.skills,
        projectData.sdg,
        projectData.score,
        projectData.verified
      );

      const cred = await registry.getCredential(0);
      expect(cred.projectTitle).to.equal(projectData.title);
      expect(cred.ipfsHash).to.equal(projectData.ipfsHash);
      expect(cred.skillsTags).to.equal(projectData.skills);
      expect(cred.sdgAlignment).to.equal(projectData.sdg);
      expect(cred.impactScore).to.equal(projectData.score);
      expect(cred.oracleVerified).to.equal(projectData.verified);
    });

    it("Should assign token to the student", async function () {
      await registry.issueCredential(
        student1.address,
        projectData.title,
        projectData.ipfsHash,
        projectData.skills,
        projectData.sdg,
        projectData.score,
        projectData.verified
      );

      expect(await registry.ownerOf(0)).to.equal(student1.address);
    });

    it("Should emit CredentialIssued event", async function () {
      await expect(
        registry.issueCredential(
          student1.address,
          projectData.title,
          projectData.ipfsHash,
          projectData.skills,
          projectData.sdg,
          projectData.score,
          projectData.verified
        )
      )
        .to.emit(registry, "CredentialIssued")
        .withArgs(0, student1.address, projectData.title, projectData.score, projectData.verified);
    });

    it("Should increment token IDs sequentially", async function () {
      await registry.issueCredential(
        student1.address, "Project A", "hash1", "s1", "SDG1", 50, false
      );
      await registry.issueCredential(
        student2.address, "Project B", "hash2", "s2", "SDG2", 70, true
      );

      expect(await registry.totalIssued()).to.equal(2);
      expect(await registry.ownerOf(0)).to.equal(student1.address);
      expect(await registry.ownerOf(1)).to.equal(student2.address);
    });

    it("Should allow authorized issuer to mint", async function () {
      await registry.authorizeIssuer(issuer.address);
      await registry.connect(issuer).issueCredential(
        student1.address, "Test", "hash", "skills", "SDG1", 50, false
      );
      expect(await registry.totalIssued()).to.equal(1);
    });

    it("Should reject unauthorized issuer", async function () {
      await expect(
        registry.connect(student1).issueCredential(
          student2.address, "Test", "hash", "skills", "SDG1", 50, false
        )
      ).to.be.revertedWithCustomError(registry, "NotAuthorizedIssuer");
    });

    it("Should reject impact score above 100", async function () {
      await expect(
        registry.issueCredential(
          student1.address, "Test", "hash", "skills", "SDG1", 101, false
        )
      ).to.be.revertedWithCustomError(registry, "InvalidImpactScore");
    });

    it("Should record block timestamp", async function () {
      const tx = await registry.issueCredential(
        student1.address, "Test", "hash", "skills", "SDG1", 50, false
      );
      const receipt = await tx.wait();
      const block = await ethers.provider.getBlock(receipt.blockNumber);
      const cred = await registry.getCredential(0);
      expect(cred.issuedAt).to.equal(block.timestamp);
    });
  });

  // ──────────────────────────────────────────────
  //  Soulbound Enforcement
  // ──────────────────────────────────────────────

  describe("Soulbound (Non-Transferable)", function () {
    beforeEach(async function () {
      await registry.issueCredential(
        student1.address, "Test Project", "hash", "skills", "SDG1", 50, false
      );
    });

    it("Should prevent transferFrom", async function () {
      await expect(
        registry.connect(student1).transferFrom(
          student1.address, student2.address, 0
        )
      ).to.be.revertedWithCustomError(registry, "SoulboundNonTransferable");
    });

    it("Should prevent safeTransferFrom", async function () {
      await expect(
        registry.connect(student1)["safeTransferFrom(address,address,uint256)"](
          student1.address, student2.address, 0
        )
      ).to.be.revertedWithCustomError(registry, "SoulboundNonTransferable");
    });

    it("Should prevent owner-initiated transfer", async function () {
      await expect(
        registry.transferFrom(student1.address, student2.address, 0)
      ).to.be.revertedWithCustomError(registry, "SoulboundNonTransferable");
    });
  });

  // ──────────────────────────────────────────────
  //  Impact Score Updates
  // ──────────────────────────────────────────────

  describe("Impact Score Updates", function () {
    beforeEach(async function () {
      await registry.issueCredential(
        student1.address, "Test", "hash", "skills", "SDG1", 50, false
      );
    });

    it("Should update impact score", async function () {
      await registry.updateImpactScore(0, 85);
      const cred = await registry.getCredential(0);
      expect(cred.impactScore).to.equal(85);
      expect(cred.oracleVerified).to.be.true;
    });

    it("Should emit ImpactScoreUpdated event", async function () {
      await expect(registry.updateImpactScore(0, 85))
        .to.emit(registry, "ImpactScoreUpdated")
        .withArgs(0, 85, true);
    });

    it("Should reject score update from non-issuer", async function () {
      await expect(
        registry.connect(student1).updateImpactScore(0, 85)
      ).to.be.revertedWithCustomError(registry, "NotAuthorizedIssuer");
    });

    it("Should reject score above 100", async function () {
      await expect(
        registry.updateImpactScore(0, 101)
      ).to.be.revertedWithCustomError(registry, "InvalidImpactScore");
    });

    it("Should reject update for non-existent token", async function () {
      await expect(
        registry.updateImpactScore(999, 85)
      ).to.be.revertedWithCustomError(registry, "TokenDoesNotExist");
    });
  });

  // ──────────────────────────────────────────────
  //  View Functions
  // ──────────────────────────────────────────────

  describe("View Functions", function () {
    it("Should revert getCredential for non-existent token", async function () {
      await expect(
        registry.getCredential(0)
      ).to.be.revertedWithCustomError(registry, "TokenDoesNotExist");
    });

    it("Should return oracle verification status", async function () {
      await registry.issueCredential(
        student1.address, "Test", "hash", "skills", "SDG1", 50, false
      );
      expect(await registry.isOracleVerified(0)).to.be.false;

      await registry.updateImpactScore(0, 85);
      expect(await registry.isOracleVerified(0)).to.be.true;
    });
  });
});
