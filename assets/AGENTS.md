# AGENTS.md - assets

## 项目结构

```
assets/
  bin/                                # 辅助脚本
  lua/                                # 从 AssetBundles 资源中提取的 Lua 脚本资源
    luajit64/                         # 游戏资源中的原始 Lua 资源
    luajit64-decrypted/               # 经过解密的 Lua 字节码
    luajit64-decompile/               # 使用（经过修改的） luajit-decompiler-v2 反编译的 Lua 脚本
  manifest/                           # 各版本原始游戏资源清单
  MasterData/                         # 游戏数据库
```
