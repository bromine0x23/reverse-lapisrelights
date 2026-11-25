# libmain.so

## 概要

| 项     | 值                                                                                                                                                    |
|--------|-------------------------------------------------------------------------------------------------------------------------------------------------------|
| 功能   | Unity 2019.4.26f1c1 的 JNI 引导库：`JNI_OnLoad` 注册 `NativeLoader.load/unload`；`load` 从 `nativeLibraryDir` 装载 `libunity.so` 并转发其 `JNI_OnLoad`，`unload` 反向卸载；armv7 版本在装载前检查 NEON |
| ABI    | `arm64-v8a`、`armeabi-v7a`                                                                                                                            |
| 工具链 | NDK `r19`、Android clang 8.0.2（build 5058415）；minSdk 21（arm64）/ 19（armv7）；armv7 额外静态链接 `libunwind_llvm` 与 NDK cpufeatures                     |
| 依赖   | `liblog.so`、`libm.so`、`libdl.so`、`libc.so`；实际导入 11 个（arm64）/ 30 个（armv7）符号                                                              |
| 使用   | `UnityPlayer.loadNative` 先 `System.loadLibrary("main")`，再调 `NativeLoader.load(nativeLibraryDir)`；`unloadNative` 调 `NativeLoader.unload()`          |

## 文件

| 版本            | ABI           | 大小  | SHA-256                                                            |
|-----------------|---------------|-------|--------------------------------------------------------------------|
| `1.0.3`–`1.5.0` | `arm64-v8a`   | 6424  | `331D1126B707B6B264203027080FD273AB1C14E5B6BEA0C853107167437E80D0` |
| `1.0.3`–`1.5.0` | `armeabi-v7a` | 18468 | `85D57FB290302DAD2F77D8650D77BCD56AEB0EFC919038720378D85BB8033F4B` |

1.0.3 – 1.5.0 的 7 个版本、两套 ABI 全部一致，没有版本特例：该文件在各版本间未发生变化。

下文地址除特别注明外均为 1.5.0 `arm64-v8a` 的 RVA。

### 文件结构

以 1.5.0 `arm64-v8a` 为例：

| 节                    | 地址      | 大小    | 说明                                                                 |
|-----------------------|-----------|---------|----------------------------------------------------------------------|
| `.plt`                | `0x810`   | `0xd0`  | 11 个导入函数跳板                                                    |
| `.text`               | `0x8e0`   | `0x324` | CRT 桩（`0x8e0`–`0x91c`）、`JNI_OnLoad`、`load`、`unload`，全部代码 |
| `.rodata`             | `0xc04`   | `0xbd`  | 类名、方法名/签名、`libunity.so`、错误文案                           |
| `.eh_frame`           | `0xce8`   | `0x78`  | 覆盖 `JNI_OnLoad`/`load`/`unload` 三个函数的展开信息                 |
| `.note.android.ident` | `0xd60`   | `0x98`  | API 21、NDK `r19`、build `5232133`                                   |
| `.fini_array`         | `0x10e10` | `0x10`  | `[0]=0x8f0`（空）、`[1]=0x8e0`（`__cxa_finalize` 桩）                |
| `.data`               | `0x11058` | `0x38`  | `__dso_handle` + `JNINativeMethod[2]`（从 `0x11060` 起）             |
| `.bss`                | `0x11090` | `0x8`   | `g_unity_lib_handle`                                                 |
| `.comment`            | —         | `0x107` | clang 8.0.2 版本串                                                  |
| `.note.unity`         | —         | `0x3c`  | `2019.4.26f1c1_d102cc46c633`                                         |
| `.gnu_debuglink`      | —         | `0x14`  | `libmain.dbg.so`（未随包提供）                                       |

* `e_entry = 0x8e0` 是 CRT 的 `__cxa_finalize(__dso_handle)` 桩，不是游戏入口；本库**没有 `.init_array`**，
  加载时不会执行构造或自解密代码。
* `.dynsym` 22 项：5 个导出（含 4 个链接器绝对符号）、11 个导入，其余为空/局部符号；已 strip，无 `.symtab`。
* 8 个程序头：两个 `PT_LOAD`（RX `0`–`0xdf8`、RW `0x10e10`–`0x11098`）；`PT_GNU_RELRO` 覆盖 `0x10e10`–`0x11000`；
  `PT_GNU_STACK` 为 RW（NX）。

`armeabi-v7a` 的主要差异：

