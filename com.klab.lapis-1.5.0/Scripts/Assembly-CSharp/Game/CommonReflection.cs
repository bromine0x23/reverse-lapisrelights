// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Game.CommonReflection
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using Google.Protobuf;
using Google.Protobuf.Collections;
using Google.Protobuf.Reflection;
using pbr = Google.Protobuf.Reflection;
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
    public static class CommonReflection
    {
        private static FileDescriptor descriptor;
        public static FileDescriptor Descriptor { get; }

        // RVA: 0x1A3B1B0
        public static FileDescriptor get_Descriptor()
        {
            return descriptor;
        }

        // RVA: 0x1A3B218
        static CommonReflection()
        {
            byte[] descriptorData = global::System.Convert.FromBase64String(
                string.Concat(
                    "Cgxjb21tb24ucHJvdG8SBGdhbWUiugEKDUNvbW1vblJlcXVlc3QSDwoHcGF5",
                    "bG9hZBgBIAEoDBIRCglzaWduYXR1cmUYAiABKAkSEAoIcGxheWVySWQYAyAB",
                    "KAMSEAoIcGxhdGZvcm0YBCABKAkSCgoCaWQYBSABKAkSDAoEbGFuZxgGIAEo",
                    "CRIKCgJ0cxgHIAEoAxIPCgdsdWFIYXNoGAggASgJEhIKCnJlc1ZlcnNpb24Y",
                    "CSABKAkSFgoObWFpblJlc1ZlcnNpb24YCiABKAkicgoOQ29tbW9uUmVzcG9u",
                    "c2USDwoHcGF5bG9hZBgBIAEoDBIRCglzaWduYXR1cmUYAiABKAkSIAoGc3Rh",
                    "dHVzGAMgASgOMhAuZ2FtZS5TdGF0dXNDb2RlEg4KBnJlc1ZlchgEIAEoCRIK",
                    "CgJ0cxgFIAEoAyJZChBBc3NldFVybHNSZXF1ZXN0EhAKCHBsYXRmb3JtGAEg",
                    "ASgJEgwKBGxhbmcYAiABKAkSEQoJYXNzZXRLZXlzGAMgAygJEhIKCnJlc1Zl",
                    "cnNpb24YBCABKAkiMAoJU2lnbmVkVVJMEhAKCHBhY2tIYXNoGAEgASgJEhEK",
                    "CXNpZ25lZFNlZxgCIAEoCSIxChBTaWduZWRVUkxQYXlsb2FkEh0KBHVybHMY",
                    "ASADKAsyDy5nYW1lLlNpZ25lZFVSTCKPAQoRQXNzZXRVcmxzUmVzcG9uc2US",
                    "IAoGc3RhdHVzGAEgASgOMhAuZ2FtZS5TdGF0dXNDb2RlEh0KBHVybHMYAiAD",
                    "KAsyDy5nYW1lLlNpZ25lZFVSTBIQCghob3N0TmFtZRgDIAEoCRISCgpyZXNW",
                    "ZXJzaW9uGAQgASgJEhMKC3VybHNQYXlsb2FkGAUgASgMIjQKElZlck1hbmlm",
                    "ZXN0UmVxdWVzdBIQCghwbGF0Zm9ybRgBIAEoCRIMCgRsYW5nGAIgASgJIjkK",
                    "E1Zlck1hbmlmZXN0UmVzcG9uc2USDgoGcmVzVmVyGAEgASgJEhIKCm1haW5S",
                    "ZXNWZXIYAiABKAkiJgoSTWFpbnRlbmFuY2VSZXF1ZXN0EhAKCHBsYXllcklk",
                    "GAEgASgDIt8BChNNYWludGVuYW5jZVJlc3BvbnNlEgwKBGJvZHkYASABKAkS",
                    "EQoJcmVmdW5kVXJsGAIgASgJEjQKBGNvZGUYAyABKA4yJi5nYW1lLk1haW50",
                    "ZW5hbmNlUmVzcG9uc2UuUmVzcG9uc2VDb2RlInEKDFJlc3BvbnNlQ29kZRIG",
                    "CgJPaxAAEg8KC01haW50ZW5hbmNlEAESDAoIT25SZWZ1bmQQAhITCg9PblJl",
                    "ZnVuZEJ1dE5vbmUQAxIOCgpPdmVyUmVmdW5kEAQSFQoRQ29tbXVuaWNhdGVG",
                    "YWlsZWQQBSIkChBSZWZ1bmRVcmxSZXF1ZXN0EhAKCHBsYXllcklkGAEgASgD",
                    "IiAKEVJlZnVuZFVybFJlc3BvbnNlEgsKA3VybBgBIAEoCSptCgpTdGF0dXND",
                    "b2RlEgYKAk9LEAASCgoGRkFJTEVEEAESEwoPU0lHTkFUVVJFX0VSUk9SEAIS",
                    "FwoTS0lDS19PVVRfTE9HSU5fVVNFUhADEgsKB0NBVVRJT04QBBIQCgxDTElF",
                    "TlRfRVJST1IQBTKRAwoFTGFwaXMSOwoIQmlkaUNhbGwSEy5nYW1lLkNvbW1v",
                    "blJlcXVlc3QaFC5nYW1lLkNvbW1vblJlc3BvbnNlIgAoATABEjMKBENhbGwS",
                    "Ey5nYW1lLkNvbW1vblJlcXVlc3QaFC5nYW1lLkNvbW1vblJlc3BvbnNlIgAS",
                    "QQoMR2V0QXNzZXRVcmxzEhYuZ2FtZS5Bc3NldFVybHNSZXF1ZXN0GhcuZ2Ft",
                    "ZS5Bc3NldFVybHNSZXNwb25zZSIAEkcKDkdldFZlck1hbmlmZXN0EhguZ2Ft",
                    "ZS5WZXJNYW5pZmVzdFJlcXVlc3QaGS5nYW1lLlZlck1hbmlmZXN0UmVzcG9u",
                    "c2UiABJHCg5HZXRNYWludGVuYW5jZRIYLmdhbWUuTWFpbnRlbmFuY2VSZXF1",
                    "ZXN0GhkuZ2FtZS5NYWludGVuYW5jZVJlc3BvbnNlIgASQQoMR2V0UmVmdW5k",
                    "VXJsEhYuZ2FtZS5SZWZ1bmRVcmxSZXF1ZXN0GhcuZ2FtZS5SZWZ1bmRVcmxS",
                    "ZXNwb25zZSIAQi0KHGNvbS5rbGFiY2hpbmEubGFwaXMucHJvdG9idWZCC0Nv",
                    "bW1vblByb3RvUAFiBnByb3RvMw=="
                    ));
            descriptor = pbr::FileDescriptor.FromGeneratedCode(descriptorData,
                new pbr::FileDescriptor[] { },
                new pbr::GeneratedClrTypeInfo[] {
                    new pbr::GeneratedClrTypeInfo(typeof(global::Game.CommonRequest), global::Game.CommonRequest.Parser, new[]{ "Payload", "Signature", "PlayerId", "Platform", "Id", "Lang", "Ts", "LuaHash", "ResVersion", "MainResVersion" }, null, null, null),
                    new pbr::GeneratedClrTypeInfo(typeof(global::Game.CommonResponse), global::Game.CommonResponse.Parser, new[]{ "Payload", "Signature", "Status", "ResVer", "Ts" }, null, null, null),
                    new pbr::GeneratedClrTypeInfo(typeof(global::Game.AssetUrlsRequest), global::Game.AssetUrlsRequest.Parser, new[]{ "Platform", "Lang", "AssetKeys", "ResVersion" }, null, null, null),
                    new pbr::GeneratedClrTypeInfo(typeof(global::Game.SignedURL), global::Game.SignedURL.Parser, new[]{ "PackHash", "SignedSeg" }, null, null, null),
                    new pbr::GeneratedClrTypeInfo(typeof(global::Game.SignedURLPayload), global::Game.SignedURLPayload.Parser, new[]{ "Urls" }, null, null, null),
                    new pbr::GeneratedClrTypeInfo(typeof(global::Game.AssetUrlsResponse), global::Game.AssetUrlsResponse.Parser, new[]{ "Status", "Urls", "HostName", "ResVersion", "UrlsPayload" }, null, null, null),
                    new pbr::GeneratedClrTypeInfo(typeof(global::Game.VerManifestRequest), global::Game.VerManifestRequest.Parser, new[]{ "Platform", "Lang" }, null, null, null),
                    new pbr::GeneratedClrTypeInfo(typeof(global::Game.VerManifestResponse), global::Game.VerManifestResponse.Parser, new[]{ "ResVer", "MainResVer" }, null, null, null),
                    new pbr::GeneratedClrTypeInfo(typeof(global::Game.MaintenanceRequest), global::Game.MaintenanceRequest.Parser, new[]{ "PlayerId" }, null, null, null),
                    new pbr::GeneratedClrTypeInfo(typeof(global::Game.MaintenanceResponse), global::Game.MaintenanceResponse.Parser, new[]{ "Body", "RefundUrl", "Code" }, null, new[] { typeof(global::Game.MaintenanceResponse.Types.ResponseCode) }, null),
                    new pbr::GeneratedClrTypeInfo(typeof(global::Game.RefundUrlRequest), global::Game.RefundUrlRequest.Parser, new[]{ "PlayerId" }, null, null, null),
                    new pbr::GeneratedClrTypeInfo(typeof(global::Game.RefundUrlResponse), global::Game.RefundUrlResponse.Parser, new[]{ "Url" }, null, null, null)
                });
        }
    }
}
