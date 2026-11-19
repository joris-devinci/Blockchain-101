## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## ERC20-101 Exercise 1

Set `SEPOLIA_RPC_URL` and `PRIVATE_KEY` in your local environment, then run:

```shell
forge script script/ClaimEx1.s.sol:ClaimEx1Script --rpc-url "$SEPOLIA_RPC_URL" --broadcast
```

The script calls `ex1_getTickerAndSupply()` on the Sepolia evaluator and prints
the ticker and initial supply assigned to the account derived from `PRIVATE_KEY`.
It skips the transaction if that account already has an assigned ticker. The
reported supply is in base units (18 decimals).

## Deploy the ERC20 solution

Set `RPC_URL` to the Sepolia RPC endpoint and `PRIVATE_KEY` to the wallet that
claimed the exercise assignment. The script claims a ticker and supply if
needed, deploys the token, and submits it to the evaluator:

```shell
forge script script/MyErc20Script.s.sol:MyErc20Script --rpc-url "$RPC_URL" --broadcast
```

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
