// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaHookFlag
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace LuaInterface
{
    public enum LuaHookFlag
    {
        LUA_HOOKCALL = 0,
        LUA_HOOKRET = 1,
        LUA_HOOKLINE = 2,
        LUA_HOOKCOUNT = 3,
        LUA_HOOKTAILRET = 4
    }
}
