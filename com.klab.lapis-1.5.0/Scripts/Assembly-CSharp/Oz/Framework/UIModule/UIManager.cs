// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.UIModule.UIManager
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using Oz.Utility;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Oz.Framework.UIModule
{
    public class UIManager : MonoBehaviour
    {
        private RectTransform m_RootCanvasTransform;
        private Canvas m_RootCanvas;
        private CanvasScaler m_RootCanvasScaler;
        private GraphicRaycaster m_RootGraphicRaycaster;
        private EventSystem m_UIEvetSystem;
        private StandaloneInputModule m_InputModule;
        private Camera m_UICamera;
        private UISettings m_UISettings;
        private Dictionary<string, RectTransform> m_LayeredNodes;
        private bool isChanged;
        public Action screenOrientationAction;
        private ScreenOrientation screenOrientationType;
        public Action<bool> focusChangeAction;
        private static UIManager Instance { get; set; }
        public static RectTransform RootCanvasTransform { get; }
        public static Canvas RootCanvas { get; }
        public static CanvasScaler RootCanvasScaler { get; }
        public static GraphicRaycaster RootGraphicRaycaster { get; }
        public static EventSystem UIEvetSystem { get; }
        public static StandaloneInputModule InputModule { get; }
        public static Camera UICamera { get; }



        // RVA: 0x2EEA670
        public static RectTransform get_RootCanvasTransform()
        {
            if (Instance == null)
            {
                return null;
            }

            return Instance.m_RootCanvasTransform;
        }

        // RVA: 0x2EEA760
        public static Canvas get_RootCanvas()
        {
            if (Instance == null)
            {
                return null;
            }

            return Instance.m_RootCanvas;
        }

        // RVA: 0x2EEA850
        public static CanvasScaler get_RootCanvasScaler()
        {
            if (Instance == null)
            {
                return null;
            }

            return Instance.m_RootCanvasScaler;
        }

        // RVA: 0x2EEA940
        public static GraphicRaycaster get_RootGraphicRaycaster()
        {
            if (Instance == null)
            {
                return null;
            }

            return Instance.m_RootGraphicRaycaster;
        }

        // RVA: 0x2EEAA30
        public static EventSystem get_UIEvetSystem()
        {
            if (Instance == null)
            {
                return null;
            }

            return Instance.m_UIEvetSystem;
        }

        // RVA: 0x2EEAB20
        public static StandaloneInputModule get_InputModule()
        {
            if (Instance == null)
            {
                return null;
            }

            return Instance.m_InputModule;
        }

        // RVA: 0x2EEAC10
        public static Camera get_UICamera()
        {
            if (Instance == null)
            {
                return null;
            }

            return Instance.m_UICamera;
        }

        // RVA: 0x2EEAD00
        private void Awake()
        {
            if (Instance == null)
            {
                Instance = this;
            }

            m_LayeredNodes = new Dictionary<string, RectTransform>();
            m_UISettings = Resources.Load<UISettings>("UISettings");

            CreateCanvas();
            CreateEventSystem();
        }

        // RVA: 0x2EEAE38
        private void CreateCanvas()
        {
            GameObject canvasObject = new GameObject("Canvas");
            canvasObject.transform.SetParent(transform, false);
            canvasObject.layer = LayerMask.NameToLayer("UI");

            m_RootCanvasTransform = canvasObject.AddComponent<RectTransform>();
            m_RootCanvas = canvasObject.AddComponent<Canvas>();

            RootCanvas.renderMode = m_UISettings.renderMode;
            RootCanvas.additionalShaderChannels |= AdditionalCanvasShaderChannels.TexCoord1;

            if (m_UISettings.renderMode == RenderMode.ScreenSpaceCamera)
            {
                CreateScreenSpaceCamera(m_UISettings.orthographic);
            }

            m_RootCanvasScaler = canvasObject.AddComponent<CanvasScaler>();
            RootCanvasScaler.referenceResolution = m_UISettings.referenceResolution;
            RootCanvasScaler.uiScaleMode = m_UISettings.uiScaleMode;
            RootCanvasScaler.screenMatchMode = m_UISettings.screenMathMode;
            RootCanvasScaler.matchWidthOrHeight = m_UISettings.matchWidthOrHeight;

            m_RootGraphicRaycaster = canvasObject.AddComponent<GraphicRaycaster>();
        }

        // RVA: 0x2EEB108
        private void CreateScreenSpaceCamera(bool orthographic)
        {
            GameObject cameraObject = new GameObject("UICamera");
            cameraObject.transform.SetParent(transform, false);
            cameraObject.AddComponent<AudioListener>();

            m_UICamera = cameraObject.AddComponent<Camera>();
            m_UICamera.cullingMask = 1 << LayerMask.NameToLayer("UI");
            m_UICamera.depth = 1000f;
            m_UICamera.allowHDR = false;
            m_UICamera.allowMSAA = false;
            m_UICamera.clearFlags = CameraClearFlags.Depth;
            m_UICamera.orthographic = orthographic;
            m_UICamera.useOcclusionCulling = false;

            RootCanvas.worldCamera = m_UICamera;
        }

        // RVA: 0x2EEB02C
        private void CreateEventSystem()
        {
            GameObject eventObject = new GameObject("EventSystem");
            eventObject.transform.SetParent(transform, false);

            m_UIEvetSystem = eventObject.AddComponent<EventSystem>();
            m_InputModule = eventObject.AddComponent<StandaloneInputModule>();
        }

        // RVA: 0x2EEB2A0
        private void Start()
        {
            AddLayer(string.Empty).gameObject.SetActive(false);

            if (m_UISettings != null)
            {
                for (int i = 0; i < m_UISettings.layers.Count; i++)
                {
                    AddLayer(m_UISettings.layers[i]);
                }
            }
        }

        // RVA: 0x2EEB530
        private void UpdateScreenOrientaion()
        {
            if (screenOrientationAction != null && screenOrientationType != Screen.orientation)
            {
                screenOrientationType = Screen.orientation;
                screenOrientationAction();
            }

            if (Screen.orientation != ScreenUtil.lastOrientation)
            {
                isChanged = true;
            }
        }

        // RVA: 0x2EEB604
        private void Update()
        {
            UpdateScreenOrientaion();
        }

        // RVA: 0x2EEB608
        private IEnumerator SetOrientation()
        {
            if (Screen.orientation == ScreenOrientation.Portrait)
            {
                Screen.orientation = ScreenOrientation.LandscapeLeft;
                yield return null;
            }

            Screen.orientation = ScreenUtil.lastOrientation;
            isChanged = false;
        }

        // RVA: 0x2EEB6A4
        private void OnApplicationFocus(bool hasFocus)
        {
            if (isChanged)
            {
                if (hasFocus)
                {
                    StartCoroutine(SetOrientation());
                }
                else
                {
                    Screen.orientation = ScreenOrientation.LandscapeLeft;
                }
            }

            if (focusChangeAction != null)
            {
                focusChangeAction(hasFocus);
            }
        }

        // RVA: 0x2EEB74C
        private void OnDestroy()
        {
            if (m_UISettings != null)
            {
                for (int i = m_UISettings.layers.Count - 1; i >= 0; i--)
                {
                    RemoveLayer(m_UISettings.layers[i]);
                }
            }
            RemoveLayer(string.Empty);

            if (Instance != null)
            {
                Instance = null;
            }
        }

        // RVA: 0x2EEBA64
        public static int GetResoulutionX()
        {
            return (int)RootCanvasScaler.referenceResolution.x;
        }

        // RVA: 0x2EEBA88
        public static int GetResoulutionY()
        {
            return (int)RootCanvasScaler.referenceResolution.y;
        }

        // RVA: 0x2EEB3A8
        public static RectTransform AddLayer(string layerName)
        {
            if (Instance == null)
            {
                return null;
            }

            RectTransform layer = CreateLayer(layerName);
            layer.SetParent(RootCanvasTransform, false);

            if (!Instance.m_LayeredNodes.ContainsKey(layerName))
            {
                Instance.m_LayeredNodes.Add(layerName, layer);
            }

            return layer;
        }

        // RVA: 0x2EEBAAC
        private static RectTransform CreateLayer(string layerName)
        {
            GameObject layerObject = new GameObject(layerName);
            RectTransform rectTransform = layerObject.AddComponent<RectTransform>();
            layerObject.layer = LayerMask.NameToLayer("UI");

            rectTransform.anchorMin = Vector2.zero;
            rectTransform.anchorMax = Vector2.one;
            rectTransform.sizeDelta = Vector2.zero;
            return rectTransform;
        }

        // RVA: 0x2EEB8E0
        public static void RemoveLayer(string layerName)
        {
            if (Instance != null
                && Instance.m_LayeredNodes.TryGetValue(layerName, out RectTransform layer)
                && layer != null)
            {
                Object.Destroy(layer.gameObject);
            }
        }

        // RVA: 0x2EEBBB8
        public static GameObject GetLayerNode(string layerName)
        {
            if (Instance != null
                && Instance.m_LayeredNodes.TryGetValue(layerName, out RectTransform layer)
                && layer != null)
            {
                return layer.gameObject;
            }

            return null;
        }

        // RVA: 0x2EE2964
        public static bool AttachToLayer(GameObject uiGameObject, string layerName)
        {
            if (Instance != null
                && Instance.m_LayeredNodes.TryGetValue(layerName, out RectTransform layer))
            {
                uiGameObject.transform.SetParent(layer, false);
                return true;
            }

            return false;
        }

        // RVA: 0x2EEBD28
        public static void DetachFromLayer(GameObject uiGameObject)
        {
            AttachToLayer(uiGameObject, string.Empty);
        }

        // RVA: 0x2EEBD78
        public void .ctor()
        {
            screenOrientationType = ScreenOrientation.LandscapeLeft;
        }
    }
}
