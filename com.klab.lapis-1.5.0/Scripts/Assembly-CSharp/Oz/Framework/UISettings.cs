// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.UISettings
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace Oz.Framework
{
    /// <summary>UI 画布初始化参数（ScriptableObject 配置资产）。</summary>
    [CreateAssetMenu]
    public class UISettings : ScriptableObject
    {
        public RenderMode renderMode;
        public bool orthographic;
        public CanvasScaler.ScaleMode uiScaleMode;
        public Vector2 referenceResolution;
        public CanvasScaler.ScreenMatchMode screenMathMode;
        public float matchWidthOrHeight;
        public List<string> layers;

        // RVA: 0x2EEBECC
        public UISettings()
        {
        }
    }
}
