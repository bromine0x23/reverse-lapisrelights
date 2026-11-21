// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.RestoreContext
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
    public class RestoreContext : Context
    {
        private readonly SuccessRestoreDelegate successRestore;
        private readonly FailureRestoreDelegate failureRestore;
        public SuccessRestoreDelegate SuccessRestore { get { return successRestore; } }
        public FailureRestoreDelegate FailureRestore { get { return failureRestore; } }
        // RVA: 0x1783B44
        public SuccessRestoreDelegate get_SuccessRestore()
        {
            return successRestore;
        }

        // RVA: 0x1783B4C
        public FailureRestoreDelegate get_FailureRestore()
        {
            return failureRestore;
        }

        // RVA: 0x1783B54
        public RestoreContext()
        {
                        this(null, null);
        }

        // RVA: 0x1783B60
        public RestoreContext(SuccessRestoreDelegate successRestore, FailureRestoreDelegate failueRestore)
        {
                        this.successRestore = successRestore;
                        this.failureRestore = failueRestore;
        }

        // RVA: 0x1783BDC
        private RestoreContext(int id, SuccessRestoreDelegate successRestore, FailureRestoreDelegate failueRestore)
            : base(id)
        {
                        this.successRestore = successRestore;
                        this.failureRestore = failueRestore;
        }

        // RVA: 0x1783C6C
        public RestoreContext OnSuccessRestore(SuccessRestoreDelegate successRestoreDelegate)
        {
                        return new RestoreContext(Id, successRestoreDelegate, failureRestore);
        }

        // RVA: 0x1783CE8
        public RestoreContext OnFailureRestore(FailureRestoreDelegate failureRestoreDelegate)
        {
                        return new RestoreContext(Id, successRestore, failureRestoreDelegate);
        }

        // RVA: 0x1783D64
        public override void Execute()
        {
                        BillingService.Instance.Restore(this);
        }
    }
}
