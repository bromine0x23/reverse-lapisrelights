// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaException
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Text;
using System.Diagnostics;
using System.Reflection;
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
    public class LuaException : Exception
    {
        public static Exception luaStack;
        public static string projectFolder;
        public static int InstantiateCount;
        public static int SendMsgCount;
        public static IntPtr L;
        protected string _stack;
        public override string StackTrace { get; }

        // RVA: 0x229349C
        public string get_StackTrace()
        {
            return _stack;
        }

        // RVA: 0x228AFE4
        public LuaException(string msg, Exception e, int skip = 1)
        {
                        if (e != null)
                        {
                            if (e is LuaException)
                            {
                                _stack = e.StackTrace;
                            }
                            else
                            {                                        
                                StackTrace trace = new StackTrace(e, true);
                                StringBuilder sb = new StringBuilder();
                                ExtractFormattedStackTrace(trace, sb);                    
                                StackTrace self = new StackTrace(skip, true);
                                ExtractFormattedStackTrace(self, sb, trace);
                                _stack = sb.ToString();                    
                            }
                        }
                        else
                        {
                            StackTrace self = new StackTrace(skip, true);
                            StringBuilder sb = new StringBuilder();
                            ExtractFormattedStackTrace(self, sb);
                            _stack = sb.ToString();
                        }                        
        }

        // RVA: 0x2293AF8
        public static Exception GetLastError()
        {
                        Exception last = luaStack;
                        luaStack = null;
                        return last;
        }

        // RVA: 0x22934A4
        public static void ExtractFormattedStackTrace(StackTrace trace, StringBuilder sb, StackTrace skip)
        {
                        int begin = 0;

                        if (skip != null && skip.FrameCount > 0)
                        {
                            MethodBase m0 = skip.GetFrame(skip.FrameCount - 1).GetMethod();

                            for (int i = 0; i < trace.FrameCount; i++)
                            {
                                StackFrame frame = trace.GetFrame(i);
                                MethodBase method = frame.GetMethod();

                                if (method == m0)
                                {
                                    begin = i + 1;
                                    break;
                                }                    
                            }

                            sb.AppendLineEx();
                        }

                        for (int i = begin; i < trace.FrameCount; i++)
                        {
                            StackFrame frame = trace.GetFrame(i);
                            MethodBase method = frame.GetMethod();

                            if (method == null || method.DeclaringType == null)
                            {
                                continue;
                            }                               

                            Type declaringType = method.DeclaringType;
                            string str = declaringType.Namespace;

                            if ( (InstantiateCount == 0 && declaringType == typeof(UnityEngine.Object) &&  method.Name == "Instantiate") //(method.Name == "Internal_CloneSingle"
                                || (SendMsgCount == 0 && declaringType == typeof(GameObject) && method.Name == "SendMessage"))
                            {
                                break;
                            }

                            if ((str != null) && (str.Length != 0))
                            {
                                sb.Append(str);
                                sb.Append(".");
                            }

                            sb.Append(declaringType.Name);
                            sb.Append(":");
                            sb.Append(method.Name);
                            sb.Append("(");
                            int index = 0;
                            ParameterInfo[] parameters = method.GetParameters();
                            bool flag = true;

                            while (index < parameters.Length)
                            {
                                if (!flag)
                                {
                                    sb.Append(", ");
                                }
                                else
                                {
                                    flag = false;
                                }

                                sb.Append(parameters[index].ParameterType.Name);
                                index++;
                            }

                            sb.Append(")");
                            string fileName = frame.GetFileName();                

                            if (fileName != null)
                            {
                                fileName = fileName.Replace('\\', '/');
                                sb.Append(" (at ");

                                if (fileName.StartsWith(projectFolder))
                                {
                                    fileName = fileName.Substring(projectFolder.Length, fileName.Length - projectFolder.Length);
                                }

                                sb.Append(fileName);
                                sb.Append(":");
                                sb.Append(frame.GetFileLineNumber().ToString());
                                sb.Append(")");
                            }

                            if (i != trace.FrameCount - 1)
                            {
                                sb.Append("\n");
                            }
                        }
        }

        // RVA: 0x2293B64
        public static void Init(IntPtr L0)
        {
                        L = L0;
                        Type type = typeof(StackTraceUtility);
                        FieldInfo field = type.GetField("projectFolder", BindingFlags.Static | BindingFlags.GetField | BindingFlags.NonPublic);
                        LuaException.projectFolder = (string)field.GetValue(null);
                        projectFolder = projectFolder.Replace('\\', '/');
            #if DEVELOPER
                        Debugger.Log("projectFolder is {0}", projectFolder);
            #endif
        }

        // RVA: 0x2293C9C
        static LuaException()
        {
            luaStack = null;
            projectFolder = null;
            InstantiateCount = 0;
            SendMsgCount = 0;
            L = IntPtr.Zero;
        }
    }
}
