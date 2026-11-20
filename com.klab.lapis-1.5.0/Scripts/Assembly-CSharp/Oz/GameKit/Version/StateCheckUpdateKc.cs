// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.StateCheckUpdateKc
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        MakeUri 拼接 "{CDNURL}{ResVersion}/{Platform}/{Lang}/manifest.xml"；
//        SetRequestHeader 写入 x-service-slug / x-app-version / x-app-platform。
// =============================================================================

using System;
using System.Collections.Generic;
using System.Net;
using Kc.Config;
using Kc.Utility;
using Oz.Utility;
using UnityEngine;
using UnityEngine.Networking;

namespace Oz.GameKit.Version
{
    public class StateCheckUpdateKc : StateCheckUpdate
    {
        // RVA: 0x1885338
        public StateCheckUpdateKc(VersionControl versionControl)
            : base(versionControl)
        {
        }

        // RVA: 0x188533C
        protected override Uri MakeUri()
        {
            string cdnUrl = KcAppSetting.CDNURL;
            string relativePath = string.Format(
                "{0}/{1}/{2}/{3}",
                VersionControl.ResVersion,
                PathUtil.GetPlatformName(),
                KcAppSetting.CurrentLang,
                "manifest.xml");

            UriBuilder builder = new UriBuilder(cdnUrl + relativePath);
            return builder.Uri;
        }

        // RVA: 0x1885570
        protected override void SetRequestHeader(UnityWebRequest request)
        {
            string host = PlayerPrefs.GetString("endpoint_host", KcAppSetting.ApiEndPoint);
            Dictionary<string, string> headers = new Dictionary<string, string>();

            headers["x-service-slug"] = NetworkUtil.GetServiceSlugValue(host);
            headers.Add("x-app-version", Application.version);
            headers.Add("x-app-platform", Application.platform == RuntimePlatform.Android ? "a" : "i");

            foreach (string key in headers.Keys)
            {
                request.SetRequestHeader(key, headers[key]);
            }
        }

        // RVA: 0x18857A8
        protected override bool ProcessResult(int result, IPackageManifest manifestOnCdn, List<IPackageInfo> updateList)
        {
            bool forceUpdate = CheckForceUpdate();
            if ((result != 0 || forceUpdate) && !GenerateUpdateList(manifestOnCdn, updateList))
            {
                m_OverrideManifestImmediately = true;
            }
            return true;
        }
        // RVA: 0x188580C
        protected override void GenerateDeleteList(IPackageManifest cdnManifest, List<IPackageInfo> list)
        {
            IPackageInfo[] packages = VersionControl.Manifest.GetAllPackageInfos();
            for (int i = 0; i < packages.Length; i++)
            {
                IPackageInfo info = packages[i];
                if (info != null && !cdnManifest.Exist(info.Name))
                {
                    list.Add(info);
                }
            }
        }
        // RVA: 0x1885A90
        protected override bool GenerateUpdateList(IPackageManifest manifest, List<IPackageInfo> updateList)
        {
            IPackageInfo[] allPackages = manifest.GetAllPackageInfos();
            for (int i = 0; i < allPackages.Length; i++)
            {
                IPackageInfo info = allPackages[i];
                if (info == null)
                {
                    continue;
                }
                // 仅处理 Flags == 0 或非 optional 的包
                if (info.Flags != 0 && info.HasFlag(ePackageFlag.optional))
                {
                    continue;
                }

                string filePath = manifest.GetPackageFilePath(info.Name);
                string loadPath = manifest.GetPackageLoadPath(info.Name);
                string path = Path.Combine(loadPath, filePath);

                if (File.Exists(path))
                {
                    string hashFile = path + ".hash";
                    string hash = File.Exists(hashFile)
                        ? File.ReadAllText(hashFile)
                        : CryptoUtility.CalcFileHash(path);

                    if (hash == info.Hash)
                    {
                        continue;
                    }
                }

                updateList.Add(info);
            }

            return updateList.Count > 0;
        }
    }
}
