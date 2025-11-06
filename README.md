# Simple Counter - CosmWasm Contract

一个最简单的 CosmWasm 计数器合约，用于演示 moo-1 测试网的合约验证流程。

## 合约功能

- **Instantiate**: 初始化计数器为指定值
- **Execute**:
  - `Increment`: 计数器 +1
  - `Reset`: 重置计数器为指定值
- **Query**:
  - `GetCount`: 查询当前计数器值

## 快速开始（已配置好环境）

✅ 环境已就绪：
- Rust 1.91.0 已安装
- wasm32-unknown-unknown target 已添加
- miniwasm v1.0.2 客户端已安装
- GitHub 仓库: https://github.com/jackmoriso/wasm

### 1. 编译合约

```bash
./build.sh
```

或手动编译：
```bash
source "$HOME/.cargo/env"
cargo build --release --target wasm32-unknown-unknown
```

### 2. 运行测试

```bash
source "$HOME/.cargo/env"
cargo test
```

### 3. 创建或导入密钥

```bash
# 方式 1: 创建新密钥
export DYLD_LIBRARY_PATH=$HOME/.cargo/bin:$DYLD_LIBRARY_PATH
miniwasmd keys add my-key

# 方式 2: 从助记词恢复
miniwasmd keys add my-key --recover
```

**重要**: 保存好助记词！

### 4. 获取测试代币

访问水龙头获取测试代币（需要 moo-1 链的代币）：
- 记录你的地址: `miniwasmd keys show my-key -a`
- 通过 Discord 或其他渠道获取测试币

### 5. 部署合约

```bash
export KEY_NAME=my-key
export DYLD_LIBRARY_PATH=$HOME/.cargo/bin:$DYLD_LIBRARY_PATH
./deploy.sh
```

脚本会自动：
- 上传 WASM 文件到 moo-1 链
- 返回 CODE_ID 和交易哈希
- 提供实例化命令

### 6. 实例化合约

使用 deploy.sh 输出的命令，或手动运行：

```bash
export DYLD_LIBRARY_PATH=$HOME/.cargo/bin:$DYLD_LIBRARY_PATH
miniwasmd tx wasm instantiate <CODE_ID> '{"count": 0}' \
  --from my-key \
  --label "simple-counter" \
  --chain-id moo-1 \
  --node https://rpc-moo-1.anvil.asia-southeast.initia.xyz:443 \
  --gas auto \
  --gas-adjustment 1.3 \
  --gas-prices 0.015ibc/37A3FB4FED4CA04ED6D9E5DA36C6D27248645F0E22F585576A1488B8A89C5A50 \
  --yes
```

## 手动部署步骤（不使用脚本）

### 1. 上传合约

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

### 2. 查询 CODE_ID

```bash
# 从上一步交易输出中获取，或查询最新的 code
miniwasmd query wasm list-code \
  --node https://rpc-moo-1.anvil.asia-southeast.initia.xyz:443 \
  --output json | jq '.code_infos[-1].code_id'
```

## 验证合约源码

部署合约后，在 https://scan.initia.xyz/moo-1 找到你的合约，点击 "Verify & publish source code"。

### 验证信息（已就绪）

填写以下信息：

1. **GitHub repository URL**:
   ```
   https://github.com/jackmoriso/wasm
   ```

2. **Commit hash**:
   ```
   ee837a238bf3d99f13607ad13bf0fab3d9bc1aaf
   ```

3. **Package name**:
   ```
   simple-counter
   ```
   （必须与 Cargo.toml 中的 name 字段一致）

4. **Compiler version**:
   ```
   rustc 1.91.0
   ```
   或运行 `source "$HOME/.cargo/env" && rustc --version` 查看

### 如何找到你的合约

1. 部署后记录 CODE_ID 或合约地址
2. 访问 https://scan.initia.xyz/moo-1/contracts
3. 搜索你的合约地址或 CODE_ID
4. 点击 "Verify & publish source code" 按钮

## 验证后的好处

验证后，用户可以：
- 在区块浏览器中直接查看合约源码
- 确认链上合约与 GitHub 源码一致
- 通过 Scan 的 schema 系统执行合约

## 项目结构

```
moo-1/
├── Cargo.toml              # Rust 项目配置
├── src/
│   └── lib.rs             # 合约源码
├── build.sh               # 编译脚本
├── deploy.sh              # 部署脚本
├── .gitignore             # Git 忽略文件
└── README.md              # 本文档
```

## moo-1 链信息

- **Chain ID**: moo-1
- **RPC**: https://rpc-moo-1.anvil.asia-southeast.initia.xyz:443
- **REST**: https://rest-moo-1.anvil.asia-southeast.initia.xyz
- **浏览器**: https://scan.initia.xyz/moo-1
- **Gas Price**: 0.015ibc/37A3FB4FED4CA04ED6D9E5DA36C6D27248645F0E22F585576A1488B8A89C5A50

## 常见问题

### Q: 如何查看合约状态？

```bash
export DYLD_LIBRARY_PATH=$HOME/.cargo/bin:$DYLD_LIBRARY_PATH
# 查询合约
miniwasmd query wasm contract-state smart <CONTRACT_ADDRESS> \
  '{"get_count":{}}' \
  --node https://rpc-moo-1.anvil.asia-southeast.initia.xyz:443
```

### Q: 如何执行合约？

```bash
export DYLD_LIBRARY_PATH=$HOME/.cargo/bin:$DYLD_LIBRARY_PATH
# 增加计数
miniwasmd tx wasm execute <CONTRACT_ADDRESS> \
  '{"increment":{}}' \
  --from my-key \
  --chain-id moo-1 \
  --node https://rpc-moo-1.anvil.asia-southeast.initia.xyz:443 \
  --gas auto \
  --gas-adjustment 1.3 \
  --gas-prices 0.015ibc/37A3FB4FED4CA04ED6D9E5DA36C6D27248645F0E22F585576A1488B8A89C5A50 \
  --yes
```

### Q: miniwasmd 命令找不到？

确保设置了环境变量：
```bash
export PATH=$HOME/.cargo/bin:$PATH
export DYLD_LIBRARY_PATH=$HOME/.cargo/bin:$DYLD_LIBRARY_PATH
```

### Q: 如何获取测试代币？

需要通过 moo-1 官方渠道获取测试代币，通常通过：
- Discord 水龙头
- Telegram 机器人
- 官方水龙头网站

## 许可证

MIT
