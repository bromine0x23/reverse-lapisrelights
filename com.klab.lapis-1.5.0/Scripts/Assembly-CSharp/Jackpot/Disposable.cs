// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Disposable
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
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
    public static class Disposable
    {
        private static readonly IDisposable empty;

        public static IDisposable Empty
        {
            get { return empty; }
        }

        // RVA: 0x19E2F04
        public static IDisposable Create(Action dispose)
        {
            return new AnonymousDisposable(dispose);
        }

        // RVA: 0x19E2F94
        static Disposable()
        {
            empty = new EmptyDisposable();
        }

        private class EmptyDisposable : IDisposable
        {
            // RVA: 0x19E30B0
            public void Dispose()
            {
            }
        }

        private class AnonymousDisposable : IDisposable
        {
            private Action onDispose;

            // RVA: 0x19E2F68
            public AnonymousDisposable(Action onDispose)
            {
                this.onDispose = onDispose;
            }

            ~AnonymousDisposable()
            {
                Dispose();
            }

            // RVA: 0x19E3080
            public void Dispose()
            {
                if (onDispose != null)
                {
                    onDispose();
                    onDispose = null;
                }
            }
        }
    }
}
