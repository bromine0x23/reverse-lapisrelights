// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.StateCheckExtract
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections;
using System.Collections.Generic;
using Oz.GameFramework.Runtime;
using Oz.GameFramework.Runtime.Coroutines;
using UnityEngine;

namespace Oz.GameKit.Version
{
    /// <summary>
    /// 检查 StreamingAssets 中是否内嵌了比 CDN 更新的资源清单：
    /// 若内嵌版本更新则把这些包加入待解压列表，并交由 VersionControl 处理。
    /// </summary>
    public class StateCheckExtract : State<eProcedure>
    {
        public enum FailedReason
        {
            ParseError = 0,
            NotFound = 1
        }

        private VersionControl m_VersionControl;
        private Coroutine m_Coroutine;

        // RVA: 0x1882530
        public StateCheckExtract(VersionControl versionControl) : base(eProcedure.CheckExtract)
        {
            m_VersionControl = versionControl;
        }

        // RVA: 0x1882598
        public override void Enter(eProcedure previousState)
        {
            if (m_VersionControl.onCheckExtractBegin != null)
            {
                m_VersionControl.onCheckExtractBegin();
            }
            m_Coroutine = CoroutineManager.StartCoroutine(Procedure());
        }

        // RVA: 0x1882668
        public override void Exit(eProcedure nextState)
        {
            if (m_Coroutine != null)
            {
                CoroutineManager.StopCoroutine(m_Coroutine);
            }
        }

        /// <summary>
        /// 从 StreamingAssets/manifest.xml 读取内嵌清单，与 CDN 清单比较 ResVersion：
        /// 内嵌版本不大于 CDN 时调用 OnCheckExtractSkip，否则调用 CollectExtractList
        /// 并 OnCheckExtractComplete。
        /// </summary>
        // RVA: 0x18825F8（迭代器 MoveNext 0x1882A94）
        public IEnumerator Procedure()
        {
            List<IPackageInfo> extractList = new List<IPackageInfo>();
            IPackageManifest manifestInStreamingAssets = null;

            // 1) 读取 StreamingAssets 内的 manifest
            using (UnityWebRequest request = UnityWebRequest.Get(
                Path.Combine(PathUtility.GetStreamingAssetsURI(), "manifest.xml")))
            {
                yield return request.SendWebRequest();

                if (request.isNetworkError || request.isHttpError)
                {
                    m_VersionControl.OnCheckExtractFailed(StateCheckExtract.FailedReason.NotFound);
                    yield break;
                }

                using (MemoryStream stream = new MemoryStream(request.downloadHandler.data))
                {
                    if (!PackageManifest.Serializer.ReadFromStream(stream, out manifestInStreamingAssets))
                    {
                        m_VersionControl.OnCheckExtractFailed(StateCheckExtract.FailedReason.ParseError);
                        yield break;
                    }
                }
            }

            // 2) 读取持久化目录内的 manifest 并比较 ResVersion
            using (UnityWebRequest request = UnityWebRequest.Get(
                new Uri(Path.Combine(PathUtility.GetPersistentDataPath(), "manifest.xml"))))
            {
                yield return request.SendWebRequest();

                if (request.isNetworkError || request.isHttpError)
                {
                    CollectExtractList(manifestInStreamingAssets, extractList);
                    m_VersionControl.OnCheckExtractComplete(manifestInStreamingAssets, extractList);
                    yield break;
                }

                IPackageManifest packageManifest = null;
                using (MemoryStream stream = new MemoryStream(request.downloadHandler.data))
                {
                    if (PackageManifest.Serializer.ReadFromStream(stream, out packageManifest))
                    {
                        if (manifestInStreamingAssets.ResVersion <= packageManifest.ResVersion)
                        {
                            m_VersionControl.OnCheckExtractSkip(packageManifest, extractList);
                            yield break;
                        }
                    }
                }

                CollectExtractList(manifestInStreamingAssets, extractList);
                m_VersionControl.OnCheckExtractComplete(manifestInStreamingAssets, extractList);
            }
        }

        /// <summary>从清单中挑选需要解压的内嵌包（默认实现：ExtractMode 下取全部 remote 包）。</summary>
        // RVA: 0x188267C
        protected virtual void CollectExtractList(IPackageManifest manifest, List<IPackageInfo> extractList)
        {
            if (!AppConst.ExtractMode)
            {
                return;
            }

            IPackageInfo[] allPackages = manifest.GetAllPackageInfos();
            for (int i = 0; i < allPackages.Length; i++)
            {
                IPackageInfo info = allPackages[i];
                if (info == null)
                {
                    continue;
                }
                if (info.HasFlag(ePackageFlag.remote))
                {
                    continue;
                }

                IAssetBundleInfo bundle = info as IAssetBundleInfo;
                if (bundle != null && bundle.EncryptKey != 0)
                {
                    extractList.Add(info);
                }
            }
        }
    }
}
