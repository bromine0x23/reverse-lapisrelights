// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.Utility.SimpleByteArray
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;
using System.IO;
using System.Net;
using System.Text;

namespace Oz.Framework.Utility
{
    /// <summary>
    /// 网络字节序（大端）写入缓冲区。多字节整数先转网络序再写入，
    /// 字符串按 UTF-8 写入（不含长度前缀）。
    /// </summary>
    public class SimpleByteArray : IDisposable
    {
        private MemoryStream m_ms;

        // RVA: 0x2EEC260
        public SimpleByteArray()
        {
            m_ms = new MemoryStream(1024);
        }

        // RVA: 0x2EEC384
        public void Dispose()
        {
            m_ms.Close();
            m_ms.Dispose();
            m_ms = null;
        }

        // RVA: 0x2EEC358
        public byte[] ToByteArray()
        {
            return m_ms.ToArray();
        }

        // RVA: 0x2EEC3D0
        public void Write(short o)
        {
            byte[] bytes = BitConverter.GetBytes(IPAddress.HostToNetworkOrder(o));
            m_ms.Write(bytes, 0, bytes.Length);
        }

        // RVA: 0x2EEC2CC
        public void Write(byte o)
        {
            m_ms.WriteByte(o);
        }

        // RVA: 0x2EEC4A4
        public void Write(int o)
        {
            byte[] bytes = BitConverter.GetBytes(IPAddress.HostToNetworkOrder(o));
            m_ms.Write(bytes, 0, bytes.Length);
        }

        // RVA: 0x2EEC578
        public void Write(long o)
        {
            byte[] bytes = BitConverter.GetBytes(IPAddress.HostToNetworkOrder(o));
            m_ms.Write(bytes, 0, bytes.Length);
        }

        // RVA: 0x2EEC64C
        public void Write(byte[] o)
        {
            m_ms.Write(o, 0, o.Length);
        }

        // RVA: 0x2EEC2F0
        public void Write(string o)
        {
            byte[] bytes = Encoding.UTF8.GetBytes(o);
            m_ms.Write(bytes, 0, bytes.Length);
        }
    }
}
