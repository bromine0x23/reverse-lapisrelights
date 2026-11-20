// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.TimerModule.OzScaleTimer
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using LuaInterface;
using UnityEngine;

namespace Oz.Framework.TimerModule
{
    /// <summary>按受 timeScale 影响的游戏时间计时。</summary>
    internal class OzScaleTimer : Timer
    {
        private float _delayTime;
        private float _endTime;

        // RVA: 0x2EE93F4
        public OzScaleTimer(int id, float delayTime, LuaFunction luaFunction, LuaTable luaObject, int repeatCount)
            : base(id, luaFunction, luaObject, repeatCount)
        {
            _delayTime = delayTime;
            Reset();
        }

        // RVA: 0x2EE9464
        public override bool IsTimeUp()
        {
            return Time.time > _endTime;
        }

        // RVA: 0x2EE9494
        public override void Reset()
        {
            _endTime = Time.time + _delayTime;
        }
    }
}
