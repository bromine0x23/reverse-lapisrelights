# APK

> 除特别注明外，本文以 **1.5.0**（`versionCode 699`）为准。结论来自静态分析（apktool 3.0.3、aapt2/apksigner 31.0.0、JADX
> 0.7.1、自写 DEX 解析脚本），未在真机执行。哈希均为 SHA-256（大写）。

## 概要

| 项          | 值                                                                                          |
|-------------|---------------------------------------------------------------------------------------------|
| 包名        | `com.klab.lapis`                                                                            |
| 版本        | `1.5.0` / `699`；应用名 `ラピライ`                                                          |
| 文件        | `com.klab.lapis-1.5.0/data/com.klab.lapis.apk`                                              |
| 大小 / 哈希 | 99,757,060 B / `499D048B07753EA3AA65CD16FF593CAF8B80EE4DFF53C1C599C6CA6664088EA0`           |
| SDK         | `minSdk 21`、`targetSdk 31`、`compileSdk 31`                                                |
| ABI         | `arm64-v8a`、`armeabi-v7a`（无 x86）                                                        |
| 引擎        | Unity `2019.4.26f1c1`，IL2CPP 元数据版本 24                                                 |
| Application | 外壳 `org.hackcode.ProxyApplication`；隐藏代码中的 `com.targetapk.MyApplication`            |
| 签名        | APK v1/v2/v3；`CN=lapis, O=KLab Inc.`                                                       |
| 分发形态    | bundletool 生成的 standalone APK，带 Play source stamp（`BNDLTOOL.*`、`stamp-cert-sha256`） |

APK 的 `classes.dex` **只包含 17 个外壳类**；真正的应用代码（8,788 个 `class_def`，含第三方库）被加密藏在 `classes.dex`
尾部，运行时解密为 `TargetApk.zip` 后由 `DexClassLoader`
加载。这是本文最重要的结构结论，格式与算法见 [README.md](README.md)。

## 包结构

APK 共 906 个 ZIP 条目，未压缩 293,244,083 B，压缩后 99,757,060 B。

| 条目                  | 大小 / 数量               | 内容                                                                                                                     |
|-----------------------|---------------------------|--------------------------------------------------------------------------------------------------------------------------|
| `classes.dex`         | 3,395,990 B               | 21,216 B 外壳 DEX + 3,374,774 B 隐藏载荷                                                                                 |
| `resources.arsc`      | 470,384 B                 | 资源表；aapt2 统计 150 个 configuration                                                                                  |
| `AndroidManifest.xml` | 25,248 B                  | 二进制清单                                                                                                               |
| `res/`                | 524 个文件 / 1,750,720 B  | appcompat、通知、ARCore、Twitter、UniWebView 等资源                                                                      |
| `assets/`             | 252 个文件 / 43,830,468 B | Unity 启动数据、加密元数据、加密资源清单、Wwise Init                                                                     |
| `lib/`                | 48 个文件 / 243,447,180 B | 24 个库 × 2 套 ABI                                                                                                       |
| `META-INF/`           | 34 个文件 / 225,333 B     | `BNDLTOOL.*` 签名、AndroidX 版本文件、Kotlin module                                                                      |
| 其他根条目            | 98,760 B                  | `kotlin/`、`okhttp3/`、`com/appsflyer/`、`generated-sources/`、Firebase/Play Services `.properties`、`stamp-cert-sha256` |

### `classes.dex` 布局

```text
0                     21,216                         3,395,986   3,395,990
+----------------------+-------------------------------+-----------+---------+
| 外壳 DEX（17 classes）| 加密载荷（3,374,770 B）        | BE32 size |         |
+----------------------+-------------------------------+-----------+---------+
                                                                 0x00337EB2 = 3,374,770
```

- DEX 头的 `file_size` 被改写为整个条目大小 3,395,990，因此载荷位于 DEX 声明范围内；`class_defs` 仍只覆盖前 21,216 B。
- 末尾 4 字节为大端载荷长度；解密为“逆序 + 取反 + 固定密钥异或”，详见 [README.md](README.md)
  与 [libklabniceway.so.md](libklabniceway.so.md)。
- 实际解密结果与 `data/TargetApk.zip` 逐字节相同：`C207D75A9201CBCF88FAEA8E61AB08A9F7E5254B60D7EE4402A412CBB569CA23`。

### `TargetApk.zip`（隐藏代码归档）

它不是可安装 APK：不含 `AndroidManifest.xml`、`resources.arsc` 与 `res/`，只有代码及原 APK 根目录的少量资源。

| 条目           | 未压缩大小 | `class_def` | 说明                                   |
|----------------|------------|-------------|----------------------------------------|
| `classes.dex`  | 8,771,140  | 8,625       | 游戏与第三方库的主代码                 |
| `classes2.dex` | 148,656    | 163         | `retrofit2`、`okio`                    |
| 其他 37 个条目 | 75,470     | —           | `*.properties`、Kotlin、Appsflyer 资源 |
| 合计           | 8,995,266  | 8,788       | ZIP 大小 3,374,770 B                   |

- `classes.dex`：`E5257F2E486088FF7F8629C6EA23629830555BECCE7480CF89359940B5B2E2EE`
- `classes2.dex`：`52448FBEA2BDDACF28DD12D79F6C07500D6D8326A989216CBA4A50E5A22974D7`
- 其中 `com/myjar/META-INF/MANIFEST.MF` 只有 25 B（`Manifest-Version: 1.0`），`com/appsflyer/internal/a-`、`b-` 为 Appsflyer
  的非标准二进制资源。

