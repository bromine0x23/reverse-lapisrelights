// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.Utility.StoreUtil
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.IO;
using Kc.Config;
using Oz.GameFramework.Runtime;
using Oz.GameKit.Version;
using UnityEngine;

namespace Oz.Framework.Utility
{
    /// <summary>数据修复：清除清单/资源/主数据缓存与 SQLite 密钥。</summary>
    public static class StoreUtil
    {
        /// <summary>完全修复：删除 manifest、当前语言目录、SoundBanks、MasterData。</summary>
        // RVA: 0x2EECED4
        public static void DataRepair()
        {
            string persistentPath = PathUtility.GetPersistentDataPath();

            string manifestPath = Path.Combine(persistentPath, "manifest.xml");
            if (File.Exists(manifestPath))
            {
                File.Delete(manifestPath);
            }

            string langDir = Path.Combine(PathUtility.GetPersistentDataPath(), KcAppSetting.CurrentLang);
            if (Directory.Exists(langDir))
            {
                Directory.Delete(langDir, true);
            }

            string soundDir = Path.Combine(PathUtility.GetPersistentDataPath(), "SoundBanks");
            if (Directory.Exists(soundDir))
            {
                Directory.Delete(soundDir, true);
            }

            string masterDir = Path.Combine(PathUtility.GetPersistentDataPath(), "MasterData");
            if (Directory.Exists(masterDir))
            {
                Directory.Delete(masterDir, true);
            }

            PlayerPrefs.DeleteKey(KlabVfs.MASTER_KEY);
            PlayerPrefs.DeleteKey(KlabVfs.MASTER_LANG_KEY);
            PlayerPrefs.Save();
        }

        /// <summary>轻量修复：仅删除 manifest 与 MasterData（含语言库及其哈希）。</summary>
        // RVA: 0x2EED110
        public static void DataRepairLight()
        {
            string persistentPath = PathUtility.GetPersistentDataPath();

            string manifestPath = Path.Combine(persistentPath, "manifest.xml");
            if (File.Exists(manifestPath))
            {
                File.Delete(manifestPath);
            }

            string masterDir = Path.Combine(PathUtility.GetPersistentDataPath(), "MasterData");
            if (Directory.Exists(masterDir))
            {
                Directory.Delete(masterDir, true);
            }

            string langDb = Path.Combine(PathUtility.GetPersistentDataPath(), MasterDataInfo.MASTER_LANG_PATH);
            if (File.Exists(langDb))
            {
                File.Delete(langDb);
            }
            string langHash = langDb + ".hash";
            if (File.Exists(langHash))
            {
                File.Delete(langHash);
            }

            PlayerPrefs.DeleteKey(KlabVfs.MASTER_KEY);
            PlayerPrefs.DeleteKey(KlabVfs.MASTER_LANG_KEY);
            PlayerPrefs.Save();
        }
    }
}
