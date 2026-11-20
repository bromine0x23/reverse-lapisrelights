// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.TimerModule.RealTimer
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using LuaInterface;
using UnityEngine;

namespace Oz.Framework.TimerModule
{
    /// <summary>按真实时间计时（Time.realtimeSinceStartup）。</summary>
    internal class RealTimer : Timer
    {
        private float _delayTime;
        private float _endTime;

        // RVA: 0x2EE94C4
        public RealTimer(int id, float delay, LuaFunction luaFunction, LuaTable luaObject, int repeatCount)
            : base(id, luaFunction, luaObject, repeatCount)
        {
            _delayTime = delay;
            Reset();
        }

        // RVA: 0x2EE9534
        public override bool IsTimeUp()
        {
            return Time.realtimeSinceStartup > _endTime;
        }

        // RVA: 0x2EE9564
        public override void Reset()
        {
            _endTime = Time.realtimeSinceStartup + _delayTime;
        }
    }
}
