# libUnityPlugin.so

## 概要

| 项     | 值                                                                                                                    |
|--------|-----------------------------------------------------------------------------------------------------------------------|
| 功能   | Unity 元数据解密插件：`query_call_back` 提供 `il2cpp_get_global_metadata`（RC4 解密 `game.dat`）与 `il2cpp_get_string`（按需解密元数据字符串池）；另带 Mono 后端接口（本作未启用） |
| ABI    | `arm64-v8a`、`armeabi-v7a`                                                                                            |
| 工具链 | NDK `r16b`、Android clang 5.0.300080，minSdk 21；静态链接 libc++/libc++abi；保留符号与 DWARF                         |
| 依赖   | `libc.so`、`libdl.so`（`DT_NEEDED` 另有 `liblog.so`/`libandroid.so`，但没有导入它们的符号）                            |
| 使用   | 由 `libil2cpp.so` 以 `dlopen`/`dlsym` 装载，opcode `107`/`108` 取回调                                                 |

## 文件

| 版本            | ABI           | 大小    | SHA-256                                                            |
|-----------------|---------------|---------|--------------------------------------------------------------------|
| `1.3.0`–`1.5.0` | `arm64-v8a`   | 2923304 | `11B56970F3F157F244088C76AE37124EEA9CA918B28A9B63555FFC9FF1383205` |
| `1.3.0`–`1.5.0` | `armeabi-v7a` | 1908576 | `718314951AA1E758A89826939C67B5AEE3591CE1D8C94E58982EBE54D069316C` |

1.3.0 – 1.5.0 两个 ABI 的文件完全一致；1.0.3 – 1.2.0 未包含该库。`get_version` 返回 SDK 版本串 `1.0.1`。

### 文件结构

以 1.5.0 `arm64-v8a` 为例：

| 节                | 地址      | 大小       | 说明                                                     |
|-------------------|-----------|------------|----------------------------------------------------------|
| `.text`           | `0xedb0`  | `0x32bbc`  | 仅前 `0x15e0` 字节为本库代码，其余是静态链接的 libc++ 等 |
| `.rodata`         | `0x41970` | `0x2b11`   | CRC32 表（`0x41970`）、`00..FF` 常量表（`0x41d70`）、版本串 |
| `.init_array`     | `0x5c340` | `0x10`     | `[0] = 0xedbc`（`.rela.dyn` 的 `R_AARCH64_RELATIVE`）     |
| `.data`/`.bss`    | `0x5e000` | `0xc0`/`0x970` | `g_flag`、互斥量、`g_opcode`、去重表（见「全局状态」） |
| `.debug_*`        | —         | `0x2682e8` | DWARF，占文件 86%                                        |

* `e_entry = 0xedb0` 指向 `__on_dlclose`（调 `__cxa_finalize`），是链接器产物，反汇编器会误认成 `start`。
* `.dynsym` 679 项中只有 19 项是本库函数，其余是 libc++/libc++abi/libgcc 的导出（含内嵌的 C++ 反混淆器）。
* DWARF 保留了源文件 `..\src\UnityPlugin\UnityPlugin.cpp`、`..\src\3rd\crc\crc32.cpp`、`..\src\3rd\xxtea\xxtea.c`
  及头文件 `common.h`、`encryptlib.h`、`file_lib_c.h`；`DW_AT_comp_dir = E:\UPS\msvc`。

## 导出

`.dynsym` 中本库自身的 19 个符号：

