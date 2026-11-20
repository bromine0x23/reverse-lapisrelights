# libassistant1.so

## 概要

| 项     | 值                                                                                       |
|--------|------------------------------------------------------------------------------------------|
| 功能   | 完整性看门狗：周期检查 `libklabniceway.so`、`libassistant2.so` 的内存映射与校验和          |
| ABI    | `arm64-v8a`、`armeabi-v7a`                                                               |
| 工具链 | `Obfuscator-LLVM clang 4.0.1`，NDK `r16b`                                                 |
| 依赖   | `liblog.so`、`libc.so`、`libm.so`、`libstdc++.so`、`libdl.so`                            |
| 使用   | `org.hackcode.ProxyApplication.<clinit>` 中 `System.loadLibrary("assistant1")`            |

## 文件

| 版本    | ABI           | 大小  | SHA-256                                                            |
|---------|---------------|-------|--------------------------------------------------------------------|
| `1.0.3` | `arm64-v8a`   | 22360 | `C0E2CC134787E8CB6955A33EAFBC6746BD3C2555C7360973926D23ECAF02331D` |
| `1.0.3` | `armeabi-v7a` | 22040 | `037D07D8FA58C82350375DFEB3965DD1E5AB39F9723AE839D03877A638B0FF93` |
| `1.0.4` | `arm64-v8a`   | 22360 | `2545D99BAFB87BA1B2BECFED19D4B0439A91B8FB73EEE457A51B08CEA065BAA5` |
| `1.0.4` | `armeabi-v7a` | 22040 | `3F78C01EF88DA21EAED5FA5ED01F517F55E322F0FBBC58398451E502E83C48EF` |
| `1.1.0` | `arm64-v8a`   | 22360 | `5D38A661B9BB7E52AFF80FB251D163ADDC6EB4AA8CAABA4A9FCCDD48B8664544` |
| `1.1.0` | `armeabi-v7a` | 22040 | `381EFD4943342B8794A71DBBFD4F363F37C1E902F12F0002500F0A5BFA7EBAED` |
| `1.2.0` | `arm64-v8a`   | 22360 | `4EB83BE269DFDB853F43111CDAF3BA38DE9F732877C01F9A8AE8ADC5AB4CEAAF` |
| `1.2.0` | `armeabi-v7a` | 22040 | `27F6222D10F2F5546A454A4E31D182AAC4C024AD10F1775E1DC1766CE3F1CA74` |
| `1.3.0` | `arm64-v8a`   | 22360 | `6D4FEADE70A0CDB4A01BFB0F50CDBF44B74F28E463202D3E4CAF469FE027D991` |
| `1.3.0` | `armeabi-v7a` | 22040 | `031B561479EE39FCD838133B345EF57872D341B42EB5D8AE0491E45C003A5438` |
| `1.4.0` | `arm64-v8a`   | 22360 | `0DC40698DDC9BD6C7F2BC47FDB89330AF36793AB02997A95D4A6EAAD95320D44` |
| `1.4.0` | `armeabi-v7a` | 22040 | `4D5A9BABC6644A0592E581479C4EC2E37BFDD99548D0D7D91CDDDC98D38F6B0F` |
| `1.5.0` | `arm64-v8a`   | 22360 | `8D6E800EFA2DAC402CD4BAC4E1CF9AC3F08AF7862B08FC0B3000B9FD9C66596E` |
| `1.5.0` | `armeabi-v7a` | 22040 | `8361C84F313E58075EB770913846C7AE6EF3EE6F474EA53AF77EDB3450C8E987` |

各版本都会重新构建/混淆，代码字节与哈希不同；`.rodata`、`.comment` 与文件大小保持稳定，
未发现需要单独说明的版本特例。

下文地址均为 1.5.0 `arm64-v8a` 的 RVA。

### 文件结构

以 1.5.0 `arm64-v8a` 为例：

| 节            | 地址      | 大小     | 说明                                             |
|---------------|-----------|----------|--------------------------------------------------|
| `.plt`        | `0xad0`   | `0x1b0`  | 导入函数跳板                                      |
| `.text`       | `0xc80`   | `0xa40`  | `JNI_OnLoad`/`JNI_OnUnload`、初始化与校验和辅助函数 |
| `.kcniceway`  | `0x16c0`  | `0x240c` | **未加密**的看门狗代码（段名只是加壳器遗留）      |
| `.rodata`     | `0x3acc`  | `0x107`  | 路径、日志、目标库名（部分 XOR 编码）             |
| `.init_array` | `0x14cf0` | `8`      | `0`（空）                                        |
| `.fini_array` | `0x14cf8` | `0x10`   | `[0] = 0xc80`（`__cxa_finalize`）                |

