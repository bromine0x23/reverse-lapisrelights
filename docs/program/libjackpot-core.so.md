# libjackpot-core.so

## 概览

| 项        | 值                                                                                                  |
|-----------|-----------------------------------------------------------------------------------------------------|
| 作用      | Jackpot SDK 的 Android 原生安全组件：su/调试器检测；生成“资产状态日志”（APK 签名 + 引擎完整性摘要） |
| Java 侧   | `com.klab.jackpot.JackpotActivityCallback.<clinit>` 调 `System.loadLibrary("jackpot-core")`         |
| IL2CPP 侧 | P/Invoke 模块名 `jackpot-core`，入口 `_KJACore_AssetStateLog*`                                      |
| 游戏版本  | `com.klab.lapis` 1.5.0（versionCode 699）                                                           |
| 架构      | `arm64-v8a`、`armeabi-v7a`                                                                          |
| 编译器    | NDK clang 3.8.256229；静态链接 gabi++/libstdc++（`.comment` 另有 `GCC 4.9.x 20150123`）             |
| 依赖      | `libandroid.so` `libstdc++.so` `libm.so` `libc.so` `libdl.so`                                       |
| 导出      | `JNI_OnLoad`、1 个 `Java_*`、4 个 `_KJACore_*`；另有数百个静态链接符号                              |

代码特征：无加壳/自解密（`e_entry` 即 `.text` 起始，`.init_array` 只有运行库构造）；敏感字符串逐段 XOR；
`_KJACore_AssetStateLog*` 的名字与真实行为不符（见下）。下文地址均为 1.5.0 arm64 的 RVA。

## 版本一致性

`1.0.3`～`1.5.0` 各版本中的该库**完全相同**：

| ABI           | 大小   | SHA-256                                                            |
|---------------|--------|--------------------------------------------------------------------|
| `arm64-v8a`   | 501880 | `8217D75C6B2F87CC4906EA3DC52E4DDE8204D2C2312BE2D7038FE270F4832915` |
| `armeabi-v7a` | 300752 | `7126A55D67B2814A72C60CDAAB510072052F1A1CA5B683EB1A0071D4C294E19A` |

armv7 仅核对结构、字符串与关键常量（`0x12D8AF36`），未逐函数复核。

## 文件结构

1.5.0 arm64：

| 节            | 地址      | 大小      | 说明                                                          |
|---------------|-----------|-----------|---------------------------------------------------------------|
| `.plt`        | `0x16d10` | `0x650`   | 导入函数跳板                                                  |
| `.text`       | `0x17360` | `0x46310` | 自定义代码 + 静态 libstdc++                                   |
| `.rodata`     | `0x5d670` | `0x4328`  | 摘要测试向量、Base64 表、C++ locale 数据                      |
| `.init_array` | `0x864f0` | `0x20`    | 3 个构造：gabi++ 运行库、`std::ios_base::Init`、locale 互斥锁 |
| `.fini_array` | `0x86510` | `0x10`    | `__cxa_finalize`                                              |

自定义代码约 `0x17360`–`0x23d50`（含 MD5/SHA-1/SHA-256/SHA-384/SHA-512）；
其后到 `.text` 末尾是静态链接进来的 gabi++/libstdc++，因此文件体积远大于业务代码，且 `.dynsym` 中有大量 `_ZNSt*`。

## 导出符号

| 地址      | 符号                                                              | 大小 | 说明                                                  |
|-----------|-------------------------------------------------------------------|------|-------------------------------------------------------|
| `0x17fdc` | `Java_com_klab_jackpot_JackpotActivityCallback_isSuBinaryPresent` | 4    | 尾调用 `0x179a8`（su 检测）                           |
| `0x17fe0` | `JNI_OnLoad`                                                      | 32   | 保存 `JavaVM*`、初始化 canary，返回 `JNI_VERSION_1_6` |
| `0x22160` | `_KJACore_AssetStateLogAvailable`                                 | 4    | 尾调用 `0x179a8`（su 检测）                           |
| `0x22164` | `_KJACore_AssetStateLogSubscribe`                                 | 4    | 尾调用 `0x17714`（调试器检测）                        |
| `0x22168` | `_KJACore_AssetStateLogGenerate`                                  | 508  | 日志 V1；IL2CPP 1.5.0 中未引用                        |
| `0x22364` | `_KJACore_AssetStateLogGenerateV2`                                | 508  | 日志 V2；游戏实际使用                                 |

> `Available` 实际是 **root 检测**，`Subscribe` 实际是 **TracerPid 检测**。
> C# 中分别由 `Jackpot.AndroidPlatform.IsRooted()` 与 `Platform.SubscribeAssetStateLog()` 使用。

## 启动

```c
JNI_OnLoad(JavaVM *vm, void *reserved) {   // 0x17fe0
    sub_174e4(vm);   // dat_8a130 = vm
    sub_17604();     // srand48(time(0))，生成随机 canary
    return 0x10006;  // JNI_VERSION_1_6
}
```

