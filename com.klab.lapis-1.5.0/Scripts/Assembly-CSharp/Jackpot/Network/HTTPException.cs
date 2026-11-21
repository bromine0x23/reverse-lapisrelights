// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.HTTPException
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
    public class HTTPException : Exception
    {
        public HTTPResponse Response { get; private set; }
        public WebExceptionStatus ExceptionStatus { get; private set; }




        // RVA: 0x1E930C8
        public HTTPException(string message, HTTPResponse response, WebExceptionStatus status)
            : base(message)
        {
            Response = response;
            ExceptionStatus = status;
            if (response != null)
            {
                base.Data["result"] = response.Bytes;
            }
        }
    }
}
