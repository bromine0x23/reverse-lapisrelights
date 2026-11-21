// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Game.AssetUrlsResponse
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using Google.Protobuf;
using Google.Protobuf.Collections;
using Google.Protobuf.Reflection;
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
    public sealed class AssetUrlsResponse : IMessage<AssetUrlsResponse>, IMessage, IEquatable<AssetUrlsResponse>, IDeepCloneable<AssetUrlsResponse>
    {
        private static readonly MessageParser<AssetUrlsResponse> _parser;
        private UnknownFieldSet _unknownFields;
        public const int StatusFieldNumber = 1;
        private StatusCode status_;
        public const int UrlsFieldNumber = 2;
        private static readonly FieldCodec<SignedURL> _repeated_urls_codec;
        private readonly RepeatedField<SignedURL> urls_;
        public const int HostNameFieldNumber = 3;
        private string hostName_;
        public const int ResVersionFieldNumber = 4;
        private string resVersion_;
        public const int UrlsPayloadFieldNumber = 5;
        private ByteString urlsPayload_;
        public static MessageParser<AssetUrlsResponse> Parser { get; }
        private static MessageDescriptor _Descriptor;
        public static MessageDescriptor Descriptor { get { return _Descriptor; } }
        private MessageDescriptor pb::Google.Protobuf.IMessage.Descriptor { get; }
        public StatusCode Status { get; set; }
        public RepeatedField<SignedURL> Urls { get; }
        public string HostName { get; set; }
        public string ResVersion { get; set; }
        public ByteString UrlsPayload { get; set; }

        // RVA: 0x1A3A19C
        public static MessageParser<AssetUrlsResponse> get_Parser()
        {
            return _parser;
        }

        // RVA: 0x1A3A204
        public static MessageDescriptor get_Descriptor()
        {
            return CommonReflection.Descriptor.MessageTypes[5];
        }

        // RVA: 0x1A3A320
        private MessageDescriptor pb::Google.Protobuf.IMessage.get_Descriptor()
        {
            return _Descriptor;
        }

        // RVA: 0x1A3A37C
        [DebuggerNonUserCode]
        public AssetUrlsResponse()
        {
            urls_ = new RepeatedField<SignedURL>();
            hostName_ = "";
            resVersion_ = "";
            urlsPayload_ = ByteString.Empty;
        }

        // RVA: 0x1A3A470
        [DebuggerNonUserCode]
        public AssetUrlsResponse(AssetUrlsResponse other)
        {
            status_ = other.status_;
            urls_ = other.urls_.Clone();
            hostName_ = other.hostName_;
            resVersion_ = other.resVersion_;
            urlsPayload_ = other.urlsPayload_;
            _unknownFields = UnknownFieldSet.Clone(other._unknownFields);
        }

        // RVA: 0x1A3A518
        [DebuggerNonUserCode]
        public AssetUrlsResponse Clone()
        {
            return new AssetUrlsResponse(this);
        }

        // RVA: 0x1A3A578
        public StatusCode get_Status()
        {
            return status_;
        }

        // RVA: 0x1A3A580
        public void set_Status(StatusCode value)
        {
            status_ = value;
        }

        // RVA: 0x1A3A588
        public RepeatedField<SignedURL> get_Urls()
        {
            return urls_;
        }

        // RVA: 0x1A3A590
        public string get_HostName()
        {
            return hostName_;
        }

        // RVA: 0x1A3A598
        public void set_HostName(string value)
        {
            hostName_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A3A608
        public string get_ResVersion()
        {
            return resVersion_;
        }

        // RVA: 0x1A3A610
        public void set_ResVersion(string value)
        {
            resVersion_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A3A680
        public ByteString get_UrlsPayload()
        {
            return urlsPayload_;
        }

        // RVA: 0x1A3A688
        public void set_UrlsPayload(ByteString value)
        {
            urlsPayload_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A3A6F8
        [DebuggerNonUserCode]
        public override bool Equals(object other)
        {
            return Equals(other as AssetUrlsResponse);
        }

        // RVA: 0x1A3A76C
        [DebuggerNonUserCode]
        public bool Equals(AssetUrlsResponse other)
        {
            if (ReferenceEquals(other, null)) {
                return false;
            }
            if (ReferenceEquals(other, this)) {
                return true;
            }
            if (Status != other.Status) return false;
            if (!urls_.Equals(other.urls_)) return false;
            if (HostName != other.HostName) return false;
            if (ResVersion != other.ResVersion) return false;
            if (UrlsPayload != other.UrlsPayload) return false;
            return Equals(_unknownFields, other._unknownFields);
        }

        // RVA: 0x1A3A884
        [DebuggerNonUserCode]
        public override int GetHashCode()
        {
            int hash = 1;
            if (Status != StatusCode.Ok) hash ^= Status.GetHashCode();
            hash ^= urls_.GetHashCode();
            if (HostName.Length != 0) hash ^= HostName.GetHashCode();
            if (ResVersion.Length != 0) hash ^= ResVersion.GetHashCode();
            if (UrlsPayload.Length != 0) hash ^= UrlsPayload.GetHashCode();
            if (_unknownFields != null) {
                hash ^= _unknownFields.GetHashCode();
            }
            return hash;
        }

        // RVA: 0x1A3A978
        [DebuggerNonUserCode]
        public override string ToString()
        {
            return JsonFormatter.ToDiagnosticString(this);
        }

        // RVA: 0x1A3A9E0
        [DebuggerNonUserCode]
        public void WriteTo(CodedOutputStream output)
        {
            if (Status != StatusCode.Ok) {
                output.WriteRawTag(8);
                output.WriteEnum((int)Status);
            }
            urls_.WriteTo(output, _repeated_urls_codec);
            if (HostName.Length != 0) {
                output.WriteRawTag(26);
                output.WriteString(HostName);
            }
            if (ResVersion.Length != 0) {
                output.WriteRawTag(34);
                output.WriteString(ResVersion);
            }
            if (UrlsPayload.Length != 0) {
                output.WriteRawTag(42);
                output.WriteBytes(UrlsPayload);
            }
            if (_unknownFields != null) {
                _unknownFields.WriteTo(output);
            }
        }

        // RVA: 0x1A3AB68
        [DebuggerNonUserCode]
        public int CalculateSize()
        {
            int size = 0;
            if (Status != StatusCode.Ok) {
                size += 1 + CodedOutputStream.ComputeEnumSize((int)Status);
            }
            size += urls_.CalculateSize(_repeated_urls_codec);
            if (HostName.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(HostName);
            }
            if (ResVersion.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(ResVersion);
            }
            if (UrlsPayload.Length != 0) {
                size += 1 + CodedOutputStream.ComputeBytesSize(UrlsPayload);
            }
            if (_unknownFields != null) {
                size += _unknownFields.CalculateSize();
            }
            return size;
        }

        // RVA: 0x1A3AD2C
        [DebuggerNonUserCode]
        public void MergeFrom(AssetUrlsResponse other)
        {
            if (other == null) {
                return;
            }
            if (other.Status != StatusCode.Ok) {
                Status = other.Status;
            }
            urls_.Add(other.urls_);
            if (other.HostName.Length != 0) {
                HostName = other.HostName;
            }
            if (other.ResVersion.Length != 0) {
                ResVersion = other.ResVersion;
            }
            if (other.UrlsPayload.Length != 0) {
                UrlsPayload = other.UrlsPayload;
            }
            _unknownFields = UnknownFieldSet.MergeFrom(_unknownFields, other._unknownFields);
        }

        // RVA: 0x1A3AE0C
        [DebuggerNonUserCode]
        public void MergeFrom(CodedInputStream input)
        {
            uint tag;
            while ((tag = input.ReadTag()) != 0) {
                switch (tag) {
                    default:
                        _unknownFields = UnknownFieldSet.MergeFieldFrom(_unknownFields, input);
                        break;
                    case 8: {
                        Status = (StatusCode)input.ReadEnum();
                        break;
                    }
                    case 18: {
                        urls_.AddEntriesFrom(input, _repeated_urls_codec);
                        break;
                    }
                    case 26: {
                        HostName = input.ReadString();
                        break;
                    }
                    case 34: {
                        ResVersion = input.ReadString();
                        break;
                    }
                    case 42: {
                        UrlsPayload = input.ReadBytes();
                        break;
                    }
                }
            }
        }

        // RVA: 0x1A3AF84
        static AssetUrlsResponse()
        {
            _repeated_urls_codec = FieldCodec.ForMessage(18, SignedURL.Parser);
            _parser = new MessageParser<AssetUrlsResponse>(() => new AssetUrlsResponse());
        }
    }
}
