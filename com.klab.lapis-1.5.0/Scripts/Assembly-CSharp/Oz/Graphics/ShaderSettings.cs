// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Graphics.ShaderSettings
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        通过全局 shader 变量 _SceneRim / _RimColor 应用场景边缘光。
// =============================================================================

using UnityEngine;

namespace Oz.Graphics
{
    public class ShaderSettings
    {
        [SerializeField]
        private float m_SceneRim;
        [SerializeField]
        private Color m_RimColor;

        // RVA: 0x13D5DC4
        public void ApplyRim(float globalRim, Color rimColor)
        {
            Shader.SetGlobalFloat("_SceneRim", globalRim);
            Shader.SetGlobalColor("_RimColor", rimColor);
        }

        // RVA: 0x13D5E64
        public void ApplyToScene()
        {
            ApplyRim(m_SceneRim, m_RimColor);
        }

        // RVA: 0x13D5E74
        public void Reset()
        {
            Shader.SetGlobalFloat("_SceneRim", 0f);
            Shader.SetGlobalColor("_RimColor", Color.black);
        }

        // RVA: 0x13D5EE0
        public ShaderSettings()
        {
            m_RimColor = Color.black;
        }
    }
}
