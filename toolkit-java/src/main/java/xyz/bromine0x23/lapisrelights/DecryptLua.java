package xyz.bromine0x23.lapisrelights;

import lombok.SneakyThrows;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;

/// @author <a href="mailto:bromine0x23@gmail.com">Bromine0x23</>
public class DecryptLua {

	static void main(String[] arguments) {
		var input  = Path.of(arguments[0]);
		var output = Path.of(arguments[1]);

		decryptDir(input, output, input);
	}

	@SneakyThrows
	public static void decryptDir(Path input, Path output, Path current) {
		try (var files = Files.list(current)) {
			files.forEach(path -> {
				if (Files.isDirectory(path)) {
					decryptDir(input, output, path);
				} else {
					decryptFile(input, output, path);
				}
			});
		}
	}

	@SneakyThrows
	public static void decryptFile(Path input, Path output, Path file) {
		var bytes = Files.readAllBytes(file);

		var part2 = Arrays.copyOfRange(bytes, 0x14, bytes.length - 0x20);

		for (var i = 0; i < part2.length; ++i) {
			part2[i] = (byte) (((0xabcdef >> ((i % 0x607) % 5)) & 0xFF) ^ part2[i]);
		}

		var outputPath = output.resolve(input.relativize(file));
		Files.createDirectories(outputPath.getParent());
		Files.write(outputPath, part2);
	}

}
