// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.TimerModule.UnscaleTimer
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using LuaInterface;
using UnityEngine;

namespace Oz.Framework.TimerModule
{
    /// <summary>按不受 timeScale 影响的时间计时（Time.unscaledTime）。</summary>
    internal class UnscaleTimer : Timer
    {
        private float _delayTime;
        private float _endTime;

        // RVA: 0x2EE9E44
        public UnscaleTimer(int id, float delay, LuaFunction luaFunction, LuaTable luaObject, int repeatCount)
            : base(id, luaFunction, luaObject, repeatCount)
        {
            _delayTime = delay;
            Reset();
        }

        // RVA: 0x2EEA180
        public override bool IsTimeUp()
        {
            return Time.unscaledTime > _endTime;
        }

        // RVA: 0x2EEA1B0
        public override void Reset()
        {
            _endTime = Time.unscaledTime + _delayTime;
        }
    }
}
