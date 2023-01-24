# POC ERS
Proof Of Concept Ethereum Reality Service, based on https://ethereum-magicians.org/t/a-proposal-for-the-ethereum-reality-service/9694

## Overview

### Installation

```console
forge install && yarn install
```

Setup Husky to format code on commit:

```bash
yarn prepare
```

Link local packages and install remaining dependencies via Lerna:

```bash
yarn run lerna bootstrap
```

Compile contracts via Foundry Hardhat:

```bash
yarn compile
```

Generate a code coverage report using `solidity-coverage`:

```bash
yarn run hardhat coverage
```

### Security Test
First install mythril
```bash
rustup default nightly
pip3 install mythril
myth analyze src/Contract.sol --solc-json mythril.config.json
```

Run mythril
```bash
myth analyze src/Counter.sol --solc-json mythril.config.json
```

### Features

 * Write / run tests with either Hardhat or Foundry:
```bash
forge test
# or
yarn test
```

 * Use Hardhat's task framework
```bash
npx hardhat example
```

### Publication

Publish packages via Lerna:

```bash
yarn lerna-publish
```