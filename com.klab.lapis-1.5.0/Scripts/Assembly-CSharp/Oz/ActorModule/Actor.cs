// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.Actor
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Init 依次构建 Skeleton/Avatar/Motion/Expression 四个子系统；
//        Update 每帧消费 m_Tasks（MotionTask 在过渡中跳过），
//        PlayBehaviourInternal 按动画时长把表情/特效/回调排入任务链。
// =============================================================================

using System;
using System.Collections.Generic;
using UnityEngine;

namespace Oz.ActorModule
{
    public class Actor : MonoBehaviour, IMaterialPropertyBlockModifier, ITimelineBinding
    {
        [SerializeField]
        private GameObject m_Root;
        [SerializeField]
        private SkeletonSystem m_SkeletonSystem;
        [SerializeField]
        private AvatarSystem m_AvatarSystem;
        [SerializeField]
        private MotionSystem m_MotionSystem;
        [SerializeField]
        private ExpressionSystem m_ExpressionSystem;
        public InteractSetting InteractSettingFile;
        private LinkedList<IBehaviourTask> m_Tasks;
        public GameObject SkeletonRoot { get; }
        public GameObject Root { get; }
        public SkeletonSystem SkeletonSystem { get; }
        public AvatarSystem AvatarSystem { get; }
        public MotionSystem MotionSystem { get; }
        public ExpressionSystem ExpressionSystem { get; }
        public bool IsLoli { get; }

        // RVA: 0x16ADE0C
        public GameObject get_SkeletonRoot()
        {
            return m_SkeletonSystem.Root;
        }

        // RVA: 0x16ADE24
        public GameObject get_Root()
        {
            return m_Root;
        }

        // RVA: 0x16ADE2C
        public SkeletonSystem get_SkeletonSystem()
        {
            return m_SkeletonSystem;
        }

        // RVA: 0x16ADE34
        public AvatarSystem get_AvatarSystem()
        {
            return m_AvatarSystem;
        }

        // RVA: 0x16ADE3C
        public MotionSystem get_MotionSystem()
        {
            return m_MotionSystem;
        }

        // RVA: 0x16ADE44
        public ExpressionSystem get_ExpressionSystem()
        {
            return m_ExpressionSystem;
        }

        // RVA: 0x16ADE4C
        public bool get_IsLoli()
        {
            return m_SkeletonSystem.ScaleSettings.isLoli;
        }

        // RVA: 0x16ADE74
        public void Init(
            GameObject skeletonPrefab,
            ScaleSettings scaleSettings,
            AvatarPart[] avatars,
            MotionController controller,
            FacialSettings facialSettings,
            EyeSettings eyeSettings,
            VowelSetting vowelSettings,
            ExpressionEffectSettings expressionEffectSettings)
        {
            m_Root = gameObject;
            m_SkeletonSystem = new SkeletonSystem(m_Root.transform, skeletonPrefab, scaleSettings);
            m_AvatarSystem = new AvatarSystem(m_SkeletonSystem, avatars);
            m_MotionSystem = new MotionSystem(m_SkeletonSystem, controller);
            m_ExpressionSystem = new ExpressionSystem(
                m_SkeletonSystem,
                m_AvatarSystem,
                facialSettings,
                eyeSettings,
                vowelSettings,
                expressionEffectSettings);
        }

        // RVA: 0x16AE098
        public void Create()
        {
            m_SkeletonSystem.Create();
            m_AvatarSystem.Create();
            m_MotionSystem.Create();
            m_ExpressionSystem.Create();
        }

        // RVA: 0x16AE198
        public void Destroy()
        {
            m_Tasks.Clear();
            m_ExpressionSystem.Destroy();
            m_MotionSystem.Destroy();
            m_AvatarSystem.Destroy();
            m_SkeletonSystem.Destroy();
            Object.Destroy(gameObject);
        }

        // RVA: 0x16AE3E8
        public void SetMaterialProperty(string name, float value)
        {
            m_AvatarSystem.SetMaterialProperty(name, value);
        }

        // RVA: 0x16AE514
        public void SetMaterialProperty(string name, Vector4 value)
        {
            m_AvatarSystem.SetMaterialProperty(name, value);
        }

        // RVA: 0x16AE660
        public void SetMaterialProperty(string name, Color value)
        {
            m_AvatarSystem.SetMaterialProperty(name, value);
        }

