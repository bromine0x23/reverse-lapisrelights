# libAkSoundEngine.so

## 概要

| 项     | 值                                                                                                                                       |
|--------|------------------------------------------------------------------------------------------------------------------------------------------|
| 功能   | Audiokinetic **Wwise 2019.2.5** 音频引擎（SoundEngine）Android 运行时，含 SWIG 生成的 C# 绑定层（`CSharp_*`）；**Profile** 配置 |
| ABI    | `arm64-v8a`、`armeabi-v7a`                                                                                                               |
| 工具链 | NDK `r17c`，`GCC: (GNU) 4.9.x 20150123 (prerelease)`（`.comment`），armv7 使用 `gold 1.12`；未混淆、已 strip、未加壳                       |
| 依赖   | `libOpenSLES.so`、`libandroid.so`、`liblog.so`、`libdl.so`、`libz.so`、`libstdc++.so`、`libm.so`、`libc.so`                              |
| 使用   | `SoundManager.Initialize()` 实例化 `WwiseInitializer/WwiseGlobal`（内含 `AkInitializer`）；`AkBankManager` 加载 `SoundBanks/*.bnk`        |

数据来源：游戏 1.0.3–1.5.0 的 APK 原生库。库已 strip，下文函数名中形如
`CAkBankMgr::ProcessBankHeader` 的名称是**按 Wwise 2019.2.5 调试符号推断的名称**，其余为地址。

## 文件

| 版本            | ABI           | 大小   | SHA-256                                                            |
|-----------------|---------------|--------|--------------------------------------------------------------------|
| `1.0.3`–`1.5.0` | `arm64-v8a`   | 4239504 | `EF617CC487D79E68E5B70190C01236B96E3058B6EAA21CD2904F9ED6EDA4773F` |
| `1.0.3`–`1.5.0` | `armeabi-v7a` | 2917184 | `C77BF44857663AAF9B04ABA5A836A1A95F76803192F5ABF57A3034F6695B9006` |

7 个版本、两个 ABI 完全一致，没有任何版本升级；库也未被游戏自研壳处理
（无 `.kcniceway`、无自解密，见“加固”）。

构建配置与版本（arm64/armv7 相同）：

| 项         | 值                                                                                     |
|------------|----------------------------------------------------------------------------------------|
| Wwise 版本 | `2019.2.5`（`CSharp_GetMajorMinorVersion` = `0x07E30002`）                             |
| SDK build  | `7349`（`CSharp_GetSubminorBuildVersion` = `0x00051CB5`，subminor 5 / build 7349）      |
| Bank 版本  | `135`（`CSharp_AK_SOUNDBANK_VERSION_get`）                                              |
| 配置       | **Profile**（非 `AK_OPTIMIZED`）：保留 353 条告警串、`AKDEBUG` 日志、断言钩子与 Profiler 通信 |

Profile 与 Release 是 Wwise 的两种预编译配置：Release 会移除日志/断言字符串，并把整个 `AK::Comm`
通信模块编译掉（`InitCommunication` 退化为直接返回 `AK_NotImplemented`）。本库保留它们，
这是后文“通信/Profiler”一节成立的前提。

下文地址均为 1.5.0 `arm64-v8a` 的 RVA。

### 文件结构

以 1.5.0 `arm64-v8a` 为例（文件偏移与虚拟地址相同，`.data.rel.ro` 起偏移 `-0x10000`）：

