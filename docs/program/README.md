# 逆向结论：游戏程序

## 二进制库

清单：
```
lib\
  arm64-v8a\           # 用于64位ARM架构
    libil2cpp.so       # 游戏主要代码
    libtolua.so        # 用于处理 LuaJit 脚本
    libklbsqlite3.so   # 用于处理数据库
    libLapis.so        #
    libklabniceway.so  # 被 DEX 脱壳处理使用
  armeabi-v7a\         # 用于32位ARM架构
```

* libil2cpp.so

## 二进制库加密

以下二进制库存在加密，在加载时会自动解密:
- `libtolua.so`
- `libLapis.so`
- `libklabniceway.so`

解密通过 `.init_array` 段的初始化代码进行：
读取 `elf.e_entry` 指向的地址，获取 `address`、`length`、`key` 三个参数。
```
----------------------
|  ...               |
|  0x18 e_entry      |
|  ...               |
|  ...               |
|  address (4B)      | <- e_entry
|  length  (4B)      |
|  key     (4B)      |
|  ...               |
|  ...               |
|  加密段             | <- address
|  ...               |
|  ...               |
----------------------
```

然后对 `address` 开始的 `length` 个字节，每第 `key % 9` 个字节取反（为 0 时全部取反）。

## DEX 加壳
使用了 [guanchao/apk_auto_enforce: jiagu.py] 中的方法隐藏了真实 class.dex。
相关处理使用 `libklabniceway.so` 库。
```
----------------------
|  脱壳用 classes.dex |
----------------------
|  加密源 APK         |
----------------------
|  源 APK 大小        |
----------------------
```

解密算法如下，简单来说就是：逆序+取反+异或密钥：
```java
private static final int[] KEY = {0x5e, 0x2f, 0x97, 0xcb, 0x65, 0xb2};

public byte[] decrypt(byte[] cipher) {
  byte[] plain = new byte[cipher.length];
  for (int i = 0; i < plain.length; ++i) {
      int k = KEY[i % 6];
      int b = cipher[length - i - 1];
      plain[i] = (byte) (k ^ ~b);
  }
  return plain;
}
```

游戏运行时 DEX 脱壳结果写入 `TargetApk.zip`

## global-metadata.dat
[global-metadata.dat.md](global-metadata.dat.md)

[guanchao/apk_auto_enforce: jiagu.py]: https://github.com/guanchao/apk_auto_enforce/blob/master/jiagu.py
