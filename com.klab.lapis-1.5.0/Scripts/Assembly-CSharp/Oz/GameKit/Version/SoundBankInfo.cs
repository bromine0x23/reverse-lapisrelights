// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.SoundBankInfo
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.IO;
using System.Xml;
using Kc.Utility;
using Oz.GameFramework.Runtime;

namespace Oz.GameKit.Version
{
    /// <summary>Wwise SoundBank 包信息（清单中的一项）。</summary>
    public class SoundBankInfo : IPackageInfoKc, IPackageInfo
    {
        public int ID { get; set; }
        public string Name { get; set; }
        public ulong Size { get; set; }
        public string ShortHash { get; set; }
        public int Flags { get; set; }
        public string Version { get; set; }
        public string Hash { get; set; }

        /// <summary>资源内路径：SoundBanks/{Name}.bnk（反斜杠统一为斜杠）。</summary>
        // RVA: 0x1882340
        public string GetFilePath()
        {
            return "SoundBanks/" + Name.Replace("\\", "/") + ".bnk";
        }

        // RVA: 0x18823D0
        public string GetFilePathByLang(string lang)
        {
            return GetFilePath();
        }

        // RVA: 0x18823D4
        public string GetFilePathByLangTSV(string lang)
        {
            return Path.Combine(PathUtil.GetPlatformName(), GetFilePath());
        }

        // RVA: 0x188245C
        public string GetDownloadPath(string version)
        {
            return string.Format("{0}/{1}/{2}", version, PathUtil.GetPlatformName(), GetFilePath());
        }

        // RVA: 0x18824DC
        public void AddFlag(ePackageFlag flag)
        {
            Flags |= (int)flag;
        }

        /// <summary>flag 为 0 时以 bit0 是否清零作为“未标记”判定。</summary>
        // RVA: 0x18824EC
        public bool HasFlag(ePackageFlag flag)
        {
            if ((int)flag == 0)
            {
                return (Flags & 1) == 0;
            }
            return (Flags & (int)flag) != 0;
        }

        /// <summary>flag 为 0 时置位 bit0（与 HasFlag 的语义配对）。</summary>
        // RVA: 0x188250C
        public void RemoveFlag(ePackageFlag flag)
        {
            if ((int)flag == 0)
            {
                Flags |= 1;
            }
            else
            {
                Flags &= ~(int)flag;
            }
        }

        /// <summary>序列化为清单 XML 节点。</summary>
        // RVA: 0x188048C
        public XmlElement ToXmlElement(XmlDocument xmlDocument)
        {
            XmlElement element = xmlDocument.CreateElement("Info");

            element.SetAttribute("Type", "SoundBank");
            element.SetAttribute("Name", Name);
            element.SetAttribute("Size", Size.ToString());
            element.SetAttribute("Hash", Hash);
            element.SetAttribute("Flags", Flags.ToString());

            return element;
        }
    }
}
