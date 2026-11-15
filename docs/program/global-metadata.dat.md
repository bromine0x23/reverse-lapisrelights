# global-metadata.dat
从 1.3.0 版本开始，Unity 引擎所需的 global-metadata.dat 元数据以加密形式存在于 APK 文件的 `assets\bin\Data\Managed\Metadata\game.dat` 路径。

加密后的 `game.dat` 文件结构大致如下
```
---------------------------
| 5D FF 27 4C 10 00 00 00 | <- 魔数
---------------------------
| ...                     |
---------------------------
| 14 E8 7F 56 MM MM MM MM | <- 魔数，后接密钥指示密钥长度 M
---------------------------
| xx xx xx xx xx xx xx xx | <- 8字节随机填充
---------------------------
| KK KK KK KK ...         | <- M 长度的密钥 K
---------------------------
| 88 F0 FA BC LL LL LL LL | <- 魔数，后接 global-metadata.dat 密文长度 L
---------------------------
| xx xx xx xx xx xx xx xx | <- 8字节随机填充
---------------------------
| CC CC CC CC CC CC CC ...| <- L 长度的密文 C
---------------------------
| xx xx xx xx xx xx xx xx | <- 尾部随机填充
---------------------------
```

提取密文后，解密步骤为：
1. RC4 解密
1. 解密元数据字符串池
   1. 从 `global-metadata.dat` 文件头读取元数据字符串池偏移 `stringOffset` 和长度 `stringCount` 参数（位于 `0x18` 和 `0x1C` 偏移处）；
   1. 从元数据字符串池内部偏移 stringIndex=0 开始，逐个解密元数据字符串；
   1. 以当前元数据字符串池内部偏移 `stringIndex % 255` 为 初始密钥 `key`，`pointer` 指示当前字节；
   1. `plaintext[pointer] = ciphertext[pointer] ^ key`, `key = plaintext[pointer++]`；
   1. 直至解密出的明文为 0 即 `NUL`，便完成了对一个元数据字符串的解密，以下一个位置作为下一个元数据字符串的 `stringIndex` 起始位置；
   ```java
   for (int stringIndex = 0; stringIndex < stringCount; ++stringIndex) {
       var pointer = stringOffset + stringIndex;
       var key     = (byte) (stringIndex % 255);
       do {
           key ^= globalMetaDataBytes[pointer];
           globalMetaDataBytes[pointer++] = key;
       } while (key != 0);
       stringIndex = pointer - stringOffset - 1;
   }
   ```
