Set-Location -Path "$PSScriptRoot/.."

$output = "output/Cpp2IL-2022.1.0-pre-release.21"

New-Item -Path $output -ItemType Directory -Force

../vendor/Cpp2IL/Cpp2IL-2022.1.0-pre-release.21-Windows.exe `
   --game-path=data/com.klab.lapis.apk `
   --force-binary-path=data/lib/arm64-v8a/libil2cpp.so `
   --force-metadata-path=data/global-metadata.dat `
   --force-unity-version=2019.4.26 `
   --output-to=$output `
   --output-as=isil `
   --verbose
