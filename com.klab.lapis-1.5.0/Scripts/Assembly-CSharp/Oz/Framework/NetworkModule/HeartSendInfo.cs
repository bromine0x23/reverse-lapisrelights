// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.NetworkModule.HeartSendInfo
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine;

namespace Oz.Framework.NetworkModule
{
    /// <summary>心跳发送计划：到期后把下次发送时刻推后 <see cref="Delay"/> 秒。</summary>
    public class HeartSendInfo
    {
        public string ProtocolName;
        public bool IsBidiCallSupport;
        public int Delay;
        public float CurrentTick;
        public bool NeedLogin;

        /// <summary>
        /// 是否到达发送时刻；未初始化（CurrentTick == 0）时返回 false 并把
        /// 下次时刻设为 now + Delay。
        /// </summary>
        // RVA: 0x2EE0800
        public bool IsReached()
        {
            float now = Time.realtimeSinceStartup;
            bool result;
            if (CurrentTick == 0f)
            {
                result = false;
            }
            else
            {
                if (now < CurrentTick)
                {
                    return false;
                }
                result = true;
            }
            CurrentTick = now + Delay;
            return result;
        }

        // RVA: 0x2EE0870
        public HeartSendInfo()
        {
        }
    }
}