不注册 native 方法，JNI 函数按符号名查找。首次进入 JNI 桥时由 `sub_174f0` 调 `JavaVM->AttachCurrentThread`
取得 `JNIEnv*`（`sub_17530` 为 `DetachCurrentThread`）。

## Root 检测（`sub_179a8`）

对以下路径逐一 `stat()`，任一存在即返回 `1`：

| 目录（拼接 `/su`）                                   | 文件                                  |
|------------------------------------------------------|---------------------------------------|
| `/system/bin`、`/system/xbin`、`/sbin`               | `/system/app/Superuser.apk`           |
| `/data/local`、`/data/local/bin`、`/data/local/xbin` | `/system/app/Superuser/Superuser.apk` |
| `/system/sd/xbin`、`/system/bin/failsafe`            | `/system/app/SuperSU.apk`             |
| `/vendor/bin`、`/system/app/`                        | `/system/app/SuperSU/SuperSU.apk`     |

典型的 RootBeer 式检查；`/system/app/` 一项会拼成 `/system/app//su`，是 SDK 原样行为。
`JackpotActivityCallback.onResume()` → `finishIfInappropriateEnvironmentSuspected()` 调用本函数，
命中则暂停 Unity、显示黑屏、Toast 后结束 Activity。

## 调试器检测（`sub_17714`）

```c
void sub_17714(bool *traced, bool *err) {
    if (canary_check_fails()) { *traced = 1; *err = 0; return; }
    FILE *fp = fopen("/proc/<pid>/status", "r");   // 路径 XOR 0x35
    *traced = 0;
    if (!fp) { *err = 1; return; }
    while (fgets(line, 1024, fp))
        if (!strncmp(line, "TracerPid:", 9)) {
            if (atoi(line + 10) != 0) *traced = 1;
            break;
        }
    fclose(fp);
    *err = 0;
}
```

`canary_check_fails()` 比较 `dat_8a144`/`dat_8a13c` 两个随机 canary；正常时走 `/proc` 分支。
结果即 `Platform.SubscribeAssetStateLog()` 的返回值（`err` 为真时不采用）。

## 资产状态日志

### 调用链

```
Lua: Jackpot.Platform.GenerateAssetStateLog(seed) / DeviceInfo.GenerateAssetStateLog(seed)
  └─ Jackpot_PlatformWrap / DeviceInfoWrap           (tolua 包装，0x16CB5A4 / 0x1741120)
     └─ Jackpot.Platform.GenerateAssetStateLog(seed) (IL2CPP, 0x1E9EE7C)
        └─ Jackpot.AndroidPlatform.GenerateAssetStateLog(seed) (0x17669B0)
           ├─ new StringBuilder(1024)
           └─ P/Invoke "jackpot-core" / "_KJACore_AssetStateLogGenerateV2" (包装 0x1764B7C)
              └─ libjackpot-core.so 0x22364 → sub_1e68c
```

返回给 Lua 的是 Base64 字符串，通常随请求上送服务端做完整性校验（服务端用法未验证）。

### V1 与 V2

|                   | V1 `_KJACore_AssetStateLogGenerate`                                      | V2 `_KJACore_AssetStateLogGenerateV2`     |
|-------------------|--------------------------------------------------------------------------|-------------------------------------------|
| 入口              | `0x22168` → `sub_1d840`                                                  | `0x22364` → `sub_1e68c`                   |
| 签名摘要          | JNI 调 `SignGenerator`（APK 签名证书）                                   | 同左                                      |
| 第二个摘要        | JNI 调 `AssetsDigestGenerator` 读 `bin/Data/Managed/Assembly-CSharp.dll` | 原生读取自身与 `libil2cpp.so`，逐字节 XOR |
| 摘要算法          | Java `MessageDigest`（md5/sha1/sha256）                                  | 原生 MD5/SHA-1/SHA-256                    |
| 混淆              | 明文与 seed 循环异或                                                     | 以 seed 前 4 字节为种子的 64 位流密码     |
| IL2CPP 1.5.0 引用 | 无                                                                       | 是                                        |

V1 应为面向 Mono/旧版的构建；本作 APK 中没有 `Assembly-CSharp.dll`，即使调用，第二部分也只会得到占位串
`asmcsharpdlldigestwasnotavailable`。

### 摘要来源（JNI 桥）

`sub_1b840`（`SignGenerator`）与 `sub_1bd94`（`AssetsDigestGenerator`）通过 `FindClass` + `GetMethodID` 调用：

| Java 类                                  | 方法                                                     | 用途                                                |
|------------------------------------------|----------------------------------------------------------|-----------------------------------------------------|
| `com.klab.jackpot.SignGenerator`         | `static open()L...;`                                     | `PackageManager` → `Signature.toByteArray()` → X509 |
|                                          | `available()Z` / `get(I)Ljava/lang/String;` / `close()V` | 对证书 DER 计算 md5/sha1/sha256，返回十六进制串     |
| `com.klab.jackpot.AssetsDigestGenerator` | `static open(Ljava/lang/String;)L...;`                   | `AssetManager.open(path)`                           |
|                                          | `available()Z` / `get(I)Ljava/lang/String;` / `close()V` | 对资产流计算摘要                                    |

