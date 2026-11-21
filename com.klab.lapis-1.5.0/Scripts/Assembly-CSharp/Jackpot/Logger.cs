// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Logger
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
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
    public class Logger : ILogger
    {
        private const string NullStringMessage = "(Null string)";
        private const string EmptyStringMessage = "(Empty string)";
        private const string NullObjectMessage = "(Null object)";
        private static readonly Dictionary<string, ILogger> loggers;
        private static readonly List<ILoggerHandler> handlers;
        private static LogLevel logLevel;
        private static Action bootStrap;
        private string callerName;

        public static ILogger Get<T>()
        {
            return Get(typeof(T));
        }

        // RVA: 0x19F4584
        public static ILogger Get(Type type)
        {
                        return Get(type.FullName);
        }

        // RVA: 0x19E9838
        public static ILogger Get(string callerName = "Default")
        {
                        if (string.IsNullOrEmpty(callerName))
                        {
                            callerName = "Default";
                        }

                        if (!loggers.ContainsKey(callerName) || loggers[callerName] == null)
                        {
                            Logger logger = new Logger();
                            logger.callerName = callerName;
                            loggers[callerName] = logger;
                        }

                        return loggers[callerName];
        }

        // RVA: 0x19E2378
        public static void AddHandler(ILoggerHandler handler)
        {
                        if (bootStrap != null)
                        {
                            bootStrap();
                        }

                        if (!handlers.Contains(handler))
                        {
                            handlers.Add(handler);
                        }
        }

        // RVA: 0x19F4638
        public static bool ContainsHandler(ILoggerHandler handler)
        {
                        if (bootStrap != null)
                        {
                            bootStrap();
                        }

                        return handlers.Contains(handler);
        }

        // RVA: 0x19F4714
        public static void RemoveHandler(ILoggerHandler handler)
        {
                        if (bootStrap != null)
                        {
                            bootStrap();
                        }

                        if (handlers.Contains(handler))
                        {
                            handlers.Remove(handler);
                        }
        }

        // RVA: 0x19F483C
        public static void RemoveAllHandlers()
        {
                        if (bootStrap != null)
                        {
                            bootStrap();
                        }

                        handlers.Clear();
        }

        // RVA: 0x19F4910
        public static void SetLogLevel(LogLevel level)
        {
                        if (bootStrap != null)
                        {
                            bootStrap();
                        }

                        logLevel = level;
        }

        // RVA: 0x19F49D8
        public void Debug(string message)
        {
                        Log(LogLevel.Debug, callerName, FormatMessage(message));
        }

        // RVA: 0x19F4CE4
        public void Debug(object obj, object[] moreObjects)
        {
                        Log(LogLevel.Debug, callerName, FormatObjects(obj, moreObjects));
        }

        // RVA: 0x19F4EAC
        public void Info(string message)
        {
                        Log(LogLevel.Info, callerName, FormatMessage(message));
        }

        // RVA: 0x19F4ED8
        public void Info(object obj, object[] moreObjects)
        {
                        Log(LogLevel.Info, callerName, FormatObjects(obj, moreObjects));
        }

        // RVA: 0x19F4F04
        public void Warn(string message)
        {
                        Log(LogLevel.Warn, callerName, FormatMessage(message));
        }

        // RVA: 0x19F4F30
        public void Warn(object obj, object[] moreObjects)
        {
                        Log(LogLevel.Warn, callerName, FormatObjects(obj, moreObjects));
        }

        // RVA: 0x19F4F5C
        public void Error(string message)
        {
                        Log(LogLevel.Error, callerName, FormatMessage(message));
        }

        // RVA: 0x19F4F88
        public void Error(object obj, object[] moreObjects)
        {
                        Log(LogLevel.Error, callerName, FormatObjects(obj, moreObjects));
        }

        // RVA: 0x19F4FB4
        public void Fatal(string message)
        {
                        Log(LogLevel.Fatal, callerName, FormatMessage(message));
        }

        // RVA: 0x19F4FE0
        public void Fatal(object obj, object[] moreObjects)
        {
                        Log(LogLevel.Fatal, callerName, FormatObjects(obj, moreObjects));
        }

        // RVA: 0x19F460C
        private Logger(string callerName)
        {
        }

        // RVA: 0x19F4A8C
        private void Log(LogLevel level, string callerName, string message)
        {
                        if (bootStrap != null)
                        {
                            BootStrap();
                        }

                        if (handlers.Count == 0 || logLevel < level)
                        {
                            return;
                        }

                        LoggerReport report = new LoggerReport(level, callerName, message);
                        foreach (ILoggerHandler handler in handlers)
                        {
                            handler.HandleLog(report);
                        }
        }

        // RVA: 0x19F4A04
        private string FormatMessage(string message)
        {
                        if (message == null)
                        {
                            return "(Null string)";
                        }

                        if (message == string.Empty)
                        {
                            return "(Empty string)";
                        }

                        return message;
        }

        // RVA: 0x19F5150
        private string FormatObject(object obj)
        {
                        if (obj == null)
                        {
                            return "(Null object)";
                        }

                        if (obj is string)
                        {
                            return FormatMessage((string)obj);
                        }

                        return obj.ToString();
        }

        // RVA: 0x19F4D10
        private string FormatObjects(object obj, object[] moreObjects)
        {
                        if (moreObjects == null || moreObjects.Length == 0)
                        {
                            return FormatObject(obj);
                        }

                        if (obj is string && ((string)obj).Contains("{0}"))
                        {
                            return string.Format((string)obj, moreObjects);
                        }

                        StringBuilder stringBuilder = new StringBuilder();
                        stringBuilder.Append(FormatObject(obj));
                        for (int i = 0; i < moreObjects.Length; i++)
                        {
                            stringBuilder.Append(",");
                            stringBuilder.Append(FormatObject(moreObjects[i]));
                        }

                        return stringBuilder.ToString();
        }

        // RVA: 0x19F500C
        public static void BootStrap()
        {
                        if (bootStrap != null)
                        {
                            bootStrap();
                        }
        }

        // RVA: 0x19F51DC
        private static void BootStrapCore()
        {
                        bootStrap = null;
                        logLevel = (Debug.isDebugBuild ? LogLevel.All : LogLevel.Fatal);
                        DebugLogHandler.Initialize();
        }

        // RVA: 0x19F52A4
        static Logger()
        {
                        loggers = new Dictionary<string, ILogger>();
                        handlers = new List<ILoggerHandler>();
                        logLevel = LogLevel.All;
                        bootStrap = BootStrapCore;
        }
    }
}
