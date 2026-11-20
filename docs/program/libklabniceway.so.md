# libklabniceway.so

## 概要

| 项     | 值                                                                                                       |
|--------|----------------------------------------------------------------------------------------------------------|
| 功能   | DEX 壳：解包 `classes.dex` 尾部载荷、替换 `LoadedApk.mClassLoader`，并实施反调试/反 Magisk 检测           |
| ABI    | `arm64-v8a`、`armeabi-v7a`                                                                               |
| 工具链 | `Obfuscator-LLVM clang 4.0.1`，NDK `r16b`；`.comment` 另有 `GCC 4.9.x 20150123`                           |
| 依赖   | `liblog.so`、`libc.so`、`libm.so`、`libstdc++.so`、`libdl.so`                                            |
| 使用   | `org.hackcode.ProxyApplication.<clinit>` 中 `System.loadLibrary("klabniceway")`，随后加载 assistant1/2  |

## 文件

| 版本    | ABI           | 大小   | SHA-256                                                            |
|---------|---------------|--------|--------------------------------------------------------------------|
| `1.0.3` | `arm64-v8a`   | 156688 | `E5994B8D3176FA821DAB8D4AC53BB366A1A63D7F9A9CB5F3184AF77B4C95EDE8` |
| `1.0.3` | `armeabi-v7a` | 78864  | `70F43C8DE7EE24E2AE3C25DE0D0FF5459A7931F5EB070D171BC7CECCDA47BDDC` |
| `1.0.4` | `arm64-v8a`   | 156688 | `9BD67EE8616C481CF409FE995532F5BA7959D2672CA2FF43E28B0B7675469767` |
| `1.0.4` | `armeabi-v7a` | 78864  | `BC09CB2469249DF9A936F45F0B62F48A74615458AFF19E6CDB1C25F340E46B62` |
| `1.1.0` | `arm64-v8a`   | 156688 | `67D5071C99BBF78EE1F9481C6FBA9A4272AD9B12FCBACC43ED61C3AC43D8E725` |
| `1.1.0` | `armeabi-v7a` | 78864  | `5B3CD91AA638060AA6121703D33673B873B3B34DF1F48F8992F27A5333285BDC` |
| `1.2.0` | `arm64-v8a`   | 156688 | `80E1DC9A49F59619B995A59B0189DEB1EFF236F8244EAF6BE873A649A2CFC335` |
| `1.2.0` | `armeabi-v7a` | 78864  | `8EF6A31DE1ED1AFBB210AEB4DC3AFC20B38A3DFCA0EA27474E94A95A09BD8754` |
| `1.3.0` | `arm64-v8a`   | 160784 | `76CA05B9F9325D4B8EBA4674F222EECD77DE3C36A626E1EB10EEBA1E8F8EACD9` |
| `1.3.0` | `armeabi-v7a` | 78864  | `A10F42407DA54913FBC0525E627D38B95F971C6ECEEB065B02EB74159101F2A6` |
| `1.4.0` | `arm64-v8a`   | 156688 | `E018EDD711DA620BC9C83926A8CBC022E6947B2060B664C2F798DEAACA5DB687` |
| `1.4.0` | `armeabi-v7a` | 78864  | `AB8245E9D42124333DFFB362BC91BB9EC42208B548E9FF540A3F82E8EB2ADBB0` |
| `1.5.0` | `arm64-v8a`   | 156688 | `B87D933AD365EC78FE7D5D63696122C9E5781E8093C61E70B85FE964BD99A2C6` |
| `1.5.0` | `armeabi-v7a` | 78864  | `950544F00D484C32D13F71C7506CC88EF7AE52EC02834B7641F3CD285DE7A923` |

每个版本都会重新构建/重新混淆，`.text`、`.kcniceway` 的代码字节不同；`.rodata`（字符串表、类名、签名）
与 `.comment` 稳定，DEX 解密密钥也不变。

下文地址均为 1.5.0 `arm64-v8a` 的 RVA。

### 文件结构

以 1.5.0 `arm64-v8a` 为例：

