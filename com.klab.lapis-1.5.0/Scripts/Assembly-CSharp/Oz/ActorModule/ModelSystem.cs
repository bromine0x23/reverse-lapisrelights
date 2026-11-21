// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.ModelSystem
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Create 以 m_Parent 实例化预制体并收集 Renderer/骨骼路径；
//        ApplyScale / SetScale 依据 ScaleSettings（含 isLoli 0.89 倍率）
//        与 listScaleData 缩放根节点及指定骨骼。
// =============================================================================

using System.Collections.Generic;
using Oz.GameFramework.Runtime;
using Oz.GameFramework.Runtime.Resource;
using UnityEngine;

namespace Oz.ActorModule
{
    public class ModelSystem
    {
        [SerializeField]
        private Transform m_Parent;
        [SerializeField]
        protected Animator m_Animator;
        [SerializeField]
        protected Vector3 m_OriginScale;
        [SerializeField]
        protected StringVector3Dictionary m_OriginBoneScales;
        [SerializeField]
        private StringTransformDictionary m_Bones;
        [SerializeField]
        protected List<Renderer> m_Renderers;
        [field: SerializeField]
        public ScaleSettings ScaleSettings { get; private set; }
        [field: SerializeField]
        public GameObject Prefab { get; private set; }
        [field: SerializeField]
        public GameObject Root { get; private set; }
        [field: SerializeField]
        public MaterialPropertyBlock MaterialPropertyBlock { get; private set; }

        // RVA: 0x13F2320
        public MaterialPropertyBlock get_MaterialPropertyBlock()
        {
            if (MaterialPropertyBlock == null)
            {
                MaterialPropertyBlock = new MaterialPropertyBlock();
            }
            return MaterialPropertyBlock;
        }

        // RVA: 0x13F238C
        public ModelSystem(Transform parent, GameObject modelPrefab, ScaleSettings scaleSettings)
        {
            Prefab = modelPrefab;
            m_Parent = parent;
            ScaleSettings = scaleSettings;
            m_OriginBoneScales = new StringVector3Dictionary();
            m_Bones = new StringTransformDictionary();
            m_Renderers = new List<Renderer>();
        }

        // RVA: 0x13F24FC
        public virtual void Create()
        {
            Root = Object.Instantiate(Prefab, m_Parent);
            Root.name = "Model";
            m_Animator = Root.GetComponent<Animator>();
            m_Renderers.AddRange(Root.GetComponentsInChildren<Renderer>());
            TransformExtentions.RecursiveFindChildrenPath(Root.transform, m_Bones);
            ApplyScale();
        }

        // RVA: 0x13F2620
        public virtual void Destroy()
        {
            m_Renderers.Clear();
            Object.Destroy(Root);
        }

        // RVA: 0x13F26A8
        public void ApplyBoneTransform(string name, Transform transform)
        {
            Transform bone;
            if (m_Bones.TryGetValue(name, out bone))
            {
                if (bone != null && transform != null)
                {
                    bone.localPosition = transform.localPosition;
                    bone.localRotation = transform.localRotation;
                }
            }
        }

        // RVA: 0x13F27A8
        protected virtual void ApplyScale()
        {
            if (ScaleSettings == null)
            {
                return;
            }

            if (Root != null)
            {
                m_OriginScale = Root.transform.localScale;
                Root.transform.localScale = m_OriginScale * ScaleSettings.scaleRatio;
            }

            if (ScaleSettings.listScaleData == null)
            {
                return;
            }

            for (int i = 0; i < ScaleSettings.listScaleData.Count; i++)
            {
                ScaleData data = ScaleSettings.listScaleData[i];
                if (data == null)
                {
                    continue;
                }

                Transform bone = GetBone(data.m_BoneName);
                if (bone == null)
                {
                    continue;
                }

                Vector3 originScale;
                if (!m_OriginBoneScales.TryGetValue(data.m_BoneName, out originScale))
                {
                    originScale = bone.localScale;
                    m_OriginBoneScales.Add(data.m_BoneName, originScale);
                }
                bone.localScale = Vector3.Scale(originScale, data.m_Scale);
            }
        }

        // RVA: 0x13F2A80
        public virtual void SetScale(AssetRef scaleSettings)
        {
            SetScale(scaleSettings.m_Object as ScaleSettings);
        }