| 节                  | 地址      | 大小     | 说明                                                                    |
|---------------------|-----------|----------|-------------------------------------------------------------------------|
| `.text`             | `0x10a0`  | `0x2308` | CRT 桩与主逻辑（`0x10a0`–`0x12f1`）、cpufeatures、静态 `libunwind_llvm` |
| `.ARM.exidx`        | `0x33a8`  | `0x1b0`  | ARM 展开索引                                                            |
| `.ARM.extab`        | `0x3558`  | `0x174`  | ARM 展开表                                                              |
| `.rodata`           | `0x36d0`  | `0x668`  | 主逻辑文案 + libunwind 断言/源路径 + CPU 特性字符串                     |
| `.fini_array`       | `0x4e98`  | `0x8`    | `0x10b4`（空函数）                                                      |
| `.data.rel.ro`      | `0x4ea0`  | `0x68`   | libunwind/cpufeatures 只读数据                                          |
| `.data`             | `0x5000`  | `0x20`   | `__dso_handle` + `JNINativeMethod[2]`（`0x5004`）+ 一个重定位指针        |
| `.bss`              | `0x50f0`  | `0x25`   | 首 4 字节为 `g_unity_lib_handle`                                        |

`e_entry = 0`；链接器为 GNU gold 1.12，`e_flags=0x05000200`（EABI5 + 硬浮点），`.ARM.attributes` 标记 `ARM v7`。
主逻辑与 arm64 同源，`.text` 多出的约 0x2000 字节来自 NDK `libunwind_llvm`
（`/Volumes/Android/buildbot/.../ndk-release-r19/external/libunwind_llvm/`）和 cpufeatures
（`/proc/cpuinfo`、`/proc/self/auxv`、`getauxval` 等字符串）。其中 cpufeatures 的
`android_getCpuFeatures()`（`0x1bcc`）被 `load` 调用用于 NEON 检测；libunwind 代码则未见主逻辑调用。

导入面：arm64 的 11 个符号均为函数：`snprintf`、`malloc`、`memcpy`、`free`、`dlopen`、`dlsym`、
`dlerror`、`dlclose`、`__cxa_finalize`、`__cxa_atexit`、`__stack_chk_fail`；armv7 的 30 个覆盖同一组调用
（`memcpy` 换为 `__aeabi_memcpy`，并多出 `__stack_chk_guard` 等对象），另有 cpufeatures/libunwind 使用的
`open`、`read`、`close`、`strtol`、`memmem`、`pthread_once` 等。`liblog.so`、`libm.so` 虽在 `DT_NEEDED` 中，
但没有导入符号。

## 导出

`arm64-v8a` 的 `.dynsym` 只有 `JNI_OnLoad` 一个函数导出，其余 4 项是链接器绝对符号：

| 地址    | 符号              | 签名                                | 功能                                             |
|---------|-------------------|-------------------------------------|--------------------------------------------------|
| `0x91c` | `JNI_OnLoad`      | `jint JNI_OnLoad(JavaVM *, void *)` | 注册 `NativeLoader` 的两个 native 方法，返回 `JNI_VERSION_1_6` |
| `0x11098` | `_bss_end__`    | `void`                              | 链接器绝对符号                                   |
| `0x11098` | `__end__`       | `void`                              | 链接器绝对符号                                   |
| `0x11090` | `__bss_start__` | `void`                              | 链接器绝对符号                                   |
| `0x11098` | `__bss_end__`   | `void`                              | 链接器绝对符号                                   |

`armeabi-v7a` 有 34 个导出：`JNI_OnLoad`（`0x10e5`）+ 3 个链接器绝对符号 + 30 个静态 `libunwind_llvm`
符号（`_Unwind_*`、`unw_*`、`__aeabi_unwind_*`、`__gnu_unwind_frame`、`decode_eht_entry`）。unwinder 符号见
「文件结构」，主逻辑仍只有下表的三个函数。

### JNI

| arm64     | armv7     | 方法                                                    | 说明                                                         |
|-----------|-----------|---------------------------------------------------------|--------------------------------------------------------------|
| `0x91c`   | `0x10e5`  | `jint JNI_OnLoad(JavaVM *, void *)`                     | `System.loadLibrary("main")` 时由 ART 调用                    |
| `0x9ac`   | `0x1144`  | `boolean NativeLoader.load(String nativeLibraryDir)`    | 静态 native；`load` 内部完成 `libunity.so` 装载与 `JNI_OnLoad` |
| `0xb7c`   | `0x12a0`  | `boolean NativeLoader.unload()`                         | 静态 native；调用 `libunity.so!JNI_OnUnload` 后 `dlclose`     |

`load`/`unload` 不是动态导出，而是在 `JNI_OnLoad` 中通过 `RegisterNatives` 注册：

