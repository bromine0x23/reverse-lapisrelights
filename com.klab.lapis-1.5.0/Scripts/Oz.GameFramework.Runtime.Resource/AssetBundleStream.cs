// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Resource.dll
//  Oz.GameFramework.Runtime.Resource.AssetBundleStream
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//
//  AssetBundle 文件流：读取时按 key 派生的块大小对齐，再交给原生 _Lapis_Decrypt 解密。
// =============================================================================

using System.IO;
using System.Runtime.InteropServices;

namespace Oz.GameFramework.Runtime.Resource
{
    /// <summary>带解密的 AssetBundle FileStream。</summary>
    public class AssetBundleStream : FileStream
    {
        private int m_Key;

        /// <summary>libLapis.so 提供的解密入口。</summary>
        public class LapisExtern
        {
            // RVA: 0x2E6819C
            [DllImport("Lapis")]
            public static extern void _Lapis_Decrypt(byte[] array, int key, int start, int size, int startIdx);
        }

        // RVA: 0x2E67DE4
        public AssetBundleStream(string path, FileMode mode, int key) : base(path, mode, FileAccess.Read)
        {
            m_Key = key;
        }

        /// <summary>
        /// 读一段并按 key 解密：块大小 = |key % 10| + 1。
        /// <paramref name="start"/> 为当前读取位置到块的尾部偏移，
        /// <paramref name="startIdx"/> 为已读块序号，均交给原生解密。
        /// </summary>
        // RVA: 0x2E68010
        public override int Read(byte[] array, int offset, int count)
        {
            int mod = m_Key % 10;
            if (mod < 0)
            {
                mod = -mod;
            }
            int blockSize = mod + 1;

            long position = Position;
            int start = position % blockSize != 0
                ? (int)(blockSize + position / blockSize * blockSize - position)
                : 0;

            long readPosition = Position;
            int read = base.Read(array, offset, count);

            int startIdx = readPosition % blockSize != 0
                ? (int)(readPosition / blockSize + 1)
                : (int)(readPosition / blockSize);

            LapisExtern._Lapis_Decrypt(array, m_Key, start, array.Length, startIdx);
            return read;
        }
    }
}
