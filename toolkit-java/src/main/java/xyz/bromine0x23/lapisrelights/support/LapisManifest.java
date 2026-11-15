package xyz.bromine0x23.lapisrelights.support;

import lombok.SneakyThrows;
import lombok.experimental.UtilityClass;

import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.io.ByteArrayInputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HexFormat;
import java.util.concurrent.TimeUnit;
import java.util.zip.GZIPInputStream;

public @UtilityClass class LapisManifest {

	public static final byte[] SECRET_KEY = HexFormat.of().parseHex("9ec473ae662f4e2a592a502b903c9ec473ae662f4e2a8d857ea7592750bb903c");
	public static final byte[] IV         = HexFormat.of().parseHex("f184dfb4912bce95dbdb7d975397723f");

	@SneakyThrows
	public static byte[] decrypt(byte[] manifestBytes) {
		var cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
		cipher.init(Cipher.DECRYPT_MODE, new SecretKeySpec(SECRET_KEY, "AES"), new IvParameterSpec(IV));
		try (var is = new GZIPInputStream(new CipherInputStream(new ByteArrayInputStream(manifestBytes), cipher))) {
			return is.readAllBytes();
		}
	}

	@SneakyThrows
	public static byte[] deserialize(byte[] manifestBytes) {
		Path temp = null;
		try {
			temp = Files.createTempFile("lapis", null);
			Files.write(temp, manifestBytes);
			var pb = new ProcessBuilder();
			pb.command("python", "bin/nrbf.py", temp.toAbsolutePath().toString());
			var p = pb.start();
			p.waitFor(10, TimeUnit.SECONDS);
			return p.getInputStream().readAllBytes();
		} finally {
			if (temp != null) {
				Files.deleteIfExists(temp);
			}
		}
	}

}
