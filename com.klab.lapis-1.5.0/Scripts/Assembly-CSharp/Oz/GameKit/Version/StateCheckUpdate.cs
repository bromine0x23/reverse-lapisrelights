// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.StateCheckUpdate
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections;
using System.Collections.Generic;
using System.IO;
using Oz.GameFramework.Runtime;
using Oz.GameFramework.Runtime.Coroutines;
using UnityEngine;
using UnityEngine.Networking;

namespace Oz.GameKit.Version
{
    /// <summary>比对本地与 CDN 清单，生成待下载/待删除列表（含强制更新判定）。</summary>
    public class StateCheckUpdate : State<eProcedure>
    {
        public enum FailedReason
        {
            ParseError = 0,
            AppVersionError = 1,
            DownloadError = 2,
            VersionError = 3
        }

        protected VersionControl m_VersionControl;
        protected Coroutine m_Coroutine;
        protected int m_RetryCount;
        protected bool m_OverrideManifestImmediately;

        // RVA: 0x1883650
        public StateCheckUpdate(VersionControl versionControl) : base(eProcedure.CheckUpdate)
        {
            m_RetryCount = 0;
            m_VersionControl = versionControl;
        }

        // RVA: 0x18836BC
        public override void Enter(eProcedure previousState)
        {
            m_OverrideManifestImmediately = false;
            if (m_VersionControl.onCheckUpdateBegin != null)
            {
                m_VersionControl.onCheckUpdateBegin();
            }
            m_Coroutine = CoroutineManager.StartCoroutine(Procedure());
        }

        // RVA: 0x1883790
        public override void Exit(eProcedure nextState)
        {
            if (m_Coroutine != null)
            {
                CoroutineManager.StopCoroutine(m_Coroutine);
            }
        }

        /// <summary>持久化目录存在 forceupdate 标记文件时强制更新。</summary>
        // RVA: 0x1883BA8
        protected bool CheckForceUpdate()
        {
            string path = Path.Combine(PathUtility.GetPersistentDataPath(), VersionConst.FORCE_UPDATE);
            return File.Exists(path);
        }

        // RVA: 0x1883D30
        protected virtual void SetRequestHeader(UnityWebRequest request)
        {
        }
        // RVA: 0x18846F4（迭代器 MoveNext）
        public IEnumerator Procedure()
        {
            List<IPackageInfo> updateList = new List<IPackageInfo>();
            IPackageManifest manifestOnCdn = null;
            IPackageManifest manifestInPersistent = null;

            using (UnityWebRequest request = UnityWebRequest.Get(MakeUri()))
            {
                request.timeout = 5;
                SetRequestHeader(request);

                yield return request.SendWebRequest();

                if (request.isNetworkError || request.isHttpError)
                {
                    m_VersionControl.OnCheckUpdateError(StateCheckUpdate.FailedReason.DownloadError);
                    yield break;
                }

                using (MemoryStream stream = new MemoryStream(request.downloadHandler.data))
                {
                    if (!PackageManifest.Serializer.ReadFromStream(stream, out manifestOnCdn))
                    {
                        m_VersionControl.OnCheckUpdateError(StateCheckUpdate.FailedReason.ParseError);
                        yield break;
                    }
                }
            }

            manifestInPersistent = null;

            using (UnityWebRequest request = UnityWebRequest.Get(
                new Uri(Path.Combine(PathUtility.GetPersistentDataPath(), "manifest.xml"))))
            {
                yield return request.SendWebRequest();

                if (request.isNetworkError || request.isHttpError)
                {
                    if (!GenerateUpdateList(manifestOnCdn, updateList))
                    {
                        m_OverrideManifestImmediately = true;
                    }
                }
                else
                {
                    using (MemoryStream stream = new MemoryStream(request.downloadHandler.data))
                    {
                        if (PackageManifest.Serializer.ReadFromStream(stream, out manifestInPersistent))
                        {
                            int result = CompareResVersion(manifestOnCdn, manifestInPersistent);
                            if (!ProcessResult(result, manifestOnCdn, updateList))
                            {
                                yield break;
                            }
                        }
                        else if (!GenerateUpdateList(manifestOnCdn, updateList))
                        {
                            m_OverrideManifestImmediately = true;
                        }
                    }
                }
            }

            List<IPackageInfo> deleteList = new List<IPackageInfo>();
            string persistentManifestPath = Path.Combine(
                PathUtility.GetPersistentDataPath(), "manifest.xml");

            if (File.Exists(persistentManifestPath)
                && manifestInPersistent != null
                && manifestInPersistent.Version != manifestOnCdn.Version)
            {
                GenerateDeleteList(manifestOnCdn, deleteList);
            }

            if (m_OverrideManifestImmediately)
            {
                using (Stream stream = File.Open(persistentManifestPath, FileMode.Create))
                {
                    PackageManifest.Serializer.WriteToStream(manifestOnCdn, stream);
                }

                string forceUpdatePath = Path.Combine(
                    PathUtility.GetPersistentDataPath(), "forceupdate");
                if (File.Exists(forceUpdatePath))
                {
                    File.Delete(forceUpdatePath);
                }
            }

            m_VersionControl.OnCheckUpdateComplete(manifestOnCdn, updateList, deleteList);
        }

