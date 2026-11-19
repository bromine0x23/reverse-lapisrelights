package xyz.bromine0x23.lapisrelights;

import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import xyz.bromine0x23.lapisrelights.support.LapisApk;
import xyz.bromine0x23.lapisrelights.support.LapisGlobalMetadata;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.file.Files;
import java.nio.file.Path;

/// 使用 [LapisApk] 解密 `com.klab.lapis.apk`
///
/// 用法: `UnpackTargetApk <com.klab.lapis.apk> [output]`
///
/// 第二个参数省略时，输出到 `com.klab.lapis.apk` 同目录下的 `TargetApk.zip`。
public class UnpackTargetApk {

	static void main(String[] arguments) throws Exception {
		if (arguments.length < 1 || arguments.length > 2) {
			System.err.println("Usage: UnpackTargetApk <com.klab.lapis.apk> [TargetApk.zip]");
			System.exit(1);
			return;
		}

		var input  = Path.of(arguments[0]);
		var output = arguments.length > 1
			? Path.of(arguments[1])
			: input.resolveSibling("TargetApk.zip");

		var sourceDexBytes = LapisApk.extractDex(input);
		var targetApkBytes = LapisApk.decryptTargetApk(LapisApk.extractTargetApk(sourceDexBytes));

		Files.write(output, targetApkBytes);
	}

}
