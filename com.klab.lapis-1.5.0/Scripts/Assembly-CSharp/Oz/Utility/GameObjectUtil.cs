// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Utility.GameObjectUtil
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using Oz.GameFramework.Runtime.Resource;
using Oz.Framework.Utility;
using DG.Tweening;
using Spine.Unity;
using Physical.RuntimeOpt;
using Oz.Framework.UIModule;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Oz.Utility
{
    public static class GameObjectUtil
    {
        private static Dictionary<string, Font> fontsCache;

        // RVA: 0x13E2A54
        public static void CopyToClipBoard(string content)
        {
        }

        // RVA: 0x13E2A5C
        public static Component GetComponent(GameObject gameObject, string componentType)
        {
            return gameObject.GetComponent(componentType);
        }

        // RVA: 0x13E2A74
        public static Component GetComponentInChildren(GameObject gameObject, string componentType)
        {
            return gameObject.GetComponentInChildren(TypeUtil.GetType(componentType));
        }

        // RVA: 0x13E2AB0
        public static Component AddComponent(GameObject gameObject, string componentType)
        {
            return gameObject.AddComponent(TypeUtil.GetType(componentType));
        }

        // RVA: 0x13E2AEC
        public static Component AddMissingComponent(GameObject gameObject, string componentType)
        {
            Component component = gameObject.GetComponent(componentType);
            if (component)
            {
                return component;
            }

            return AddComponent(gameObject, componentType);
        }

        // RVA: 0x13E2BDC
        public static GameObject Instantiate(GameObject prefab, GameObject parent)
        {
            GameObject gameObject = Object.Instantiate(prefab);
            AttachGameObject(gameObject, parent, true);
            return gameObject;
        }

        // RVA: 0x13E2DA0
        public static GameObject InstantiatePrefab(AssetRef prefab)
        {
            return Object.Instantiate(prefab.Asset as GameObject);
        }

        // RVA: 0x13E2E40
        public static GameObject InstantiatePrefab(AssetRef prefab, GameObject parent)
        {
            GameObject gameObject = Object.Instantiate(prefab.Asset as GameObject);
            AttachGameObject(gameObject, parent, true);
            return gameObject;
        }

        // RVA: 0x13E2F2C
        public static GameObject InstantiatePrefabByCenter(AssetRef prefab, GameObject parent)
        {
            GameObject gameObject = Object.Instantiate(prefab.Asset as GameObject);
            AttachGameObjectByCenter(gameObject, parent);
            return gameObject;
        }

        // RVA: 0x13E3250
        public static GameObject InstantiateUIPrefab(AssetRef prefab, GameObject parent)
        {
            GameObject gameObject = Object.Instantiate(prefab.Asset as GameObject);
            gameObject.transform.SetParent(parent.transform, false);
            return gameObject;
        }

        // RVA: 0x13E3358
        public static GameObject InstantiateUI(GameObject prefab, GameObject parent)
        {
            GameObject gameObject = Object.Instantiate(prefab);
            gameObject.transform.SetParent(parent.transform, false);
            return gameObject;
        }

        // RVA: 0x13E3434
        public static void ResetTransform(GameObject go, bool ignoreScale = false)
        {
            go.transform.localPosition = Vector3.zero;
            go.transform.localRotation = Quaternion.identity;
            if (!ignoreScale)
            {
                go.transform.localScale = Vector3.one;
            }
        }

        // RVA: 0x13E3574
        public static void AttachUIGameObject(GameObject gameObject, GameObject parent)
        {
            gameObject.transform.SetParent(parent.transform, false);
        }

        // RVA: 0x13E2C98
        public static void AttachGameObject(GameObject gameObject, GameObject parent, bool resetTransform = false)
        {
            gameObject.transform.SetParent(parent != null ? parent.transform : null, false);

            if (resetTransform)
            {
                ResetTransform(gameObject, false);
            }
        }

        // RVA: 0x13E3014
        public static void AttachGameObjectByCenter(GameObject go, GameObject parent)
        {
            go.transform.SetParent(parent.transform, false);

            Renderer[] renderers = go.GetComponentsInChildren<Renderer>();
            Vector3 center = Vector3.zero;
            for (int i = 0; i < renderers.Length; i++)
            {
                center += renderers[i].bounds.center;
            }
            center /= renderers.Length;

            go.transform.position -= center;
        }

        // RVA: 0x13E3638
        public static GameObject NewGameObject(string name, GameObject parent)
        {
            GameObject gameObject = new GameObject(name);
            AttachGameObject(gameObject, parent, true);
            return gameObject;
        }

        // RVA: 0x13E36D8
        public static GameObject NewGameObjectUI(string name, GameObject parent)
        {
            GameObject gameObject = new GameObject(name, typeof(RectTransform));
            AttachGameObject(gameObject, parent, true);

            RectTransform rectTransform = gameObject.GetComponent<RectTransform>();
            rectTransform.pivot = new Vector2(0.5f, 0.5f);
            rectTransform.anchorMin = Vector2.zero;
            rectTransform.anchorMax = Vector2.one;
            rectTransform.offsetMax = Vector2.zero;
            rectTransform.offsetMin = Vector2.zero;
            return gameObject;
        }

        // RVA: 0x13E38D8
        public static void SetActive(GameObject gameObject, bool active)
        {
            if (gameObject.activeSelf != active)
            {
                gameObject.SetActive(active);
            }
        }

        // RVA: 0x13E3928
        public static void SetActive(Component component, bool active)
        {
            SetActive(component.gameObject, active);
        }

        // RVA: 0x13E39B8
        public static void SetActive(GameObject gameObject, int v)
        {
            SetActive(gameObject, v != 0);
        }

        // RVA: 0x13E3A30
        public static void SetActive(Component component, int v)
        {
            SetActive(component.gameObject, v != 0);
        }

        // RVA: 0x13E3AC0
        public static void SetGameObjectsActive(GameObject[] objects, int[] numbers)
        {
            for (int i = 0; i < objects.Length; i++)
            {
                SetActive(objects[i], numbers[i]);
            }
        }

        // RVA: 0x13E3BA8
        public static void SetComponenttsActive(Component[] components, int[] numbers)
        {
            for (int i = 0; i < components.Length; i++)
            {
                SetActive(components[i], numbers[i]);
            }
        }

        // RVA: 0x13E3C90
        public static void SetComponentEnabled(GameObject go, bool vbool)
        {
            Graphic[] graphics = go.GetComponentsInChildren<Graphic>();
            for (int i = 0; i < graphics.Length; i++)
            {
                graphics[i].enabled = vbool;
            }
        }

        // RVA: 0x13E3D50
        public static void SetComponentEnabled(GameObject go, int vbool)
        {
            SetComponentEnabled(go, vbool != 0);
        }

        // RVA: 0x13E3DC8
        public static void SetCanvasGroupAlpha(CanvasGroup cg, int v)
        {
            cg.alpha = v;
            cg.blocksRaycasts = v != 0;
        }

        // RVA: 0x13E3E0C
        public static bool IsActiveSelf(GameObject gameObject)
        {
            return gameObject.activeSelf;
        }

        // RVA: 0x13E3E24
        public static bool IsActiveInHierarchy(GameObject gameObject)
        {
            return gameObject.activeInHierarchy;
        }

        // RVA: 0x13E3E3C
        public static string GetGameObjectHashCode(GameObject gameObject)
        {
            if (gameObject == null)
            {
                return string.Empty;
            }

            return gameObject.GetHashCode().ToString();
        }

        // RVA: 0x13E3EFC
        public static string GetGameObjectPath(GameObject gameObject)
        {
            if (gameObject == null)
            {
                return string.Empty;
            }

            Transform transform = gameObject.transform;
            string path = transform.name + "/";
            while (transform.parent != null)
            {
                path = transform.parent.name + "/" + path;
                transform = transform.parent;
            }
            return path;
        }

        // RVA: 0x13E4058
        public static Component FindChildComponent(GameObject gameObject, string childPath, string componentType)
        {
            Transform child = gameObject.transform.Find(childPath);
            if (child == null)
            {
                return null;
            }

            return child.GetComponent(componentType);
        }

        // RVA: 0x13E412C
        public static GameObject FindChildGameObject(GameObject gameObject, string childPath)
        {
            Transform child = gameObject.transform.Find(childPath);
            if (child == null)
            {
                return null;
            }

            return child.gameObject;
        }

        // RVA: 0x13E41F8
        public static GameObject FindGameObjectByName(string name, GameObject parent)
        {
            Transform[] transforms = parent.GetComponentsInChildren<Transform>();
            for (int i = 0; i < transforms.Length; i++)
            {
                if (name == transforms[i].name)
                {
                    return transforms[i].gameObject;
                }
            }
            return null;
        }

        // RVA: 0x13E42E8
        public static void DestroyAllChildren(GameObject gameObject)
        {
            Transform transform = gameObject.transform;
            for (int i = 0; i < transform.childCount; i++)
            {
                Object.Destroy(transform.GetChild(i).gameObject);
            }
        }

        // RVA: 0x13E43F4
        public static void SetGameObjectLayer(GameObject gameObject, int layer)
        {
            Transform[] transforms = gameObject.GetComponentsInChildren<Transform>();
            for (int i = 0; i < transforms.Length; i++)
            {
                transforms[i].gameObject.layer = layer;
            }
        }

        // RVA: 0x13E44BC
        public static void SetAssetRefGameObjectLayer(AssetRef gameObject, int layer)
        {
            GameObject go = gameObject.Asset as GameObject;
            Transform[] transforms = go.GetComponentsInChildren<Transform>();
            for (int i = 0; i < transforms.Length; i++)
            {
                transforms[i].gameObject.layer = layer;
            }
        }

        // RVA: 0x13E45A0
        public static void SetTransformPosition(GameObject gameObject, float x, float y, float z)
        {
            gameObject.transform.position = new Vector3(x, y, z);
        }

        // RVA: 0x13E4628
        public static void GetTransformPosition(GameObject gameObject, out float x, out float y, out float z)
        {
            Vector3 position = gameObject.transform.position;
            x = position.x;
            y = position.y;
            z = position.z;
        }

        // RVA: 0x13E467C
        public static void SetTransformLocalPosition(GameObject gameObject, float x, float y, float z)
        {
            gameObject.transform.localPosition = new Vector3(x, y, z);
        }

        // RVA: 0x13E4704
        public static void SetSpringPause(GameObject gameObject, bool pause)
        {
            SpringManager springManager = gameObject.GetComponentInChildren<SpringManager>();
            springManager.RefreshBones();
            springManager.Paused = pause;
        }

        // RVA: 0x13E47DC
        public static Vector2 GetUIPosForCameraMode(Camera sceneCamera, Canvas canvas, Vector3 worldPos)
        {
            Vector2 localPoint = Vector2.zero;
            if (sceneCamera == null)
            {
                return localPoint;
            }

            Vector2 screenPoint = sceneCamera.WorldToScreenPoint(worldPos);
            RectTransformUtility.ScreenPointToLocalPointInRectangle(
                canvas.transform as RectTransform, screenPoint, canvas.worldCamera, out localPoint);
            return localPoint;
        }

        // RVA: 0x13E4A20
        public static int GetScreenPosX(GameObject g)
        {
            return (int)UIManager.UICamera.WorldToScreenPoint(g.transform.position).x;
        }

        // RVA: 0x13E4A7C
        public static int GetScreenPosY(GameObject g)
        {
            return (int)UIManager.UICamera.WorldToScreenPoint(g.transform.position).y;
        }

        // RVA: 0x13E4AD8
        public static void GetTransformLocalPosition(GameObject gameObject, out float x, out float y, out float z)
        {
            Vector3 localPosition = gameObject.transform.localPosition;
            x = localPosition.x;
            y = localPosition.y;
            z = localPosition.z;
        }

        // RVA: 0x13E4B2C
        public static void SetTransformRotation(GameObject gameObject, float x, float y, float z)
        {
            gameObject.transform.rotation = Quaternion.Euler(x, y, z);
        }

        // RVA: 0x13E4BE4
        public static void GetTransformRotation(GameObject gameObject, out float x, out float y, out float z)
        {
            Vector3 eulerAngles = gameObject.transform.rotation.eulerAngles;
            x = eulerAngles.x;
            y = eulerAngles.y;
            z = eulerAngles.z;
        }

        // RVA: 0x13E4C58
        public static Tweener DORotate(Transform transform, int targetPos)
        {
            return transform.DORotate(new Vector3(targetPos, 0f, 0f), 0.1f, RotateMode.FastBeyond360);
        }

        // RVA: 0x13E4CBC
        public static Tweener DORotate(Transform transform, int targetPos, float duration)
        {
            return transform.DORotate(new Vector3(0f, targetPos, 0f), duration, RotateMode.FastBeyond360);
        }

        // RVA: 0x13E4D28
        public static Tweener DOScale(Transform transform, float targetPos, float duration)
        {
            return transform.DOScale(new Vector3(targetPos, 1f, 1f), duration);
        }

        // RVA: 0x13E4D8C
        public static Tweener DOScaleAll(Transform transform, float targetPos, float duration)
        {
            return transform.DOScale(new Vector3(targetPos, targetPos, 1f), duration);
        }

        // RVA: 0x13E4DF0
        public static Tweener DoMoveX(Transform trans, float endValue, float duration)
        {
            return trans.DOMoveX(endValue, duration);
        }

        // RVA: 0x13E4DFC
        public static Tweener DoMoveY(Transform trans, float endValue, float duration)
        {
            return trans.DOMoveY(endValue, duration);
        }

        // RVA: 0x13E4E08
        public static Tweener DoMoveZ(Transform trans, float endValue, float duration)
        {
            return trans.DOMoveZ(endValue, duration);
        }

        // RVA: 0x13E4E14
        public static void DoFloat(Text trans, float endValue, float duration)
        {
            DOTween.To(() => 0f, value => trans.text = Mathf.Floor(value).ToString(), endValue, duration);
        }

        // RVA: 0x13E4EFC
        public static Tweener DoText(Text trans, string to, float duration)
        {
            return trans.DOText(to, duration, true, ScrambleMode.None, null)
                .SetUpdate(true)
                .SetEase(Ease.Linear);
        }

        // RVA: 0x13E4F98
        public static Tweener DOFillAmount(Image trans, float endValue, float duration)
        {
            return trans.DOFillAmount(endValue, duration);
        }

        // RVA: 0x13E4FA0
        public static void DOFade(Image trans, float endValue, float duration, Ease ease = Ease.Linear)
        {
            trans.DOFade(endValue, duration).SetEase(ease);
        }

        // RVA: 0x13E5020
        public static void DoComplete(Tweener tween)
        {
            tween.Complete();
        }

        // RVA: 0x13E5030
        public static void SetTweenerCallback(Tweener tween, TweenCallback onComplete)
        {
            if (tween != null && tween.onComplete == null)
            {
                tween.onComplete = onComplete;
            }
        }

        // RVA: 0x13E5048
        public static void SetTransformLocalRotation(GameObject gameObject, float x, float y, float z)
        {
            gameObject.transform.localRotation = Quaternion.Euler(x, y, z);
        }

        // RVA: 0x13E5100
        public static void GetTransformLocalRotation(GameObject gameObject, out float x, out float y, out float z)
        {
            Vector3 eulerAngles = gameObject.transform.localRotation.eulerAngles;
            x = eulerAngles.x;
            y = eulerAngles.y;
            z = eulerAngles.z;
        }

        // RVA: 0x13E5174
        public static void SetTransformLocalScale(GameObject gameObject, float scale)
        {
            gameObject.transform.localScale = Vector3.one * scale;
        }

        // RVA: 0x13E521C
        public static void SetTransformLocalScale(GameObject gameObject, float x, float y, float z)
        {
            gameObject.transform.localScale = new Vector3(x, y, z);
        }

        // RVA: 0x13E52A4
        public static void GetTransformLossyScale(GameObject gameObject, out float x, out float y, out float z)
        {
            Vector3 lossyScale = gameObject.transform.lossyScale;
            x = lossyScale.x;
            y = lossyScale.y;
            z = lossyScale.z;
        }

        // RVA: 0x13E52F8
        public static void GetTransformLocalScale(GameObject gameObject, out float x, out float y, out float z)
        {
            Vector3 localScale = gameObject.transform.localScale;
            x = localScale.x;
            y = localScale.y;
            z = localScale.z;
        }

        // RVA: 0x13E534C
        public static void SetRectTransformOffsetMax(GameObject gameObject, float x, float y)
        {
            RectTransform rectTransform = gameObject.transform as RectTransform;
            if (rectTransform != null)
            {
                rectTransform.offsetMax = new Vector2(x, y);
            }
        }

        // RVA: 0x13E543C
        public static void SetRectTransformOffsetMin(GameObject gameObject, float x, float y)
        {
            RectTransform rectTransform = gameObject.transform as RectTransform;
            if (rectTransform != null)
            {
                rectTransform.offsetMin = new Vector2(x, y);
            }
        }

        // RVA: 0x13E552C
        public static void SetRectTransformPivot(GameObject gameObject, float x, float y)
        {
            RectTransform rectTransform = gameObject.transform as RectTransform;
            if (rectTransform != null)
            {
                rectTransform.pivot = new Vector2(x, y);
            }
        }

        // RVA: 0x13E561C
        public static void SetRectTransformOffsetType(GameObject gameObject, int type, int offx, int offy)
        {
            RectTransform rectTransform = gameObject.transform as RectTransform;

            switch (type)
            {
                case 1:
                    rectTransform.anchorMin = new Vector2(1f, 1f);
                    rectTransform.anchorMax = new Vector2(1f, 1f);
                    break;
                case 2:
                    rectTransform.anchorMin = new Vector2(0f, 1f);
                    rectTransform.anchorMax = new Vector2(0f, 1f);
                    break;
                case 3:
                    rectTransform.anchorMin = new Vector2(0f, 0.5f);
                    rectTransform.anchorMax = new Vector2(0f, 0.5f);
                    break;
                default:
                    rectTransform.anchorMin = new Vector2(0.5f, 0.5f);
                    rectTransform.anchorMax = new Vector2(0.5f, 0.5f);
                    break;
            }

            rectTransform.anchoredPosition = new Vector2(offx, offy);
        }

        // RVA: 0x13E57FC
        public static void SetRectTransformSizeDelta(GameObject gameObject, float x, float y)
        {
            RectTransform rectTransform = gameObject.transform as RectTransform;
            if (rectTransform != null)
            {
                rectTransform.sizeDelta = new Vector2(x, y);
            }
        }

        // RVA: 0x13E58EC
        public static void SetRectTransformSizeDeltaWidth(GameObject gameObject, float x)
        {
            RectTransform rectTransform = gameObject.transform as RectTransform;
            if (rectTransform != null)
            {
                rectTransform.sizeDelta = new Vector2(x, rectTransform.sizeDelta.y);
            }
        }

        // RVA: 0x13E59D8
        public static void SetRectTransformSizeDeltaHeight(GameObject gameObject, float y)
        {
            RectTransform rectTransform = gameObject.transform as RectTransform;
            if (rectTransform != null)
            {
                rectTransform.sizeDelta = new Vector2(rectTransform.sizeDelta.x, y);
            }
        }

        // RVA: 0x13E5AC4
        public static int GetRectTransformSizeDeltaWidth(GameObject gameObject)
        {
            RectTransform rectTransform = gameObject.transform as RectTransform;
            return (int)rectTransform.sizeDelta.x;
        }

        // RVA: 0x13E5B40
        public static int GetRectTransformSizeDeltaWidth(AssetRef gameObject)
        {
            return GetRectTransformSizeDeltaWidth(gameObject.Asset as GameObject);
        }

        // RVA: 0x13E5BD4
        public static int GetRectTransformSizeDeltaHeight(GameObject gameObject)
        {
            RectTransform rectTransform = gameObject.transform as RectTransform;
            return (int)rectTransform.sizeDelta.y;
        }

        // RVA: 0x13E5C50
        public static int GetRectTransformSizeDeltaHeight(AssetRef gameObject)
        {
            return GetRectTransformSizeDeltaHeight(gameObject.Asset as GameObject);
        }

        // RVA: 0x13E5CE4
        public static int GetRectTransformWidth(GameObject go)
        {
            RectTransform rectTransform = go.transform as RectTransform;
            return (int)rectTransform.rect.width;
        }

        // RVA: 0x13E5D80
        public static int GetRectTransformHeight(GameObject go)
        {
            RectTransform rectTransform = go.transform as RectTransform;
            return (int)rectTransform.rect.height;
        }

        // RVA: 0x13E5E1C
        public static void SetRectTransformAnchoredPosition(GameObject gameObject, float x, float y)
        {
            RectTransform rectTransform = gameObject.transform as RectTransform;
            if (rectTransform != null)
            {
                rectTransform.anchoredPosition = new Vector2(x, y);
            }
        }

        // RVA: 0x13E5F0C
        public static void SetRectTransformAnchoredPosition3D(GameObject gameObject, float x, float y, float z)
        {
            RectTransform rectTransform = gameObject.transform as RectTransform;
            if (rectTransform != null)
            {
                rectTransform.anchoredPosition3D = new Vector3(x, y, z);
            }
        }

        // RVA: 0x13E6014
        public static void SetRectTransformAnchorMax(GameObject gameObject, float x, float y)
        {
            RectTransform rectTransform = gameObject.transform as RectTransform;
            if (rectTransform != null)
            {
                rectTransform.anchorMax = new Vector2(x, y);
            }
        }

        // RVA: 0x13E6104
        public static void SetRectTransformAnchorMin(GameObject gameObject, float x, float y)
        {
            RectTransform rectTransform = gameObject.transform as RectTransform;
            if (rectTransform != null)
            {
                rectTransform.anchorMin = new Vector2(x, y);
            }
        }

        // RVA: 0x13E61F4
        public static void SetRectTransformRectHeight(GameObject gameObject, float h)
        {
            RectTransform rectTransform = gameObject.transform as RectTransform;
            if (rectTransform != null)
            {
                rectTransform.sizeDelta = new Vector2(rectTransform.sizeDelta.x, h);
            }
        }

        // RVA: 0x13E62E0
        public static void SetScrollPosInt(GameObject go)
        {
            go.GetComponent<ScrollRect>().verticalNormalizedPosition = 1f;
        }

        // RVA: 0x13E6348
        public static void SetSpriteRendererSprite(GameObject gameObject, Sprite sprite)
        {
            gameObject.GetComponent<SpriteRenderer>().sprite = sprite;
        }

        // RVA: 0x13E640C
        public static void SetImageOverrideSprite(Image image, Sprite sprite)
        {
            image.overrideSprite = sprite;
        }

        // RVA: 0x13E64B0
        public static void SetLightColor(GameObject gameObject, float r, float g, float b)
        {
            gameObject.GetComponent<Light>().color = new Color(r, g, b);
        }

        // RVA: 0x13E65A0
        public static void SetLightIntensity(GameObject gameObject, float intensity)
        {
            gameObject.GetComponent<Light>().intensity = intensity;
        }

        // RVA: 0x13E6664
        public static void UpdateSpineSkeleton(GameObject go)
        {
            SkeletonGraphic[] skeletons = go.GetComponentsInChildren<SkeletonGraphic>();
            for (int i = 0; i < skeletons.Length; i++)
            {
                skeletons[i].Update(0f);
            }
        }

        // RVA: 0x13E671C
        public static void SetSpineAnimation(GameObject g, string name, bool loop)
        {
            SkeletonGraphic skeleton = g.GetComponentInChildren<SkeletonGraphic>();
            skeleton.AnimationState.SetAnimation(0, name, loop);
        }

        // RVA: 0x13E67A8
        public static Velocity GetVelocity(GameObject go)
        {
            return go.GetComponentsInChildren<Velocity>()[1];
        }

        // RVA: 0x13E6824
        public static void SetImageColor(GameObject gameObject, float r, float g, float b)
        {
            gameObject.GetComponent<Image>().color = new Color(r, g, b);
        }

        // RVA: 0x13E6924
        public static void SetImageAlpha(GameObject gameObject, float a)
        {
            Image image = gameObject.GetComponent<Image>();
            if (image != null)
            {
                Color color = image.color;
                image.color = new Color(color.r, color.g, color.b, a / 255f);
            }
        }

        // RVA: 0x13E6A60
        public static void SetTextColor(GameObject gameObject, float r, float g, float b)
        {
            gameObject.GetComponent<Text>().color = new Color(r, g, b);
        }

        // RVA: 0x13E6B60
        public static void SetOutLineColor(GameObject gameObject, string html, float distance)
        {
            Color color = Color.red;
            Component outline = AddMissingComponent(gameObject, "Parallel.View.Graphic.FullOutline");
            ColorUtility.TryParseHtmlString(html, out color);

            Shadow shadow = (Shadow)outline;
            shadow.effectColor = color;
            shadow.effectDistance = new Vector2(distance, -distance);
        }

        // RVA: 0x13E6C94
        public static void SetFont(Text text, string fontPath)
        {
            if (!fontsCache.TryGetValue(fontPath, out Font font) || font == null)
            {
                font = ResourceManager.LoadSync(fontPath, typeof(Font)).Asset as Font;
                fontsCache[fontPath] = font;
            }

            text.font = font;
        }

        // RVA: 0x13E6F48
        static GameObjectUtil()
        {
            fontsCache = new Dictionary<string, Font>();
        }
    }
}
