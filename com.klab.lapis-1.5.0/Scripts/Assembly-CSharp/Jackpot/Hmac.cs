// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Hmac
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
    public static class Hmac
    {

        // RVA: 0x19F28D0
        private static HMAC Md5Factory(byte[] key)
        {
            return key == null ? new HMACMD5() : new HMACMD5(key);
        }

        // RVA: 0x19F2944
        private static HMAC Ripemd160Factory(byte[] key)
        {
            return key == null ? new HMACRIPEMD160() : new HMACRIPEMD160(key);
        }

        // RVA: 0x19F29B8
        private static HMAC Sha1Factory(byte[] key)
        {
            return key == null ? new HMACSHA1() : new HMACSHA1(key, false);
        }

        // RVA: 0x19F2A30
        private static HMAC Sha256Factory(byte[] key)
        {
            return key == null ? new HMACSHA256() : new HMACSHA256(key);
        }

        // RVA: 0x19F2AA4
        private static HMAC Sha384Factory(byte[] key)
        {
            return key == null ? new HMACSHA384() : new HMACSHA384(key);
        }

        // RVA: 0x19F2B18
        private static HMAC Sha512Factory(byte[] key)
        {
            return key == null ? new HMACSHA512() : new HMACSHA512(key);
        }

        // RVA: 0x19F2B8C
        public static string Hash(Func<byte[], HMAC> hmacFactory, byte[] key, byte[] data)
        {
            using (HMAC hmac = hmacFactory(key))
            {
                byte[] hash = hmac.ComputeHash(data);
                return BitConverter.ToString(hash).ToLower().Replace("-", "");
            }
        }

        // RVA: 0x19F2D18
        public static string Md5Hash(byte[] key, byte[] data)
        {
            return Hash(Md5Factory, key, data);
        }

        // RVA: 0x19F2DA4
        public static string Ripemd160Hash(byte[] key, byte[] data)
        {
            return Hash(Ripemd160Factory, key, data);
        }

        // RVA: 0x19F2E30
        public static string Sha1Hash(byte[] key, byte[] data)
        {
            return Hash(Sha1Factory, key, data);
        }

        // RVA: 0x19F2EBC
        public static string Sha256Hash(byte[] key, byte[] data)
        {
            return Hash(Sha256Factory, key, data);
        }

        // RVA: 0x19F2F48
        public static string Sha384Hash(byte[] key, byte[] data)
        {
            return Hash(Sha384Factory, key, data);
        }

        // RVA: 0x19F2FD4
        public static string Sha512Hash(byte[] key, byte[] data)
        {
            return Hash(Sha512Factory, key, data);
        }
    }
}