| 节               | 地址      | 大小      | 说明                                                         |
|------------------|-----------|-----------|--------------------------------------------------------------|
| `.dynsym`        | `0x29a8`  | `0x8c28`  | 1495 个动态符号（1333 定义 / 162 导入）                      |
| `.text`          | `0x4cf60` | `0x26274c` | 引擎、SWIG 绑定、内置 Opus/Vorbis、rpmalloc、libzip           |
| `.rodata`        | `0x2af6b0`| `0xbc11a` | 353 条带完整 C++ 签名的告警串、Monitor 错误表、Bank 错误消息  |
| `.eh_frame`      | `0x37ee48`| `0x6fe68` | 异常展开表                                                   |
| `.init_array`    | `0x3ff250`| `0x718`   | 227 个构造函数（GCC 按编译单元生成）                          |
| `.fini_array`    | `0x3ff968`| `8`       | `0x4d220`                                                    |
| `.data.rel.ro`   | `0x3ff970`| `0x120f0` | vtable、插件注册节点、字符串指针表                            |
| `.data`          | `0x413000`| `0x7930`  | 全局状态（`g_pAKPluginList`=`0x4311b8` 等）                  |
| `.bss`           | `0x41a940`| `0x17c70` | 引擎状态、Bank 头异或密钥（`0x4310e0`）                       |

`e_entry = 0x4cf60`，即 `.text` 首地址（普通函数，不是加壳描述符）；`.init_array` 全部是常规静态构造，
未发现自解密或反调试。armv7 结构类似（`e_entry = 0`，保留 `.interp`、`.ARM.exidx`，`.init_array` 同为 227 项）。

## 导出

共 1495 个动态符号：1333 个定义（含 1072 个 `CSharp_*`、82 个 C++ mangled、47 个 zlib/libzip、
44 个 `opus_*_AK`、22 个 rpmalloc 系列），162 个导入（Bionic、OpenSL ES、zlib、Android Asset）。
下表只列与集成/安全相关的符号：

| 地址      | 符号                                   | 签名                                                     | 功能                                                         |
|-----------|----------------------------------------|----------------------------------------------------------|--------------------------------------------------------------|
| `0x5b0ec` | `JNI_OnLoad`                           | `jint JNI_OnLoad(JavaVM *, void *)`                      | 缓存 `JavaVM*`，返回 `JNI_VERSION_1_6`                        |
| `0x5d678` | `CSharp_AK_SOUNDBANK_VERSION_get`      | `AkUInt32(void)`                                         | 返回 `135`                                                   |
| `0x6b098` | `CSharp_GetMajorMinorVersion`          | `AkUInt32(void)`                                         | 返回 `0x07E30002`（2019.2）                                  |
| `0x6b09c` | `CSharp_GetSubminorBuildVersion`       | `AkUInt32(void)`                                         | 返回 `0x00051CB5`（subminor 5 / build 7349）                 |
| `0x62ef4` | `CSharp_LoadBank__SWIG_0`              | `int(const char *, AkBankID *)`                          | 带初始化保护的 Bank 加载入口                                 |
| `0x6ac1c` | `CSharp_Init`                          | `AkUInt32(AkInitializationSettings *)`                   | 引擎初始化（thunk 到 `0x5b650`）                             |
| `0x6ac24` | `CSharp_InitCommunication`             | `AkUInt32(AkCommunicationSettings *)`                    | 通信模块初始化（thunk 到 `0x5b894`）                         |
| `0x6ac28` | `CSharp_Term`                          | `void(void)`                                             | 引擎终止                                                     |
| `0x610a0` | `CSharp_RegisterPluginDLL__SWIG_0`     | `int(const char *, const char *)`                        | `dlopen` 动态插件                                             |
| `0x6ac40` | `CSharp_LoadFilePackage`               | `AkUInt32(const char *, AkUInt32 *)`                     | 加载 `.akpk` 文件包（游戏未使用）                            |
| `0x6ac50` | `CSharp_LoadAndDecodeBank`             | `int(const char *, ...)`                                 | 解码 Bank 到磁盘（“decoded bank”模式）                       |
| `0x65fa8` | `CSharp_StartProfilerCapture`          | `int(const AkOSChar *)`                                  | 开启 Profiler 采集（写文件）                                 |
| `0xe7eb0` | `ak_rpmalloc_thread_verify_integrity`  | `int(void)`                                              | 分配器空闲链表完整性校验                                     |
| `0x4311b8`| `g_pAKPluginList`                      | `AK::PluginRegistration *`                               | 静态插件注册链表头                                           |
| `0x264124`| `opus_get_version_string_AK`           | `const char *(void)`                                     | 内置 Opus 解码器版本                                         |
| `0x2a9890`| `zip_fopen_index_encrypted`             | `libzip` 内部                                           | 内置 libzip（支持 ZipCrypto）                                |

