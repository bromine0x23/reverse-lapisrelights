# libassistant2.so

## 概要

| 项     | 值                                                                                       |
|--------|------------------------------------------------------------------------------------------|
| 功能   | 完整性看门狗：周期检查 `libklabniceway.so`、`libassistant1.so` 的内存映射与校验和          |
| ABI    | `arm64-v8a`、`armeabi-v7a`                                                               |
| 工具链 | `Obfuscator-LLVM clang 4.0.1`，NDK `r16b`                                                 |
| 依赖   | `liblog.so`、`libc.so`、`libm.so`、`libstdc++.so`、`libdl.so`                            |
| 使用   | `org.hackcode.ProxyApplication.<clinit>` 中 `System.loadLibrary("assistant2")`            |

## 文件

| 版本    | ABI           | 大小  | SHA-256                                                            |
|---------|---------------|-------|--------------------------------------------------------------------|
| `1.0.3` | `arm64-v8a`   | 22360 | `019E962EF467F93172F42936CEC43FE2F1DA96B3E44EF2B0531BF59DE735BE02` |
| `1.0.3` | `armeabi-v7a` | 22040 | `720AA1C2BCED88804D0B1107487DE32908F8DB99810F610A08C173D2AC66BDEE` |
| `1.0.4` | `arm64-v8a`   | 22360 | `04A3388F2A9D859EE82AD0DDE765E5679AE8896DCDF67E9835CA6EA49AA8A5C8` |
| `1.0.4` | `armeabi-v7a` | 22040 | `1377DEC3714B9A3DBB2D2592D9E3DADB158CF96DD9B826F3D052FF1619D31170` |
| `1.1.0` | `arm64-v8a`   | 22360 | `7A9074C261036600644DFF3326FB2ECE3871122587C5474A8B3F99199D00C129` |
| `1.1.0` | `armeabi-v7a` | 22040 | `8001BD1069B3781329D3024A80B87123428ED8C9E1A7D59E94510D9C2E39B415` |
| `1.2.0` | `arm64-v8a`   | 22360 | `9F9730A3A137AB8DCE86B5AABFE743504BAE78B5B75E793F1E0279F78C50A7D3` |
| `1.2.0` | `armeabi-v7a` | 22040 | `610D5D9D48C229F97C3BD7E0F825C097EBE83B8F498197ACC89AF2ED6FD07FF2` |
| `1.3.0` | `arm64-v8a`   | 22360 | `CEBDFEEDC55A48CA0AE7FAD22B14BB107283BB053436D5599F999DE43033AB8C` |
| `1.3.0` | `armeabi-v7a` | 22040 | `0D55A1A399A4F12C3CCA1490256711D581B3CDA9F2B6508FC35B9B308E0A25E8` |
| `1.4.0` | `arm64-v8a`   | 22360 | `0BD592EE005D71CAC1BBDC3551A82C0802D4D0D43A3AF65ED13FC796BF4A18F1` |
| `1.4.0` | `armeabi-v7a` | 22040 | `7F21DD28EF1BF714CC4AFA84F2138BDB1219770AE7C9B740146DD3F14AACA78F` |
| `1.5.0` | `arm64-v8a`   | 22360 | `C381AB90BB42492003184AE9F564C2F688DD06A45D02DAE98A6DBC4F1307D183` |
| `1.5.0` | `armeabi-v7a` | 22040 | `2BC20E4774201249B3ACC68E07D586FBA9F8CA3B1B3793379E0CBBA8E252CD1D` |

各版本都会重新构建/混淆，代码字节与哈希不同；`.rodata`、`.comment` 与文件大小保持稳定，
未发现需要单独说明的版本特例。

下文地址均为 1.5.0 `arm64-v8a` 的 RVA。

### 文件结构

以 1.5.0 `arm64-v8a` 为例：

| 节            | 地址      | 大小     | 说明                                             |
|---------------|-----------|----------|--------------------------------------------------|
| `.plt`        | `0xad0`   | `0x1b0`  | 导入函数跳板                                      |
| `.text`       | `0xc80`   | `0xa34`  | `JNI_OnLoad`/`JNI_OnUnload`、初始化与校验和辅助函数 |
| `.kcniceway`  | `0x16b4`  | `0x2364` | **未加密**的看门狗代码（段名只是加壳器遗留）      |
| `.rodata`     | `0x3a18`  | `0x107`  | 路径、日志、目标库名（部分 XOR 编码）             |
| `.init_array` | `0x14cf0` | `8`      | `0`（空）                                        |
| `.fini_array` | `0x14cf8` | `0x10`   | `[0] = 0xc80`（`__cxa_finalize`）                |