`get(int)` 的 0/1/2 分别对应 MD5/SHA-1/SHA-256。

### V1 算法

```text
part1 = 签名证书摘要（算法索引 (seed[1]-'0') % 3）
part2 = Assembly-CSharp.dll 摘要（算法索引 (seed[2]-'0') % 3）
        失败时用 "signature digest was not available" /
        "asmcsharpdlldigestwasnotavailable"
plain = part1 + "-" + part2            // seed[0]-'0' 的奇偶决定槽位
out   = base64( plain[i] ^ seed[i % strlen(seed)] )
```

### V2 算法

```text
// 两个算法索引为 seed[1] % 3 与 seed[2] % 3；
// seed[0] 最低位决定谁用于签名、谁用于 native，以及拼接顺序
sig    = 签名证书摘要
self   = 本库文件摘要（路径取自 /proc/self/maps）
engine = <同目录>/libil2cpp.so 摘要（与 self 同一算法）
native = hex( self[i] ^ engine[i] )        // 16/20/32 字节
plain  = sig + "-" + native
out    = base64( plain[i] ^ keystream(seed[0..3])[i] )
```

- 本库路径由 `dladdr` + `/proc/self/maps` 按 basename 匹配（`sub_1d16c`）；摘要转十六进制由 C++ iostream
  `setw(2)/setfill('0')` 完成（`sub_1d54c`）。
- `self`/`engine` 任一读取失败时 `native` 用占位串 `asmcsharpdlldigestwasnotavailable`。

`keystream` 是 4 抽头非线性 64 位移位寄存器（`sub_1e68c`：`0x1f260`–`0x1f348` 初始化，`0x1fa2c` 起逐字节输出）。
初值由 seed 前 4 字节（小端 u32）与 `0x12D8AF36`、`0x2BD577FD`、`0x100459D572C`、`0x9C627F0A0E`、`0x15FDEC10BCD` 混合得到：

```c
// D[-3..0] = J, N, Q, S
for (int k = 1; k <= n; k++) {
    uint64_t t = D[k-4] ^ (D[k-4] << 11);
    D[k] = t ^ (D[k-1] >> 19) ^ D[k-1] ^ (t >> 8);
    out[k-1] = (uint8_t)D[k] ^ in[k-1];
}
```

### 参数约束

- V1 要求 `seed` 至少 3 字节、V2 至少 4 字节；实现未做长度检查。
- 边界判断为 `bufsize >= 输出长度`，但随后 `strcpy` 多写 1 个 NUL；SDK 固定传 `1024`，不会触发。

## 字符串混淆

敏感字符串（路径、类名、JNI 签名、占位串）均为栈上逐字节常量，由 `sub_17580(key, str)` 原位 XOR 解码：

| key                      | 内容示例                                                                     |
|--------------------------|------------------------------------------------------------------------------|
| `0x63`                   | `/system/bin`、`/system/app/`、`Superuser`、`SuperSU`、`/su`                 |
| `0x35`                   | `/proc/%d/status`、`TracerPid`                                               |
| `0x5b`                   | `com/klab/jackpot/SignGenerator`、`AssetsDigestGenerator`、方法名与 JNI 签名 |
| `0x2f`                   | `libil2cpp.so` 相关说明串、占位串                                            |
| `0x42`                   | `/proc/self/maps`、`bin/Data/Managed/Assembly-CSharp.dll`、`libil2cpp.so`    |
| `0x4d` / `0x26` / `0x72` | canary 与比较常量                                                            |

## 内置密码学

| 算法    | 初始化 / 更新 / 收尾（arm64）                       | 备注                         |
|---------|-----------------------------------------------------|------------------------------|
| MD5     | `0x19080` / `0x190bc` / `0x19548`（变换 `0x180a8`） | 标准常量                     |
| SHA-1   | `0x21cec` / `0x21d50` / `0x21e68`                   | 输出 20 字节                 |
| SHA-256 | `0x22618` / `0x22884` / `0x229f0`                   | H0 表 `0x5dcd0`              |
| SHA-384 | `0x20d64` / …                                       | H0 表 `0x5db90`              |
| SHA-512 | `0x20698` / `0x206f0` / …                           | H0 表 `0x5d8d0`              |
| Base64  | 字母表 `0x5d750`                                    | 标准 `A–Za–z0–9+/`，`=` 填充 |

`.rodata` 带五种摘要的“The quick brown fox…”标准测试向量。

## 未确定

* Lua 侧 `seed` 的来源、服务端如何验证该 Base64 串未确认。
* `canary_check_fails()` 中两个随机 canary 的关系判定，设计意图未完全还原。
* armv7 未逐函数复核；动态行为（结束 Activity、日志上送）未在真机验证。
