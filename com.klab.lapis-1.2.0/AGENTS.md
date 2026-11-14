# AGENTS.md - com.klab.lapis-1.2.0

## 项目结构

```
com.klab.lapis-1.2.0/
  bin/                                  # 辅助脚本
    apktool-decode.ps1                  # 使用 apktool 工具解包
    Cpp2IL-2022.0.7.ps1                 # 使用 Cpp2IL 2022.0.7 工具逆向
    Cpp2IL-2022.1.0-pre-release.21.ps1  # 使用 Cpp2IL 2022.1.0-pre-release.21 工具逆向
    Il2CppDumper-v6.7.46.ps1            # 使用 Il2CppDumper v6.7.46 工具逆向
  data/                                 # 常用或重要的游戏文件
    com.klab.lapis.apk                  # 游戏原始 APK 包
    global-metadata.dat                 # Unity IL2CPP 元数据文件
    lib/                                # 游戏使用的二进制库
  output/                               # 各类逆向工具输出
    apktool/                            # apktool 的输出
    Cpp2IL-2022.0.7/                    # Cpp2IL 2022.0.7 的输出
    Cpp2IL-2022.1.0-pre-release.21/     # Cpp2IL 2022.1.0-pre-release.21 的输出
    Il2CppDumper-v6.7.46/               # Il2CppDumper v6.7.46 的输出
      il2cpp.h                          # 包含结构体的 C 头文件
      stringliteral.json                # 包含所有 stringLiteral 信息
      script.json                       # 用于 IDA 和 Ghidra 脚本的辅助数据
```
