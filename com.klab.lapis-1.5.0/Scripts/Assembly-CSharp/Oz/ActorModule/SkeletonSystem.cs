// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.SkeletonSystem
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        在 ModelSystem 基础上管理额外骨骼、SpringBone 与脚跟修正；
//        Merge/MergeBones/FindChildExtraBones/SetupSpringParameter/
//        ClearSpringParameter 仍待还原。
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

namespace Oz.ActorModule
{
    public class SkeletonSystem : ModelSystem
    {
        [SerializeField]
        private Vector3 m_OriginHeadScale;
        [SerializeField]
        private StringExtraBoneDictionary m_ExtraBones;
        [SerializeField]
        private HeelUpdate m_HeelUpdate;
        [SerializeField]
        private SpringManager m_SpringManager;
        public ScaleSettings ScaleSettings { get; private set; }

        // RVA: 0x13F50A4
        public SkeletonSystem(Transform parent, GameObject skeletonPrefab, ScaleSettings scaleSettings)
            : base(parent, skeletonPrefab, scaleSettings)
        {
            m_ExtraBones = new StringExtraBoneDictionary();
        }

        // RVA: 0x13F5180
        public override void Create()
        {
            base.Create();
            m_HeelUpdate = base.AddMissingComponent<HeelUpdate>();
            if (m_HeelUpdate != null)
            {
                m_HeelUpdate.Init(this);
            }
        }

        // RVA: 0x13F51EC
        public override void Destroy()
        {
            base.Destroy();
        }

        // RVA: 0x13F51F0
        public void DestroyExtraBone(string bonePath)
        {
            ExtraBone extraBone;
            if (!m_ExtraBones.TryGetValue(bonePath, out extraBone))
            {
                return;
            }

            if (extraBone.GetRefCount() > 1)
            {
                extraBone.DecRef();
                return;
            }

            extraBone.DecRef();
            if (extraBone.Bone != null)
            {
                extraBone.Bone.SetParent(null);
                Object.Destroy(extraBone.Bone.gameObject);
            }
            m_ExtraBones.Remove(bonePath);
        }

        // RVA: 0x13F5340
        public void Merge(
            GameObject model,
            Dictionary<string, Transform> dictExtraBonePath,
            List<Renderer> renderers,
            bool rebindAnimator)
        {
            MergeBones(model.transform, m_Root.transform, dictExtraBonePath, renderers);

            if (m_Animator != null && rebindAnimator)
            {
                m_Animator.Rebind();
            }
        }

        // RVA: 0x13F5440
        private void MergeBones(
            Transform src,
            Transform dest,
            Dictionary<string, Transform> dictExtraBonePath,
            List<Renderer> renderers)
        {
            for (int i = 0; i < src.childCount; i++)
            {
                Transform child = src.GetChild(i);
                if (child == null)
                {
                    continue;
                }

                string childName = child.name;
                Transform found = dest.Find(childName);

                if (found == null)
                {
                    Transform clone = Object.Instantiate(child);
                    clone.name = child.name;
                    clone.SetParent(dest);
                    clone.localPosition = child.localPosition;
                    clone.localRotation = child.localRotation;
                    clone.localScale = child.localScale;
                    FindChildExtraBones(clone, dictExtraBonePath, renderers);
                }
                else
                {
                    ExtraBone extraBone;
                    if (m_ExtraBones.TryGetValue(childName, out extraBone))
                    {
                        extraBone.AddRef();
                    }
                    dictExtraBonePath.Add(childName, found);
                    MergeBones(child, found, dictExtraBonePath, renderers);
                }
            }
        }

        // RVA: 0x13F56CC
        private void FindChildExtraBones(
            Transform bone,
            Dictionary<string, Transform> dictExtraBonePath,
            List<Renderer> renderers)
        {
            Renderer renderer = bone.GetComponent<Renderer>();
            if (renderer != null)
            {
                renderers.Add(renderer);
                return;
            }

            string boneName = bone.name;
            m_ExtraBones.Add(boneName, new ExtraBone(bone));
            dictExtraBonePath.Add(boneName, bone);

            for (int i = 0; i < bone.childCount; i++)
            {
                FindChildExtraBones(bone.GetChild(i), dictExtraBonePath, renderers);
            }
        }

