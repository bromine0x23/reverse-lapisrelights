// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Game.Lapis.LapisClient
//  来源：Il2CppDumper 元数据 + 反汇编（gRPC 生成代码模板）
// =============================================================================

using System;
using System.Threading;
using System.Threading.Tasks;
using Grpc.Core;

namespace Game
{
    public static partial class Lapis
    {
        public class LapisClient : ClientBase<LapisClient>
        {
            public LapisClient(ChannelBase channel) : base(channel)
            {
            }

            public LapisClient(CallInvoker callInvoker) : base(callInvoker)
            {
            }

            protected LapisClient() : base()
            {
            }

            protected LapisClient(ClientBase.ClientBaseConfiguration configuration) : base(configuration)
            {
            }

            public virtual AsyncDuplexStreamingCall<CommonRequest, CommonResponse> BidiCall(Metadata headers, Nullable<DateTime> deadline, CancellationToken cancellationToken)
            {
                return BidiCall(new CallOptions(headers, deadline, cancellationToken));
            }

            public virtual AsyncDuplexStreamingCall<CommonRequest, CommonResponse> BidiCall(CallOptions options)
            {
                return CallInvoker.AsyncDuplexStreamingCall(__Method_BidiCall, null, options);
            }

            public virtual CommonResponse Call(CommonRequest request, Metadata headers, Nullable<DateTime> deadline, CancellationToken cancellationToken)
            {
                return Call(request, new CallOptions(headers, deadline, cancellationToken));
            }

            public virtual CommonResponse Call(CommonRequest request, CallOptions options)
            {
                return CallInvoker.BlockingUnaryCall(__Method_Call, null, options, request);
            }

            public virtual AsyncUnaryCall<CommonResponse> CallAsync(CommonRequest request, Metadata headers, Nullable<DateTime> deadline, CancellationToken cancellationToken)
            {
                return CallAsync(request, new CallOptions(headers, deadline, cancellationToken));
            }

            public virtual AsyncUnaryCall<CommonResponse> CallAsync(CommonRequest request, CallOptions options)
            {
                return CallInvoker.AsyncUnaryCall(__Method_Call, null, options, request);
            }

            public virtual AssetUrlsResponse GetAssetUrls(AssetUrlsRequest request, Metadata headers, Nullable<DateTime> deadline, CancellationToken cancellationToken)
            {
                return GetAssetUrls(request, new CallOptions(headers, deadline, cancellationToken));
            }

            public virtual AssetUrlsResponse GetAssetUrls(AssetUrlsRequest request, CallOptions options)
            {
                return CallInvoker.BlockingUnaryCall(__Method_GetAssetUrls, null, options, request);
            }

            public virtual AsyncUnaryCall<AssetUrlsResponse> GetAssetUrlsAsync(AssetUrlsRequest request, Metadata headers, Nullable<DateTime> deadline, CancellationToken cancellationToken)
            {
                return GetAssetUrlsAsync(request, new CallOptions(headers, deadline, cancellationToken));
            }

            public virtual AsyncUnaryCall<AssetUrlsResponse> GetAssetUrlsAsync(AssetUrlsRequest request, CallOptions options)
            {
                return CallInvoker.AsyncUnaryCall(__Method_GetAssetUrls, null, options, request);
            }

            public virtual VerManifestResponse GetVerManifest(VerManifestRequest request, Metadata headers, Nullable<DateTime> deadline, CancellationToken cancellationToken)
            {
                return GetVerManifest(request, new CallOptions(headers, deadline, cancellationToken));
            }

            public virtual VerManifestResponse GetVerManifest(VerManifestRequest request, CallOptions options)
            {
                return CallInvoker.BlockingUnaryCall(__Method_GetVerManifest, null, options, request);
            }

            public virtual AsyncUnaryCall<VerManifestResponse> GetVerManifestAsync(VerManifestRequest request, Metadata headers, Nullable<DateTime> deadline, CancellationToken cancellationToken)
            {
                return GetVerManifestAsync(request, new CallOptions(headers, deadline, cancellationToken));
            }

            public virtual AsyncUnaryCall<VerManifestResponse> GetVerManifestAsync(VerManifestRequest request, CallOptions options)
            {
                return CallInvoker.AsyncUnaryCall(__Method_GetVerManifest, null, options, request);
            }

            public virtual MaintenanceResponse GetMaintenance(MaintenanceRequest request, Metadata headers, Nullable<DateTime> deadline, CancellationToken cancellationToken)
            {
                return GetMaintenance(request, new CallOptions(headers, deadline, cancellationToken));
            }

            public virtual MaintenanceResponse GetMaintenance(MaintenanceRequest request, CallOptions options)
            {
                return CallInvoker.BlockingUnaryCall(__Method_GetMaintenance, null, options, request);
            }

            public virtual AsyncUnaryCall<MaintenanceResponse> GetMaintenanceAsync(MaintenanceRequest request, Metadata headers, Nullable<DateTime> deadline, CancellationToken cancellationToken)
            {
                return GetMaintenanceAsync(request, new CallOptions(headers, deadline, cancellationToken));
            }

            public virtual AsyncUnaryCall<MaintenanceResponse> GetMaintenanceAsync(MaintenanceRequest request, CallOptions options)
            {
                return CallInvoker.AsyncUnaryCall(__Method_GetMaintenance, null, options, request);
            }

            public virtual RefundUrlResponse GetRefundUrl(RefundUrlRequest request, Metadata headers, Nullable<DateTime> deadline, CancellationToken cancellationToken)
            {
                return GetRefundUrl(request, new CallOptions(headers, deadline, cancellationToken));
            }

            public virtual RefundUrlResponse GetRefundUrl(RefundUrlRequest request, CallOptions options)
            {
                return CallInvoker.BlockingUnaryCall(__Method_GetRefundUrl, null, options, request);
            }

            public virtual AsyncUnaryCall<RefundUrlResponse> GetRefundUrlAsync(RefundUrlRequest request, Metadata headers, Nullable<DateTime> deadline, CancellationToken cancellationToken)
            {
                return GetRefundUrlAsync(request, new CallOptions(headers, deadline, cancellationToken));
            }

            public virtual AsyncUnaryCall<RefundUrlResponse> GetRefundUrlAsync(RefundUrlRequest request, CallOptions options)
            {
                return CallInvoker.AsyncUnaryCall(__Method_GetRefundUrl, null, options, request);
            }

            protected override LapisClient NewInstance(ClientBase.ClientBaseConfiguration configuration)
            {
                return new LapisClient(configuration);
            }
        }
    }
}
