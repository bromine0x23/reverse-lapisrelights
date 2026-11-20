// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.GameObjectExtentions
//  来源：Il2CppDumper 元数据（泛型方法无独立 RVA）
// =============================================================================

using UnityEngine;

namespace Oz.GameFramework.Runtime
{
    /// <summary>GameObject 组件便捷扩展。</summary>
    public static class GameObjectExtentions
    {
        /// <summary>是否已挂载组件 T（共享泛型 RVA 0x26B28F0：gameObject.TryGetComponent&lt;T&gt;(out _)）。</summary>
        public static bool HasComponent<T>(GameObject gameObject)
        {
            return gameObject.TryGetComponent<T>(out _);
        }

        /// <summary>取得组件 T，缺失时添加后返回（共享泛型 RVA 0x154454C：先 TryGetComponent，失败再 AddComponent）。</summary>
        public static T AddMissingComponent<T>(GameObject gameObject)
        {
            if (gameObject.TryGetComponent<T>(out T component))
            {
                return component;
            }

            return gameObject.AddComponent<T>();
        }
    }
}
