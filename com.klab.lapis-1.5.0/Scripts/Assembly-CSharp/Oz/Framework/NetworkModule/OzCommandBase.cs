// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.NetworkModule.OzCommandBase
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================


namespace Oz.Framework.NetworkModule
{
    /// <summary>网络命令基类：保存消息携带的 <see cref="Channel"/> 供子类使用。</summary>
    public class OzCommandBase
    {
        private Channel m_chl;

        public Channel Channel
        {
            // RVA: 0x2EE4738
            get { return m_chl; }
        }

        // RVA: 0x2EE4740
        public virtual void Exec(Dispatcher.NodeMsg msg)
        {
            m_chl = msg.Channel;
        }

        // RVA: 0x2EE4730
        public OzCommandBase()
        {
        }
    }
}
