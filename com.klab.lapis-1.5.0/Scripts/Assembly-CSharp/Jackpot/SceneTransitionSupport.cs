// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.SceneTransitionSupport
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Jackpot
{
    public static class SceneTransitionSupport
    {
        private const string SceneParameterPrefix = "SceneTransitionSupport.Scene.";
        private const string PrevSceneKey = "SceneTransitionSupport.PrevScene";
        private const string PrevSceneNameKey = "SceneTransitionSupport.PrevSceneName";

        // RVA: 0x1EA18C0
        [Extension]
        public static void ChangeScene(ISceneTransitionSupport self, string sceneName, IMemory parameter)
        {
                        ChangeSceneCore(sceneName, parameter);
        }

        // RVA: 0x1EA194C
        [Extension]
        public static AsyncOperation ChangeSceneAsync(ISceneTransitionSupport self, string sceneName, IMemory parameter)
        {
                        return ChangeSceneAsyncCore(sceneName, parameter);
        }

        // RVA: 0x1EA19D8
        [Extension]
        public static IMemory GetSceneParameter(ISceneTransitionSupport self, string sceneName)
        {
                        return GetSceneParameterCore(sceneName);
        }

        // RVA: 0x1EA1AF4
        [Extension]
        public static void StoreSceneParameter(ISceneTransitionSupport self, string sceneName, IMemory parameter)
        {
                        StoreSceneParameterCore(sceneName, parameter);
        }

        // RVA: 0x1EA1D44
        [Extension]
        public static void DeleteSceneParameter(ISceneTransitionSupport self, string sceneName)
        {
                        if (string.IsNullOrEmpty(sceneName))
                        {
                            sceneName = SceneManager.GetActiveScene().name;
                        }

                        ApplicationCache.Instance.Remove(SceneParameterKey(sceneName));
        }

        // RVA: 0x1EA1E84
        [Extension]
        public static string GetPrevSceneName(ISceneTransitionSupport self)
        {
                        return GetSceneParameterCore(null).Get<string>("SceneTransitionSupport.PrevSceneName");
        }

        // RVA: 0x1EA1FBC
        [Extension]
        public static int GetPrevScene(ISceneTransitionSupport self)
        {
                        return GetSceneParameterCore(null).Get<int>("SceneTransitionSupport.PrevScene");
        }

        [Extension]
        public static void ChangeScene<TParam>(ISceneTransitionSupport self, string sceneName, TParam parameter) where TParam : IMemory
        {
            ChangeSceneCore(sceneName, parameter);
        }

        [Extension]
        public static AsyncOperation ChangeSceneAsync<TParam>(ISceneTransitionSupport self, string sceneName, TParam parameter) where TParam : IMemory
        {
            return ChangeSceneAsyncCore(sceneName, parameter);
        }

        [Extension]
        public static TParam GetSceneParameter<TParam>(ISceneTransitionSupport self, string sceneName) where TParam : IMemory
        {
            return (TParam)GetSceneParameterCore(sceneName);
        }

        [Extension]
        public static void StoreSceneParameter<TParam>(ISceneTransitionSupport self, string sceneName, TParam parameter) where TParam : IMemory
        {
            StoreSceneParameterCore(sceneName, parameter);
        }

        // RVA: 0x1EA18CC
        private static void ChangeSceneCore(string sceneName, IMemory parameter)
        {
                        StoreSceneParameterCore(sceneName, parameter);
                        SceneManager.LoadScene(sceneName);
        }

        // RVA: 0x1EA1958
        private static AsyncOperation ChangeSceneAsyncCore(string sceneName, IMemory parameter)
        {
                        StoreSceneParameterCore(sceneName, parameter);
                        return SceneManager.LoadSceneAsync(sceneName);
        }

        // RVA: 0x1EA19E0
        private static IMemory GetSceneParameterCore(string sceneName)
        {
                        if (string.IsNullOrEmpty(sceneName))
                        {
                            sceneName = SceneManager.GetActiveScene().name;
                        }

                        IMemory memory = ApplicationCache.Instance.Get<IMemory>(SceneParameterKey(sceneName));
                        if (memory == null)
                        {
                            memory = new Memory();
                        }

                        return memory;
        }

        // RVA: 0x1EA1B00
        private static void StoreSceneParameterCore(string sceneName, IMemory parameter)
        {
                        if (parameter == null)
                        {
                            parameter = GetSceneParameterCore(sceneName);
                        }

                        parameter.Set("SceneTransitionSupport.PrevScene", SceneManager.GetActiveScene().buildIndex);
                        parameter.Set("SceneTransitionSupport.PrevSceneName", SceneManager.GetActiveScene().name);
                        ApplicationCache.Instance.Set(SceneParameterKey(sceneName), parameter);
        }

        // RVA: 0x1EA1E28
        private static string SceneParameterKey(string sceneName)
        {
                        ValidateSceneName(sceneName);
                        return "SceneTransitionSupport.Scene." + sceneName;
        }

        // RVA: 0x1EA20F4
        private static void ValidateSceneName(string sceneName)
        {
                        if (string.IsNullOrEmpty(sceneName) || sceneName.Trim().Length == 0)
                        {
                            throw new ArgumentException("scene name is not valid");
                        }
        }
    }
}