        // RVA: 0x16AE7AC
        public void ClearMaterialPropertyBlock()
        {
            m_AvatarSystem.ClearMaterialPropertyBlock();
        }

        // RVA: 0x16AE8B8
        public void SetMaterialPropertyAlphaForRTRendering(float value)
        {
            m_AvatarSystem.SetMaterialProperty("_Color", Color.white * value);
        }

        // RVA: 0x16AE93C
        public void ResetState()
        {
            m_ExpressionSystem.Play(eFaceExpression.USUALLY, false);
            m_ExpressionSystem.ExpressionAnimator.SetBlinkRatio(1f);
            m_ExpressionSystem.ExpressionEffector.Stop();

            m_ExpressionSystem.ExpressionAnimator.Voice.ResetVowelInfo();
            m_ExpressionSystem.ExpressionAnimator.Voice.ResetVowel();
        }

        // RVA: 0x16AE9E0
        public void ResetBehaviour()
        {
            m_Tasks.Clear();
            m_ExpressionSystem.StopEffect();
            m_ExpressionSystem.CrossFade(eFaceExpression.USUALLY, false, 0.02f);
        }

        // RVA: 0x16AEAF0
        private void Update()
        {
            LinkedListNode<IBehaviourTask> node = m_Tasks.First;
            while (node != null)
            {
                IBehaviourTask task = node.Value;
                LinkedListNode<IBehaviourTask> next = node.Next;

                if (task.Check())
                {
                    if (task is MotionTask && m_MotionSystem.IsInTransition)
                    {
                        node = next;
                        continue;
                    }

                    m_Tasks.Remove(node);
                    task.Execute();
                }

                node = next;
            }
        }

        // RVA: 0x16AED48
        private void LateUpdate()
        {
            m_MotionSystem.LateUpdate();
            m_SkeletonSystem.LateUpdate();
            m_ExpressionSystem.LateUpdate();
        }

        // RVA: 0x16AED9C
        public void PlayBehaviour(BehaviourData behaviourData, Action onComplete)
        {
            if (behaviourData != null && behaviourData.AnimClip != null)
            {
                m_ExpressionSystem.StopEffect();
                m_Tasks.Clear();
                PlayBehaviourInternal(behaviourData, onComplete, false);
            }
        }

        // RVA: 0x16AF134
        public void PlayBehaviourImmediately(BehaviourData behaviourData, Action onComplete)
        {
            if (behaviourData != null && behaviourData.AnimClip != null)
            {
                m_ExpressionSystem.StopEffect();
                m_Tasks.Clear();
                PlayBehaviourInternal(behaviourData, onComplete, true);
            }
        }

        // RVA: 0x16AEE74
        private void PlayBehaviourInternal(BehaviourData behaviourData, Action onComplete, bool playImmediately = false)
        {
            if (behaviourData == null)
            {
                return;
            }

            MotionTask motionTask = new MotionTask(
                m_MotionSystem,
                behaviourData.AnimClip,
                behaviourData.CrossFadeTime,
                Time.time,
                behaviourData.UseFixedTime);

            if (playImmediately)
            {
                motionTask.SetPlayImmediately();
            }
            m_Tasks.AddLast(motionTask);

            float length = behaviourData.AnimClip.length;

            if (behaviourData.ExpressionEvents != null)
            {
                for (int i = 0; i < behaviourData.ExpressionEvents.Length; i++)
                {
                    ExpressionEvent expressionEvent = behaviourData.ExpressionEvents[i];
                    m_Tasks.AddLast(new ExpressionTask(
                        m_ExpressionSystem, expressionEvent, Time.time + length * expressionEvent.m_Time));
                }
            }

            if (behaviourData.ExpressionEffectEvents != null)
            {
                for (int i = 0; i < behaviourData.ExpressionEffectEvents.Length; i++)
                {
                    ExpressionEffectEvent effectEvent = behaviourData.ExpressionEffectEvents[i];
                    m_Tasks.AddLast(new ExpressionEffectTask(
                        m_ExpressionSystem, effectEvent, Time.time + length * effectEvent.m_Time));
                }
            }

            if (onComplete != null && !behaviourData.AnimClip.isLooping)
            {
                m_Tasks.AddLast(new CallbackTask(onComplete, Time.time + length));
            }
        }

        // RVA: 0x16AF248
        public Actor()
        {
        }
    }
}
