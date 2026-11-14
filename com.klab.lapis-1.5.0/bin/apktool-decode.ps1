Set-Location -Path "$PSScriptRoot/.."

../vendor/Apktool/apktool.bat `
  decode `
  data/com.klab.lapis.apk `
  --output output/apktool `
  --force