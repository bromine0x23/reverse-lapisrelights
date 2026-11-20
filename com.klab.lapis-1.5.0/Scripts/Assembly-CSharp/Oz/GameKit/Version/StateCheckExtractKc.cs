// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.StateCheckExtractKc
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;
using Oz.GameFramework.Runtime;

namespace Oz.GameKit.Version
{
    /// <summary>
    /// Kc 渠道的内嵌资源检查：ExtractMode 下只把名为 "Init" 的包加入解压列表。
    /// </summary>
    public class StateCheckExtractKc : StateCheckExtract
    {
        // RVA: 0x18834D8
        public StateCheckExtractKc(VersionControl versionControl) : base(versionControl)
        {
        }

        // RVA: 0x18834DC
        protected override void CollectExtractList(IPackageManifest manifest, List<IPackageInfo> extractList)
        {
            if (!AppConst.ExtractMode)
            {
                return;
            }

            IPackageInfo item;
            if (manifest.TryGetPackageInfo("Init", out item))
            {
                extractList.Add(item);
            }
        }
    }
}
