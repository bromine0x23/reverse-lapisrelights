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
        public InteractSetting InteractSettingFile;
        private LinkedList<IBehaviourTask> m_Tasks;
        public GameObject SkeletonRoot { get; }
        [field: SerializeField]
        public GameObject Root { get; private set; }
        [field: SerializeField]
        public SkeletonSystem SkeletonSystem { get; private set; }
        [field: SerializeField]
        public AvatarSystem AvatarSystem { get; private set; }
        [field: SerializeField]
        public MotionSystem MotionSystem { get; private set; }
        [field: SerializeField]
        public ExpressionSystem ExpressionSystem { get; private set; }
        public bool IsLoli { get; }

        // RVA: 0x16ADE0C
        public GameObject get_SkeletonRoot()
        {
            return SkeletonSystem.Root;
        }

        // RVA: 0x16ADE4C
        public bool get_IsLoli()
        {
            return SkeletonSystem.ScaleSettings.isLoli;
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
            Root = gameObject;
            SkeletonSystem = new SkeletonSystem(Root.transform, skeletonPrefab, scaleSettings);
            AvatarSystem = new AvatarSystem(SkeletonSystem, avatars);
            MotionSystem = new MotionSystem(SkeletonSystem, controller);
            ExpressionSystem = new ExpressionSystem(
                SkeletonSystem,
                AvatarSystem,
                facialSettings,
                eyeSettings,
                vowelSettings,
                expressionEffectSettings);
        }

        // RVA: 0x16AE098
        public void Create()
        {
            SkeletonSystem.Create();
            AvatarSystem.Create();
            MotionSystem.Create();
            ExpressionSystem.Create();
        }

        // RVA: 0x16AE198
        public void Destroy()
        {
            m_Tasks.Clear();
            ExpressionSystem.Destroy();
            MotionSystem.Destroy();
            AvatarSystem.Destroy();
            SkeletonSystem.Destroy();
            Object.Destroy(gameObject);
        }

        // RVA: 0x16AE3E8
        public void SetMaterialProperty(string name, float value)
        {
            AvatarSystem.SetMaterialProperty(name, value);
        }

        // RVA: 0x16AE514
        public void SetMaterialProperty(string name, Vector4 value)
        {
            AvatarSystem.SetMaterialProperty(name, value);
        }

        // RVA: 0x16AE660
        public void SetMaterialProperty(string name, Color value)
        {
            AvatarSystem.SetMaterialProperty(name, value);
        }

        // RVA: 0x16AE7AC
        public void ClearMaterialPropertyBlock()
        {
            AvatarSystem.ClearMaterialPropertyBlock();
        }

        // RVA: 0x16AE8B8
        public void SetMaterialPropertyAlphaForRTRendering(float value)
        {
            AvatarSystem.SetMaterialProperty("_Color", Color.white * value);
        }

        // RVA: 0x16AE93C
        public void ResetState()
        {
            ExpressionSystem.Play(eFaceExpression.USUALLY, false);
            ExpressionSystem.ExpressionAnimator.SetBlinkRatio(1f);
            ExpressionSystem.ExpressionEffector.Stop();

            ExpressionSystem.ExpressionAnimator.Voice.ResetVowelInfo();
            ExpressionSystem.ExpressionAnimator.Voice.ResetVowel();
        }

        // RVA: 0x16AE9E0
        public void ResetBehaviour()
        {
            m_Tasks.Clear();
            ExpressionSystem.StopEffect();
            ExpressionSystem.CrossFade(eFaceExpression.USUALLY, false, 0.02f);
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
                    if (task is MotionTask && MotionSystem.IsInTransition)
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
            MotionSystem.LateUpdate();
            SkeletonSystem.LateUpdate();
            ExpressionSystem.LateUpdate();
        }

        // RVA: 0x16AED9C
        public void PlayBehaviour(BehaviourData behaviourData, Action onComplete)
        {
            if (behaviourData != null && behaviourData.AnimClip != null)
            {
                ExpressionSystem.StopEffect();
                m_Tasks.Clear();
                PlayBehaviourInternal(behaviourData, onComplete, false);
            }
        }

        // RVA: 0x16AF134
        public void PlayBehaviourImmediately(BehaviourData behaviourData, Action onComplete)
        {
            if (behaviourData != null && behaviourData.AnimClip != null)
            {
                ExpressionSystem.StopEffect();
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
                MotionSystem,
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
                        ExpressionSystem, expressionEvent, Time.time + length * expressionEvent.m_Time));
                }
            }

            if (behaviourData.ExpressionEffectEvents != null)
            {
                for (int i = 0; i < behaviourData.ExpressionEffectEvents.Length; i++)
                {
                    ExpressionEffectEvent effectEvent = behaviourData.ExpressionEffectEvents[i];
                    m_Tasks.AddLast(new ExpressionEffectTask(
                        ExpressionSystem, effectEvent, Time.time + length * effectEvent.m_Time));
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
