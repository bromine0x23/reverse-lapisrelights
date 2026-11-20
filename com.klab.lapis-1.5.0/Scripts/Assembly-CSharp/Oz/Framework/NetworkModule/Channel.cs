// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.NetworkModule.Channel
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//
//  一个 Socket 连接：接收走 BeginReceive/EndReceive 异步链，发送走
//  SendNode 环形缓存 + BeginSend/EndSend 异步链，全部由 m_mutex 串行化。
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using System.Net.Sockets;
using System.Threading;
using Oz.GameFramework.Runtime.Coroutines;
using UnityEngine;

namespace Oz.Framework.NetworkModule
{
    /// <summary>协议通道。</summary>
    public class Channel
    {
        public enum ChannelState
        {
            Build = 0,
            Closing = 1,
            Closed = 2
        }

        /// <summary>发送环形缓冲区中的一段。</summary>
        private class SendNode
        {
            public Channel Channel;
            public byte[] Cache;
            public int Offset;
            public bool IsSending;

            // RVA: 0x14032A8
            public SendNode(Channel chl, int sz)
            {
                Channel = chl;
                Cache = new byte[sz];
            }
        }

        private Socket m_socket;
        private Protocol m_protocol;
        private ChannelState m_state;
        private byte[] m_rev_cache;
        public int m_rev_cache_size;
        private int m_rev_cache_offset;
        private int m_send_cache_size;
        private List<SendNode> m_send_nodes;
        private int m_send_node_offset;
        private static object m_lock_counter;
        private static int s_id_counter;
        private Mutex m_mutex;
        private string m_close_breif;
        private int m_id;
        private AsyncCallback m_asyncCbSend;
        private AsyncCallback m_asyncCbReceive;

        public Socket Socket
        {
            // RVA: 0x1402E78
            get { return m_socket; }
        }

        public Protocol Protocol
        {
            // RVA: 0x1402E80
            get { return m_protocol; }
        }

        public ChannelState State
        {
            // RVA: 0x1402E88
            get { return m_state; }
            // RVA: 0x1402E90
            set { m_state = value; }
        }

        public int RevCacheSize
        {
            // RVA: 0x1402E98
            get { return m_rev_cache_size; }
            // RVA: 0x1402EA0
            set
            {
                m_rev_cache_size = value;
                m_rev_cache = new byte[value];
            }
        }

        public int RevCacheOffset
        {
            // RVA: 0x1402F08
            get { return m_rev_cache_offset; }
            // RVA: 0x1402F10
            set { m_rev_cache_offset = value; }
        }

        public int SendCacheSize
        {
            // RVA: 0x1402F18
            get { return m_send_cache_size; }
            // RVA: 0x1402F20
            set
            {
                m_send_cache_size = value;
                foreach (SendNode node in m_send_nodes)
                {
                    node.Offset = 0;
                    node.Cache = new byte[value];
                }
            }
        }

        public int ID
        {
            // RVA: 0x140303C
            get { return m_id; }
        }

        public string Token { get; set; }

        public NetNodeType LocalType { get; set; }

        public NetNodeType RemoteType { get; set; }

        // RVA: 0x1403074
        public Channel(Socket socket, Protocol protocol)
        {
            m_state = ChannelState.Closed;
            m_send_nodes = new List<SendNode>();
            m_mutex = new Mutex();
            m_id = -1;

            lock (m_lock_counter)
            {
                m_id = ++s_id_counter;
            }

            m_socket = socket;
            m_protocol = protocol;
            RevCacheSize = 2048;
            SendCacheSize = 10240;
            m_send_nodes.Add(new SendNode(this, m_send_cache_size));

            m_state = ChannelState.Build;
            m_asyncCbSend = SendCallback;
            m_asyncCbReceive = ReceiveCallback;
        }

        // RVA: 0x1403320
        public void Close()
        {
            Close("");
        }

        /// <summary>
        /// 关闭连接：Shutdown 后异步断开，并等待最多 5 秒。
        /// </summary>
        // RVA: 0x1403370
        public void Close(string brief)
        {
            m_mutex.WaitOne();
            if (m_state == ChannelState.Build)
            {
                string closeBrief = brief;
                m_close_breif = closeBrief;
                m_state = ChannelState.Closing;
                m_socket.Shutdown(SocketShutdown.Both);
                IAsyncResult result = m_socket.BeginDisconnect(true, DisconnectCallback, this);
                CoroutineManager.StartCoroutine(WaitEnd(result, 5f));
            }
            m_mutex.ReleaseMutex();
        }

        /// <summary>等待异步操作结束；超时则上报断开失败。</summary>
        // RVA: 0x14035D0（状态机 MoveNext: 0x14049C8）
        private IEnumerator WaitEnd(IAsyncResult result, float timeout)
        {
            Channel chl = result.AsyncState as Channel;
            float deadline = Time.realtimeSinceStartup + timeout;
            while (!result.IsCompleted && Time.realtimeSinceStartup < deadline)
            {
                yield return null;
            }
            if (!result.IsCompleted)
            {
                Dispatcher.m_inst.PushEvent(Dispatcher.EventType.Disconnect, false, "", null, chl);
            }
        }

        // RVA: 0x140367C
        private static void DisconnectCallback(IAsyncResult ar)
        {
            Channel chl = ar.AsyncState as Channel;
            if (chl == null)
            {
                return;
            }
            chl.m_mutex.WaitOne();
            chl.m_socket.EndDisconnect(ar);
            chl.m_state = ChannelState.Closed;
            Dispatcher.m_inst.PushEvent(Dispatcher.EventType.Disconnect, true, chl.m_close_breif, null, chl);
            chl.m_mutex.ReleaseMutex();
        }

