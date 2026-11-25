// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ScenarioKit
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  剧情场景模块总入口：初始化、销毁各子模块并提供单例。
// =============================================================================

using Oz.Framework;
using UnityEngine;

public class ScenarioKit : ModuleManager
{
    private static ScenarioKit _instance;

    public Blueprint Blueprint;
    public ScenarioUI UI;
    public ScenarioEvents Events;
    public ScenarioCamera Cameras;
    public ScenarioActors Actors;
    public ScenarioTimelines Timelines;
    public ScenarioLua Lua;
    public ScenarioSounds Sounds;
    public SceneObjects Objects;
    public SceneManualItem manualItem;
    public ScenarioLanguage Language;
    public ScenarioSaveLoad saveLoad;

    public static ScenarioKit Instance
    {
        // RVA: 0x1B79AF8
        get
        {
            if (_instance == null)
            {
                _instance = Object.FindObjectOfType<ScenarioKit>();
            }
            return _instance;
        }
        // RVA: 0x1B7FFD4
        set
        {
            _instance = value;
        }
    }

    // RVA: 0x1B80028
    public override void Init()
    {
        base.Init();
        Lua = InitModule(Lua);
        Events = InitModule(Events);
        manualItem = InitModule(manualItem);
        Objects = InitModule(Objects);
        Cameras = InitModule(Cameras);
        Language = InitModule(Language);
        UI = InitModule(UI);
        Actors = InitModule(Actors);
        Sounds = InitModule(Sounds);
        Timelines = InitModule(Timelines);
        saveLoad = InitModule(saveLoad);
        Blueprint = InitModule(Blueprint);
    }

    // RVA: 0x1B801C4
    private void Start()
    {
        if (Instance == null)
        {
            _instance = this;
        }
        Init();
    }

    // RVA: 0x1B80288
    private void OnDestroy()
    {
        base.Dispose();
        Blueprint.Dispose();
        UI.Dispose();
        Cameras.Dispose();
        Actors.Dispose();
        Sounds.Dispose();
        Timelines.Dispose();
        Lua.Dispose();
        Language.Dispose();
        saveLoad.Dispose();
        Events.Dispose();
        _instance = null;
    }

    // RVA: 0x1B803B4
    public static bool IsScenarioEditMode()
    {
        return Launcher.Instance is EditorEnviroment;
    }

    // RVA: 0x1B80498
    public ScenarioKit()
    {
    }
}
