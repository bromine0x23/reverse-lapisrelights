// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.TransformExtentions
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;
using System.Collections.Generic;
using UnityEngine;

namespace Oz.GameFramework.Runtime
{
    /// <summary>Transform 层级查找扩展。</summary>
    public static class TransformExtentions
    {
        /// <summary>递归把所有子孙节点按名字写入字典。</summary>
        // RVA: 0x2E93880
        public static void RecursiveFindChildrenPath(Transform parent, Dictionary<string, Transform> children)
        {
            for (int i = 0; i < parent.childCount; i++)
            {
                Transform child = parent.GetChild(i);
                children.Add(child.name, child);
                RecursiveFindChildrenPath(child, children);
            }
        }

        // RVA: 0x2E93958
        public static Transform RecursiveFind(Transform transform, Predicate<Transform> match)
        {
            return FindChild(transform, match);
        }

        /// <summary>深度优先查找第一个匹配节点（含自身）。</summary>
        // RVA: 0x2E9395C
        private static Transform FindChild(Transform transform, Predicate<Transform> match)
        {
            if (match(transform))
            {
                return transform;
            }
            for (int i = 0; i < transform.childCount; i++)
            {
                Transform found = FindChild(transform.GetChild(i), match);
                if (found != null)
                {
                    return found;
                }
            }
            return null;
        }

        /// <summary>广度优先（GetComponentsInChildren）查找第一个匹配节点。</summary>
        // RVA: 0x2E93A6C
        public static Transform IterativeFind(Transform transform, Predicate<Transform> match)
        {
            Transform[] all = transform.GetComponentsInChildren<Transform>();
            for (int i = 0; i < all.Length; i++)
            {
                if (match(all[i]))
                {
                    return all[i];
                }
            }
            return null;
        }

        // RVA: 0x2E93B4C
        public static Transform[] RecusiveFindAll(Transform transform, Predicate<Transform> match)
        {
            List<Transform> list = new List<Transform>();
            FindChildren(transform, match, list);
            return list.ToArray();
        }

        /// <summary>递归收集所有匹配节点（含自身）。</summary>
        // RVA: 0x2E93BE4
        private static void FindChildren(Transform transform, Predicate<Transform> match, List<Transform> list)
        {
            if (match(transform))
            {
                list.Add(transform);
            }
            foreach (Transform child in transform)
            {
                FindChildren(child, match, list);
            }
        }

        // RVA: 0x2E93E70
        public static Transform[] IterativeFindAll(Transform transform, Predicate<Transform> match)
        {
            List<Transform> list = new List<Transform>();
            Transform[] all = transform.GetComponentsInChildren<Transform>();
            for (int i = 0; i < all.Length; i++)
            {
                if (match(all[i]))
                {
                    list.Add(all[i]);
                }
            }
            return list.ToArray();
        }

        /// <summary>是否已挂载组件 T（共享泛型 RVA 0x26B292C：transform.TryGetComponent&lt;T&gt;(out _)）。</summary>
        public static bool HasComponent<T>(Transform transform)
        {
            return transform.TryGetComponent<T>(out _);
        }
    }
}
