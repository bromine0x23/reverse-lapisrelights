// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.ResumeContext
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

namespace Jackpot.Billing
{
    public class ResumeContext : Context
    {
        private readonly SuccessResumeDelegate successResume;
        private readonly FailureResumeDelegate failureResume;
        public SuccessResumeDelegate SuccessResume { get { return successResume; } }
        public FailureResumeDelegate FailureResume { get { return failureResume; } }
        // RVA: 0x1783E54
        public SuccessResumeDelegate get_SuccessResume()
        {
            return successResume;
        }

        // RVA: 0x1783E5C
        public FailureResumeDelegate get_FailureResume()
        {
            return failureResume;
        }

        // RVA: 0x1776378
        public ResumeContext()
        {
                        this(null, null);
        }

        // RVA: 0x1783E64
        public ResumeContext(SuccessResumeDelegate successRestore, FailureResumeDelegate failureRestore)
        {
                        this.successResume = successRestore;
                        this.failureResume = failureRestore;
        }

        // RVA: 0x1783EE0
        private ResumeContext(int id, SuccessResumeDelegate successResume, FailureResumeDelegate failureResume)
            : base(id)
        {
                        this.successResume = successResume;
                        this.failureResume = failureResume;
        }

        // RVA: 0x1776394
        public ResumeContext OnSuccessResume(SuccessResumeDelegate successResumeDelegate)
        {
                        return new ResumeContext(Id, successResumeDelegate, failureResume);
        }

        // RVA: 0x1776420
        public ResumeContext OnFailureResume(FailureResumeDelegate failureResumeDelegate)
        {
                        return new ResumeContext(Id, successResume, failureResumeDelegate);
        }

        // RVA: 0x1783F70
        public override void Execute()
        {
                        BillingService.Instance.Resume(this);
        }
    }
}
