package xyz.bromine0x23.lapisrelights;

import lombok.SneakyThrows;
import xyz.bromine0x23.lapisrelights.support.LapisLibs;

import java.nio.file.Files;
import java.nio.file.Path;

/// @author <a href="mailto:bromine0x23@gmail.com">Bromine0x23</>
public class UnpackLib {

	static void main(String[] arguments) {
		if (arguments.length < 1 || arguments.length > 2) {
			System.err.println("Usage: UnpackLib <lib.so> [lib.decrytped.so]");
			System.exit(1);
			return;
		}

		var input  = Path.of(arguments[0]);
		var output = arguments.length > 1
			? Path.of(arguments[1])
			: input.resolveSibling(input.getFileName().toString().replaceFirst("\\.so$", ".decrytped.so"));

		unpack(input, output);
	}

	@SneakyThrows
	public static void unpack(Path input, Path output) {
		var libBytes = Files.readAllBytes(input);

		var unpackedBytes = LapisLibs.unpack(libBytes);

		Files.write(output, unpackedBytes);
	}
}
