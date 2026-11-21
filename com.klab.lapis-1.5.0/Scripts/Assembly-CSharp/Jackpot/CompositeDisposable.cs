// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.CompositeDisposable
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
    public class CompositeDisposable : ICollection<IDisposable>, IEnumerable<IDisposable>, IEnumerable, IDisposable
    {
        private List<IDisposable> disposables;
        public bool IsDisposed { get; set; }
        public int Count { get { return disposables.Count; } }
        public bool IsReadOnly { get { return false; } }


        // RVA: 0x1789694
        public CompositeDisposable()
        {
                        disposables = new List<IDisposable>();
                        disposed = false;
        }

        // RVA: 0x178970C
        public CompositeDisposable(IEnumerable<IDisposable> disposables)
            : this()
        {
                        foreach (IDisposable disposable in disposables)
                        {
                            Add(disposable);
                        }
        }

        // RVA: 0x1789A54
        public CompositeDisposable(IDisposable[] disposables)
            : this(disposables.Length)
        {
                        foreach (IDisposable disposable in disposables)
                        {
                            Add(disposable);
                        }
        }

        // RVA: 0x1789AD4
        public CompositeDisposable(int capacity)
        {
                        disposables = new List<IDisposable>(capacity);
                        disposed = false;
        }

        // RVA: 0x1789B5C
        ~CompositeDisposable()
        {
                        if (!disposed)
                        {
                            Clear();
                            disposed = true;
                        }
        }

        // RVA: 0x178996C
        public void Add(IDisposable item)
        {
                        if (disposed)
                        {
                            item.Dispose();
                        }
                        else
                        {
                            disposables.Add(item);
                        }
        }

        // RVA: 0x1789C0C
        public bool Remove(IDisposable item)
        {
                        return disposables.Remove(item);
        }

        // RVA: 0x1789C74
        public void Clear()
        {
                        foreach (IDisposable disposable in disposables)
                        {
                            disposable.Dispose();
                        }

                        disposables.Clear();
        }

        // RVA: 0x1789DEC
        public bool Contains(IDisposable item)
        {
                        return disposables.Contains(item);
        }

        // RVA: 0x1789E54
        public void CopyTo(IDisposable[] array, int arrayIndex)
        {
                        disposables.CopyTo(array, arrayIndex);
        }

        // RVA: 0x1789BD8
        public void Dispose()
        {
                        if (disposed)
                        {
                            return;
                        }

                        Clear();
                        disposed = true;
        }

        // RVA: 0x1789EC4
        public IEnumerator<IDisposable> GetEnumerator()
        {
                        return disposables.GetEnumerator();
        }

        // RVA: 0x1789F50
        private IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
                        return GetEnumerator();
        }
    }
}