与 `libklabniceway.so` 不同，本库没有自解密构造：`.kcniceway` 起始（`0x16b4`）即合法的 AArch64 函数序言，
`e_entry` 为普通代码地址 `0xc80`（即 `.fini_array[0]` 的收尾函数），没有加壳描述符。

## 导出

`.dynsym` 共 37 项：仅 2 个已定义导出（`JNI_OnLoad`/`JNI_OnUnload`）、25 个导入函数、
7 个链接器绝对符号，其余为空/节符号。

| 地址     | 符号           | 签名                                   | 功能                          |
|----------|----------------|----------------------------------------|-------------------------------|
| `0xf0c`  | `JNI_OnLoad`   | `jint JNI_OnLoad(JavaVM *, void *)`    | 计算预期校验和并启动看门狗线程 |
| `0x10cc` | `JNI_OnUnload` | `void JNI_OnUnload(JavaVM *, void *)`  | 空返回                        |

### JNI

本库不注册任何 native 方法；`System.loadLibrary("assistant2")` 触发一次 `JNI_OnLoad` 后即不再与
Java 层交互，`JNI_OnUnload` 为空返回。

## 加固

本库自身就是壳的加固组件，没有自解密或加壳：

* **代码混淆**：控制流平坦化；被监控库名以 XOR `0x42` 编码。
* **看门狗**：`JNI_OnLoad` 启动 10 秒轮询线程，对目标库的可执行映射做大小/校验和比对，
  失败即 `kill(getpid(), SIGKILL)`。
* 普通 ELF 加固：Full RELRO（`DF_1_NOW`）、NX 栈、已 strip。

## 功能点

### 启动

`JNI_OnLoad`（`0xf0c`）：

1. `GetEnv(JNI_VERSION_1_4)`，失败返回 `-1`。
2. `sub_cbc("libassistant2.so")` 在 `/proc/<pid>/maps` 中定位自身基址，读取 ELF `e_ident[EI_CLASS]`，
   设置 `dat_15018`（`0x20`/`0x40`）。
3. `sub_1458()` 计算两个被监控库的预期大小/校验和。
4. `pthread_create(..., sub_16b4, &pid)`。
5. 返回 `0x10004`。

看门狗线程：

```c
while (1) {
    sub_3028();      // 检查 /proc/self/maps 与内存校验和
    sleep(10);
}
```

### 监控对象

| 目标                | 编码（key `0x42`）      |
|---------------------|-------------------------|
| `libklabniceway.so` | `.+ ).# ,+!'5#;l1-`     |
| `libassistant1.so`  | `.+ #11+16#,6sl1-`      |

`libklabniceway.so` 的作用见 [libklabniceway.so](libklabniceway.so.md)，
`libassistant1.so` 见 [libassistant1.so](libassistant1.so.md)。assistant1/2 与
`libklabniceway.so` 形成三方互查。

### 完整性检查

`sub_1458()` 先由 `sub_16cc` 解出两个目标库的路径，再对每个目标调用
`sub_2588(path, &expected[i], i)`：打开目标 ELF 文件，解析程序头，找到可执行段并计算大小/字节和，
存入 `.bss` 的 `dat_15008`。

`sub_3028()` 每 10 秒执行一次：

1. `openat("/proc/self/maps")`，逐行 `sscanf("%lx-%lx %s %s %s %s %s")`。
2. 对包含目标库名的行调用 `sub_2c18(line, &expected[i], i)`。
3. 仅接受可读且可执行（`r`、`x`）的映射；对映射区间按字节求和，并与预期大小/校验和比较。
4. 找不到可执行段时输出 `CHECKSUM: No executable section found. Suspicious`；映射读取失败时输出
   `error: Error opening /proc/self/maps. That's usually a bad sign.`。
5. 检查失败路径调用 `kill(getpid(), SIGKILL)`。

因此，运行时对 `libklabniceway.so`、`libassistant1.so` 的代码段做内存补丁/Inline Hook，
会破坏映射校验和并导致进程被 SIGKILL。

## 引用

* `output/apktool/smali/org/hackcode/ProxyApplication.smali`：`<clinit>` 在 `klabniceway` 之后加载
  `assistant1`、`assistant2`。
* [libklabniceway.so](libklabniceway.so.md)：DEX 壳与三方互查的说明。
* [libassistant1.so](libassistant1.so.md)：互查的另一半。
* [README.md](README.md)：二进制库加密与 `.kcniceway` 段的通用说明。

## 待探究

* [ ] `sub_2588`/`sub_2c18` 的校验和细节（是否累加整段、是否跳过文件头）未完全还原。
* [ ] 仅对 1.5.0 arm64 逐函数分析；armv7 仅核对结构、字符串与导出。
* [ ] 未在真机观察 10 秒轮询与 kill 的时序。