`.dynsym` 未删除，1072 个接口名全部可读，等于提供了完整的引擎 API 清单（见“加固”）。

### C# 绑定（CSharp_*）

Wwise 2019.2 的 Unity 集成改用 SWIG 生成绑定：C# 侧 `AkSoundEnginePINVOKE` 逐个 P/Invoke 到
`CSharp_<API>__SWIG_n`。本库中 1072 个 `CSharp_*` 即这套绑定，覆盖 `AkSoundEngine`、`AkBankManager`、
`AkCallbackManager`、`AkCommunicationSettings`、`AkInitSettings` 等全部托管接口。

每个包装函数都有同一个“初始化顺序保护”：

```c
if (g_bSoundEngineInitialized /* byte_430FD8 */) {
    return real_api(...);
}
__android_log_print(4, "AKDEBUG",
    "Wwise warning in AK::SoundEngine::LoadBank(...): "
    "AkInitializer.cs Awake() was not executed yet. "
    "Set the Script Execution Order properly so the current call is executed after.");
return 2;            /* AK_Fail */
```

`byte_430FD8` 由引擎初始化函数 `AK::SoundEngine::Init`（`0x112504`，`0x112774`）成功后置 1，
由 `0x10c1a8`（`Term`/初始化失败清理路径）清零。因此“Awake 未执行”实际等价于“引擎未成功初始化”：
未初始化时调用返回 `AK_Fail`（`2`）而不是崩溃。353 条这样的字符串（每个被包装的 API 重载一条），
Release 配置中全部被编译掉。

### JNI

| 地址      | 方法                            | 说明                                                                 |
|-----------|---------------------------------|----------------------------------------------------------------------|
| `0x5b0ec` | `JNI_OnLoad`                    | 仅把 `JavaVM*` 存入全局 `0x41b3f0` 并返回 `0x10006`，不注册 native 方法 |
| —         | `AAssetManager_fromJava`（导入） | 由 `RegisterPluginDLL` 经 JNI 查询 `Activity.getApplicationInfo()` 使用 |

## 加固

没有自研壳、自解密、反调试或完整性校验；仅为常规 ELF 加固，且**未**被游戏的 `.kcniceway` 壳覆盖：

* `PT_GNU_RELRO` + `DF_1_NOW` → Full RELRO；`PT_GNU_STACK` 无 `PF_X` → NX；导入 `__stack_chk_fail`（栈保护）、
  `__FD_SET_chk`（FORTIFY）；无 `DT_RPATH`/`DT_RUNPATH`；无 AArch64 BTI/PAC 属性。
* 已 strip（无 `.symtab`），但 `.dynsym` 完整保留 1072 个 `CSharp_*` 接口名。
* 与 `libtolua.so`、`libLapis.so`、`libklabniceway.so` 不同：本库没有 `.kcniceway` 段，
  `e_entry` 指向 `.text` 首地址而非解密描述符，`.init_array` 中无解密代码。
* 本次分析未发现 `ptrace`、`/proc/self/status`、`frida`、`magisk`、`xposed`、`procinfo` 等反分析痕迹；
  库内唯一的 `/proc` 引用是 `/proc/meminfo`，由 `ak_rpmalloc_initialize_config` 读取用于分配器初始化。
* **弱点（信息暴露）**：Profile 构建保留 353 条带完整参数列表的 C++ 签名告警串与 1072 个接口符号名；
  断言钩子的格式串 `AKASSERT: %s. File: %s, line: %d` 还会输出源文件名与行号。引擎内部结构因此
  几乎无需逆向即可还原（Release 配置会把这些日志串与大部分断言调用点编译掉）。

## 功能点

### SoundBank 加载与校验

