// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.LuaModule.LuaManager
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using System.Text;
using System.IO;
using UnityEngine.Networking;
using UnityEngine.SceneManagement;
using Oz.GameFramework.Runtime.Resource;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Oz.Framework.LuaModule
{
    public class LuaManager : MonoBehaviour
    {
        protected LuaLooper loop;
        private LuaTable profiler;
        private static LuaManager Instance { get; set; }
        public LuaState luaState { get; set; }
        public string LuaDesKey { get; set; }







        // RVA: 0x1401334
        public void Awake()
        {
            if (Instance == null)
            {
                Instance = this;
            }

            LuaClassMonitor.Clear();
            InitLoader();

            luaState = new LuaState();
            OpenLibs();
            luaState.LuaSetTop(0);
            Bind();
        }

        // RVA: 0x14014A0
        private void Start()
        {
            SceneManager.sceneLoaded += OnSceneLoaded;
            SceneManager.sceneUnloaded += OnSceneUnloaded;
        }

        // RVA: 0x140157C
        private IEnumerator GetCommonKey()
        {
            string path = Path.Combine(Application.streamingAssetsPath, "icon-show.png");
            Uri uri = new Uri(path);

            using (UnityWebRequest request = UnityWebRequest.Get(uri.AbsoluteUri))
            {
                yield return request.SendWebRequest();

                if (!request.isNetworkError && !request.isHttpError)
                {
                    LuaDesKey = ReadKeyFromPic(request.downloadHandler.data);
                }
            }
        }

        // RVA: 0x1401618
        private string ReadKeyFromPic(byte[] images)
        {
            Texture2D texture = new Texture2D(300, 300, TextureFormat.RGBA32, false);
            texture.LoadImage(images);

            Color32[] pixels = texture.GetPixels32();
            int step = pixels.Length / 10;

            StringBuilder builder = new StringBuilder();
            for (int i = 0; i < 10; i++)
            {
                builder.Append(pixels[i * step].r.ToString());
            }

            return builder.ToString();
        }

        // RVA: 0x140175C
        private void OnDestroy()
        {
            SceneManager.sceneUnloaded -= OnSceneUnloaded;
            SceneManager.sceneLoaded -= OnSceneLoaded;

            if (luaState != null)
            {
                luaState.Call("OnApplicationQuit", false);
                DetachProfiler();

                LuaState state = luaState;
                luaState = null;

                if (loop != null)
                {
                    loop.Destroy();
                    loop = null;
                }

                state.Dispose();
            }

            LuaClassMonitor.Clear();

            if (Instance != null)
            {
                Instance = null;
            }
        }

        // RVA: 0x1401A90
        protected virtual LuaFileUtils InitLoader()
        {
            if (LuaFileUtils.instance != null)
            {
                return LuaFileUtils.instance;
            }

            return new LuaResLoader();
        }

        // RVA: 0x1401BB4
        protected virtual void OpenLibs()
        {
            luaState.OpenLibs(LuaDLL.luaopen_pb);
            luaState.OpenLibs(LuaDLL.luaopen_struct);
            luaState.OpenLibs(LuaDLL.luaopen_lpeg);

            if (LuaConst.openLuaSocket)
            {
                OpenLuaSocket();
            }

            if (LuaConst.openLuaDebugger)
            {
                OpenZbsDebugger("localhost");
            }

            OpenCJson();
        }

        // RVA: 0x14011A0
        private static int LuaOpen_Socket_Core(IntPtr L)
        {
            return LuaDLL.luaopen_socket_core(L);
        }

        // RVA: 0x1401208
        private static int LuaOpen_Mime_Core(IntPtr L)
        {
            return LuaDLL.luaopen_mime_core(L);
        }

        // RVA: 0x1401D34
        protected void OpenLuaSocket()
        {
            LuaConst.openLuaSocket = true;

            luaState.BeginPreLoad();
            luaState.RegFunction("socket.core", LuaOpen_Socket_Core);
            luaState.RegFunction("mime.core", LuaOpen_Mime_Core);
            luaState.EndPreLoad();
        }

        // RVA: 0x1402000
        protected void OpenCJson()
        {
            luaState.LuaGetField(LuaIndexes.LUA_REGISTRYINDEX, "_LOADED");
            luaState.OpenLibs(LuaDLL.luaopen_cjson);
            luaState.LuaSetField(-2, "cjson");

            luaState.OpenLibs(LuaDLL.luaopen_cjson_safe);
            luaState.LuaSetField(-2, "cjson.safe");
        }

        // RVA: 0x1401E64
        public void OpenZbsDebugger(string ip = "localhost")
        {
            if (!Directory.Exists(LuaConst.zbsDir))
            {
                Debugger.LogWarning("ZeroBraneStudio not install or LuaConst.zbsDir not right");
                return;
            }

            if (!LuaConst.openLuaSocket)
            {
                OpenLuaSocket();
            }

            if (!string.IsNullOrEmpty(LuaConst.zbsDir))
            {
                luaState.AddSearchPath(LuaConst.zbsDir, false);
            }

            luaState.LuaDoString(
                string.Format("DebugServerIp = '{0}'", ip), "@LuaClient.cs");
        }

        // RVA: 0x1402154
        protected virtual void Bind()
        {
            LuaBinder.Bind(luaState);
            DelegateFactory.Init();
            LuaCoroutine.Register(luaState, this);
        }

        // RVA: 0x14003D0
        public IEnumerator StartMain()
        {
            yield return GetCommonKey();

            luaState.Start();
            StartLooper();
            luaState.DoFile("Main.lua");
            CallMain();
        }

        // RVA: 0x1402224
        protected void StartLooper()
        {
            loop = gameObject.AddComponent<LuaLooper>();
            loop.luaState = luaState;
        }

        // RVA: 0x1402298
        protected virtual void CallMain()
        {
            LuaFunction function = luaState.GetFunction("Main", true);
            function.Call();
            function.Dispose();
        }

        // RVA: 0x1402318
        private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
        {
            if (luaState != null)
            {
                LuaFunction function = luaState.GetFunction("OnSceneLoaded", true);
                if (function != null)
                {
                    function.Call();
                    function.Dispose();
                }
            }

            Launcher.Instance.BackKeyProcess.ForceClose();
        }

        // RVA: 0x14024FC
        private void OnSceneUnloaded(Scene scene)
        {
            if (luaState != null)
            {
                luaState.RefreshDelegateMap();
                luaState.LuaGC(LuaGCOptions.LUA_GCCOLLECT, 0);
                ResourceManager.UnloadAll(false);
                Resources.UnloadUnusedAssets();

                LuaFunction function = luaState.GetFunction("OnSceneUnloaded", true);
                if (function != null)
                {
                    function.Call();
                    function.Dispose();
                }
            }

            Launcher.Instance.BackKeyProcess.ForceClose();
        }

        // RVA: 0x140273C
        public static void DoString(string chunk)
        {
            if (Instance != null)
            {
                Instance.luaState.DoString(chunk, "LuaState.cs");
            }
        }

        // RVA: 0x1402850
        public void AttachProfiler()
        {
            if (profiler == null)
            {
                profiler = luaState.Require<LuaTable>("UnityEngine.Profiler");
                profiler.Call("start", profiler);
            }
        }

        // RVA: 0x14019CC
        public void DetachProfiler()
        {
            if (profiler != null)
            {
                profiler.Call("stop", profiler);
                profiler.Dispose();
                LuaProfiler.Clear();
            }
        }

        // RVA: 0x14028FC
        public void .ctor()
        {
        }
    }
}
