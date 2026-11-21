// =============================================================================
//  Lapis Re:Lights 1.5.0 — Debugger.dll
//  LuaInterface.Debugger
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Diagnostics;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace LuaInterface
{
    public static class Debugger
    {
        public static bool useLog;
        public static string threadStack;
        public static ILogger logger;
        private static CString sb;

        // RVA: 0x2ED32DC
        static Debugger()
        {
            useLog = true;
            threadStack = string.Empty;
            logger = null;
            sb = new CString(0x100);

            for (int i = 0x18; i < 0x46; i++)
            {
                StringPool.PreAlloc(i, 2);
            }
        }

        // RVA: 0x2ED33C4
        private static string GetLogFormat(string str)
        {
            DateTime now = DateTime.Now;
            sb.Clear();
            sb.Append(ConstStringTable.GetTimeIntern(now.Hour));
            sb.Append(":");
            sb.Append(ConstStringTable.GetTimeIntern(now.Minute));
            sb.Append(":");
            sb.Append(ConstStringTable.GetTimeIntern(now.Second));
            sb.Append(".");
            sb.Append(now.Millisecond);
            sb.Append("-");
            sb.Append(Time.frameCount % 999);
            sb.Append(":");
            sb.Append(str);
            string result = StringPool.Alloc(sb.Length);
            sb.CopyToString(result);
            return result;
        }

        // RVA: 0x2ED367C
        public static void Log(string str)
        {
            string msg = GetLogFormat(str);
            if (useLog)
            {
                UnityEngine.Debug.Log(msg);
            }
            else if (logger != null)
            {
                logger.Log(msg, string.Empty, LogType.Log);
            }
            StringPool.Collect(msg);
        }

        // RVA: 0x2ED3834
        public static void Log(object message)
        {
            Log(message.ToString());
        }

        // RVA: 0x2ED38B8
        public static void Log(string str, object arg0)
        {
            Log(string.Format(str, arg0));
        }

        // RVA: 0x2ED3940
        public static void Log(string str, object arg0, object arg1)
        {
            Log(string.Format(str, arg0, arg1));
        }

        // RVA: 0x2ED39D0
        public static void Log(string str, object arg0, object arg1, object arg2)
        {
            Log(string.Format(str, arg0, arg1, arg2));
        }

        // RVA: 0x2ED3A70
        public static void Log(string str, object[] param)
        {
            Log(string.Format(str, param));
        }

        // RVA: 0x2ED3AF8
        public static void LogWarning(string str)
        {
            string msg = GetLogFormat(str);
            if (useLog)
            {
                UnityEngine.Debug.LogWarning(msg);
            }
            else if (logger != null)
            {
                logger.Log(msg, UnityEngine.StackTraceUtility.ExtractStackTrace(), LogType.Warning);
            }
            StringPool.Collect(msg);
        }

        // RVA: 0x2ED3CCC
        public static void LogWarning(object message)
        {
            LogWarning(message.ToString());
        }

        // RVA: 0x2ED3D50
        public static void LogWarning(string str, object arg0)
        {
            LogWarning(string.Format(str, arg0));
        }

        // RVA: 0x2ED3DD8
        public static void LogWarning(string str, object arg0, object arg1)
        {
            LogWarning(string.Format(str, arg0, arg1));
        }

        // RVA: 0x2ED3E68
        public static void LogWarning(string str, object arg0, object arg1, object arg2)
        {
            LogWarning(string.Format(str, arg0, arg1, arg2));
        }

        // RVA: 0x2ED3F08
        public static void LogWarning(string str, object[] param)
        {
            LogWarning(string.Format(str, param));
        }

        // RVA: 0x2ED3F90
        public static void LogError(string str)
        {
            string msg = GetLogFormat(str);
            if (useLog)
            {
                UnityEngine.Debug.LogError(msg);
            }
            else if (logger != null)
            {
                logger.Log(msg, UnityEngine.StackTraceUtility.ExtractStackTrace(), LogType.Error);
            }
            StringPool.Collect(msg);
        }

        // RVA: 0x2ED4164
        public static void LogError(object message)
        {
            LogError(message.ToString());
        }

        // RVA: 0x2ED41E8
        public static void LogError(string str, object arg0)
        {
            LogError(string.Format(str, arg0));
        }

        // RVA: 0x2ED4270
        public static void LogError(string str, object arg0, object arg1)
        {
            LogError(string.Format(str, arg0, arg1));
        }

        // RVA: 0x2ED4300
        public static void LogError(string str, object arg0, object arg1, object arg2)
        {
            LogError(string.Format(str, arg0, arg1, arg2));
        }

        // RVA: 0x2ED43A0
        public static void LogError(string str, object[] param)
        {
            LogError(string.Format(str, param));
        }

        // RVA: 0x2ED4428
        public static void LogException(Exception e)
        {
            threadStack = e.StackTrace;
            string msg = GetLogFormat(e.Message);
            if (useLog)
            {
                UnityEngine.Debug.LogError(msg);
            }
            else if (logger != null)
            {
                logger.Log(msg, threadStack, LogType.Exception);
            }
            StringPool.Collect(msg);
        }

        // RVA: 0x2ED4604
        public static void LogException(string str, Exception e)
        {
            threadStack = e.StackTrace;
            LogError(str + e.Message);
        }
    }
}
