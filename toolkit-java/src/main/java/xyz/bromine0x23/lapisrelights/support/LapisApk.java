package xyz.bromine0x23.lapisrelights.support;

import lombok.experimental.UtilityClass;
import lombok.extern.slf4j.Slf4j;

import java.util.Arrays;

/// @author <a href="mailto:bromine0x23@gmail.com">Bromine0x23</>
@Slf4j
public @UtilityClass class LapisApk {

	private static final int[] TARGET_APK_KEYS = {0x5e, 0x2f, 0x97, 0xcb, 0x65, 0xb2};

	public static byte[] extractTargetApk(byte[] source) {
		var sourceLength = source.length;
		var targetLength = ((source[sourceLength - 4] & 0xFF) << 24)
			| ((source[sourceLength - 3] & 0xFF) << 16)
			| ((source[sourceLength - 2] & 0xFF) << 8)
			| (source[sourceLength - 1] & 0xFF);
		log.debug("TargetApk.zip size: {} {}", String.format("%08x", sourceLength - targetLength), String.format("%08x", targetLength));

		var target = new byte[targetLength];
		var targetOffset = sourceLength - targetLength - 4;
		for (var i = 0; i < targetLength; ++i) {
			var k = TARGET_APK_KEYS[i % 6];
			var b = source[targetOffset + i];
			target[i] = (byte) (k ^ ~b);
		}
		return target;
	}

}