| 节            | 地址      | 大小     | 说明                                        |
|---------------|-----------|----------|---------------------------------------------|
| `.plt`        | `0x1060`  | `0x2b0`  | 导入函数跳板                                    |
| `.text`       | `0x1310`  | `0x1858` | `JNI_OnLoad`/`JNI_OnUnload` 与自解密初始化代码   |
| `.kcniceway`  | `0x2b68`  | `0xff50` | 被加壳的核心代码                            |
| `.rodata`     | `0x12ab8` | `0xb83`  | 字符串、类名、JNI 签名                      |
| `.b5a75776d1` | `0x26010` | `0x3e8`  | 加壳描述符，`e_entry` 指向此处              |
| `.init_array` | `0x24c58` | `0x10`   | `[0] = _INIT_0`（`0x134c`，自解密）          |
| `.fini_array` | `0x24c68` | `0x10`   | `[0] = _FINI_0`（`0x1310`，`__cxa_finalize`） |

`e_entry` 指向描述符而不是代码，反汇编器会误认成 `start`。armv7 1.5.0 对应 `e_entry = 0x13010`，
`.kcniceway = 0x4074..0xF824`。

### 版本特例

* **1.3.0 arm64**：文件 160784 字节（其余 arm64 版本 156688）；`e_entry = 0x27010`（其余 `0x26010`），
  描述符与 `.kcniceway` 整体后移，功能无变化。
* **1.4.0 armv7**：`key % 9 == 0`（`0x64F6F488`），`.kcniceway` 全部字节取反，而非只取反每 `key % 9` 字节。

## 导出

`.dynsym` 共 53 项：仅 2 个已定义导出（`JNI_OnLoad`/`JNI_OnUnload`）、41 个导入函数、
7 个链接器绝对符号，其余为空/节符号。

| 地址     | 符号           | 签名                              | 功能                                        |
|----------|----------------|-----------------------------------|---------------------------------------------|
| `0x1358` | `JNI_OnLoad`   | `jint JNI_OnLoad(JavaVM *, void *)` | 注册 4 个 native 方法，读取 SDK 版本，返回 `JNI_VERSION_1_4` |
| `0x17f8` | `JNI_OnUnload` | `void JNI_OnUnload(JavaVM *, void *)` | 空实现                                     |

### JNI

`JNI_OnLoad`：`GetEnv(JNI_VERSION_1_4)`；`FindClass("org/hackcode/ProxyApplication")` 后
`RegisterNatives`；读 `ro.build.version.sdk` 存入 `dword_250B4`；返回 `0x10004`。

| 地址     | Java 方法       | 签名                                                                              | 功能                                      |
|----------|-----------------|-----------------------------------------------------------------------------------|-------------------------------------------|
| `0x4510` | `start`         | `void start(Application app, String str, ClassLoader loader, Object obj)`         | 首次解包并安装 DEX                        |
| `0x4870` | `niceway_start` | `void niceway_start(Application app, String str, ClassLoader loader, Object obj)` | 已解包，直接安装 DEX                      |
| `0x4ae4` | `get_target`    | `String get_target(Application app)`                                              | 返回 `<dataDir>/app_assets/TargetApk.zip` |
| `0x4ae8` | `mg_present`    | `boolean mg_present(int pid)`                                                     | Magisk/Frida 检测（隔离进程调用）         |

`start`/`niceway_start` 在 `JNIEnv *` 后的第一个参数是 `ProxyApplication` 实例（`this`），
`sub_2e80` 直接对它调用 `getApplicationInfo()`。

## 加固

### 自解密

`.init_array[0]`（`_INIT_0`，`0x134c`）尾调用 `sub_1ac8("libklabniceway.so")`：

```c
base = find_module_base("libklabniceway.so");   // sub_1dcc：/proc/<pid>/maps
desc = base + ((Elf_Ehdr *)base)->e_entry;      // {address, length, key}
p    = base + desc[0];
step = desc[2] % 9;

mprotect(page_align(p), page_size(desc[1]), PROT_READ | PROT_WRITE | PROT_EXEC);
for (i = 0; i < desc[1]; ++i)
    if (step == 0 || i % step == 0) p[i] = ~p[i];
mprotect(page_align(p), page_size(desc[1]), PROT_READ | PROT_EXEC);
```

