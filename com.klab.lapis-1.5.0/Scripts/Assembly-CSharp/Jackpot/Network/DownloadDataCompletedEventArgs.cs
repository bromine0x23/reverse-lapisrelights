// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.DownloadDataCompletedEventArgs
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
    public class DownloadDataCompletedEventArgs : AsyncCompletedEventArgs
    {
        private readonly byte[] result;
        public byte[] Result { get { return result; } }
        // RVA: 0x1E8FE1C
        public DownloadDataCompletedEventArgs(byte[] result, Exception exception)
            : base(exception, false, null)
        {
            this.result = result;
        }

        // RVA: 0x1E8FE54
        public DownloadDataCompletedEventArgs(byte[] result, Exception exception, bool cancelled, object userToken)
            : base(exception, cancelled, userToken)
        {
            this.result = result;
        }

        // RVA: 0x1E8FE90
        public byte[] get_Result()
        {
            return result;
        }
    }
}
