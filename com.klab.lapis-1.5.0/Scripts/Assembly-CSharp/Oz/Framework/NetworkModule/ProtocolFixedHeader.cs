// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.NetworkModule.ProtocolFixedHeader
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//
//  线上帧格式（均为网络字节序 / 大端）：
//    +0   int32  totalLen   整帧长度（12 + 包体长度）
//    +4   int32  msgId      消息号（由消息名 "s<id>_xxx" 解析）
//    +8   int32  group      分组号；0 表示不加密
//    +12  byte[] body       包体（DES3 加密时已加密）
// =============================================================================

using System;
using System.IO;
using System.Net;
using System.Text;

namespace Oz.Framework.NetworkModule
{
    /// <summary>定长头协议（12 字节头 + 包体）。</summary>
    public class ProtocolFixedHeader : Protocol
    {
        private static readonly int RecvHeaderSize = 12;

        private MemoryStream m_ms;
        private int _restLen;

        // RVA: 0x2EE0FD0
        public ProtocolFixedHeader()
        {
            m_ms = new MemoryStream(1024);
        }

        /// <summary>
        /// 打包：头 + 消息号 + 请求号 + 包体。消息名形如 <c>s10001_xxx</c>，
        /// 取第一个下划线前的数字作为消息号。
        /// </summary>
        // RVA: 0x2EE490C
        public override byte[] Pack(string msg, long sn, long requestId, byte[] body)
        {
            m_ms.Position = 0;

            if (body == null)
            {
                Write(RecvHeaderSize);
                body = null;
            }
            else
            {
                EncryptBody(ref body);
                Write(RecvHeaderSize + body.Length);
            }

            int index = msg.IndexOf("_");
            Write(int.Parse(msg.Substring(1, index - 1)));
            Write((int)requestId);

            if (body != null && body.Length != 0)
            {
                Write(body);
            }

            byte[] result = new byte[m_ms.Position];
            m_ms.Position = 0;
            m_ms.Read(result, 0, result.Length);
            return result;
        }

        /// <summary>
        /// 从缓冲解析一帧并压入 Dispatcher；不足一帧时返回 null 且不移动 offset。
        /// </summary>
        // RVA: 0x2EE4C04
        public override PackData ParserOutput(Channel chl, byte[] data, ref int offset, int length)
        {
            _restLen = length - offset;
            if (_restLen < RecvHeaderSize)
            {
                return null;
            }

            int packetLen = IPAddress.NetworkToHostOrder(BitConverter.ToInt32(data, offset));
            int msgId = IPAddress.NetworkToHostOrder(BitConverter.ToInt32(data, offset + 4));
            int group = IPAddress.NetworkToHostOrder(BitConverter.ToInt32(data, offset + 8));
            if (_restLen - packetLen < 0)
            {
                return null;
            }

            byte[] body = null;
            int bodyLen = packetLen - RecvHeaderSize;
            if (bodyLen >= 1)
            {
                body = new byte[bodyLen];
                Array.Copy(data, RecvHeaderSize + offset, body, 0, bodyLen);
                if (Encrypt != EncryptType.None)
                {
                    DecryptBody(ref body);
                }
            }

            Dispatcher.m_inst.PushMsg(chl, msgId, body, group);
            offset += packetLen;

            return new PackData
            {
                pbData = body,
                msgId = msgId
            };
        }

        /// <summary>同 <see cref="ParserOutput"/>，但只返回是否已解析出一帧。</summary>
        // RVA: 0x2EE4EB8
        public override bool Parser(Channel chl, byte[] data, ref int offset, int length)
        {
            _restLen = length - offset;
            if (_restLen < RecvHeaderSize)
            {
                return false;
            }

            int packetLen = IPAddress.NetworkToHostOrder(BitConverter.ToInt32(data, offset));
            int msgId = IPAddress.NetworkToHostOrder(BitConverter.ToInt32(data, offset + 4));
            int group = IPAddress.NetworkToHostOrder(BitConverter.ToInt32(data, offset + 8));
            if (_restLen - packetLen < 0)
            {
                return false;
            }

            byte[] body = null;
            int bodyLen = packetLen - RecvHeaderSize;
            if (bodyLen >= 1)
            {
                body = new byte[bodyLen];
                Array.Copy(data, RecvHeaderSize + offset, body, 0, bodyLen);
                // group == 0 表示该帧未加密
                if (group != 0 && Encrypt != EncryptType.None)
                {
                    DecryptBody(ref body);
                }
            }

            Dispatcher.m_inst.PushMsg(chl, msgId, body, group);
            offset += packetLen;
            return true;
        }

        // RVA: 0x2EE5144
        public void Write(byte o)
        {
            m_ms.WriteByte(o);
        }

        // RVA: 0x2EE4AFC
        public void Write(int o)
        {
            byte[] bytes = BitConverter.GetBytes(IPAddress.HostToNetworkOrder(o));
            m_ms.Write(bytes, 0, bytes.Length);
        }

        // RVA: 0x2EE5168
        public void Write(long o)
        {
            byte[] bytes = BitConverter.GetBytes(IPAddress.HostToNetworkOrder(o));
            m_ms.Write(bytes, 0, bytes.Length);
        }

        // RVA: 0x2EE4BD0
        public void Write(byte[] o)
        {
            m_ms.Write(o, 0, o.Length);
        }

        // RVA: 0x2EE523C
        public void Write(string o)
        {
            byte[] bytes = Encoding.UTF8.GetBytes(o);
            m_ms.Write(bytes, 0, bytes.Length);
        }

        // RVA: 0x2EE52A4
        static ProtocolFixedHeader()
        {
        }
    }
}
