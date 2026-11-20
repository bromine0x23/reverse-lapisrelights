# libLapis.so

## 概要

| 项     | 值                                                                                   |
|--------|--------------------------------------------------------------------------------------|
| 功能   | 向托管代码提供 AssetBundle 流解密函数 `_Lapis_Decrypt`，并以自解密壳保护该函数        |
| ABI    | `arm64-v8a`、`armeabi-v7a`                                                           |
| 工具链 | `Obfuscator-LLVM clang 4.0.1`（`.comment`），NDK `r16b`，minSdk 21                    |
| 依赖   | `liblog.so`、`libstdc++.so`、`libc.so`、`libm.so`、`libdl.so`                         |
| 使用   | 托管 `AssetBundleStream.Read` 经 P/Invoke 模块 `"Lapis"` 调用 `_Lapis_Decrypt`        |

## 文件

| 版本            | ABI           | 大小  | SHA-256                                                            |
|-----------------|---------------|-------|--------------------------------------------------------------------|
| `1.0.3`–`1.5.0` | `arm64-v8a`   | 78840 | `FB9C7257823844335DF0A338BEDE68A596628B0D5AC3ECC47717E8045E162393` |
| `1.0.3`–`1.5.0` | `armeabi-v7a` | 25592 | `11687F555EF3FA6247AB3E2EBEBDDB438B338E9DD59F6AE9DD6F5BA03B6CC7CD` |

1.0.3 – 1.5.0 的各版本、两个 ABI 均与上表一致，没有版本特例。

下文地址均为 1.5.0 `arm64-v8a` 的 RVA。

### 文件结构

以 1.5.0 `arm64-v8a` 为例：

| 节               | 地址      | 大小   | 说明                                            |
|------------------|-----------|--------|-------------------------------------------------|
| `.plt`           | `0x8d0`   | `0x110` | 导入函数跳板                                    |
| `.text`          | `0x9e0`   | `0x7f0` | 加壳器运行时（`init_func`、`kcDecodeFunc` 等）  |
| `.kclapisniceway`| `0x11d0`  | `0x120` | 被加密的 `_Lapis_Decrypt`                       |
| `.rodata`        | `0x12f0`  | `0x9b`  | 日志文案、库名                                  |
| `.init_array`    | `0x11d38` | `0x10`  | `[0] = 0xa1c`（`init_func`，由重定位填入）      |
| `.fini_array`    | `0x11d48` | `0x10`  | `[0] = 0x9e0`（`__cxa_finalize`）               |
| `.8259b86f1d`    | `0x13010` | `0x3e8` | 加壳描述符（其余为填充）；文件在此结束（78840 字节） |

`.init_array` 在文件中为 0，由 `.rela.dyn` 的 `R_AARCH64_ABS64` 重定位填入 `0xa1c`（`init_func`）。
`e_entry = 0x13010` 指向描述符而不是代码，反汇编器会误认成 `start`。

## 导出

`.dynsym` 共 28 项：5 个已定义函数、13 个导入函数、7 个链接器绝对符号，其余为空/节符号。

| 地址     | 符号                  | 签名                                                                              | 功能                                                    |
|----------|-----------------------|-----------------------------------------------------------------------------------|---------------------------------------------------------|
| `0x11d0` | `_Lapis_Decrypt`      | `void _Lapis_Decrypt(uint8_t *array, int key, int start, int size, int startIdx)`  | AssetBundle 流解密；加载时由壳解密                       |
| `0xa50`  | `_Z12kcDecodeFuncPKc` | `void kcDecodeFunc(const char *libName)`                                          | 解密自身的 `.kclapisniceway`                            |
| `0x1010` | `_Z12kcgetLibAddrPKc` | `uintptr_t kcgetLibAddr(const char *libName)`                                     | 从 `/proc/<pid>/maps` 取库基址                           |
| `0xa1c`  | `_Z9init_funcv`       | `void init_func(void)`                                                            | `.init_array[0]`：打日志后尾调用 `kcDecodeFunc`          |
| `0xa4c`  | `_Z7my_initv`         | `void my_init(void)`                                                              | 空函数（`RET`）                                          |

