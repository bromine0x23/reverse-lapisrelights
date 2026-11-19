# libassistant1.so

## 概览

| 项 | 值 |
| --- | --- |
| 作用 | 完整性看门狗：周期检查 `libklabniceway.so`、`libassistant2.so` 的内存映射与校验和 |
| 加载 | `org.hackcode.ProxyApplication.<clinit>` 中 `System.loadLibrary("assistant1")` |
| 游戏版本 | `com.klab.lapis` 1.5.0（versionCode 699） |
| 架构 | `arm64-v8a`、`armeabi-v7a` |
| 编译器 | `Obfuscator-LLVM clang 4.0.1`，NDK `r16b` |
| 依赖 | `liblog.so` `libc.so` `libm.so` `libstdc++.so` `libdl.so` |
| 导出 | `JNI_OnLoad`、`JNI_OnUnload`；不注册 native 方法 |

代码特征：控制流平坦化；被监控库名以 XOR `0x4D` 编码。下文地址为 1.5.0 arm64 RVA。

## 版本一致性

| ABI | 大小 | SHA-256 |
| --- | --- | --- |
| `arm64-v8a` | 22360 | `8D6E800EFA2DAC402CD4BAC4E1CF9AC3F08AF7862B08FC0B3000B9FD9C66596E` |
| `armeabi-v7a` | 22040 | `8361C84F313E58075EB770913846C7AE6EF3EE6F474EA53AF77EDB3450C8E987` |

各版本会重新构建/混淆，地址与哈希不同；`.rodata`、`.comment` 与文件大小保持稳定。未发现需要单独说明的版本特例。

## 文件结构

1.5.0 arm64：

| 节 | 说明 |
| --- | --- |
| `.text` | `JNI_OnLoad`/`JNI_OnUnload`、`.plt`、初始化辅助函数 |
| `.kcniceway` | **未加密**的看门狗代码（段名只是加壳器遗留） |
| `.rodata` | 路径、日志、目标库名（部分 XOR 编码） |
| `.init_array` | 空（`0`） |
| `.fini_array` | `[0] = _FINI_0`（`0xc80`，调用 `__cxa_finalize`） |

与 `libklabniceway.so` 不同，本库没有自解密构造：`.kcniceway` 起始即合法 AArch64 函数序言，`e_entry` 为普通代码地址 `0xc80`，没有加壳描述符。

## 启动与看门狗

`JNI_OnLoad`（`0xf0c`）：

1. `GetEnv(JNI_VERSION_1_4)`，失败返回 `-1`。
2. `sub_cbc("libassistant1.so")` 在 `/proc/<pid>/maps` 中定位自身基址，读取 ELF `e_ident[EI_CLASS]`，设置 `dat_15018`（`0x20`/`0x40`）。
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

`JNI_OnUnload`（`0x10c0`）为空返回。

## 监控对象

| 目标 | 编码（key `0x4D`） |
| --- | --- |
| `libklabniceway.so` | `!$/&!,/#$.(:,4c>"` |
| `libassistant2.so` | `!$/,>>$>9,#9\x7fc>"` |

`libklabniceway.so` 的作用见 [libklabniceway.so](libklabniceway.so.md)，`libassistant2.so` 见 [libassistant2.so](libassistant2.so.md)。assistant1/2 与 `libklabniceway.so` 形成三方互查。

## 完整性检查

`sub_145c()` 先由 `sub_16d8` 解出两个目标库的路径，再对每个目标调用 `sub_25e0(path, &expected[i], i)`：打开目标 ELF 文件，解析程序头，找到可执行段并计算大小/字节和，存入 `.bss` 的 `dat_15008`。

`sub_30b8()` 每 10 秒执行一次：

1. `openat("/proc/self/maps")`，逐行 `sscanf("%lx-%lx %s %s %s %s %s")`。
2. 对包含目标库名的行调用 `sub_2c8c(line, &expected[i], i)`。
3. 仅接受可读且可执行（`r`、`x`）的映射；对映射区间按字节求和，并与预期大小/校验和比较。
4. 找不到可执行段时输出 `CHECKSUM: No executable section found. Suspicious`；映射读取失败时输出 `error: Error opening /proc/self/maps. That's usually a bad sign.`。
5. 检查失败路径调用 `kill(getpid(), SIGKILL)`。

因此，运行时对 `libklabniceway.so`、`libassistant2.so` 的代码段做内存补丁/Inline Hook，会破坏映射校验和并导致进程被 SIGKILL。

## 未确定

* `sub_25e0`/`sub_2c8c` 的校验和细节（是否累加整段、是否跳过文件头）未完全还原。
* 仅对 1.5.0 arm64 逐函数分析；armv7 仅核对结构、字符串与导出。
* 未在真机观察 10 秒轮询与 kill 的时序。
