#!/bin/bash

# 设置环境
source "$HOME/.cargo/env"

echo "==================================="
echo "编译 Simple Counter 合约"
echo "==================================="
echo ""

# 清理旧的构建
echo "清理旧的构建文件..."
cargo clean

# 编译
echo "开始编译 WASM 合约..."
cargo build --release --target wasm32-unknown-unknown

if [ $? -eq 0 ]; then
    WASM_FILE="target/wasm32-unknown-unknown/release/simple_counter.wasm"
    FILE_SIZE=$(ls -lh $WASM_FILE | awk '{print $5}')

    echo ""
    echo "==================================="
    echo "✅ 编译成功！"
    echo "==================================="
    echo "文件: $WASM_FILE"
    echo "大小: $FILE_SIZE"
    echo ""
    echo "下一步："
    echo "1. 设置密钥: export KEY_NAME=your-key-name"
    echo "2. 运行部署: ./deploy.sh"
else
    echo ""
    echo "❌ 编译失败"
    exit 1
fi
