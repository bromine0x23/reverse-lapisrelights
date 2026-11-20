# libklbsqlite3.so

## 概要

| 项     | 值                                                                                                                       |
|--------|--------------------------------------------------------------------------------------------------------------------------|
| 功能   | 官方 SQLite **3.28.0**，附加只读 VFS `klb_vfs`：按虚拟文件名携带的密钥，在读取时透明解密 MasterData                        |
| ABI    | `arm64-v8a`、`armeabi-v7a`                                                                                               |
| 工具链 | NDK `GCC: (GNU) 4.9.x 20150123 (prerelease)`（`.comment`）；未混淆、未加壳                                                |
| 依赖   | `libc.so`、`libdl.so`                                                                                                    |
| 使用   | 托管 `KlabVfs.klbvfs_register()`（P/Invoke）注册 VFS；`SqlLiteSupport.OpenDB(..., vfs: "klb_vfs")` 打开数据库            |

## 文件

| 版本            | ABI           | 大小   | SHA-256                                                            |
|-----------------|---------------|--------|--------------------------------------------------------------------|
| `1.0.3`–`1.5.0` | `arm64-v8a`   | 686704 | `02BEE791B1170379295572BB8790F4FA1D61255CF4D7C4A25AD158AB1FD1D78F` |
| `1.0.3`–`1.5.0` | `armeabi-v7a` | 682432 | `80F6885AA0600FCEF0F26702402FAD2027BA751E1C8BEC89D2FE9E54DFD0A7AE` |

1.0.3 – 1.5.0 的各版本、两个 ABI 均与上表一致，没有版本特例。

下文地址均为 1.5.0 `arm64-v8a` 的 RVA。

### 文件结构

以 1.5.0 `arm64-v8a` 为例：

| 节             | 地址      | 大小      | 说明                                          |
|----------------|-----------|-----------|-----------------------------------------------|
| `.text`        | `0xcb10`  | `0x89230` | SQLite 3.28.0 与自定义 VFS 代码               |
| `.rodata`      | `0x95d40` | `0xbf24`  | 版本号、source id、编译选项、SQL 关键字等     |
| `.data.rel.ro` | `0xb2910` | `0x22d8`  | 自定义 `sqlite3_io_methods`（位于节首）       |
| `.data`        | `0xb5000` | `0x2408`  | 自定义 `sqlite3_vfs`（`0xb5008`）             |
| `.bss`         | `0xb7410` | `0x6b0`   | 默认 VFS 指针、`szOsFile` 等运行时状态        |
| `.init_array`  | `0xb28f8` | `8`       | `0`（无构造函数）                             |
| `.fini_array`  | `0xb2900` | `0x10`    | `[0] = 0x109fc`（`__cxa_finalize(&__dso_handle)`） |

`e_entry = 0xcb10`，即 `.text` 首地址，是普通函数而非加壳描述符；`.init_array` 为空，说明该库没有构造阶段的自解密。

## 导出

共 342 个动态符号：270 个已定义的函数/数据符号、62 个导入函数、7 个链接器绝对符号，
其余为空/节符号。254 个 `sqlite3_*`
与官方 3.28.0 的 API 一致（签名同官方头文件），不逐一列出；下表只列与本作相关的符号。

| 地址      | 符号                    | 签名                                                             | 功能                                                        |
|-----------|-------------------------|------------------------------------------------------------------|-------------------------------------------------------------|
| `0x110ac` | `klbvfs_register`       | `void klbvfs_register(void)`                                     | 注册 `klb_vfs`（非默认 VFS），保存默认 VFS 的 `szOsFile`    |
| `0x97000` | `sqlite3_version`       | `const char sqlite3_version[7]`                                  | `"3.28.0"`                                                  |
| `0x16964` | `sqlite3_sourceid`      | `const char *sqlite3_sourceid(void)`                             | 官方 3.28.0 的 source id                                    |
| `0x92e94` | `sqlite3_open_v2`       | `int sqlite3_open_v2(const char *, sqlite3 **, int, const char *)` | 打开数据库，`zVfs` 可指定 `"klb_vfs"`                     |
| `0x2a5d8` | `sqlite3_vfs_find`      | `sqlite3_vfs *sqlite3_vfs_find(const char *)`                    | 按名查找 VFS                                                |
| `0x2a690` | `sqlite3_vfs_register`  | `int sqlite3_vfs_register(sqlite3_vfs *, int)`                   | 注册 VFS                                                    |
| `0x2a718` | `sqlite3_os_init`       | `int sqlite3_os_init(void)`                                      | 只注册 4 个官方 unix VFS 变体，不含 `klb_vfs`               |

其余为 14 个编译器软浮点符号（`__addtf3` 等）与内部数据符号 `sqlite3one`。
完整的 254 个 API 名可直接读 `.dynsym`（如 `nm -D libklbsqlite3.so`），此处不复制标准接口清单。

> 托管侧声明了 `Jackpot.Sqlite.SQLite.sqlite3_key`，但本库**未导出该符号**；`SQLiteDB.Key()` 也无调用方，
> 属于死代码。数据库并非 SQLCipher 加密。

