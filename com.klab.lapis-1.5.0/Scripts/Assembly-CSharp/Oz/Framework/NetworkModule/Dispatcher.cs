// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.NetworkModule.Dispatcher
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//
//  线程模型：网络线程通过 PushMsg / PushEvent 把消息压入加锁队列，
//  主线程每帧调用 Dispatch() 交换到 *_post 队列后依次派发。
// =============================================================================

using System;
using System.Collections.Generic;
using LuaInterface;

namespace Oz.Framework.NetworkModule
{
    /// <summary>消息与连接事件分发器。</summary>
    public class Dispatcher
    {
        public delegate void DgtConnect(bool is_succ, string brief, Connector cnt);

        public delegate void DgtDisconnect(bool is_succ, string brief, int chl);

        public delegate void DgtServerError(string reason);

        public delegate void DgtMessage(NodeMsg msg);

        public delegate void CshapreMessage(bool isSucceed, object msg);

        public enum EventType
        {
            Connect = 1,
            Disconnect = 2,
            ServerError = 3,
            SetServerTime = 4,
            GetAssetUrl = 5,
            OnFetchVersion = 6,
            GetMaintenance = 7
        }

        public class ObsNode
        {
            public DgtMessage DgtMsg;

            // RVA: 0x2ED765C
            public ObsNode()
            {
            }
        }

        public class NodeEvent
        {
            public EventType Event;
            public bool IsSucc;
            public string Brief;
            public Channel Channel;
            public object Owner;

            // RVA: 0x2ED7980
            public NodeEvent(EventType et, bool is_succ, string brief, object owner, Channel chl)
            {
                Event = et;
                IsSucc = is_succ;
                Brief = string.Copy(brief);
                Channel = chl;
                Owner = owner;
            }
        }

        public class NodeMsg
        {
            public int Key;
            public byte[] Body;
            public int Group;
            public int state;

            // RVA: 0x2ED7B00
            public NodeMsg(Channel chl, int key, byte[] body, int vGroup)
            {
                Channel = chl;
                Key = key;
                Body = body;
                Group = vGroup;
                state = 0;
            }

            // RVA: 0x2ED7C54
            public NodeMsg(int _key, int _state)
            {
                Key = _key;
                state = _state;
            }

            public LuaByteBuffer BodyString
            {
                // RVA: 0x2ED935C
                get { return new LuaByteBuffer(Body); }
            }
        }

        internal static Dispatcher m_inst;

        public DgtConnect OnConnect;
        public DgtDisconnect OnDisconnect;
        public DgtServerError OnServerError;
        public Dictionary<int, ObsNode> m_msg_obs;
        public Dictionary<EventType, CshapreMessage> m_msg_csharp;
        private List<NodeEvent> m_node_evt;
        private List<NodeEvent> m_node_evt_post;
        private object m_lock_node_evt;
        private List<NodeMsg> m_node_msg;
        private List<NodeMsg> m_node_msg_post;
        private object m_lock_node_msg;
        private Dictionary<string, Type> m_cmd_types;

        public static Dispatcher Instance
        {
            // RVA: 0x2ED72BC
            get { return m_inst; }
        }

        // RVA: 0x2ED730C
        public static void CreateInstance()
        {
            m_inst = new Dispatcher();
        }

        // RVA: 0x2ED74F4
        public static void DestroyInstance()
        {
            m_inst = null;
        }

        /// <summary>注册消息观察者，返回传入的委托便于注销。</summary>
        // RVA: 0x2ED7544
        public DgtMessage AddObserver(int k, DgtMessage dgt)
        {
            if (!m_msg_obs.ContainsKey(k))
            {
                m_msg_obs[k] = new ObsNode();
            }
            ObsNode node = m_msg_obs[k];
            node.DgtMsg = (DgtMessage)Delegate.Combine(node.DgtMsg, dgt);
            return dgt;
        }

        // RVA: 0x2ED7664
        public bool RemoveObserver(int k, DgtMessage dgt)
        {
            if (!m_msg_obs.ContainsKey(k))
            {
                return false;
            }
            ObsNode node = m_msg_obs[k];
            node.DgtMsg = (DgtMessage)Delegate.Remove(node.DgtMsg, dgt);
            return true;
        }

        // RVA: 0x2ED773C
        public void AddCSharpObserver(EventType t, CshapreMessage callback)
        {
            m_msg_csharp[t] = callback;
        }

