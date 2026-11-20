// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.ExpressionEffector
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + IDA 反汇编核对
//        0x13EF380: GetBone(data.Dummy)        0x13EF450: Request(data.PrefabPath)
//        0x13EF3D8: cache 以 name 为键（与 lambda 中 Add(name, prefab) 一致）
// =============================================================================

using System.Collections.Generic;
using Oz.Framework.EffectModule;
using Oz.GameFramework.Runtime.Resource;
using UnityEngine;

namespace Oz.ActorModule
{
    public class ExpressionEffector : MonoBehaviour
    {
        private SkeletonSystem m_SkeletonSystem;
        private string m_Current;
        private StringExpressionEffectDataDictionary m_DictExpressionEffectSettings;
        private int m_hActiveEffect;
        private int m_requestHandle;
        private Dictionary<string, AssetRef> m_cacheRef;

        // RVA: 0x13EEEE0
        public void Init(SkeletonSystem skeletonSystem, ExpressionEffectSettings settings)
        {
            m_SkeletonSystem = skeletonSystem;
            m_DictExpressionEffectSettings = new StringExpressionEffectDataDictionary();
            m_requestHandle = -1;
            m_cacheRef = new Dictionary<string, AssetRef>();

            if (settings != null && settings.effects != null)
            {
                for (int i = 0; i < settings.effects.Count; i++)
                {
                    ExpressionEffectData data = settings.effects[i];
                    if (data != null && !m_DictExpressionEffectSettings.ContainsKey(data.Name))
                    {
                        m_DictExpressionEffectSettings.Add(data.Name, data);
                    }
                }
            }
        }

        // RVA: 0x13EF098
        private void OnDestroy()
        {
            Stop();

            foreach (AssetRef assetRef in m_cacheRef.Values)
            {
                if (assetRef != null)
                {
                    ResourceManager.Unload(assetRef);
                }
            }
            m_cacheRef.Clear();
        }

        // RVA: 0x13EF298
        public void Play(string name)
        {
            if (m_Current == name)
            {
                return;
            }

            Stop();

            ExpressionEffectData data;
            if (!m_DictExpressionEffectSettings.TryGetValue(name, out data))
            {
                return;
            }

            Transform dummyNode = m_SkeletonSystem.GetBone(data.Dummy);
            if (dummyNode != null)
            {
                AssetRef prefab;
                if (m_cacheRef.TryGetValue(name, out prefab))
                {
                    m_hActiveEffect = EffectManager.Alloc(prefab, dummyNode, -1f);
                }
                else
                {
                    m_requestHandle = ResourceManager.Begin(null, null);
                    ResourceManager.Request(data.PrefabPath, typeof(GameObject),
                        (blockHandle, resHandle, loadedPrefab) =>
                        {
                            m_hActiveEffect = EffectManager.Alloc(loadedPrefab, dummyNode, -1f);
                            m_requestHandle = -1;
                            m_cacheRef.Add(name, loadedPrefab);
                        });
                    ResourceManager.End();
                }
            }

            m_Current = name;
        }

        // RVA: 0x13EF1E8
        public void Stop()
        {
            if (m_requestHandle != -1)
            {
                ResourceManager.Cancel(m_requestHandle);
                m_requestHandle = -1;
            }

            if (m_hActiveEffect != -1)
            {
                EffectManager.Free(m_hActiveEffect);
                m_hActiveEffect = -1;
            }

            m_Current = string.Empty;
        }

        // RVA: 0x13EF764
        private void OnAnimationEvent(Object data)
        {
            ExpressionEffectEventData eventData = data as ExpressionEffectEventData;
            if (eventData == null)
            {
                return;
            }

            if (string.IsNullOrEmpty(eventData.effectName))
            {
                Stop();
            }
            else
            {
                Play(eventData.effectName);
            }
        }

        // RVA: 0x13EF868
        public ExpressionEffector()
        {
        }
    }
}
