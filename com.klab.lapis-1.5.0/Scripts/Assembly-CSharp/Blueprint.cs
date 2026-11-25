// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Blueprint
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  剧情资源加载与场景搭建：按 ObjectRefs/AvatarCache 加载资源、构建角色、
//  收集时间线/引用对象，并驱动主时间线播放。
// =============================================================================

using System.Collections;
using System.Collections.Generic;
using Oz.ActorModule;
using Oz.GameFramework.Runtime.Resource;
using UnityEngine;

public class Blueprint : Module
{
    public Blueprint.Timing Loadtiming;
    public Blueprint.Timing Playtiming;
    public List<SceneObject> ObjectRefs;
    public List<SceneTimelineRebinder> rebinders;
    public List<int> AvatarCache;
    public string MainTimeline;
    public bool LoadComplate;

    // RVA: 0x19997F0
    public override void Init()
    {
        base.Init();

        if (Loadtiming == Timing.start)
        {
            LoadAssets();
        }
    }

    // RVA: 0x199982C
    public void LoadAssets()
    {
        if (ObjectRefs.Count <= 0 && AvatarCache.Count < 1)
        {
            CreateSceneComplete();
            return;
        }

        Kit.Lua.Loading(true);
        ResourceManager.Begin(onFinishAll, null);

        foreach (SceneObject item in ObjectRefs)
        {
            if (item.RefType == typeof(ActorRefObj).Name)
            {
                ScenarioActors.actorParam param =
                    JsonUtility.FromJson<ScenarioActors.actorParam>(item.AssetPath);
                ActorFactory factory = Kit.Actors.NewActorFactory(param);
                GameObject gameObject = factory.Product.gameObject;
                ReferenceObject referenceObject = item.BindInstance(gameObject);

                gameObject.name = item.Name;
                referenceObject.PuToScene();
                factory.Cache();
            }
            else if (!string.IsNullOrEmpty(item.AssetPath))
            {
                ResourceManager.Request(
                    item.AssetPath,
                    typeof(GameObject),
                    (blockHandle, resHandle, prefab) =>
                    {
                        GameObject gameObject = Object.Instantiate(prefab.Asset as GameObject);
                        gameObject.name = item.Name;
                        item.BindInstance(gameObject).PuToScene();
                    });
            }
        }

        foreach (int item in AvatarCache)
        {
            AvatarFactory avatarFactory =
                Kit.Lua.Invoke<int, AvatarFactory>("ActorUtil.BuildAvatarFactory", item);
            Kit.Actors.AvatarFactories[item] = avatarFactory;
            avatarFactory.Cache();
        }

        ResourceManager.End();
    }

    // RVA: 0x199A06C
    private void onFinishAll(int arg1)
    {
        foreach (ActorFactory factory in Kit.Actors.ActorFactories)
        {
            Actor actor = factory.Build(false);
            actor.Create();
            actor.MotionSystem.SetOverrideAnimatorController(Kit.Actors.DefaultController);

            ScenarioReferences references = Kit.GetModule<ScenarioReferences>();
            if (references)
            {
                ScaleSettings scaleSettings = actor.GetComponent<ActorRefObj>().param.loli
                    ? references.Scale_Loli
                    : references.Scale_Normal;
                actor.SkeletonSystem.SetScale(scaleSettings);
            }

            actor.GetComponentInChildren<HeelUpdate>().enabled = false;
        }

        foreach (SceneObject item in ObjectRefs)
        {
            if (string.IsNullOrEmpty(item.AssetPath))
            {
                GameObject sceneInstance = item.GetSceneInstance();
                if (sceneInstance)
                {
                    item.BindInstance(sceneInstance);
                }
            }
        }

        ReferenceRoot.Instance.CollectRefrence();
        Kit.Lua.Loading(false);
        CreateSceneComplete();
    }

    // RVA: 0x1999E34
    public void CreateSceneComplete()
    {
        List<SceneTimelineRebinder> list = new List<SceneTimelineRebinder>(rebinders);
        list.RemoveAll(e => e == null);

        foreach (SceneTimelineRebinder item in list)
        {
            item.Rebind();
        }

        LoadComplate = true;
        Kit.Events.LoadAssetsComplate.Dispatch(null);

        if (Playtiming == Timing.start)
        {
            StartCoroutine(waitOneFrame());
        }
    }

    // RVA: 0x199A55C
    private IEnumerator waitOneFrame()
    {
        yield return null;
        Play(null);
    }

    // RVA: 0x199A5CC
    public void CollectTimeLine()
    {
        rebinders = new List<SceneTimelineRebinder>(
            Object.FindObjectsOfType<SceneTimelineRebinder>());
    }

    // RVA: 0x199A678
    public void CollectRefObject()
    {
        ReferenceRoot.Instance.CollectRefrence();
        ObjectRefs = new List<SceneObject>();

        for (int i = 0; i < ReferenceRoot.Instance.Refrences.Count; i++)
        {
            ReferenceObject referenceObject = ReferenceRoot.Instance.Refrences[i];
            referenceObject.SetSceneData();
            ObjectRefs.Add(referenceObject.Data);
        }

        ObjectRefs.Sort((l, r) =>
        {
            if (string.IsNullOrEmpty(l.AssetPath))
            {
                return string.IsNullOrEmpty(r.AssetPath) ? 0 : 1;
            }
            return string.IsNullOrEmpty(r.AssetPath) ? -1 : 0;
        });
    }

    // RVA: 0x199A8D8
    public void Play(string saveData)
    {
        if (!LoadComplate)
        {
            return;
        }

        ReferenceRoot.Instance.CollectRefrence();

        if (!string.IsNullOrEmpty(saveData) && Kit.saveLoad.Load(saveData))
        {
            return;
        }

        Kit.Timelines.GetTimeline(MainTimeline).director.Play();
    }

    // RVA: 0x199A9E4
    public List<ScenarioSaveLoadStringData> LoadRecords(string JsonData)
    {
        if (!LoadComplate)
        {
            return null;
        }

        return Kit.saveLoad.GetSaveString(JsonData);
    }

    // RVA: 0x199AA40
    public void Save()
    {
        Kit.saveLoad.Save();
    }

    // RVA: 0x199AA74
    public Blueprint()
    {
        ObjectRefs = new List<SceneObject>();
        rebinders = new List<SceneTimelineRebinder>();
        AvatarCache = new List<int>();
        MainTimeline = "Main";
    }

    public enum Timing
    {
        start = 0,
        custom = 1
    }
}
