# ✅ 上传新的 WASM 文件

## 问题解决

之前的错误：
```
Error during static Wasm validation: reference-types not enabled
```

**原因**: CosmWasm 2.x 生成的 WASM 使用了 moo-1 链不支持的新特性

**解决方案**: 降级到 CosmWasm 1.5，生成兼容的 WASM 文件

## 新的 WASM 文件

位置: `target/wasm32-unknown-unknown/release/simple_counter.wasm`
大小: **152KB** (之前是 228KB)
版本: CosmWasm 1.5.11

## 上传步骤

### 方式 1: 使用 deploy.sh 脚本（推荐）

```bash
export KEY_NAME=my-key
export DYLD_LIBRARY_PATH=$HOME/.cargo/bin:$DYLD_LIBRARY_PATH
./deploy.sh
```

### 方式 2: 手动上传

```bash
export DYLD_LIBRARY_PATH=$HOME/.cargo/bin:$DYLD_LIBRARY_PATH

miniwasmd tx wasm store target/wasm32-unknown-unknown/release/simple_counter.wasm \
  --from my-key \
  --chain-id moo-1 \
  --node https://rpc-moo-1.anvil.asia-southeast.initia.xyz:443 \
  --gas auto \
  --gas-adjustment 1.3 \
  --gas-prices 0.015ibc/37A3FB4FED4CA04ED6D9E5DA36C6D27248645F0E22F585576A1488B8A89C5A50 \
  --yes
```

### 方式 3: 通过 Scan UI 上传（如果支持）

1. 访问 https://scan.initia.xyz/moo-1
2. 找到上传合约的界面
3. 选择文件: `target/wasm32-unknown-unknown/release/simple_counter.wasm`
4. 提交交易

## 验证信息（已更新）

部署成功后，使用以下信息验证合约：

| 字段 | 值 |
|------|-----|
| **GitHub URL** | `https://github.com/jackmoriso/wasm` |
| **Commit hash** | `5263dd45c387ffe80a0b6dcb06a820687722e3a8` |
| **Package name** | `simple-counter` |
| **Compiler version** | `rustc 1.91.0` |

⚠️ **重要**: 使用新的 commit hash！旧的 commit 无法验证通过。

## 重新编译（如果需要）

如果你想自己重新编译：

```bash
cd /Users/jack/moo-1
source "$HOME/.cargo/env"
./build.sh
```

或手动：
```bash
source "$HOME/.cargo/env"
cargo clean
RUSTFLAGS='-C link-arg=-s' cargo build --release --target wasm32-unknown-unknown
```

## 变更说明

- ✅ 使用 CosmWasm 1.5.11（兼容性更好）
- ✅ 添加 `.cargo/config.toml` 配置正确的 WASM 标志
- ✅ WASM 文件体积减小 33%
- ✅ 代码已推送到 GitHub
- ✅ 修复了 reference-types 错误

## 测试

可以运行测试确保功能正常：

```bash
source "$HOME/.cargo/env"
cargo test
```

应该看到 3 个测试全部通过：
- ✓ proper_initialization
- ✓ increment
- ✓ reset

## 下一步

1. 使用上述方式之一上传新的 WASM 文件
2. 等待交易确认，记录 CODE_ID
3. 实例化合约
4. 在 Scan 上验证合约（使用新的 commit hash）

如有问题，查看完整文档：
- `README.md` - 完整使用指南
- `VERIFICATION.md` - 验证快速参考