## AndroidManifest.xml

| 项                           | 值                                                                 |
|------------------------------|--------------------------------------------------------------------|
| `package`                    | `com.klab.lapis`                                                   |
| `application`                | `org.hackcode.ProxyApplication`                                    |
| `appComponentFactory`        | `androidx.core.app.CoreComponentFactory`                           |
| `isGame` / `installLocation` | `true` / `preferExternal`                                          |
| `uses-feature`               | `android:glEsVersion="0x30000"`；相机、触摸屏均为 `required=false` |
| `queries`                    | `jp.naver.line.android`、`com.twitter.android`                     |

### 组件

共 33 个：11 个 activity、13 个 service、8 个 receiver、1 个 provider。关键项：

| 类型     | 组件                                                                | 作用 / 备注                                   |
|----------|---------------------------------------------------------------------|-----------------------------------------------|
| activity | `com.klab.jackpot.notification.FirebaseMessagingActivity`           | LAUNCHER；`exported=true`；`singleTask`；横屏 |
| activity | `com.klab.jackpot.billing.PurchaseProxyActivity`                    | 内购代理                                      |
| activity | `com.onevcat.uniwebview.UniWebViewFileChooserActivity`              | WebView 文件选择                              |
| activity | `com.google.ar.core.InstallActivity`                                | ARCore 安装引导                               |
| activity | `com.android.billingclient.api.ProxyBillingActivity`                | Play Billing 3.0.0                            |
| activity | `com.google.android.gms.auth.api.signin.internal.SignInHubActivity` | Google 登录                                   |
| activity | `com.google.games.bridge.NativeBridgeActivity`                      | Google Play Games                             |
| activity | `com.twitter.sdk.android.*`（Composer/OAuth/Login）                 | Twitter 分享/登录                             |
| service  | `com.google.firebase.messaging.MessageForwardingService`            | FCM                                           |
| service  | `com.google.firebase.messaging.cpp.ListenerService`                 | Firebase C++ Messaging                        |
| service  | `com.klab.jackpot.notification.TimerNotificationService`            | 本地定时通知                                  |
| service  | `org.hackcode.service.IsolatedService`                              | `isolatedProcess=true`，Magisk 检查           |
| receiver | `com.unity.androidnotifications.UnityNotificationManager`           | Unity Mobile Notifications                    |
| receiver | `com.klab.jackpot.notification.*Receiver`                           | 本地通知/时间变化                             |
| receiver | `com.google.firebase.iid.FirebaseInstanceIdReceiver`                | FCM                                           |
| provider | `com.google.firebase.provider.FirebaseInitProvider`                 | `com.klab.lapis.firebaseinitprovider`         |

主 Activity 的 intent filter：

- `MAIN` + `LAUNCHER` / `LEANBACK_LAUNCHER`
- `VIEW` + `BROWSABLE`：`com.klab.lapis://`
- `VIEW` + `autoVerify`：`https://lapis.onelink.me/6VBT`（AppsFlyer OneLink）

`application` 下的关键 `meta-data`：

| name                                                | value                                   |
|-----------------------------------------------------|-----------------------------------------|
| `unity.build-id`                                    | `e3b5922a-99a4-4ed6-978f-1d6dd526c40f`  |
| `unity.builder`                                     | `anonymous`                             |
| `com.klab.jackpot.notification.ActivityCallback`    | `com.klab.jackpot.JackpotActivityProxy` |
| `com.klab.jackpot.platformmessage.ActivityCallback` | `com.klab.jackpot.JackpotActivityProxy` |
| `com.google.android.gms.games.APP_ID`               | `186724667514`                          |
| `com.google.android.gms.games.unityVersion`         | `0.9.57`                                |
| `com.android.stamp.source`                          | `https://play.google.com/store`         |
| `com.android.stamp.type`                            | `STAMP_TYPE_STANDALONE_APK`             |
| `com.android.vending.splits`                        | `@xml/splits0`                          |
| `com.android.vending.derived.apk.id`                | `1`                                     |

> `JackpotActivityProxy` 只是元数据里的“标记值”，APK 中不存在同名类。`JackpotActivity` 会遍历 `meta-data`，当值等于该标记时，把
> **key 本身** 作为回调类加载；实际加载的是 `notification.ActivityCallback` 与 `platformmessage.ActivityCallback`。

### 权限

`INTERNET`、`ACCESS_NETWORK_STATE`、`ACCESS_WIFI_STATE`、`WRITE_EXTERNAL_STORAGE`、`CAMERA`、`WAKE_LOCK`、
`com.android.vending.BILLING`、`com.google.android.finsky.permission.BIND_GET_INSTALL_REFERRER_SERVICE`、
`com.google.android.c2dm.permission.RECEIVE`、`com.klab.lapis.permission.C2D_MESSAGE`（自定义 `signature` 权限）。

未声明 `READ_PHONE_STATE`、定位、读通讯录等；`debuggable`、`networkSecurityConfig`、`usesCleartextTraffic` 均未设置。

## DEX 分层与加载

### 外壳 DEX