        /// <summary>拼接清单下载地址（CDN + 平台 + 版本）。</summary>
        // RVA: 0x18837A4
        protected virtual System.Uri MakeUri()
        {
            int retry = m_RetryCount;
            m_RetryCount = retry + 1;

            string domain = VersionControl.CdnDomains[retry % VersionControl.CdnDomains.Count];
            string path = Path.Combine(domain, VersionControl.PatchInfo.path);
            path = Path.Combine(path, "manifest.xml");

            UriBuilder builder = new UriBuilder(path.Replace("\\", "/"));
            builder.Query = builder.Query + System.Guid.NewGuid().ToString();
            return builder.Uri;
        }

        /// <summary>比较 CDN 清单与持久化清单的资源版本号。</summary>
        // RVA: 0x1883A4C
        protected virtual int CompareResVersion(
            IPackageManifest cdnManifest,
            IPackageManifest persistentManifest)
        {
            return Math.Sign((long)(cdnManifest.ResVersion - persistentManifest.ResVersion));
        }

        /// <summary>处理下载结果，返回是否继续流程。</summary>
        // RVA: 0x1883C30
        protected virtual bool ProcessResult(
            int result,
            IPackageManifest manifestOnCdn,
            List<IPackageInfo> updateList)
        {
            if (result == 0 && !CheckForceUpdate())
            {
                return true;
            }

            if (result == 0 || result == 1)
            {
                if (!GenerateUpdateList(manifestOnCdn, updateList))
                {
                    m_OverrideManifestImmediately = true;
                }
                return true;
            }

            m_VersionControl.OnCheckUpdateError(StateCheckUpdate.FailedReason.VersionError);
            return false;
        }

        /// <summary>生成待删除列表（CDN 已移除的包）。</summary>
        // RVA: 0x1883D60
        protected virtual void GenerateDeleteList(IPackageManifest cdnManifest, List<IPackageInfo> list)
        {
            string[] packages = VersionControl.Manifest.GetPackagesWithFlag(ePackageFlag.remote);
            for (int i = 0; i < packages.Length; i++)
            {
                string packageName = packages[i];
                if (!cdnManifest.Exist(packageName))
                {
                    list.Add(VersionControl.Manifest.GetPackageInfo(packageName));
                }
            }
        }

        /// <summary>生成待更新列表，返回是否有更新。</summary>
        // RVA: 0x1884050
        protected virtual bool GenerateUpdateList(IPackageManifest cdnManifest, List<IPackageInfo> updateList)
        {
            IPackageInfo[] allPackages = cdnManifest.GetAllPackageInfos();
            for (int i = 0; i < allPackages.Length; i++)
            {
                IPackageInfo info = allPackages[i];
                if (info == null)
                {
                    continue;
                }
                if (!info.HasFlag(ePackageFlag.remote) || info.HasFlag(ePackageFlag.optional))
                {
                    continue;
                }

                string loadPath = cdnManifest.GetPackageLoadPath(info.Name);
                string filePath = cdnManifest.GetPackageFilePath(info.Name);
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
