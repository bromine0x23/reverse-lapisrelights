// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.TimerModule.Timer
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;
using LuaInterface;

namespace Oz.Framework.TimerModule
{
    /// <summary>定时器基类：判定到期、触发 Lua 回调、维护重复次数。</summary>
    internal abstract class Timer : IDisposable
    {
        private int _id;
        protected int _repeatCount;
        protected bool _valid;
        protected LuaFunction _luaFunction;
        protected LuaTable _luaObject;

        public int ID
        {
            // RVA: 0x2EE96D0
            get { return _id; }
        }

        /// <summary>剩余次数大于 0 或为 -1（无限）时仍需重置。</summary>
        public bool Repeat
        {
            // RVA: 0x2EE96D8
            get { return _repeatCount == -1 || _repeatCount > 0; }
        }

        public bool Valid
        {
            // RVA: 0x2EE96F4
            get { return _valid; }
        }

        /// <summary>是否已到期（由子类按时间/帧实现）。</summary>
        public abstract bool IsTimeUp();

        /// <summary>重置到期时间点（由子类实现）。</summary>
        public abstract void Reset();

        // RVA: 0x2EE9340
        public Timer(int id, LuaFunction luaFunction, LuaTable luaObject, int repeatCount)
        {
            _luaFunction = luaFunction;
            _luaObject = luaObject;
            _valid = true;
            _id = id;
            _repeatCount = repeatCount;
        }

        /// <summary>消耗一次重复次数并执行回调。</summary>
        // RVA: 0x2EE9594
        public void Execute()
        {
            if (_repeatCount >= 1)
            {
                _repeatCount--;
            }
            if (_luaFunction != null)
            {
                if (_luaObject != null)
                {
                    _luaFunction.Call(_luaObject);
                }
                else
                {
                    _luaFunction.Call();
                }
            }
        }

        // RVA: 0x2EE9650
        public void Kill()
        {
            _valid = false;
        }

        // RVA: 0x2EE9658
        public void Dispose()
        {
            if (_luaFunction != null)
            {
                _luaFunction.Dispose();
            }
            if (_luaObject != null)
            {
                _luaObject.Dispose();
            }
        }
    }
}