| 项        | 值                                                                                                                                                                                                           |
|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 大小      | 3,395,990 B（含载荷）；纯外壳 21,216 B                                                                                                                                                                       |
| class_def | 17（JADX 顶级类 6）                                                                                                                                                                                          |
| 类        | `ProxyApplication`、`ProxyApplication$1/$2`、`ReflectUtils`、`IIsolatedService`、`IIsolatedService$Stub`、`IIsolatedService$Stub$Proxy`、`IsolatedService`、`IsolatedService$1`、`BuildConfig`、`R` 及 `R$*` |
| 字符串    | 394                                                                                                                                                                                                          |
| 哈希      | 整个 `classes.dex`：`3686678A0B445A5A3A680BB479F57DEC12CA6F1686D822A81C8581E366235D4E`；21,216 B 外壳：`124DFB5B7B0C9F1F17DB231438A242EB5C20E64B8C734E670AC973E5FA12FAAE`                                    |

`<clinit>` 依次加载三个 native 库：

```text
System.loadLibrary("klabniceway")
System.loadLibrary("assistant1")
System.loadLibrary("assistant2")
```

`JNI_OnLoad` 在 `libklabniceway.so` 注册 4 个 native 方法：

| Java 方法       | 签名                                         | 作用                                      |
|-----------------|----------------------------------------------|-------------------------------------------|
| `start`         | `(Application, String, ClassLoader, Object)` | 首次解包/安装 DEX                         |
| `niceway_start` | `(Application, String, ClassLoader, Object)` | 已解包，直接安装                          |
| `get_target`    | `(Application) → String`                     | 返回 `<dataDir>/app_assets/TargetApk.zip` |
| `mg_present`    | `(int) → boolean`                            | Magisk/Frida 检测（隔离进程调用）         |

启动链（静态推断）：

```text
ProxyApplication.attachBaseContext()
  ├─ isUIProcess()（只处理主进程）
  ├─ get_target() / 检查 TargetApk.zip 与 versionCode
  ├─ 首次或版本变化：start()
  │    ├─ 读取已安装 APK 的 classes.dex
  │    ├─ 解密尾部载荷 → <dataDir>/app_assets/TargetApk.zip
  │    ├─ 反调试/反 Magisk（libklabniceway）
  │    └─ DexClassLoader(TargetApk.zip, …, parent) → 替换 LoadedApk.mClassLoader
  └─ 否则：niceway_start()

ProxyApplication.onCreate()
  ├─ 取出 ActivityThread / AppBindData / LoadedApk
  ├─ className 改为 com.targetapk.MyApplication
  ├─ makeApplication() → 真实 Application
  ├─ 设为 mInitialApplication，调用其 onCreate()
  └─ 启动每 10 秒随机调用 checkMg0..checkMg29 的线程
```

`checkMg*` 通过绑定 `IsolatedService` 调用 `checkPresent(mainPid)`：先读 `/proc/self/mounts` 匹配 `/sbin/.magisk/` 等 4
个路径，再调用 native `mg_present`；命中即 `Process.killProcess`。详见 [libklabniceway.so.md](libklabniceway.so.md)。

`DexClassLoader` 的 `parent` 是外壳类加载器的父级（BootClassLoader），因此隐藏代码与外壳类互不可见；替换的是
`LoadedApk.mClassLoader`，之后 `makeApplication` 用新加载器实例化 `com.targetapk.MyApplication`。

### 隐藏代码归档

`com.targetapk.MyApplication` 只继承 `Application`，`onCreate()` 仅调用 `super.onCreate()`；它存在的意义是让
`makeApplication` 从新 ClassLoader 创建 Application。真正的初始化在 Unity/IL2CPP 的 `Launcher`。

真实 DEX 的 `class_def` 共 8,788（JADX 顶级类 5,699，其余为内部/匿名类）。按包统计：

| 顶层包          | class_def | 主要来源                     |
|-----------------|-----------|------------------------------|
| `com`           | 5,878     | 见下                         |
| `androidx`      | 1,345     | AndroidX/AppCompat           |
| `kotlin`        | 854       | Kotlin stdlib                |
| `gbase_okhttp3` | 202       | GBase 的 OkHttp 分支         |
| `okhttp3`       | 201       | OkHttp                       |
| `dagger`        | 50        | Dagger                       |
| `gbase_okio`    | 42        | GBase 的 Okio 分支           |
| `net`           | 22        | `net.codestage.actk`（ACTk） |
| `android`       | 14        | 兼容类                       |
| `backtrace`     | 7         | Backtrace Unity 插件         |
| `javax`         | 6         | `javax.inject`               |
| `a`             | 2         | 混淆类                       |
| `bitter`        | 2         | JNI Bridge                   |
| `retrofit2`     | 85        | `classes2.dex`               |
| `okio`          | 44        | `classes2.dex`               |
| `org`           | 34        | FMOD、JetBrains 注解         |

`com` 下的主要分布：`com.google` 4,253（GMS 3,268、Firebase、ARCore、DataTransport、Gson 等）、`com.unity3d` 369（UnityPlayer +
Unity Ads）、`com.twitter` 302、`com.alibaba` 234（Fastjson）、`com.appsflyer` 224、`com.onevcat` 135（UniWebView）、`com.klab`
134、`com.android` 95（Billing 等）、`com.squareup` 81（Picasso）、`com.unity` 23（Mobile Notifications/ARCore）、`com.gbase`
17（GDevice）、`com.yasirkula` 5（NativeGallery）、`com.example` 3、`com.mason` 2、`com.targetapk` 1。

关键自有类：

