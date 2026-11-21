// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.IPackageManifest
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

namespace Oz.GameFramework.Runtime
{
    public interface IPackageManifest
    {
        public abstract string get_AppVersion();
        public abstract string get_Version();
        public abstract ulong get_ResVersion();
        public abstract IPackageInfo[] GetAllPackageInfos();
        public abstract bool Exist(string packageName);
        public abstract bool TryGetPackageInfo(string packageName, out IPackageInfo packageInfo);
        public abstract IPackageInfo GetPackageInfo(string packageName);
        public abstract int GetPackageIndex(string packageName);
        public abstract void AddPackageInfo(IPackageInfo packageInfo);
        public abstract string[] GetPackagesWithFlag(ePackageFlag flag);
        public abstract string GetPackageHash(string packageName);
        public abstract string GetPackageFilePath(string packageName);
        public abstract string GetPackageLoadPath(string packageName);
        public abstract ulong GetPackageSize(string packageName);
        public abstract void SetVersion(string version);
        public abstract void SetResVersion(ulong resVersion);
        public abstract void SetAppVersion(string appVersion);
        public abstract string AppVersion { get; }
        public abstract string Version { get; }
        public abstract ulong ResVersion { get; }
    }
}
