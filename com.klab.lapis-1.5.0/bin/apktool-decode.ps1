Set-Location -Path "$PSScriptRoot/.."

$output = "output/apktool"

New-Item -Path $output -ItemType Directory -Force

../vendor/Apktool/apktool.bat `
  decode `
  data/com.klab.lapis.apk `
  --output $output `
  --force