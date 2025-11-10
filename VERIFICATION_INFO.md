# Contract Verification Information for moo-1

Use this information to verify and publish the source code on Initia Scan.

## Verification Details

### Code ID
```
15
```

### Code Hash
```
0edb440a240bc5d80dbfabc1153c674d67414cf2b513ba17a9bce530d4d8b274
```

### GitHub Repository URL
```
https://github.com/jackmoriso/wasm
```

### Commit Hash
```
584993d4aaa6ead3f296d6528e859815a49d87bc
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

## How to Verify

1. Go to: https://scan.initia.xyz/moo-1/codes/15
2. Click on "Verify & publish source code"
3. Fill in the form with the information above:
   - **GitHub repository URL**: `https://github.com/jackmoriso/wasm`
   - **Commit hash**: `584993d4aaa6ead3f296d6528e859815a49d87bc`
   - **Package name**: `simple-counter`
   - **Compiler version**: Select `cosmwasm/optimizer:0.17.0` from dropdown or input it
4. Click "Verify & publish"

## Verification Process

The Initia Scan will:
1. Clone your GitHub repository at the specified commit
2. Build the contract using the same compiler version
3. Compare the generated WASM hash with the on-chain code hash
4. If they match, mark the contract as verified

This process may take several hours depending on code complexity.

## Build Reproducibility

To verify locally that the build is reproducible:

```bash
# Clone the repo at the specific commit
git clone https://github.com/jackmoriso/wasm
cd wasm
git checkout 584993d4aaa6ead3f296d6528e859815a49d87bc

# Build with the same optimizer
docker run --rm -v "$(pwd)":/code \
  --mount type=volume,source="$(basename "$(pwd)")_cache",target=/target \
  --mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
  cosmwasm/optimizer:0.17.0

# Check the hash
cat artifacts/checksums.txt
```

The checksum should match: `0edb440a240bc5d80dbfabc1153c674d67414cf2b513ba17a9bce530d4d8b274`