| 地址      | 符号                             | 签名                                                                        | 功能                                             |
|-----------|----------------------------------|-----------------------------------------------------------------------------|--------------------------------------------------|
| `0xedb0`  | `__on_dlclose`                   | `void (void)`                                                               | `e_entry` / `.fini_array[0]`                     |
| `0xedbc`  | `_GLOBAL__sub_I_UnityPlugin.cpp` | `void (void)`                                                               | `.init_array[0]`，构造全局状态                   |
| `0xee80`  | `crc32`                          | `uint32_t crc32(const uint8_t *data, size_t len)`                           | 反射式 CRC-32                                    |
| `0xeec0`  | `crc32_ex`                       | `uint32_t crc32_ex(const uint8_t *data, size_t len, uint32_t crc)`          | 可续算 CRC-32                                    |
| `0xeefc`  | `xxtea_encrypt`                  | `void *xxtea_encrypt(const void *data, size_t len, const char key[16], size_t *outLen)` | XXTEA 加密                            |
| `0xf1d8`  | `xxtea_decrypt`                  | `char *xxtea_decrypt(const void *data, size_t len, const char key[16], size_t *outLen)` | XXTEA 解密                            |
| `0xf4d0`  | `read_file_size`                 | `bool read_file_size(const char *path, uint32_t *size)`                     | 取文件大小                                       |
| `0xf548`  | `read_file_to_buffer`            | `bool read_file_to_buffer(const char *path, uint8_t *buf, uint32_t size)`   | 读整个文件                                       |
| `0xf624`  | `get_game_data_from_mem`         | `bool get_game_data_from_mem(uint8_t *buf, int len, uint32_t magic, uint8_t **out, uint32_t *outLen)` | 按记录链查找 magic     |
| `0xf694`  | `il2cpp_get_global_metadata`     | `char *il2cpp_get_global_metadata(const char *path)`                        | 读取并 RC4 解密 `game.dat`                       |
| `0xf9e4`  | `il2cpp_get_string`              | `void il2cpp_get_string(char *s, int offset)`                               | 原地解密一条元数据字符串                         |
| `0xfb88`  | `mono_metadata_encrypt`          | `uint32_t mono_metadata_encrypt(void)`                                      | 返回元数据加密标志位                             |
| `0xfb98`  | `mono_get_method`                | `void mono_get_method(char *s, int len)`                                    | 按长度解密 Mono 方法名字符串                     |
| `0xfd48`  | `mono_get_string_heap`           | `void mono_get_string_heap(char *s, int len)`                               | 还原字符串堆条目                                 |
| `0xfd90`  | `mono_get_opcode`                | `int mono_get_opcode(int op)`                                               | 查 opcode 表                                     |
| `0xfda8`  | `init_callback_func_info`        | `int init_callback_func_info(char **blob, int size, CallBackFuncInfo *table)` | 解析配置并把回调写入调用方表格                   |
| `0xffc4`  | `mono_get_assembly_csharp`       | `void mono_get_assembly_csharp(char **buf, int *len, const char *unused, CallBackFuncInfo *table)` | 解密 Assembly-CSharp 数据     |
| `0x102b0` | `query_call_back`                | `void *query_call_back(int op)`                                             | 按 opcode 派发回调                               |
| `0x102f4` | `get_version`                    | `const char *get_version(void)`                                             | 返回 `"1.0.1"`                                   |

| opcode | 返回                          |
|--------|-------------------------------|
| `0x64` | `mono_get_assembly_csharp`    |
| `0x6b` | `il2cpp_get_global_metadata`  |
| `0x6c` | `il2cpp_get_string`           |
| 其它   | `NULL`                        |

armv7 同一组函数地址：`0xb4e5`/`0xb521`/`0xb555`/`0xb779`/`0xb9c5`/`0xba09`/`0xba9d`/`0xbaf1`/`0xbe95`/
`0xbfbd`/`0xbfcd`/`0xc0f9`/`0xc125`/`0xc139`/`0xc2b1`/`0xc63d`/`0xc671`。无 JNI 导出，也未被托管
`DllImport` 引用。

## 加固

无。未 strip：保留 `.symtab` 与完整 DWARF，源文件名、函数名与行号可直接读出；无自定义加密段、无反调试。

## 功能点

### 记录容器

`game.dat`、Mono 配置 blob、Assembly-CSharp 数据共用同一容器：0x10 字节记录头 + 变长数据，记录间无对齐填充。

```text
+0x00  uint32 magic
+0x04  uint32 size          // 紧随其后的数据长度
+0x08  8 字节填充
+0x10  uint8 data[size]
下一个记录 = 当前记录 + 0x10 + size
```

