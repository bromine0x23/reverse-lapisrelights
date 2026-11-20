// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.MasterDataInfo
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Xml;
using Kc.Config;
using Kc.Utility;
using Oz.GameFramework.Runtime;

namespace Oz.GameKit.Version
{
    /// <summary>
    /// 主数据库包信息（含 KlabVfs 三段密钥）。名称 "MASTERDATA" 表示主库，
    /// 其余名称视为语言库。
    /// </summary>
    public class MasterDataInfo : IPackageInfoKc, IPackageInfo
    {
        public static string MASTER_FILE_PATH;

        public int ID { get; set; }
        public string Name { get; set; }
        public ulong Size { get; set; }
        public string ShortHash { get; set; }
        public int Flags { get; set; }
        public string Version { get; set; }
        public uint Key1 { get; set; }
        public uint Key2 { get; set; }
        public uint Key3 { get; set; }
        public string Hash { get; set; }

        /// <summary>KlabVfs 密钥列表 { Key1, Key2, Key3 }。</summary>
        // RVA: 0x187F2AC
        public uint[] KeyList
        {
            get { return new uint[] { Key1, Key2, Key3 }; }
        }

        // RVA: 0x187F354
        public void AddFlag(ePackageFlag flag)
        {
            Flags |= (int)flag;
        }

        // RVA: 0x187F374
        public bool HasFlag(ePackageFlag flag)
        {
            if ((int)flag == 0)
            {
                return (Flags & 1) == 0;
            }
            return (Flags & (int)flag) != 0;
        }

        // RVA: 0x187F394
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

        // RVA: 0x187F3B0
        public string GetFilePath()
        {
            if (Name == "MASTERDATA")
            {
                return "MasterData/master_data.db";
            }
            return string.Format("{0}/{1}", KcAppSetting.CurrentLang, "master_data_lang.db");
        }

        // RVA: 0x187F470
        public string GetFilePathByLang(string lang)
        {
            if (Name == "MASTERDATA")
            {
                return "MasterData/master_data.db";
            }
            return string.Format("{0}/{1}", lang, "master_data_lang.db");
        }

        // RVA: 0x187F514
        public string GetFilePathByLangTSV(string lang)
        {
            return GetFilePathByLang(lang);
        }

        /// <summary>当前语言库路径：{lang}/master_data_lang.db。</summary>
        // RVA: 0x187F518
        public static string MASTER_LANG_PATH
        {
            get { return string.Format("{0}/{1}", KcAppSetting.CurrentLang, "master_data_lang.db"); }
        }

        /// <summary>主库下载路径 {version}/{路径}；语言库再加平台段。</summary>
        // RVA: 0x187F5A0
        public string GetDownloadPath(string version)
        {
            if (Name == "MASTERDATA")
            {
                return string.Format("{0}/{1}", version, GetFilePath());
            }
            return string.Format("{0}/{1}/{2}", version, PathUtil.GetPlatformName(), GetFilePath());
        }

        /// <summary>序列化为清单 XML 节点。</summary>
        // RVA: 0x187F670
        public XmlElement ToXmlElement(XmlDocument xmlDocument)
        {
            XmlElement element = xmlDocument.CreateElement("Info");

            element.SetAttribute("ID", ID.ToString());
            element.SetAttribute("Type", "MasterData");
            element.SetAttribute("Name", Name);
            element.SetAttribute("Size", Size.ToString());
            element.SetAttribute("Hash", Hash);
            element.SetAttribute("Key1", Key1.ToString());
            element.SetAttribute("Key2", Key2.ToString());
            element.SetAttribute("Key3", Key3.ToString());
            element.SetAttribute("Flags", Flags.ToString());
            element.SetAttribute("Version", Version);

            return element;
        }

        // RVA: 0x187F8E4
        public MasterDataInfo()
        {
        }

        // RVA: 0x187F8EC
        static MasterDataInfo()
        {
            MASTER_FILE_PATH = "MasterData/master_data.db";
        }
    }
}
