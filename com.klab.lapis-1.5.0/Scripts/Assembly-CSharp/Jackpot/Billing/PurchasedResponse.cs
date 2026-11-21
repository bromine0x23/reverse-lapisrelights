// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.PurchasedResponse
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

namespace Jackpot.Billing
{
    public class PurchasedResponse
    {
        public PurchasedResponseKind ResultCode { get; private set; }
        public string Message { get; private set; }
        public List<string> SkippedTransactionIds { get; private set; }






        // RVA: 0x17823C0
        public PurchasedResponse(Dictionary<string, object> responseDic)
        {
                        ResultCode = (dict.ContainsKey("result_code") ? ((PurchasedResponseKind)int.Parse(dict["result_code"].ToString())) : PurchasedResponseKind.Unknown);
                        if (dict.ContainsKey("message"))
                        {
                            Message = dict["message"] as string;
                        }

                        SkippedTransactionIds = new List<string>();
                        if (dict.ContainsKey("skipped_transaction_ids"))
                        {
                            foreach (object item in (List<object>)dict["skipped_transaction_ids"])
                            {
                                SkippedTransactionIds.Add(item as string);
                            }
                        }
        }

        // RVA: 0x178265C
        public bool IsProcessedFailure()
        {
                        return ResultCode != PurchasedResponseKind.ProcessedSuccessfully && ResultCode != PurchasedResponseKind.AlreadyProcessed;
        }
    }
}
