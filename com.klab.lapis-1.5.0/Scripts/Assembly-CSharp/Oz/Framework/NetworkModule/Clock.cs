// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.NetworkModule.Clock
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;
using UnityEngine;

namespace Oz.Framework.NetworkModule
{
    /// <summary>
    /// 服务器时钟：由服务器时间戳与本地 realtimeSinceStartup 维护偏移，
    /// 并保证对外时间戳单调（lowerLimit）。
    /// </summary>
    public static class Clock
    {
        private static double? delta;
        private static long? lowerLimit;

        /// <summary>服务器毫秒时间戳（单调递增）。未同步时返回 null。</summary>
        public static long? MilliTimestamp
        {
            // RVA: 0x1404CE0
            get
            {
                if (delta.HasValue && lowerLimit.HasValue)
                {
                    long limit = lowerLimit.Value;
                    double value = delta.Value;
                    long? timestamp = Math.Max(limit, (long)((value + Time.realtimeSinceStartup) * 1000.0));
                    lowerLimit = timestamp;
                    return timestamp;
                }
                return null;
            }
        }

        /// <summary>服务器秒时间戳。未同步时返回 null。</summary>
        public static long? Timestamp
        {
            // RVA: 0x1404E08
            get
            {
                long? milli = MilliTimestamp;
                if (milli.HasValue)
                {
                    return milli.Value / 1000;
                }
                return null;
            }
        }

        /// <summary>本地时区相对 UTC 的偏移（秒），按固定日期 2017-01-01 计算。</summary>
        public static int TimeDifference
        {
            // RVA: 0x1404E98
            get
            {
                TimeSpan offset = new DateTimeOffset(new DateTime(2017, 1, 1, 0, 0, 0, DateTimeKind.Local)).Offset;
                return offset.Hours * 3600 + offset.Minutes * 60 + offset.Seconds;
            }
        }

        /// <summary>当前本地时区偏移（秒）。</summary>
        public static int LocalTimeDifference
        {
            // RVA: 0x1404F54
            get
            {
                TimeSpan offset = DateTimeOffset.Now.Offset;
                return offset.Hours * 3600 + offset.Minutes * 60 + offset.Seconds;
            }
        }

        /// <summary>
        /// 用服务器响应时间戳与本地发送时刻校正偏移：
        /// 首次直接取 responseTimestamp/1000 - now；此后仅在结果偏离
        /// [sentTime, now] 区间时才重新校正（抑制网络抖动）。
        /// </summary>
        // RVA: 0x140501C
        public static void SetServerTime(long responseTimestamp, float sentTime)
        {
            float now = Time.realtimeSinceStartup;

            long limit = responseTimestamp;
            if (lowerLimit.HasValue)
            {
                limit = Math.Max(lowerLimit.Value, responseTimestamp);
            }
            lowerLimit = limit + 1;

            if (!delta.HasValue)
            {
                delta = responseTimestamp * 0.001 - now;
                return;
            }

            double expected = responseTimestamp * 0.001 - delta.Value;
            if (expected < sentTime)
            {
                delta = responseTimestamp * 0.001 - sentTime;
            }
            else if (expected > now)
            {
                delta = responseTimestamp * 0.001 - now;
            }
        }
    }
}
