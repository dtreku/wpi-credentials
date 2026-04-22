# Impact Assessment Framework

## Purpose

This framework provides a structured methodology for evaluating the real-world impact of WPI student projects. It operates alongside the existing academic grading system — it does not replace it. The framework produces the impact score recorded in the Net Impact Credential.

## Five Dimensions

### 1. Stakeholder Reach (20%)
Who was directly affected by the project?

- Quantify the population served or engaged
- Identify organizations, communities, or systems affected
- Document geographic scope
- Distinguish between direct and indirect beneficiaries

### 2. Outcome Evidence (30%)
What measurable change did the project produce?

- Pre/post measurement data where available
- Attribution: can the change be reasonably attributed to the project?
- Efficiency gains, cost reductions, behavioral changes, adoption rates
- Distinguish between outputs (what was built) and outcomes (what changed)

### 3. SDG Alignment (15%)
How does the project connect to global development goals?

- Map outcomes to specific SDG targets (not just goals)
- Provide narrative justification for the mapping
- Reference SDG indicator framework where applicable
- UN SDG reference: https://sdgs.un.org/goals

### 4. Sustainability (20%)
Will the project's effects persist beyond the project period?

- Handoff plan to partner organization
- Ongoing funding or institutional adoption
- Open-source release for continued development
- Training provided to local stakeholders

### 5. Unintended Effects (15%)
What negative externalities or trade-offs exist?

- Environmental costs
- Displacement effects
- Equity considerations
- Honest acknowledgment of limitations

## Scoring Rubric

Each dimension is scored on a 4-point scale:

| Score | Level | Description |
|-------|-------|-------------|
| 4 | Exemplary | Clear evidence with quantification; rigorous methodology |
| 3 | Proficient | Reasonable evidence; some quantification |
| 2 | Developing | Qualitative description; limited measurement |
| 1 | Insufficient | No meaningful evidence presented |

## Overall Impact Score Calculation

```
Overall Score = (Stakeholder × 0.20 + Outcome × 0.30 + SDG × 0.15 + 
                Sustainability × 0.20 + Unintended × 0.15) × 25
```

This produces a score on the 0–100 scale stored in the credential.

| Score Range | Credential Designation |
|-------------|----------------------|
| 80–100 | Verified High Impact |
| 60–79 | Verified Impact |
| 0–59 | Impact Assessment Completed |

## Oracle Verification

Where feasible, impact claims are cross-checked using Chainlink Functions:

1. Project team identifies a verifiable claim and an external data source
2. Faculty advisor reviews the claim and data source for appropriateness
3. Chainlink Functions executes a query against the external API
4. Oracle returns a verification result (confirmed / not confirmed / inconclusive)
5. Verification status is recorded on-chain in the credential

Not all impact claims are oracle-verifiable. The system is designed to accommodate a spectrum from fully oracle-verified to advisor-verified only, with appropriate confidence flags.

## Supported External Data Sources

| Source | API | Relevant Domains |
|--------|-----|-----------------|
| World Bank Open Data | api.worldbank.org | Development indicators, poverty, education |
| EPA Environmental Data | edg.epa.gov | Air quality, water quality, emissions |
| WHO Global Health Observatory | gho.who.int | Health indicators |
| UN SDG Global Database | unstats.un.org | SDG indicator data |
| Partner-organization APIs | Varies | Project-specific metrics |
