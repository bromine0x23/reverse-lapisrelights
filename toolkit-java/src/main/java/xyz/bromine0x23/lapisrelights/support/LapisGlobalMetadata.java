package xyz.bromine0x23.lapisrelights.support;

import lombok.extern.slf4j.Slf4j;
import org.bouncycastle.crypto.engines.RC4Engine;
import org.bouncycastle.crypto.params.KeyParameter;

/// @author <a href="mailto:bromine0x23@gmail.com">Bromine0x23</>
@Slf4j
public class LapisGlobalMetadata {

	/// 从 game.dat 恢复为 global-metadata.dat
	public static byte[] decrypt(byte[] bytes) {
		var globalMetaDataBytes = doDecrypt(bytes);
		decryptStrings(globalMetaDataBytes);
		return globalMetaDataBytes;
	}

	private static byte[] doDecrypt(byte[] ciphertext) {
		var sizePosition = findPosition(ciphertext, 0xbcfaf088L);
		var size         = readSInt32(ciphertext, sizePosition + 4);
		log.info("game.dat size = {}", String.format(" %08x", size));

		var stepPosition = findPosition(ciphertext, 0x567fe814L);
		var step         = readSInt32(ciphertext, stepPosition + 4);
		log.info("game.dat step = {}", String.format(" %08x", step));

		var key = new byte[step];
		for (var i = 0; i < step; ++i) {
			key[i] = ciphertext[stepPosition + 0x10 + i % step];
		}

		var rc4 = new RC4Engine();
		rc4.init(true, new KeyParameter(key));

		var plaintext = new byte[size];
		rc4.processBytes(ciphertext, sizePosition + 0x10, ciphertext.length - sizePosition - 0x10, plaintext, 0);

		return plaintext;
	}

	private static void decryptStrings(byte[] globalMetaDataBytes) {
		var stringOffset = readSInt32(globalMetaDataBytes, 0x18);
		var stringCount  = readSInt32(globalMetaDataBytes, 0x1C);
		for (int stringIndex = 0; stringIndex < stringCount; ++stringIndex) {
			var pointer = stringOffset + stringIndex;
			var a       = (byte) (stringIndex % 255);
			do {
				a ^= globalMetaDataBytes[pointer];
				globalMetaDataBytes[pointer++] = a;
			} while (a != 0);
			stringIndex = pointer - stringOffset - 1;
		}
	}

	private static int findPosition(byte[] bytes, long flag) {
		var step = 0;
		for (var position = 0; position < bytes.length; position = position + step + 0x10) {
			var current = readUInt32(bytes, position);
			if (current == flag) {
				return position;
			}
			step = readSInt32(bytes, position + 4);
		}
		return -1;
	}

	private static long readUInt32(byte[] bytes, int position) {
		return readSInt32(bytes, position) & 0xFFFFFFFFL;
	}

	private static int readSInt32(byte[] bytes, int position) {
		return (bytes[position] & 0xFF)
			| ((bytes[position + 1] & 0xFF) << 8)
			| ((bytes[position + 2] & 0xFF) << 16)
			| ((bytes[position + 3] & 0xFF) << 24)
			;
	}

	private static int readUInt16(byte[] bytes, int position) {
		return (bytes[position] & 0xFF)
			| ((bytes[position + 1] & 0xFF) << 8)
			;
	}

}
