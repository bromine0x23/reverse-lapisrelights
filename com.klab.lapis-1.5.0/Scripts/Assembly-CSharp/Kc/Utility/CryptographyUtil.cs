// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Kc.Utility.CryptographyUtil
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using Kc.Config;

namespace Kc.Utility
{
    /// <summary>哈希、对称/非对称加密与字节工具。</summary>
    public class CryptographyUtil
    {
        private static SHA1CryptoServiceProvider sha1Provider;
        private static RSACryptoServiceProvider rsa;
        private static RNGCryptoServiceProvider rng;

        /// <summary>对文件内容求 SHA1（流式读取）。</summary>
        // RVA: 0x1EE1780
        public static string GetFileHash(string path)
        {
            using (Stream stream = File.OpenRead(path))
            {
                SHA1CryptoServiceProvider provider = new SHA1CryptoServiceProvider();
                byte[] hash = provider.ComputeHash(stream);
                return GetBytesString(hash);
            }
        }

        /// <summary>对字节数组求 SHA1，返回大写十六进制字符串。</summary>
        // RVA: 0x1EE19F0
        public static string GetSha1BytesHash(byte[] byteArr)
        {
            return GetBytesString(sha1Provider.ComputeHash(byteArr));
        }

        // RVA: 0x1EE1A70
        public static byte[] GetSHA1Bytes(byte[] datas, int offset = 0)
        {
            using (SHA1CryptoServiceProvider provider = new SHA1CryptoServiceProvider())
            {
                return provider.ComputeHash(datas, offset, datas.Length - offset);
            }
        }

        // RVA: 0x1EE1AFC
        public static string GetSHA1BytesString(byte[] datas, int offset = 0)
        {
            return GetBytesString(GetSHA1Bytes(datas, offset));
        }

        /// <summary>字节数组 → 大写十六进制字符串。</summary>
        // RVA: 0x1EE18F4
        private static string GetBytesString(byte[] ret)
        {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < ret.Length; i++)
            {
                sb.Append(ret[i].ToString("X2"));
            }
            return sb.ToString();
        }

        // RVA: 0x1EE1B74
        public static string GetFileSHA1(string fn, int offset = 0)
        {
            return GetSHA1BytesString(File.ReadAllBytes(fn), offset);
        }

        // RVA: 0x1EE1BFC
        public static string GetSHA1(string datas, int offset = 0)
        {
            return GetSHA1BytesString(Encoding.UTF8.GetBytes(datas), offset);
        }

        // RVA: 0x1EE1C9C
        public static byte[] GetMd5Bytes(byte[] datas, int offset = 0)
        {
            using (MD5CryptoServiceProvider provider = new MD5CryptoServiceProvider())
            {
                return provider.ComputeHash(datas, offset, datas.Length - offset);
            }
        }

        // RVA: 0x1EE1D28
        public static string GetMd5BytesString(byte[] datas, int offset = 0)
        {
            byte[] md5 = GetMd5Bytes(datas, offset);
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < md5.Length; i++)
            {
                sb.Append(md5[i].ToString("X2"));
            }
            return sb.ToString();
        }

        // RVA: 0x1EE1E5C
        public static string GetFileMd5(string fn, int offset = 0)
        {
            return GetMd5BytesString(File.ReadAllBytes(fn), offset);
        }

        // RVA: 0x1EE1EE4
        public static string GetMd5(string datas, int offset = 0)
        {
            return GetMd5BytesString(Encoding.UTF8.GetBytes(datas), offset);
        }

        /// <summary>3DES(ECB/PKCS7) 加密后转 Base64。</summary>
        // RVA: 0x1EE1F84
        public static string GetDES3(string text, string str_key)
        {
            byte[] data = Encoding.UTF8.GetBytes(text);
            byte[] key = Encoding.UTF8.GetBytes(str_key);
            return Convert.ToBase64String(GetDES3Bytes(data, key));
        }

        // RVA: 0x1EE207C
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

        // RVA: 0x1EE22BC
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

        /// <summary>用内置 RSA 公钥（<see cref="KcAppSetting.RsaPublicKey"/>）创建 1024 位实例。</summary>
        // RVA: 0x1EE24FC
        private static RSACryptoServiceProvider CreateRSAProvider()
        {
            RSACryptoServiceProvider provider = new RSACryptoServiceProvider(1024);
            provider.FromXmlString(KcAppSetting.RsaPublicKey);
            return provider;
        }

        // RVA: 0x1EE25A0
        public static byte[] PublicEncrypt(byte[] data)
        {
            return rsa.Encrypt(data, true);
        }

        // RVA: 0x1EE2620
        public static byte[] RandomBytes(int len)
        {
            byte[] bytes = new byte[len];
            rng.GetBytes(bytes);
            return bytes;
        }

        /// <summary>生成 MAK：随机数 → RSA 公钥加密 → Base64。</summary>
        // RVA: 0x1EE26C4
        public static string GetMakData(byte[] randomBytes)
        {
            return Convert.ToBase64String(PublicEncrypt(randomBytes));
        }

        // RVA: 0x1EE275C
        public static string GetBase64String(byte[] radBytes)
        {
            return Convert.ToBase64String(radBytes);
        }

        // RVA: 0x1EE27C4
        public static byte[] HmacSha1(byte[] data, byte[] key)
        {
            using (HMACSHA1 hmac = new HMACSHA1(key))
            {
                return hmac.ComputeHash(data);
            }
        }

        /// <summary>字节数组 → 小写十六进制字符串。</summary>
        // RVA: 0x1EE2844
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

        // RVA: 0x1EE296C
        public static byte[] XorBytes(byte[] l, byte[] r)
        {
            if (l.Length != r.Length)
            {
                throw new ArgumentException();
            }
            byte[] result = new byte[l.Length];
            for (int i = 0; i < l.Length; i++)
            {
                result[i] = (byte)(r[i] ^ l[i]);
            }
            return result;
        }

        // RVA: 0x1EE2A84
        public CryptographyUtil()
        {
        }

        // RVA: 0x1EE2A8C
        static CryptographyUtil()
        {
            sha1Provider = new SHA1CryptoServiceProvider();
            rsa = CreateRSAProvider();
            rng = new RNGCryptoServiceProvider();
        }
    }
}
