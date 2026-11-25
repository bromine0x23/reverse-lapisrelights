// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  GameObjectUtilities
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  GameObject/Transform 常用工具：包围盒、层级遍历、克隆、清空子节点、
//  按名称/递归查找、图层设置与场景对象收集。
// =============================================================================

using System;
using System.Collections.Generic;
using Oz.Framework;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace SeanLib.Core
{
    public static class GameObjectUtilities
    {
        // RVA: 0x194EF54
        public static Bounds GetBoundsWithChildren(GameObject obj)
        {
            Renderer[] componentsInChildren = obj.GetComponentsInChildren<Renderer>();
            if (componentsInChildren.Length == 0)
            {
                throw new Exception("no child in this gameobject");
            }

            Bounds bounds = componentsInChildren[0].bounds;
            Vector3 min = bounds.min;
            Vector3 max = bounds.max;

            for (int i = 1; i < componentsInChildren.Length; i++)
            {
                Bounds rendererBounds = componentsInChildren[i].bounds;
                min = Vector3.Min(min, rendererBounds.min);
                max = Vector3.Max(max, rendererBounds.max);
            }

            return new Bounds((min + max) / 2f, max - min);
        }

        // RVA: 0x194F418
        public static bool IsActive(GameObject obj)
        {
            return obj && obj.activeInHierarchy;
        }

        // RVA: 0x194F4A8
        public static GameObject Parent(GameObject obj)
        {
            if (obj == null)
            {
                return null;
            }

            Transform parent = obj.transform.parent;
            if (parent == null)
            {
                return null;
            }

            return parent.gameObject;
        }

        // RVA: 0x194F5A0
        public static void ClearChildrenImmediate(GameObject parent)
        {
            List<GameObject> list = new List<GameObject>();

            foreach (Transform child in parent.transform)
            {
                list.Add(child.gameObject);
            }

            foreach (GameObject item in list)
            {
                UnityEngine.Object.DestroyImmediate(item);
            }
        }

        // RVA: 0x194F95C
        public static void ClearChildren(GameObject parent)
        {
            List<GameObject> list = new List<GameObject>();

            foreach (Transform child in parent.transform)
            {
                list.Add(child.gameObject);
            }

            foreach (GameObject item in list)
            {
                UnityEngine.Object.Destroy(item);
            }
        }

        // RVA: 0x194FD18
        public static GameObject AddEmptyGameObject(GameObject parent)
        {
            GameObject gameObject = new GameObject();
            gameObject.transform.SetParent(parent.transform);
            gameObject.transform.localPosition = Vector3.zero;
            gameObject.transform.localScale = Vector3.one;
            gameObject.transform.localRotation = Quaternion.identity;
            return gameObject;
        }

        // RVA: 0x194FE7C
        public static GameObject AddInstantiate(GameObject parent, GameObject src)
        {
            return AddInstantiate(
                parent,
                src,
                Vector3.zero,
                Vector3.one,
                Quaternion.identity);
        }

        // RVA: 0x194FF88
        public static GameObject AddInstantiate(
            GameObject parent,
            GameObject src,
            Vector3 position,
            Vector3 scale,
            Quaternion quaternion,
            bool withParentLayer = true)
        {
            GameObject gameObject = UnityEngine.Object.Instantiate(src);
            gameObject.transform.SetParent(parent.transform);
            gameObject.transform.localPosition = position;
            gameObject.transform.localScale = scale;
            gameObject.transform.localRotation = quaternion;

            if (withParentLayer)
            {
                SetLayerWidthChildren(gameObject, parent.layer);
            }

            return gameObject;
        }

        // RVA: 0x1950100
        public static void SetLayerWidthChildren(GameObject parent, int layer)
        {
            foreach (Transform item in parent.GetComponentsInChildren<Transform>())
            {
                item.gameObject.layer = layer;
            }
        }

        // RVA: 0x19501C8
        public static List<GameObject> GetChildren(GameObject parent)
        {
            List<GameObject> list = new List<GameObject>();

            foreach (Transform child in parent.transform)
            {
                list.Add(child.gameObject);
            }

            return list;
        }

        // RVA: 0x195046C
        public static GameObject GetChildByName(GameObject parent, string name)
        {
            foreach (Transform child in parent.transform)
            {
                if (child.gameObject.name == name)
                {
                    return child.gameObject;
                }
            }

            return null;
        }

        // RVA: 0x1950760
        public static GameObject GetParentByName(GameObject child, string name)
        {
            while (child.name != name)
            {
                Transform parent = child.transform.parent;
                if (parent == null)
                {
                    return null;
                }

                child = parent.gameObject;
            }

            return child;
        }

        // RVA: 0x1950870
        public static bool IsChildBy(GameObject child, GameObject parent)
        {
            foreach (Transform item in parent.GetComponentsInChildren<Transform>())
            {
                if (item.gameObject == child)
                {
                    return true;
                }
            }

            return false;
        }

        // RVA: 0x1950978
        public static Transform GetChildByNameRecursion(Transform parent, string name)
        {
            Transform transform = parent.transform.Find(name);
            if (transform != null)
            {
                return transform;
            }

            for (int i = 0; i < parent.transform.childCount; i++)
            {
                Transform result = GetChildByNameRecursion(parent.transform.GetChild(i), name);
                if (result != null)
                {
                    return result;
                }
            }

            return null;
        }

        // RVA: 0x1950AC4
        public static void ForEach(Transform root, Action<Transform> childAction)
        {
            foreach (Transform child in root)
            {
                childAction(child);
            }
        }

        // RVA: 0x1950D2C
        public static void SetLayerToCameraCullingMask(GameObject obj, Camera camera)
        {
            int cullingMask = camera.cullingMask;
            if (cullingMask == 0)
            {
                return;
            }

            int layer = obj.layer;
            if ((cullingMask & (1 << layer)) != 0)
            {
                return;
            }

            for (int i = 0; i <= 99; i++)
            {
                if ((cullingMask & (1 << i)) != 0)
                {
                    SetLayerWidthChildren(obj, i);
                    return;
                }
            }
        }

        // RVA: 0x1950DCC
        public static List<GameObject> FindSceneAllGameObjects()
        {
            Scene activeScene = SceneManager.GetActiveScene();
            if (!activeScene.isLoaded)
            {
                return new List<GameObject>();
            }

            List<GameObject> roots = new List<GameObject>(activeScene.GetRootGameObjects());
            return FindAllGameObject(roots, null);
        }

        // RVA: 0x1950EC8
        public static List<GameObject> FindAllGameObject(
            List<GameObject> roots,
            Func<GameObject, bool> where)
        {
            List<GameObject> list = new List<GameObject>();

            foreach (GameObject root in roots)
            {
                if (where != null && root && where(root))
                {
                    list.Add(root);
                }

                Transform transform = root.transform;
                if (transform.childCount >= 1)
                {
                    List<GameObject> children = new List<GameObject>();
                    for (int i = 0; i < transform.childCount; i++)
                    {
                        children.Add(transform.GetChild(i).gameObject);
                    }

                    list.AddRange(FindAllGameObject(children, where));
                }
            }

            return list;
        }

        // RVA: 0x1A002A0
        public static List<T> FindAllComponent<T>(List<GameObject> roots) where T : Component
        {
            List<T> list = new List<T>();

            foreach (GameObject root in roots)
            {
                T component = root.GetComponent<T>();
                if ((UnityEngine.Object)component != null)
                {
                    list.Add(component);
                }

                Transform transform = root.transform;
                if (transform.childCount >= 1)
                {
                    List<GameObject> children = new List<GameObject>();
                    for (int i = 0; i < transform.childCount; i++)
                    {
                        children.Add(transform.GetChild(i).gameObject);
                    }

                    list.AddRange(FindAllComponent<T>(children));
                }
            }

            return list;
        }

        // RVA: 0x1A00604
        public static List<T> FindSceneAllGameObjects<T>() where T : Component
        {
            List<GameObject> list = new List<GameObject>();

            for (int i = 0; i < SceneManager.sceneCount; i++)
            {
                Scene scene = SceneManager.GetSceneAt(i);
                if (scene.isLoaded)
                {
                    list.AddRange(scene.GetRootGameObjects());
                }
            }

            if (Launcher.Instance)
            {
                list.Add(Launcher.Instance.gameObject);
            }

            return FindAllComponent<T>(list);
        }
    }
}
