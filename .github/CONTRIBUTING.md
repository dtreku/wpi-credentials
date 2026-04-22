# Contributing to WPI Credential System

Thank you for your interest in contributing. This project is developed by the WPI FinTech Lab and the WPI Blockchain Club.

## Who Can Contribute

- WPI students (MQP/IQP teams, Blockchain Club members)
- WPI faculty and staff
- External contributors from the Chainlink ecosystem
- Anyone interested in oracle-verified educational credentials

## How to Contribute

### Reporting Issues

1. Check existing issues to avoid duplicates
2. Use the issue templates provided
3. Include clear reproduction steps for bugs
4. For feature requests, describe the use case

### Submitting Code

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Write tests for any new functionality
4. Ensure all tests pass (`npx hardhat test`)
5. Run the linter (`npm run lint`)
6. Submit a pull request with a clear description

### Code Standards

- Solidity: Follow the [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- JavaScript: Use ES6+ syntax; format with Prettier
- Tests: Maintain >90% line coverage; test both success and failure cases
- Documentation: Update relevant docs for any contract changes

### Smart Contract Changes

All smart contract modifications require:

1. Updated test coverage
2. Slither static analysis (`pip install slither-analyzer && slither .`)
3. Documentation of any new public/external functions
4. Gas optimization considerations noted in the PR

### Commit Messages

Use conventional commits:
- `feat: add new credential metadata field`
- `fix: correct soulbound transfer check`
- `test: add edge case for impact score validation`
- `docs: update deployment guide for Sepolia`

## Development Setup

```bash
git clone https://github.com/[your-fork]/wpi-credentials.git
cd wpi-credentials
npm install
cp .env.example .env
# Fill in .env with your keys
npx hardhat compile
npx hardhat test
```

## Contact

- Faculty Lead: Daniel [Last Name] — [email]
- Blockchain Club: wpi-blockchain-club@wpi.edu
- Issues: Use GitHub Issues

## Code of Conduct

Be respectful, constructive, and inclusive. This is an academic project — we value learning and collaboration over ego.