        // RVA: 0x13F2B24
        public virtual void SetScale(ScaleSettings scaleSettings)
        {
            if (scaleSettings == null)
            {
                return;
            }

            if (Root != null)
            {
                Root.transform.localScale = m_OriginScale * scaleSettings.scaleRatio;
            }

            if (scaleSettings.listScaleData == null)
            {
                return;
            }

            for (int i = 0; i < scaleSettings.listScaleData.Count; i++)
            {
                ScaleData data = scaleSettings.listScaleData[i];
                if (data == null)
                {
                    continue;
                }

                Transform bone = GetBone(data.m_BoneName);
                Vector3 originScale;
                if (bone != null && m_OriginBoneScales.TryGetValue(data.m_BoneName, out originScale))
                {
                    bone.localScale = Vector3.Scale(originScale, data.m_Scale);
                }
            }
        }

        // RVA: 0x13F2D98
        public virtual void SetScale(bool origin)
        {
            if (ScaleSettings != null && Root != null)
            {
                float ratio = origin ? 1f : ScaleSettings.scaleRatio;
                if (ScaleSettings.isLoli && origin)
                {
                    ratio = 0.89f;
                }
                Root.transform.localScale = m_OriginScale * ratio;
            }

            if (origin)
            {
                foreach (string boneName in m_OriginBoneScales.Keys)
                {
                    Transform bone = GetBone(boneName);
                    Vector3 scale;
                    if (bone != null && m_OriginBoneScales.TryGetValue(boneName, out scale))
                    {
                        bone.localScale = scale;
                    }
                }
                return;
            }

            if (ScaleSettings == null || ScaleSettings.listScaleData == null)
            {
                return;
            }

            for (int i = 0; i < ScaleSettings.listScaleData.Count; i++)
            {
                ScaleData data = ScaleSettings.listScaleData[i];
                if (data == null)
                {
                    continue;
                }

                Transform bone = GetBone(data.m_BoneName);
                Vector3 originScale;
                if (bone != null && m_OriginBoneScales.TryGetValue(data.m_BoneName, out originScale))
                {
                    bone.localScale = Vector3.Scale(originScale, data.m_Scale);
                }
            }
        }

        // RVA: 0x13F3258
        public virtual Transform GetBone(string boneName)
        {
            Transform bone = null;
            if (m_Bones.TryGetValue(boneName, out bone))
            {
                return bone;
            }
            return null;
        }

        // RVA: 0x13F32D8
        public void SetMaterialProperty(string name, float value)
        {
            for (int i = 0; i < m_Renderers.Count; i++)
            {
                Renderer renderer = m_Renderers[i];
                if (renderer != null)
                {
                    renderer.GetPropertyBlock(MaterialPropertyBlock);
                    MaterialPropertyBlock.SetFloat(name, value);
                    renderer.SetPropertyBlock(MaterialPropertyBlock);
                }
            }
        }

        // RVA: 0x13F33C4
        public void SetMaterialProperty(string name, Vector4 value)
        {
            for (int i = 0; i < m_Renderers.Count; i++)
            {
                Renderer renderer = m_Renderers[i];
                if (renderer != null)
                {
                    renderer.GetPropertyBlock(MaterialPropertyBlock);
                    MaterialPropertyBlock.SetVector(name, value);
                    renderer.SetPropertyBlock(MaterialPropertyBlock);
                }
            }
        }

        // RVA: 0x13F34D0
        public void SetMaterialProperty(string name, Color value)
        {
            for (int i = 0; i < m_Renderers.Count; i++)
            {
                Renderer renderer = m_Renderers[i];
                if (renderer != null)
                {
                    renderer.GetPropertyBlock(MaterialPropertyBlock);
                    MaterialPropertyBlock.SetColor(name, value);
                    renderer.SetPropertyBlock(MaterialPropertyBlock);
                }
            }
        }

        // RVA: 0x13F35DC
        public void ClearMaterialPropertyBlock()
        {
            for (int i = 0; i < m_Renderers.Count; i++)
            {
                Renderer renderer = m_Renderers[i];
                if (renderer != null)
                {
                    renderer.SetPropertyBlock(null);
                }
            }
        }
    }
}
