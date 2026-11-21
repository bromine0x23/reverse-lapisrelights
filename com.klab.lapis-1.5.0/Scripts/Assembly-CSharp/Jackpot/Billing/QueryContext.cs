// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.QueryContext
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
    public class QueryContext : Context
    {
        private readonly QueryRequestDelegate queryRequest;
        private readonly QueryItemsRequestDelegate queryItemsRequest;
        private readonly SuccessQueryDelegate successQuery;
        private readonly FailureQueryDelegate failureQuery;
        public QueryRequestDelegate QueryRequest { get { return queryRequest; } }
        public QueryItemsRequestDelegate QueryItemsRequest { get { return queryItemsRequest; } }
        public SuccessQueryDelegate SuccessQuery { get { return successQuery; } }
        public FailureQueryDelegate FailureQuery { get { return failureQuery; } }
        // RVA: 0x1782678
        public QueryRequestDelegate get_QueryRequest()
        {
            return queryRequest;
        }

        // RVA: 0x1782680
        public QueryItemsRequestDelegate get_QueryItemsRequest()
        {
            return queryItemsRequest;
        }

        // RVA: 0x1782688
        public SuccessQueryDelegate get_SuccessQuery()
        {
            return successQuery;
        }

        // RVA: 0x1782690
        public FailureQueryDelegate get_FailureQuery()
        {
            return failureQuery;
        }

        // RVA: 0x1782698
        public QueryContext()
        {
                        this(null, null, null, null);
        }

        // RVA: 0x178273C
        public QueryContext(QueryRequestDelegate queryRequest, SuccessQueryDelegate successQuery, FailureQueryDelegate failureQuery)
        {
                        this(queryRequest, null, successQuery, failureQuery);
        }

        // RVA: 0x178274C
        public QueryContext(QueryItemsRequestDelegate queryItemsRequest, SuccessQueryDelegate successQuery, FailureQueryDelegate failureQuery)
        {
                        this(null, queryItemsRequest, successQuery, failureQuery);
        }

        // RVA: 0x17826AC
        private QueryContext(QueryRequestDelegate queryRequest, QueryItemsRequestDelegate queryItemsRequest, SuccessQueryDelegate successQuery, FailureQueryDelegate failureQuery)
        {
                        this.queryRequest = queryRequest;
                        this.queryItemsRequest = queryItemsRequest;
                        this.successQuery = successQuery;
                        this.failureQuery = failureQuery;
        }

        // RVA: 0x1782760
        private QueryContext(int id, QueryRequestDelegate queryRequest, QueryItemsRequestDelegate queryItemsRequest, SuccessQueryDelegate successQuery, FailureQueryDelegate failureQuery)
            : base(id)
        {
                        this.queryRequest = queryRequest;
                        this.queryItemsRequest = queryItemsRequest;
                        this.successQuery = successQuery;
                        this.failureQuery = failureQuery;
        }

        // RVA: 0x1782804
        public QueryContext OnQueryRequest(QueryRequestDelegate queryRequestDelegate)
        {
                        return new QueryContext(Id, queryRequestDelegate, null, successQuery, failureQuery);
        }

        // RVA: 0x1782890
        public QueryContext OnQueryRequest(QueryItemsRequestDelegate queryItemsRequestDelegate)
        {
                        return new QueryContext(Id, null, queryItemsRequestDelegate, successQuery, failureQuery);
        }

        // RVA: 0x178291C
        public QueryContext OnSuccess(SuccessQueryDelegate successQueryDelegate)
        {
                        return new QueryContext(Id, queryRequest, queryItemsRequest, successQueryDelegate, failureQuery);
        }

        // RVA: 0x17829AC
        public QueryContext OnFailure(FailureQueryDelegate failureQueryDelegate)
        {
                        return new QueryContext(Id, queryRequest, queryItemsRequest, successQuery, failureQueryDelegate);
        }

        // RVA: 0x1782A3C
        public override void Execute()
        {
                        BillingService.Instance.Query(this);
        }
    }
}
