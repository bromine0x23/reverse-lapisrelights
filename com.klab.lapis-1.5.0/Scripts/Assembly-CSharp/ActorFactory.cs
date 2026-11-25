// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ActorFactory
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  角色装配：同步/异步加载骨骼、Avatar、表情、口型、交互资源，
//  构建 Actor 并把 InteractSetting 绑定到角色实例。
// =============================================================================

using System.Collections.Generic;
using Oz.ActorModule;
using Oz.GameFramework.Runtime.Resource;
using UnityEngine;

public class ActorFactory
{
    public Actor Product { get; private set; }
    private string m_SkeletonPrefabPath;
    private string m_ScaleSettingsPath;
    private List<AvatarFactory> m_AvatarFactories;
    private MotionFactory m_MotionFactory;
    private string m_FacialSettingsPath;
    private string m_EyeSettingPath;
    private string m_VowelSettingsPath;
    private string m_ExpressionEffectSettingsPath;
    private string m_InteractSettingPath;
    public AssetRef SkeletonPrefab { get; private set; }
    public AssetRef ScaleSettings { get; private set; }
    public AssetRef FacialSettings { get; private set; }
    public AssetRef EyeSettings { get; private set; }
    public AssetRef VowelSetting { get; private set; }
    public AssetRef ExpressionEffectSettings { get; private set; }
    public AssetRef InteractSetting { get; private set; }

    // RVA: 0x163548C
    public ActorFactory(
        string name,
        string skeletonPrefabPath,
        string scaleSettingsPath,
        string[] avatarSettingsPath,
        string animationControllerPath,
        string facialSettingsPath,
        string eyeSettingPath,
        string vowelSettingsPath,
        string expressionEffectSettingsPath,
        string interactSettingPath)
    {
        m_SkeletonPrefabPath = skeletonPrefabPath;
        m_ScaleSettingsPath = scaleSettingsPath;
        m_AvatarFactories = new List<AvatarFactory>();

        foreach (string path in avatarSettingsPath)
        {
            m_AvatarFactories.Add(new AvatarFactory(path));
        }

        m_MotionFactory = new MotionFactory(animationControllerPath);
        m_FacialSettingsPath = facialSettingsPath;
        m_EyeSettingPath = eyeSettingPath;
        m_VowelSettingsPath = vowelSettingsPath;
        m_ExpressionEffectSettingsPath = expressionEffectSettingsPath;
        m_InteractSettingPath = interactSettingPath;

        Product = new GameObject(name).AddComponent<Actor>();
    }

    // RVA: 0x163564C
    public void ApplyOverride(string originalClip, string overrideClip)
    {
        m_MotionFactory.ApplyOverride(originalClip, overrideClip);
    }

    // RVA: 0x1635668
    public void CacheSync()
    {
        SkeletonPrefab = ResourceManager.LoadSync(m_SkeletonPrefabPath, typeof(GameObject));
        ScaleSettings = ResourceManager.LoadSync(m_ScaleSettingsPath, typeof(ScaleSettings));

        foreach (AvatarFactory factory in m_AvatarFactories)
        {
            factory.CacheSync();
        }

        m_MotionFactory.CacheSync();

        FacialSettings = ResourceManager.LoadSync(m_FacialSettingsPath, typeof(FacialSettings));
        EyeSettings = ResourceManager.LoadSync(m_EyeSettingPath, typeof(EyeSettings));
        VowelSetting = ResourceManager.LoadSync(m_VowelSettingsPath, typeof(VowelSetting));
        ExpressionEffectSettings = ResourceManager.LoadSync(
            m_ExpressionEffectSettingsPath,
            typeof(ExpressionEffectSettings));

        if (!string.IsNullOrEmpty(m_InteractSettingPath))
        {
            InteractSetting = ResourceManager.LoadSync(m_InteractSettingPath, typeof(InteractSetting));
        }
    }