| 类                                                        | 作用                                                                                                    |
|-----------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| `com.klab.jackpot.JackpotActivity`                        | 继承 `UnityPlayerActivity`；按 `meta-data` 分发静态 Activity 回调；权限请求                             |
| `com.klab.jackpot.JackpotActivityCallback`                | Activity 生命周期回调；`onResume` 执行调试器/模拟器/su 检查                                             |
| `com.klab.jackpot.notification.FirebaseMessagingActivity` | 主 Activity；继承 `JackpotActivity`；把新 Intent 转给 `MessageForwardingService`                        |
| `com.klab.jackpot.UnityBridge`                            | C# 调用的设备/存储/电量/内存/语言/Toast/LaunchApp/リセマラ ID 桥                                        |
| `com.klab.jackpot.billing.UnityBridge`、`BillingService`  | Play Billing 3.0.0 封装；查询、购买、确认、消耗、按比例换购                                             |
| `com.klab.jackpot.network.UnityBridge`                    | OkHttp 下载/上传、进度与取消                                                                            |
| `com.klab.jackpot.notification.UnityBridge`               | 本地通知的添加/取消/查询                                                                                |
| `com.klab.jackpot.platformmessage.UnityBridge`            | 保存/读取 deep link URL（`SharedPreferences`）                                                          |
| `com.klab.jackpot.SignGenerator`                          | 读取 APK 签名证书，按需输出 MD5/SHA-1/SHA-256                                                           |
| `com.klab.jackpot.AssetsDigestGenerator`                  | `AssetManager.open(path)` 后计算摘要                                                                    |
| `com.klab.jackpot.CertificateValidator`                   | X509 主机名 + 默认 TrustManager 校验；**未发现 Java 调用者**                                            |
| `com.klab.jackpot.ResemaraDetectionIdentifierRequest`     | `MD5(GAID + packageName)`，用于リセマラ检测                                                             |
| `com.klab.jackpot.InstanceHolderImpl`                     | Java 对象注册表（`get/set/remove`）                                                                     |
| `com.klab.jackpot.JackpotUnityPlayer`                     | 自定义 `UnityPlayer`；仅当 `com.klab.jackpot.UseJackpotUnityPlayer` 为 true 时使用，1.5.0 未声明该 meta |

Java ↔ C# 桥：C# 侧通过 `AndroidJavaClass("com.klab.jackpot.UnityBridge")`、`billing.UnityBridge`、
`notification.UnityBridge`、`network.UnityBridge`、`platformmessage.UnityBridge` 调用；通知回调通过
`UnityPlayer.UnitySendMessage`，内购/网络等通过 Java 监听接口（C# `AndroidJavaProxy`）回到 C#。证据见
`Scripts/Assembly-CSharp/Jackpot/{AndroidPlatform,Billing/GoogleInAppBilling,Notification/AndroidNotification,Network/HttpClientAndroid,PlatformMessage/PlatformMessageSetting}.cs`。

真实 DEX 共 242 个 `native` 声明（加上外壳 4 个，APK 内共 246 个），绝大多数来自 UnityPlayer、ARCore、Play
Billing、AppsFlyer、FMOD；**游戏自有仅 1 个**：`com.klab.jackpot.JackpotActivityCallback.isSuBinaryPresent()`
，对应 [libjackpot-core.so](libjackpot-core.so.md)。

## 保护与检测

| 层   | 机制         | 实现 / 证据                                                                                                                                                                            |
|------|--------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 外壳 | 隐藏 DEX     | `classes.dex` 尾部逆序+取反+XOR，`DexClassLoader` 加载 `TargetApk.zip`                                                                                                                 |
| 外壳 | 反调试       | `ptrace(PTRACE_TRACEME)`、`/proc/<pid>/status` 的 `TracerPid`、调试端口 `23946/27042`                                                                                                  |
| 外壳 | 反 Frida     | `/proc/<pid>/maps` 的 `frida-agent`/`frida.server`、线程 `gum-js-loop`/`gmain`、`linjector` fd                                                                                         |
| 外壳 | 反 Magisk    | `/proc/self/mounts` 的 `/sbin/.magisk/` 等，隔离进程 + native `mg_present`                                                                                                             |
| 外壳 | ELF 完整性   | `libklabniceway` 对 4 个库解析程序头并校验                                                                                                                                             |
| 外壳 | 三方互查     | `libassistant1/2` 10 秒轮询，检查本库与另一 assistant 的映射/校验和                                                                                                                    |
| 应用 | 运行环境检查 | `JackpotActivityCallback.onResume()`：`Debug.isDebuggerConnected()`、`Build.PRODUCT` 为 `google_sdk`/`sdk`、native `isSuBinaryPresent()`；命中则暂停 Unity、黑屏、Toast、结束 Activity |
| 应用 | 速度作弊     | IL2CPP `Launcher.Start()` 启动 ACTk `SpeedHackDetector`，命中弹出警告并重启                                                                                                            |
| 应用 | 代码哈希     | ACTk `CodeHashGenerator`（类随包；还原源码中未定位调用）                                                                                                                               |
| 原生 | Root/调试器  | `libjackpot-core.so` 的 su 路径检查、`TracerPid`、随机 canary                                                                                                                          |
| 原生 | 资产状态日志 | `_KJACore_AssetStateLogGenerateV2`：APK 签名摘要 + 引擎/资源摘要；通过 `SignGenerator`/`AssetsDigestGenerator` 或原生直读                                                              |
| 签名 | APK 完整性   | v1 `MANIFEST.MF` 覆盖整个 3,395,990 B 的 `classes.dex`；v2/v3 覆盖全包，因此隐藏载荷也受签名保护                                                                                       |

