# libtolua.so

## 概要

| 项     | 值                                                                                                                                                           |
|--------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 功能   | tolua_runtime `1.0.8.584`（tolua 版本串 `1.0.7`）+ 修改版 LuaJIT 2.1.0-beta3（加密字节码、`table`/`exdata` 扩展）+ 内置 C 扩展库；加载时自解密 `.luaniceway` |
| ABI    | `arm64-v8a`、`armeabi-v7a`                                                                                                                                   |
| 工具链 | arm64：NDK r16b `Android clang 5.0.300080`；armv7：NDK r10 系列 `GCC 4.9 20140827`；LuaJIT 汇编由 `DynASM 1.4.0` 生成                                        |
| 依赖   | `libc.so`、`libm.so`、`libstdc++.so`、`libdl.so`                                                                                                             |
| 使用   | 托管 `LuaInterface.LuaDLL` 以 `[DllImport("tolua")]` 引用全部 Lua API，由 IL2CPP P/Invoke 在首次调用时加载                                                   |

## 文件

| 版本              | ABI           | 大小   | SHA-256                                                            |
|-------------------|---------------|--------|--------------------------------------------------------------------|
| `1.0.3`–`1.5.0`   | `arm64-v8a`   | 742416 | `782C99B9103C002D78898EEE9FACA0029E2C4AE76AC63AF604B85972A9C6835A` |
| `1.0.3`–`1.5.0`   | `armeabi-v7a` | 525328 | `C762AEDA5C9190DE0707F49DC7DCB107DB9EE928C5A1E1908EBC65F52FC024FA` |

1.0.3 – 1.5.0 逐版本、逐 ABI 完全相同，没有随游戏版本重编译。

下文地址均为 1.5.0 `arm64-v8a` 的 RVA。

### 文件结构

以 1.5.0 `arm64-v8a` 为例：

| 节              | 地址      | 大小      | 说明                                                        |
|-----------------|-----------|-----------|-------------------------------------------------------------|
| `.hash`         | `0x1f0`   | `0x10e4`  | SysV 哈希表                                                 |
| `.dynsym`       | `0x12d8`  | `0x3450`  | 558 项：385 个函数、1 个对象、163 个导入（含 1 个空名）     |
| `.dynstr`       | `0x4728`  | `0x1b65`  | 动态字符串                                                  |
| `.rela.dyn`     | `0x6750`  | `0x65b8`  | 相对重定位；填写 `.init_array` / `.fini_array`              |
| `.rela.plt`     | `0xcd08`  | `0x21a8`  | 导入函数重定位                                              |
| `.plt`          | `0xeeb0`  | `0x1690`  | 导入跳板（`kcgetLibAddr`/`kcDecodeFunc` 等内调用亦经 PLT）  |
| `.text`         | `0x10540` | `0x7ecc8` | tolua 运行时、LuaJIT、扩展库；**明文**                      |
| `.luaniceway`   | `0x8f208` | `0x28bc`  | tolua 扩展函数与字节码加载器；**加密**                      |
| `.rodata`       | `0x91ad0` | `0x7718`  | 字符串、浮点常量、Lua 库定义字节码                          |
| `.eh_frame_hdr` | `0x991e8` | `0x10b4`  | 异常帧索引                                                  |
| `.eh_frame`     | `0x9a2a0` | `0x4e50`  | 异常帧                                                      |
| `.init_array`   | `0xafcf0` | `0x10`    | 文件中为 0，重定位后 `[0] = init_func`                      |
| `.fini_array`   | `0xafd00` | `0x10`    | 文件中为 0，重定位后 `[0] = 0x105e0`（`__cxa_finalize` 桩） |
| `.data.rel.ro`  | `0xafd10` | `0x2540`  | `luaL_openlibs` 库表、tolua 注册表                          |
| `.dynamic`      | `0xb2250` | `0x200`   | `SONAME = libtolua.so`，`FLAGS_1 = DF_1_NOW`                |
| `.got`          | `0xb2450` | `0xba8`   | 全局偏移表                                                  |
| `.data`         | `0xb3000` | `0xa38`   | `toluaflags`（`0xb3008`）等                                 |
| `.bss`          | `0xb3a40` | `0x1248`  | 注册表索引、`string.dump` 加密偏移 `0xb4a28` 等             |
| `.comment`      | `0xa3a38` | `0x71`    | `Android clang 5.0.300080`、`GCC 4.9.x`、`DynASM 1.4.0`     |
| `.shstrtab`     | `0xa3aa9` | `0x11567` | 声明长度被加壳器放大到覆盖整个尾部；真实名字止于 `0xa3b86`  |
| `.4b27a707e3`   | `0xb5010` | `0x3e8`   | 自解密描述符（`e_entry` 指向此处），其余为填充              |

