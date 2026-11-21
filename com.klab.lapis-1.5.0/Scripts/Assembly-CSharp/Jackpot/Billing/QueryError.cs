// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.QueryError
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
    public class QueryError
    {
        public bool IsFailedOnQueryRequest { get; private set; }
        public bool IsMaintenanceAppServer { get; private set; }
        public bool IsStillPurchasing { get; private set; }
        public bool IsFailedOnPlatformRequest { get; private set; }
        public bool IsInvalidOperation { get; private set; }
        public string Message { get; private set; }
        public List<string> FailureProductIdList { get; private set; }














        // RVA: 0x1782AEC
        public static QueryError FailedOnQueryRequest(string message)
        {
                        QueryError queryError = new QueryError(message);
                        queryError.IsFailedOnQueryRequest = true;
                        return queryError;
        }

        // RVA: 0x1782B8C
        public static QueryError MaintenanceAppServer(string message)
        {
                        QueryError queryError = new QueryError(message);
                        queryError.IsMaintenanceAppServer = true;
                        return queryError;
        }

        // RVA: 0x1782C00
        public static QueryError StillPurchasing(List<string> failureProductIdList)
        {
                        QueryError queryError = new QueryError("ProductIds:" + string.Join(",", failureProductIdList.ToArray()));
                        queryError.IsStillPurchasing = true;
                        queryError.FailureProductIdList = failureProductIdList;
                        return queryError;
        }

        // RVA: 0x1782CD8
        public static QueryError FailedOnPlatformRequest(string message)
        {
                        QueryError queryError = new QueryError(message);
                        queryError.IsFailedOnPlatformRequest = true;
                        return queryError;
        }

        // RVA: 0x1782D4C
        public static QueryError InvalidOperation(string message)
        {
                        QueryError queryError = new QueryError(message);
                        queryError.IsInvalidOperation = true;
                        return queryError;
        }

        // RVA: 0x1782B60
        private QueryError(string message)
        {
        }

        // RVA: 0x1782DC0
        public override string ToString()
        {
                        if (IsFailedOnQueryRequest)
                        {
                            return string.Format("FailedOnQueryRequest: {0}", Message);
                        }

                        if (IsStillPurchasing)
                        {
                            return string.Format("StillPurchasing: {0}", Message);
                        }

                        if (IsFailedOnPlatformRequest)
                        {
                            return string.Format("FailedOnPlatformRequest: {0}", Message);
                        }

                        if (IsInvalidOperation)
                        {
                            return string.Format("InvalidOperation: {0}", Message);
                        }

                        if (IsMaintenanceAppServer)
                        {
                            return string.Format("IsMaintenanceAppServer: {0}", Message);
                        }

                        return Message;
        }
    }
}
