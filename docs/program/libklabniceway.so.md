# libklabniceway.so

## 概览

| 项       | 值                                                                                                      |
|----------|---------------------------------------------------------------------------------------------------------|
| 作用     | DEX 壳：解包 `classes.dex` 尾部载荷、替换 `LoadedApk.mClassLoader`；反调试/反 Magisk                    |
| Java 壳  | `org.hackcode.ProxyApplication`（壳 APK 的 `classes.dex`）                                              |
| 加载     | `ProxyApplication.<clinit>` 调 `System.loadLibrary("klabniceway")`，同时加载 `assistant1`、`assistant2` |
| 游戏版本 | `com.klab.lapis` 1.5.0（versionCode 699，minSdk 21，targetSdk 31）                                      |
| 架构     | `arm64-v8a`、`armeabi-v7a`                                                                              |
| 编译器   | `Obfuscator-LLVM clang 4.0.1`，NDK `r16b`；`.comment` 另有 `GCC 4.9.x 20150123`                         |
| 依赖     | `liblog.so` `libc.so` `libm.so` `libstdc++.so` `libdl.so`                                               |
| 导出     | `JNI_OnLoad`、`JNI_OnUnload`；通过 `RegisterNatives` 注册 4 个 native 方法                              |

代码特征：控制流平坦化、字符串单字节 XOR（常用 key：`0x31`、`0x3C`、`0x3D`、`0x58`、`0x29`、`0x23`、`0x09`）。下文地址均为 **1.5.0
arm64** 的 RVA。

## 版本一致性

1.5.0 原始文件：

| ABI           | 大小   | SHA-256                                                            |
|---------------|--------|--------------------------------------------------------------------|
| `arm64-v8a`   | 156688 | `B87D933AD365EC78FE7D5D63696122C9E5781E8093C61E70B85FE964BD99A2C6` |
| `armeabi-v7a` | 78864  | `950544F00D484C32D13F71C7506CC88EF7AE52EC02834B7641F3CD285DE7A923` |

`libklabniceway.decrytped.so`（1.5.0 arm64，自解密后）：`0537F92D1FA30C01648718381AFF0954C4C9EE438E57F9A53F751726433F2033`。

每个版本都会重新构建/重新混淆，`.text`、`.kcniceway` 的代码字节不同；`.rodata`（字符串表、类名、签名）与 `.comment` 稳定，DEX
解密密钥也不变。

### 显著特例

* **1.3.0 arm64**：160784 字节（其余 arm64 版本 156688）；`e_entry = 0x27010`（其余 `0x26010`），描述符与 `.kcniceway`
  整体后移，功能无变化。
* **1.4.0 armv7**：`key % 9 == 0`，`.kcniceway` 全部字节取反，而非只取反每 `key % 9` 字节。

## 文件结构

1.5.0 arm64：

| 节            | 地址      | 大小     | 说明                                       |
|---------------|-----------|----------|--------------------------------------------|
| `.text`       | `0x1310`  | `0x1858` | `JNI_OnLoad`/`JNI_OnUnload`、PLT、工具函数 |
| `.kcniceway`  | `0x2b68`  | `0xff50` | 被加壳的核心代码                           |
| `.rodata`     | `0x12ab8` | `0xb83`  | 字符串、类名、JNI 签名                     |
| `.b5a75776d1` | `0x26010` | `0x3e8`  | 加壳描述符，`e_entry` 指向此处             |
| `.init_array` | `0x24c58` | `0x10`   | `[0] = _INIT_0`（`0x134c`，自解密）        |
| `.fini_array` | `0x24c68` | `0x10`   | `[0] = _FINI_0`（`0x1310`，`__cxa_finalize`） |

`e_entry` 指向描述符而不是代码，反汇编器会误认成 `start`。armv7 1.5.0 对应 `e_entry = 0x13010`，
`.kcniceway = 0x4074..0xF824`。

## 自解密

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

mprotect 失败时输出 `mem privilege change failed` / `The second mem privilege change failed`（tag `JNITag` / `JNI_TAG`
）。1.5.0 参数：

| ABI   | `e_entry` | `address` | `length`  | `key`        | `key % 9` |
|-------|-----------|-----------|-----------|--------------|-----------|
| arm64 | `0x26010` | `0x2b68`  | `0x0FF50` | `0x28C9D4E5` | 4         |
| armv7 | `0x13010` | `0x4074`  | `0x0B7B0` | `0x69B99EE5` | 2         |

1.5.0 arm64 共 16340 字节被取反（`0xff50 / 4`）。
其他版本按各自 `e_entry` 读取同一 12 字节描述符；特例见上。

## JNI 与 native 方法

`JNI_OnLoad`（`0x1358`）：`GetEnv(JNI_VERSION_1_4)`；`FindClass("org/hackcode/ProxyApplication")` 后 `RegisterNatives`；
读 `ro.build.version.sdk` 存入 `dword_250B4`；返回 `0x10004`。

| Java 方法       | 签名                                                                              | 地址                | 说明                                      |
|-----------------|-----------------------------------------------------------------------------------|---------------------|-------------------------------------------|
| `start`         | `void start(Application app, String str, ClassLoader loader, Object obj)`         | `0x4510`            | 首次解包并安装 DEX                        |
| `niceway_start` | `void niceway_start(Application app, String str, ClassLoader loader, Object obj)` | `0x4870`            | 已解包，直接安装 DEX                      |
| `get_target`    | `String get_target(Application app)`                                              | `0x4ae4` → `0x4190` | 返回 `<dataDir>/app_assets/TargetApk.zip` |
| `mg_present`    | `boolean mg_present(int pid)`                                                     | `0x4ae8`            | Magisk/Frida 检测（隔离进程调用）         |

