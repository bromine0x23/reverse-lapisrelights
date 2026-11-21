// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.FileSystemEntry
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
    public class FileSystemEntry
    {
        public static readonly int CurrentFormat;
        public static readonly int CurrentFormatColumn;
        public static readonly string CommandModify;
        public static readonly string CommandRemove;
        public string Path { get; private set; }
        public string Tag { get; private set; }
        public int Version { get { return _Version; } }
        public string VersionString { get; private set; }




        // RVA: 0x19EAD14
        public int get_Version()
        {
            return _Version;
        }



        // RVA: 0x19F1390
        public FileSystemEntry(string path, string tag, int version)
        {
                        Path = path;
                        Tag = tag;
                        VersionString = version.ToString();
        }

        // RVA: 0x19EF314
        public FileSystemEntry(string path, string tag, string version)
        {
            Path = path;
            Tag = tag;
            VersionString = version;
        }

        // RVA: 0x19F13EC
        public FileSystemEntry(FileSystemEntry entry)
        {
                        if (entry != null)
                        {
                            Path = entry.Path;
                            Tag = entry.Tag;
                            VersionString = entry.VersionString;
                        }
        }

        // RVA: 0x19F1434
        public override string ToString()
        {
                        return string.Format("[FileSystemEntry: Path={0}, Tag={1}, Version={2}]", Path, Tag, VersionString);
        }

        // RVA: 0x19EF444
        public string ToCsvString()
        {
                        return string.Format("{0},{1},{2},{3}", CommandModify, Path, Tag, VersionString);
        }

        // RVA: 0x19EF764
        public string ToRemoveCsvString()
        {
                        return string.Format("{0},{1},,", CommandRemove, Path);
        }

        // RVA: 0x19F148C
        static FileSystemEntry()
        {
                        CurrentFormat = 1;
                        CurrentFormatColumn = 4;
                        CommandModify = "M";
                        CommandRemove = "R";
        }
    }
}
