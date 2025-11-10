# Simple Counter Contract for moo-1 Rollup

A minimal CosmWasm smart contract deployed on the MilkyWay (moo-1) rollup.

## Contract Overview

This is a simple counter contract with the following functionality:
- **Instantiate**: Initialize the counter with a starting value
- **Increment**: Increase the counter by 1
- **Reset**: Set the counter to a specific value
- **Query**: Get the current counter value

## Build

The contract was built using `cosmwasm/optimizer:0.17.0`:

```bash
docker run --rm -v "$(pwd)":/code \
  --mount type=volume,source="$(basename "$(pwd)")_cache",target=/target \
  --mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
  cosmwasm/optimizer:0.17.0
```

The optimized WASM file is located at: `artifacts/simple_counter.wasm`

## Network Information

- **Chain ID**: moo-1
- **Network**: MilkyWay (Mainnet)
- **RPC**: https://rpc-moo-1.anvil.asia-southeast.initia.xyz
- **REST**: https://rest-moo-1.anvil.asia-southeast.initia.xyz
- **Explorer**: https://scan.initia.xyz/moo-1
- **Gas Denom**: `ibc/37A3FB4FED4CA04ED6D9E5DA36C6D27248645F0E22F585576A1488B8A89C5A50`
- **Min Gas Price**: 0.015

## Prerequisites

1. Install `miniwasmd` CLI (v1.0.2 recommended)
2. Install `jq` for JSON processing: `brew install jq` (macOS)

## Deployment

### Option 1: Using the deployment script

The easiest way to deploy is using the provided script:

```bash
./deploy.sh
```

This script will:
1. Create a wallet if needed (or use existing 'deployer' wallet)
2. Store the contract on-chain
3. Instantiate the contract with count=0
4. Test the contract by incrementing and querying

### Option 2: Manual deployment

#### 1. Create/Import a wallet

```bash
# Create a new wallet
miniwasmd keys add deployer --keyring-backend test

# Or import an existing one
miniwasmd keys add deployer --recover --keyring-backend test
```

#### 2. Fund your wallet

Get your address:
```bash
miniwasmd keys show deployer --keyring-backend test -a
```

Fund it through a faucet or transfer tokens to this address.

#### 3. Store the contract

```bash
miniwasmd tx wasm store artifacts/simple_counter.wasm \
  --from deployer \
  --keyring-backend test \
  --chain-id moo-1 \
  --node https://rpc-moo-1.anvil.asia-southeast.initia.xyz \
  --gas auto \
  --gas-adjustment 1.5 \
  --gas-prices "0.015ibc/37A3FB4FED4CA04ED6D9E5DA36C6D27248645F0E22F585576A1488B8A89C5A50" \
  -y
```

Note the `code_id` from the transaction result.

#### 4. Instantiate the contract

```bash
miniwasmd tx wasm instantiate <CODE_ID> '{"count":0}' \
  --from deployer \
  --keyring-backend test \
  --chain-id moo-1 \
  --node https://rpc-moo-1.anvil.asia-southeast.initia.xyz \
  --label "simple-counter" \
  --gas auto \
  --gas-adjustment 1.5 \
  --gas-prices "0.015ibc/37A3FB4FED4CA04ED6D9E5DA36C6D27248645F0E22F585576A1488B8A89C5A50" \
  --no-admin \
  -y
```

Note the `contract_address` from the transaction result.

## Interacting with the Contract

### Query the current count

```bash
miniwasmd query wasm contract-state smart <CONTRACT_ADDRESS> '{"get_count":{}}' \
  --node https://rpc-moo-1.anvil.asia-southeast.initia.xyz
```

### Increment the counter

```bash
miniwasmd tx wasm execute <CONTRACT_ADDRESS> '{"increment":{}}' \
  --from deployer \
  --keyring-backend test \
  --chain-id moo-1 \
  --node https://rpc-moo-1.anvil.asia-southeast.initia.xyz \
  --gas auto \
  --gas-adjustment 1.5 \
  --gas-prices "0.015ibc/37A3FB4FED4CA04ED6D9E5DA36C6D27248645F0E22F585576A1488B8A89C5A50" \
  -y
```

### Reset the counter

```bash
miniwasmd tx wasm execute <CONTRACT_ADDRESS> '{"reset":{"count":10}}' \
  --from deployer \
  --keyring-backend test \
  --chain-id moo-1 \
  --node https://rpc-moo-1.anvil.asia-southeast.initia.xyz \
  --gas auto \
  --gas-adjustment 1.5 \
  --gas-prices "0.015ibc/37A3FB4FED4CA04ED6D9E5DA36C6D27248645F0E22F585576A1488B8A89C5A50" \
  -y
```

## Contract Structure

```
src/lib.rs
├── InstantiateMsg - Initialize with a count
├── ExecuteMsg
│   ├── Increment - Increment by 1
│   └── Reset - Set to specific value
└── QueryMsg
    └── GetCount - Get current count
```

## Dependencies

- cosmwasm-std: 1.5.0
- cosmwasm-schema: 1.5.0
- serde: 1.0

## License

This is a simple example contract for educational purposes.
