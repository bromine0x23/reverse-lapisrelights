// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.PackageManifest
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Oz.GameKit.Version
{
    public class PackageManifest : IPackageManifest
    {
        private Dictionary<string, int> m_PackageName2Index;
        private List<IPackageInfo> m_PackageInfos;
        private Queue<int> m_EmptyIndexQueue;
        public string AppVersion { get; private set; }
        public ulong ResVersion { get; private set; }
        public string Version { get; set; }

        // RVA: 0x187F978
        private void set_Version(string value)
        {
            m__Version = value;
            ResVersion = ulong.Parse(value.Split('-')[0]);
        }

        // RVA: 0x187FA30
        public PackageManifest(string appVersion, ulong resVersion)
        {
            AppVersion = appVersion;
            ResVersion = resVersion;
            m_PackageInfos = new List<IPackageInfo>();
            m_PackageName2Index = new Dictionary<string, int>();
            m_EmptyIndexQueue = new Queue<int>();
        }

        // RVA: 0x187FB08
        public PackageManifest(string appVersion, string version)
        {
            AppVersion = appVersion;
            Version = version;
            m_PackageInfos = new List<IPackageInfo>();
            m_PackageName2Index = new Dictionary<string, int>();
            m_EmptyIndexQueue = new Queue<int>();
        }

        // RVA: 0x187FBEC
        public PackageManifest Clone(int addedVersion = 0)
        {
            string[] parts = Version.Split('-');
            long version = long.Parse(parts[0]) + addedVersion;
            parts[0] = version.ToString();

            if (addedVersion >= 1)
            {
                parts[2] = GetMaskVersion(parts[0], parts[1]);
            }

            PackageManifest clone = new PackageManifest(AppVersion, string.Join("-", parts));

            foreach (KeyValuePair<string, int> pair in m_PackageName2Index)
            {
                clone.m_PackageName2Index.Add(pair.Key, pair.Value);
            }
            for (int i = 0; i < m_PackageInfos.Count; i++)
            {
                clone.m_PackageInfos.Add(m_PackageInfos[i]);
            }

            return clone;
        }

        // RVA: 0x187FFE4
        public IPackageInfo[] GetAllPackageInfos()
        {
            return m_PackageInfos.ToArray();
        }

        // RVA: 0x188003C
        public bool WriteToXmlDocument(Stream stream)
        {
            XmlDocument document = new XmlDocument();
            document.AppendChild(document.CreateXmlDeclaration("1.0", "UTF-8", null));

            XmlElement versionElement = document.CreateElement("Version");
            versionElement.SetAttribute("App", AppVersion);
            versionElement.SetAttribute("Res", Version);
            document.AppendChild(versionElement);

            XmlElement infosElement = document.CreateElement("Infos");
            versionElement.AppendChild(infosElement);

            DefaultAssetBundlesManifest manifest = new DefaultAssetBundlesManifest(this);

            foreach (IPackageInfo packageInfo in m_PackageInfos)
            {
                if (packageInfo is AssetBundleInfo assetBundleInfo)
                {
                    infosElement.AppendChild(assetBundleInfo.ToXmlElement(document, manifest));
                }
                else if (packageInfo is MasterDataInfo masterDataInfo)
                {
                    infosElement.AppendChild(masterDataInfo.ToXmlElement(document));
                }
                else if (packageInfo is SoundBankInfo soundBankInfo)
                {
                    infosElement.AppendChild(soundBankInfo.ToXmlElement(document));
                }
            }

            document.Save(stream);
            return true;
        }

        // RVA: 0x18805F4
        public bool TryGetPackageInfo(string packageName, out IPackageInfo packageInfo)
        {
            int index = 0;
            if (!m_PackageName2Index.TryGetValue(packageName, out index))
            {
                packageInfo = null;
                return false;
            }
            if (m_PackageInfos.Count <= index)
            {
                packageInfo = null;
                return false;
            }
            packageInfo = m_PackageInfos[index];
            return true;
        }

        // RVA: 0x18806C0
        public int GetPackageIndex(string packageName)
        {
            int value = 0;
            if (m_PackageName2Index.TryGetValue(packageName, out value))
            {
                return value;
            }
            return -1;
        }

        // RVA: 0x1880740
        public IPackageInfo GetPackageInfo(string packageName)
        {
            int index = 0;
            if (!m_PackageName2Index.TryGetValue(packageName, out index))
            {
                return null;
            }
            if (m_PackageInfos.Count <= index)
            {
                return null;
            }
            return m_PackageInfos[index];
        }

        // RVA: 0x18807F4
        private bool GetPackageSize(int index, out ulong size)
        {
            if (m_PackageInfos.Count <= index)
            {
                size = 0;
                return false;
            }
            size = m_PackageInfos[index].Size;
            return true;
        }

        // RVA: 0x18808FC
        private bool GetPackageSize(string packageName, out ulong size)
        {
            int index = 0;
            if (m_PackageName2Index.TryGetValue(packageName, out index))
            {
                return GetPackageSize(index, out size);
            }
            size = 0;
            return false;
        }

        // RVA: 0x18809A0
        public ulong GetPackageSize(string packageName)
        {
            ulong size = 0;
            if (GetPackageSize(packageName, out size))
            {
                return size;
            }
            return 0;
        }

        // RVA: 0x18809D0
        public void AddPackageInfo(IPackageInfo packageInfo)
        {
            if (packageInfo == null)
            {
                throw new ArgumentNullException("packageInfo is null");
            }
            if (m_PackageName2Index.ContainsKey(packageInfo.Name))
            {
                throw new ArgumentException("An element with the same name already exists in the manifest");
            }

            int index;
            if (m_EmptyIndexQueue.Count < 1)
            {
                m_PackageInfos.Add(packageInfo);
                index = m_PackageInfos.Count - 1;
            }
            else
            {
                index = m_EmptyIndexQueue.Dequeue();
                m_PackageInfos[index] = packageInfo;
            }

            m_PackageName2Index.Add(packageInfo.Name, index);
        }

        // RVA: 0x187FED4
        private string GetMaskVersion(string verMain, string verionBuild)
        {
            string hash = CryptoUtility.CalcStringHash(verMain + verionBuild);
            StringBuilder builder = new StringBuilder();
            for (int i = 0; i < 10; i++)
            {
                int index = Random.Range(0, hash.Length);
                builder.Append(hash.Substring(index, 1));
            }
            return builder.ToString();
        }

        // RVA: 0x1880C14
        public bool Exist(string packageName)
        {
            return m_PackageName2Index.ContainsKey(packageName);
        }

        // RVA: 0x1880C7C
        public void Remove(string packageName)
        {
            if (!Exist(packageName))
            {
                return;
            }

            int index = GetPackageIndex(packageName);
            m_PackageInfos[index] = null;
            m_PackageName2Index.Remove(packageName);
            m_EmptyIndexQueue.Enqueue(index);
        }

        // RVA: 0x1880D54
        public string[] GetPackagesWithFlag(ePackageFlag flag)
        {
            return m_PackageInfos
                .Where(info => info.HasFlag(flag))
                .Select(info => info.Name)
                .ToArray();
        }

        // RVA: 0x1880EE0
        public void SetResVersion(ulong resVersion)
        {
            ResVersion = resVersion;
        }

        // RVA: 0x1880EE8
        public void SetAppVersion(string appVersion)
        {
            AppVersion = appVersion;
        }

        // RVA: 0x1880EF0
        private bool GetPackageFilePath(int index, out string packageFilePath)
        {
            if (m_PackageInfos.Count <= index)
            {
                packageFilePath = string.Empty;
                return false;
            }
            packageFilePath = m_PackageInfos[index].GetFilePath();
            return true;
        }

        // RVA: 0x1881008
        private bool GetPackageFilePath(string packageName, out string packageFilePath)
        {
            int index = 0;
            if (m_PackageName2Index.TryGetValue(packageName, out index))
            {
                return GetPackageFilePath(index, out packageFilePath);
            }
            packageFilePath = string.Empty;
            return false;
        }

        // RVA: 0x18810C0
        public string GetPackageFilePath(string packageName)
        {
            string packageFilePath = null;
            if (!GetPackageFilePath(packageName, out packageFilePath))
            {
                return string.Empty;
            }
            return packageFilePath;
        }

        // RVA: 0x188113C
        private bool GetPackageHash(int index, out string hash)
        {
            if (m_PackageInfos.Count <= index)
            {
                hash = string.Empty;
                return false;
            }
            hash = m_PackageInfos[index].Hash;
            return true;
        }

        // RVA: 0x1881254
        private bool GetPackageHash(string packageName, out string hash)
        {
            int index = 0;
            if (m_PackageName2Index.TryGetValue(packageName, out index))
            {
                return GetPackageHash(index, out hash);
            }
            hash = string.Empty;
            return false;
        }

        // RVA: 0x188130C
        public string GetPackageHash(string packageName)
        {
            string hash = null;
            if (!GetPackageHash(packageName, out hash))
            {
                return string.Empty;
            }
            return hash;
        }

        // RVA: 0x1881388
        private string GetPackageLoadPath(int index)
        {
            if (m_PackageInfos.Count <= index)
            {
                return string.Empty;
            }
            return PathUtility.GetPersistentDataPath();
        }

        // RVA: 0x1881414
        public string GetPackageLoadPath(string packageName)
        {
            int index = 0;
            if (m_PackageName2Index.TryGetValue(packageName, out index))
            {
                return GetPackageLoadPath(index);
            }
            return string.Empty;
        }

        // RVA: 0x18814B0
        public void SetVersion(string resVersion)
        {
            Version = resVersion;
        }
    }
}