`start`/`niceway_start` 在 `JNIEnv *` 后的第一个参数是 `ProxyApplication` 实例（`this`），
`sub_2e80` 直接对它调用 `getApplicationInfo()`。

## 启动与 DEX 解包

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

壳 APK 的 `classes.dex` ZIP 条目（解压后）：

```text
+----------------------+-------------------------------+------------------+
| 壳 DEX（21216 B）     | 加密载荷（3374770 B）          | 大小 BE32（4 B）  |
+----------------------+-------------------------------+------------------+
```

`sub_2e80` 从 `getApplicationInfo().sourceDir` 打开已安装 APK，读取 `classes.dex` 条目；`sub_39e4` 取最后 4 字节作为
size，复制前 size 字节并交给 `sub_2b68`：

```c
plain[i] = KEY[i % 6] ^ ~cipher[size - 1 - i];   // 逆序 + 取反 + XOR
KEY = {0x5E, 0x2F, 0x97, 0xCB, 0x65, 0xB2};
```

1.5.0 还原结果与 `data/TargetApk.zip` 逐字节相同（SHA-256
`C207D75A9201CBCF88FAEA8E61AB08A9F7E5254B60D7EE4402A412CBB569CA23`）。
该密钥在已收集版本中不变。`TargetApk.zip` 是 `DexClassLoader` 用的代码归档（`classes.dex`/`classes2.dex` 等，无
`AndroidManifest.xml`），资源与清单仍在壳 APK。

`sub_3e6c` 等待首轮反调试完成（`dword_25084 >= 1`），若 `dword_25088 <= 0` 才创建
`DexClassLoader(TargetApk.zip, <dataDir>/app_assets, libPaths, parent)`，
并通过 `org.hackcode.ReflectUtils.setFieldObject("android.app.LoadedApk", "mClassLoader", loadedApk, loader)` 替换
ClassLoader。

## 反调试与反篡改

`sub_bcb4` 在 `start`/`niceway_start` 开头调用：`ptrace(PTRACE_TRACEME, 0, 0, 0)`、`sub_2914()` 完整性准备、然后创建两个
pthread：`sub_7b54`（周期轮询）与 `sub_4c78`（大型检查）。`sub_bd54`/`sub_c558` 负责 `/proc` maps 扫描，`sub_cab4` 为 memmem 辅助。

| 检测项          | 函数                                  | 实现                                                                                                                     |
|-----------------|---------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| `ptrace`        | `sub_bcb4`                            | `PTRACE_TRACEME`                                                                                                         |
| Java 调试器     | `sub_9cd4`                            | `android/os/Debug.isDebuggerConnected()`                                                                                 |
| `TracerPid`     | `sub_a024`                            | `/proc/<pid>/status`                                                                                                     |
| 调试端口        | `sub_8a10`                            | `/proc/net/tcp`，`:5D8A`（23946）、`:69A2`（27042）                                                                      |
| Frida 映射      | `sub_aeb8`                            | `/proc/<pid>/maps`，`frida-agent`、`frida.server`                                                                        |
| Frida 映射/内存 | `sub_bcb4`（`sub_bd54`/`sub_c558`）   | `/proc/<pid>/maps`，匹配 `FRIDA_AGENT`（memmem 辅助：`sub_cab4`）                                                        |
| Frida 线程      | `sub_cdb0`                            | `/proc/self/task/%s/status`，`gum-js-loop`、`gmain`                                                                      |
| Frida 注入器    | `sub_e36c`                            | `/proc/self/fd/%s`，`linjector`                                                                                          |
| Magisk          | `sub_eec0`                            | `/proc/<pid>/mounts`，`/sbin/.magisk/` 等                                                                                |
| ELF 完整性      | `sub_2914` → `sub_ff08` → `sub_111d0` | `sub_ff08` 从 maps 取 4 个库路径，`sub_111d0` 逐个解析 ELF 程序头；`CHECKSUM`、`No executable section found. Suspicious` |
| 隔离进程        | Java `checkPresent` + `mg_present`    | 先查 `/proc/self/mounts`，再调 native                                                                                    |

`IsolatedService` 在 `AndroidManifest.xml` 中声明 `isolatedProcess="true"`，`checkPresent(mainPid)` 在隔离进程执行上述
Magisk 检查。命中后多数检查直接 `kill(getpid(), SIGKILL)`；`sub_9cd4` 主要累加 `dword_25088`。`sub_3e6c` 会等待首轮检查完成；若
`dword_25088 > 0` 则不加载真实 DEX。

加载后 `assistant1`/`assistant2` 各自启动 10 秒轮询的完整性看门狗，检查本库与另一个 assistant 的内存映射/校验和，形成三方互查；
详见 [libassistant1.so](libassistant1.so.md)、[libassistant2.so](libassistant2.so.md)。

## 未确定

* `sub_4c78`（0x2EDC 字节）的分支未全部还原，仅确认包含 Frida/`linjector`/`/proc` 检查与 `kill(getpid(), SIGKILL)`。
* ELF 完整性算法（`sub_2914` → `sub_ff08` → `sub_111d0`，以及 `sub_10940`/`sub_11ab8`）未完全还原；
  确认使用 `CHECKSUM` 标签，并在找不到可执行段时输出 `No executable section found. Suspicious`。
* `sub_7cb0` 未见调用者，初步判断是对本库 ELF 头的完整性检查，未完全还原。
* 全部结论来自静态分析，未在真机执行。
