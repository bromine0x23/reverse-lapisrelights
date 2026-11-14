# Lua 脚本

游戏使用 [tolua] 框架加载和运行 [LuaJIT] 脚本。

## 来源
Unity AssetBundle 资源中，`assets/products/resources/luajit64` 和 `assets/products/resources/luajit32` 路径下为 Lua 脚本资源。

## 解密
游戏中的 Lua 脚本资源由三部分组成：
1. 20字节二进制格式的 SHA1 签名，由第二部分计算得出；
1. 主体，脚本字节码；
1. 32字节HEX格式 MD5 签名，生成方式不明。

游戏对原始 LuaJIT 字节码进行了以下修改：
* 加密：`plaintext[i] = (byte) (((0xabcdef >> ((i % 0x607) % 5)) & 0xFF) ^ ciphertext[i])`
* 指令变更：`MOV`、`NOT`、`UNM`、`LEN` 编号移至 `ISEQV` 前，即 `MOV=4 NOT=5 UNM=6 LEN=7 ISEQV=8 ...`
* 格式变更：
  + 修改文件头魔数，`header = ESC 'P' 'O' '0x82' flagsU [namelenU nameB*]`
  + `bcinsW` 和 `uvdataH` 顺序对换，即 `pdata  = phead uvdataH* bcinsW* kgc* knum* [debugB*]`

## 结构

```
lua\
  const\      # 全局常量
  luadata\    # 数据库相关
  network\    # 网络通信相关
  pb\         # 网络通信使用的 ProtoBuf 协议
  ui\         # UI 相关
```

[LuaJIT]: https://luajit.org
[tolua]: https://github.com/topameng/tolua
