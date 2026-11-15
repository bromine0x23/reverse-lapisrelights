# 资源清单

## 来源
`manifest.xml` 是游戏资源清单文件，从 `/<manifestVersion>/Android/JP/manifest.xml` 路径下下载。
`manifestVersion` 可以使用游戏主界面显示的版本，比如 `202209301251-1-a9c916bdcd`，或者资源清单内部的资源版本，比如 `202209301249-1-298166`。

## 解密
如 [@MalitsPlus: Lapis Re:LiGHTs 资源解析] 中所述，资源清单存在加密，解密步骤为：
1. 使用 `AES/CBC/PKCS5Padding` 解密，
   密钥 `9ec473ae662f4e2a592a502b903c9ec473ae662f4e2a8d857ea7592750bb903c` (HEX)，
   初始化向量 `f184dfb4912bce95dbdb7d975397723f` (HEX)。
1. GZIP 解压缩
1. C# BinaryFormatter 反序列化

~~在不知道原始类结构的情况下，无法在 C# 中通过 BinaryFormatter 进行反序列化。~~
使用 [gurnec/Undo_FFG: nrbf.py] 的 Python 脚本，可以直接将序列化数据导出为 JSON，绕过了对原始类结构的需要。

.NET 9 新引入的 `NrbfDecoder` 可以直接解码 NRBF 内容，见 [Read BinaryFormatter (NRBF) payloads]。

[@MalitsPlus: Lapis Re:LiGHTs 资源解析]: https://malitsplus.blogspot.com/2022/01/lapis-relights.html
[gurnec/Undo_FFG: nrbf.py]: https://github.com/gurnec/Undo_FFG/blob/master/nrbf.py
[Read BinaryFormatter (NRBF) payloads]: https://github.com/dotnet/docs/blob/main/docs/standard/serialization/binaryformatter-migration-guide/read-nrbf-payloads.md