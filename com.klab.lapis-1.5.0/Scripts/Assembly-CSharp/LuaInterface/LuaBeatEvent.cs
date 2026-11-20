// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaBeatEvent
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
    public class LuaBeatEvent : IDisposable
    {
        protected LuaState luaState;
        protected bool beDisposed;
        private LuaTable self;
        private LuaFunction _add;
        private LuaFunction _remove;

        // RVA: 0x2288BD8
        public LuaBeatEvent(LuaTable table)
        {
                        self = table;
                        luaState = table.GetLuaState();
                        self.AddRef();

                        _add = self.GetLuaFunction("Add");
                        _remove = self.GetLuaFunction("Remove");
                        //_call = self.GetLuaFunction("__call");            
        }

        // RVA: 0x2288C94
        public void Dispose()
        {
                        --count;

                        if (count > 0)
                        {
                            return;
                        }

                        IsAlive = false;
                        Dispose(true);            
        }

        // RVA: 0x2288D00
        private void Clear()
        {
                        //_call = null;
                        _add = null;
                        _remove = null;
                        self = null;            
                        luaState = null;
        }

        // RVA: 0x2288D10
        public void Dispose(bool disposeManagedResources)
        {
                        if (!beDisposed)
                        {
                            beDisposed = true;   

                            if (reference > 0 && luaState != null)
                            {
                                luaState.CollectRef(reference, name, !disposeManagedResources);
                            }

                            reference = -1;
                            luaState = null;
                            count = 0;
                        }            
        }

        // RVA: 0x2288DD0
        public void Add(LuaFunction func, LuaTable obj)
        {
                        if (func == null)
                        {
                            return;
                        }

                        _add.BeginPCall();
                        _add.Push(self);
                        _add.Push(func);
                        _add.Push(obj);
                        _add.PCall();
                        _add.EndPCall();
        }

        // RVA: 0x2288EB4
        public void Remove(LuaFunction func, LuaTable obj)
        {
                        if (func == null)
                        {
                            return;
                        }

                        _remove.BeginPCall();
                        _remove.Push(self);
                        _remove.Push(func);
                        _remove.Push(obj);
                        _remove.PCall();
                        _remove.EndPCall();
        }
    }
}
