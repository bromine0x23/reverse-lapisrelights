// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.Utility.SecurityUtil
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;
using System.Collections.Generic;
using System.Text;
using Kc.Utility;
using LuaInterface;

namespace Oz.Framework.Utility
{
    /// <summary>请求校验用的 Lua 资源哈希生成。</summary>
    public class SecurityUtil
    {
        /// <summary>
        /// 由 Lua 资源哈希表派生请求签名：
        /// Base64( ver(1B) + SHA1(requestId + 所有 value 拼接) + 每条 key 的 SHA1 前 8 位拼接 )。
        /// </summary>
        // RVA: 0x2EDC3E4
        public static string GetLuaHash(string requestId, int ver = 1)
        {
            LuaResLoader loader = LuaFileUtils.Instance as LuaResLoader;
            Dictionary<string, string> radLuaHash = loader.GetRadLuaHash(3);
            if (radLuaHash == null)
            {
                return "";
            }

            SimpleByteArray buffer = new SimpleByteArray();
            buffer.Write((byte)ver);

            StringBuilder values = new StringBuilder();
            StringBuilder keyHashes = new StringBuilder();
            foreach (KeyValuePair<string, string> pair in radLuaHash)
            {
                values.Append(pair.Value);
                keyHashes.Append(CryptographyUtil.GetSHA1(pair.Key, 0).Substring(0, 8));
            }

            buffer.Write(CryptographyUtil.GetSHA1(requestId + values.ToString(), 0));
            buffer.Write(keyHashes.ToString());

            string result = Convert.ToBase64String(buffer.m_ms.ToArray());
            buffer.Dispose();
            return result;
        }

        // RVA: 0x2EEC37C
        public SecurityUtil()
        {
        }
    }
}