        // RVA: 0x13F587C
        public override Transform GetBone(string boneName)
        {
            Transform bone = base.GetBone(boneName);
            if (bone == null)
            {
                ExtraBone extraBone;
                if (m_ExtraBones.TryGetValue(boneName, out extraBone) && extraBone != null)
                {
                    return extraBone.Bone;
                }
            }
            return bone;
        }

        // RVA: 0x13F0BC4
        public Transform GetBone(HumanBodyBones humanBodyBones)
        {
            if (m_Animator == null)
            {
                return null;
            }
            return m_Animator.GetBoneTransform(humanBodyBones);
        }

        // RVA: 0x13F594C
        public Transform GetBone(int humanBodyBones)
        {
            return GetBone((HumanBodyBones)humanBodyBones);
        }

        // RVA: 0x13F5950
        public void SetupSkinningMeshRenderer(SkinnedMeshRenderer smr)
        {
            Transform[] bones = smr.bones;
            Transform[] newBones = new Transform[bones.Length];
            for (int i = 0; i < bones.Length; i++)
            {
                Transform bone = GetBone(smr.bones[i].name);
                if (bone != null)
                {
                    newBones[i] = bone;
                }
            }
            smr.bones = newBones;

            if (smr.rootBone != null)
            {
                Transform rootBone = GetBone(smr.rootBone.name);
                if (rootBone != null)
                {
                    smr.rootBone = rootBone;
                }
            }
        }

        // RVA: 0x13F5B98
        public void LateUpdate()
        {
            if (m_HeelUpdate != null && m_HeelUpdate.isActiveAndEnabled)
            {
                m_HeelUpdate.CustomLateUpdate();
            }
        }

        // RVA: 0x13F5C3C
        public void ApplyBreastScale(SkinnedMeshRenderer breast)
        {
            if (breast == null || breast.sharedMesh == null)
            {
                return;
            }
            if (breast.sharedMesh.blendShapeCount < 4 || m_ScaleSettings == null)
            {
                return;
            }

            breast.SetBlendShapeWeight(0, m_ScaleSettings.breastUp);
            breast.SetBlendShapeWeight(1, m_ScaleSettings.breastDown);
            breast.SetBlendShapeWeight(2, m_ScaleSettings.breastLarger);
            breast.SetBlendShapeWeight(3, m_ScaleSettings.breastSmall);
        }

        // RVA: 0x13F5DE0
        public void ApplyHeelSetting(float tweakFootAngle, float tweakFootHeight)
        {
            if (m_HeelUpdate != null)
            {
                m_HeelUpdate.Apply(tweakFootAngle, tweakFootHeight);
            }
        }

        // RVA: 0x13F5E78
        public void SetSpringBoneDestory()
        {
            if (m_SpringManager != null)
            {
                m_SpringManager.ReadyToDestory = true;
            }
        }

        // RVA: 0x13F5F04
        public void SetSpringPreventRefresh(bool enabled)
        {
            if (m_SpringManager != null)
            {
                m_SpringManager.preventUpdateBone = enabled;
            }
        }

        // RVA: 0x13F5F9C
        public void SetSrpingBoneEnabled(bool enabled)
        {
            if (m_SpringManager == null)
            {
                return;
            }

            if (!enabled)
            {
                m_SpringManager.Paused = true;
                return;
            }

            m_SpringManager.RefreshBones();
            m_SpringManager.Paused = false;
        }

        // RVA: 0x13F6060
        public void SetSrpingBoneZlimit(bool supportZLimit)
        {
            if (m_SpringManager != null)
            {
                m_SpringManager.SupportZLimit = supportZLimit;
            }
        }

