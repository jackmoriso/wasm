# Contract Verification Information for moo-1 (CosmWasm 3.0)

⚠️ **IMPORTANT**: This is a CosmWasm 3.0 contract built with `cosmwasm/optimizer:0.17.0`.
You need to upload this contract to moo-1 first to get a new Code ID before verification.

## Step 1: Upload Contract to moo-1

First, upload the new contract to get a Code ID:

```bash
# Store the contract
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

Note the `code_id` from the transaction result. You can also query it:

```bash
# Get the transaction hash from above, then query:
miniwasmd query tx <TX_HASH> --node https://rpc-moo-1.anvil.asia-southeast.initia.xyz --output json | jq -r '.events[] | select(.type=="store_code") | .attributes[] | select(.key=="code_id") | .value'
```

## Step 2: Verification Details

Once you have the new Code ID, use these details to verify on Initia Scan:

### Code Hash
```
1e6de1aa8d66f7e71c4fd17ffedddee365fbd3f6b77095b984260cf03d2087df
```

### GitHub Repository URL
```
https://github.com/jackmoriso/wasm
```

### Commit Hash
```
575f3356ac4b5f840fe459f6fad927ff558fba4e
```

### Package Name
```
simple-counter
```
(This matches the name in Cargo.toml)

### Compiler Version
```
cosmwasm/optimizer:0.17.0
```

## Step 3: Verify on Initia Scan

1. Go to: `https://scan.initia.xyz/moo-1/codes/<YOUR_NEW_CODE_ID>`
2. Click on "Verify & publish source code"
3. Fill in the form with the information above:
   - **GitHub repository URL**: `https://github.com/jackmoriso/wasm`
   - **Commit hash**: `575f3356ac4b5f840fe459f6fad927ff558fba4e`
   - **Package name**: `simple-counter`
   - **Compiler version**: `cosmwasm/optimizer:0.17.0`
4. Click "Verify & publish"

## Verification Process

The Initia Scan will:
1. Clone your GitHub repository at the specified commit
2. Build the contract using cosmwasm/optimizer:0.17.0
3. Compare the generated WASM hash with the on-chain code hash
4. If they match, mark the contract as verified

This process may take several hours depending on code complexity.

## Contract Details

- **CosmWasm Version**: 3.0
- **Optimizer Version**: 0.17.0
- **Rust Version**: 1.86.0 (used by optimizer)
- **Wasm Size**: ~160KB (optimized)

## Build Reproducibility

To verify locally that the build is reproducible:

```bash
# Clone the repo at the specific commit
git clone https://github.com/jackmoriso/wasm
cd wasm
git checkout 575f3356ac4b5f840fe459f6fad927ff558fba4e

# Build with the same optimizer
docker run --rm -v "$(pwd)":/code \
  --mount type=volume,source="$(basename "$(pwd)")_cache",target=/target \
  --mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
  cosmwasm/optimizer:0.17.0

# Check the hash
cat artifacts/checksums.txt
```

The checksum should match: `1e6de1aa8d66f7e71c4fd17ffedddee365fbd3f6b77095b984260cf03d2087df`

## Notes

- This contract requires CosmWasm 3.0+ support on the chain
- The previous Code ID 15 was built with CosmWasm 1.5 (different version)
- If moo-1 doesn't support CosmWasm 3.0 yet, the upload will fail
