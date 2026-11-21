// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.UploadDataCompletedEventArgs
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

namespace Jackpot.Network
{
    public class UploadDataCompletedEventArgs : AsyncCompletedEventArgs
    {
        private readonly byte[] result;
        public byte[] Result { get { return result; } }
        // RVA: 0x1E9AEE0
        public UploadDataCompletedEventArgs(byte[] result, Exception exception)
            : base(exception, false, null)
        {
            this.result = result;
        }

        // RVA: 0x1E9A57C
        public UploadDataCompletedEventArgs(byte[] result, Exception exception, bool cancelled, object userToken)
            : base(exception, cancelled, userToken)
        {
            this.result = result;
        }

        // RVA: 0x1E9AF18
        public byte[] get_Result()
        {
            return result;
        }
    }
}