```c
static JNINativeMethod g_native_methods[2] = {
    { "load",   "(Ljava/lang/String;)Z", load   },
    { "unload", "()Z",                   unload },
};
```

表位于 `.data`：arm64 `0x11060`（`"load"`→`0xcbc`、`0x9ac`；`"unload"`→`0xc3a`、`0xb7c`），
armv7 `0x5004`（函数指针带 Thumb 位：`0x1145`/`0x12a1`）。

## 加固

无。本库由 Unity 构建（见 `.note.unity`），不具有 KLab 的加固/加壳特征：

* 没有自解密：不存在 `.kcniceway`/`.kclapisniceway` 段，也没有 `.init_array` 或 `e_entry` 描述符；
  `e_entry` 只是 CRT 的 `__cxa_finalize` 桩。
* 代码与字符串全部明文，无控制流混淆、无字符串加密、无反调试、无完整性校验。
* 普通 ELF 加固：NX 栈、Partial RELRO（未设置 `BIND_NOW`）、栈保护（导入 `__stack_chk_fail`）、已 strip；
  无 `RPATH`/`RUNPATH`，无 AArch64 BTI/PAC。
* 同一文件的哈希在 1.0.3 – 1.5.0 保持不变，未发现重新打包或二次修改的痕迹。

## 功能点

### `JNI_OnLoad`

```c
jint JNI_OnLoad(JavaVM *vm, void *reserved) {
    JNIEnv *env = NULL;
    (*vm)->AttachCurrentThread(vm, &env, NULL);          // 返回值未检查
    jclass clazz = (*env)->FindClass(env, "com/unity3d/player/NativeLoader");
    if ((*env)->RegisterNatives(env, clazz, g_native_methods, 2) < 0) {
        (*env)->FatalError(env, "com/unity3d/player/NativeLoader");
        return -1;
    }
    return 0x10006;                                      // JNI_VERSION_1_6
}
```

* 通过 `JavaVM` 函数表偏移 `0x20`（索引 4）调用 `AttachCurrentThread`。
* 通过 `JNIEnv` 函数表偏移 `0x30`（索引 6）调用 `FindClass`，偏移 `0x6B8`（索引 215）调用 `RegisterNatives`。
* 失败分支调用 `FatalError`（偏移 `0x90`，索引 18），按 JNI 约定不会返回；其后的 `return -1` 是编译产物。
* 只注册方法，不加载 `libunity.so`；真正的引擎装载发生在 Java 调用 `NativeLoader.load` 时。

### `NativeLoader.load`

```c
bool load(JNIEnv *env, jclass clazz, jstring jpath) {
    // armv7 only: if (!(android_getCpuFeatures() & ANDROID_CPU_ARM_FEATURE_NEON)) return false;

    jsize len = (*env)->GetStringUTFLength(env, jpath);
    char *dir = malloc(len + 1);
    const char *utf = (*env)->GetStringUTFChars(env, jpath, NULL);
    memcpy(dir, utf, len + 1);
    (*env)->ReleaseStringUTFChars(env, jpath, utf);

    if (g_unity_lib_handle == NULL) {
        JavaVM *vm = NULL;
        if ((*env)->GetJavaVM(env, &vm) < 0) {
            (*env)->FatalError(env, "Unable to retrieve Java VM");
        } else {
            char path[2048];
            snprintf(path, 0x7ff, "%s/%s", dir, "libunity.so");
            void *h = dlopen(path, RTLD_LAZY);
            if (h == NULL)
                h = dlopen("libunity.so", RTLD_LAZY);     // 回退到默认搜索路径

            if (h == NULL) {
                char msg[1024];
                snprintf(msg, 0x400, "Unable to load library: %s [%s]", path, dlerror());
                (*env)->FatalError(env, msg);
            } else {
                jint (*onLoad)(JavaVM *, void *) = dlsym(h, "JNI_OnLoad");
                if (onLoad == NULL || onLoad(vm, NULL) < 0x10007)
                    g_unity_lib_handle = h;               // 成功（dlsym 失败也算成功）
                else
                    (*env)->FatalError(env, "Unsupported VM version");
            }
        }
    }
    free(dir);
    return g_unity_lib_handle != NULL;
}
```

* armv7 版本在函数入口（`0x1162`）先调用 cpufeatures 的 `android_getCpuFeatures()`（`0x1bcc`），检查
  `ANDROID_CPU_ARM_FEATURE_NEON`（bit 2）；不支持 NEON 时直接 `return false`，不复制字符串、不装载 `libunity.so`。
  arm64 没有这一步（ARMv8 的 ASIMD 为必需）。
