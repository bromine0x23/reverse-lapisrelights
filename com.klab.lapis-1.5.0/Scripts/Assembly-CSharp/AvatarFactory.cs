// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  AvatarFactory
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  AvatarSetting 资源加载、构建 AvatarPart 与释放。
// =============================================================================

using Oz.ActorModule;
using Oz.GameFramework.Runtime.Resource;

public class AvatarFactory
{
    private string m_AvatarSettingPath;

    public AssetRef AvatarSetting { get; private set; }

    // RVA: 0x198CAA0
    public AvatarFactory(string avatarSettingPath)
    {
        m_AvatarSettingPath = avatarSettingPath;
    }

    // RVA: 0x198CACC
    public void CacheSync()
    {
        AvatarSetting = ResourceManager.LoadSync(m_AvatarSettingPath, typeof(AvatarSetting));
    }

    // RVA: 0x198CB8C
    public void Cache()
    {
        ResourceManager.Request(m_AvatarSettingPath, typeof(AvatarSetting), OnComplete);
    }

    // RVA: 0x198CC7C
    private void OnComplete(int groupHandle, int nodeHandle, AssetRef assetRef)
    {
        AvatarSetting = assetRef;
    }

    // RVA: 0x198CC84
    public AvatarPart Build(bool needBoneAdjust = false)
    {
        return AvatarPart.Build((AvatarSetting)AvatarSetting.Asset, needBoneAdjust);
    }

    // RVA: 0x198CD24
    public void Purge()
    {
        ResourceManager.Unload(AvatarSetting);
        AvatarSetting = null;
    }
}
