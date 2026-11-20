// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.LocalizeDic
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        m_Dictionary: 语言 → (key → 文本)。静态构造的数据表由
//        pseudo/p187ded4.c 逐条 Add 还原（StringLiteral_N → ScriptString[N-1]）。
// =============================================================================

using System.Collections.Generic;
using Oz.GameFramework.Runtime;

namespace Oz.GameKit.Version
{
    public class LocalizeDic
    {
        private static Dictionary<string, Dictionary<string, string>> m_Dictionary;

        // RVA: 0x187DDB0
        public static string GetLocalizeByKey(string key)
        {
            if (!m_Dictionary.ContainsKey(key))
            {
                return key;
            }

            Dictionary<string, string> localized = m_Dictionary[key];
            if (localized != null && localized.ContainsKey(AppConst.Language))
            {
                return localized[AppConst.Language];
            }
            return key;
        }

        // RVA: 0x187DECC
        public LocalizeDic()
        {
        }

        // RVA: 0x187DED4
        static LocalizeDic()
        {
            var dict = new Dictionary<string, Dictionary<string, string>>();
            var v2 = new Dictionary<string, string>();
            v2.Add("CN", "确定");
            v2.Add("EN", "确定");
            dict.Add("PROMPT_SURE", v2);
            v3.Add("CN", "取消");
            v3.Add("EN", "取消");
            dict.Add("PROMPT_CANCEL", v3);
            v4.Add("CN", "重试");
            v4.Add("EN", "重试");
            dict.Add("PROMPT_RETRY", v4);
            v5.Add("CN", "未知错误!");
            v5.Add("EN", "未知错误!");
            dict.Add("UNKOWN_ERROR", v5);
            v6.Add("CN", "资源清单解析失败，请尝试重新安装客户端!");
            v6.Add("EN", "资源清单解析失败，请尝试重新安装客户端!");
            dict.Add("PARSE_INNER_VERSION_ERROR", v6);
            v7.Add("CN", "无法找到资源清单，请尝试重新安装客户端!");
            v7.Add("EN", "无法找到资源清单，请尝试重新安装客户端!");
            dict.Add("FIND_INNER_VERSION_ERROR", v7);
            v8.Add("CN", "发现新版本:{0}是否升级?");
            v8.Add("EN", "发现新版本:{0}是否升级?");
            dict.Add("PROMPT_UPDATE", v8);
            v9.Add("CN", "下载速度:{0} / s");
            v9.Add("EN", "下载速度:{0} / s");
            dict.Add("DOWNLOAD_SPEED", v9);
            v10.Add("CN", "下载遇到了一些问题，请确保在网络流畅情况下进行下载，是否重试？");
            v10.Add("EN", "下载遇到了一些问题，请确保在网络流畅情况下进行下载，是否重试？");
            dict.Add("DOWNLOAD_COMMON_ERROR", v10);
            v11.Add("CN", "检查是否需要提取资源文件");
            v11.Add("EN", "检查是否需要提取资源文件");
            dict.Add("EXTRA_CHECK", v11);
            v12.Add("CN", "资源清单解析失败,可能客户端版本太旧");
            v12.Add("EN", "资源清单解析失败,可能客户端版本太旧");
            dict.Add("VERSION_FILE_ERROR", v12);
            v13.Add("CN", "资源清单解析失败,客户端版与服务器不一致");
            v13.Add("EN", "资源清单解析失败,客户端版与服务器不一致");
            dict.Add("APP_VERSION_NOT_VALID", v13);
            v14.Add("CN", "本地版本比服务器版本高");
            v14.Add("EN", "本地版本比服务器版本高");
            dict.Add("VERSION_HIGHER_THAN_SERVER", v14);
            v15.Add("CN", "发现新版本:{0}是否升级?");
            v15.Add("EN", "发现新版本:{0}是否升级?");
            dict.Add("UPDATE_VERSION_TIPS", v15);
            v16.Add("CN", "正在提取资源文件");
            v16.Add("EN", "正在提取资源文件");
            dict.Add("EXTRA_NOW_TIPS", v16);
            v17.Add("CN", "获取启动信息:");
            v17.Add("EN", "获取启动信息");
            dict.Add("BOOT_INFO_GET", v17);
            v18.Add("CN", "获取启动信息失败");
            v18.Add("EN", "获取启动信息失败");
            dict.Add("BOOT_INFO_GET_FAILED", v18);
            v19.Add("CN", "正在清理资源...");
            v19.Add("EN", "正在清理资源...");
            dict.Add("RESOURCE_CLEAN", v19);
            v20.Add("CN", "检查资源文件更新");
            v20.Add("EN", "检查资源文件更新");
            dict.Add("UPDATE_CHECK", v20);
            v21.Add("CN", "需要下载:{0}数据,数据，请更新后再进入游戏，目前正在使用运营商数据，建议在wifi环境下进行更新");
            v21.Add("EN", "需要下载:{0}数据,数据，请更新后再进入游戏，目前正在使用运营商数据，建议在wifi环境下进行更新");
            dict.Add("DOWNLOAD_SIZE_PROT", v21);
            v22.Add("CN", "下载更新资源文件");
            v22.Add("EN", "下载更新资源文件");
            dict.Add("DOWNLOAD_TIPS", v22);
            v23.Add("CN", "下载遇到一些问题,建议移动到网络良好环境下再重试,是否重试？");
            v23.Add("EN", "下载遇到一些问题,建议移动到网络良好环境下再重试,是否重试？");
            dict.Add("DOWNLOAD_ERROR", v23);
            v24.Add("CN", "错误:");
            v24.Add("EN", "错误:");
            dict.Add("ERROR_PREFIX", v24);
            v25.Add("CN", "下载进度:{0}/{1}");
            v25.Add("EN", "下载进度:{0}/{1}");
            dict.Add("DOWNLOAD_PROGRESS", v25);
            v26.Add("CN", "本地版本比服务器版本高");
            v26.Add("EN", "本地版本比服务器版本高");
            dict.Add("LOCAL_MANIFILE_ERROR", v26);
            v27.Add("CN", "发现新版本应用需要更新");
            v27.Add("EN", "发现新版本应用需要更新");
            dict.Add("FORCE_UPDATE_CONFIRM", v27);
            v28.Add("CN", "需要更新");
            v28.Add("EN", "需要更新");
            dict.Add("FORCE_UPDATE_TITLE", v28);
            v29.Add("CN", "正在维护");
            v29.Add("EN", "正在维护");
            dict.Add("MAINTAIN_TITLE", v29);
            v30.Add("CN", "检测切换到运营商网络，更新可能产生费用。更新数据约:{0}");
            v30.Add("EN", "检测切换到运营商网络，更新可能产生费用。更新数据约:{0}");
            dict.Add("DOWNLOAD_CHANGE_NETWORK", v30);
            v31.Add("CN", "检测到游戏更新资源，更新数据约:{0}");
            v31.Add("EN", "检测到游戏更新资源，更新数据约:{0}");
            dict.Add("DOWNLOAD_CONFRIM", v31);
            m_Dictionary = dict;
        }
    }
}
