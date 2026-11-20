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
        protected ScaleSettings m_ScaleSettings;
        [SerializeField]
        protected GameObject m_Prefab;
        [SerializeField]
        private Transform m_Parent;
        [SerializeField]
        protected Animator m_Animator;
        [SerializeField]
        private GameObject m_Root;
        [SerializeField]
        protected Vector3 m_OriginScale;
        [SerializeField]
        protected StringVector3Dictionary m_OriginBoneScales;
        [SerializeField]
        private StringTransformDictionary m_Bones;
        [SerializeField]
        protected List<Renderer> m_Renderers;
        [SerializeField]
        private MaterialPropertyBlock m_MaterialPropertyBlock;
        public ScaleSettings ScaleSettings { get; }
        public GameObject Prefab { get; }
        public GameObject Root { get; }
        public MaterialPropertyBlock MaterialPropertyBlock { get; }

        // RVA: 0x13F2300
        public ScaleSettings get_ScaleSettings()
        {
            return m_ScaleSettings;
        }

        // RVA: 0x13F2308
        public GameObject get_Prefab()
        {
            return m_Prefab;
        }

        // RVA: 0x13F2310
        public GameObject get_Root()
        {
            return m_Root;
        }

        // RVA: 0x13F2318
        private void set_Root(GameObject value)
        {
            m_Root = value;
        }

        // RVA: 0x13F2320
        public MaterialPropertyBlock get_MaterialPropertyBlock()
        {
            if (m_MaterialPropertyBlock == null)
            {
                m_MaterialPropertyBlock = new MaterialPropertyBlock();
            }
            return m_MaterialPropertyBlock;
        }

        // RVA: 0x13F238C
        public ModelSystem(Transform parent, GameObject modelPrefab, ScaleSettings scaleSettings)
        {
            m_Prefab = modelPrefab;
            m_Parent = parent;
            m_ScaleSettings = scaleSettings;
            m_OriginBoneScales = new StringVector3Dictionary();
            m_Bones = new StringTransformDictionary();
            m_Renderers = new List<Renderer>();
        }

        // RVA: 0x13F24FC
        public virtual void Create()
        {
            m_Root = Object.Instantiate(m_Prefab, m_Parent);
            m_Root.name = "Model";
            m_Animator = m_Root.GetComponent<Animator>();
            m_Renderers.AddRange(m_Root.GetComponentsInChildren<Renderer>());
            TransformExtentions.RecursiveFindChildrenPath(m_Root.transform, m_Bones);
            ApplyScale();
        }

        // RVA: 0x13F2620
        public virtual void Destroy()
        {
            m_Renderers.Clear();
            Object.Destroy(m_Root);
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
            if (m_ScaleSettings == null)
            {
                return;
            }

            if (m_Root != null)
            {
                m_OriginScale = m_Root.transform.localScale;
                m_Root.transform.localScale = m_OriginScale * m_ScaleSettings.scaleRatio;
            }

            if (m_ScaleSettings.listScaleData == null)
            {
                return;
            }

            for (int i = 0; i < m_ScaleSettings.listScaleData.Count; i++)
            {
                ScaleData data = m_ScaleSettings.listScaleData[i];
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

            if (m_Root != null)
            {
                m_Root.transform.localScale = m_OriginScale * scaleSettings.scaleRatio;
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
            if (m_ScaleSettings != null && m_Root != null)
            {
                float ratio = origin ? 1f : m_ScaleSettings.scaleRatio;
                if (m_ScaleSettings.isLoli && origin)
                {
                    ratio = 0.89f;
                }
                m_Root.transform.localScale = m_OriginScale * ratio;
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

            if (m_ScaleSettings == null || m_ScaleSettings.listScaleData == null)
            {
                return;
            }

            for (int i = 0; i < m_ScaleSettings.listScaleData.Count; i++)
            {
                ScaleData data = m_ScaleSettings.listScaleData[i];
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