`LoadBank` 系列（文件名、BankID、MemoryView、MemoryCopy）最终进入 Bank 解析器。以 1.5.0 arm64 为例，
`0x1246fc` 是 Bank 文件读取主循环，`0x11f060`（调试符号对应 `CAkBankMgr::ProcessBankHeader`）解析 BKHD：

1. 读 8 字节块头，要求前 4 字节等于 `'BKHD'`（小端 `0x44484B42`），否则返回 `7`（`AK_InvalidFile`）。
2. 读 20 字节 Bank 头并做版本判定：

   ```text
   version == 135 (0x87)      → 接受
   118 <= version <= 134      → 接受，并置“旧版本”标志（后续按旧布局处理）
   其他（<118 或 >135）        → 返回 64（AK_WrongBankVersion），
                                上报 “Load bank failed : incompatible bank version ...”
   ```

3. 之后按块循环处理 `BKHD`/`STMG`/`HIRC`/`STID`/`DATA`/`PLAT`/`ENVS`/`INIT`/`DIDX`；
   未知块按声明长度整块跳过，若实际读取长度与声明不符则返回 `7`（截断检测）。

只做**结构合法性**校验，没有签名、摘要或来源认证：任何满足上述条件的 `.bnk` 都能加载。
游戏资源侧 1040 个 `.bnk` 全部是明文 `BKHD`+`DIDX`+`DATA`+`HIRC`、版本 135，`DATA` 内 WEM 为明文 RIFF，
不含 `.akpk`，因此 Bank 加密特性未被使用（也解释了资源可直接提取）。

### Bank 头异或（内建“加密”，未启用）

`0x11f060` 在版本判定前有一段可选的头异或：

```c
/* dword_4310E0..4310EC 为 16 字节密钥，位于 .bss */
if (key_present /* dword_4310E0 != 0 */) {
    hdr[0..3]   ^= key[0..3];
    hdr[4..7]   ^= key[4..7];
    hdr[8..11]  ^= key[8..11];
    hdr[12..13] ^= key[12..13];
    hdr[14..15] ^= key[14..15];
}
```

只覆盖 BKHD 前 16 字节（版本、BankID、语言 ID、反馈标志），最后 4 字节（`dwProjectID`）不参与。
该密钥全局在 `.bss`，**游戏库中没有任何写入点**，
因此恒为 0，异或分支永不执行——这是一条**未被使用**的引擎能力，不是本作的保护手段。

### 初始化顺序保护与断言

* `CSharp_Init_0`（`0x5b650`）依次创建内存管理器、Stream Manager、Android 输出、SoundEngine、
  Music Engine；失败时输出 `Cannot create the memory manager.` / `Cannot initialize sound engine.` 等。
* 初始化时把 `AkInitSettings` 内的一个函数指针（偏移 `+0x50`，按 Wwise 布局为断言钩子 `pfnAssertHook`）
  指向 `0x5aa04`：只格式化
  `AKASSERT: <expr>. File: <file>, line: <n>` 并交给 Monitor/回调序列化器输出（logcat tag `AKDEBUG`），
  **不会 abort**。即畸形数据触发断言时表现为错误日志，不会直接杀进程。
* `CSharp_Term_0` 在未初始化时只输出 `Term() called before successful initialization.`。

### 通信 / Profiler 模块（AK::Comm）

这是本库最值得注意的**攻击面**，且只有 Profile/Debug 配置才包含（Release 配置下整个模块被编译掉）：

* 导入 `socket`/`bind`/`listen`/`accept`/`select`/`sendto`/`recvfrom`/`gethostname`/`inet_addr` 等；
  Release 配置下没有这些导入。
* `AK::Comm::GetDefaultInitSettings`（`0xf7cac`）默认值：发现广播端口 **24024**、命令端口 **0**、
  通知端口 **0**、`bInitSystemLib = 1`、`szAppNetworkName = "Unspecified"`。
* `AK::Comm::Init`（`0xf7da4`）校验：发现端口为 0 或三个端口互相重复时返回 `31`
  （`AK_InvalidParameter`）；命令/通知端口为 0 **不算错误**。