        /// <summary>开始一次异步接收。</summary>
        // RVA: 0x1403968
        public void Recieve()
        {
            m_mutex.WaitOne();
            if (m_state == ChannelState.Build)
            {
                m_socket.BeginReceive(m_rev_cache, 0, m_rev_cache.Length, SocketFlags.None, m_asyncCbReceive, this);
            }
            m_mutex.ReleaseMutex();
        }

        /// <summary>
        /// 接收回调：把新数据追加到接收缓存，循环解析完整帧，
        /// 剩余半包前移并继续 BeginReceive；缓存不足时按 1024 字节扩容。
        /// </summary>
        // RVA: 0x1403B08
        private static void ReceiveCallback(IAsyncResult ar)
        {
            Channel chl = ar.AsyncState as Channel;
            if (chl == null)
            {
                return;
            }
            chl.m_mutex.WaitOne();

            int received = chl.m_socket.EndReceive(ar);
            if (received < 1)
            {
                throw new Exception("Recieve zero packet !");
            }

            int offset = 0;
            int total = chl.m_rev_cache_offset + received;
            while (offset < total)
            {
                if (!chl.m_protocol.Parser(chl, chl.m_rev_cache, ref offset, total))
                {
                    // 半包：扩容后保留数据，等待下次接收
                    byte[] oldCache = chl.m_rev_cache;
                    int newSize = chl.m_rev_cache_size + 1024;
                    chl.m_rev_cache_size = newSize;
                    byte[] newCache = new byte[newSize];
                    Array.Copy(oldCache, 0, newCache, 0, oldCache.Length);
                    chl.m_rev_cache = newCache;
                    break;
                }
            }

            if (offset == total)
            {
                total = 0;
            }
            else if (offset != 0)
            {
                byte[] oldCache = chl.m_rev_cache;
                byte[] newCache = new byte[chl.m_rev_cache_size];
                Array.Copy(oldCache, offset, newCache, 0, received - offset + chl.m_rev_cache_offset);
                chl.m_rev_cache = newCache;
                total = chl.m_rev_cache_offset + received - offset;
            }
            chl.m_rev_cache_offset = total;

            chl.m_socket.BeginReceive(chl.m_rev_cache, total, chl.m_rev_cache.Length - total,
                SocketFlags.None, chl.m_asyncCbReceive, chl);

            if (chl.m_rev_cache_offset >= 4)
            {
                // 原代码此处读取尾部残留长度，但结果未使用
                BitConverter.ToInt32(chl.m_rev_cache, chl.m_rev_cache_offset - 4);
            }
            chl.m_mutex.ReleaseMutex();
        }

        // RVA: 0x1403F98
        private void GrowSendCache(int sz, ref byte[] buffer)
        {
            byte[] newBuffer = new byte[m_send_cache_size + sz];
            Array.Copy(buffer, 0, newBuffer, 0, buffer.Length);
            m_send_cache_size = newBuffer.Length;
            buffer = newBuffer;
        }

        // RVA: 0x140403C
        public void Send(string msg, long group, long pid)
        {
            Send(msg, group, pid, null);
        }

        // RVA: 0x1404374
        public void Send(string msg, long pid, byte[] body)
        {
            Send(msg, 0, pid, body);
        }

        /// <summary>打包并写入当前发送缓存（非线程安全的部分由 m_mutex 保护）。</summary>
        // RVA: 0x1404044
        public void Send(string msg, long group, long pid, byte[] body)
        {
            m_mutex.WaitOne();

            string error = null;
            if (m_state != ChannelState.Build)
            {
                error = string.Format("Channel isn't build.");
            }
            else
            {
                SendNode node = m_send_nodes[m_send_node_offset];
                byte[] packet = m_protocol.Pack(msg, group, pid, body);
                if (packet != null)
                {
                    if (node.Offset + packet.Length > node.Cache.Length)
                    {
                        GrowSendCache(m_send_cache_size, ref node.Cache);
                    }
                    Array.Copy(packet, 0, node.Cache, node.Offset, packet.Length);
                    node.Offset += packet.Length;
                }
            }

            m_mutex.ReleaseMutex();
            if (error != null)
            {
                Close(error);
            }
        }

        /// <summary>把当前缓存通过 BeginSend 发出，并切换到下一个空闲节点。</summary>
        // RVA: 0x1404384
        public void FlushSend()
        {
            SendNode node = m_send_nodes[m_send_node_offset];
            if (node.Offset == 0)
            {
                return;
            }

            m_mutex.WaitOne();

            string error = null;
            int errorCode = 0;
            if (m_state != ChannelState.Build)
            {
                error = string.Format("Channel isn't build.");
            }
            else
            {
                node.IsSending = true;
                m_socket.BeginSend(node.Cache, 0, node.Offset, SocketFlags.None, out errorCode, m_asyncCbSend, node);

                m_send_node_offset = (m_send_node_offset + 1) % m_send_nodes.Count;
                SendNode next = m_send_nodes[m_send_node_offset];
                if (next.IsSending)
                {
                    m_send_nodes.Add(new SendNode(this, m_send_cache_size));
                    m_send_node_offset = m_send_nodes.Count - 1;
                }
            }

            m_mutex.ReleaseMutex();
            if (error != null)
            {
                Close(error);
            }
        }

        // RVA: 0x14046F0
        private static void SendCallback(IAsyncResult ar)
        {
            SendNode node = ar.AsyncState as SendNode;
            if (node == null)
            {
                return;
            }
            Channel chl = node.Channel;
            chl.m_mutex.WaitOne();
            chl.m_socket.EndSend(ar);
            node.IsSending = false;
            node.Offset = 0;
            chl.m_mutex.ReleaseMutex();
        }

        // RVA: 0x140494C
        static Channel()
        {
            m_lock_counter = new object();
        }
    }
}