与 `libklabniceway.so` 不同，本库没有自解密构造：`.kcniceway` 起始（`0x16c0`）即合法的 AArch64 函数序言，
`e_entry` 为普通代码地址 `0xc80`（即 `.fini_array[0]` 的收尾函数），没有加壳描述符。

## 导出

`.dynsym` 共 37 项：仅 2 个已定义导出（`JNI_OnLoad`/`JNI_OnUnload`）、25 个导入函数、
7 个链接器绝对符号，其余为空/节符号。

| 地址     | 符号           | 签名                                   | 功能                          |
|----------|----------------|----------------------------------------|-------------------------------|
| `0xf0c`  | `JNI_OnLoad`   | `jint JNI_OnLoad(JavaVM *, void *)`    | 计算预期校验和并启动看门狗线程 |
| `0x10c0` | `JNI_OnUnload` | `void JNI_OnUnload(JavaVM *, void *)`  | 空返回                        |

### JNI

本库不注册任何 native 方法；`System.loadLibrary("assistant1")` 触发一次 `JNI_OnLoad` 后即不再与
Java 层交互，`JNI_OnUnload` 为空返回。

## 加固

本库自身就是壳的加固组件，没有自解密或加壳：

* **代码混淆**：控制流平坦化；被监控库名以 XOR `0x4D` 编码。
* **看门狗**：`JNI_OnLoad` 启动 10 秒轮询线程，对目标库的可执行映射做大小/校验和比对，
  失败即 `kill(getpid(), SIGKILL)`。
* 普通 ELF 加固：Full RELRO（`DF_1_NOW`）、NX 栈、已 strip。

## 功能点

### 启动

`JNI_OnLoad`（`0xf0c`）：

1. `GetEnv(JNI_VERSION_1_4)`，失败返回 `-1`。
2. `sub_cbc("libassistant1.so")` 在 `/proc/<pid>/maps` 中定位自身基址，读取 ELF `e_ident[EI_CLASS]`，
   设置 `dat_15018`（`0x20`/`0x40`）。
3. `sub_145c()` 计算两个被监控库的预期大小/校验和。
4. `pthread_create(..., sub_16c0, &pid)`。
5. 返回 `0x10004`。

看门狗线程：

```c
while (1) {
    sub_30b8();      // 检查 /proc/self/maps 与内存校验和
    sleep(10);
}
```

### 监控对象

| 目标                | 编码（key `0x4D`）     |
|---------------------|------------------------|
| `libklabniceway.so` | `!$/&!,/#$.(:,4c>"`    |
| `libassistant2.so`  | `!$/,>>$>9,#9\x7fc>"`  |

`libklabniceway.so` 的作用见 [libklabniceway.so](libklabniceway.so.md)，
`libassistant2.so` 见 [libassistant2.so](libassistant2.so.md)。assistant1/2 与
`libklabniceway.so` 形成三方互查。

### 完整性检查

`sub_145c()` 先由 `sub_16d8` 解出两个目标库的路径，再对每个目标调用
`sub_25e0(path, &expected[i], i)`：打开目标 ELF 文件，解析程序头，找到可执行段并计算大小/字节和，
存入 `.bss` 的 `dat_15008`。

`sub_30b8()` 每 10 秒执行一次：

1. `openat("/proc/self/maps")`，逐行 `sscanf("%lx-%lx %s %s %s %s %s")`。
2. 对包含目标库名的行调用 `sub_2c8c(line, &expected[i], i)`。
3. 仅接受可读且可执行（`r`、`x`）的映射；对映射区间按字节求和，并与预期大小/校验和比较。
4. 找不到可执行段时输出 `CHECKSUM: No executable section found. Suspicious`；映射读取失败时输出
   `error: Error opening /proc/self/maps. That's usually a bad sign.`。
5. 检查失败路径调用 `kill(getpid(), SIGKILL)`。

因此，运行时对 `libklabniceway.so`、`libassistant2.so` 的代码段做内存补丁/Inline Hook，
会破坏映射校验和并导致进程被 SIGKILL。

## 引用

* `output/apktool/smali/org/hackcode/ProxyApplication.smali`：`<clinit>` 在 `klabniceway` 之后加载
  `assistant1`、`assistant2`。
* [libklabniceway.so](libklabniceway.so.md)：DEX 壳与三方互查的说明。
* [libassistant2.so](libassistant2.so.md)：互查的另一半。
* [README.md](README.md)：二进制库加密与 `.kcniceway` 段的通用说明。

## 待探究

* [ ] `sub_25e0`/`sub_2c8c` 的校验和细节（是否累加整段、是否跳过文件头）未完全还原。
* [ ] 仅对 1.5.0 arm64 逐函数分析；armv7 仅核对结构、字符串与导出。
* [ ] 未在真机观察 10 秒轮询与 kill 的时序。
