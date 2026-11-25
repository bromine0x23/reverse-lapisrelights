// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  BaseTimeLine.RefControlBehaviour
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  按片段局部时间控制场景对象显隐 / 播放。
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using TimeLine;

namespace BaseTimeLine
{
    public class RefControlBehaviour : Behaviour
    {
        public RefControlClip Clip
        {
            // RVA: 0x19955DC
            get { return context.clip as RefControlClip; }
        }

        public RefControlMixer Mixer
        {
            // RVA: 0x199566C
            get { return context.mixer as RefControlMixer; }
        }

        public RefControlTrack Track
        {
            // RVA: 0x19956FC
            get { return context.track as RefControlTrack; }
        }

        // RVA: 0x199578C
        public override void OnBehaviourPlay(Playable playable, FrameData info)
        {
            base.OnBehaviourPlay(playable, info);
            if (Clip != null)
            {
                foreach (RefControlClip.ControlItem item in Clip.Items)
                {
                    item.apply = false;
                }
            }
        }

        // RVA: 0x19958CC
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            base.ProcessFrame(playable, info, playerData);
            float time = Time01;
            if (context.weight <= 0f)
            {
                return;
            }

            foreach (RefControlClip.ControlItem item in Clip.Items)
            {
                if (time < item.LifeTime.start || time > item.LifeTime.end)
                {
                    if (item.apply)
                    {
                        ControlObject(item, !item.On);
                        item.apply = false;
                    }
                }
                else if (!item.apply)
                {
                    ControlObject(item, item.On);
                    item.apply = true;
                }
            }
        }

        // RVA: 0x1996144
        public override void OnPlayableDestroy(Playable playable)
        {
            if (Clip != null)
            {
                foreach (RefControlClip.ControlItem item in Clip.Items)
                {
                    item.Reference.ClearCache();
                    item.Reference.ClearTypeCache();
                    item.Postion.ClearCache();
                    item.Postion.ClearTypeCache();
                }
            }
            base.OnPlayableDestroy(playable);
        }

        // RVA: 0x19962E8
        public override void PauseOnPlaying(Playable playable, FrameData info)
        {
            base.PauseOnPlaying(playable, info);
            if (Clip != null)
            {
                foreach (RefControlClip.ControlItem item in Clip.Items)
                {
                    if (item.apply && item.LifeTime.end <= 1f)
                    {
                        ControlObject(item, !item.On);
                        item.apply = false;
                    }
                }
            }
        }

        // RVA: 0x1995AAC
        private void ControlObject(RefControlClip.ControlItem item, bool On)
        {
            Object reference = item.Reference.Resolve();
            if (reference == null)
            {
                return;
            }
            item.apply = true;

            Object position = item.Postion.Resolve();
            GameObject referenceObject = reference as GameObject;

            if (referenceObject != null)
            {
                referenceObject.SetActive(On);
                if (position == null)
                {
                    return;
                }

                GameObject positionObject = (GameObject)position;
                if (Application.isPlaying && item.SetAsChild)
                {
                    TransformHelper.SetParentLocalScale(referenceObject.transform, positionObject.transform, false);
                    referenceObject.transform.localPosition = Vector3.zero;
                    referenceObject.transform.localRotation = Quaternion.identity;
                }
                else
                {
                    referenceObject.transform.position = positionObject.transform.position;
                    referenceObject.transform.rotation = positionObject.transform.rotation;
                }
                return;
            }

            Component component = reference as Component;
            if (component == null)
            {
                return;
            }

            if (component is Animator animator)
            {
                if (On)
                {
                    // 推断：Trigger 名称常量位于 off_3F55A50，静态无法读取。
                    animator.SetTrigger("Play");
                }
            }
            else if (component is ParticleSystem particle)
            {
                component.gameObject.SetActive(On);
                if (On)
                {
                    particle.Play();
                    foreach (ParticleSystem child in component.GetComponentsInChildren<ParticleSystem>())
                    {
                        child.Play();
                    }
                }
                else
                {
                    particle.Stop();
                    foreach (ParticleSystem child in component.GetComponentsInChildren<ParticleSystem>())
                    {
                        child.Stop();
                    }
                }
            }
            else if (component is PlayableDirector director)
            {
                component.gameObject.SetActive(On);
                if (On)
                {
                    director.Play();
                }
                else
                {
                    director.Stop();
                }
            }

            if (position == null)
            {
                return;
            }

            GameObject target = (GameObject)position;
            if (Application.isPlaying && item.SetAsChild)
            {
                TransformHelper.SetParentLocalScale(component.transform, target.transform, false);
                component.transform.localPosition = Vector3.zero;
                component.transform.localRotation = Quaternion.identity;
            }
            else
            {
                component.transform.position = target.transform.position;
                component.transform.rotation = target.transform.rotation;
            }
        }

        // RVA: 0x199646C
        public RefControlBehaviour()
        {
        }
    }
}
