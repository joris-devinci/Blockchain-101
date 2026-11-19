## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

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

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Run the ERC721 exercises

Set `SEPOLIA_RPC_URL` and `YOUR_ANVIL_PRIVATE_KEY` in your shell. Use a private
key for an account you control that has Sepolia ETH. Check
that the Evaluator and Evaluator2 contracts each hold at least `0.0001` Sepolia
ETH for the purchase and reproduction exercises; the completion script stops
if either balance is too low.

Run this once to deploy a fresh NFT, submit it to both evaluators, and execute
exercises 1–7. `--slow` waits for each transaction to succeed before submitting
the next. The script's balance log is simulated; verify the final on-chain
balance separately after every transaction succeeds.

```shell
$ forge script script/CompleteExercises.s.sol:CompleteExercises \
    --rpc-url "$SEPOLIA_RPC_URL" \
    --private-key "$YOUR_ANVIL_PRIVATE_KEY" \
    --broadcast \
    --slow \
    --gas-estimate-multiplier 200
```

Check the actual balance after the script finishes successfully:

```shell
$ cast call 0x36f7439dB3b9E408B095A9895456A95BA5450D24 \
    "balanceOf(address)(uint256)" \
    "$(cast wallet address --private-key "$YOUR_ANVIL_PRIVATE_KEY")" \
    --rpc-url "$SEPOLIA_RPC_URL"
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