第一个 `PT_LOAD` 覆盖 `0x0`–`0xb53f8`（R+X），所以描述符虽在节表中标记为不可执行，运行时仍被映射；
第二个 `PT_LOAD` 把 `0xafcf0` 起的数据段重新映射为 RW。

## 导出

`.dynsym` 共 558 项：385 个已定义函数（`.text` 370、`.luaniceway` 15）、1 个对象
（`toluaflags`）、163 个导入（含 1 个空名）、7 个链接器绝对符号，其余为空/节符号。

| 地址      | 符号                | 签名                                                                                  | 功能                                                   |
|-----------|---------------------|---------------------------------------------------------------------------------------|--------------------------------------------------------|
| `0x107b8` | `init_func`         | `void init_func(void)`                                                                | `.init_array[0]`：调用 `kcDecodeFunc("libtolua.so")`   |
| `0x106f8` | `kcDecodeFunc`      | `void kcDecodeFunc(const char *libName)`                                              | 解密自身的 `.luaniceway`                               |
| `0x1061c` | `kcgetLibAddr`      | `uintptr_t kcgetLibAddr(const char *libName)`                                         | 从 `/proc/<pid>/maps` 取库基址                         |
| `0x11060` | `tolua_loadbuffer`  | `int tolua_loadbuffer(lua_State *, const char *, int, const char *)`                  | 转调 `luaL_loadbuffer`（解密路径）                     |
| `0x494b4` | `luaL_loadbuffer`   | `int luaL_loadbuffer(lua_State *, const char *, size_t, const char *)`                | 置 `mode = NULL` 后转调 `luaL_loadbufferx`             |
| `0x49488` | `luaL_loadbufferx`  | `int luaL_loadbufferx(lua_State *, const char *, size_t, const char *, const char *)` | 使用解密 reader `0x917d0` 调用 `lua_loadx`             |
| `0x494bc` | `luaL_loadstringx`  | `int luaL_loadstringx(lua_State *, const char *, size_t, const char *, const char *)` | 使用明文 reader `0x917b0` 调用 `lua_loadx_forstr`      |
| `0x91a08` | `lua_loadx_forstr`  | `int (lua_State *, lua_Reader, void *, const char *, const char *)`                   | `.luaniceway` 中的 `lua_loadx` 副本                    |
| `0x12df8` | `tolua_openlibs`    | `void tolua_openlibs(lua_State *)`                                                    | 打开 Lua 标准库并注册 int64/uint64/Mathf/tolua         |
| `0x12d9c` | `tolua_openlualibs` | `int tolua_openlualibs(lua_State *)`                                                  | 注册 Vector2/3/4、Color、Quaternion、LayerMask、Update |

按符号前缀统计：

| 组          | 数量 | 内容                                                           |
|-------------|------|----------------------------------------------------------------|
| `tolua_*`   | 101  | tolua# 运行时（class/module/ref/值类型/协程回调等）            |
| `lua_*`     | 90   | LuaJIT C API                                                   |
| `luaL_*`    | 45   | 辅助库 API                                                     |
| `luaopen_*` | 18   | 标准库与内置扩展库入口                                         |
| `luaJIT_*`  | 5    | `luaJIT_setmode`、profile 三件套、`luaJIT_version_2_1_0_beta3` |
| 其它        | 126  | luasocket/mime/strbuf/cjson/lpeg 内部函数、`kc*` 保护函数      |

