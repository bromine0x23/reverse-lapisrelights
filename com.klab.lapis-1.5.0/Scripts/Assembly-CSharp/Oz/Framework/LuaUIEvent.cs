// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.LuaUIEvent
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using LuaInterface;
using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>以 Lua 函数形式挂接的 UI 事件（tolua）。</summary>
    public class LuaUIEvent : UIEvent
    {
        public LuaFunction luaFunc;
        public LuaTable luaObject;

        // RVA: 0x1402DB0
        public LuaUIEvent()
        {
        }

        // RVA: 0x13FCE04
        public LuaUIEvent(LuaFunction luaFunc, LuaTable luaObject)
        {
            this.luaFunc = luaFunc;
            this.luaObject = luaObject;
        }

        /// <summary>
        /// 有 LuaTable 上下文时以 &lt;table, eventData&gt; 调用，否则只传 eventData。
        /// </summary>
        // RVA: 0x1402DB8
        public override void Callback(BaseEventData data)
        {
            if (luaObject != null)
            {
                if (luaFunc != null)
                {
                    luaFunc.Call(luaObject, data);
                }
            }
            else if (luaFunc != null)
            {
                luaFunc.Call(data);
            }
        }
    }
}
