// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp-firstpass.dll
//  TPNSPush.TPNSAPIManager
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//
//  对腾讯 TPNS 的 Unity 桥接（com.tencent.unity.push.TPNSBridge）的静态封装。
//  集合类参数统一序列化为 JSON 字符串后传给 Java 侧。
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

namespace TPNSPush
{
    /// <summary>TPNS 推送的 JNI 封装。</summary>
    public class TPNSAPIManager : MonoBehaviour
    {
        private static AndroidJavaObject _plugin;

        // RVA: 0x2ECE884
        static TPNSAPIManager()
        {
            using (AndroidJavaClass bridge = new AndroidJavaClass("com.tencent.unity.push.TPNSBridge"))
            {
                _plugin = bridge.CallStatic<AndroidJavaObject>("shareInstance");
            }
        }

        // RVA: 0x2ECEA58
        public static void InitPush(string gameObject)
        {
            _plugin.Call("initPush", gameObject);
        }

        // RVA: 0x2ECEB44
        public static void SetDebugMode(bool mode)
        {
            _plugin.Call("setDebugMode", mode);
        }

        // RVA: 0x2ECEC50
        public static void SetDomain(string domain)
        {
            _plugin.Call("setDomain", domain);
        }

        // RVA: 0x2ECED3C
        public static string TPNSToken()
        {
            return _plugin.Call<string>("getTPNSToken");
        }

        // RVA: 0x2ECEE5C
        public static string SDKVersion()
        {
            return _plugin.Call<string>("getSDKVersion");
        }

        // RVA: 0x2ECEF7C
        public static void ClearCache()
        {
            _plugin.Call("clearCache");
        }

        // RVA: 0x2ECF094
        public static void SetBadge(int count)
        {
            _plugin.Call("setBadge", count);
        }

        // 空实现（iOS 专用，Android 侧无对应 JNI 调用）
        // RVA: 0x2ECF1A0
        public static void SetApplicationBadge(int count)
        {
        }

        // RVA: 0x2ECF1A4
        public static int GetApplicationBadge()
        {
            return 0;
        }

        // RVA: 0x2ECF1AC
        public static void StopPush()
        {
            _plugin.Call("stopPush");
        }

        /// <summary>批量绑定账号：Dictionary → List&lt;Account&gt; → JSON。</summary>
        // RVA: 0x2ECF2C4
        public static void UpsertAccounts(Dictionary<int, string> accounts)
        {
            List<Account> list = new List<Account>();
            foreach (KeyValuePair<int, string> pair in accounts)
            {
                list.Add(new Account(pair.Key, pair.Value));
            }
            _plugin.Call("upsertAccount", JsonHelper.ToJson(list));
        }

        // RVA: 0x2ECF4FC
        public static void DeleteAccountsByKeys(List<int> keys)
        {
            _plugin.Call("deleteAccountByKeys", JsonHelper.ToJson(keys));
        }

        // RVA: 0x2ECF604
        public static void ClearAccounts()
        {
            _plugin.Call("clearAccounts");
        }

        // RVA: 0x2ECF71C
        public static void AppendTags(List<string> tags)
        {
            _plugin.Call("appendTags", JsonHelper.ToJson(tags));
        }

        // RVA: 0x2ECF824
        public static void DeleteTags(List<string> tags)
        {
            _plugin.Call("deleteTags", JsonHelper.ToJson(tags));
        }

        // RVA: 0x2ECF92C
        public static void ClearTags()
        {
            _plugin.Call("clearTags");
        }

        // RVA: 0x2ECFA44
        public static void ClearAndAppendTags(List<string> tags)
        {
            _plugin.Call("clearAndAppendTags", JsonHelper.ToJson(tags));
        }

        /// <summary>批量设置属性：Dictionary → List&lt;Attribute&gt; → JSON。</summary>
        // RVA: 0x2ECFB4C
        public static void UpsertAttributes(Dictionary<string, string> attributes)
        {
            List<Attribute> list = new List<Attribute>();
            foreach (KeyValuePair<string, string> pair in attributes)
            {
                list.Add(new Attribute(pair.Key, pair.Value));
            }
            _plugin.Call("upsertAttributes", JsonHelper.ToJson(list));
        }

        // RVA: 0x2ECFD7C
        public static void DeleteAttributesByKeys(List<string> keys)
        {
            _plugin.Call("deleteAttributesByKeys", JsonHelper.ToJson(keys));
        }

        // RVA: 0x2ECFE84
        public static void ClearAttributes()
        {
            _plugin.Call("clearAttributes");
        }

        // RVA: 0x2ECFF9C
        public static void ClearAndAppendAttributes(Dictionary<string, string> attributes)
        {
            ClearAttributes();
            UpsertAttributes(attributes);
        }

        // RVA: 0x2ED01CC
        public TPNSAPIManager()
        {
        }
    }
}