内置扩展库由符号与版本串确认：`luaopen_pb`（lua-protobuf）、`luaopen_lpeg`（LPeg `0.10`）、
`luaopen_struct`、`luaopen_cjson`/`luaopen_cjson_safe`（lua-cjson `2.1.0`）、
`luaopen_socket_core`/`luaopen_mime_core`（LuaSocket `3.0-rc1`、MIME `1.0.3`）。

这些扩展库与 `tolua.c` 的 C API 部分来自 tolua_runtime `1.0.8.584`；对照其源码后确认 tolua 函数体未被改写，
游戏改动集中在 LuaJIT 与 `.luaniceway` 的布局上，见下文“上游对比”。

## 加固

* **自解密**：`.init_array` 经 `R_AARCH64_ABS64` 重定位填入 `init_func`。它尾调用
  `kcDecodeFunc("libtolua.so")`；后者用 `/proc/self/maps` 定位自身，读取 `e_entry` 处 12 字节描述符，
  `mprotect(RWX)` 后按 `key % 9` 取反 `.luaniceway`，再改回 RX。
* **加密范围**：整个 `.luaniceway`（约 50 个函数）全部取反，而 tolua/LuaJIT 主体仍在明文 `.text`，
  因此 hook `luaL_loadbuffer`/`lua_loadx` 不需要先解密。
* **描述符**：`e_entry = 0xb5010` 指向 `.4b27a707e3`，而不是代码入口；反汇编器会误认为 `start`。
* **节表伪装**：`.shstrtab` 的 `offset/size` 被放大到 `0xa3aa9 + 0x11567 = 0xb5010`，把追加的描述符节
  和节头表都包进“字符串表”；`.4b27a707e3` 的名字存放在该范围的末尾。
* 普通 ELF 加固：Full RELRO（`DF_1_NOW` + `PT_GNU_RELRO`）、NX 栈、已 strip、无 RPATH/RUNPATH。

描述符参数：

| ABI           | `e_entry` | 被解密段      | offset    | length   | key          | `key % 9` | 取反步长      |
|---------------|-----------|---------------|-----------|----------|--------------|-----------|---------------|
| `arm64-v8a`   | `0xb5010` | `.luaniceway` | `0x8f208` | `0x28bc` | `0x1FBADBE6` | 0         | 全部          |
| `armeabi-v7a` | `0x80010` | `.luaniceway` | `0x726e8` | `0x1ef8` | `0x49175688` | 3         | 每第 3 个字节 |

## 功能点

### 启动与自解密

```c
void init_func(void) { kcDecodeFunc("libtolua.so"); }

void kcDecodeFunc(const char *name) {
    uintptr_t base = kcgetLibAddr(name);              // 首条含该名的 /proc/self/maps 映射
    uint32_t *d = (uint32_t *)(base + ((Elf64_Ehdr *)base)->e_entry);
    uint8_t *addr = (uint8_t *)(base + d[0]);
    uint32_t len = d[1], key = d[2];
    size_t page = (uintptr_t)addr & ~0xfffUL;
    size_t size = (0x2000 + len) & ~0xfffUL;          // 长度非页对齐时多映射一页
    mprotect(page, size, PROT_READ | PROT_WRITE | PROT_EXEC);
    if (key % 9 == 0) {
        for (uint32_t i = 0; i < len; i++) addr[i] = ~addr[i];
    } else {
        for (uint32_t i = 0; i < len; i++)
            if (i % (key % 9) == 0) addr[i] = ~addr[i];
    }
    mprotect(page, size, PROT_READ | PROT_EXEC);
}
```

`kcDecodeFunc`/`kcgetLibAddr` 只有一份实现；库内对它们的调用经由 `.plt` 跳板
（`0x102b0`、`0x10260`）转发到导出地址，所以反汇编会看到同一函数出现两个入口。

### 加密 LuaJIT 字节码的加载

`luaL_loadbufferx`（`0x49488`）没有使用标准的内存 reader，而是把 `{ptr, len}` 传给
解密 reader（`0x917d0`）：

