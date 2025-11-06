#!/bin/bash

# 设置环境变量
export PATH=$HOME/.cargo/bin:$PATH
export DYLD_LIBRARY_PATH=$HOME/.cargo/bin:$DYLD_LIBRARY_PATH

# moo-1 链配置
CHAIN_ID="moo-1"
NODE="https://rpc-moo-1.anvil.asia-southeast.initia.xyz:443"
GAS_PRICES="0.015ibc/37A3FB4FED4CA04ED6D9E5DA36C6D27248645F0E22F585576A1488B8A89C5A50"
WASM_FILE="target/wasm32-unknown-unknown/release/simple_counter.wasm"

echo "==================================="
echo "Simple Counter - moo-1 部署脚本"
echo "==================================="
echo ""

# 检查密钥
if [ -z "$KEY_NAME" ]; then
    echo "请设置环境变量 KEY_NAME，例如："
    echo "export KEY_NAME=your-key-name"
    echo ""
    echo "如果还没有创建密钥，请先运行："
    echo "miniwasmd keys add your-key-name"
    echo ""
    exit 1
fi

# 检查 WASM 文件
if [ ! -f "$WASM_FILE" ]; then
    echo "错误: WASM 文件不存在: $WASM_FILE"
    echo "请先运行: ./build.sh"
    exit 1
fi

echo "配置信息："
echo "- Chain ID: $CHAIN_ID"
echo "- Node: $NODE"
echo "- Key: $KEY_NAME"
echo "- WASM file: $WASM_FILE"
echo ""

# 获取账户地址
ACCOUNT=$(miniwasmd keys show $KEY_NAME -a)
echo "账户地址: $ACCOUNT"
echo ""

# 查询余额
echo "查询账户余额..."
miniwasmd query bank balances $ACCOUNT --node $NODE
echo ""

read -p "确认上传合约吗？(y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "取消部署"
    exit 1
fi

# 上传合约
echo ""
echo "正在上传合约到 moo-1..."
TX_HASH=$(miniwasmd tx wasm store $WASM_FILE \
    --from $KEY_NAME \
    --chain-id $CHAIN_ID \
    --node $NODE \
    --gas auto \
    --gas-adjustment 1.3 \
    --gas-prices $GAS_PRICES \
    --output json \
    --yes | jq -r '.txhash')

if [ -z "$TX_HASH" ]; then
    echo "错误: 上传失败"
    exit 1
fi

echo "交易已提交: $TX_HASH"
echo "等待交易确认..."
sleep 6

# 查询 CODE_ID
CODE_ID=$(miniwasmd query tx $TX_HASH --node $NODE --output json | jq -r '.events[] | select(.type=="store_code") | .attributes[] | select(.key=="code_id") | .value')

if [ -z "$CODE_ID" ]; then
    echo "错误: 无法获取 CODE_ID"
    echo "请手动查询交易: miniwasmd query tx $TX_HASH --node $NODE"
    exit 1
fi

echo ""
echo "==================================="
echo "✅ 合约上传成功！"
echo "==================================="
echo "CODE_ID: $CODE_ID"
echo "Transaction: $TX_HASH"
echo ""
echo "查看交易: https://scan.initia.xyz/moo-1/txs/$TX_HASH"
echo ""
echo "下一步，实例化合约："
echo "miniwasmd tx wasm instantiate $CODE_ID '{\"count\": 0}' \\"
echo "  --from $KEY_NAME \\"
echo "  --label \"simple-counter\" \\"
echo "  --chain-id $CHAIN_ID \\"
echo "  --node $NODE \\"
echo "  --gas auto \\"
echo "  --gas-adjustment 1.3 \\"
echo "  --gas-prices $GAS_PRICES \\"
echo "  --yes"
echo ""
echo "验证信息："
echo "- GitHub: https://github.com/jackmoriso/wasm"
echo "- Commit: ee837a238bf3d99f13607ad13bf0fab3d9bc1aaf"
echo "- Package: simple-counter"
echo "- Compiler: $(rustc --version | cut -d' ' -f2)"
