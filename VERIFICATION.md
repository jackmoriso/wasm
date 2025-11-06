# 合约验证快速参考

## 当前合约信息

已编译的 WASM 文件:
```
target/wasm32-unknown-unknown/release/simple_counter.wasm
```

文件大小: 228KB

## GitHub 仓库

✅ 代码已推送到: https://github.com/jackmoriso/wasm

## 验证所需信息

部署合约后，在 https://scan.initia.xyz/moo-1 的合约页面点击 "Verify & publish source code"，填写：

### 1. GitHub repository URL
```
https://github.com/jackmoriso/wasm
```

### 2. Commit hash
```
ee837a238bf3d99f13607ad13bf0fab3d9bc1aaf
```

验证命令（确认当前 commit）:
```bash
git rev-parse HEAD
```

### 3. Package name
```
simple-counter
```

验证命令（确认包名）:
```bash
grep "^name" Cargo.toml
```

### 4. Compiler version
```
rustc 1.91.0 (f8297e351 2025-10-28)
```

验证命令（确认编译器版本）:
```bash
source "$HOME/.cargo/env" && rustc --version
```

## 部署流程概览

```
1. 创建/导入密钥
   └─> miniwasmd keys add my-key

2. 获取测试代币
   └─> 记录地址并从水龙头获取

3. 上传合约
   └─> ./deploy.sh (需要设置 KEY_NAME)
   └─> 记录返回的 CODE_ID

4. 实例化合约
   └─> miniwasmd tx wasm instantiate <CODE_ID> ...
   └─> 记录返回的 CONTRACT_ADDRESS

5. 验证合约
   └─> 访问 scan.initia.xyz
   └─> 填写本文档中的验证信息
   └─> 等待验证完成（可能需要几小时）
```

## 环境变量快速设置

在每次使用 miniwasmd 前运行：

```bash
export PATH=$HOME/.cargo/bin:$PATH
export DYLD_LIBRARY_PATH=$HOME/.cargo/bin:$DYLD_LIBRARY_PATH
```

或添加到你的 shell 配置文件（~/.zshrc 或 ~/.bash_profile）:

```bash
# 添加这两行到文件末尾
export PATH="$HOME/.cargo/bin:$PATH"
export DYLD_LIBRARY_PATH="$HOME/.cargo/bin:$DYLD_LIBRARY_PATH"
```

然后重新加载:
```bash
source ~/.zshrc  # 或 source ~/.bash_profile
```

## 验证前检查清单

- [ ] 合约已成功上传到 moo-1 链
- [ ] 已记录 CODE_ID 或 CONTRACT_ADDRESS
- [ ] GitHub 仓库是公开的（不是 private）
- [ ] 确认 commit hash 正确
- [ ] 确认包名与 Cargo.toml 一致
- [ ] 确认编译器版本正确

## 常见验证失败原因

1. **Commit hash 错误**: 必须是上传到 GitHub 的那个 commit
2. **Package name 不匹配**: 必须与 Cargo.toml 中的 name 完全一致
3. **编译器版本不匹配**: 需要与编译时使用的版本一致
4. **GitHub 仓库是私有的**: 验证系统无法访问私有仓库
5. **代码已修改但未推送**: 确保 GitHub 上的代码是最新的

## 链接

- **GitHub 仓库**: https://github.com/jackmoriso/wasm
- **区块浏览器**: https://scan.initia.xyz/moo-1
- **RPC 节点**: https://rpc-moo-1.anvil.asia-southeast.initia.xyz:443