        // RVA: 0x13F60F8
        public void SetupSpringParameter(
            SpringSetting setting,
            out StringSpringBoneDictionary springBones,
            out StringSpringColliderDictionary springColliders,
            bool needInitAdjust = false)
        {
            springBones = new StringSpringBoneDictionary();
            springColliders = new StringSpringColliderDictionary();

            if (m_Root == null || setting == null)
            {
                return;
            }

            // 1) 生成 SpringBone 并逐字段拷贝参数
            if (setting.boneParameters != null)
            {
                for (int i = 0; i < setting.boneParameters.Length; i++)
                {
                    SpringBoneParameter param = setting.boneParameters[i];
                    Transform node = m_Root.transform.Find(param.nodeName);
                    if (node == null)
                    {
                        continue;
                    }

                    SpringBone bone = new SpringBone();
                    bone.DoAwake(node, node.name);
                    springBones.Add(param.nodeName, bone);

                    bone.child = m_Root.transform.Find(param.childPath);
                    bone.boneAxis = param.boneAxis;
                    bone.radius = param.radius;
                    bone.stiffnessForce = param.stiffnessForce;
                    bone.dragForce = param.dragForce;
                    bone.externalForce = param.externalForce;
                    bone.lowRotationLimit = param.lowRotationLimit;
                    bone.highRotationLimit = param.highRotationLimit;
                    bone.enableRotationLimit = param.enableRotationLimit;
                    bone.BoneLevel = param.BoneLevel;

                    if (param.colliderIDs != null && param.colliderIDs.Length != 0)
                    {
                        bone.colliderIDs = new SpringColliderID[param.colliderIDs.Length];
                        for (int j = 0; j < param.colliderIDs.Length; j++)
                        {
                            bone.colliderIDs[j] = (SpringColliderID)param.colliderIDs[j];
                        }
                    }
                }

                // 2) 关联 sibling 骨骼
                for (int i = 0; i < setting.boneParameters.Length; i++)
                {
                    SpringBoneParameter param = setting.boneParameters[i];
                    SpringBone bone;
                    if (springBones.TryGetValue(param.nodeName, out bone))
                    {
                        SpringBone sibling;
                        if (springBones.TryGetValue(param.sibilingPath, out sibling))
                        {
                            bone.sibling = sibling;
                        }
                    }
                }
            }

            // 3) 生成 SpringCollider 并逐字段拷贝参数
            if (setting.colliderParameters != null)
            {
                for (int i = 0; i < setting.colliderParameters.Length; i++)
                {
                    SpringColliderParameter param = setting.colliderParameters[i];
                    Transform node = m_Root.transform.Find(param.nodeName);
                    if (node == null)
                    {
                        continue;
                    }

                    SpringCollider collider = new SpringCollider();
                    collider.transform = node;
                    collider.name = node.name;
                    springColliders.Add(param.nodeName, collider);
                    collider.radius = param.radius;
                    collider.offset = param.offset;
                }

                // 4) 关联 sibling 碰撞体
                for (int i = 0; i < setting.colliderParameters.Length; i++)
                {
                    SpringColliderParameter param = setting.colliderParameters[i];
                    SpringCollider collider;
                    if (springColliders.TryGetValue(param.nodeName, out collider))
                    {
                        SpringCollider sibling;
                        if (springColliders.TryGetValue(param.sibilingPath, out sibling))
                        {
                            collider.sibling = sibling;
                        }
                    }
                }
            }

            // 5) 在 Reference 节点上挂 SpringManager 并注入骨骼/碰撞体
            Transform reference = GetBone("Reference");
            m_SpringManager = reference.gameObject.AddMissingComponent<SpringManager>();
            m_SpringManager.SetBoneAndCollider(springBones.Values, springColliders.Values);
            m_SpringManager.RefreshBones();
        }

        // RVA: 0x13F6794
        public void ClearSpringParameter(
            Dictionary<string, SpringBone> springBones,
            Dictionary<string, SpringCollider> springColliders)
        {
            if (m_Root == null)
            {
                return;
            }

            if (springBones != null)
            {
                foreach (SpringBone bone in springBones.Values)
                {
                    if (bone != null)
                    {
                        bone.isDestroyed = true;
                    }
                }
                springBones.Clear();
            }

            if (springColliders != null)
            {
                foreach (SpringCollider collider in springColliders.Values)
                {
                    if (collider != null)
                    {
                        collider.isDestroyed = true;
                    }
                }
                springColliders.Clear();
            }

            if (m_SpringManager != null)
            {
                m_SpringManager.RefreshBones();
            }
        }
    }
}
