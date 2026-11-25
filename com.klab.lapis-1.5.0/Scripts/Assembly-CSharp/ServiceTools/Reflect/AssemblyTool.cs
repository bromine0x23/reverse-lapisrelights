// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  AssemblyTool
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  程序集/类型缓存与按名称、特性、继承关系查找类型。
// =============================================================================

using System;
using System.Collections.Generic;
using System.Reflection;

namespace ServiceTools.Reflect
{
    public static class AssemblyTool
    {
        // RVA: 0x17D38CC
        public static HashSet<Assembly> Assemblys = new HashSet<Assembly>();
        public static Dictionary<string, Type> TypeFullName = new Dictionary<string, Type>();

        // RVA: 0x17D31B0
        public static void RefreshCache()
        {
            Assemblys.Clear();
            TypeFullName.Clear();

            foreach (Assembly assembly in AppDomain.CurrentDomain.GetAssemblies())
            {
                Assemblys.Add(assembly);

                foreach (Type type in assembly.GetTypes())
                {
                    TypeFullName[type.FullName] = type;
                }
            }
        }

        // RVA: 0x17D33B0
        public static void ForeachCurrentDomainType(Action<Type> execute)
        {
            if (Assemblys.Count == 0)
            {
                RefreshCache();
            }

            foreach (Type type in TypeFullName.Values)
            {
                execute(type);
            }
        }

        // RVA: 0x17D3534
        public static List<Type> FindTypesInCurrentDomainWhere(Func<Type, bool> condition)
        {
            if (Assemblys.Count == 0)
            {
                RefreshCache();
            }

            List<Type> list = new List<Type>();

            foreach (Type type in TypeFullName.Values)
            {
                if (condition(type))
                {
                    list.Add(type);
                }
            }

            return list;
        }

        // RVA: 0x17D3718
        public static Type FindTypesInCurrentDomainByName(string ClassName)
        {
            List<Type> list = FindTypesInCurrentDomainWhere(e => e.Name == ClassName);
            if (list.Count > 0)
            {
                return list[0];
            }

            return null;
        }

        // RVA: 0x19FECE8
        public static List<Type> FindTypesInCurrentDomainWhereAttributeIs<T>()
        {
            Type withType = typeof(T);
            return FindTypesInCurrentDomainWhere(
                type => type.GetCustomAttributes(withType, true).Length != 0);
        }

        // RVA: 0x19FEDFC
        public static List<Type> FindTypesInCurrentDomainWhereExtend<T>()
        {
            return FindTypesInCurrentDomainWhere(
                type => typeof(T).IsAssignableFrom(type)
                    && !type.IsInterface
                    && !type.IsAbstract);
        }

        // RVA: 0x17D3804
        public static List<Type> FindTypesInCurrentDomainWhereExtend(Type withType)
        {
            return FindTypesInCurrentDomainWhere(
                type => withType.IsAssignableFrom(type)
                    && !type.IsInterface
                    && !type.IsAbstract);
        }
    }
}
