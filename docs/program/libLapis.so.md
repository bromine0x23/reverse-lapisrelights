# libLapis.so

## 概览

| 项     | 值                                                                   |
|--------|----------------------------------------------------------------------|
| 作用   | 向托管代码提供 AssetBundle 流解密函数 `_Lapis_Decrypt`               |
| 架构   | `arm64-v8a`、`armeabi-v7a`                                           |
| 编译器 | `Obfuscator-LLVM clang 4.0.1`（`.comment`），NDK `r16b`，`minSdk 21` |
| 依赖   | `liblog.so` `libstdc++.so` `libc.so` `libm.so` `libdl.so`            |
| 导出   | 5 个函数（另有 7 个链接器绝对符号），无 `Java_*` / `JNI_OnLoad`      |

代码特征：控制流平坦化（状态机 + 无意义常量比较）、字符串拆分复用（如 `"The second mem privilege change failed"+0xB` →
`"mem privilege change failed"`）。下文地址与参数样例取自 1.5.0（地址为 arm64 版 RVA）。

## 导出符号

| 地址     | 符号                  | 签名                                                                              | 说明                                                   |
|----------|-----------------------|-----------------------------------------------------------------------------------|--------------------------------------------------------|
| `0x11D0` | `_Lapis_Decrypt`      | `void _Lapis_Decrypt(uint8_t *array, int key, int start, int size, int startIdx)` | AssetBundle 流解密，托管代码 P/Invoke 调用（见下）     |
| `0xA50`  | `_Z12kcDecodeFuncPKc` | `void kcDecodeFunc(const char *libName)`                                          | 解密自身被加密的代码段                                 |
| `0x1010` | `_Z12kcgetLibAddrPKc` | `uintptr_t kcgetLibAddr(const char *libName)`                                     | 从 `/proc/<pid>/maps` 取库基址                         |
| `0xA1C`  | `_Z9init_funcv`       | `void init_func(void)`                                                            | 构造函数：打日志后尾调用 `kcDecodeFunc("libLapis.so")` |
| `0xA4C`  | `_Z7my_initv`         | `void my_init(void)`                                                              | 空函数（`RET`）                                        |
| `0x9E0`  | `sub_9E0`（内部）     | `void fini(void)`                                                                 | `.fini_array[0]`：`__cxa_finalize(&__dso_handle)`      |

`kcDecodeFunc` / `kcgetLibAddr` 以 C++ 修饰名导出，供外部按名解析。

## 加壳参数

加壳/解密机制见 [README.md](README.md)，本库的描述符参数（各版本相同）如下：

| 架构  | `e_entry` | 被解密段          | offset   | length  | key          | `key % 9` |
|-------|-----------|-------------------|----------|---------|--------------|-----------|
| arm64 | `0x13010` | `.kclapisniceway` | `0x11D0` | `0x120` | `0x3F23138C` | 2         |
| armv7 | `0x6010`  | `.kclapisniceway` | `0x3170` | `0x124` | `0x73ECB360` | 5         |

* 被解密的段恰好就是 `_Lapis_Decrypt` 一个函数（段长度 = `length`）。
* 描述符 `{offset, length, key}` 位于文件尾部随机命名段 `.8259b86f1d`（`0x13010`，其余为填充），
  `e_entry` 指向它而不是代码，反汇编器会误认成 `start` 函数。

## `_Lapis_Decrypt`：AssetBundle 流解密

托管侧声明（`Il2CppDumper` 输出 `dump.cs`）：

```csharp
public class AssetBundleStream.LapisExtern {
    // RVA: 0x2E6819C（1.5.0）
    public static extern void _Lapis_Decrypt(byte[] array, int key, int start, int size, int startIdx);
}
```

该 `extern` 方法由 IL2CPP 的 P/Invoke 机制实现：`libil2cpp.so` 的包装函数（`0x2E6819C`）首次调用时把模块名 `"Lapis"`、入口名
`"_Lapis_Decrypt"`（`0x304AA28` / `0x304AA2E`）交给 P/Invoke 解析函数（`0x10B6C18`）取得地址并缓存，之后转发 `byte[]`
数据区指针（对象 +0x20）。这也解释了为什么没有任何库以 `DT_NEEDED` 依赖 `libLapis.so`——它由 P/Invoke 按需加载。

原生实现（`0x11D0`，还原后）：

```c
void _Lapis_Decrypt(uint8_t *array, int key, int start, int size, int startIdx) {
    int step   = abs(key % 10) + 1;                 // 字节步长
    int modulo = abs((key / 10) % 10) + 1;          // 移位取模
    for (int i = start, c = startIdx; i < size; ++c, i += step) {
        int x = c * 1103515245 + 12345;
        if (x < 0) x = c * 1103515245 + 77880;
        int k = ((x >> 16) & 0x7FFF) % modulo;
        array[i] ^= (uint8_t)(key >> k);
    }
}
```

* `size` 实际是**结束索引**（循环条件 `i < size`），不是字节数。
* 只有 `step` 的整数倍位置被异或，`step` 与移位范围均由 `key` 的十进制位决定。
* 即 [Unity-AssetBundle.md](../assets/Unity-AssetBundle.md) 中的 `assetBundleDecrypt`，本库为其原生实现。

### 调用方与对齐参数

`AssetBundleStream.Read(byte[] array, int offset, int count)`（RVA `0x2E68010`）：

```c
int Read(byte[] array, int offset, int count) {
    int step   = abs(m_Key % 10) + 1;
    int  pos   = Position;                       // 解密块按全局偏移对齐
    int  start = (pos % step == 0) ? 0 : step - (pos % step);
    int  n     = base.Read(array, offset, count);
    if (n <= 0) return n;
    int  index = pos / step + (pos % step != 0 ? 1 : 0);   // = ceil(pos / step)
    LapisExtern._Lapis_Decrypt(array, m_Key, start, array.Length, index);
    return n;
}
```

因此 `startIdx` 是“缓冲区内第一个待解密字节所属的全局步长块序号”，`start` 是其在缓冲区内的偏移，保证分块读取时解密与文件偏移无关。