`onResume` 中的检查在 `debuggable() == true` 时直接跳过；release 包 `android:debuggable` 未设置，因此正常执行。
`libjackpot-core` 的导出名 `_KJACore_AssetStateLog*` 与实际行为不符（`Available` 是 root 检测、`Subscribe` 是 TracerPid
检测），详见其文档。

## 第三方组件

| 组件                        | 包/类数                                                                          | 版本 / 证据                                         | 用途                                                                                 |
|-----------------------------|----------------------------------------------------------------------------------|-----------------------------------------------------|--------------------------------------------------------------------------------------|
| Unity                       | `com.unity3d.player` 等                                                          | `2019.4.26f1c1`（`globalgamemanagers`、DEX 字符串） | 引擎、UnityPlayer、Burst                                                             |
| Unity Mobile Notifications  | `com.unity.androidnotifications` 23                                              | 清单 receiver/service                               | 本地通知                                                                             |
| Unity Ads                   | `com.unity3d.splash` 228                                                         | 无清单项、无 C# 引用、无独立 native 库              | 疑似未使用（未证明）                                                                 |
| Google Play services        | `com.google.android.gms` 3,268                                                   | —                                                   | 登录、Games、Ads Identifier、Install Referrer                                        |
| Firebase                    | `com.google.firebase` 等                                                         | `firebase-common` `19.3.1`（其 BuildConfig）        | FCM、Analytics、Installations、DataTransport                                         |
| Google Play Games           | `com.google.android.gms.games` 477 + `libgpg.so`                                 | 清单 `unityVersion=0.9.57`                          | 成就、排行榜、存档等                                                                 |
| Play Billing                | `com.android.billingclient` 79                                                   | `3.0.0`                                             | 内购                                                                                 |
| ARCore                      | `com.google.ar.core` 131 + `libarcore_*`、`libarpresto_api.so`                   | 清单 `optional`                                     | AR 功能                                                                              |
| AppsFlyer                   | `com.appsflyer` 224                                                              | `6.2.0`（`com.appsflyer.BuildConfig`）              | 安装归因、OneLink deep link                                                          |
| Twitter Kit                 | `com.twitter.sdk` 302                                                            | `3.1.1`                                             | Twitter 登录/分享                                                                    |
| UniWebView                  | `com.onevcat.uniwebview` 135                                                     | Kotlin，`uniwebview_release.kotlin_module`          | 应用内 WebView                                                                       |
| Fastjson                    | `com.alibaba.fastjson` 234                                                       | 含 JAX-RS provider 注册文件                         | JSON                                                                                 |
| Gson / Picasso              | `com.google.gson` / `com.squareup.picasso`                                       | —                                                   | JSON / 图片                                                                          |
| OkHttp / Okio / Retrofit2   | 201 / 44 / 85                                                                    | 标准 OkHttp3 + GBase 分支                           | 网络                                                                                 |
| Dagger / javax.inject       | 50 / 6                                                                           | —                                                   | 依赖注入（多为库内部）                                                               |
| GDevice                     | `com.gbase.gdevice` 17 + `gbase_okhttp3`/`gbase_okio`                            | `SystemInfoUtil.GDeviceU3DInterfaceInit()`          | 设备型号/CPU/GPU/内存/磁盘/模拟器/Root 分档；`EventSubmit`/`OkHttpUtil` 提供上报接口 |
| Anti-Cheat Toolkit          | `net.codestage.actk` 22                                                          | `Launcher` 使用 `SpeedHackDetector`                 | 变速检测；`CodeHashGenerator` 随包                                                   |
| Backtrace                   | `backtrace.io` 7 + `libbacktrace-native`、`libcrashpad_handler`、`libnative-lib` | `Launcher.BKClient`                                 | 崩溃/ANR 上报                                                                        |
| NativeGallery / PhotoHelper | `com.yasirkula` 5 / `com.mason.photo` 2                                          | —                                                   | 相册选择、保存图片                                                                   |
| FPS / 权限插件              | `com.example.fps` 3                                                              | 仅 BuildConfig/Installation                         | 帧率/内存显示、Android 权限                                                          |
| FMOD                        | `org.fmod` 3 个 native 声明                                                      | **无 `libfmod.so`**                                 | 疑似遗留/未使用（未证明）                                                            |
| JNI Bridge                  | `bitter.jnibridge` 2                                                             | —                                                   | JNI 反射桥（具体调用方未定位）                                                       |

## assets

