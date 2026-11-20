// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Game.Lapis
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using Google.Protobuf.Collections;
using Google.Protobuf.Reflection;
using Grpc.Core;
using Google.Protobuf;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Game
{
    public static partial class Lapis
    {
        private static readonly string __ServiceName;
        private static readonly Marshaller<CommonRequest> __Marshaller_game_CommonRequest;
        private static readonly Marshaller<CommonResponse> __Marshaller_game_CommonResponse;
        private static readonly Marshaller<AssetUrlsRequest> __Marshaller_game_AssetUrlsRequest;
        private static readonly Marshaller<AssetUrlsResponse> __Marshaller_game_AssetUrlsResponse;
        private static readonly Marshaller<VerManifestRequest> __Marshaller_game_VerManifestRequest;
        private static readonly Marshaller<VerManifestResponse> __Marshaller_game_VerManifestResponse;
        private static readonly Marshaller<MaintenanceRequest> __Marshaller_game_MaintenanceRequest;
        private static readonly Marshaller<MaintenanceResponse> __Marshaller_game_MaintenanceResponse;
        private static readonly Marshaller<RefundUrlRequest> __Marshaller_game_RefundUrlRequest;
        private static readonly Marshaller<RefundUrlResponse> __Marshaller_game_RefundUrlResponse;
        private static readonly Method<CommonRequest, CommonResponse> __Method_BidiCall;
        private static readonly Method<CommonRequest, CommonResponse> __Method_Call;
        private static readonly Method<AssetUrlsRequest, AssetUrlsResponse> __Method_GetAssetUrls;
        private static readonly Method<VerManifestRequest, VerManifestResponse> __Method_GetVerManifest;
        private static readonly Method<MaintenanceRequest, MaintenanceResponse> __Method_GetMaintenance;
        private static readonly Method<RefundUrlRequest, RefundUrlResponse> __Method_GetRefundUrl;
        public static ServiceDescriptor Descriptor { get; }

        // RVA: 0x1A3F1B4
        public static ServiceDescriptor get_Descriptor()
        {
            return CommonReflection.Descriptor.Services[0];
        }

        // RVA: 0x1A3F2D0
        public static ServerServiceDefinition BindService(Lapis.LapisBase serviceImpl)
        {
            return ServerServiceDefinition.CreateBuilder()
                .AddMethod(__Method_BidiCall, serviceImpl.BidiCall)
                .AddMethod(__Method_Call, serviceImpl.Call)
                .AddMethod(__Method_GetAssetUrls, serviceImpl.GetAssetUrls)
                .AddMethod(__Method_GetVerManifest, serviceImpl.GetVerManifest)
                .AddMethod(__Method_GetMaintenance, serviceImpl.GetMaintenance)
                .AddMethod(__Method_GetRefundUrl, serviceImpl.GetRefundUrl)
                .Build();
        }

        // RVA: 0x1A3F5B0
        public static void BindService(ServiceBinderBase serviceBinder, Lapis.LapisBase serviceImpl)
        {
            serviceBinder.AddMethod(__Method_BidiCall, serviceImpl.BidiCall);
            serviceBinder.AddMethod(__Method_Call, serviceImpl.Call);
            serviceBinder.AddMethod(__Method_GetAssetUrls, serviceImpl.GetAssetUrls);
            serviceBinder.AddMethod(__Method_GetVerManifest, serviceImpl.GetVerManifest);
            serviceBinder.AddMethod(__Method_GetMaintenance, serviceImpl.GetMaintenance);
            serviceBinder.AddMethod(__Method_GetRefundUrl, serviceImpl.GetRefundUrl);
        }

        // RVA: 0x1A3F9A0
        static Lapis()
        {
            __ServiceName = "game.Lapis";
            __Marshaller_game_CommonRequest = Marshallers.Create(
                (arg) => arg.ToByteArray(),
                CommonRequest.Parser.ParseFrom);
            __Marshaller_game_CommonResponse = Marshallers.Create(
                (arg) => arg.ToByteArray(),
                CommonResponse.Parser.ParseFrom);
            __Marshaller_game_AssetUrlsRequest = Marshallers.Create(
                (arg) => arg.ToByteArray(),
                AssetUrlsRequest.Parser.ParseFrom);
            __Marshaller_game_AssetUrlsResponse = Marshallers.Create(
                (arg) => arg.ToByteArray(),
                AssetUrlsResponse.Parser.ParseFrom);
            __Marshaller_game_VerManifestRequest = Marshallers.Create(
                (arg) => arg.ToByteArray(),
                VerManifestRequest.Parser.ParseFrom);
            __Marshaller_game_VerManifestResponse = Marshallers.Create(
                (arg) => arg.ToByteArray(),
                VerManifestResponse.Parser.ParseFrom);
            __Marshaller_game_MaintenanceRequest = Marshallers.Create(
                (arg) => arg.ToByteArray(),
                MaintenanceRequest.Parser.ParseFrom);
            __Marshaller_game_MaintenanceResponse = Marshallers.Create(
                (arg) => arg.ToByteArray(),
                MaintenanceResponse.Parser.ParseFrom);
            __Marshaller_game_RefundUrlRequest = Marshallers.Create(
                (arg) => arg.ToByteArray(),
                RefundUrlRequest.Parser.ParseFrom);
            __Marshaller_game_RefundUrlResponse = Marshallers.Create(
                (arg) => arg.ToByteArray(),
                RefundUrlResponse.Parser.ParseFrom);
            __Method_BidiCall = new Method<CommonRequest, CommonResponse>(
                MethodType.DuplexStreaming,
                __ServiceName,
                "BidiCall",
                __Marshaller_game_CommonRequest,
                __Marshaller_game_CommonResponse);
            __Method_Call = new Method<CommonRequest, CommonResponse>(
                MethodType.Unary,
                __ServiceName,
                "Call",
                __Marshaller_game_CommonRequest,
                __Marshaller_game_CommonResponse);
            __Method_GetAssetUrls = new Method<AssetUrlsRequest, AssetUrlsResponse>(
                MethodType.Unary,
                __ServiceName,
                "GetAssetUrls",
                __Marshaller_game_AssetUrlsRequest,
                __Marshaller_game_AssetUrlsResponse);
            __Method_GetVerManifest = new Method<VerManifestRequest, VerManifestResponse>(
                MethodType.Unary,
                __ServiceName,
                "GetVerManifest",
                __Marshaller_game_VerManifestRequest,
                __Marshaller_game_VerManifestResponse);
            __Method_GetMaintenance = new Method<MaintenanceRequest, MaintenanceResponse>(
                MethodType.Unary,
                __ServiceName,
                "GetMaintenance",
                __Marshaller_game_MaintenanceRequest,
                __Marshaller_game_MaintenanceResponse);
            __Method_GetRefundUrl = new Method<RefundUrlRequest, RefundUrlResponse>(
                MethodType.Unary,
                __ServiceName,
                "GetRefundUrl",
                __Marshaller_game_RefundUrlRequest,
                __Marshaller_game_RefundUrlResponse);
        }
    }
}
