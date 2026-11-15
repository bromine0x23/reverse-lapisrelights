package xyz.bromine0x23.lapisrelights;

import xyz.bromine0x23.lapisrelights.support.LapisManifest;

import java.nio.file.Files;
import java.nio.file.Path;

public class DecodeManifest {

	static void main(String[] arguments)throws Exception  {
		if (arguments.length < 1 || arguments.length > 2) {
			System.err.println("Usage: DecodeManifest <manifest.xml> [manifest.json]");
			System.exit(1);
			return;
		}

		var input  = Path.of(arguments[0]);
		var output = arguments.length > 1
			? Path.of(arguments[1])
			: input.resolveSibling("manifest.json");

		var manifestBytes = LapisManifest.decrypt(Files.readAllBytes(input));

		var jsonBytes = LapisManifest.deserialize(manifestBytes);

		var parent = output.toAbsolutePath().getParent();
		if (parent != null) {
			Files.createDirectories(parent);
		}
		Files.write(output, jsonBytes);
	}

}