```c
typedef struct { const char *p; size_t n; } MemBuf;

static const char *decrypt_reader(lua_State *L, MemBuf *mb, size_t *sz) {
    size_t n = mb->n;
    if (!n) return NULL;                              // 第二次调用即 EOF
    uint8_t *p = (uint8_t *)mb->p;
    for (size_t i = 0; i < n; i++)
        p[i] ^= (uint8_t)(0xABCDEF >> ((i % 0x607) % 5));   // 原地解密
    mb->n = 0;
    *sz = n;
    return mb->p;
}

int luaL_loadbufferx(lua_State *L, const char *buff, size_t sz,
                     const char *name, const char *mode) {
    MemBuf mb = { buff, sz };
    return lua_loadx(L, decrypt_reader, &mb, name, mode);
}
```

* 密钥流周期为 `0x607 * 5`，逐字节对齐，因此可以原地、分块处理；本库的 reader 一次处理整个缓冲区。
* `luaL_loadstringx`（`0x494bc`）仍使用明文 reader `0x917b0`，走 `.luaniceway` 中的
  `lua_loadx_forstr`。Lua 层同样被拆分：`load`（`0x8035c`）走解密版 `luaL_loadbufferx`，
  `loadstring`（`0x8022c`）被改成 `luaL_loadstringx` 的明文副本。
* `luaL_loadfilex`（`0x492bc`）使用 `.luaniceway` 中的文件 reader `0x9194c`：每次 `fread` 1024 字节后
  都从密钥流下标 0 开始解密。文件大于 1024 字节时第二个块起的密钥流会错位，因此该路径对实际脚本不可用，
  游戏也只通过 `luaL_loadbuffer` 加载整块脚本。
* 副作用（推断）：`LuaState.DoString` 最终调用 `luaL_loadbuffer`，其明文源码同样会被异或。
  生产流程只用 `DoFile`；`DoString` 仅出现在 ZeroBraneStudio 调试与未使用的重载路径。

### `string.dump` 的加密输出

`lua_dump`（`0x49520`）本体是标准实现：受保护调用 `0x49030` 写字节码，由调用方提供 writer。
基础库的 `string.dump`（`0x818b0`）把 writer 换成 `0x813c0`，用同一密钥流**加密**输出：

```c
static size_t g_dump_off;                             // .bss:0xb4a28

static int encrypt_writer(lua_State *L, const void *p, size_t sz, Buf *out) {
    uint8_t *q = (uint8_t *)p;
    for (size_t j = 0; j < sz; j++)                   // 密钥流下标跨写入块连续
        q[j] ^= (uint8_t)(0xABCDEF >> (((g_dump_off + j) % 0x607) % 5));
    g_dump_off += sz;
    buf_append(out, p, sz);
    return 0;
}
```

即：输出可用 Lua `load(str)`（走解密版 `luaL_loadbufferx`）或 `luaL_loadbuffer` 重新加载；
Lua 的 `loadstring` 被改成明文路径，不能直接加载该输出。`g_dump_off` 在库内没有复位点，
连续两次 `string.dump` 的第二次会从上次偏移继续（游戏未使用该 API）。

### 修改后的字节码格式

* 头部由字节码写出函数（`0x49030`）写出：`ESC 'P' 'O' 0x82`，随后是 flags 字节；
  flags 低 4 位有效且必须包含 `0x08`（FR2，64 位），`0x02` 表示 strip，`0x04` 表示 FFI。
  版本号 `0x82 = 0x80 | 2`，符合上游 `lj_bcdump.h` 对私有格式“使用 >= 0x80”的要求。
* 二进制块读取器（`0x4859c`）校验 `'P'`、`'O'`、`0x82` 与 FR2 位；词法初始化（`0x403e8`）在
  首个字节为 `0x1b` 时选择二进制解析，同时兼容 UTF-8 BOM 与 `#!` 行。
* 指令编号被重排（`MOV`/`NOT`/`UNM`/`LEN` 移到 `ISEQV` 前），VM 与读写器按新编号生成；
  `.rodata:0x95010` 的 97 项 `lj_bc_mode` 已与上游表逐项比对确认，详见 [Lua.md](../assets/Lua.md)。

### 模块注册

