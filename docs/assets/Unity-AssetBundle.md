# Unity AssetBundle

## 来源
资源清单中 `Oz.GameKit.Version.AssetBundleInfo` 类型的对象是 Unity AssetBundle 格式资源，从 `/<version>/Android/JP/AssetBundles/<name>.bdl` 路径下载。

## 解密
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

## 组成
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
