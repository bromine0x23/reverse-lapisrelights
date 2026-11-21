// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.FileSystemToc
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
    public class FileSystemToc : IEnumerable<FileSystemEntry>, IEnumerable
    {
        private Dictionary<string, FileSystemEntry> entries;
        public FileSystemEntry this[string path]
        {
            get { return new FileSystemEntry(entries[path]); }
            set { Modify(value); }
        }

        public int Count { get { return entries.Count; } }
        // RVA: 0x19F0558
        public FileSystemToc()
        {
                        entries = new Dictionary<string, FileSystemEntry>();
        }

        // RVA: 0x19EF354
        public void Modify(FileSystemEntry entry)
        {
                        if (entry == null)
                        {
                            throw new ArgumentNullException();
                        }

                        bool flag = entries.ContainsKey(entry.Path);
                        FileSystemEntry fileSystemEntry = new FileSystemEntry(entry);
                        if (flag)
                        {
                            entries[entry.Path] = fileSystemEntry;
                        }
                        else
                        {
                            entries.Add(entry.Path, fileSystemEntry);
                        }
        }

        // RVA: 0x19EAC18
        public bool Contains(string path)
        {
                        return entries.ContainsKey(path);
        }

        // RVA: 0x19EF6FC
        public bool Remove(string path)
        {
                        return entries.Remove(path);
        }

        // RVA: 0x19F03F8
        public void Clear()
        {
                        entries.Clear();
        }

        // RVA: 0x19ECF8C
        public IEnumerator<FileSystemEntry> GetEnumerator()
        {
                        return entries.Values.GetEnumerator();
        }

        // RVA: 0x19F1524
        private IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
                        return entries.Values.GetEnumerator();
        }
    }
}
