// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.StubRequestResult
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
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
    public class StubRequestResult
    {
        private static readonly StubRequestResult ResultPassed;
        public bool IsSuccess { get; private set; }
        public bool IsFailure { get { return !IsSuccess; } }
        public bool Passed { get; private set; }
        public HTTPResponse Response { get; private set; }







        // RVA: 0x1E9A218
        public static StubRequestResult Success(string responseText)
        {
            HTTPResponse hTTPResponse = new HTTPResponse(HTTPStatus.OK);
            hTTPResponse.Text = responseText;
            return Success(hTTPResponse);
        }

        // RVA: 0x1E9A2A4
        public static StubRequestResult Success(HTTPResponse response)
        {
            return new StubRequestResult
            {
                IsSuccess = true,
                Passed = false,
                Response = response
            };
        }

        // RVA: 0x1E9A35C
        public static StubRequestResult Failure(HTTPResponse response)
        {
            return new StubRequestResult
            {
                IsSuccess = false,
                Passed = false,
                Response = response
            };
        }

        // RVA: 0x1E9A3C4
        public static StubRequestResult Pass()
        {
            return ResultPassed;
        }

        // RVA: 0x1E9A310
        private StubRequestResult(HTTPResponse response, bool isSuccess, bool passed)
        {
            IsSuccess = isSuccess;
            Passed = passed;
            Response = response;
        }

        // RVA: 0x1E9A42C
        static StubRequestResult()
        {
            ResultPassed = new StubRequestResult(null, true, true);
        }
    }
}
