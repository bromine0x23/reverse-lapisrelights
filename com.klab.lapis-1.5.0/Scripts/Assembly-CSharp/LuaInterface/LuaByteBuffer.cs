// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaByteBuffer
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Runtime.InteropServices;
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
    public struct LuaByteBuffer
    {
        public byte[] buffer;
        public int Length { get; private set; }
        // RVA: 0x2288F5C
        public LuaByteBuffer(IntPtr source, int len)
        {
            buffer = new byte[len];
            Length = len;
            Marshal.Copy(source, buffer, 0, len);
        }

        // RVA: 0x2289004
        public LuaByteBuffer(byte[] buf)
        {
            buffer = buf;
            Length = buf.Length;
        }

        // RVA: 0x2289024
        public LuaByteBuffer(byte[] buf, int len)
        {
            buffer = buf;
            Length = len;
        }

        // RVA: 0x2289030
        public LuaByteBuffer(MemoryStream stream)
        {
            buffer = stream.ToArray();
            Length = (int)stream.Length;
        }

        // RVA: 0x2289088
        public static LuaByteBuffer op_Implicit(MemoryStream stream)
        {
            return new LuaByteBuffer(stream);
        }


    }
}
