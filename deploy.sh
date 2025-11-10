#!/bin/bash

# Deploy script for moo-1 rollup
# Network: MilkyWay (moo-1)
# RPC: https://rpc-moo-1.anvil.asia-southeast.initia.xyz
# REST: https://rest-moo-1.anvil.asia-southeast.initia.xyz

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

echo -e "${GREEN}=== Deploying to moo-1 rollup ===${NC}"
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

# Store the contract
echo ""
echo -e "${YELLOW}Storing contract...${NC}"
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
    miniwasmd query tx "$TX_HASH" --node "$RPC"
    exit 1
fi

echo -e "${GREEN}Code ID: ${CODE_ID}${NC}"

# Instantiate the contract
echo ""
echo -e "${YELLOW}Instantiating contract with initial count of 0...${NC}"
INIT_MSG='{"count":0}'

TX_HASH=$(miniwasmd tx wasm instantiate "$CODE_ID" "$INIT_MSG" \
    --from deployer \
    --keyring-backend test \
    --chain-id "$CHAIN_ID" \
    --node "$RPC" \
    --label "simple-counter" \
    --gas auto \
    --gas-adjustment 1.5 \
    --gas-prices "0.015${GAS_DENOM}" \
    --broadcast-mode sync \
    --output json \
    --no-admin \
    -y | jq -r '.txhash')

echo -e "${GREEN}Instantiate transaction hash: ${TX_HASH}${NC}"
echo -e "${YELLOW}Waiting for transaction to be included in a block...${NC}"
sleep 6

# Get contract address
CONTRACT_ADDR=$(miniwasmd query tx "$TX_HASH" --node "$RPC" --output json | jq -r '.events[] | select(.type=="instantiate") | .attributes[] | select(.key=="_contract_address") | .value')

if [ -z "$CONTRACT_ADDR" ] || [ "$CONTRACT_ADDR" = "null" ]; then
    echo -e "${RED}Failed to get contract address. Transaction might have failed.${NC}"
    miniwasmd query tx "$TX_HASH" --node "$RPC"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Contract deployed successfully!${NC}"
echo -e "${GREEN}Code ID: ${CODE_ID}${NC}"
echo -e "${GREEN}Contract Address: ${CONTRACT_ADDR}${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Test the contract
echo -e "${YELLOW}Testing contract - querying current count...${NC}"
COUNT=$(miniwasmd query wasm contract-state smart "$CONTRACT_ADDR" '{"get_count":{}}' --node "$RPC" --output json | jq -r '.data.count')
echo -e "${GREEN}Current count: ${COUNT}${NC}"

echo ""
echo -e "${YELLOW}Incrementing counter...${NC}"
TX_HASH=$(miniwasmd tx wasm execute "$CONTRACT_ADDR" '{"increment":{}}' \
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

echo -e "${GREEN}Execute transaction hash: ${TX_HASH}${NC}"
sleep 6

echo -e "${YELLOW}Querying count after increment...${NC}"
COUNT=$(miniwasmd query wasm contract-state smart "$CONTRACT_ADDR" '{"get_count":{}}' --node "$RPC" --output json | jq -r '.data.count')
echo -e "${GREEN}New count: ${COUNT}${NC}"

echo ""
echo -e "${GREEN}Deployment and testing complete!${NC}"
echo -e "${YELLOW}Explorer: https://scan.initia.xyz/moo-1/accounts/${CONTRACT_ADDR}${NC}"
