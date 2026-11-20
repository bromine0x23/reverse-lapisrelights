// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.CryptoUtility
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;

namespace Oz.GameFramework.Runtime
{
    /// <summary>哈希 / 3DES / RSA / 随机数工具（静态复用密码学实例）。</summary>
    public static class CryptoUtility
    {
        private static SHA1CryptoServiceProvider s_SHA1CryptoServiceProvider;
        private static SHA256CryptoServiceProvider s_SHA256CryptoServiceProvider;
        private static MD5CryptoServiceProvider s_MD5CryptoServiceProvider;
        private static RSACryptoServiceProvider s_RSACryptoServiceProvider;
        private static RNGCryptoServiceProvider s_RNGCryptoServiceProvider;

        // RVA: 0x2E9060C
        public static string BytesToHexString(byte[] bytes)
        {
            return Hexlify(bytes);
        }

        /// <summary>字节数组 → 小写十六进制字符串。</summary>
        // RVA: 0x2E90670
        public static string Hexlify(byte[] data)
        {
            if (data.Length == 0)
            {
                return string.Empty;
            }
            StringBuilder sb = new StringBuilder(data.Length * 2);
            for (int i = 0; i < data.Length; i++)
            {
                sb.Append(data[i].ToString("x2"));
            }
            return sb.ToString();
        }

        // RVA: 0x2E90798
        static CryptoUtility()
        {
            s_SHA1CryptoServiceProvider = new SHA1CryptoServiceProvider();
            s_SHA256CryptoServiceProvider = new SHA256CryptoServiceProvider();
            s_MD5CryptoServiceProvider = new MD5CryptoServiceProvider();
            s_RSACryptoServiceProvider = new RSACryptoServiceProvider();
            s_RNGCryptoServiceProvider = new RNGCryptoServiceProvider();
        }

        // RVA: 0x2E908A8
        public static string GetBase64String(byte[] radBytes)
        {
            return Convert.ToBase64String(radBytes);
        }

        /// <summary>文件 SHA1（十六进制小写）。</summary>
        // RVA: 0x2E90910
        public static string CalcFileHash(string filePath)
        {
            using (Stream stream = File.OpenRead(filePath))
            {
                return BytesToHexString(s_SHA1CryptoServiceProvider.ComputeHash(stream));
            }
        }

        // RVA: 0x2E90A68
        public static string CalcBytesHash(byte[] buffer, int offset, int count)
        {
            return BytesToHexString(s_SHA1CryptoServiceProvider.ComputeHash(buffer, offset, count));
        }

        // RVA: 0x2E90B00
        public static string CalcStringHash(string value)
        {
            byte[] bytes = Encoding.UTF8.GetBytes(value);
            return BytesToHexString(s_SHA1CryptoServiceProvider.ComputeHash(bytes));
        }

        // RVA: 0x2E90B98
        public static byte[] HmacSha1(byte[] data, byte[] key)
        {
            using (HMACSHA1 hmac = new HMACSHA1(key))
            {
                return hmac.ComputeHash(data);
            }
        }

        // RVA: 0x2E90C18
        public static string CalcFileSHA256(string filePath)
        {
            using (Stream stream = File.OpenRead(filePath))
            {
                return BytesToHexString(s_SHA256CryptoServiceProvider.ComputeHash(stream));
            }
        }

        // RVA: 0x2E90D70
        public static string CalcBytesSHA256(byte[] buffer, int offset, int count)
        {
            return BytesToHexString(s_SHA256CryptoServiceProvider.ComputeHash(buffer, offset, count));
        }

        // RVA: 0x2E90E08
        public static string CalcStringSHA256(string value)
        {
            byte[] bytes = Encoding.UTF8.GetBytes(value);
            return BytesToHexString(s_SHA256CryptoServiceProvider.ComputeHash(bytes));
        }

        /// <summary>3DES(ECB/PKCS7) 加密。</summary>
        // RVA: 0x2E90EA0
        public static byte[] GetDES3Bytes(byte[] data, byte[] key)
        {
            MemoryStream ms = new MemoryStream();
            TripleDESCryptoServiceProvider des = new TripleDESCryptoServiceProvider();
            des.Mode = CipherMode.ECB;
            des.Padding = PaddingMode.PKCS7;
            ICryptoTransform transform = des.CreateEncryptor(key, null);
            CryptoStream cs = new CryptoStream(ms, transform, CryptoStreamMode.Write);
            cs.Write(data, 0, data.Length);
            cs.FlushFinalBlock();
            byte[] result = ms.ToArray();
            cs.Close();
            ms.Close();
            return result;
        }

        /// <summary>3DES(ECB/PKCS7) 解密。</summary>
        // RVA: 0x2E910E4
        public static byte[] DecryptDES3(byte[] data, byte[] key)
        {
            MemoryStream ms = new MemoryStream();
            TripleDESCryptoServiceProvider des = new TripleDESCryptoServiceProvider();
            des.Mode = CipherMode.ECB;
            des.Padding = PaddingMode.PKCS7;
            ICryptoTransform transform = des.CreateDecryptor(key, null);
            CryptoStream cs = new CryptoStream(ms, transform, CryptoStreamMode.Write);
            cs.Write(data, 0, data.Length);
            cs.FlushFinalBlock();
            byte[] result = ms.ToArray();
            cs.Close();
            ms.Close();
            return result;
        }

        // RVA: 0x2E91328
        public static byte[] GetMd5Bytes(byte[] datas, int offset = 0)
        {
            return s_MD5CryptoServiceProvider.ComputeHash(datas, offset, datas.Length - offset);
        }

        // RVA: 0x2E913C0
        public static string GetMD5BytesString(byte[] datas, int offset = 0)
        {
            byte[] md5 = GetMd5Bytes(datas, offset);
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < md5.Length; i++)
            {
                sb.Append(md5[i].ToString("X2"));
            }
            return sb.ToString();
        }

        // RVA: 0x2E91438
        public static string GetFileMD5(string fn, int offset = 0)
        {
            return GetMD5BytesString(File.ReadAllBytes(fn), offset);
        }

        // RVA: 0x2E914C0
        public static string GetMD5(string datas, int offset = 0)
        {
            return GetMD5BytesString(Encoding.UTF8.GetBytes(datas), offset);
        }

        /// <summary>用给定 XML 公钥加密（OAEP）。</summary>
        // RVA: 0x2E91560
        public static byte[] PublicEncrypt(byte[] data, string xml)
        {
            s_RSACryptoServiceProvider.FromXmlString(xml);
            return s_RSACryptoServiceProvider.Encrypt(data, true);
        }

        /// <summary>线性同余伪随机数：LCG(1103515245, 12345) 取高 16 位并保留 15 位。</summary>
        // RVA: 0x2E9160C
        public static uint Rand(int idx)
        {
            uint v = unchecked((uint)(1103515245 * idx + 12345));
            return (v >> 16) & 0x7FFF;
        }

        // RVA: 0x2E9163C
        public static byte[] RandomBytes(int len)
        {
            byte[] bytes = new byte[len];
            s_RNGCryptoServiceProvider.GetBytes(bytes);
            return bytes;
        }
    }
}
