// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Kc.Utility.FileUtil
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.IO;

namespace Kc.Utility
{
    /// <summary>资源哈希文件的读写工具。</summary>
    public class FileUtil
    {
        public const string HASH_EXT = ".hash";

        /// <summary>
        /// 将 <paramref name="hash"/> 写入 <paramref name="path"/>；
        /// 目录不存在则创建，文件已存在则先删除。
        /// </summary>
        // RVA: 0x1EE2B30
        public static void SaveHashFile(string path, string hash)
        {
            string directoryName = Path.GetDirectoryName(path);
            if (!Directory.Exists(directoryName))
            {
                Directory.CreateDirectory(directoryName);
            }
            if (File.Exists(path))
            {
                File.Delete(path);
            }
            File.WriteAllText(path, hash);
        }

        // RVA: 0x1EE2BEC
        public FileUtil()
        {
        }
    }
}
