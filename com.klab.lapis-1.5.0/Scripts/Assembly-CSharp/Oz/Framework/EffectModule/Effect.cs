// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.EffectModule.Effect
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Oz.Framework.EffectModule
{
    public class Effect
    {
        public int uid;
        public int resid;
        public GameObject effectObject;
        public float duration;
        public float life;
        public List<TrailRenderer> trdr;
        public List<ParticleSystem> ptcs;
        public List<Animation> anims;
        public List<Animator> animtors;

        // RVA: 0x13F8D88
        public Effect(GameObject effectPrefab)
        {
            trdr = new List<TrailRenderer>();
            ptcs = new List<ParticleSystem>();
            anims = new List<Animation>();
            animtors = new List<Animator>();

            if (effectPrefab != null)
            {
                resid = effectPrefab.GetInstanceID();
                effectObject = Object.Instantiate(effectPrefab);
                uid = effectObject.GetInstanceID();

                ptcs.AddRange(effectObject.GetComponentsInChildren<ParticleSystem>());
                anims.AddRange(effectObject.GetComponentsInChildren<Animation>());
                animtors.AddRange(effectObject.GetComponentsInChildren<Animator>());
            }
        }

        // RVA: 0x13F8F88
        public void Update()
        {
            if (duration > 0f)
            {
                life -= Time.deltaTime;
            }
        }

        // RVA: 0x13F8FCC
        public void Destroy()
        {
            ptcs.Clear();
            anims.Clear();
            animtors.Clear();

            if (effectObject != null)
            {
                Object.Destroy(effectObject);
            }
        }

        // RVA: 0x13F90CC
        public bool IsAlive()
        {
            return duration < 0f || life > 0f;
        }

        // RVA: 0x13F90F0
        public bool IsLoop()
        {
            return duration < 0f;
        }

        // RVA: 0x13F9100
        public bool IsExist()
        {
            return effectObject != null;
        }

        // RVA: 0x13F9170
        public bool IsAnyParticleSystemAlive()
        {
            for (int i = 0; i < ptcs.Count; i++)
            {
                ParticleSystem particleSystem = ptcs[i];
                if (particleSystem != null && particleSystem.IsAlive())
                {
                    return true;
                }
            }
            return false;
        }

        // RVA: 0x13F9254
        public void SetActive(bool active)
        {
            if (effectObject != null)
            {
                effectObject.SetActive(active);
            }
        }

        // RVA: 0x13F92FC
        public void OnActive(float lifeDuration)
        {
            duration = lifeDuration;
            life = lifeDuration;

            for (int i = 0; i < ptcs.Count; i++)
            {
                if (ptcs[i] != null)
                {
                    ptcs[i].Play();
                }
            }

            for (int i = 0; i < trdr.Count; i++)
            {
                if (trdr[i] != null)
                {
                    trdr[i].emitting = true;
                }
            }

            for (int i = 0; i < anims.Count; i++)
            {
                if (anims[i] != null)
                {
                    anims[i].Play(PlayMode.StopAll);
                }
            }

            for (int i = 0; i < animtors.Count; i++)
            {
                Animator animator = animtors[i];
                if (animator != null)
                {
                    animator.Play(animator.GetCurrentAnimatorStateInfo(0).shortNameHash, 0);
                }
            }
        }

        // RVA: 0x13F95C4
        public void Attach(Transform parent, bool worldPositionStays = false)
        {
            if (effectObject == null)
            {
                return;
            }

            effectObject.transform.SetParent(parent, worldPositionStays);
            if (worldPositionStays)
            {
                return;
            }

            effectObject.transform.localPosition = Vector3.zero;
            effectObject.transform.localRotation = Quaternion.identity;
            effectObject.transform.localScale = Vector3.one;
        }

        // RVA: 0x13F9750
        public void Attach(Transform parent, Vector3 position, Quaternion rotation, float scale)
        {
            if (effectObject == null)
            {
                return;
            }

            effectObject.transform.SetParent(parent);
            effectObject.transform.position = position;
            effectObject.transform.rotation = rotation;
            effectObject.transform.localScale = Vector3.one * scale;
        }

        // RVA: 0x13F9904
        public void OnDeactive()
        {
        }
    }
}
