// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Context
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

namespace Jackpot
{
    public abstract class Context
    {
        private static int serial;
        private readonly int id;
        public abstract void Execute();
        public int Id { get { return id; } }
        // RVA: 0x178A7E8
        public int get_Id()
        {
            return id;
        }

        // RVA: 0x17807C4
        protected void .ctor()
        {
            id = ++serial;
        }

        // RVA: 0x1780900
        protected Context(int id)
        {
            this.id = id;
        }

        // RVA: 0x178A7F0
        public override bool Equals(object that)
        {
            Context context = that as Context;
            if (context == null)
            {
                return false;
            }

            return id == context.id;
        }

        // RVA: 0x178A898
        public override int GetHashCode()
        {
            return id.GetHashCode();
        }

        // RVA: 0x178A8C4
        static Context()
        {
        }
    }
}