* 参数 `jpath` 是 `ApplicationInfo.nativeLibraryDir`；本库拼成 `<nativeLibraryDir>/libunity.so` 后 `dlopen`。
* 第一次 `dlopen` 失败时回退到不带路径的 `dlopen("libunity.so")`，由动态链接器按默认路径查找。
* 版本判断只看 `libunity.so!JNI_OnLoad` 的返回值：`< 0x10007` 即视为成功。`0x10007` 不是标准
  `JNI_VERSION_*`，含义等价于「不超过 1.6」；`libunity.so` 实测返回 `0x10006`，因此通过。
* `dlsym` 返回 `NULL` 也写入全局句柄并返回成功——即 `libunity.so` 缺少 `JNI_OnLoad` 不会在这里报错。
* 已加载时直接跳过装载，但仍会复制一次 Java 字符串并 `free`。

### `NativeLoader.unload`

```c
bool unload(JNIEnv *env, jclass clazz) {
    void *h = g_unity_lib_handle;
    if (h != NULL) {
        g_unity_lib_handle = NULL;
        JavaVM *vm = NULL;
        if ((*env)->GetJavaVM(env, &vm) < 0) {
            (*env)->FatalError(env, "Unable to retrieve Java VM");
        } else {
            void (*onUnload)(JavaVM *, void *) = dlsym(h, "JNI_OnUnload");
            if (onUnload != NULL)
                onUnload(vm, NULL);
            dlclose(h);
        }
    }
    return true;
}
```

先清空全局句柄，再对 `libunity.so` 调用 `JNI_OnUnload`（若存在），最后 `dlclose`。

### 加载链

`libmain.so` 由 Java 显式加载，之后 `libmain` 再装载 `libunity.so`：

```java
// com.unity3d.player.UnityPlayer（真实 DEX）
private static String loadNative(ApplicationInfo ai) {
    String libmainPath = ai.nativeLibraryDir + "/libmain.so";   // 仅用于错误信息
    System.loadLibrary("main");                                  // dlopen libmain.so → JNI_OnLoad
    if (NativeLoader.load(ai.nativeLibraryDir))                  // 静态 native
        return "";
    Log.e(..., "NativeLoader.load failure, Unity libraries were not loaded.");
    ...
}

private static void unloadNative() {
    if (q.c())
        NativeLoader.unload();
}
```

`libunity.so` 的 `DT_NEEDED` 首项就是 `libmain.so`（`libmain` 不反向依赖 `libunity`）。其
`JNI_OnLoad`（arm64 `0x3e06a4`、armv7 `0x28ed51`）返回 `0x10006`，通过本库的版本检查；之后由
`libunity.so` 接手 Unity 引擎初始化。

### 全局状态

| 符号                 | arm64     | armv7     | 类型       | 用途                          |
|----------------------|-----------|-----------|------------|-------------------------------|
| `g_unity_lib_handle` | `0x11090` | `0x50f0`  | `void *`   | `libunity.so` 的 `dlopen` 句柄；0 表示未加载 |

没有互斥量或原子操作；`load`/`unload` 未做并发保护，依赖 Java 侧串行调用。

## 引用

* 真实 DEX `classes.dex`：`Lcom/unity3d/player/UnityPlayer;.loadNative`（`0x6e4dfc`）与
  `unloadNative`（`0x6e52c8`）；`Lcom/unity3d/player/NativeLoader;` 只声明两个静态 native 方法。
* `libunity.so`：`DT_NEEDED` 包含 `libmain.so`；`JNI_OnLoad` / `JNI_OnUnload` 由本库的 `load`/`unload` 调用。
* [libil2cpp.so](libil2cpp.so.md)：Unity IL2CPP AOT 代码；[libUnityPlugin.so](libUnityPlugin.so.md)
  的元数据解密插件挂在 IL2CPP 初始化流程上。
* [APK.md](APK.md)：原生库清单；[README.md](README.md)：二进制库加密说明（本库不在加密列表内）。

## 待探究

* [ ] `0x10007` 版本上界的来源：不是标准 `JNI_VERSION_*`，推测是「`JNI_VERSION_1_6 + 1`」的排他上界。
* [ ] `RegisterNatives`/`GetJavaVM` 失败时 `FatalError` 的实际表现未在真机验证（按 JNI 约定应终止进程）。
* [ ] armv7 静态链接的 `libunwind_llvm` 是否会被实际调用；主逻辑只调用了 cpufeatures 的 `android_getCpuFeatures()`。
* [ ] `load`/`unload` 无锁，若被多线程并发调用存在竞态；未观察 Java 侧是否存在这种调用。
* [ ] `.gnu_debuglink` 指向 `libmain.dbg.so`，该调试文件未随 APK 提供，无法恢复局部符号。
