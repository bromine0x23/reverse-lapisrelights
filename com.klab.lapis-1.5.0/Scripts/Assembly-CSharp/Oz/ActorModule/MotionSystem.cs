// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.MotionSystem
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Play/CrossFade 系列通过 AnimatorOverrideController 轮换两个状态名，
//        把 clip 覆盖到当前状态后播放；Update 负责 CrossFadeInFixedTime 回调。
// =============================================================================

using System.Collections.Generic;
using LuaInterface;
using Oz.Framework;
using Oz.GameFramework.Runtime.Resource;
using UnityEngine;
using UnityEngine.Events;

namespace Oz.ActorModule
{
    public class MotionSystem
    {
        private string currentState;
        private string nextState;
        [SerializeField]
        private ModelSystem m_ModelSystem;
        [SerializeField]
        private Animator m_Animator;
        [SerializeField]
        private MotionController m_MotionController;
        [SerializeField]
        private AnimationSyncSource m_AnimationSyncSource;
        private UnityAction m_OnCrossFadeComp;
        private float m_CrossFadeDuration;
        private float m_DeltaTime;
        [field: SerializeField]
        public IKHeadController HeadDirection { get; private set; }
        public IKBodyController IKTimelineController { get; private set; }

        // RVA: 0x13F3BE8
        public MotionSystem(ModelSystem modelSystem, MotionController controller)
        {
            currentState = "State 0";
            nextState = "State 1";
            m_ModelSystem = modelSystem;
            m_MotionController = controller;
        }

        // RVA: 0x13F3C6C
        public void LateUpdate()
        {
            if (m_AnimationSyncSource != null)
            {
                m_AnimationSyncSource.Apply(m_ModelSystem);
            }
        }

        // RVA: 0x13F3D04
        public void Create()
        {
            m_Animator = m_ModelSystem.AddMissingComponent<Animator>();
            HeadDirection = m_ModelSystem.AddMissingComponent<IKHeadController>();
            HeadDirection.Init(m_Animator);
            IKTimelineController = m_ModelSystem.AddMissingComponent<IKBodyController>();
            IKTimelineController.Init(m_Animator);
            EnableAnimatorController(true);
        }

        // RVA: 0x13F3E34
        public void Destroy()
        {
            if (IKTimelineController != null)
            {
                Object.Destroy(IKTimelineController);
            }
            if (HeadDirection != null)
            {
                Object.Destroy(HeadDirection);
            }
            if (m_Animator != null)
            {
                Object.Destroy(m_Animator);
            }
        }

        // RVA: 0x13F3F98
        public void SetSyncAnimaion(AnimationSyncSource src)
        {
            m_AnimationSyncSource = src;
        }

        // RVA: 0x13F3FA0
        public void Pause()
        {
            m_Animator.speed = 0f;
        }

        // RVA: 0x13F3FC0
        public void Resume()
        {
            m_Animator.speed = 1f;
        }

        // RVA: 0x13F3FE0
        public void FaceAt(Transform transform, float weight = 1f)
        {
            if (HeadDirection != null)
            {
                HeadDirection.SetLookAtTarget(transform, weight);
            }
        }

        // RVA: 0x13F4098
        public void FaceAtImmediate(Transform transform, float weight = 1f)
        {
            if (HeadDirection != null)
            {
                HeadDirection.SetLookAtTargetImmediate(transform, 1f);
            }
        }

        // RVA: 0x13F3DC0
        public void EnableAnimatorController(bool enable)
        {
            if (enable)
            {
                if (m_MotionController != null && m_Animator != null)
                {
                    m_Animator.runtimeAnimatorController = m_MotionController.RuntimeAnimatorController;
                    m_Animator.Rebind();
                }
            }
            else if (m_Animator != null)
            {
                m_Animator.runtimeAnimatorController = null;
            }
        }

        // RVA: 0x13F4140
        public void SetOverrideAnimatorController(RuntimeAnimatorController controller)
        {
            m_Animator.runtimeAnimatorController = controller;
        }

        // RVA: 0x13F415C
        public void SetOverrideAnimatorController(AssetRef controller)
        {
            m_Animator.runtimeAnimatorController = controller.m_Object as RuntimeAnimatorController;
        }

        // RVA: 0x13F4200
        public void SetOverrideAniClip(string clipName, string newClipName)
        {
            if (m_MotionController != null)
            {
                m_MotionController.OverrideAnimatorController[clipName] =
                    m_MotionController.OverrideClips[newClipName];
            }
        }

        // RVA: 0x13F42A0
        public void EnableFireEvents(bool enable)
        {
            m_Animator.fireEvents = enable;
        }

        // RVA: 0x13F42C0
        public string SwapState()
        {
            string state = currentState;
            currentState = nextState;
            nextState = state;
            return state;
        }

        // RVA: 0x13F42D0
        public void Play(AssetRef assetRef)
        {
            Play(assetRef.m_Object as AnimationClip);
        }

        // RVA: 0x13F4350
        public void Play(AnimationClip clip)
        {
            if (m_Animator == null)
            {
                return;
            }

            AnimatorOverrideController overrideController =
                m_Animator.runtimeAnimatorController as AnimatorOverrideController;
            if (overrideController == null)
            {
                return;
            }

            string state = currentState;
            currentState = nextState;
            nextState = state;

            overrideController[state] = clip;
            m_Animator.Play(state);
        }

        // RVA: 0x13F4460
        public void Play(string stateName)
        {
            int layer = m_Animator.GetLayerIndex("Base Layer");
            m_Animator.Play(stateName, layer);
        }