| magic        | 用途                                    |
|--------------|-----------------------------------------|
| `0x4C27FF5D` | 文件头标记（本库不使用）                |
| `0x567FE814` | RC4 密钥（1.5.0 为 4 字节 `7C 42 A8 10`） |
| `0xBCFAF088` | 元数据密文，`size` 为明文长度           |
| `0x738E1C4A` | Mono 配置 blob，首字节为标志位          |
| `0xDFDA8E83` | Mono opcode 表                          |
| `0x3AB7E657` | Assembly-CSharp 明文长度                |
| `0x7EC17A83` | Assembly-CSharp 的 RC4 密钥             |

### `il2cpp_get_global_metadata`：整块元数据解密

`0xf694`，对应 opcode `107`：

```c
char *il2cpp_get_global_metadata(const char *path) {
    uint32_t total = file_size(path);
    char *buf = new (nothrow) char[total];
    if (!buf || !read_file_to_buffer(path, buf, total)) return NULL;

    uint32_t cipher_off = find_record(buf, 0xBCFAF088);   // 记录链线性扫描
    uint32_t cipher_len = *(uint32_t *)(buf + cipher_off + 4);
    uint32_t key_off    = find_record(buf, 0x567FE814);
    uint32_t key_len    = *(uint32_t *)(buf + key_off + 4);

    char *out = new (nothrow) char[cipher_len];
    rc4(buf + key_off + 0x10, key_len, buf + cipher_off + 0x10, cipher_len, out);
    delete[] buf;
    return out;
}
```

* 标准 RC4（KSA + PRGA）：S 盒初值是 `.rodata 0x41d70` 的 `00 01 02 .. FF`（`for(i) S[i]=i` 被折叠成 32 次
  `qword` 拷贝）；密钥长度直接取记录头 `size`。
* 实现来自 `encryptlib.h` 的 `init/init_inline`、`encrypt/encrypt_inline`、`swap_bytes`，在
  `il2cpp_get_global_metadata` 与 `mono_get_assembly_csharp` 中各内联一份。
* 只校验两条记录存在且长度非 0，不校验解密结果的 `0xFAB11BAF` 魔数。
* 实测 1.5.0 `game.dat` 解得 11 748 184 字节、头部 `AF 1B B1 FA` + 版本 `24`，与
  [global-metadata.dat](global-metadata.dat.md) 一致。

### `il2cpp_get_string`：字符串池按需解密

`0xf9e4`，对应 opcode `108`。RC4 之后字符串池仍是密文，每个名称在首次访问时原地解密：

```c
void il2cpp_get_string(char *s, int offset) {     // offset = 字符串池内偏移
    lock(g_metadata_string_mutex);
    if (g_il2cpp_string_index_table.count(offset)) { unlock(); return; }
    g_il2cpp_string_index_table.insert(offset);
    uint8_t key = offset % 255;
    do {
        key ^= (uint8_t)*s;      // 明文 = 密文 ^ 前一个明文字节
        *s++ = key;
    } while (key != 0);          // 解出 NUL 即一条名称结束
    unlock();
}
```

* `NUL` 由解出的明文产生，而不是密文中的 0。
* 去重表是 `std::set<int>`：解密是破坏性的，重复调用必须短路。
* 实测：按此规则处理 1 390 296 字节字符串池得到 78 775 条可读名称（首条 `mscorlib`），186 条含非可打印字节。

### Mono 后端接口（本作未启用）

面向 Mono 构建的 Unity 游戏，本包内 `init_callback_func_info` 无调用方。

```c
struct CallBackFuncInfo {   // 16 字节一项
    int    type;            // +0x00
    int    pad;
    void **ppfn;            // +0x08，指向调用方的函数指针槽
    uint64_t pad2;
};
```

`init_callback_func_info` 先在 blob 中找记录 `0x738E1C4A`，取数据首字节为标志位写入 `g_flag`，再按
`table` 逐项写入函数指针（`type == 0` 结束并返回 1）：

| `type`        | 写入                    | 条件                                  |
|---------------|-------------------------|---------------------------------------|
| `0x65`        | `mono_get_method`       | `g_flag & 0x04`                       |
| `0x66`        | `mono_get_string_heap`  | `g_flag & 0x08`                       |
| `0x67`        | `mono_get_opcode`       | 仅「进阶模式」（`g_flag & 0x02`），并从记录 `0xDFDA8E83` 拷入 opcode 表 |
| `0x68`        | `mono_metadata_encrypt` | `g_flag & 0x10`                       |
| `0x69`,`0x6a` | `NULL`                  | —                                     |

