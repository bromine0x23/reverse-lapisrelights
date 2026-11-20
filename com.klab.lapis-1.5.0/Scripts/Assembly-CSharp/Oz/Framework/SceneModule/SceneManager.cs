// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.SceneModule.SceneManager
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

namespace Oz.Framework.SceneModule
{
    public class SceneManager : MonoBehaviour
    {

        // RVA: 0x2EE5BC4
        public static void LoadSceneAsync(string sceneName, int mode)
        {
            UnityEngine.SceneManagement.SceneManager.LoadSceneAsync(
                sceneName, (LoadSceneMode)mode);
        }

        // RVA: 0x2EE5C3C
        public static void UnloadSceneAsync(string sceneName)
        {
            UnityEngine.SceneManagement.SceneManager.UnloadSceneAsync(sceneName);
        }

        // RVA: 0x2EE5CA4
        public static bool SetActiveScene(string sceneName)
        {
            return UnityEngine.SceneManagement.SceneManager.SetActiveScene(
                UnityEngine.SceneManagement.SceneManager.GetSceneByName(sceneName));
        }

        // RVA: 0x2EE5D18
        public void .ctor()
        {
        }
    }
}
