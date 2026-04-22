# FERPA Compliance

## Overview

The Family Educational Rights and Privacy Act (FERPA) protects the privacy of student education records. This document explains how the WPI Credential System is designed to comply with FERPA requirements.

## Key Principle: No PII On-Chain

**No personally identifiable information (PII) is stored on the blockchain.**

The credential token is linked to an Ethereum wallet address — a pseudonymous identifier that does not inherently reveal the student's identity. The following data is **never** recorded on-chain:

- Student name
- WPI ID number
- Social Security number
- Date of birth
- Email address
- Phone number
- Home address
- Grades or GPA

## What Is Stored On-Chain

- Project title
- Skills taxonomy tags
- SDG alignment codes
- Impact score (0-100)
- IPFS content hash (linking to the project report)
- Issuance timestamp
- Oracle verification status

The project title is public information (WPI project reports are already published in Digital Commons). The remaining fields are metadata about the project's characteristics, not about the student's identity.

## Student Consent and Control

- **Opt-in only**: Students voluntarily consent to participate in the credential pilot
- **Student-controlled wallet**: The student owns and controls the wallet that holds the credential
- **Student decides sharing**: Only the student can share or present the credential to employers or others
- **WPI cannot access**: WPI cannot access, modify, or revoke the credential without the student's wallet key

## Consent Process

1. Student receives and reviews the consent form (see Pedagogical Materials, Section 5)
2. Student signs the consent form acknowledging permanence and public nature of blockchain data
3. Faculty advisor co-signs
4. Consent form is retained by WPI per standard records retention policy
5. Credential is issued only after consent is confirmed

## Withdrawal

Students may withdraw from the program at any time **before** the credential is issued. Once a token is minted on the blockchain, it cannot be deleted (this is a fundamental property of blockchain technology). However, the student is not obligated to share or use the credential.

## Legal Review

**This document provides a design-level analysis, not legal advice.** The consent form and credential issuance process must be reviewed and approved by WPI's Office of General Counsel before the pilot begins. The IQP institutional adoption study (Project Brief IQP-1) includes a regulatory compliance workstream that will produce a formal FERPA compliance checklist.
