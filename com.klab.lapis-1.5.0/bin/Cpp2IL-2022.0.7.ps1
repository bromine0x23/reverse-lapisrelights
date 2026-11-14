Set-Location -Path "$PSScriptRoot/.."

../vendor/Cpp2IL/Cpp2IL-2022.0.7-Windows.exe `
   --game-path=data/com.klab.lapis.apk `
   --force-binary-path=data/lib/arm64-v8a/libil2cpp.so `
   --force-metadata-path=data/global-metadata.dat `
   --force-unity-version=2019.4.26 `
   --output-root=output/Cpp2IL-2022.0.7 `
   --analyze-all `
   --verbose