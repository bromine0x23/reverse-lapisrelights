// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Kc.Utility.IosDeviceRank
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;
using Oz.Framework.Utility;
using UnityEngine;

namespace Kc.Utility
{
    /// <summary>按 iOS 机型标识（如 "iPhone14,2"）给出设备性能档位。</summary>
    public class IosDeviceRank
    {
        private static Dictionary<string, string> iosRankMap;

        /// <summary>返回当前设备的性能档位（ultra/high/medium/low），未知机型返回空串。</summary>
        // RVA: 0x1EE2BF4
        public static string GetIosDeviceRank()
        {
            string deviceModel = SystemInfoUtil.deviceModel;
            if (iosRankMap.ContainsKey(deviceModel))
            {
                Debug.Log(">>>>>>>>>>>>>> Use Device Rank : " + iosRankMap[deviceModel]);
                return iosRankMap[deviceModel];
            }
            return "";
        }

        // RVA: 0x1EE2D60
        public IosDeviceRank()
        {
        }

        // RVA: 0x1EE2D68
        static IosDeviceRank()
        {
            iosRankMap = new Dictionary<string, string>
            {
                { "iPhone14,2", "ultra" },
                { "iPhone14,3", "ultra" },
                { "iPhone14,4", "ultra" },
                { "iPhone14,5", "ultra" },
                { "iPhone13,1", "ultra" },
                { "iPhone13,2", "ultra" },
                { "iPhone13,3", "ultra" },
                { "iPhone13,4", "ultra" },
                { "iPhone12,5", "high" },
                { "iPhone12,3", "high" },
                { "iPhone12,1", "high" },
                { "iPhone11,8", "high" },
                { "iPhone11,6", "high" },
                { "iPhone11,4", "high" },
                { "iPhone11,2", "high" },
                { "iPhone10,6", "high" },
                { "iPhone10,3", "high" },
                { "iPhone12,8", "medium" },
                { "iPhone10,5", "medium" },
                { "iPhone10,4", "medium" },
                { "iPhone10,2", "medium" },
                { "iPhone10,1", "medium" },
                { "iPhone9,4", "medium" },
                { "iPhone9,3", "medium" },
                { "iPhone9,2", "medium" },
                { "iPhone9,1", "medium" },
                { "iPhone8,4", "low" },
                { "iPhone8,2", "low" },
                { "iPhone8,1", "low" },
                { "iPhone7,2", "low" },
                { "iPhone7,1", "low" },
                { "iPhone6,2", "low" },
                { "iPhone6,1", "low" },
                { "iPhone5,4", "low" },
                { "iPhone5,3", "low" },
                { "iPhone5,2", "low" },
                { "iPad14,1", "ultra" },
                { "iPad14,2", "ultra" },
                { "iPad13,4", "ultra" },
                { "iPad13,5", "ultra" },
                { "iPad13,6", "ultra" },
                { "iPad13,7", "ultra" },
                { "iPad13,8", "ultra" },
                { "iPad13,9", "ultra" },
                { "iPad13,10", "ultra" },
                { "iPad13,11", "ultra" },
                { "iPad13,1", "high" },
                { "iPad13,2", "high" },
                { "iPad12,1", "high" },
                { "iPad12,2", "high" },
                { "iPad7,11", "high" },
                { "iPad7,12", "high" },
                { "iPad11,6", "high" },
                { "iPad11,7", "high" },
                { "iPad7,5", "high" },
                { "iPad7,6", "high" },
                { "iPad8,1", "high" },
                { "iPad8,2", "high" },
                { "iPad8,3", "high" },
                { "iPad8,4", "high" },
                { "iPad8,5", "high" },
                { "iPad8,6", "high" },
                { "iPad8,7", "high" },
                { "iPad8,8", "high" },
                { "iPad8,9", "high" },
                { "iPad8,10", "high" },
                { "iPad8,11", "high" },
                { "iPad8,12", "high" },
                { "iPad11,1", "high" },
                { "iPad11,2", "high" },
                { "iPad11,3", "high" },
                { "iPad11,4", "high" },
                { "iPad6,3", "medium" },
                { "iPad6,4", "medium" },
                { "iPad6,7", "medium" },
                { "iPad6,8", "medium" },
                { "iPad6,11", "medium" },
                { "iPad6,12", "medium" },
                { "iPad7,1", "medium" },
                { "iPad7,2", "medium" },
                { "iPad7,3", "medium" },
                { "iPad7,4", "medium" },
                { "iPad1,1", "low" },
                { "iPad2,1", "low" },
                { "iPad2,2", "low" },
                { "iPad2,3", "low" },
                { "iPad2,4", "low" },
                { "iPad3,1", "low" },
                { "iPad3,2", "low" },
                { "iPad3,3", "low" },
                { "iPad3,4", "low" },
                { "iPad3,5", "low" },
                { "iPad3,6", "low" },
                { "iPad4,1", "low" },
                { "iPad4,2", "low" },
                { "iPad4,3", "low" },
                { "iPad5,3", "low" },
                { "iPad5,4", "low" },
                { "iPad2,5", "low" },
                { "iPad2,6", "low" },
                { "iPad2,7", "low" },
                { "iPad4,4", "low" },
                { "iPad4,5", "low" },
                { "iPad4,6", "low" },
                { "iPad4,7", "low" },
                { "iPad4,8", "low" },
                { "iPad4,9", "low" },
                { "iPad5,1", "low" },
                { "iPad5,2", "low" },
            };
        }
    }
}