* `AK::Comm::Start`（`0xf82b8`）无条件依次启动：`Network::Init` → 发现通道
  （UDP，`0xf86dc`，失败时打印 `DiscoveryChannel::Init() -> m_socket.Bind() failed...`）→
  命令通道与通知通道（`0xfa5d8`，直接 `bind()` 后 `listen()`；没有“端口为 0 即跳过”的分支，
  因此按 POSIX 语义会绑定到内核分配的临时端口——推断，待真机确认）。
* `CSharp_InitCommunication_0`（`0x5b894`）把托管 `AkCommunicationSettings` 逐字段拷入 C 结构后调用
  `AK::Comm::Init`，失败输出 `Cannot initialize Wwise communication.`。
* `AK::Comm::Init/Term/GetCurrentSettings` 等以 **default 可见性动态符号**导出（`_ZN2AK4Comm*`），
  进程内任意代码都可用 `dlsym` 直接启停通信模块；Release 配置中这些符号不存在。

游戏侧确实启用了它：

* AssetBundle `assets/.../resources/wwiseinitializer.bdl` 内的 `AkWwiseInitializationSettings`（Android 平台）：
  `BasePath=SoundBanks`、`StartupLanguage=Japanese (JP)`、`SampleRate=48000`、`SamplesPerFrame=1024`、
  `MonitorQueuePoolSize=65536`、`DebugOutOfRangeCheckEnabled=0`；
  `CommsSettings`：`PoolSize=262144`、`DiscoveryBroadcastPort=24024`、`CommandPort=0`、
  `NotificationPort=0`、`InitializeSystemComms=1`、`NetworkName=""`。
* `AkWwiseInitializationSettings.InitializeSoundEngine()`（IL2CPP `0x1cbe500`）在 `AkSoundEngine.Init`
  成功后**无条件**调用 `AkSoundEngine.InitCommunication`（`0x1cbe708`，目标 `0x15ae654`）。

结论：运行时至少会绑定 UDP/24024 的 Wwise 发现广播套接字，并按配置为命令/通知通道调用 `bind(0)`
（系统分配临时 TCP 端口，推断）。配置值为 0，Wwise Authoring 无法从配置得知端口，实际可利用性低；
但这是随包发布的调试/Profiler 通道，属于不必要的局域网暴露面（Release 配置下该路径为空实现，
`CSharp_InitCommunication` 直接返回 `AK_NotImplemented`）。

### 动态插件加载

`CSharp_RegisterPluginDLL`（`0x610a0` → `0x1ec7cc`）按以下顺序解析路径并加载：

```text
路径为空时：JNI 取 Activity.getApplicationInfo().nativeLibraryDir
           → 拼接 nativeLibraryDir + "/lib" + <name> + ".so"
然后：dlopen(path, RTLD_NOW) → dlsym(handle, "g_pAKPluginList") → 注册插件
      dlsym 失败：log "Plugin DLL does not have g_pAKPluginList symbol exported..."，返回 7
      dlopen 失败：log dlerror()，返回 66
```

即引擎允许在运行时 `dlopen` 任意 `.so` 并注册其中的插件表；本作 APK 未打包任何 Wwise 插件库，
因此该接口即便被调用也没有可加载的插件。

### 内建插件静态注册表

`.init_array` 中 19 个构造函数把 `AK::PluginRegistration` 节点压入 `g_pAKPluginList`
（节点 `0x70` 字节，关键字段：`+0 next`、`+8 type`、`+0xC company`、`+0x10 pluginID`、
`+0x18 create`、`+0x20 createParam`）。游戏库注册内容：

