// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.Connectable
//  来源：Il2CppDumper 元数据（全部成员为 abstract，无方法体）
// =============================================================================

namespace Oz.Framework
{
    /// <summary>网络连接抽象：连接、收发、加密与会话维护。</summary>
    public abstract class Connectable
    {
        public abstract string EncryptKey { get; set; }

        /// <summary>建立到 ip:port 的连接。</summary>
        public abstract void Connect(string ip, int port);

        public abstract void Disconnect();

        /// <summary>
        /// 发送消息。
        /// </summary>
        /// <param name="msg">协议名/消息名</param>
        /// <param name="group">消息组</param>
        /// <param name="body">包体</param>
        /// <param name="setTop">是否插入发送队列首部</param>
        /// <param name="needAuth">是否需要鉴权</param>
        /// <param name="retry">是否允许重试</param>
        public abstract void Send(string msg, int group, byte[] body, bool setTop = false, bool needAuth = true, bool retry = false);

        public abstract void SetEncryptType(int type);

        /// <summary>保存会话密钥（由服务器下发的随机数派生）。</summary>
        public abstract void SaveSessionKey(string resKey, byte[] randomBytes, bool isCached);

        public abstract void Close();

        public abstract void Flush();

        public abstract void SetAsLogin(string playerId);
    }
}