## 加固

无自加壳、自解密或反调试，仅保留普通 ELF 加固：

* Full RELRO（`DF_1_NOW`）、NX 栈、已 strip；无 RPATH/RUNPATH、无 BTI/PAC。
* 代码未混淆，`.comment` 保留编译器版本。

## 功能点

### 与官方 SQLite 3.28.0 的关系

* `sqlite3_version` = `"3.28.0"`；`sqlite3_sourceid` =
  `"2019-04-16 19:49:53 884b4b7e502b4e991677b53971277adfaf0a04a284f8e483e2553d0f83156b50"`，
  与官方 3.28.0 amalgamation 一致。
* 编译选项（`sqlite3_compileoption_get` 表）：
  `COMPILER=gcc-4.9.x 20150123 (prerelease)`、`ENABLE_COLUMN_METADATA`、`ENABLE_FTS3`、
  `ENABLE_FTS3_PARENTHESIS`、`ENABLE_FTS4`、`ENABLE_MEMORY_MANAGEMENT`、`ENABLE_RTREE`、
  `HAVE_ISNAN`、`TEMP_STORE=2`、`THREADSAFE=2`。
  未启用 FTS5、ICU、JSON1、SEE/SQLCipher。
* `sqlite3_os_init` 只注册 `unix`、`unix-excl`、`unix-dotfile`、`unix-none`，**不注册也不默认使用**
  `klb_vfs`。游戏侧由 `KcAppSetting.EnableSqlLiteEncrypt`（静态字段 `+0x51`）决定是否以
  `vfs=klb_vfs` 打开，并在首次使用时调用一次 `klbvfs_register()`。
* 唯一的非 SQLite/编译器运行时导出是 `klbvfs_register`（`0x110ac`），其余自定义函数均为内部静态函数。

### 自定义 VFS `klb_vfs`

#### 注册与结构

`klbvfs_register()`（`0x110ac`）返回 `void`（托管侧却声明为 `int`）：

```c
sqlite3_vfs *def = sqlite3_vfs_find(NULL);   // 当前默认 VFS（unix）
g_default_vfs = def;
g_sz_os_file  = def->szOsFile;
g_klb_vfs.szOsFile = g_sz_os_file + 0x18;    // armv7 为 +0x10
sqlite3_vfs_register(&g_klb_vfs, 0);         // 非默认 VFS，需按名选择
```

| 字段         | 值 / 地址                              |
|--------------|----------------------------------------|
| `iVersion`   | `2`                                    |
| `szOsFile`   | 运行时 = 默认 VFS 的 `szOsFile + 0x18` |
| `mxPathname` | `1024`                                 |
| `zName`      | `"klb_vfs"`（`0x95d40`）               |
| `pAppData`   | `NULL`                                 |
| 结构地址     | `0xb5008`                              |

自定义 `sqlite3_io_methods` 位于 `0xb2910`，`iVersion = 3`：

| 方法         | 地址      | 方法             | 地址      |
|--------------|-----------|------------------|-----------|
| `xClose`     | `0x10a7c` | `xFileControl`   | `0x10b9c` |
| `xRead`      | `0x10fb4` | `xSectorSize`    | `0x10bc0` |
| `xWrite`     | `0x10aa0` | `xShmMap`        | `0x10c08` |
| `xTruncate`  | `0x10ac4` | `xShmLock`       | `0x10c2c` |
| `xSync`      | `0x10ae8` | `xShmBarrier`    | `0x10c50` |
| `xFileSize`  | `0x10b0c` | `xFetch`         | `0x10c98` |

除 `xOpen`、`xRead` 外，其余方法（含未列出的 `xLock`、`xUnlock`、`xCheckReservedLock`、
`xShmUnmap`、`xUnfetch`）都只是用保存的原始 `pMethods` 直接转发。

每个文件的额外状态追加在默认 `sqlite3_file` 之后（arm64 `0x18` 字节，armv7 `0x10` 字节）：

```text
+0x00  sqlite3_io_methods *pMethods_original
+0x08  uint32_t k1
+0x0c  uint32_t k2
+0x10  uint32_t k3
```

#### 文件名约定

VFS 打开的文件名必须是：

```text
<k1>.<k2>.<k3> <real_path>
```

`xOpen`（`0x10ecc`）逐字节解析：只接受十进制数字、`.` 和分隔空格，且必须恰有两个 `.`；
不满足时返回 `1`（`SQLITE_ERROR`）。解析成功后：

1. 以空格后的 `real_path` 调用原始 VFS 的 `xOpen`；
2. 把原始 `pMethods` 与三个 `uint32` 存入额外状态；
3. 把文件的 `pMethods` 换成 `0xb2910` 的自定义方法表。

前缀只存在于传给 SQLite 的“虚拟文件名”中，真实文件仍叫 `master_data.db`。
托管侧用 `string.Format("{1} {0}", realPath, key)` 生成该名字（即 `key + " " + realPath`）。

#### 读取解密

