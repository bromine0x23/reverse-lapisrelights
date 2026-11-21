// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.RefCountDisposable
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
    public class RefCountDisposable : IDisposable
    {
        private IDisposable disposable;
        private int refCount;
        public bool IsDisposed { get; private set; }


        // RVA: 0x1EA04FC
        public RefCountDisposable(IDisposable disposable)
        {
        }

        // RVA: 0x1EA052C
        public IDisposable GetDisposable()
        {
            if (IsDisposed)
            {
                return Disposable.Empty;
            }

            refCount++;
            return Disposable.Create(OnDisposed);
        }

        // RVA: 0x1EA0648
        private void OnDisposed()
        {
            if (--refCount > 0)
            {
                return;
            }

            Dispose();
        }

        // RVA: 0x1EA0664
        public void Dispose()
        {
            if (IsDisposed)
            {
                return;
            }

            if (refCount > 0)
            {
                return;
            }

            disposable.Dispose();
            disposable = null;
            IsDisposed = true;
        }
    }
}
