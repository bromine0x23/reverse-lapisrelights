// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ActorLipSync
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  口型数据模块：解析 StoryLipSyncData / LipData，按语音名建立索引，
//  并把时间轴位置换算为秒后交给角色的 LipSync。
// =============================================================================

using System.Collections.Generic;
using Oz.ActorModule;
using Oz.GameFramework.Runtime.Resource;
using UnityEngine;

public class ActorLipSync : Module
{
    public TextAsset LipJson;
    public List<TextAsset> LipJsons;
    public StoryLipSyncData datas;
    private Dictionary<string, List<LipSync.LipsyncData>> dic;
    private AssetRef assetRef;

    // RVA: 0x1638564
    public List<LipSync.LipsyncData> Get(string PlayVoice)
    {
        string key = PlayVoice.Substring(5);

        List<LipSync.LipsyncData> value = null;
        dic.TryGetValue(key, out value);
        return value;
    }

    // RVA: 0x16385FC
    public override void Init()
    {
        base.Init();

        if (!LipJson)
        {
            return;
        }

        datas = JsonUtility.FromJson<StoryLipSyncData>(LipJson.text);
        dic.Clear();

        foreach (DialogLipsync dialogLip in datas.dialogLip)
        {
            foreach (LipSync.LipsyncData data in dialogLip.data)
            {
                data.time *= (float)LipSync.PositionToSecond;
            }

            dic[dialogLip.PlayVoice] = dialogLip.data;
        }
    }

    // RVA: 0x163892C
    public void Init(string Path)
    {
        if (dic.Count > 0)
        {
            return;
        }

        AssetRef assetRef = ResourceManager.LoadSync(Path, typeof(LipData));
        base.Init();

        if (assetRef == null)
        {
            return;
        }

        dic.Clear();

        LipData lipData = (LipData)assetRef.Asset;
        foreach (DialogLipsync dialogLip in lipData.dialogLip)
        {
            dic[dialogLip.PlayVoice] = dialogLip.data;
        }

        ResourceManager.Unload(assetRef);
    }

    // RVA: 0x1638B70
    public void AddByPath(string Path)
    {
        AssetRef assetRef = ResourceManager.LoadSync(Path, typeof(LipData));

        if (assetRef == null)
        {
            return;
        }

        LipData lipData = (LipData)assetRef.Asset;
        foreach (DialogLipsync dialogLip in lipData.dialogLip)
        {
            dic[dialogLip.PlayVoice] = dialogLip.data;
        }

        ResourceManager.Unload(assetRef);
    }

    // RVA: 0x1638D70
    public void Init(TextAsset textAsset)
    {
        LipJson = textAsset;
        Init();
    }

    // RVA: 0x1638D80
    public void Play(Actor actor, string PlayVoice)
    {
        List<LipSync.LipsyncData> list = Get(PlayVoice);
        actor.ExpressionSystem.ExpressionAnimator.LipSyncVoice.SetData(PlayVoice, list);
    }

    // RVA: 0x1638DE4
    private void OnDisable()
    {
        if (assetRef != null)
        {
            ResourceManager.Unload(assetRef);
            assetRef = null;
        }
    }

    // RVA: 0x1638E5C
    public ActorLipSync()
    {
        dic = new Dictionary<string, List<LipSync.LipsyncData>>();
    }
}
