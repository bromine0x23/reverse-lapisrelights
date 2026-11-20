// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.IPackageInfo
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

namespace Oz.GameFramework.Runtime
{
    public interface IPackageInfo
    {
        public abstract string get_Name();
        public abstract ulong get_Size();
        public abstract string get_Hash();
        public abstract int get_Flags();
        public abstract bool HasFlag(ePackageFlag flag);
        public abstract void AddFlag(ePackageFlag flag);
        public abstract void RemoveFlag(ePackageFlag flag);
        public abstract string GetFilePath();
        public abstract string Name { get; }
        public abstract ulong Size { get; }
        public abstract string Hash { get; }
        public abstract int Flags { get; }
    }
}
