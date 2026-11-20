// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.NetworkModule.Protocol
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Text;
using Oz.GameFramework.Runtime;

namespace Oz.Framework.NetworkModule
{
    /// <summary>协议编解码基类：提供包体加解密与加密方式设置。</summary>
    public abstract class Protocol
    {
        public EncryptType Encrypt { get; private set; }
        public string EncryptKey { get; set; }

        /// <summary>打包一条消息。</summary>
        public abstract byte[] Pack(string msg, long sn, long pid, byte[] body);

        /// <summary>解析缓冲，判断是否已收齐一个完整包。</summary>
        public abstract bool Parser(Channel chl, byte[] data, ref int offset, int length);

        /// <summary>取出解析出的消息。</summary>
        public abstract PackData ParserOutput(Channel chl, byte[] data, ref int offset, int length);

        // RVA: 0x2EDB49C
        public void SetEncryptType(int type)
        {
            Encrypt = (EncryptType)type;
        }

        /// <summary>DES3 加密包体（仅在 <see cref="EncryptType.DES3"/> 时生效）。</summary>
        // RVA: 0x2EE478C
        protected void EncryptBody(ref byte[] body)
        {
            if (Encrypt == EncryptType.DES3)
            {
                body = CryptoUtility.GetDES3Bytes(body, Encoding.UTF8.GetBytes(EncryptKey));
            }
        }

        /// <summary>DES3 解密包体（仅在 <see cref="EncryptType.DES3"/> 时生效）。</summary>
        // RVA: 0x2EE4848
        protected void DecryptBody(ref byte[] body)
        {
            if (Encrypt == EncryptType.DES3)
            {
                body = CryptoUtility.DecryptDES3(body, Encoding.UTF8.GetBytes(EncryptKey));
            }
        }

        // RVA: 0x2EE4904
        protected Protocol()
        {
        }
    }
}
