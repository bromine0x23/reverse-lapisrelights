// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  VoiceVowel
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  将元音权重叠加到面部 BlendShape；剩余权重分配给普通口型列表。
// =============================================================================

using System.Collections.Generic;
using Oz.ActorModule;
using UnityEngine;

public class VoiceVowel
{
    private SkinnedMeshRenderer m_MeshFace;
    private Dictionary<Vowel, VowelData> m_VowelSetting;
    private List<VoiceVowel.VowelInfo> m_VowelInfoList;
    private BlendShapeHandle[] m_MouthMeshList;

    // RVA: 0x2C734D0
    public VoiceVowel(SkinnedMeshRenderer mesh, BlendShapeHandle[] mouthMeshList, VowelSetting vowelSetting)
    {
        m_VowelInfoList = new List<VowelInfo>();
        m_MeshFace = mesh;
        m_VowelSetting = new Dictionary<Vowel, VowelData>();
        m_MouthMeshList = mouthMeshList;
        for (int i = 0; i < vowelSetting.VowelData.Count; i++)
        {
            VowelData data = vowelSetting.VowelData[i];
            m_VowelSetting.Add(data.Vowel, data);
        }
    }

    // RVA: 0x2C735F8
    public void ResetVowelInfo()
    {
        m_VowelInfoList.Clear();
    }

    // RVA: 0x2C73650
    public void SetVowelWeight(Vowel vowel, float weight)
    {
        m_VowelInfoList.Add(new VowelInfo
        {
            vowel = vowel,
            weight = weight
        });
    }

    // RVA: 0x2C736CC
    public void OnVoiceUpdate(BlendWeight[] mouthList)
    {
        if (m_VowelInfoList.Count < 1)
        {
            return;
        }

        ResetVowel();

        float remain = 1f;
        foreach (VowelInfo info in m_VowelInfoList)
        {
            remain -= info.weight;
            VowelData data;
            if (!m_VowelSetting.TryGetValue(info.vowel, out data))
            {
                continue;
            }
            foreach (VowelBlendData blend in data.BlendData)
            {
                float weight = m_MeshFace.GetBlendShapeWeight(blend.ShapeIndex);
                m_MeshFace.SetBlendShapeWeight(blend.ShapeIndex, weight + info.weight * blend.BlendValue);
            }
        }

        if (mouthList == null || remain <= 0f || mouthList.Length < 1)
        {
            return;
        }

        for (int i = 0; i < mouthList.Length; i++)
        {
            BlendWeight blend = mouthList[i];
            float weight = m_MeshFace.GetBlendShapeWeight(blend.Handle.ShapeIndex);
            m_MeshFace.SetBlendShapeWeight(blend.Handle.ShapeIndex, weight + remain * blend.Weight);
        }
    }

    // RVA: 0x2C73A50
    public void ResetVowel()
    {
        for (int i = 0; i < m_MouthMeshList.Length; i++)
        {
            if (m_MeshFace.sharedMesh != null)
            {
                m_MeshFace.SetBlendShapeWeight(m_MouthMeshList[i].ShapeIndex, 0f);
            }
        }
    }

    private struct VowelInfo
    {
        public Vowel vowel;
        public float weight;
    }
}
