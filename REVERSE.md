# REVERSE

[[_TOC_]]

## 程序

### 二进制库

清单：
```
lib\
  arm64-v8a\           # 用于64位ARM架构
    libil2cpp.so       # 游戏主要代码
    libtolua.so        # 用于处理 LuaJit 脚本
    libklbsqlite3.so   # 用于处理数据库
    libLapis.so        #
    libklabniceway.so  # 被 DEX 脱壳处理使用
  armeabi-v7a\         # 用于32位ARM架构
```

* libil2cpp.so

### 二进制库加密

以下二进制库存在加密，在加载时会自动解密:
- `libtolua.so`
- `libLapis.so`
- `libklabniceway.so`

解密通过 `.init_array` 段的初始化代码进行：
读取 `elf.e_entry` 指向的地址，获取 `address`、`length`、`key` 三个参数。
```
--------------------
|  ...               |
|  0x18 e_entry      |
|  ...               |
|  ...               |
|  address (4B)      | <- e_entry
|  length  (4B)      |
|  key     (4B)      |
|  ...               |
|  ...               |
|  加密段             | <- address
|  ...               |
|  ...               |
--------------------
```

然后对 `address` 开始的 `length` 个字节，每第 `key % 9` 个字节取反（为 0 时全部取反）。

### DEX 加壳
使用了 [guanchao/apk_auto_enforce: jiagu.py] 中的方法隐藏了真实 class.dex。
相关处理使用 `libklabniceway.so` 库。
```
--------------------
|  脱壳用 classes.dex |
--------------------
|  加密源 APK         |
--------------------
|  源 APK 大小        |
--------------------
```

解密算法如下，简单来说就是：逆序+取反+异或密钥：
```java
private static final int[] KEY = {0x5e, 0x2f, 0x97, 0xcb, 0x65, 0xb2};

public byte[] decrypt(byte[] cipher) {
  byte[] plain = new byte[cipher.length];
  for (int i = 0; i < plain.length; ++i) {
      int k = KEY[i % 6];
	  int b = cipher[length - i - 1];
      plain[i] = (byte) (k ^ ~b);
  }
  return plain;
}
```

### global-metadata.dat
从 1.3.0 版本开始，Unity 引擎所需的 global-metadata.dat 元数据以加密形式存在于 APK 文件的 `assets\bin\Data\Managed\Metadata\game.dat` 路径。

## 资源

### ~~资源下载~~
> 游戏已经停止运营，游戏资源已无法下载

游戏资源在 `https://prod-lapis-pack.you-zhe.com` 路径下获取，没有身份认证，但需要设置 `X-Unity-Version` 请求头：
```shell
curl -X HEAD -H "X-Unity-Version: 2019.4.26f1c1" --location "https://prod-lapis-pack.you-zhe.com/<path>"

curl -X HEAD -H "X-Unity-Version: 2019.4.26f1c1" --location "https://prod-lapis-pack.you-zhe.com/assets/products/resources"
```

### 资源清单
`manifest.xml` 是游戏资源清单文件，从 `/<manifestVersion>/Android/JP/manifest.xml` 路径下下载。

`manifestVersion` 可以使用游戏主界面显示的版本，比如 `202209301251-1-a9c916bdcd`，或者资源清单内部的资源版本，比如 `202209301249-1-298166`。

如 [@MalitsPlus: Lapis Re:LiGHTs 资源解析] 中所述，资源清单存在加密，解密步骤为：
1. 使用 `AES/CBC/PKCS5Padding` 解密，
   密钥 `9ec473ae662f4e2a592a502b903c9ec473ae662f4e2a8d857ea7592750bb903c` (HEX)，
   初始化向量 `f184dfb4912bce95dbdb7d975397723f` (HEX)。
1. GZIP 解压缩
1. C# BinaryFormatter 反序列化

在不知道原始类结构的情况下，无法在 C# 中通过 BinaryFormatter 进行反序列化。
但使用 [gurnec/Undo_FFG: nrbf.py] 脚本，可以直接将序列化数据导出为 JSON，绕过了对原始类结构的需要。

### Unity AssetBundle
资源清单中 `Oz.GameKit.Version.AssetBundleInfo` 类型的对象是 Unity AssetBundle 格式资源，从 `/<version>/Android/JP/AssetBundles/<name>.bdl` 路径下载。
清单中参数 `key` 非 0 表示文件被加密，需要解密。

解密算法为：
```java
public static void assetBundleDecrypt(byte[] bytes, int key) {
	var step  = Math.abs(key % 10) + 1;
	var align = Math.abs(key / 10 % 10) + 1;
	var length = bytes.length;
	for (int index = 0, start = 0; start < length; ++index, start += step) {
		var x = 1103515245 * index + 12345;
		if (x < 0) {
			x = 1103515245 * index + 77880;
		}
		var h = x >> 16;
		bytes[start] ^= key >> ((h & 0x00FFL) - (h & 0x7FFFL) / align * align);
	}
}
```

资源目录结构大致如下：
```
AssetBundles\ #
  assets\
    products\
      resources\
        actors\                    # 3D 模型
        ar\                        # AR 相关
        battle\                    # 战斗相关
        card\                      # Spine 角色卡图
        luajit32\                  # 用于 32位架构的 LuaJIT 脚本
        luajit64\                  # 用于 64位架构的 LuaJIT 脚本
        story\                     # 剧情故事脚本
        ui\                        # UI 相关
        uidyatlas\                 # UI 动态图集资源
        uispine\                   # UI 相关 Spine 资源
        videos\                    # 视频动画
        ...
```

