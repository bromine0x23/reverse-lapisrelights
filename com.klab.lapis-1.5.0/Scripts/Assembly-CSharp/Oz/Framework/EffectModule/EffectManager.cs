// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.EffectModule.EffectManager
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
    public class EffectManager : MonoBehaviour
    {
        private const int MAX_CACHE = 16;
        private Dictionary<int, Effect> m_ActiveEffects;
        private Dictionary<int, Queue<Effect>> m_CachedEffects;
        private List<int> m_EffectsToDie;
        private GameObject m_CacheNode;
        private static EffectManager Instance { get; set; }

        // RVA: 0x13F9908
        private static EffectManager get_Instance()
        {
            return Instance;
        }

        // RVA: 0x13F9958
        private static void set_Instance(EffectManager value)
        {
            Instance = value;
        }

        // RVA: 0x13F99AC
        private void Awake()
        {
            if (Instance == null)
            {
                Instance = this;
            }

            m_ActiveEffects = new Dictionary<int, Effect>();
            m_CachedEffects = new Dictionary<int, Queue<Effect>>();
            m_EffectsToDie = new List<int>();

            m_CacheNode = new GameObject("EffectCacheNode");
            m_CacheNode.transform.SetParent(transform);
        }

        // RVA: 0x13F9B68
        private void OnDestroy()
        {
            Clear();

            if (Instance != null)
            {
                Instance = null;
            }
        }

        // RVA: 0x13F9D38
        private void LateUpdate()
        {
            foreach (KeyValuePair<int, Effect> pair in m_ActiveEffects)
            {
                Effect effect = pair.Value;
                if (effect != null)
                {
                    if (effect.duration > 0f)
                    {
                        effect.life -= Time.deltaTime;
                    }

                    if ((effect.duration >= 0f && effect.life <= 0f) || !effect.IsExist())
                    {
                        m_EffectsToDie.Add(effect.uid);
                    }
                }
            }

            for (int i = 0; i < m_EffectsToDie.Count; i++)
            {
                Free(m_EffectsToDie[i]);
            }
            m_EffectsToDie.Clear();
        }

        // RVA: 0x13F9EB0
        public static void Prewarm(AssetRef effectPrefab, int count)
        {
            if (Instance != null)
            {
                Instance.PrewarmInternal(effectPrefab, count);
            }
        }

        // RVA: 0x13F9FC0
        public void PrewarmInternal(AssetRef effectPrefab, int count)
        {
            for (int i = 0; i < count; i++)
            {
                Effect effect = Create(effectPrefab.Asset as GameObject);
                Deactive(effect);
                PutIntoCache(effect);
            }
        }

        // RVA: 0x13F9C44
        public static void Clear()
        {
            if (Instance != null)
            {
                Instance.ClearInternal();
            }
        }

        // RVA: 0x13FA288
        public void ClearInternal()
        {
            foreach (Effect effect in m_ActiveEffects.Values)
            {
                effect.Destroy();
            }
            m_ActiveEffects.Clear();

            foreach (Queue<Effect> queue in m_CachedEffects.Values)
            {
                foreach (Effect effect in queue)
                {
                    effect.Destroy();
                }
            }
            m_CachedEffects.Clear();

            m_EffectsToDie.Clear();
        }

        // RVA: 0x13FA604
        public static void Clear(AssetRef assetRef)
        {
            if (Instance != null && assetRef.Asset != null)
            {
                Instance.ClearInternal(assetRef.Asset.GetInstanceID());
            }
        }

        // RVA: 0x13FA8A8
        public static void Clear(GameObject prefab)
        {
            if (Instance != null)
            {
                Instance.ClearInternal(prefab.GetInstanceID());
            }
        }

        // RVA: 0x13FA754
        public void ClearInternal(int instanceID)
        {
            if (m_CachedEffects.TryGetValue(instanceID, out Queue<Effect> queue))
            {
                foreach (Effect effect in queue)
                {
                    effect.Destroy();
                }
            }

            m_CachedEffects.Remove(instanceID);
        }

        // RVA: 0x13EF518
        public static int Alloc(AssetRef effectPrefab, Transform parent, float duration)
        {
            if (Instance == null)
            {
                return -1;
            }

            return Instance.AllocInternal(effectPrefab.Asset as GameObject, parent, duration);
        }

        // RVA: 0x13FAA58
        public static int Alloc(GameObject effectPrefab, Transform parent, float duration)
        {
            if (Instance == null)
            {
                return -1;
            }

            return Instance.AllocInternal(effectPrefab, parent, duration);
        }

        // RVA: 0x13FAB80
        public static int Alloc(AssetRef effectPrefab, float duration)
        {
            if (Instance == null)
            {
                return -1;
            }

            return Instance.AllocInternal(
                effectPrefab.Asset as GameObject, Vector3.zero, Quaternion.identity, 1f, duration);
        }

        // RVA: 0x13FAE64
        public static int Alloc(GameObject effectPrefab, float duration)
        {
            if (Instance == null)
            {
                return -1;
            }

            return Instance.AllocInternal(
                effectPrefab, Vector3.zero, Quaternion.identity, 1f, duration);
        }

        // RVA: 0x13FB00C
        public static int Alloc(AssetRef effectPrefab, Vector3 position, float duration)
        {
            if (Instance == null)
            {
                return -1;
            }

            return Instance.AllocInternal(
                effectPrefab.Asset as GameObject, position, Quaternion.identity, 1f, duration);
        }

        // RVA: 0x13FB1B4
        public static int Alloc(GameObject effectPrefab, Vector3 position, float duration)
        {
            if (Instance == null)
            {
                return -1;
            }

            return Instance.AllocInternal(
                effectPrefab, position, Quaternion.identity, 1f, duration);
        }

        // RVA: 0x13FB334
        public static int Alloc(AssetRef effectPrefab, Vector3 position, float scale, float duration)
        {
            if (Instance == null)
            {
                return -1;
            }

            return Instance.AllocInternal(
                effectPrefab.Asset as GameObject, position, Quaternion.identity, scale, duration);
        }

        // RVA: 0x13FB4E8
        public static int Alloc(GameObject effectPrefab, Vector3 position, float scale, float duration)
        {
            if (Instance == null)
            {
                return -1;
            }

            return Instance.AllocInternal(effectPrefab, position, Quaternion.identity, scale, duration);
        }

        // RVA: 0x13FB674
        public static int Alloc(
            AssetRef effectPrefab, Vector3 position, Quaternion rotation, float duration)
        {
            if (Instance == null)
            {
                return -1;
            }

            return Instance.AllocInternal(
                effectPrefab.Asset as GameObject, position, rotation, 1f, duration);
        }

        // RVA: 0x13FB800
        public static int Alloc(
            GameObject effectPrefab, Vector3 position, Quaternion rotation, float duration)
        {
            if (Instance == null)
            {
                return -1;
            }

            return Instance.AllocInternal(effectPrefab, position, rotation, 1f, duration);
        }

        // RVA: 0x13FB964
        public static int Alloc(
            AssetRef effectPrefab, Vector3 position, Quaternion rotation, float scale, float duration)
        {
            if (Instance == null)
            {
                return -1;
            }

            return Instance.AllocInternal(
                effectPrefab.Asset as GameObject, position, rotation, scale, duration);
        }

        // RVA: 0x13FBB10
        public static int Alloc(
            GameObject effectPrefab, Vector3 position, Quaternion rotation, float scale, float duration)
        {
            if (Instance == null)
            {
                return -1;
            }

            return Instance.AllocInternal(effectPrefab, position, rotation, scale, duration);
        }

        // RVA: 0x13FBC94
        public static int Alloc(AssetRef effectPrefab, Transform parent, Vector3 position, float duration)
        {
            if (Instance == null)
            {
                return -1;
            }

            return Instance.AllocInternal(
                effectPrefab.Asset as GameObject, parent, position, duration);
        }

        // RVA: 0x13FA9B8
        private int AllocInternal(GameObject effectPrefab, Transform parent, float duration)
        {
            Effect effect = GetFromCache(effectPrefab.GetInstanceID());
            if (effect == null)
            {
                effect = Create(effectPrefab);
            }

            Active(effect, parent, duration);
            return effect.uid;
        }

        // RVA: 0x13FAD50
        private int AllocInternal(
            GameObject effectPrefab, Vector3 position, Quaternion rotation, float scale, float duration)
        {
            Effect effect = GetFromCache(effectPrefab.GetInstanceID());
            if (effect == null)
            {
                effect = Create(effectPrefab);
            }

            Active(effect, position, rotation, scale, duration);
            return effect.uid;
        }

        // RVA: 0x13FBE08
        private int AllocInternal(
            GameObject effectPrefab, Transform parent, Vector3 position, float duration)
        {
            Effect effect = GetFromCache(effectPrefab.GetInstanceID());
            if (effect == null)
            {
                effect = Create(effectPrefab);
            }

            Active(effect, parent, position, duration);
            return effect.uid;
        }

        // RVA: 0x13FC288
        public static void Attach(int handle, Transform parent)
        {
            if (Instance != null)
            {
                Instance.AttachInternal(handle, parent);
            }
        }

        // RVA: 0x13FC430
        public static void Attach(
            int handle, Transform parent, Vector3 position, Quaternion rotation, float scale)
        {
            if (Instance != null)
            {
                Instance.AttachInternal(handle, parent, position, rotation, scale);
            }
        }

        // RVA: 0x13FC398
        private void AttachInternal(int handle, Transform parent)
        {
            if (m_ActiveEffects.TryGetValue(handle, out Effect effect))
            {
                effect.Attach(parent, false);
            }
        }

        // RVA: 0x13FC5B0
        private void AttachInternal(
            int handle, Transform parent, Vector3 position, Quaternion rotation, float scale)
        {
            if (m_ActiveEffects.TryGetValue(handle, out Effect effect))
            {
                effect.Attach(parent, position, rotation, scale);
            }
        }

        // RVA: 0x13EF668
        public static void Free(int handle)
        {
            if (Instance != null)
            {
                Instance.FreeInternal(handle);
            }
        }

        // RVA: 0x13FC6A4
        public void FreeInternal(int handle)
        {
            if (m_ActiveEffects.TryGetValue(handle, out Effect effect))
            {
                Deactive(effect);

                if (!PutIntoCache(effect))
                {
                    effect.Destroy();
                }
            }
        }

        // RVA: 0x13FC744
        public static void DelayFree(int handle, float delayTime = 0)
        {
            if (Instance != null)
            {
                Instance.StartCoroutine(Instance.DelayFreeInternal(handle, delayTime));
            }
        }

        // RVA: 0x13FC868
        private IEnumerator DelayFreeInternal(int handle, float delayTime)
        {
            if (!m_ActiveEffects.TryGetValue(handle, out Effect effect))
            {
                yield break;
            }

            StopEmit(effect);

            if (delayTime > 0f)
            {
                yield return new WaitForSeconds(delayTime);
            }
            else
            {
                yield return new WaitUntil(() => !effect.IsAnyParticleSystemAlive());
            }

            Deactive(effect);
            if (!PutIntoCache(effect))
            {
                effect.Destroy();
            }
        }

        // RVA: 0x13FBED4
        private Effect GetFromCache(int instanceID)
        {
            if (!m_CachedEffects.TryGetValue(instanceID, out Queue<Effect> queue))
            {
                return null;
            }

            while (queue.Count > 0)
            {
                Effect effect = queue.Dequeue();
                if (effect.IsExist())
                {
                    return effect;
                }
            }

            return null;
        }

        // RVA: 0x13FA180
        private bool PutIntoCache(Effect effect)
        {
            if (effect == null || !effect.IsExist())
            {
                return false;
            }

            if (!m_CachedEffects.TryGetValue(effect.resid, out Queue<Effect> queue))
            {
                queue = new Queue<Effect>(MAX_CACHE);
                m_CachedEffects.Add(effect.resid, queue);
            }

            if (queue.Count >= MAX_CACHE)
            {
                return false;
            }

            queue.Enqueue(effect);
            return true;
        }

        // RVA: 0x13FA078
        private Effect Create(GameObject effectPrefab)
        {
            return new Effect(effectPrefab);
        }

        // RVA: 0x13FA5EC
        private void Destroy(Effect effect)
        {
            effect.Destroy();
        }

        // RVA: 0x13FC048
        private void Active(
            Effect effect, Vector3 position, Quaternion rotation, float scale, float duration)
        {
            effect.SetActive(true);
            effect.Attach(null, position, rotation, scale);
            effect.OnActive(duration);

            m_ActiveEffects.Add(effect.uid, effect);
        }

        // RVA: 0x13FBF8C
        private void Active(Effect effect, Transform parent, float duration)
        {
            effect.SetActive(true);
            effect.Attach(parent, false);
            effect.OnActive(duration);

            m_ActiveEffects.Add(effect.uid, effect);
        }

        // RVA: 0x13FC160
        private void Active(Effect effect, Transform parent, Vector3 position, float duration)
        {
            effect.SetActive(true);
            effect.Attach(parent, position, Quaternion.identity, 1f);
            effect.OnActive(duration);

            m_ActiveEffects.Add(effect.uid, effect);
        }

        // RVA: 0x13FA0D8
        private void Deactive(Effect effect)
        {
            if (effect != null)
            {
                effect.SetActive(false);
                effect.Attach(m_CacheNode.transform, false);
                m_ActiveEffects.Remove(effect.uid);
            }
        }

        // RVA: 0x13FC924
        private void StopEmit(Effect effect)
        {
            effect.Attach(null, true);

            for (int i = 0; i < effect.ptcs.Count; i++)
            {
                effect.ptcs[i].Stop();
            }

            for (int i = 0; i < effect.trdr.Count; i++)
            {
                effect.trdr[i].emitting = false;
            }
        }

        // RVA: 0x13FCA24
        public void .ctor()
        {
        }
    }
}
