# AGENTS.md - lapisrelights

## 概览
本项目用于对已停运的安卓游戏《ラピスリライツ》（《宝石幻想光芒重现》、《Lapis Re:Lights》）的逆向工程，
游戏 Google Play ID 为 `com.klab.lapis`。

## 游戏信息
* CPU架构：ARM（`arm64-v8a`、`armeabi-v7a`）
* Unity版本：`2019.4.26f1c1`
* 游戏资源组成：
  + AssetBundles: Unity AssetBundle 资源，绝大部分游戏资源以该形式提供
  + MasterData: SQLite 数据库
  + SoundBanks: Wwise SoundBanks 格式音频
* 动态脚本：使用 [tolua](https://github.com/topameng/tolua) 框架加载的加密 LuaJIT 字节码

更多逆向结论见 [docs/](docs/READMD.md)

## 项目结构
```
lapisrelights/
  bin/                                           # 辅助工具和脚本
    luajit-decompiler-v2.exe                     # 修改 LuaJIT Decompiler v2 的构建结果 
  assets/                                        # 针对游戏资源的用户逆向工作区
  com.klab.lapis-1.5.0/                          # 针对游戏 1.5.0 版本的用户逆向工作区
  com.klab.lapis-1.4.0/                          # 针对游戏 1.4.0 版本的用户逆向工作区
  com.klab.lapis-1.3.0/                          # 针对游戏 1.3.0 版本的用户逆向工作区
  com.klab.lapis-1.2.0/                          # 针对游戏 1.2.0 版本的用户逆向工作区
  com.klab.lapis-1.1.0/                          # 针对游戏 1.1.0 版本的用户逆向工作区
  com.klab.lapis-1.0.4/                          # 针对游戏 1.0.4 版本的用户逆向工作区
  com.klab.lapis-1.0.3/                          # 针对游戏 1.0.3 版本的用户逆向工作区
  toolkit-java/                                  # 开发辅助逆向的 Java 工具
  luajit-decompiler-v2-lapis-relight/            # 逆向工具 LuaJIT Decompiler v2 的修改版本，以适配游戏所进行的修改
  vendor/                                        # 用于辅助逆向的外部通用工具
    Apktool/                                     # Apktool: https://github.com/iBotPeaches/Apktool
    Cpp2IL/                                      # Cpp2IL: https://github.com/SamboyCoding/Cpp2IL
     Cpp2IL-2022.0.7-Windows.exe                 # Cpp2IL 2022.0.7: https://github.com/SamboyCoding/Cpp2IL/tree/2022.0.7
     Cpp2IL-2022.1.0-pre-release.21-Windows.exe  # Cpp2IL 2022.1.0-pre-release.21: https://github.com/SamboyCoding/Cpp2IL/tree/2022.1.0-pre-release.21
    Il2CppDumper/                                # Il2CppDumper: https://github.com/Perfare/Il2CppDumper
      Il2CppDumper-win-v6.7.46/                  # Il2CppDumper v6.7.46: https://github.com/Perfare/Il2CppDumper/tree/v6.7.46
    wwiser-utils/                                # wwiser-utils: https://github.com/bnnm/wwiser-utils
```

## 环境配置
* `APKTOOL_COMMAND`: apktool 运行指令
* `IL2CPPDUMPER_COMMAND`: Il2CppDumper 运行指令
* `CPP2IL_2022_0_COMMAND`: Cpp2IL 2022.0.x版本 运行指令
* `CPP2IL_2022_1_COMMAND`: Cpp2IL 2022.1.x版本 运行指令
* `LAPIS_ASSETS_DIR`: 游戏资产目录

## 约束
- 在未明确要求的情况下，使用全局或子模块的 `.agents/workspaces` 目录作为智能体工作区。
- 如果 AGENTS.md 文件的内容与实际情况矛盾，以实际为准，并更正 AGENTS.md 文件。
