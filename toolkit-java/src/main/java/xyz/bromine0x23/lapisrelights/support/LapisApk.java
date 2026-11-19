package xyz.bromine0x23.lapisrelights.support;

import lombok.SneakyThrows;
import lombok.experimental.UtilityClass;
import lombok.extern.slf4j.Slf4j;

import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;

/// @author <a href="mailto:bromine0x23@gmail.com">Bromine0x23</>
@Slf4j
public @UtilityClass class LapisApk {

	private static final int[] TARGET_APK_KEYS = {0x5e, 0x2f, 0x97, 0xcb, 0x65, 0xb2};

	@SneakyThrows
	public static byte[] extractDex(Path path) {
		try (var fs = FileSystems.newFileSystem(path)) {
			var dexBytes = Files.readAllBytes(fs.getPath("/classes.dex"));
			var dexSize  = dexBytes.length;
			log.info("classes.dex size: {} [{}]", String.format("%08x", dexSize), path);
			return dexBytes;
		}
	}

	public static byte[] extractTargetApk(byte[] dexBytes) {
		var dexSize = dexBytes.length;
		var targetApkSize = ((dexBytes[dexSize - 4] & 0xFF) << 24)
			| ((dexBytes[dexSize - 3] & 0xFF) << 16)
			| ((dexBytes[dexSize - 2] & 0xFF) << 8)
			| (dexBytes[dexSize - 1] & 0xFF);
		log.info("TargetApk.zip size: {} {}", String.format("%08x", dexSize - targetApkSize), String.format("%08x", targetApkSize));
		return Arrays.copyOfRange(dexBytes, dexSize - targetApkSize - 4, dexSize);
	}

	public static byte[] decryptTargetApk(byte[] cipherBytes) {
		var length     = cipherBytes.length - 4;
		var plainBytes = new byte[length];
		for (var i = 0; i < length; ++i) {
			var k = TARGET_APK_KEYS[i % 6];
			var b = cipherBytes[length - i - 1];
			plainBytes[i] = (byte) (k ^ ~b);
		}
		return plainBytes;
	}

	public static byte[] encryptTargetApk(byte[] plainBytes) {
		var length     = plainBytes.length;
		var cipherBytes = new byte[length + 4];
		for (var i = 0; i < length; ++i) {
			var k = TARGET_APK_KEYS[i % 6];
			var b = plainBytes[i];
			cipherBytes[length - i - 1] = (byte) (k ^ ~b);
		}
		return cipherBytes;
	}

}
