// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  MotionFactory
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  AnimatorController 与动画片段覆盖的加载、构建 MotionController 与释放。
// =============================================================================

using System.Collections.Generic;
using Oz.ActorModule;
using Oz.GameFramework.Runtime.Resource;
using UnityEngine;

public class MotionFactory
{
    public AssetRef RuntimeAnimatorController { get; private set; }
    public Dictionary<string, AssetRef> OverrideClips { get; private set; }
    private string m_AnimationControllerPath;
    private List<OverrideInfo> m_OverrideInfos;

    // RVA: 0x169CCC4
    public MotionFactory(string animationControllerPath)
    {
        m_AnimationControllerPath = animationControllerPath;
        m_OverrideInfos = new List<OverrideInfo>();
        OverrideClips = new Dictionary<string, AssetRef>();
    }

    // RVA: 0x169CD70
    public void ApplyOverride(string originalClip, string overrideClip)
    {
        m_OverrideInfos.Add(new OverrideInfo(originalClip, overrideClip));
    }

    // RVA: 0x169CE04
    public void CacheSync()
    {
        RuntimeAnimatorController = ResourceManager.LoadSync(
            m_AnimationControllerPath,
            typeof(RuntimeAnimatorController));

        foreach (OverrideInfo info in m_OverrideInfos)
        {
            if (!string.IsNullOrEmpty(info.originClip) && !string.IsNullOrEmpty(info.overrideClip))
            {
                OverrideClips[info.originClip] = ResourceManager.LoadSync(
                    info.overrideClip,
                    typeof(AnimationClip));
            }
        }
    }

    // RVA: 0x169CFF8
    public void Cache()
    {
        if (!string.IsNullOrEmpty(m_AnimationControllerPath))
        {
            ResourceManager.Request(
                m_AnimationControllerPath,
                typeof(RuntimeAnimatorController),
                (groupHandle, nodeHandle, assetRef) => RuntimeAnimatorController = assetRef);
        }

        foreach (OverrideInfo info in m_OverrideInfos)
        {
            if (string.IsNullOrEmpty(info.originClip) || string.IsNullOrEmpty(info.overrideClip))
            {
                continue;
            }

            string originClipName = info.originClip;
            ResourceManager.Request(
                info.overrideClip,
                typeof(AnimationClip),
                (groupHandle, nodeHandle, assetRef) => OverrideClips.Add(originClipName, assetRef));
        }
    }

    // RVA: 0x169D2D4
    public MotionController Build()
    {
        return new MotionController(
            (RuntimeAnimatorController)RuntimeAnimatorController.Asset,
            OverrideClips);
    }

    // RVA: 0x169D398
    public void Purge()
    {
        ResourceManager.Unload(RuntimeAnimatorController);
        RuntimeAnimatorController = null;

        foreach (AssetRef assetRef in OverrideClips.Values)
        {
            ResourceManager.Unload(assetRef);
        }
        OverrideClips.Clear();
    }
}