    // RVA: 0x1635928
    public void Cache()
    {
        if (!string.IsNullOrEmpty(m_SkeletonPrefabPath))
        {
            ResourceManager.Request(
                m_SkeletonPrefabPath,
                typeof(GameObject),
                (blockHandle, resHandle, assetRef) => SkeletonPrefab = assetRef);
        }

        if (!string.IsNullOrEmpty(m_ScaleSettingsPath))
        {
            ResourceManager.Request(
                m_ScaleSettingsPath,
                typeof(ScaleSettings),
                (blockHandle, resHandle, assetRef) => ScaleSettings = assetRef);
        }

        foreach (AvatarFactory factory in m_AvatarFactories)
        {
            factory.Cache();
        }

        m_MotionFactory.Cache();

        if (!string.IsNullOrEmpty(m_FacialSettingsPath))
        {
            ResourceManager.Request(
                m_FacialSettingsPath,
                typeof(FacialSettings),
                (blockHandle, resHandle, assetRef) => FacialSettings = assetRef);
        }

        if (!string.IsNullOrEmpty(m_EyeSettingPath))
        {
            ResourceManager.Request(
                m_EyeSettingPath,
                typeof(EyeSettings),
                (blockHandle, resHandle, assetRef) => EyeSettings = assetRef);
        }

        if (!string.IsNullOrEmpty(m_VowelSettingsPath))
        {
            ResourceManager.Request(
                m_VowelSettingsPath,
                typeof(VowelSetting),
                (blockHandle, resHandle, assetRef) => VowelSetting = assetRef);
        }

        if (!string.IsNullOrEmpty(m_ExpressionEffectSettingsPath))
        {
            ResourceManager.Request(
                m_ExpressionEffectSettingsPath,
                typeof(ExpressionEffectSettings),
                (blockHandle, resHandle, assetRef) => ExpressionEffectSettings = assetRef);
        }

        if (!string.IsNullOrEmpty(m_InteractSettingPath))
        {
            ResourceManager.Request(
                m_InteractSettingPath,
                typeof(InteractSetting),
                (blockHandle, resHandle, assetRef) => InteractSetting = assetRef);
        }
    }

    // RVA: 0x1635F04
    public Actor Build(bool needBoneAdjust = false)
    {
        AvatarPart[] avatars = new AvatarPart[m_AvatarFactories.Count];
        for (int i = 0; i < m_AvatarFactories.Count; i++)
        {
            avatars[i] = m_AvatarFactories[i].Build(needBoneAdjust);
        }

        MotionController controller = m_MotionFactory.Build();

        Product.Init(
            SkeletonPrefab.Asset as GameObject,
            ScaleSettings.Asset as ScaleSettings,
            avatars,
            controller,
            FacialSettings.Asset as FacialSettings,
            EyeSettings.Asset as EyeSettings,
            VowelSetting.Asset as VowelSetting,
            ExpressionEffectSettings.Asset as ExpressionEffectSettings);

        if (InteractSetting != null)
        {
            Product.InteractSettingFile = InteractSetting.Asset as InteractSetting;
        }

        return Product;
    }

    // RVA: 0x1636264
    public void Purge()
    {
        if (SkeletonPrefab != null)
        {
            ResourceManager.Unload(SkeletonPrefab);
            SkeletonPrefab = null;
        }

        if (ScaleSettings != null)
        {
            ResourceManager.Unload(ScaleSettings);
            ScaleSettings = null;
        }

        foreach (AvatarFactory factory in m_AvatarFactories)
        {
            factory.Purge();
        }
        m_AvatarFactories.Clear();

        m_MotionFactory.Purge();
        m_MotionFactory = null;

        if (FacialSettings != null)
        {
            ResourceManager.Unload(FacialSettings);
            FacialSettings = null;
        }

        if (EyeSettings != null)
        {
            ResourceManager.Unload(EyeSettings);
            EyeSettings = null;
        }

        if (VowelSetting != null)
        {
            ResourceManager.Unload(VowelSetting);
            VowelSetting = null;
        }

        if (ExpressionEffectSettings != null)
        {
            ResourceManager.Unload(ExpressionEffectSettings);
            ExpressionEffectSettings = null;
        }

        if (InteractSetting != null)
        {
            ResourceManager.Unload(InteractSetting);
            InteractSetting = null;
        }
    }

    // RVA: 0x16364B0
    public static InteractSetting GetInteractSetting(string interactSettingPath)
    {
        AssetRef assetRef = ResourceManager.LoadSync(interactSettingPath, typeof(InteractSetting));
        if (assetRef == null)
        {
            return null;
        }
        return assetRef.Asset as InteractSetting;
    }
}