| 路径                                           | 大小                      | 内容                                                                                                                                                          |
|------------------------------------------------|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `assets/bin/Data/`                             | 241 个文件 / 43,208,215 B | Unity 启动数据：`level0`–`level15`、`sharedassets0`–`15`、`globalgamemanagers*`、`unity default resources`、`Resources/unity_builtin_extra`、若干哈希命名资源 |
| `assets/bin/Data/Managed/Metadata/game.dat`    | 11,748,252 B              | 加密的 IL2CPP 元数据；`6F4CDC6E00F4BC660AE0BEB4DBF9FD47E31583E75144E814AFC9A02E5FD9A412`                                                                      |
| `assets/bin/Data/Managed/Resources/*.dat`      | —                         | `Grpc.Core`、`mscorlib`、`Newtonsoft.Json`、`System.Memory` 的托管资源                                                                                        |
| `assets/bin/Data/Managed/etc/mono/`            | —                         | Mono BCL 配置（IL2CPP 构建仍保留）                                                                                                                            |
| `assets/manifest.xml`                          | 424,944 B                 | AES-CBC 加密 + GZIP + NRBF 的 Unity 资源清单；解密见 [../assets/manifest.md](../assets/manifest.md)                                                           |
| `assets/SoundBanks/Init.bnk` + `.hash`         | 4,506 / 40 B              | Wwise 初始化 bank                                                                                                                                             |
| `assets/device_hardware_info.json`             | 11,001 B                  | GDevice 的 CPU/GPU 频率表                                                                                                                                     |
| `assets/device_level.json`                     | 18,251 B                  | GDevice 的 CPU 分档表（ultra/high/…）                                                                                                                         |
| `assets/device_url_info_config.json`           | 71 B                      | 占位 URL（`http:abcd`）                                                                                                                                       |
| `assets/supplierconfig.json`                   | 136 B                     | 国内 OEM 渠道配置（vivo `appid=100215079`）                                                                                                                   |
| `assets/google-services-desktop.json`          | 1,321 B                   | Firebase 配置副本；项目号 `186724667514`                                                                                                                      |
| `assets/icon-show.png` / `password-origin.png` | 136,480 / 25,265 B        | 零散 UI 图片；后者实际是 JPEG 数据                                                                                                                            |
| `assets/desc.txt`                              | 238 B                     | Wwise StreamingAssets 占位说明                                                                                                                                |

`res/` 以 appcompat、通知模板、ARCore 引导、Twitter 组件、UniWebView 文件选择为主；语言/地区字符串在 `resources.arsc` 中（aapt2
统计 150 个 configuration）。APK 根目录另有 `kotlin/*.kotlin_builtins`（7 个）、
`okhttp3/internal/publicsuffix/publicsuffixes.gz`、`com/appsflyer/internal/a-`/`b-`、
`generated-sources/com/twitter/TldLists.java`、`com/myjar/META-INF/MANIFEST.MF` 等非代码条目。

`assets/bin/Data` 只是启动/引导资源；游戏主体资源以 AssetBundle 下载，见 [../assets/README.md](../assets/README.md)。

### 加密/封装汇总

| 对象           | 位置                                              | 方案                                                    | 入口 / 产物                                                                       |
|----------------|---------------------------------------------------|---------------------------------------------------------|-----------------------------------------------------------------------------------|
| 真实 DEX       | `classes.dex` 尾部                                | 逆序 + 取反 + 6 字节密钥 XOR                            | `TargetApk.zip`（`DexClassLoader`）                                               |
| IL2CPP 元数据  | `game.dat`                                        | RC4 + 字符串差分编码                                    | `output/global-metadata.dat`，见 [global-metadata.dat.md](global-metadata.dat.md) |
| 资源清单       | `assets/manifest.xml`                             | AES-CBC + GZIP + NRBF                                   | `manifest.json`，见 [../assets/manifest.md](../assets/manifest.md)                |
| AssetBundle 流 | 下载/缓存                                         | `libLapis._Lapis_Decrypt`                               | 见 [libLapis.so.md](libLapis.so.md)                                               |
| Lua 字节码     | AssetBundle/下载                                  | `libtolua`                                              | 见 [libtolua.so.md](libtolua.so.md)、[../assets/Lua.md](../assets/Lua.md)         |
| 自解密库       | `libtolua.so`、`libLapis.so`、`libklabniceway.so` | `.init_array` 取 `.kcniceway` 描述符后按 `key % 9` 取反 | 见 [README.md](README.md)                                                         |

## 原生库

两套 ABI 各 24 个，共 48 个条目。下表为 `arm64-v8a / armeabi-v7a` 未压缩大小。

| 库                            | 大小（arm64 / armv7）   | 作用                                                                              |
|-------------------------------|-------------------------|-----------------------------------------------------------------------------------|
| `libil2cpp.so`                | 69,005,904 / 55,628,352 | 游戏 IL2CPP AOT 代码                                                              |
| `libunity.so`                 | 17,913,576 / 13,530,112 | Unity 引擎                                                                        |
| `libmain.so`                  | 6,424 / 18,468          | Unity JNI 引导（`JNI_OnLoad`）                                                    |
| `lib_burst_generated.so`      | 17,272 / 15,492         | Unity Burst 生成代码                                                              |
| `libgrpc_csharp_ext.so`       | 23,694,960 / 21,967,400 | gRPC C# 原生扩展                                                                  |
| `libAkSoundEngine.so`         | 4,239,504 / 2,917,184   | Wwise 音频引擎                                                                    |
| `libFirebaseCppApp-6_16_0.so` | 5,157,048 / 4,166,560   | Firebase C++ 6.16.0                                                               |
| `libFirebaseCppMessaging.so`  | 121,040 / 94,752        | Firebase C++ Messaging                                                            |
| `libgpg.so`                   | 3,718,560 / 2,489,616   | Google Play Games C++                                                             |
| `libarcore_sdk_c.so`          | 67,768 / 30,348         | ARCore C API                                                                      |
| `libarcore_sdk_jni.so`        | 134,688 / 51,512        | ARCore JNI                                                                        |
| `libarpresto_api.so`          | 529,576 / 295,312       | ARCore ArPresto 包装层                                                            |
| `libUnityARCore.so`           | 297,656 / 228,412       | Unity ARCore 集成                                                                 |
| `libbacktrace-native.so`      | 1,485,240 / 1,099,736   | Backtrace 原生崩溃采集                                                            |
| `libcrashpad_handler.so`      | 2,917,440 / 2,563,384   | Crashpad handler                                                                  |
| `libnative-lib.so`            | 223,288 / 120,420       | Backtrace breadcrumb JNI                                                          |
| `libUnityPlugin.so`           | 2,923,304 / 1,908,576   | IL2CPP `game.dat` 解密插件（`query_call_back`、opcode 107/108）                   |
| `libtolua.so`                 | 742,416 / 525,328       | tolua/LuaJIT 运行时与脚本解密                                                     |
| `libklbsqlite3.so`            | 686,704 / 682,432       | SQLite；见 [libklbsqlite3.so.md](libklbsqlite3.so.md)                             |
| `libLapis.so`                 | 78,840 / 25,592         | AssetBundle 流解密；见 [libLapis.so.md](libLapis.so.md)                           |
| `libjackpot-core.so`          | 501,880 / 300,752       | su/调试器检测与资产状态日志；见 [libjackpot-core.so.md](libjackpot-core.so.md)    |
| `libklabniceway.so`           | 156,688 / 78,864        | DEX 壳、ClassLoader 替换、反调试；见 [libklabniceway.so.md](libklabniceway.so.md) |
| `libassistant1.so`            | 22,360 / 22,040         | 完整性看门狗；见 [libassistant1.so.md](libassistant1.so.md)                       |
| `libassistant2.so`            | 22,360 / 22,040         | 完整性看门狗；见 [libassistant2.so.md](libassistant2.so.md)                       |

