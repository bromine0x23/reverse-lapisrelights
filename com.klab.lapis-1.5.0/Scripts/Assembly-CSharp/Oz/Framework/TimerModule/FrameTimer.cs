// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.TimerModule.FrameTimer
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using LuaInterface;
using UnityEngine;

namespace Oz.Framework.TimerModule
{
    /// <summary>按帧数计时。</summary>
    internal class FrameTimer : Timer
    {
        private int _delayFrame;
        private int _endFrame;

        // RVA: 0x2EE92D8
        public FrameTimer(int id, int delay, LuaFunction luaFunction, LuaTable luaObject, int repeatCount)
            : base(id, luaFunction, luaObject, repeatCount)
        {
            _delayFrame = delay;
            Reset();
        }

        // RVA: 0x2EE9394
        public override bool IsTimeUp()
        {
            return Time.frameCount >= _endFrame;
        }

        // RVA: 0x2EE93C4
        public override void Reset()
        {
            _endFrame = _delayFrame + Time.frameCount;
        }
    }
}
