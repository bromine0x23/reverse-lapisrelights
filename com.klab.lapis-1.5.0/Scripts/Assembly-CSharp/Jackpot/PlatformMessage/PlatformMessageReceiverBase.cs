// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.PlatformMessage.PlatformMessageReceiverBase
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Jackpot.PlatformMessage
{
    public abstract class PlatformMessageReceiverBase : MonoBehaviour
    {
        protected abstract void OnUrlSchemeReceived(Uri uri);

        // RVA: 0x1E9EEE8
        private void OnLaunchWithUrlScheme(string urlString)
        {
            try
            {
                OnUrlSchemeReceived(new Uri(urlString));
            }
            catch (UriFormatException e)
            {
                Logger.Get<PlatformMessageReceiverBase>().Error(e.Message);
            }
        }

        // RVA: 0x1E9F0A4
        protected PlatformMessageReceiverBase()
        {
        }
    }
}
