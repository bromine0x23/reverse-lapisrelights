Set-Location -Path "$PSScriptRoot/.."

../vendor/Il2CppDumper/Il2CppDumper-win-v6.7.46/Il2CppDumper.exe `
  data/lib/arm64-v8a/libil2cpp.so `
  data/global-metadata.dat `
  output/Il2CppDumper-v6.7.46