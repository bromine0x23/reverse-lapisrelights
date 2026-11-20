// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.StateCleanResources
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections;
using System.IO;
using Oz.GameFramework.Runtime;
using Oz.GameFramework.Runtime.Coroutines;
using UnityEngine;

namespace Oz.GameKit.Version
{
    /// <summary>清理已废弃资源：删除持久化目录中 DeleteList 对应的文件及其 .hash。</summary>
    public class StateCleanResources : State<eProcedure>
    {
        private Coroutine m_Coroutine;
        private VersionControl m_VersionControl;

        // RVA: 0x1885F80
        public StateCleanResources(VersionControl versionControl) : base(eProcedure.CleanResources)
        {
            m_VersionControl = versionControl;
        }

        // RVA: 0x1885FE8
        public override void Enter(eProcedure previousState)
        {
            if (m_VersionControl.onCleanResourceBegin != null)
            {
                m_VersionControl.onCleanResourceBegin();
            }
            m_Coroutine = CoroutineManager.StartCoroutine(Procedure());
        }

        // RVA: 0x18860B8
        public override void Exit(eProcedure nextState)
        {
            if (m_Coroutine != null)
            {
                CoroutineManager.StopCoroutine(m_Coroutine);
            }
        }

        // RVA: 0x1886048（状态机 MoveNext: 0x18860FC）
        public IEnumerator Procedure()
        {
            yield return new WaitForEndOfFrame();

            foreach (IPackageInfo info in m_VersionControl.DeleteList)
            {
                string filePath = Path.Combine(PathUtility.GetPersistentDataPath(), info.GetFilePath());
                string hashPath = filePath + ".hash";
                if (File.Exists(filePath))
                {
                    File.Delete(filePath);
                }
                if (File.Exists(hashPath))
                {
                    File.Delete(hashPath);
                }
            }

            if (m_VersionControl.onCleanSuccess != null)
            {
                m_VersionControl.onCleanSuccess();
            }
        }
    }
}
