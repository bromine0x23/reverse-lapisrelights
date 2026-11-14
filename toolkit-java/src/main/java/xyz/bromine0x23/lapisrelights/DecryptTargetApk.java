package xyz.bromine0x23.lapisrelights;

import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import xyz.bromine0x23.lapisrelights.support.LapisGlobalMetadata;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.file.Files;
import java.nio.file.Path;

/// 使用 [LapisGlobalMetadata] 解密 `game.dat`
///
/// 用法: `DecryptTargetApk <game.apk> [output]`
///
/// 第二个参数省略时，输出到 `game.dat` 同目录下的 `global-metadata.dat`。
public class DecryptTargetApk {

	/// IL2CPP `global-metadata.dat` 文件头 signature
	private static final int GLOBAL_METADATA_SIGNATURE = 0xFAB11BAF;

	private static final Options options = new Options()
		.addOption(Option.builder("o").longOpt("output").get())
	;

	static void main(String[] arguments) throws Exception {
		var commandLine = DefaultParser.builder().get().parse(options, arguments);


		if (arguments.length < 1 || arguments.length > 2) {
			System.err.println("Usage: DecryptGlobalMetadata <game.dat> [global-metadata.dat]");
			System.exit(1);
			return;
		}

		var input  = Path.of(arguments[0]);
		var output = arguments.length > 1
			? Path.of(arguments[1])
			: input.resolveSibling("global-metadata.dat");

		if (!Files.isRegularFile(input)) {
			System.err.println("Input file does not exist: " + input.toAbsolutePath());
			System.exit(1);
			return;
		}

		var plaintext = LapisGlobalMetadata.decrypt(Files.readAllBytes(input));

		var signature = ByteBuffer.wrap(plaintext).order(ByteOrder.LITTLE_ENDIAN).getInt();
		if (signature != GLOBAL_METADATA_SIGNATURE) {
			System.err.printf("Decrypted data is not a valid global-metadata.dat (signature = 0x%08X)%n", signature);
			System.exit(1);
			return;
		}

		var parent = output.toAbsolutePath().getParent();
		if (parent != null) {
			Files.createDirectories(parent);
		}
		Files.write(output, plaintext);

		IO.println(String.format("Decrypted %s -> %s (%,d bytes)", input.toAbsolutePath(), output.toAbsolutePath(), plaintext.length));
	}

}