`luaL_openlibs`（`0x8b920`）打开 `base/package/table/io/os/string/math/debug/bit/jit`，
并把 `ffi` 放进 `package.preload`（基础库函数表由库定义字节码注册）。`tolua_openlibs`（`0x12df8`）在其上：

1. `tolua_setluabaseridx`：把 registry 1–64 预填为索引，写入 thread、全局表、`require`。
2. `tolua_opentraceback`：注册 `debug.traceback` 与自定义 traceback（`0x9076c`）。
3. 把 `package.preload`/`package.loaded` 缓存到 registry 25/26。
4. `tolua_openint64`/`tolua_openuint64`、`Mathf` 表、`tolua` 表（`gettag`/`settag`/`version = 1.0.7`）。
5. registry 21 为类表，安装受保护的 `__index`/`__newindex`（`0x9030c`/`0x9045c`）。

`tolua_openlualibs`（`0x12d9c`）在 `lua_pcall` 中执行 `0x90ea0`，依次注册
`Vector3`、`Vector2`、`Vector4`、`Color`、`Quaternion`、`LayerMask` 的 `New`/`Get`，
以及 `Update`/`LateUpdate`/`FixedUpdate` 回调。

其余 `pb`/`struct`/`lpeg`/`socket`/`mime`/`cjson` 不在此处注册，由托管的 `LuaManager.OpenLibs`
调用各自的 `luaopen_*` 打开（`socket.core`/`mime.core` 通过 `package.preload` 注册）。

### 受保护的 `.luaniceway`

这些函数来自 `tolua.c` 的 open/元方法/Mathf 子集与 `lj_load.c` 的静态加载辅助函数（`cpparser`、
`reader_string`、`reader_file`、解密 reader），由游戏按符号放入该段，而不是整目标文件迁移。

该节约有 50 个函数，全部被自解密覆盖，分为三组：

| 地址范围            | 内容                                                                                                                                                                                                                                                              |
|---------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `0x8f208`–`0x90278` | tolua 表/对象索引、`__index`/`__newindex`、错误格式化（14 个）                                                                                                                                                                                                    |
| `0x90278`–`0x90ea0` | 14 个导出（`tolua_openvptr`、`tolua_setluabaseridx`、`tolua_openpreload`、`tolua_opentraceback`、`tolua_openubox`、`tolua_openfixedmap`、`tolua_openvaluetype`、6 个 `tolua_openlua*` 值类型、`tolua_openupdate`）+ 3 个内部实现（`0x9030c`/`0x9045c`/`0x9076c`） |
| `0x90ea0`–`0x91ac4` | 值类型装箱、`Mathf` 辅助、traceback、明文 reader `0x917b0`、文件 reader `0x9194c`、解密 reader `0x917d0`、解析入口 `0x91860`、`lua_loadx_forstr`（`0x91a08`）                                                                                                     |

加固意图是隐藏“加密字节码如何被解析”这一环：`0x917d0` 与解析入口同在加密段内，单独替换
`.luaniceway` 或直接 hook `luaL_loadbufferx` 都需要先处理自解密。

## 上游对比

对照 `tolua_runtime 1.0.8.584`（`tolua.c` 版本串 `1.0.7`，内置 LuaJIT 2.1.0-beta3）与
LuaJIT 2.1.0-beta3 原始源码，确认基线一致，游戏改动集中在 LuaJIT。
方法：按源码 `BCDEF` 重算 `lj_bc_mode` 后在 `.rodata` 搜索；其余函数用 Kuna 伪代码与上游 C 源码逐条比对。

### 基线

| 组件   | 上游                                                                | 结论                                                                                                                      |
|--------|---------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------|
| tolua  | tolua_runtime 1.0.8.584 `tolua.c`                                   | 函数体一致（`tolua_openlibs`、`tolua_openlualibs`、各 `tolua_open*`、`traceback`、`Mathf`）；部分函数被放入 `.luaniceway` |
| LuaJIT | 2.1.0-beta3（tolua_runtime 内置同一份）                             | 有下述定制，并含 OpenResty 风格的 `table` 扩展；仍导出 `luaJIT_version_2_1_0_beta3`                                       |
| 扩展库 | lua-protobuf、LPeg 0.10、lua-cjson 2.1.0、LuaSocket 3.0-rc1、struct | 直接编译进同一个 `.so`                                                                                                    |

