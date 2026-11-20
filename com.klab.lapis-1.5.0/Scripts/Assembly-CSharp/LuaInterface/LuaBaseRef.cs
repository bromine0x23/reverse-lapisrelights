// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaBaseRef
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
    public abstract class LuaBaseRef : IDisposable
    {
        public string name;
        protected int reference;
        protected LuaState luaState;
        protected ObjectTranslator translator;
        protected bool beDisposed;
        protected int count;
        public bool IsAlive;

        // RVA: 0x2288848
        public void .ctor()
        {
            reference = -1;
            IsAlive = true;
            count = 1;
        }

        // RVA: 0x2288890
        protected override void Finalize()
        {
            try
            {
                Dispose(false);
            }
            finally
            {
                base.Finalize();
            }
        }

        // RVA: 0x2288910
        public virtual void Dispose()
        {
            if (--count > 0)
            {
                return;
            }

            IsAlive = false;
            Dispose(true);
        }

        // RVA: 0x2288964
        public virtual void DelayDispose()
        {
            luaState.DelayDispose(this);
        }

        // RVA: 0x228839C
        public void AddRef()
        {
            count++;
        }

        // RVA: 0x2288984
        public virtual void Dispose(bool disposeManagedResources)
        {
            if (beDisposed)
            {
                return;
            }

            beDisposed = true;

            if (reference > 0 && luaState != null)
            {
                luaState.CollectRef(reference, name, !disposeManagedResources);
            }

            reference = -1;
            luaState = null;
            count = 0;
        }

        // RVA: 0x2288A60
        public void Dispose(int generation)
        {
            if (count > generation)
            {
                return;
            }

            Dispose(true);
        }

        // RVA: 0x2288A80
        public LuaState GetLuaState()
        {
            return luaState;
        }

        // RVA: 0x2288A88
        public void Push()
        {
            luaState.Push(this);
        }

        // RVA: 0x2288AA8
        public override int GetHashCode()
        {
            return RuntimeHelpers.GetHashCode(this);
        }

        // RVA: 0x2288AB0
        public virtual int GetReference()
        {
            return reference;
        }

        // RVA: 0x2288AB8
        public override bool Equals(object o)
        {
            if (o == null)
            {
                return reference < 1;
            }

            LuaBaseRef lbr = o as LuaBaseRef;
            if (lbr == null)
            {
                return false;
            }

            return lbr.reference > 0 && lbr.reference == reference && reference > 0;
        }

        // RVA: 0x2288B78
        private static bool CompareRef(LuaBaseRef a, LuaBaseRef b)
        {
            if (a == b)
            {
                return true;
            }

            if (a == null)
            {
                return b.reference < 1;
            }

            if (b == null)
            {
                return a.reference < 1;
            }

            return a.reference == b.reference && a.reference > 0;
        }

        // RVA: 0x2285894
        public static bool op_Equality(LuaBaseRef a, LuaBaseRef b)
        {
            return CompareRef(a, b);
        }

        // RVA: 0x22852D8
        public static bool op_Inequality(LuaBaseRef a, LuaBaseRef b)
        {
            return !CompareRef(a, b);
        }
    }
}
