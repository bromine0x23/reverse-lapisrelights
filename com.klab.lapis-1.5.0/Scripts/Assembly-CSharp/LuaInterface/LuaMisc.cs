// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaMisc
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
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
    public static class LuaMisc
    {

        // RVA: 0x229B814
        public static string GetArrayRank(Type t)
        {
                        int count = t.GetArrayRank();

                        if (count == 1)
                        {                
                            return "[]";
                        }

                        using (CString.Block())
                        {
                            CString sb = CString.Alloc(64);
                            sb.Append('[');

                            for (int i = 1; i < count; i++)
                            {
                                sb.Append(',');
                            }

                            sb.Append(']');
                            return sb.ToString();
                        }
        }

        // RVA: 0x229BA0C
        public static string GetTypeName(Type t)
        {
                        if (t.IsArray)
                        {
                            string str = GetTypeName(t.GetElementType());
                            str += GetArrayRank(t);
                            return str;                
                        }
                        else if (t.IsByRef)
                        {
                            t = t.GetElementType();
                            return GetTypeName(t);
                        }
                        else if (t.IsGenericType)
                        {
                            return GetGenericName(t);
                        }
                        else if (t == typeof(void))
                        {
                            return "void";
                        }
                        else
                        {
                            string name = GetPrimitiveStr(t);
                            return name.Replace('+', '.');
                        }
        }

        // RVA: 0x229C38C
        public static string[] GetGenericName(Type[] types, int offset, int count)
        {
                        string[] results = new string[count];

                        for (int i = 0; i < count; i++)
                        {
                            int pos = i + offset;

                            if (types[pos].IsGenericType)
                            {
                                results[i] = GetGenericName(types[pos]);
                            }
                            else
                            {
                                results[i] = GetTypeName(types[pos]);
                            }

                        }

                        return results;
        }

        // RVA: 0x229C4E4
        private static string CombineTypeStr(string space, string name)
        {
                        if (string.IsNullOrEmpty(space))
                        {
                            return name;
                        }
                        else
                        {
                            return space + "." + name;
                        }
        }

        // RVA: 0x229BB84
        private static string GetGenericName(Type t)
        {
                        Type[] gArgs = t.GetGenericArguments();
                        string typeName = t.FullName ?? t.Name;
                        int count = gArgs.Length;
                        int pos = typeName.IndexOf("[");

                        if (pos > 0)
                        {
                            typeName = typeName.Substring(0, pos);
                        }

                        string str = null;
                        string name = null;
                        int offset = 0;
                        pos = typeName.IndexOf("+");

                        while (pos > 0)
                        {
                            str = typeName.Substring(0, pos);
                            typeName = typeName.Substring(pos + 1);
                            pos = str.IndexOf('`');

                            if (pos > 0)
                            {
                                count = (int)(str[pos + 1] - '0');
                                str = str.Substring(0, pos);
                                str += "<" + string.Join(",", GetGenericName(gArgs, offset, count)) + ">";
                                offset += count;
                            }

                            name = CombineTypeStr(name, str);
                            pos = typeName.IndexOf("+");
                        }

                        str = typeName;

                        if (offset < gArgs.Length)
                        {
                            pos = str.IndexOf('`');
                            count = (int)(str[pos + 1] - '0');
                            str = str.Substring(0, pos);
                            str += "<" + string.Join(",", GetGenericName(gArgs, offset, count)) + ">";
                        }

                        return CombineTypeStr(name, str);
        }

        // RVA: 0x229C56C
        public static Delegate GetEventHandler(object obj, Type t, string eventName)
        {
                        FieldInfo eventField = t.GetField(eventName, BindingFlags.GetField | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static);
                        return (Delegate)eventField.GetValue(obj);
        }

        // RVA: 0x229BE68
        public static string GetPrimitiveStr(Type t)
        {
                        if (t == typeof(System.Single))
                        {
                            return "float";
                        }
                        else if (t == typeof(System.String))
                        {
                            return "string";
                        }
                        else if (t == typeof(System.Int32))
                        {
                            return "int";
                        }
                        else if (t == typeof(System.Double))
                        {
                            return "double";
                        }
                        else if (t == typeof(System.Boolean))
                        {
                            return "bool";
                        }
                        else if (t == typeof(System.UInt32))
                        {
                            return "uint";
                        }
                        else if (t == typeof(System.SByte))
                        {
                            return "sbyte";
                        }
                        else if (t == typeof(System.Byte))
                        {
                            return "byte";
                        }
                        else if (t == typeof(System.Int16))
                        {
                            return "short";
                        }
                        else if (t == typeof(System.UInt16))
                        {
                            return "ushort";
                        }
                        else if (t == typeof(System.Char))
                        {
                            return "char";
                        }
                        else if (t == typeof(System.Int64))
                        {
                            return "long";
                        }
                        else if (t == typeof(System.UInt64))
                        {
                            return "ulong";
                        }
                        else if (t == typeof(System.Decimal))
                        {
                            return "decimal";
                        }
                        else if (t == typeof(System.Object))
                        {
                            return "object";
                        }
                        else
                        {
                            return t.ToString();
                        }
        }

        // RVA: 0x229C634
        public static double ToDouble(object obj)
        {
                        Type t = obj.GetType();

                        if (t == typeof(double) || t == typeof(float))
                        {
                            double d = Convert.ToDouble(obj);
                            return d;
                        }
                        else if (t == typeof(int))
                        {
                            int n = Convert.ToInt32(obj);
                            return (double)n;
                        }
                        else if (t == typeof(uint))
                        {
                            uint n = Convert.ToUInt32(obj);
                            return (double)n;
                        }
                        else if (t == typeof(long))
                        {
                            long n = Convert.ToInt64(obj);
                            return (double)n;
                        }
                        else if (t == typeof(ulong))
                        {
                            ulong n = Convert.ToUInt64(obj);
                            return (double)n;
                        }
                        else if (t == typeof(byte))
                        {
                            byte b = Convert.ToByte(obj);
                            return (double)b;
                        }
                        else if (t == typeof(sbyte))
                        {
                            sbyte b = Convert.ToSByte(obj);
                            return (double)b;
                        }
                        else if (t == typeof(char))
                        {
                            char c = Convert.ToChar(obj);
                            return (double)c;
                        }            
                        else if (t == typeof(short))
                        {
                            Int16 n = Convert.ToInt16(obj);
                            return (double)n;
                        }
                        else if (t == typeof(ushort))
                        {
                            UInt16 n = Convert.ToUInt16(obj);
                            return (double)n;
                        }

                        return 0;
        }

        // RVA: 0x229CB9C
        public static Type GetExportBaseType(Type t)
        {
                        Type baseType = t.BaseType;

                        if (baseType == typeof(ValueType))
                        {
                            return null;
                        }

                        if (t.IsAbstract && t.IsSealed)
                        {
                            return baseType == typeof(object) ? null : baseType;
                        }

                        return baseType;
        }
    }
}