### 字节码格式

| 项       | 上游                                            | 本库                                   | 依据                                          |
|----------|-------------------------------------------------|----------------------------------------|-----------------------------------------------|
| 魔数     | `ESC 'L' 'J'`                                   | `ESC 'P' 'O'`                          | 写出 `0x1b 0x50 0x4f`；读取校验 `0x50`/`0x4f` |
| 版本     | `2`                                             | `0x82`                                 | `lj_bcdump.h` 注释要求私有格式使用 `>= 0x80`  |
| flags    | `0x01` BE、`0x02` strip、`0x04` FFI、`0x08` FR2 | 相同                                   | 读取时强制 FR2                                |
| 指令编号 | ISLT…ISGT、ISEQV…、ISTC…、MOV…                  | ISLT…ISGT、**MOV/NOT/UNM/LEN**、ISEQV… | 见下                                          |

`.rodata:0x95010` 处是 97 项 `uint16_t lj_bc_mode`。按上游 `lj_bc.h` 的 `BCDEF` 重新计算，
“仅把 MOV/NOT/UNM/LEN 移到 ISGT 之后”得到的数组与二进制逐字节一致，即：

```text
0 ISLT   1 ISGE   2 ISLE   3 ISGT
4 MOV    5 NOT    6 UNM    7 LEN
8 ISEQV  9 ISNEV  10 ISEQS 11 ISNES 12 ISEQN 13 ISNEN 14 ISEQP 15 ISNEP
16 ISTC  17 ISFC  18 IST   19 ISF   20 ISTYPE 21 ISNUM 22 ADDVN …
```

其余 opcode 的相对顺序不变（共 97 个）。这同时验证了 [Lua.md](../assets/Lua.md) 中“MOV/NOT/UNM/LEN
编号移到 ISEQV 前”的结论。

### 加载与写出路径

| 上游位置                       | 上游实现                        | 本库                                                                                       |
|--------------------------------|---------------------------------|--------------------------------------------------------------------------------------------|
| `lj_load.c: luaL_loadbufferx`  | `reader_string`                 | 换成解密 reader `0x917d0`                                                                  |
| `lj_load.c: reader_file`       | 直接 `fread`                    | 增加 XOR 解密，但每次 1024 字节都从密钥流下标 0 开始，多块文件会错位                       |
| `lj_load.c: luaL_loadstring`   | 转调 `luaL_loadbuffer`          | 改调新增的 `luaL_loadstringx` → `lua_loadx_forstr`（明文路径，绕开解密）                   |
| `lj_load.c`                    | 无                              | 新增 `luaL_loadstringx`（`0x494bc`）与 `lua_loadx_forstr`（`0x91a08`，`lua_loadx` 的副本） |
| `lib_base.c: lj_cf_load`       | 字符串分支用 `luaL_loadbufferx` | 相同（因此 Lua `load` 会解密）                                                             |
| `lib_base.c: lj_cf_loadstring` | `return lj_cf_load(L)`          | 复制 `lj_cf_load` 函数体，字符串分支改调 `luaL_loadstringx`（明文）                        |
| `lib_string.c: string_dump`    | `writer_buf`                    | 换成加密 writer `0x813c0`（全局偏移 `0xb4a28`）                                            |
| `lj_bcwrite.c: bcwrite_pt`     | 写 `'L','J',2`                  | 写 `'P','O',0x82`                                                                          |
| `lj_bcread.c: lj_bcread`       | 校验 `'L','J',2`                | 校验 `'P','O',0x82`                                                                        |

这一分组是有意为之：`loadstring`/`luaL_loadstring` 继续接受明文源码，而
`load`/`luaL_loadbuffer`/`luaL_loadfile` 处理加密资源。

### table 扩展

`luaopen_table`（`0x83908`）在标准 `table` 注册后追加 4 个 preload（beta3 只有 `table.new`/`table.clear`）：