`xRead`（`0x10fb4`）先调用原始 `xRead`，成功后对本次读出的 `iAmt` 字节做流式异或：

```c
#define A 0x000343FDu
#define C 0x00269EC3u

uint32_t adv(uint32_t k, uint64_t n) {
    // 等价于连续推进 n 次：k = k*A + C (mod 2^32)
    // 原实现用倍增法求 k*A^n + C*(A^n-1)/(A-1)
}

// 对文件偏移 ofs 处的第 i 个字节：
s1 = adv(k1, ofs + i);
s2 = adv(k2, ofs + i);
s3 = adv(k3, ofs + i);
plain = cipher ^ (s1 >> 24) ^ (s2 >> 24) ^ (s3 >> 24);
```

实现上先对 `k1/k2/k3` 各推进 `ofs` 步（`sub_10a38`，倍增法），再在循环中每字节推进一次。
因此解密与分块读取无关，任意偏移都可直接定位。

`xWrite`（`0x10aa0`）只转发原始方法，**不加密**。所以 `klb_vfs` 实际只能用于只读数据库：
若通过它写入，落盘的是明文，之后再读又会被异或，数据即被破坏。游戏中的 MasterData 正是只读使用。

### 与 MasterData 加密流程的关系

见 [MasterData.md](../assets/MasterData.md)。本库只实现其中的**单层 LCG 异或**，密钥来自文件名前缀。
完整链路如下：

```text
下载文件（已用固定参数加密）
    │  KlabVfs.Deflate(tmpFile, manifestKeys, ref savedKey)
    │    外层 LCG 密钥 = manifestKeys[i] ^ KcAppSetting.SqliteKey[i]
    │                    = 2000^100, 1500^150, 1000^200 = 1972, 1354, 800
    │    内层 LCG 密钥 = GetRawSqliteKey(tmpFile, masterKey)
    ▼
本地文件 master_data.db（仅内层加密）
    │  savedKey = "k1.k2.k3"  → KcAppSetting.GetSqlClientKey()
    │  SqlLiteSupport.OpenDB 以 "k1.k2.k3 <path>" 和 vfs=klb_vfs 打开
    ▼
libklbsqlite3.so / klb_vfs：xOpen 取出 k1.k2.k3，xRead 用内层密钥异或 → 明文页
```

* `GetRawSqliteKey` 取“带设备主密钥的摘要（文件名, masterKey）”前 12 字节，按大端拆成 3 个
  `uint32`；具体摘要/HMAC 算法未确认（见“待探究”）。
* `KcAppSetting.SqliteKey1/2/3 = 100/150/200` 是由 `2000/1500/1000 → 1972/1354/800` 反推的，
  与 MasterData.md 的结论一致。
* 下载到的原始文件可直接用 **1972 / 1354 / 800** 解密；本地重加密文件使用由设备主密钥与文件路径
  派生的 `k1.k2.k3`。该键串不写入数据库文件，仅由应用在打开时通过虚拟文件名提供，单凭文件无法直接解密。

可直接复用的解密片段：

```python
def klb_decrypt(buf, k1, k2, k3):
    out = bytearray(buf)
    for i in range(len(out)):
        out[i] ^= (k1 >> 24) ^ (k2 >> 24) ^ (k3 >> 24)
        k1 = (k1 * 0x343FD + 0x269EC3) & 0xFFFFFFFF
        k2 = (k2 * 0x343FD + 0x269EC3) & 0xFFFFFFFF
        k3 = (k3 * 0x343FD + 0x269EC3) & 0xFFFFFFFF
    return bytes(out)
```

## 引用

* `Scripts/Assembly-CSharp/Oz/Framework/Utility/SqliteUtil.cs`：`LoadSqlite()` 以
  `path = $"{realPath} {GetSqlClientKey()}"`、`useVfs = EnableSqlLiteEncrypt` 调用 `SqlLiteSupport.OpenDB`。
* `Scripts/Assembly-CSharp/Kc/Config/KcAppSetting.cs`：`EnableSqlLiteEncrypt`、`SqliteKey1/2/3`、
  `GetSqlClientKey()`（读取 `PlayerPrefs`）。
* `Scripts/Stubs/AssemblyCSharpStubs.cs`：`KlabVfs`、`SqlLiteSupport` 的桩声明；`Scripts` 中尚未补上
  `klbvfs_register()`（元数据为 `public static extern int klbvfs_register()`）。
* [MasterData.md](../assets/MasterData.md)：MasterData 的下载、外层/内层加密与密钥推导。

## 待探究

* [ ] `GetRawSqliteKey` 使用的具体摘要/HMAC 算法，以及设备主密钥 `GetSqliteMasterKey` 的生成与存储位置。
* [ ] `e_entry` 为何等于 `.text` 首地址（`0xcb10`）；未发现该地址被用作初始化入口。
* [ ] 是否存在任何经 `klb_vfs` 写入的路径（静态看 `xWrite` 不加密，应为只读专用）。
* [ ] armv7 仅核对导出、字符串、VFS 结构与解密逻辑，未逐函数分析。
