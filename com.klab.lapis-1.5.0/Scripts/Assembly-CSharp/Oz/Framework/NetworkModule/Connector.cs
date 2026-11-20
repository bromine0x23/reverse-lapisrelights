// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.NetworkModule.Connector
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Sockets;
using System.Text.RegularExpressions;

namespace Oz.Framework.NetworkModule
{
    /// <summary>TCP 连接器：负责建连、重连、发送队列与通道生命周期。</summary>
    public class Connector : Connectable
    {
        public enum CntState
        {
            Init = 0,
            Connecting = 1,
            Connected = 2,
            Closed = 3
        }

        public class HostInfo
        {
            public string IP;
            public int Port;

            // RVA: 0x2ED7270
            public HostInfo()
            {
            }
        }

        private class ReqInfo
        {
            public string Msg;
            public int Group;
            public byte[] Body;

            // RVA: 0x2ED7278
            public ReqInfo(string msg, int _group, byte[] body)
            {
                Msg = msg;
                Group = _group;
                Body = body;
            }
        }

        private CntState m_state;
        private HostInfo m_last_remote;
        private Socket m_socket;
        public Protocol protocol;
        private Channel m_channel;
        public int timeout;
        public bool AutoReconnect;
        public long PID;
        private List<ReqInfo> m_for_sends;

        public CntState State
        {
            // RVA: 0x1405334
            get { return m_state; }
        }

        public Channel Channel
        {
            // RVA: 0x140533C
            get { return m_channel; }
        }

        public override string EncryptKey
        {
            // RVA: 0x1405DF8
            get { return protocol.EncryptKey; }
            // RVA: 0x1405E14
            set { protocol.EncryptKey = value; }
        }

        // RVA: 0x1405344
        public Connector(Protocol prot)
        {
            timeout = 1000;
            PID = 1;
            m_for_sends = new List<ReqInfo>();
            protocol = prot;
        }

        // RVA: 0x14053D8
        public override void SaveSessionKey(string resKey, byte[] randomBytes, bool isCached)
        {
        }

        // RVA: 0x14053DC
        public override void SetAsLogin(string playerId)
        {
        }

        /// <summary>建立连接；先从历史状态清理旧 socket，再异步 BeginConnect。</summary>
        // RVA: 0x14053E0
        public override void Connect(string ip, int port)
        {
            if (m_socket != null && m_state == CntState.Closed)
            {
                m_socket.Shutdown(SocketShutdown.Both);
                m_socket.Disconnect(true);
                m_socket.Close();
                m_socket = null;
            }

            m_state = CntState.Connecting;
            m_last_remote = new HostInfo
            {
                IP = ip,
                Port = port
            };

            AddressFamily ipType = AddressFamily.InterNetwork;
            string newServerIp = "";
            getIPType(ip, port.ToString(), out newServerIp, out ipType);
            if (!string.IsNullOrEmpty(newServerIp))
            {
                ip = newServerIp;
            }

            m_socket = new Socket(ipType, SocketType.Stream, ProtocolType.Tcp);
            m_socket.BeginConnect(ip, port, ConnectCallback, this);
        }

        // RVA: 0x14058F4
        private static void ConnectCallback(IAsyncResult ar)
        {
            Connector cnt = ar.AsyncState as Connector;
            if (cnt == null)
            {
                return;
            }

            cnt.m_socket.EndConnect(ar);
            cnt.m_channel = new Channel(cnt.m_socket, cnt.protocol);
            cnt.m_channel.Recieve();
            cnt.m_state = CntState.Connected;

            Dispatcher.m_inst.PushEvent(Dispatcher.EventType.Connect, true, "", cnt, cnt.m_channel);
        }

        // RVA: 0x1405BB4
        public void ConnectFailed()
        {
            m_state = CntState.Closed;
        }

        // RVA: 0x1405BC0
        public override void Disconnect()
        {
            if (m_channel != null)
            {
                m_channel.Close();
            }
            m_state = CntState.Closed;
        }

        // RVA: 0x1405BF0
        public void Recieve()
        {
        }

        /// <summary>
        /// 发送消息。setTop / needAuth / retry 三个开关在当前版本未参与逻辑，
        /// 仅按 PID 递增后写入通道发送缓存。
        /// </summary>
        // RVA: 0x1405BF4
        public override void Send(string msg, int group, byte[] body, bool setTop = false, bool needAuth = true, bool retry = false)
        {
            if (m_channel != null)
            {
                m_channel.Send(msg, group, PID++, body);
            }
        }

        // RVA: 0x1405C1C
        public void SendImmediate(string msg, int group, byte[] body)
        {
            if (m_channel != null)
            {
                m_channel.Send(msg, group, PID++, body);
            }
        }

        /// <summary>已关闭且开启自动重连时重连，否则把发送缓存刷到 socket。</summary>
        // RVA: 0x1405C44
        public override void Flush()
        {
            if (AutoReconnect && m_state == CntState.Closed)
            {
                if (m_last_remote != null)
                {
                    Connect(m_last_remote.IP, m_last_remote.Port);
                }
            }
            else if (m_state == CntState.Connected)
            {
                FlushSend();
            }
        }

        /// <summary>把待发队列全部写入通道，然后触发一次实际发送。</summary>
        // RVA: 0x1405C84
        public void FlushSend()
        {
            if (m_channel != null)
            {
                foreach (ReqInfo req in m_for_sends)
                {
                    Send(req.Msg, req.Group, req.Body, false, true, false);
                }
                m_for_sends.Clear();
                m_channel.FlushSend();
            }
        }

        // RVA: 0x1405DCC
        public override void SetEncryptType(int type)
        {
            protocol.SetEncryptType(type);
        }

        // RVA: 0x1405DE8
        public override void Close()
        {
            if (m_channel != null)
            {
                m_channel.Close();
            }
        }

        // RVA: 0x1405DC8
        public void FlushRecieve()
        {
        }

        /// <summary>
        /// 当前实现固定返回 "host&&ipv4"；getIPType 只在后缀为 "ipv6" 时启用 IPv6，
        /// 因此实际始终使用 IPv4。
        /// </summary>
        // RVA: 0x1405E30
        public static string GetIPv6(string mHost, string mPort)
        {
            return mHost + "&&ipv4";
        }

        /// <summary>按 "host&&ipv6" 形式判定地址族，并去掉后缀。</summary>
        // RVA: 0x1405768
        private void getIPType(string serverIp, string serverPorts, out string newServerIp, out AddressFamily mIPType)
        {
            mIPType = AddressFamily.InterNetwork;
            newServerIp = serverIp;

            string ipv6 = GetIPv6(serverIp, serverIp);
            if (!string.IsNullOrEmpty(ipv6))
            {
                string[] parts = Regex.Split(ipv6, "&&");
                if (parts != null && parts.Length >= 2 && parts[1] == "ipv6")
                {
                    newServerIp = parts[0];
                    mIPType = AddressFamily.InterNetworkV6;
                }
            }
        }
    }
}