| 函数                   | 算法                                                                 |
|------------------------|----------------------------------------------------------------------|
| `mono_get_method`      | `key = len % 255` 链式差分原地解密 `len` 字节（以长度而非 `NUL` 结束），以指针为键的 `std::set` 去重 |
| `mono_get_string_heap` | `s[0] = 0`，其后 `s[i] ^= s[i-1]`（`s[0]` 非 0 才处理）              |
| `mono_get_opcode`      | `op <= 9` 返回 `g_opcode[op]`，否则原样返回                          |
| `mono_metadata_encrypt`| 返回 `(g_flag >> 4) & 1`                                             |
| `mono_get_assembly_csharp` | 先 `init_callback_func_info`；取 `0x3AB7E657` 的长度与 `0x7EC17A83` 的密钥做 RC4，把 `*buf`/`*len` 换成明文 |

第三个参数只在入口做非空判断，之后从未被读取。

### 其它工具函数

`crc32`、`crc32_ex`、`xxtea_encrypt`、`xxtea_decrypt`、`read_file_size`、`get_game_data_from_mem`
在本库内无调用方，属 SDK 公共工具面：

* `crc32`：表驱动反射 CRC-32（表在 `.rodata 0x41970`）。
* `xxtea_*`：delta `0x9E3779B9`、`rounds = 6 + 52/n`；密钥按 16 字节 C 字符串处理（首个 `NUL` 之后清零），
  输出末尾 word 存明文长度，解密侧用 `n*4-7 <= len <= n*4-4` 校验。

### 全局状态

`.init_array[0]`（`0xedbc`）在加载时构造两把互斥量与两个 `std::set`；库不创建线程、不读 `/proc`、不写日志。

| 符号                          | 地址      | 类型              | 用途                            |
|-------------------------------|-----------|-------------------|---------------------------------|
| `g_flag`                      | `0x5e008` | `uint32_t`        | Mono 配置标志，初值 `0xFFFFFFFF` |
| `g_method_mutex`              | `0x5e0c0` | `std::mutex`      | 保护 `g_method_table`           |
| `g_metadata_string_mutex`     | `0x5e0e8` | `std::mutex`      | 保护字符串去重表                |
| `g_opcode`                    | `0x5e110` | `uint8_t[256]`    | Mono opcode 表                  |
| `g_method_table`              | `0x5e210` | `std::set<char*>` | `mono_get_method` 去重          |
| `g_il2cpp_string_index_table` | `0x5e228` | `std::set<int>`   | `il2cpp_get_string` 去重        |

## 引用

* `libil2cpp.so`：元数据初始化（`0x106e830`）执行 `dlopen("libUnityPlugin.so")` + `dlsym("query_call_back")`，
  用 opcode `107`/`108` 取回调；随后按插件是否可用选择 `Metadata/game.dat` 或明文 `global-metadata.dat`，
  详见 [libil2cpp.so](libil2cpp.so.md)。
* `assets/bin/Data/Managed/Metadata/game.dat`：`il2cpp_get_global_metadata` 的输入（1.3.0 起）。
* 无 `DT_NEEDED` 依赖本库，也无托管 `DllImport` 声明，属运行时动态装载。
* 容器格式与两层解密算法另见 [global-metadata.dat](global-metadata.dat.md)。

## 待探究

* [ ] 未出现厂商/产品标识（无日志、URL、公司名），SDK 归属未知。
* [ ] `mono_get_assembly_csharp` 的明文是否为 PE 程序集未验证（本包内无 `0x3AB7E657` 记录）。
* [ ] `armeabi-v7a` 仅核对导出、字符串与版本串（无 `0x41d70` 常量表，RC4 的 S 盒初值在代码中生成），
      未逐函数复核解密逻辑。
* [ ] `crc32`、`xxtea_*`、`read_file_size`、`get_game_data_from_mem` 的实际使用者未知。