        // RVA: 0x2ED77AC
        public bool RemoveCSharpObserver(EventType t)
        {
            if (m_msg_csharp.ContainsKey(t))
            {
                m_msg_csharp.Remove(t);
                return true;
            }
            return false;
        }

        public Dictionary<string, Type> CmdTypes
        {
            // RVA: 0x2ED7844
            get { return m_cmd_types; }
        }

        /// <summary>压入一个连接事件（网络线程安全）。</summary>
        // RVA: 0x2ED784C
        public void PushEvent(EventType et, bool is_succ, string breif, object owner, Channel chl)
        {
            lock (m_lock_node_evt)
            {
                m_node_evt.Add(new NodeEvent(et, is_succ, breif, owner, chl));
            }
        }

        /// <summary>压入一条协议消息（网络线程安全）。</summary>
        // RVA: 0x2ED79E8
        public void PushMsg(Channel chl, int k, byte[] param, int vGroup)
        {
            lock (m_lock_node_msg)
            {
                m_node_msg.Add(new NodeMsg(chl, k, param, vGroup));
            }
        }

        /// <summary>压入一条超时通知（state = 1）。</summary>
        // RVA: 0x2ED7B54
        public void PushMsgTimeOut(int k)
        {
            lock (m_lock_node_msg)
            {
                m_node_msg.Add(new NodeMsg(k, 1));
            }
        }

        /// <summary>主线程每帧调用：交换队列并派发。</summary>
        // RVA: 0x2ED7C90
        public void Dispatch()
        {
            lock (m_lock_node_msg)
            {
                m_node_msg_post.AddRange(m_node_msg);
                m_node_msg.Clear();
            }
            lock (m_lock_node_evt)
            {
                m_node_evt_post.AddRange(m_node_evt);
                m_node_evt.Clear();
            }

            int eventCount = m_node_evt_post.Count;
            for (int i = 0; i < eventCount; i++)
            {
                NodeEvent evt = m_node_evt_post[i];
                NotifyEvent(evt.Event, evt.IsSucc, evt.Brief, evt.Owner, evt.Channel);
            }
            m_node_evt_post.Clear();

            int msgCount = m_node_msg_post.Count;
            for (int i = 0; i < msgCount; i++)
            {
                NotifySpecMsg(m_node_msg_post[i]);
            }
            m_node_msg_post.Clear();
        }

        /// <summary>按事件类型派发到对应的全局回调或 C# 观察者。</summary>
        // RVA: 0x2ED7F28
        private void NotifyEvent(EventType et, bool is_succ, string brief, object owner, Channel chl)
        {
            switch (et)
            {
                case EventType.Connect:
                    if (OnConnect != null)
                    {
                        OnConnect(is_succ, brief, owner as Connector);
                    }
                    return;
                case EventType.Disconnect:
                    if (OnDisconnect != null)
                    {
                        OnDisconnect(is_succ, brief, Convert.ToInt32(owner));
                    }
                    return;
                case EventType.ServerError:
                    if (OnServerError != null)
                    {
                        OnServerError(brief);
                    }
                    return;
                case EventType.SetServerTime:
                    if (owner is ClockInfo info)
                    {
                        Clock.SetServerTime(info.ServerTime, info.SendTime);
                    }
                    return;
                default:
                    CshapreMessage callback;
                    if (m_msg_csharp.TryGetValue(et, out callback) && callback != null)
                    {
                        callback(is_succ, owner);
                    }
                    return;
            }
        }

        // RVA: 0x2ED80F4
        private void NotifySpecMsg(NodeMsg msg)
        {
            ObsNode node;
            if (m_msg_obs.TryGetValue(msg.Key, out node) && node.DgtMsg != null)
            {
                node.DgtMsg(msg);
            }
        }

        // RVA: 0x2ED736C
        public Dispatcher()
        {
            m_msg_obs = new Dictionary<int, ObsNode>();
            m_msg_csharp = new Dictionary<EventType, CshapreMessage>();
            m_node_evt = new List<NodeEvent>();
            m_node_evt_post = new List<NodeEvent>();
            m_lock_node_evt = new object();
            m_node_msg = new List<NodeMsg>();
            m_node_msg_post = new List<NodeMsg>();
            m_lock_node_msg = new object();
            m_cmd_types = new Dictionary<string, Type>();
        }
    }
}
