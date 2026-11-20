// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.LogUtility
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//
//  对 UnityEngine.Debug 的转发封装；LogAssertion* 在二进制中为空实现。
// =============================================================================

using System;
using UnityEngine;

namespace Oz.GameFramework.Runtime
{
    /// <summary>统一日志入口。</summary>
    public static class LogUtility
    {
        // RVA: 0x2E92774
        public static void Log(object message)
        {
            Debug.Log(message);
        }

        // RVA: 0x2E927DC
        public static void Log(object message, Object context)
        {
            Debug.Log(message, context);
        }

        // RVA: 0x2E92854
        public static void LogFormat(LogType logType, LogOption logOptions, Object context, string format, object[] args)
        {
            Debug.LogFormat(logType, logOptions, context, format, args);
        }

        // RVA: 0x2E928EC
        public static void LogFormat(Object context, string format, object[] args)
        {
            Debug.LogFormat(context, format, args);
        }

        // RVA: 0x2E9296C
        public static void LogFormat(string format, object[] args)
        {
            Debug.LogFormat(format, args);
        }

        // RVA: 0x2E929E4
        public static void LogWarning(object message)
        {
            Debug.LogWarning(message);
        }

        // RVA: 0x2E92A4C
        public static void LogWarning(object message, Object context)
        {
            Debug.LogWarning(message, context);
        }

        // RVA: 0x2E92AC4
        public static void LogWarningFormat(string format, object[] args)
        {
            Debug.LogWarningFormat(format, args);
        }

        // RVA: 0x2E92B3C
        public static void LogWarningFormat(Object context, string format, object[] args)
        {
            Debug.LogWarningFormat(context, format, args);
        }

        // RVA: 0x2E92BBC
        public static void LogException(Exception exception)
        {
            Debug.LogException(exception);
        }

        // RVA: 0x2E92C24
        public static void LogException(Exception exception, Object context)
        {
            Debug.LogException(exception, context);
        }

        // RVA: 0x2E92C9C
        public static void LogError(object message)
        {
            Debug.LogError(message);
        }

        // RVA: 0x2E92D04
        public static void LogError(object message, Object context)
        {
            Debug.LogError(message, context);
        }

        // RVA: 0x2E92D7C
        public static void LogErrorFormat(string format, object[] args)
        {
            Debug.LogErrorFormat(format, args);
        }

        // RVA: 0x2E92DF4
        public static void LogErrorFormat(Object context, string format, object[] args)
        {
            Debug.LogErrorFormat(context, format, args);
        }

        // RVA: 0x2E92E74（空实现）
        public static void LogAssertion(object message, Object context)
        {
        }

        // RVA: 0x2E92E78（空实现）
        public static void LogAssertion(object message)
        {
        }

        // RVA: 0x2E92E7C（空实现）
        public static void LogAssertionFormat(Object context, string format, object[] args)
        {
        }

        // RVA: 0x2E92E80（空实现）
        public static void LogAssertionFormat(string format, object[] args)
        {
        }
    }
}
