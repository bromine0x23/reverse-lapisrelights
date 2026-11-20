// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaInjectionStation
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
    public class LuaInjectionStation
    {
        public const byte NOT_INJECTION_FLAG = 0;
        public const byte INVALID_INJECTION_FLAG = 255;
        private static int cacheSize;
        private static byte[] injectionFlagCache;
        private static LuaFunction[] injectFunctionCache;

        // RVA: 0x2297AF8
        static LuaInjectionStation()
        {
                        injectionFlagCache = new byte[cacheSize];
                        injectFunctionCache = new LuaFunction[cacheSize];
        }

        // RVA: 0x2297B88
        [NoToLua]
        public static byte GetInjectFlag(int index)
        {
                        byte result = injectionFlagCache[index];

                        if (result == INVALID_INJECTION_FLAG)
                        {
                            return NOT_INJECTION_FLAG;
                        }
                        else if (result == NOT_INJECTION_FLAG)
                        {
                            /// Delay injection not supported
                            if (LuaState.GetInjectInitState(index))
                            {
                                injectionFlagCache[index] = INVALID_INJECTION_FLAG;
                            }
                        }

                        return result;
        }

        // RVA: 0x2297CB0
        [NoToLua]
        public static LuaFunction GetInjectionFunction(int index)
        {
                        return injectFunctionCache[index];
        }

        // RVA: 0x2297D44
        public static void CacheInjectFunction(int index, byte injectFlag, LuaFunction func)
        {
                        if (index >= cacheSize)
                        {
                            return;
                        }

                        injectFunctionCache[index] = func;
                        injectionFlagCache[index] = injectFlag;
        }

        // RVA: 0x2297E64
        public static void Clear()
        {
                        //_call = null;
                        _add = null;
                        _remove = null;
                        self = null;            
                        luaState = null;
        }

        // RVA: 0x2297F6C
        public LuaInjectionStation()
        {

        }
    }
}