        // RVA: 0x13F44E4
        public void Play(string stateName, float normalizedTime)
        {
            int layer = m_Animator.GetLayerIndex("Base Layer");
            m_Animator.Play(stateName, layer, normalizedTime);
        }

        // RVA: 0x13F4578
        public void CrossFade(AssetRef assetRef, float normalizedTransitionDuration)
        {
            CrossFade(assetRef.m_Object as AnimationClip, normalizedTransitionDuration);
        }

        // RVA: 0x13F4750
        public void CrossFadeFixedTime(AssetRef assetRef, float normalizedTransitionDuration)
        {
            CrossFadeFixedTime(assetRef.m_Object as AnimationClip, normalizedTransitionDuration);
        }

        // RVA: 0x13F47E0
        public void CrossFadeFixedTime(AnimationClip clip, float normalizedTransitionDuration)
        {
            if (m_Animator == null)
            {
                return;
            }

            AnimatorOverrideController overrideController =
                m_Animator.runtimeAnimatorController as AnimatorOverrideController;
            if (overrideController == null)
            {
                return;
            }

            string state = currentState;
            currentState = nextState;
            nextState = state;

            overrideController[state] = clip;
            int layer = m_Animator.GetLayerIndex("Base Layer");
            m_Animator.CrossFadeInFixedTime(state, normalizedTransitionDuration, layer);
        }

        // RVA: 0x13F4608
        public void CrossFade(AnimationClip clip, float normalizedTransitionDuration)
        {
            if (m_Animator == null)
            {
                return;
            }

            AnimatorOverrideController overrideController =
                m_Animator.runtimeAnimatorController as AnimatorOverrideController;
            if (overrideController == null)
            {
                return;
            }

            string state = currentState;
            currentState = nextState;
            nextState = state;

            overrideController[state] = clip;
            int layer = m_Animator.GetLayerIndex("Base Layer");
            m_Animator.CrossFade(state, normalizedTransitionDuration, layer);
        }

        // RVA: 0x13F4928
        public void CrossFade(string stateName, float normalizedTransitionDuration)
        {
            int layer = m_Animator.GetLayerIndex("Base Layer");
            m_Animator.CrossFade(stateName, normalizedTransitionDuration, layer);
        }

        // RVA: 0x13F49BC
        public void CrossFadeInFixedTime(
            string stateName,
            float normalizedTransitionDuration,
            string layerName = "Body")
        {
            int layer = m_Animator.GetLayerIndex(layerName);
            m_Animator.CrossFadeInFixedTime(stateName, normalizedTransitionDuration, layer);
        }

        // RVA: 0x13F4A1C
        public void CrossFadeInFixedTime(
            string stateName,
            float normalizedTransitionDuration,
            UnityAction onCrossFadeComp,
            string layerName = "Body")
        {
            if (onCrossFadeComp != null)
            {
                m_OnCrossFadeComp = onCrossFadeComp;
            }
            m_CrossFadeDuration = normalizedTransitionDuration;

            int layer = m_Animator.GetLayerIndex(layerName);
            m_Animator.CrossFadeInFixedTime(stateName, normalizedTransitionDuration, layer);
        }

        // RVA: 0x13F4A88
        public void SetTrigger(string name)
        {
            m_Animator.SetTrigger(name);
        }

        // RVA: 0x13F4AA4
        public void SetBool(string name, bool val)
        {
            m_Animator.SetBool(name, val);
        }

        // RVA: 0x13F4AC4
        public void SetInteger(string name, int v)
        {
            m_Animator.SetInteger(name, v);
        }

        // RVA: 0x13F4AE0
        public bool IsState(string stateName)
        {
            int layer = m_Animator.GetLayerIndex("Base Layer");
            if (layer == -1)
            {
                return false;
            }
            return m_Animator.GetCurrentAnimatorStateInfo(layer).IsName(stateName);
        }

        // RVA: 0x13F4BE8
        public bool IsInTransition()
        {
            if (m_Animator == null)
            {
                return false;
            }
            return m_Animator.IsInTransition(0);
        }

        // RVA: 0x13F4C84
        public float GetCurAniLength()
        {
            int layer = m_Animator.GetLayerIndex("Base Layer");
            if (layer == -1)
            {
                return 0f;
            }
            return m_Animator.GetCurrentAnimatorStateInfo(layer).length;
        }

        // RVA: 0x13F4D40
        public float GetAnimLength(string stateName)
        {
            if (m_MotionController != null)
            {
                return m_MotionController.GetClipLength(stateName);
            }
            return 0f;
        }

        // RVA: 0x13F4D54
        public LuaTable GetAllStateName()
        {
            LuaTable table = Launcher.Instance.LuaMgr.luaState.NewTable();
            int index = 0;
            foreach (KeyValuePair<string, float> pair in m_MotionController.NameToClipLength)
            {
                if (pair.Value != 0f)
                {
                    table[index++] = pair.Key;
                }
            }
            return table;
        }

        // RVA: 0x13F4EB8
        public void Update()
        {
            if (m_CrossFadeDuration <= 0f)
            {
                return;
            }

            m_DeltaTime += Time.deltaTime;
            if (m_DeltaTime < m_CrossFadeDuration)
            {
                return;
            }

            if (m_OnCrossFadeComp != null)
            {
                m_OnCrossFadeComp.Invoke();
            }
            m_Animator.Update(m_CrossFadeDuration);
            m_CrossFadeDuration = 0f;
            m_DeltaTime = 0f;
        }
    }
}