## 签名与完整性

`apksigner 31.0.0 verify --print-certs`：v1/v2/v3 均通过，v4 无 `.idsig`；`inspect_apk_signature` 另检出 source stamp。

| 方案            | 状态           | 说明                                                                                        |
|-----------------|----------------|---------------------------------------------------------------------------------------------|
| v1 (JAR)        | 存在且验证通过 | `META-INF/BNDLTOOL.SF`、`META-INF/BNDLTOOL.RSA`                                             |
| v2              | 存在且验证通过 | 全包签名                                                                                    |
| v3              | 存在且验证通过 | `minSdk=24`，`maxSdk=INT_MAX`                                                               |
| v3.1 / 密钥轮换 | 无             | 无 rotation lineage                                                                         |
| v4              | 无             | 未随包提供 `.idsig`                                                                         |
| Source stamp    | 存在           | 根 `stamp-cert-sha256` = `3257D599A49D2C961A471CA9843F59D341A405884583FC087DF4237B733BBD6D` |

| 项               | 值                                                                 |
|------------------|--------------------------------------------------------------------|
| Subject / Issuer | `C=JP, ST=Unknown, L=Unknown, O=KLab Inc., OU=Unknown, CN=lapis`   |
| 证书 SHA-256     | `71BCF4FE8D2349F28AEA9E204C72B1ECC1DD95A479B1CA7D0A5325236111BCAF` |
| 证书 SHA-1       | `23534C83E649FA32F59397B5A1BD168B0D1C4000`                         |
| 公钥             | RSA 2048                                                           |
| 有效期           | 2021-09-28 05:54:16 UTC → 2295-07-14 05:54:16 UTC                  |
| 序列号           | `6E00B705B3917236`                                                 |

`META-INF/BNDLTOOL.*`、`stamp-cert-sha256`、
`com.android.stamp.source=https://play.google.com/store`、`STAMP_TYPE_STANDALONE_APK`、`com.android.vending.splits` 表明该
APK 是 **bundletool 从 AAB 生成的 standalone APK，并由 Play 加 source stamp**，而非开发者直接导出的原始 APK。

v1 `MANIFEST.MF` 对 `classes.dex` 的摘要覆盖整个 3,395,990 B（含隐藏载荷），v2/v3 覆盖全包；因此直接改写隐藏 DEX
会破坏签名。游戏自身还会通过 `SignGenerator` 读取签名证书摘要，供 `libjackpot-core` 的资产状态日志使用。

## 版本对比

| 版本  | versionCode | APK (MB) | targetSdk | 外壳 `classes.dex` | `TargetApk.zip` | 真实 `classes.dex` / `classes2.dex`（class_def） |
|-------|-------------|----------|-----------|--------------------|-----------------|--------------------------------------------------|
| 1.0.3 | 634         | 86.62    | 30        | 3,523,018          | 3,501,798       | 8,616 / 241（8,857）                             |
| 1.0.4 | 635         | 86.54    | 30        | 3,439,455          | 3,418,235       | 8,614 / 241（8,855）                             |
| 1.1.0 | 641         | 86.53    | 30        | 3,439,472          | 3,418,252       | 8,614 / 241（8,855）                             |
| 1.2.0 | 652         | 86.59    | 30        | 3,439,478          | 3,418,258       | 8,614 / 241（8,855）                             |
| 1.3.0 | 675         | 99.68    | 31        | 3,391,719          | 3,370,499       | 8,623 / 163（8,786）                             |
| 1.4.0 | 681         | 99.65    | 31        | 3,395,975          | 3,374,755       | 8,625 / 163（8,788）                             |
| 1.5.0 | 699         | 99.76    | 31        | 3,395,990          | 3,374,770       | 8,625 / 163（8,788）                             |

1.0.3–1.2.0 仅做包级对比，未逐版本反编译外壳 DEX/隐藏 DEX；1.3.0–1.5.0 以 1.5.0 为主。

各版本差异：