| preload         | 实现                  | FF id  | 功能                                 |
|-----------------|-----------------------|--------|--------------------------------------|
| `table.clone`   | `0x83090` → `0x310d4` | `0x5e` | 按原布局新建表，浅拷贝数组与哈希节点 |
| `table.isarray` | `0x83044` → `0x323dc` | `0x5f` | 哈希键是否全为整数                   |
| `table.nkeys`   | `0x82ff8` → `0x32448` | `0x60` | 统计数组/哈希部分的非 nil 键         |
| `table.isempty` | `0x82fac` → `0x324b8` | `0x61` | 数组与哈希部分均为空                 |

`table.new`（FF `0x63`）与 `table.clear`（FF `0x64`，最终调用 `lj_tab_clear` `0x311c0`）为 beta3 已有。
上述 4 个函数不在 beta3 与 tolua_runtime 的 `lib_table.c` 中，行为与 OpenResty LuaJIT 的同名扩展一致
（推断其来源）。

### exdata 扩展

| 上游                                                               | 本库                                                                                                                                                                         |
|--------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 上游 `lua_State` 最后字段为 `stacksize`（`0x58`），结构大小 `0x60` | 末尾追加 `void *exdata`（`L+0x60`）                                                                                                                                          |
| 无                                                                 | 导出 `lua_setexdata`（`0x3fc40`）/ `lua_getexdata`（`0x3fc48`）                                                                                                              |
| 无                                                                 | `exdata` 函数（FF id `38`，实现 `0x7fe78`）：`luaopen_base` 先注册 `package.preload["thread.exdata"]`，该 preload 运行时再通过 `lj_lib_postreg` 写入全局表 `exdata` 并返回它 |
| 无                                                                 | JIT recorder `recff_thread_exdata`（`0x62770`）                                                                                                                              |

`require "thread.exdata"` 返回 `exdata(ud)`：写入当前线程的 `L->exdata`（参数须为 light userdata）；
无参时创建一个 `cdata<void *>`（ctypeid `17`、TValue 标签 `0xfffa8…`，payload 存 `L->exdata`）返回。
`lua_setexdata`/`lua_getexdata` 直接读写 `L+0x60`。还原的 C# 与 Lua 脚本中均未找到调用方。

### 其它新增导出

* `lj_str_indep_hash`（`0x30a18`）：对 `GCstr` 调用与 `lj_str_new` 相同的 lookup3 哈希（`0x306c0`）；
  库内无调用方，仅作为导出工具函数。
* `lua_getexdata`/`lua_setexdata`、`luaL_loadstringx`、`lua_loadx_forstr`、`recff_thread_exdata`
  均不在上游符号表中。

### 函数对照

| 二进制                      | 上游                                                |
|-----------------------------|-----------------------------------------------------|
| `0x49200 lua_loadx`         | `lj_load.c: lua_loadx`                              |
| `0x492bc luaL_loadfilex`    | `lj_load.c: luaL_loadfilex`（reader 改）            |
| `0x49488 luaL_loadbufferx`  | `lj_load.c: luaL_loadbufferx`（reader 改）          |
| `0x494e8 luaL_loadstring`   | `lj_load.c: luaL_loadstring`（改走新增函数）        |
| `0x49520 lua_dump`          | `lj_load.c: lua_dump`                               |
| `0x91860 cpparser`          | `lj_load.c: cpparser`                               |
| `0x917b0 reader_string`     | `lj_load.c: reader_string`                          |
| `0x9194c reader_file`       | `lj_load.c: reader_file`（改）                      |
| `0x49030 bcwrite_pt`        | `lj_bcwrite.c: bcwrite_pt`（写头 + 常量内联）       |
| `0x4859c lj_bcread`         | `lj_bcread.c: lj_bcread`（校头 + 常量内联）         |
| `0x403e8 lj_lex_setup`      | `lj_lex.c: lj_lex_setup`                            |
| `0x818b0 string_dump`       | `lib_string.c: string_dump`（writer 改）            |
| `0x8035c load`              | `lib_base.c: lj_cf_load`（`luaL_loadbufferx` 解密） |
| `0x8022c loadstring`        | `lib_base.c: lj_cf_loadstring`（改为明文副本）      |
| `0x83908 luaopen_table`     | `lib_table.c: luaopen_table`（增加 4 个 preload）   |
| `0x808ac luaopen_base`      | `lib_base.c: luaopen_base`（增加 exdata 预注册）    |
| `0x12df8 tolua_openlibs`    | `tolua.c: tolua_openlibs`                           |
| `0x12d9c tolua_openlualibs` | `tolua.c: tolua_openlualibs`                        |