mprotect 失败时输出 `mem privilege change failed` / `The second mem privilege change failed`
（tag `JNITag` / `JNI_TAG`）。1.5.0 参数：

| ABI   | `e_entry` | `address` | `length`  | `key`        | `key % 9` |
|-------|-----------|-----------|-----------|--------------|-----------|
| arm64 | `0x26010` | `0x2b68`  | `0x0FF50` | `0x28C9D4E5` | 4         |
| armv7 | `0x13010` | `0x4074`  | `0x0B7B0` | `0x69B99EE5` | 2         |

1.5.0 arm64 共 16340 字节被取反（`0xff50 / 4`）。自解密后的文件 SHA-256 为
`0537F92D1FA30C01648718381AFF0954C4C9EE438E57F9A53F751726433F2033`。

### 代码混淆

控制流平坦化；字符串单字节 XOR（常用 key：`0x31`、`0x3C`、`0x3D`、`0x58`、`0x29`、`0x23`、`0x09`）。
普通 ELF 加固：Full RELRO（`DF_1_NOW`）、NX 栈、已 strip。

### 反调试与反篡改

`sub_bcb4` 在 `start`/`niceway_start` 开头调用：`ptrace(PTRACE_TRACEME, 0, 0, 0)`、`sub_2914()`
完整性准备，然后创建两个 pthread：`sub_7b54`（周期轮询）与 `sub_4c78`（大型检查）。
`sub_bd54`/`sub_c558` 负责 `/proc` maps 扫描，`sub_cab4` 为 memmem 辅助。

| 检测项          | 函数                                  | 实现                                                                         |
|-----------------|---------------------------------------|------------------------------------------------------------------------------|
| `ptrace`        | `sub_bcb4`                            | `PTRACE_TRACEME`                                                             |
| Java 调试器     | `sub_9cd4`                            | `android/os/Debug.isDebuggerConnected()`                                     |
| `TracerPid`     | `sub_a024`                            | `/proc/<pid>/status`                                                         |
| 调试端口        | `sub_8a10`                            | `/proc/net/tcp`，`:5D8A`（23946）、`:69A2`（27042）                          |
| Frida 映射      | `sub_aeb8`                            | `/proc/<pid>/maps`，`frida-agent`、`frida.server`                            |
| Frida 映射/内存 | `sub_bcb4`（`sub_bd54`/`sub_c558`）   | `/proc/<pid>/maps`，匹配 `FRIDA_AGENT`（memmem 辅助：`sub_cab4`）            |
| Frida 线程      | `sub_cdb0`                            | `/proc/self/task/%s/status`，`gum-js-loop`、`gmain`                          |
| Frida 注入器    | `sub_e36c`                            | `/proc/self/fd/%s`，`linjector`                                              |
| Magisk          | `sub_eec0`                            | `/proc/<pid>/mounts`，`/sbin/.magisk/` 等                                    |
| ELF 完整性      | `sub_2914` → `sub_ff08` → `sub_111d0` | 从 maps 取 4 个库路径，逐个解析 ELF 程序头；输出 `CHECKSUM`、`No executable section found. Suspicious` |
| 隔离进程        | Java `checkPresent` + `mg_present`    | 先查 `/proc/self/mounts`，再调 native                                        |

`IsolatedService` 在 `AndroidManifest.xml` 中声明 `isolatedProcess="true"`，`checkPresent(mainPid)`
在隔离进程执行上述 Magisk 检查。命中后多数检查直接 `kill(getpid(), SIGKILL)`；`sub_9cd4` 主要累加
`dword_25088`。`sub_3e6c` 会等待首轮检查完成；若 `dword_25088 > 0` 则不加载真实 DEX。

