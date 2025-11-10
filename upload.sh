#!/bin/bash

# Upload script for CosmWasm 3.0 contract to moo-1
# This will upload the contract and return the Code ID for verification

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Network configuration
CHAIN_ID="moo-1"
RPC="https://rpc-moo-1.anvil.asia-southeast.initia.xyz"
REST="https://rest-moo-1.anvil.asia-southeast.initia.xyz"
GAS_DENOM="ibc/37A3FB4FED4CA04ED6D9E5DA36C6D27248645F0E22F585576A1488B8A89C5A50"
WASM_FILE="artifacts/simple_counter.wasm"

echo -e "${GREEN}=== Uploading CosmWasm 3.0 Contract to moo-1 ===${NC}"
echo ""

# Check if wallet key exists
if ! miniwasmd keys show deployer --keyring-backend test &>/dev/null; then
    echo -e "${YELLOW}Wallet 'deployer' not found. Creating a new one...${NC}"
    miniwasmd keys add deployer --keyring-backend test
    echo ""
    echo -e "${YELLOW}Please fund this address before continuing!${NC}"
    echo -e "${YELLOW}You can get the address with: miniwasmd keys show deployer --keyring-backend test${NC}"
    exit 1
fi

# Get deployer address
DEPLOYER=$(miniwasmd keys show deployer --keyring-backend test -a)
echo -e "${GREEN}Deployer address: ${DEPLOYER}${NC}"

# Check balance
echo -e "${YELLOW}Checking balance...${NC}"
BALANCE=$(curl -s "${REST}/cosmos/bank/v1beta1/balances/${DEPLOYER}" | jq -r '.balances[0].amount // "0"')
echo -e "${GREEN}Balance: ${BALANCE}${NC}"

if [ "$BALANCE" = "0" ]; then
    echo -e "${RED}No balance found. Please fund your account first!${NC}"
    exit 1
fi

# Verify checksum
echo ""
echo -e "${YELLOW}Verifying WASM checksum...${NC}"
EXPECTED_CHECKSUM="1e6de1aa8d66f7e71c4fd17ffedddee365fbd3f6b77095b984260cf03d2087df"
ACTUAL_CHECKSUM=$(cat artifacts/checksums.txt | awk '{print $1}')

if [ "$ACTUAL_CHECKSUM" != "$EXPECTED_CHECKSUM" ]; then
    echo -e "${RED}ERROR: Checksum mismatch!${NC}"
    echo -e "${RED}Expected: ${EXPECTED_CHECKSUM}${NC}"
    echo -e "${RED}Actual:   ${ACTUAL_CHECKSUM}${NC}"
    echo -e "${RED}Please rebuild the contract with: docker run --rm -v \"\$(pwd)\":/code --mount type=volume,source=\"\$(basename \"\$(pwd)\")_cache\",target=/target --mount type=volume,source=registry_cache,target=/usr/local/cargo/registry cosmwasm/optimizer:0.17.0${NC}"
    exit 1
fi

echo -e "${GREEN}Checksum verified: ${ACTUAL_CHECKSUM}${NC}"

# Store the contract
echo ""
echo -e "${YELLOW}Storing contract on moo-1...${NC}"
echo -e "${YELLOW}This may take a moment...${NC}"

TX_HASH=$(miniwasmd tx wasm store "$WASM_FILE" \
    --from deployer \
    --keyring-backend test \
    --chain-id "$CHAIN_ID" \
    --node "$RPC" \
    --gas auto \
    --gas-adjustment 1.5 \
    --gas-prices "0.015${GAS_DENOM}" \
    --broadcast-mode sync \
    --output json \
    -y | jq -r '.txhash')

echo -e "${GREEN}Transaction hash: ${TX_HASH}${NC}"
echo -e "${YELLOW}Waiting for transaction to be included in a block...${NC}"
sleep 6

# Get code ID
CODE_ID=$(miniwasmd query tx "$TX_HASH" --node "$RPC" --output json | jq -r '.events[] | select(.type=="store_code") | .attributes[] | select(.key=="code_id") | .value')

if [ -z "$CODE_ID" ] || [ "$CODE_ID" = "null" ]; then
    echo -e "${RED}Failed to get code ID. Transaction might have failed.${NC}"
    echo -e "${YELLOW}Checking transaction details...${NC}"
    miniwasmd query tx "$TX_HASH" --node "$RPC"
    echo ""
    echo -e "${RED}If you see an error about CosmWasm version, moo-1 may not support CosmWasm 3.0 yet.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Contract uploaded successfully!${NC}"
echo -e "${GREEN}Code ID: ${CODE_ID}${NC}"
echo -e "${GREEN}Code Hash: ${ACTUAL_CHECKSUM}${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Display verification info
echo -e "${YELLOW}=== Verification Information ===${NC}"
echo ""
echo -e "To verify this contract on Initia Scan:"
echo -e "1. Go to: ${GREEN}https://scan.initia.xyz/moo-1/codes/${CODE_ID}${NC}"
echo -e "2. Click 'Verify & publish source code'"
echo -e "3. Fill in the form:"
echo ""
echo -e "   ${YELLOW}GitHub repository URL:${NC} https://github.com/jackmoriso/wasm"
echo -e "   ${YELLOW}Commit hash:${NC} 575f3356ac4b5f840fe459f6fad927ff558fba4e"
echo -e "   ${YELLOW}Package name:${NC} simple-counter"
echo -e "   ${YELLOW}Compiler version:${NC} cosmwasm/optimizer:0.17.0"
echo ""
echo -e "4. Click 'Verify & publish'"
echo ""
echo -e "${GREEN}Done!${NC}"