| 类型         | 插件 ID → 名称（名称按 Wwise 2019.2.5 调试符号推断）                                                     |
|--------------|-----------------------------------------------------------------------------------------------------------|
| Codec (`1`)  | 4 = Vorbis；19/20 = Opus（WEM / Ogg 两个变体）                                                            |
| Source (`2`) | 100 = Sine；101 = Silence；102 = Tone Generator；200 = Audio Input                                        |
| Effect (`3`) | 105 = Parametric EQ、106 = Delay、108 = Compressor、109 = Expander、110 = Peak Limiter、115 = Matrix Reverb、118 = RoomVerb、125 = Flanger、129 = Meter、138 = Harmonizer、139 = Gain、171 = Reflect |
| Sink (`7`)   | 174、181（名称未确认）                                                                                     |

`company` 均为 0（Audiokinetic）。Wwise 2019.2.5 还把一批效果/源作为**可选动态插件**单独发布
（Guitar Distortion、Pitch Shifter、Recorder、Stereo Delay、Time Stretch、Tremolo、Synth One、
Convolution Reverb、SoundSeed、Auro、iZotope、McDSP 等），这些 ID 不在静态表中；
本作 APK 未打包任何插件库，因此相应效果在运行时不注册。

### 内存分配与日志

* 内置 **rpmalloc** 作为 SoundEngine 的内存分配器，导出 `ak_rpmalloc*`/`ak_rpaligned_*` 系列；
  `ak_rpmalloc_thread_verify_integrity`（`0xe7eb0`）校验线程缓存/空闲链表完整性，可发现堆破坏。
* 所有调试点输出走 `__android_log_print(4, "AKDEBUG", ...)`（INFO 级），tag 固定为 `AKDEBUG`；
  Release 配置中该 tag 与 353 条告警串全部不存在。
* Monitor 错误通过 `AkCallbackManager.SetMonitoringCallback` 回到 C#（`SoundManager` 注册了
  `ErrorLevel_All`）。

## 引用

* `Scripts/Assembly-CSharp/Oz/Framework/SoundModule/SoundManager.cs`：`Initialize()` 加载
  `WwiseInitializer/WwiseGlobal`、注册 `AkCallbackManager.SetMonitoringCallback(ErrorLevel_All, ...)`；
  `LoadBank()`/`LoadBankAsync()`/`UnloadBank()` 转调 `AkBankManager`。
* `Scripts/Assembly-CSharp/Oz/Framework/Launcher.cs`：退出时 `AkSoundEngine.Term()`。
* `Scripts/Assembly-CSharp/EditorEnviroment.cs`：编辑器环境下给对象补 `AkInitializer`。
* `Scripts/Stubs/WwiseStubs.cs`、`Scripts/Assembly-CSharp/AssemblyCSharpStubs.cs`：`AkInitializer`、
  `AkSoundEngine`、`AkCallbackManager` 等桩声明（Wwise 托管层本身未还原，见 `UNRESTORED-global.txt`）。
* AssetBundle `assets/asset-latest/AssetBundles/assets/products/resources/wwiseinitializer.bdl`：
  `AkInitializer` 预制体与 `AkWwiseInitializationSettings` 多平台配置。
* `assets/asset-latest/SoundBanks/`：1040 个 `.bnk`（`Japanese (JP)` 语言目录），版本 135、明文。
* [APK.md](APK.md)：原生库清单与加固总览；[libexample.so.md](libexample.so.md)：本文档模板。

## 待探究

* [ ] Sink 类型插件 ID 174/181 的具体名称与用途。
* [ ] 游戏 Bank 是否引用了仅以动态插件形式提供的效果（若引用，该效果在真机上会静默失效）。
* [ ] 命令/通知端口配置为 0 时，运行时实际绑定的临时 TCP 端口是否会被 Wwise 发现应答暴露；
      需真机抓包确认（关系到局域网内是否可被 Wwise Authoring 连接）。
* [ ] `AkWwiseInitializationSettings.AdvancedSettings.m_EngineLogging` 的具体映射（是否等价于
      `pfnAssertHook`/Monitor 级别）。
* [ ] Bank 版本 118–134 的兼容读取路径（“旧版本”标志）未逐分支验证，未确认是否会绕过后续校验。
* [ ] armv7 仅静态核对了导出、版本常量、`.comment` 与初始化表，未逐函数分析。
