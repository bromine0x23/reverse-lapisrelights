// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.TrackAssetExtensions
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        GetBindingGameObject: director.GetGenericBinding(trackAsset)，
//        GameObject 直接返回，Component 返回其 gameObject，否则 null
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    public static class TrackAssetExtensions
    {
        // RVA: 0x13DCE2C
        [Extension]
        public static GameObject GetBindingGameObject(TrackAsset trackAsset, PlayableDirector director)
        {
            if (director == null)
            {
                return null;
            }

            Object binding = director.GetGenericBinding(trackAsset);

            GameObject go = binding as GameObject;
            if (go != null)
            {
                return go;
            }

            Component component = binding as Component;
            if (component != null)
            {
                return component.gameObject;
            }

            return null;
        }

        // RVA: 0x15445B8（泛型共享，实例：Actor / ExpressionAnimator / object）
        [Extension]
        public static T GetBindingComponent<T>(TrackAsset trackAsset, PlayableDirector director)
        {
            if (director == null)
            {
                return default;
            }

            Object binding = director.GetGenericBinding(trackAsset);
            if (binding is T result)
            {
                return result;
            }

            if (binding is Component component)
            {
                return component.GetComponent<T>();
            }

            return default;
        }

        // RVA: 0x1544770（泛型共享，实例：IMaterialPropertyBlockModifier / object）
        [Extension]
        public static T GetBindingInterface<T>(TrackAsset trackAsset, PlayableDirector director)
        {
            if (director == null)
            {
                return default;
            }

            Object binding = director.GetGenericBinding(trackAsset);
            if (binding is T result)
            {
                return result;
            }

            if (binding is Component component)
            {
                Component[] components = component.gameObject.GetComponents(typeof(T));
                for (int i = 0; i < components.Length; i++)
                {
                    if (components[i] is T found)
                    {
                        return found;
                    }
                }
            }

            return default;
        }
    }
}