`kcDecodeFunc` / `kcgetLibAddr` 以 C++ 修饰名导出，供外部按名解析。

## 加固

* **自解密**：`.init_array` 在重定位后写入 `init_func`（`0xa1c`）。它调用
  `kcDecodeFunc("libLapis.so")`，后者用 `kcgetLibAddr` 定位自身，读取 `e_entry` 处的 12 字节描述符，
  `mprotect` 后对 `.kclapisniceway` 每 `key % 9` 字节取反（`0` 表示全部取反），再改回只读可执行。
* **加密范围**：只覆盖 `_Lapis_Decrypt` 一个函数，段长度等于该函数长度；其余代码明文。
* **代码混淆**：控制流平坦化（状态机 + 无意义常量比较）、字符串拆分复用，例如
  `"The second mem privilege change failed"+0xB` → `"mem privilege change failed"`。
* 普通 ELF 加固：Full RELRO（`DF_1_NOW`）、NX 栈、已 strip；无 RPATH/RUNPATH。

1.5.0 描述符参数：

| ABI   | `e_entry` | 被解密段          | offset   | length  | key          | `key % 9` |
|-------|-----------|-------------------|----------|---------|--------------|-----------|
| arm64 | `0x13010` | `.kclapisniceway` | `0x11d0` | `0x120` | `0x3F23138C` | 2         |
| armv7 | `0x6010`  | `.kclapisniceway` | `0x3170` | `0x124` | `0x73ECB360` | 5         |

## 功能点

### `_Lapis_Decrypt`：AssetBundle 流解密

托管侧声明（`Il2CppDumper` 输出 `dump.cs`）：

```csharp
public class AssetBundleStream : FileStream {
    public class LapisExtern {
        // RVA: 0x2E6819C（1.5.0）
        [DllImport("Lapis")]
        public static extern void _Lapis_Decrypt(byte[] array, int key, int start, int size, int startIdx);
    }
}
```

原生实现（`0x11d0`，还原后）：

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

### 调用方与分块对齐

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

`startIdx` 是“缓冲区内第一个待解密字节所属的全局步长块序号”，`start` 是其在缓冲区内的偏移，
保证分块读取时解密与文件偏移无关。

### P/Invoke 加载

`extern` 方法由 IL2CPP 的 P/Invoke 机制实现：`libil2cpp.so` 的包装函数（`0x2E6819C`）首次调用时把模块名
`"Lapis"`、入口名 `"_Lapis_Decrypt"`（`0x304AA28` / `0x304AA2E`）交给 P/Invoke 解析函数（`0x10B6C18`）
取得地址并缓存，之后转发 `byte[]` 数据区指针（对象 `+0x20`）。因此没有任何库以 `DT_NEEDED`
依赖 `libLapis.so`——它由 P/Invoke 按需加载。

## 引用

* `Scripts/Oz.GameFramework.Runtime.Resource/AssetBundleStream.cs`：`[DllImport("Lapis")]` 声明与
  `Read` 的分块对齐逻辑。
* `libil2cpp.so`：P/Invoke 包装 `0x2E6819C`，解析器 `0x10B6C18`，字符串 `0x304AA28`。
* [Unity-AssetBundle.md](../assets/Unity-AssetBundle.md)：AssetBundle 文件头与流解密的整体说明。
* [README.md](README.md)：二进制库的通用加壳格式。

## 待探究

* [ ] `_Z7my_initv` 为空函数，未发现调用方，保留原因不明。
* [ ] `kcgetLibAddr` 以 C++ 修饰名导出，除 `kcDecodeFunc` 外是否有其它调用方（如 `libtolua.so`）。
* [ ] armv7 仅核对导出、字符串与描述符参数，未逐函数分析。