`0x403e8`、`0x4859c` 等地址落在工具自动合并的 `sub_40320`、`sub_47d68` 内部，是函数边界未单独切分，
不是额外的包装函数。

## 引用

* `Scripts/Assembly-CSharp/LuaInterface/LuaDLL.cs`：`LUADLL = "tolua"` 与全部 `[DllImport]` 声明；
  `luaL_loadbuffer` 转发到 `tolua_loadbuffer`（`0x11060`）。
* `Scripts/Assembly-CSharp/LuaInterface/LuaState.cs`、`LuaStatePtr.cs`：创建 state、`LuaOpenLibs`、
  `DoFile`/`DoString` 与 `LuaLoadBuffer`。
* `Scripts/Assembly-CSharp/LuaInterface/LuaUnityLibs.cs`：调用 `tolua_openlualibs` 注册 Unity 值类型。
* `Scripts/Assembly-CSharp/Oz/Framework/LuaModule/LuaManager.cs`：打开 `pb`/`struct`/`lpeg`/`socket`/`mime`/`cjson`。
* `com.klab.lapis-1.5.0/output/Il2CppDumper-v6.7.46/dump.cs`：`LuaResLoader.DecryptLuaFile`（RVA `0x1F83D14`）
  处理 Lua 资源的封装，`LuaResLoader.SHA1_KEY_LEN = 20`；实测封装为
  “20 字节 SHA1（内容为**加密后**的脚本体）+ 脚本体 + 32 字节大写 HEX MD5”，MD5 的输入未知。
* [Lua.md](../assets/Lua.md)：脚本封装、加密算法、指令编号与字节码布局。
* [README.md](README.md)：二进制库通用的“`e_entry` 描述符 + 按 `key % 9` 取反”加壳格式。
* 对照源码：tolua_runtime `1.0.8.584`（`tolua.c`、内置 `luajit-2.1`）与 LuaJIT 2.1.0-beta3；
  差异见 [上游对比](#上游对比)。

## 待探究

* [ ] 已对照 `tolua_runtime 1.0.8.584` 抽查主要函数，未做全量逐字节 diff。
* [ ] armv7 仅核对节结构、描述符与导出；已确认它同样导出 `lua_loadx_forstr`/`luaL_loadstringx`/`lua_*exdata`/
  `lj_str_indep_hash`，`lj_bc_mode` 表（`0x7951c`）与 arm64 相同，且存在 `table.clone` 等 preload，但未逐函数分析；
  `.luaniceway` 解密已用 `key % 9 = 3` 验证首部为合法 Thumb 指令。
* [ ] `string.dump` 加密偏移 `0xb4a28` 无复位点，连续 dump 的行为与实际用途未验证。
* [ ] `lua_loadx_forstr` 与 `lua_loadx` 仅有 `0xd8` 字段差异，复制到受保护段的原因不明。
* [ ] `luaL_loadfilex` 的文件 reader `0x9194c` 每块都重置密钥流下标，是否为已知缺陷/从未被使用未验证。
* [ ] `exdata`（`require "thread.exdata"`）、`lua_getexdata`/`lua_setexdata` 在还原的 C# 与 Lua 脚本中均无调用方，实际用途未确认。
* [ ] `lj_str_indep_hash`（`0x30a18`）在库内无调用方，是否供外部工具使用未确认。
* [ ] `table.clone/isarray/nkeys/isempty` 的来源（OpenResty 补丁或自研）未最终确认；还原的 Lua 脚本中未发现调用。
* [ ] 32 字节 MD5 后缀的输入未还原（不等于密文或明文的 MD5），`LuaResLoader.DecryptLuaFile` 未在 `Scripts/` 中还原。
