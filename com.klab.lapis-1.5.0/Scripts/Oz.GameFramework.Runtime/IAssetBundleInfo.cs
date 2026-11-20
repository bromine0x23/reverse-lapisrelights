// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.IAssetBundleInfo
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
    public interface IAssetBundleInfo : IPackageInfo
    {
        public abstract int[] get_Dependencies();
        public abstract int get_EncryptKey();
        public abstract int[] Dependencies { get; }
        public abstract int EncryptKey { get; }
    }
}