- **1.0.3–1.2.0**：targetSdk 30、约 86.5 MB、1186–1188 个 ZIP 条目；APK 内是明文 `global-metadata.dat`；Kotlin 元数据以
  `kotlin/*.kotlin_metadata` 形式打包；`classes2.dex` 还包含 `okhttp3`（多 78 个类）。
- **1.3.0**：targetSdk 31、约 99.7 MB、905 个条目；删除 289 个 `kotlin/*.kotlin_metadata`、`libSmartBeatNdk.so` 与明文
  `global-metadata.dat`，加入加密的 `game.dat` 与 `libUnityPlugin`、`libnative-lib`、`libbacktrace-native`、
  `libcrashpad_handler`；`classes2.dex` 只剩 `retrofit2`/`okio`（241→163 类）。
- **1.4.0 / 1.5.0**：条目集合基本一致；1.5.0 比 1.4.0 多 1 个 Unity 资源，`game.dat`、`globalgamemanagers*`、
  `assets/manifest.xml`、`libil2cpp.so` 与隐藏 DEX 均更新。
- 所有版本使用同一签名证书（`71BCF4…`）；外壳 DEX 始终 17 个 `class_def`，解密密钥不变。

## 复现

```powershell
# 清单/资源/smali
apktool d data/com.klab.lapis.apk -o output/apktool --force

# 包信息与签名
aapt2 dump badging data/com.klab.lapis.apk
apksigner verify --verbose --print-certs data/com.klab.lapis.apk
```

隐藏载荷（等价于 `toolkit-java` 的 `UnpackTargetApk`）：

```python
import struct

dex = open("classes.dex", "rb").read()
n = struct.unpack(">I", dex[-4:])[0]  # 3,374,770
cipher = dex[-4 - n:-4]
KEY = [0x5E, 0x2F, 0x97, 0xCB, 0x65, 0xB2]
plain = bytes(KEY[i % 6] ^ (~cipher[len(cipher) - 1 - i] & 0xFF) for i in range(len(cipher)))
open("TargetApk.zip", "wb").write(plain)  # 与 data/TargetApk.zip 相同
```

JADX/REA 分析真实代码时，可把 `TargetApk.zip` 复制为 `TargetApk.apk` 作为入口；它没有 `AndroidManifest.xml`
，只能做类/方法级代码分析，不能安装，也无法据此恢复资源清单。要分析“外壳 APK 的清单/资源”仍应使用原始 APK。

## 证据与局限

- 静态分析，未执行 APK；运行时行为（尤其反调试/反 Magisk 的实际触发路径）未观察。
- APK 签名由 apksigner 验证 v1/v2/v3 通过；REA 的签名工具仅描述声明记录，不评估证书链、吊销或真实性。
- 主要证据：
    - `inspect_android_package`：`ev_9ae4944a8afa0bf3150b06fa34e71b7a4431161d552689ebb16be0e21380547e`
    - `inspect_apk_signature`：`ev_076a8e0dfd64df542e97240c002cca343447917db59dd78526f77e087b7fc11d`
    - `search_android_classes`（`TargetApk.apk`）：`ev_ec34a6f8d75cc35d02c02a945395e06cb3540e9c907e2427804c1dce47a68e46`
    - `inspect_android_class`（`com.targetapk.MyApplication`）：
      `ev_0c627cf2e77e8ee68d76ece29c6703957dfad0cec30ba8f3e72ef8d864132cee`
    - 证据 ID 为当前 REA 会话范围；文件哈希与命令输出可直接复现。
- 未解析/未证明：
    - `com.appsflyer.internal/a-`、`b-` 的二进制格式与用途；
    - `CertificateValidator` 的调用者（Java 静态引用为 0，可能由反射/JNI 或未使用）；
    - Unity Ads 228 个类、FMOD 3 个 native 声明是否为死代码（清单/C#/native 库均未发现对应项，但未做运行时验证）；
    - `google-services-desktop.json` 中 `certificate_hash` 与当前签名证书 SHA-1 不一致，未追查；
    - 1.0.3–1.2.0 的外壳 DEX/隐藏载荷逐字节差异未做；
    - `assets/manifest.xml` 的内容未在本文重新解码，见 [../assets/manifest.md](../assets/manifest.md)。

## 引用

- [README.md](README.md)：DEX 加壳布局与解密算法
- [libklabniceway.so.md](libklabniceway.so.md)：脱壳、ClassLoader 替换、反调试/反 Magisk
- [libassistant1.so.md](libassistant1.so.md)、[libassistant2.so.md](libassistant2.so.md)：完整性看门狗
- [libjackpot-core.so.md](libjackpot-core.so.md)：su/调试器检测、资产状态日志
- [libil2cpp.so.md](libil2cpp.so.md)：IL2CPP 代码、`game.dat`、`libUnityPlugin`
- [libLapis.so.md](libLapis.so.md)、[libtolua.so.md](libtolua.so.md)、[libklbsqlite3.so.md](libklbsqlite3.so.md)
- [global-metadata.dat.md](global-metadata.dat.md)：`game.dat` 解密
- [../assets/manifest.md](../assets/manifest.md)：资源清单解密
- [../assets/README.md](../assets/README.md)：AssetBundle、MasterData、Wwise、Lua
- `com.klab.lapis-1.5.0/Scripts/README.md`：IL2CPP 还原源码与证据链
- `toolkit-java/src/main/java/xyz/bromine0x23/lapisrelights/UnpackTargetApk.java`：隐藏归档提取工具
