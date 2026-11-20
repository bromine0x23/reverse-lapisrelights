// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.MaterialRendererCollection
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        对 collection 中每个 Renderer：GetPropertyBlock → 设置属性 → SetPropertyBlock
// =============================================================================

using UnityEngine;

namespace Oz.Timeline
{
    public class MaterialRendererCollection : MonoBehaviour, IMaterialPropertyBlockModifier, ITimelineBinding
    {
        public Renderer[] collection;
        private MaterialPropertyBlock _materialPropertyBlock;

        // RVA: 0x13DB9F0
        private MaterialPropertyBlock get_MaterialPropertyBlock()
        {
            if (_materialPropertyBlock == null)
            {
                _materialPropertyBlock = new MaterialPropertyBlock();
            }
            return _materialPropertyBlock;
        }

        // RVA: 0x13DBA5C
        public void ClearMaterialPropertyBlock()
        {
            for (int i = 0; i < collection.Length; i++)
            {
                if (collection[i] != null)
                {
                    collection[i].SetPropertyBlock(null);
                }
            }
        }

        // RVA: 0x13DBB30
        public void SetMaterialProperty(string name, float value)
        {
            for (int i = 0; i < collection.Length; i++)
            {
                Renderer renderer = collection[i];
                if (renderer != null)
                {
                    renderer.GetPropertyBlock(MaterialPropertyBlock);
                    MaterialPropertyBlock.SetFloat(name, value);
                    renderer.SetPropertyBlock(MaterialPropertyBlock);
                }
            }
        }

        // RVA: 0x13DBC58
        public void SetMaterialProperty(string name, Vector4 value)
        {
            for (int i = 0; i < collection.Length; i++)
            {
                Renderer renderer = collection[i];
                if (renderer != null)
                {
                    renderer.GetPropertyBlock(MaterialPropertyBlock);
                    MaterialPropertyBlock.SetVector(name, value);
                    renderer.SetPropertyBlock(MaterialPropertyBlock);
                }
            }
        }

        // RVA: 0x13DBDA0
        public void SetMaterialProperty(string name, Color value)
        {
            for (int i = 0; i < collection.Length; i++)
            {
                Renderer renderer = collection[i];
                if (renderer != null)
                {
                    renderer.GetPropertyBlock(MaterialPropertyBlock);
                    MaterialPropertyBlock.SetColor(name, value);
                    renderer.SetPropertyBlock(MaterialPropertyBlock);
                }
            }
        }

        // RVA: 0x13DBEE8
        public MaterialRendererCollection()
        {
        }
    }
}
