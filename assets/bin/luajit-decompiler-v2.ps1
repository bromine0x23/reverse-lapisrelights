Set-Location -Path "$PSScriptRoot/.."

../bin/luajit-decompiler-v2.exe `
  lua/luajit64-decrypted `
  --output lua/luajit64-decompile `
  --force_overwrite