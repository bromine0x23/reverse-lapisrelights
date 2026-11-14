package xyz.bromine0x23.lapisrelights.support;

import lombok.experimental.UtilityClass;
import lombok.extern.slf4j.Slf4j;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/// @author <a href="mailto:bromine0x23@gmail.com">Bromine0x23</>
@Slf4j
public @UtilityClass class LapisLibs {

	/// 移除二进制库（.so）的加固
	public static byte[] unpack(byte[] bytes) {
		var decrypted = bytes.clone();
		var buffer = ByteBuffer.wrap(bytes).order(ByteOrder.LITTLE_ENDIAN);

		// 读取 ELF 文件头的 e_entry 字段
		buffer.position(0x18);
		var entry = buffer.getInt();
		System.out.printf("entry   = %08x%n", entry);

		// 从 e_entry 字段指示的位置读取 address、length、key 三个参数
		buffer.position(entry);
		var address = buffer.getInt();
		var length  = buffer.getInt();
		var magic  = buffer.getInt();
		System.out.printf("address = %08x%n", address);
		System.out.printf("length  = %08x%n", length);
		System.out.printf("magic   = %08x%n", magic);

		// 解密从 address 位置开始的 length 个字节
		// 每第 key % 9 个字节取反（为 0 时全部取反）
		buffer.position(address);
		var step = Math.max(magic % 9, 1);
		for (var i = 0; i < length; i += step) {
			decrypted[address + i] = (byte)~bytes[address + i];
		}

		return decrypted;
	}

}
