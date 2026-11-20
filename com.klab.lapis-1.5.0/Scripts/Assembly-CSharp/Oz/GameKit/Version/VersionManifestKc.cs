// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.VersionManifestKc
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;
using System.Text;
using System.IO;
using UnityEngine;

namespace Oz.GameKit.Version
{
    /// <summary>Kc 版清单（JSON），同时携带 SQLite 三段密钥与语言/平台信息。</summary>
    public class VersionManifestKc
    {
        public string appVersion;
        public string appUrl;
        public string resVersion;
        public string startTime;
        public string endTime;
        public uint sqliteKey1;
        public uint sqliteKey2;
        public uint sqliteKey3;
        public string platform;
        public string lang;

        /// <summary>资源版本号（取 resVersion 中 '-' 前的数字部分）。</summary>
        public ulong NumVersion { get; set; }

        // RVA: 0x1892954
        public VersionManifestKc()
        {
        }

        // RVA: 0x189295C
        public VersionManifestKc(string appVersion, string appURL, string resVersion)
        {
            this.appVersion = appVersion;
            appUrl = appURL;
            this.resVersion = resVersion;
            NumVersion = ulong.Parse(resVersion.Split('-')[0]);
        }

        // RVA: 0x1887A40
        public static VersionManifestKc ReadFromString(string jsonText)
        {
            return JsonUtility.FromJson<VersionManifestKc>(jsonText);
        }
        // RVA: 0x1892A34
        public bool ReadFromStream(Stream stream)
        {
            XmlDocument document = new XmlDocument();
            document.Load(stream);

            XmlNode version = document.SelectSingleNode("Version");
            if (version != null)
            {
                XmlNode app = version.SelectSingleNode("App");
                if (app != null)
                {
                    if (app.Attributes["Version"] != null)
                    {
                        appVersion = app.Attributes["Version"].Value;
                    }
                    if (app.Attributes["URL"] != null)
                    {
                        appUrl = app.Attributes["URL"].Value;
                    }
                    if (app.Attributes["ResVersion"] != null)
                    {
                        resVersion = app.Attributes["ResVersion"].Value;
                    }
                }
            }
            return true;
        }
        // RVA: 0x1892C60
        public bool WriteToStream(Stream stream)
        {
            string json = JsonUtility.ToJson(this);
            Debug.Log(json);

            byte[] bytes = Encoding.UTF8.GetBytes(json);
            stream.Write(bytes, 0, bytes.Length);
            return true;
        }
    }
}
