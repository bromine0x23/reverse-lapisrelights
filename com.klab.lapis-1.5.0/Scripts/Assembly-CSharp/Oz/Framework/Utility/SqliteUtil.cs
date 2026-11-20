// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.Utility.SqliteUtil
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.IO;
using Kc.Config;
using Oz.GameFramework.Runtime;
using Oz.GameKit.Version;
using UnityEngine;

namespace Oz.Framework.Utility
{
    /// <summary>打开主数据库 / 语言数据库。</summary>
    public class SqliteUtil
    {
        /// <summary>
        /// AssetBundle 模式下从持久化目录打开（加密时带密钥）；
        /// 编辑器模式下直接使用工程内 SqliteData 目录且不加密。
        /// </summary>
        // RVA: 0x2EEC680
        public static void LoadSqlite()
        {
            if (AppConst.AssetBundleMode)
            {
                string mainPath = Path.Combine(PathUtility.GetPersistentDataPath(), MasterDataInfo.MASTER_FILE_PATH);
                string langPath = Path.Combine(PathUtility.GetPersistentDataPath(), MasterDataInfo.MASTER_LANG_PATH);

                SqlLiteSupport.OpenDB(
                    key: SqlLiteSupport.MasterTableName,
                    path: string.Format("{1} {0}", mainPath, KcAppSetting.GetSqlClientKey(false)),
                    useVfs: KcAppSetting.EnableSqlLiteEncrypt);

                SqlLiteSupport.OpenDB(
                    key: SqlLiteSupport.MasterTableLangName,
                    path: string.Format("{1} {0}", langPath, KcAppSetting.GetSqlClientKey(true)),
                    useVfs: KcAppSetting.EnableSqlLiteEncrypt);
            }
            else
            {
                SqlLiteSupport.OpenDB(
                    key: SqlLiteSupport.MasterTableName,
                    path: Application.dataPath + "/../SqliteData/NewGame.db",
                    useVfs: false);

                SqlLiteSupport.OpenDB(
                    key: SqlLiteSupport.MasterTableLangName,
                    path: Application.dataPath + string.Format("/../SqliteData/lang/LangDb_{0}.db", KcAppSetting.GetCurrentLang()),
                    useVfs: false);
            }
        }

        /// <summary>
        /// 首次启动时把 StreamingAssets 内的数据库复制到持久化目录，
        /// 并按清单（manifest.xml）中的 KeyList 对文件做 KlabVfs 解压。
        /// </summary>
        // RVA: 0x2EEC950
        private static void ProcessInnerSqliteFile(bool existMain, bool existLang)
        {
            string mainDest = Path.Combine(PathUtility.GetPersistentDataPath(), MasterDataInfo.MASTER_FILE_PATH);
            string mainSrc = Path.Combine(PathUtility.GetStreamingAssetsPath(), MasterDataInfo.MASTER_FILE_PATH);
            string langDest = Path.Combine(PathUtility.GetPersistentDataPath(), MasterDataInfo.MASTER_LANG_PATH);
            string langSrc = Path.Combine(PathUtility.GetStreamingAssetsPath(), MasterDataInfo.MASTER_LANG_PATH);

            string mainDir = Path.GetDirectoryName(mainDest);
            if (!Directory.Exists(mainDir))
            {
                Directory.CreateDirectory(mainDir);
            }
            string langDir = Path.GetDirectoryName(langDest);
            if (!Directory.Exists(langDir))
            {
                Directory.CreateDirectory(langDir);
            }

            IPackageManifest packageManifest;
            using (FileStream stream = new FileStream(
                       Path.Combine(PathUtility.GetStreamingAssetsPath(), "manifest.xml"),
                       FileMode.Open, FileAccess.Read))
            {
                PackageManifest.Serializer.ReadFromStream(stream, out packageManifest);
            }
            if (packageManifest == null)
            {
                return;
            }

            MasterDataInfo mainInfo = packageManifest.GetPackageInfo(SqlLiteSupport.MasterTableName) as MasterDataInfo;
            MasterDataInfo langInfo = packageManifest.GetPackageInfo(SqlLiteSupport.MasterTableLangName) as MasterDataInfo;

            if (!existMain)
            {
                File.Copy(mainSrc, mainDest);
                if (mainInfo != null)
                {
                    KlabVfs.Deflate(mainDest, mainInfo.KeyList, KlabVfs.MASTER_KEY);
                }
            }
            if (!existLang)
            {
                File.Copy(langSrc, langDest);
                if (langInfo != null)
                {
                    KlabVfs.Deflate(langDest, langInfo.KeyList, KlabVfs.MASTER_LANG_KEY);
                }
            }
        }

        // RVA: 0x2EECECC
        public SqliteUtil()
        {
        }
    }
}
