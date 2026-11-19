# MasterData

各数据库的功能说明见 [Database.md](../data/Database.md)

## 来源
资源清单中 `Oz.GameKit.Version.MasterDataInfo` 类型的对象是 SQLite 数据库。
实际具有只有两种文件：`MASTERDATA` 和 `MASTERDATA_LANG`，对应参数数据库和文本数据库，分别从 `/<version>/MasterData/master_data.db` 和 `/<version>/Android/JP/master_data_lang.db` 下载。

## 解密
清单中具有三个参数 `key1` `key2` `key3` 为初始密钥，固定为 2000、1500、1000。

游戏下载数据库后会先进行解密，再用随机生成的密钥加密。
本地文件的透明解密由 [libklbsqlite3.so](../program/libklbsqlite3.so.md) 的 `klb_vfs` VFS 完成。

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

[@Francesco149: reversing-sifas]: https://github.com/Francesco149/reversing-sifas
