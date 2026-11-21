# libil2cpp.so

## 概要

| 项     | 值                                                                                     |
|--------|----------------------------------------------------------------------------------------|
| 作用   | Unity IL2CPP 运行时：托管程序集的 AOT 编译结果、元数据装载与运行时服务                 |
| ABI    | `arm64-v8a`（主分析目标）、`armeabi-v7a`                                               |
| 工具链 | NDK `r19`（`.note.android.ident`）、clang 8.0.2；`.comment` 另含 `GCC 4.9.x 20150123`  |
| 依赖   | `liblog.so` `libm.so` `libdl.so` `libc.so`（不以 `DT_NEEDED` 依赖 `libunity.so`） |
| 使用   | `libunity.so` 加载并通过 229 个 `il2cpp_*` 导出驱动；无 `JNI_OnLoad`、无 `Java_*`       |
| 元数据 | 1.3.0+ 为加密的 `game.dat`，由 [libUnityPlugin.so](#引用) 解密；1.0.3–1.2.0 为明文 `global-metadata.dat` |

Unity `2019.4.26f1c1`（`.rodata` 含 `Unity IL2CPP (Jan  7 2022 00:53:26)` 与
`/Applications/Unity/2019.4.26f1c1/…`），IL2CPP 元数据版本 **24**。

## 文件

| 版本          | ABI           | 大小       | SHA-256                                                            |
|---------------|---------------|------------|--------------------------------------------------------------------|
| 1.0.3 / 1.0.4 | `arm64-v8a`   | 68,032,864 | `60B94B1DD6E241B453B8A5D7D984FE95B6C7CA658DAAFAD239C7A6601A27693C` |
| 1.0.3 / 1.0.4 | `armeabi-v7a` | 54,968,268 | `89749AB01255FEB5635DFB69FF2E9BC89E6FABB0C82854CDB0730576817F21BA` |
| 1.1.0         | `arm64-v8a`   | 68,090,224 | `B76FCA79BC71558670B624481F026040C76DEDC3B8CA05C464B93F684BA2E286` |
| 1.1.0         | `armeabi-v7a` | 54,972,584 | `A8416F0CFA2F56D710446AB859FE3DF93DADCA35F9E6237D7BFAD64392CA8818` |
| 1.2.0         | `arm64-v8a`   | 68,164,408 | `88C1E960CCD158CD596D40BB828590BA9D9AB9195B6DB7A8EA27ABC78FB45E7E` |
| 1.2.0         | `armeabi-v7a` | 54,984,928 | `B4927B506350BE85FB06782B448A8D86ABEE56703B27056279A467784D5E5911` |
| 1.3.0         | `arm64-v8a`   | 68,882,496 | `3532669FFDAD214FE036543E6C23BCAEA79B37BC5EC56B017F6180B847A852EF` |
| 1.3.0         | `armeabi-v7a` | 55,555,420 | `6C2751E67B42FDD8EB053EDAD65C1FD935E071B60E6751D07B6646A32B7F0ED4` |
| 1.4.0         | `arm64-v8a`   | 68,915,376 | `C586788CAE3D82CFD8EE405DAD921379B0DC9F02B6D2066F04AD5678590871B8` |
| 1.4.0         | `armeabi-v7a` | 55,563,804 | `C762E82AAAC41DDD96513896E76F4858F670F4C9863A757890031B1BEA08D7D2` |
| 1.5.0         | `arm64-v8a`   | 69,005,904 | `65BFAEFD31D580919924CB474EB7AF7AD5CE96BD1D0EEAAB3C2E459B017508D2` |
| 1.5.0         | `armeabi-v7a` | 55,628,352 | `30BCC59FCF3B4D7DE92FCAD331819B3C50EB7C690E32A48D8882D4DA20916C2B` |

1.0.3 与 1.0.4 的文件完全相同。各版本均重新编译，地址与大小随托管代码增长；结构与加固特性一致。

### 文件结构

1.5.0 `arm64-v8a`（地址为 RVA）：

| 节 / 项目        | 地址        | 大小        | 说明                                              |
|------------------|-------------|-------------|---------------------------------------------------|
| `.text`          | `0xE7EA60`  | `0x449D20`  | C++ 运行库、icall、工具函数                       |
| `il2cpp`         | `0x12C8780` | `0x1C25E4C` | IL2CPP 生成代码（`SHT_PROGBITS`，可执行）         |
| `.rodata`        | `0x2EEE5D0` | `0x3ED23D`  | 字符串、常量、异常表                              |
| `.data.rel.ro`   | `0x3BA20F0` | `0x31FC48`  | 元数据用法表、vtable                              |
| `.got`           | `0x3EC1F18` | `0xFF500`   | 可写 GOT（无 `BIND_NOW`）                         |
| `.data`          | `0x3FC2530` | `0x21C3C0`  | 全局数据                                          |
| `.bss`           | `0x41DE900` | `0x2B4560`  | 运行时状态                                        |
| `.init_array`    | `0x3BA2098` | `0x48`      | 9 个构造（C++ 运行库/静态对象）                   |
| `.fini_array`    | `0x3BA20E0` | `0x10`      | 2 个析构                                          |
| `.gnu_debuglink` | —           | `0x18`      | `libil2cpp.sym.so`（符号文件未随包提供）          |

`il2cpp` 是 Unity 链接脚本划出的生成代码段，不是加壳段。与
[libLapis.so](libLapis.so.md)、[libklabniceway.so](libklabniceway.so.md) 不同，本库**没有**自解密 descriptor：
`e_entry = 0xE7EA60` 直接指向 `.text` 起始，`.text`/`il2cpp` 均为明文合法代码，`dlopen` 后即可反汇编。

`armeabi-v7a` 的差异：`e_entry = 0`；`.text` 从 `0x4F3C28` 开始、`il2cpp` 在 `0x916860`；存在 `PT_GNU_RELRO`
与 `.ARM.exidx`/`.ARM.attributes`；同样有 9 个 `.init_array` 构造。

## 导出

`dynsym` 共 2199 个导出，其中 229 个为 `il2cpp_*` 运行时 API，其余为静态链接的 libc++/libc++abi 与 Unity 插件
（如 `UnityAdsEngine*`）。没有 `JNI_OnLoad`，也没有 `Java_*`，Java 侧不直接调用本库。

| 地址       | 符号                        | 签名                                                                      | 说明               |
|------------|-----------------------------|---------------------------------------------------------------------------|--------------------|
| `0x103B464` | `il2cpp_init`               | `void il2cpp_init(const char *domain_name)`                               | 运行时初始化入口   |
| `0x103B49C` | `il2cpp_init_utf16`         | `int il2cpp_init_utf16(const Il2CppChar *domain_name)`                    | UTF-16 域初始化    |
| `0x103B534` | `il2cpp_set_data_dir`       | `void il2cpp_set_data_dir(const char *path)`                              | 设置资源目录       |
| `0x103B5CC` | `il2cpp_class_from_name`    | `Il2CppClass *il2cpp_class_from_name(const Il2CppImage *, const char *, const char *)` | 类型查找 |
| `0x103BBC0` | `il2cpp_domain_get`         | `Il2CppDomain *il2cpp_domain_get(void)`                                   | 当前域             |
| `0x103BF2C` | `il2cpp_runtime_invoke`     | `Il2CppObject *il2cpp_runtime_invoke(const MethodInfo *, void *, void **, Il2CppException **)` | 反射调用 |
| `0x103BF78` | `il2cpp_thread_attach`      | `Il2CppThread *il2cpp_thread_attach(Il2CppDomain *)`                      | 线程附着           |
| `0x103B694` | `il2cpp_stats_dump_to_file` | `void il2cpp_stats_dump_to_file(const char *path)`                        | 统计导出           |

完整的 `il2cpp_*` 导出面便于外部（包括注入工具）按名解析并 Hook，见「加固」中的薄弱点。

## 加固

| 机制                | arm64-v8a            | armeabi-v7a          | 说明                                                         |
|---------------------|----------------------|----------------------|--------------------------------------------------------------|
| 代码加壳 / 自解密   | 无                   | 无                   | `.text`、`il2cpp` 明文；`.init_array` 仅运行库构造           |
| 元数据加密          | 有                   | 有                   | `game.dat` + `libUnityPlugin.so`（RC4 + 字符串差分编码）     |
| 托管层反作弊        | 有（ACTk）           | 有                   | 实际启动 `SpeedHackDetector`；其余检测器仅存在类型           |
| 数值混淆            | 有（可选）           | 有                   | `ObscuredTypes`，经 tolua 暴露给 Lua                         |
| 外部完整性校验      | 有                   | 有                   | 启动时 `libklabniceway.so` 校验本库可执行段；`libjackpot-core.so` 摘要上送 |
| NX                  | 有                   | 有                   | `PT_GNU_STACK` 无 `PF_X`                                     |
| Stack canary        | 有                   | 有                   | 导入 `__stack_chk_fail`                                      |
| FORTIFY             | 有（`__FD_SET_chk`） | 未检出               | 仅说明部分代码使用                                           |
| RELRO               | **无**               | 部分                 | arm64 无 `PT_GNU_RELRO`；armv7 有 RELRO 但无 `BIND_NOW`      |
| `BIND_NOW`          | 无                   | 无                   | `.got` 可写                                                  |
| PAC / BTI           | 无                   | —                    | 无 `.note.gnu.property`                                      |
| strip               | 是                   | 是                   | 无 `.symtab`，仅保留 `.dynsym`                               |
| 原生反调试          | 无                   | 无                   | 无 `ptrace`/`TracerPid`/`frida` 等字符串与导入               |

### 元数据加密

元数据保护由三部分组成：加密容器 `game.dat`、解密插件 `libUnityPlugin.so`、以及对 Unity 运行时
`MetadataCache::Initialize` 的改造。

```text
libil2cpp  MetadataCache::Initialize (0x106E8CC)
  └─ sub_106E830
       ├─ dlopen("libUnityPlugin.so") / dlsym("query_call_back")
       ├─ query_call_back(107) ──> il2cpp_get_global_metadata   （读 + 解密整块元数据）
       └─ query_call_back(108) ──> il2cpp_get_string            （逐条名称解密）
  └─ sub_106F060("Metadata/game.dat")
       └─ 107 回调返回明文 global-metadata.dat 缓冲区
  └─ 对元数据各表中的每条名称：
       il2cpp_get_string(名称地址, 字符串池内偏移)
```

若插件缺失、`game.dat` 不存在或读取失败，则回退到明文 `Metadata/global-metadata.dat`，并清空名称解密回调
（`off_41F6498 = 0`）。1.0.3–1.2.0 走的就是这条回退路径。

`game.dat` 是「记录链 + 定长记录头」容器（记录头 0x10 字节：`magic`、`value`、8 字节填充，数据紧随其后）：

```text
1.5.0（11,748,252 字节）
0x00  5D FF 27 4C  10 00 00 00  <8B 填充>        记录 0，value=0x10
0x20  14 E8 7F 56  04 00 00 00  <8B 填充>        密钥记录，value=密钥长度
0x30  7C 42 A8 10                                RC4 密钥（4 字节）
0x34  88 F0 FA BC  58 43 B3 00  <8B 填充>        size 记录，value=密文长度
0x44  密文（0xB34358 字节）
```

| 版本  | `game.dat` 大小 | 明文长度（= size） | `step`（密钥长度） | 密钥       |
|-------|-----------------|--------------------|--------------------|------------|
| 1.3.0 | 11,729,324      | `0xB2F968`         | 4                  | `10DCCBC7` |
| 1.4.0 | 11,732,172      | `0xB30488`         | 4                  | `4EA537A2` |
| 1.5.0 | 11,748,252      | `0xB34358`         | 4                  | `7C42A810` |

解密与字符串还原算法见「功能点」。加密只覆盖元数据，不覆盖 `.text`；且 RC4 密钥以明文放在容器头内。

### 托管层反作弊

`libil2cpp.so` 内包含完整 [Anti-Cheat Toolkit](https://codestage.net/)（ACTk）类型：

| 检测器                     | 状态                                                                 |
|----------------------------|----------------------------------------------------------------------|
| `SpeedHackDetector`        | **已启用**：`Oz.Framework.Launcher.Start` 调 `StartDetection(OnSpeedHackDetected)` |
| `InjectionDetector`        | 仅类型存在；IL2CPP 上会输出「not supported on current platform」     |
| `ObscuredCheatingDetector` | 仅类型存在，未找到调用点                                             |
| `TimeCheatingDetector`     | 仅类型存在，未找到调用点                                             |
| `WallHackDetector`         | 仅类型存在，未找到调用点                                             |

检测到加速时，`OnSpeedHackDetected` 加载 `UIVersionControl/PanelWarning`，点击确认后调用 `Launcher.Restart`
（[Launcher.cs](../../com.klab.lapis-1.5.0/Scripts/Assembly-CSharp/Oz/Framework/Launcher.cs)）。

`ObscuredTypes`（`ObscuredInt/Double/String/Vector3`）由
[ObscuredUtils.cs](../../com.klab.lapis-1.5.0/Scripts/Assembly-CSharp/Oz/Utility/ObscuredUtils.cs) 封装，并通过
`Oz_Utility_ObscuredUtilsWrap` 暴露给 Lua，用于关键数值的内存混淆（防内存搜索/改写），不是完整性校验；
Lua 侧是否实际调用未验证。

### 外部完整性校验

* **`libklabniceway.so`（启动期）**：`sub_bcb4` → `sub_2914` → `sub_ff08`/`sub_111d0` 会读取
  `/proc/<pid>/maps`，并对内嵌的 4 个库名做 ELF 可执行段校验：
  `libil2cpp.so`、`libc.so`、`libart.so`、`libklbsqlite3.so`。
  其中 4 个名字均以单字节 XOR `0x37` 编码（如 `0x135C3` 处为 `libil2cpp.so`）。
  校验失败按该库既有结论走 `kill`/SIGKILL 路径，详见 [libklabniceway.so](libklabniceway.so.md)。
  这表示直接修改 `libil2cpp.so` 的代码段（含 `.text`、`il2cpp`）会在启动时被检出；该检查只观察到一次调用点。
* **`libjackpot-core.so`（运行时）**：V2 资产状态日志会计算自身与 `libil2cpp.so` 的摘要并按 seed 加密上送，
  用于服务端判断客户端是否被改动，详见 [libjackpot-core.so](libjackpot-core.so.md)。
* **[libassistant1.so](libassistant1.so.md) / [libassistant2.so](libassistant2.so.md)**：互为看门狗，监控对象是
  `libklabniceway.so` 与另一个 assistant，**不监控** `libil2cpp.so`。

### 薄弱点

* RC4 密钥仅 4 字节，且明文存放在 `game.dat` 头部；容器格式与算法均可离线复现（`bin/decrypt_global_metadata.py`）。
* 名称在 `MetadataCache::Initialize` 中**原地解密**，初始化完成后字符串池在内存中即为明文；内存 dump 可绕过。
* 对 `libUnityPlugin.so` 不做认证：伪造同名库并实现 `query_call_back`（107 返回任意元数据、108 为空操作）即可绕过解密，
  但需自行提供可解析的元数据。
* `arm64-v8a` 无 RELRO、无 `BIND_NOW`，GOT 可写，Hook 导入函数的成本低。
* 未发现本库自身的原生反调试/反注入代码；启动期依赖 `libklabniceway.so` 的反调试与完整性检查。
* 229 个 `il2cpp_*` 导出与完整的 libc++ 符号使 Frida/动态插桩较容易定位运行时 API。
* `.gnu_debuglink` 暴露原始符号文件名 `libil2cpp.sym.so`（文件本身未随包提供）。
* 部分托管字符串（如反射签名、`CreateAssetMenu` 菜单路径）仍以明文存在于 `.rodata`。

## 功能点

### 元数据文件选择（`sub_106E830`）

> `MetadataCache::Initialize` 等名称为按 Unity 2019.4 源码结构对应，非导出符号；地址均为 1.5.0 arm64 RVA。

```c
// 返回 1 表示使用 game.dat
void *h = dlopen("libUnityPlugin.so", RTLD_NOW);
cb = dlsym(h, "query_call_back");
if (!cb) return 0;
read_meta  = cb(107);   // il2cpp_get_global_metadata
dec_string = cb(108);   // il2cpp_get_string
return read_meta != NULL && dec_string != NULL;
```

`MetadataCache::Initialize`（`0x106E8CC`）根据该返回值选择 `Metadata/game.dat` 或
`Metadata/global-metadata.dat`，并把两个回调分别存入 `off_41F6490` / `off_41F6498`。

### `il2cpp_get_global_metadata`：RC4 解密

`libUnityPlugin.so` 的 `il2cpp_get_global_metadata`（`0xF694`）先按记录链定位两个 magic：

```c
int find_record(uint8_t *buf, uint32_t magic) {
    int pos = 0;
    while (pos < len) {
        if (*(uint32_t *)(buf + pos) == magic) return pos;
        pos += *(uint32_t *)(buf + pos + 4) + 0x10;
    }
    return -1;
}

size_pos = find_record(buf, 0xBCFAF088);
key_pos  = find_record(buf, 0x567FE814);
size = *(uint32_t *)(buf + size_pos + 4);
step = *(uint32_t *)(buf + key_pos  + 4);
key  = buf + key_pos + 0x10;                 // step 字节
out  = malloc(size);
rc4(key, step, buf + size_pos + 0x10, size); // 标准 RC4（KSA + PRGA）
return out;
```

失败返回 `NULL`，由 `sub_106F060` 回退到 `global-metadata.dat`。

### `il2cpp_get_string`：字符串差分解码

`libUnityPlugin.so` 的 `il2cpp_get_string`（`0xF9E4`）以字符串池内偏移 `offset` 为种子，原地解码一条名称：

```c
void il2cpp_get_string(char *s, int offset) {
    uint8_t key = offset % 255;      // 实现用 (index/255)*255 的乘法技巧计算
    uint8_t b = s[0] ^ key;
    s[0] = b;
    for (int i = 1; b != 0; ++i) {   // 以解码出的 0 作为字符串结束
        b = s[i] ^ b;
        s[i] = b;
    }
}
```

实现用一个以 `offset` 为键的 `std::set` 记录已解码的字符串，避免同一名称被解码两次。

### `query_call_back` 接口

`libUnityPlugin.so` 的 `query_call_back`（`0x102B0`）只实现 3 个 opcode：

| opcode | 返回                                   | 说明                         |
|--------|----------------------------------------|------------------------------|
| `100`  | `mono_get_assembly_csharp`             | 本作 `libil2cpp` 未调用      |
| `107`  | `il2cpp_get_global_metadata`           | 读取并解密整块元数据         |
| `108`  | `il2cpp_get_string`                    | 解密单条名称                 |
| 其它   | `NULL`                                 |                              |

插件还导出 `mono_get_method`、`mono_get_string_heap`、`mono_metadata_encrypt` 等，由
`init_callback_func_info` 按配置 blob 里的标志位（`0x4`/`0x8`/`0x10`）挂到 101–106 号槽位；
本作没有任何库引用 `init_callback_func_info`，该路径实际未使用。插件版本串为 `1.0.1`（`get_version`）。

### 反加速检测与重启

```text
Launcher.Start (0x13FFDD0) → MoveNext (0x1400B0C)
  └─ SpeedHackDetector.StartDetection(OnSpeedHackDetected)   // 调用点 0x1400D44
       └─ 检测到时间加速
            └─ OnSpeedHackDetected (0x13FFE6C)
                 ├─ ResourceManager.LoadSync("UIVersionControl/PanelWarning")
                 └─ Btn_Ok.onClick → Launcher.Restart
```

检测基于 ACTk 的 `SpeedHackDetector`（定时比较真实时间与 Unity 时间），属于托管层逻辑，随 `libil2cpp.so`
一起发布，不涉及原生代码。

## 引用

| 引用方                  | 方式                                                                     |
|-------------------------|--------------------------------------------------------------------------|
| `libunity.so`           | 加载 IL2CPP（含 `Failed to load Il2CPP.`、`/il2cpp` 字符串），经 `il2cpp_*` API 驱动；未以 `DT_NEEDED` 依赖 |
| `libUnityPlugin.so`     | 提供 opcode 107/108 的元数据解密回调                                     |
| `libklabniceway.so`     | 启动时把 `libil2cpp.so` 的可执行段纳入完整性校验                         |
| `libjackpot-core.so`    | V2 资产状态日志计算本库摘要并上送服务端                                  |
| `data/game.dat`         | 1.3.0 起替代 `global-metadata.dat` 的加密元数据                          |
| 托管代码                | `Oz.Framework.Launcher`、ACTk 检测器、`Oz.Utility.ObscuredUtils`         |

## 待探究

* [ ] `libklabniceway.so` 的 4 库校验以文件还是内存为基准、失败后的确切动作，以及是否存在周期复检。
* [ ] `libil2cpp.so` 的具体加载者与加载方式（`libunity.so` 无 `DT_NEEDED`，也未找到 `libil2cpp.so` 字面量）。
* [ ] 1.0.3–1.2.0 已含 `game.dat`/插件分支，但 APK 未带插件；是否还有其他触发条件未验证。
* [ ] `armeabi-v7a` 仅核对结构、字符串与导出，未逐函数复核 RC4/字符串解码逻辑。
* [ ] 场景/Prefab 中是否挂载并自动启动其他 ACTk 检测器（`ACTkDetectorBase` 可自动启动）。
* [ ] `init_callback_func_info` 的配置来源与设计用途（本作未使用）。
* [ ] 服务端如何使用 `libjackpot-core.so` 上送的 `libil2cpp.so` 摘要。