### MasterData（数据库）
资源清单中 `Oz.GameKit.Version.MasterDataInfo` 类型的对象是 SQLite 数据库。
实际具有只有两种文件：`MASTERDATA` 和 `MASTERDATA_LANG`，对应参数数据库和文本数据库，分别从 `/<version>/MasterData/master_data.db` 和 `/<version>/Android/JP/master_data_lang.db` 下载。
清单中具有三个参数 `key1` `key2` `key3` 为初始密钥，固定为 2000、1500、1000。

游戏下载数据库后会先进行解密，再用随机生成的密钥加密。

实际初始解密时使用的参数为 1972=2000^100, 1354=1500^150, 800=1000^200。

根据 [@Francesco149: reversing-sifas]，加解密算法为：
```java
public static byte[] databaseDecrypt(byte[] ciphertext, int k1, int k2, int k3) {
	var keys      = databaseKeys(ciphertext.length, k1, k2, k3);
	var plaintext = new byte[ciphertext.length];
	for (var i = 0; i < plaintext.length; ++i) {
		plaintext[i] = (byte) (ciphertext[i] ^ keys[i]);
	}
	return plaintext;
}
private static final long LCG_A    = 0x000343FDL;
private static final long LCG_C    = 0x00269EC3L;
private static final long LCG_MASK = 0xFFFFFFFFL;
private static byte[] databaseKeys(int length, int k1, int k2, int k3) {
	var keys = new byte[length];
	for (var i = 0; i < length; ++i) {
		keys[i] = (byte) (((k1 >> 24) & 0xFF) ^ ((k2 >> 24) & 0xFF) ^ ((k3 >> 24) & 0xFF));
		k1      = (int) ((((k1 * LCG_A) & LCG_MASK) + LCG_C) & LCG_MASK);
		k2      = (int) ((((k2 * LCG_A) & LCG_MASK) + LCG_C) & LCG_MASK);
		k3      = (int) ((((k3 * LCG_A) & LCG_MASK) + LCG_C) & LCG_MASK);
	}
	return keys;
}
```

### Wwise SoundBank
资源清单中 `Oz.GameKit.Version.SoundBankInfo` 类型的对象是 Wwise SoundBank 格式的音频数据，从 `/<version>/Android/SoundBanks/<name>.bnk` 路径下载。

文件没有加密，但 Wwise 引擎本身的工作机制将音频事件名进行了哈希处理，需要通过事件名模式、已有的事件名进行猜测和逆向。
参见[bnnm/wwiser-utils: REVERSING WWISE NUMBERS]。

利用 wwiser-utils 逆向工具，参考剧情脚本、参数数据库的语音播放事件名，可以大致总结出语音事件的命名模式：
* `Play_<group>_<speaker>_<no><suffix>`，
* `<group>` 一般是 SoundBank 文件名，但也有存在差异的情况
* `<speaker>` 是说话人编号，推测前三位用于标识声优，第四位用于区分所配音的人物
* `<no>` 是时间线编号（或单纯的序号），一般从 `0001` 开始按顺序递增，但存在疑似废案的数据会使用 `1001` 开始的值
* `<suffix>` 是可选的，可能为 `b`、`c`、`_b`、`_c`、`_1` 等，猜测也是用于废案。
* e.g. `Play_VOX_EVT_0001_01_01_0010_0001`
  + `groug = VOX_EVT_0001_01_01`，0001号活动语音第1话
  + `speaker = 0010`，ティアラ（安齋由香里）
  + `no = 0001`，时间线顺序 `0001`

### 卡图
Unity AssetBundle 资源中存在使用 Spine 的 2D 动画。

贴图文件未经过 premultiplied alpha 处理。

### 脚本
游戏使用 [tolua] 框架加载和运行 [LuaJIT] 脚本。

游戏中的 Lua 脚本资源由三部分组成：
1. 20字节二进制格式的 SHA1 签名，由第二部分计算得出；
1. 主体，脚本字节码；
1. 32字节HEX格式 MD5 签名，生成方式不明。

游戏对原始 LuaJIT 字节码进行了以下修改：
* 加密：`plaintext[i] = (byte) (((0xabcdef >> ((i % 0x607) % 5)) & 0xFF) ^ ciphertext[i])`
* 指令变更：`MOV`、`NOT`、`UNM`、`LEN` 编号移至 `ISEQV` 前，即 `MOV=4 NOT=5 UNM=6 LEN=7 ISEQV=8 ...`
* 格式变更：
  + 修改文件头魔数，`header = ESC 'P' 'O' '0x82' flagsU [namelenU nameB*]`
  + `bcinsW` 和 `uvdataH` 顺序对换，即 `pdata  = phead uvdataH* bcinsW* kgc* knum* [debugB*]`


[guanchao/apk_auto_enforce: jiagu.py]: https://github.com/guanchao/apk_auto_enforce/blob/master/jiagu.py
[@MalitsPlus: Lapis Re:LiGHTs 资源解析]: https://malitsplus.blogspot.com/2022/01/lapis-relights.html
[gurnec/Undo_FFG: nrbf.py]: https://github.com/gurnec/Undo_FFG/blob/master/nrbf.py
[@Francesco149: reversing-sifas]: https://github.com/Francesco149/reversing-sifas
[bnnm/wwiser-utils: REVERSING WWISE NUMBERS]: https://github.com/bnnm/wwiser-utils/blob/master/doc/NAMES.md
[LuaJIT]: https://luajit.org
[tolua]: https://github.com/topameng/tolua