加载后 `assistant1`/`assistant2` 各自启动 10 秒轮询的完整性看门狗，检查本库与另一个 assistant 的
内存映射/校验和，形成三方互查；详见 [libassistant1.so](libassistant1.so.md)、
[libassistant2.so](libassistant2.so.md)。

## 功能点

### 壳 APK 的 DEX 布局

壳 APK 的 `classes.dex` ZIP 条目（解压后）：

```text
+----------------------+-------------------------------+------------------+
| 壳 DEX（21216 B）     | 加密载荷（3374770 B）          | 大小 BE32（4 B）  |
+----------------------+-------------------------------+------------------+
```

### 启动与解包

```text
attachBaseContext()
  └─ isUIProcess()
       ├─ get_target() -> TargetApk.zip 是否存在 / 版本码是否变化
       ├─ 否/已变化 -> start()      : sub_bcb4 + sub_2e80 + sub_39e4 + sub_3e6c
       └─ 是       -> niceway_start(): sub_bcb4 + sub_3e6c

onCreate()
  └─ 替换 LoadedApk.mApplication / className = com.targetapk.MyApplication
     -> makeApplication() -> 真实 Application.onCreate()
     -> Java 线程每 10s 随机 checkMgN -> checkPresent(mainPid) -> kill
```

`sub_2e80` 从 `getApplicationInfo().sourceDir` 打开已安装 APK，读取 `classes.dex` 条目；
`sub_39e4` 取最后 4 字节作为 size，复制前 size 字节并交给 `sub_2b68`：

```c
plain[i] = KEY[i % 6] ^ ~cipher[size - 1 - i];   // 逆序 + 取反 + XOR
KEY = {0x5E, 0x2F, 0x97, 0xCB, 0x65, 0xB2};
```

1.5.0 还原结果与 `data/TargetApk.zip` 逐字节相同（SHA-256
`C207D75A9201CBCF88FAEA8E61AB08A9F7E5254B60D7EE4402A412CBB569CA23`）。
该密钥在已收集版本中不变。`TargetApk.zip` 是 `DexClassLoader` 用的代码归档
（`classes.dex`/`classes2.dex` 等，无 `AndroidManifest.xml`），资源与清单仍在壳 APK。

### ClassLoader 替换

`sub_3e6c` 等待首轮反调试完成（`dword_25084 >= 1`），若 `dword_25088 <= 0` 才创建
`DexClassLoader(TargetApk.zip, <dataDir>/app_assets, libPaths, parent)`，
并通过 `org.hackcode.ReflectUtils.setFieldObject("android.app.LoadedApk", "mClassLoader", loadedApk, loader)`
替换 ClassLoader。

## 引用

* `output/apktool/smali/org/hackcode/ProxyApplication.smali`：`<clinit>` 依次加载
  `klabniceway`、`assistant1`、`assistant2`；`attachBaseContext`/`onCreate` 的壳流程；
  native 方法 `start`、`niceway_start`、`get_target`、`mg_present`。
* `org.hackcode.ReflectUtils`：替换 `LoadedApk.mClassLoader`。
* `AndroidManifest.xml`：`ProxyApplication`、`IsolatedService`（`isolatedProcess="true"`）。
* [README.md](README.md)：DEX 加壳格式与解密算法。
* [libassistant1.so](libassistant1.so.md)、[libassistant2.so](libassistant2.so.md)：三方互查的另一半。

## 待探究

* [ ] `sub_4c78`（0x2EDC 字节）的分支未全部还原，仅确认包含 Frida/`linjector`/`/proc` 检查与
  `kill(getpid(), SIGKILL)`。
* [ ] ELF 完整性算法（`sub_2914` → `sub_ff08` → `sub_111d0`，以及 `sub_10940`/`sub_11ab8`）未完全还原；
  确认使用 `CHECKSUM` 标签，并在找不到可执行段时输出 `No executable section found. Suspicious`。
* [ ] `sub_7cb0` 未见调用者，初步判断是对本库 ELF 头的完整性检查，未完全还原。
* [ ] armv7 仅核对结构、字符串与导出，未逐函数分析；全部结论来自静态分析，未在真机执行。
