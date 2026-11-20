// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Game.Lapis.LapisBase
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
        public abstract class LapisBase
        {
            public virtual Task BidiCall(IAsyncStreamReader<CommonRequest> requestStream, IServerStreamWriter<CommonResponse> responseStream, ServerCallContext context)
            {
                throw new RpcException(new Status(StatusCode.Unimplemented, ""));
            }

            public virtual Task<CommonResponse> Call(CommonRequest request, ServerCallContext context)
            {
                throw new RpcException(new Status(StatusCode.Unimplemented, ""));
            }

            public virtual Task<AssetUrlsResponse> GetAssetUrls(AssetUrlsRequest request, ServerCallContext context)
            {
                throw new RpcException(new Status(StatusCode.Unimplemented, ""));
            }

            public virtual Task<VerManifestResponse> GetVerManifest(VerManifestRequest request, ServerCallContext context)
            {
                throw new RpcException(new Status(StatusCode.Unimplemented, ""));
            }

            public virtual Task<MaintenanceResponse> GetMaintenance(MaintenanceRequest request, ServerCallContext context)
            {
                throw new RpcException(new Status(StatusCode.Unimplemented, ""));
            }

            public virtual Task<RefundUrlResponse> GetRefundUrl(RefundUrlRequest request, ServerCallContext context)
            {
                throw new RpcException(new Status(StatusCode.Unimplemented, ""));
            }

            protected LapisBase()
            {
            }
        }
    }
}
