// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  EditorEnviroment
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  编辑器模式启动器：确保 Wwise/LuaManager 组件存在，并加载编辑器 Lua 入口。
// =============================================================================

using LuaInterface;
using Oz.Framework;
using Oz.Framework.LuaModule;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.Timeline;

[ExecuteInEditMode]
public class EditorEnviroment : Launcher
{
    public ScenarioFramework CurrentFramework;
    public RuntimeAnimatorController controller;
    public GameObject TimelinePrefab;
    public TimelineAsset DefaultNewTimeLineAsset;
    private bool soundStart;

    // RVA: 0x1745A7C
    public void Awake()
    {
        if (Launcher.Instance == null)
        {
            Launcher.Instance = this;
        }

        if (!gameObject.GetComponent<AkInitializer>())
        {
            gameObject.AddComponent<AkInitializer>();
        }

        LuaMgr = GetComponent<LuaManager>();
        if (!LuaMgr)
        {
            LuaMgr = gameObject.AddComponent<LuaManager>();
        }

        if (GameObject.Find("OzWwiseGlobal") == null)
        {
            soundStart = true;
        }

        if (Application.isPlaying)
        {
            StartLua();
        }
    }

    // RVA: 0x1745E18
    private void changeSceneEditorMode(Scene arg0, Scene arg1)
    {
    }

    // RVA: 0x1745D14
    public void StartLua()
    {
        LuaMgr.luaState.Start();
        LuaMgr.luaState.AddSearchPath(
            Application.dataPath + "/Products/ScenarioKit/EditorTools",
            false);
        LuaMgr.luaState.DoFile("EditorLuaMain.lua");

        LuaFunction function = LuaMgr.luaState.GetFunction("Main", true);
        function.Call();
        function.Dispose();
    }

    // RVA: 0x1745E1C
    public void Start()
    {
        if (soundStart)
        {
            if (!gameObject.GetComponent<AkAudioListener>())
            {
                gameObject.AddComponent<AkAudioListener>();
            }
            soundStart = false;
        }

        if (!Application.isPlaying)
        {
            if (LuaMgr.luaState == null)
            {
                LuaMgr.Awake();
                StartLua();
            }
        }
    }

    // RVA: 0x1745F50
    private void OnDestroy()
    {
        if (LuaMgr.luaState != null)
        {
            LuaMgr.luaState.Dispose();
            LuaMgr.luaState = null;
        }
    }

    // RVA: 0x174608C
    public EditorEnviroment()
    {
    }
}
