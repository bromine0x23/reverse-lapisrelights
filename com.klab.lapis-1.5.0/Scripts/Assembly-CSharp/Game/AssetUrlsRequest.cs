// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Game.AssetUrlsRequest
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
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
    public sealed class AssetUrlsRequest : IMessage<AssetUrlsRequest>, IMessage, IEquatable<AssetUrlsRequest>, IDeepCloneable<AssetUrlsRequest>
    {
        private static readonly MessageParser<AssetUrlsRequest> _parser;
        private UnknownFieldSet _unknownFields;
        public const int PlatformFieldNumber = 1;
        private string platform_;
        public const int LangFieldNumber = 2;
        private string lang_;
        public const int AssetKeysFieldNumber = 3;
        private static readonly FieldCodec<string> _repeated_assetKeys_codec;
        private readonly RepeatedField<string> assetKeys_;
        public const int ResVersionFieldNumber = 4;
        private string resVersion_;
        public static MessageParser<AssetUrlsRequest> Parser { get; }
        public static MessageDescriptor Descriptor { get; }
        private MessageDescriptor pb::Google.Protobuf.IMessage.Descriptor { get; }
        public string Platform { get; set; }
        public string Lang { get; set; }
        public RepeatedField<string> AssetKeys { get; }
        public string ResVersion { get; set; }

        // RVA: 0x1A39390
        public static MessageParser<AssetUrlsRequest> get_Parser()
        {
            return _parser;
        }

        // RVA: 0x1A393F8
        public static MessageDescriptor get_Descriptor()
        {
            return CommonReflection.Descriptor.MessageTypes[2];
        }

        // RVA: 0x1A39514
        private MessageDescriptor pb::Google.Protobuf.IMessage.get_Descriptor()
        {
            return Descriptor;
        }

        // RVA: 0x1A39570
        [DebuggerNonUserCode]
        public AssetUrlsRequest()
        {
            platform_ = "";
            lang_ = "";
            assetKeys_ = new RepeatedField<string>();
            resVersion_ = "";
        }

        // RVA: 0x1A395FC
        [DebuggerNonUserCode]
        public AssetUrlsRequest(AssetUrlsRequest other)
        {
            platform_ = other.platform_;
            lang_ = other.lang_;
            assetKeys_ = other.assetKeys_.Clone();
            resVersion_ = other.resVersion_;
            _unknownFields = UnknownFieldSet.Clone(other._unknownFields);
        }

        // RVA: 0x1A3969C
        [DebuggerNonUserCode]
        public AssetUrlsRequest Clone()
        {
            return new AssetUrlsRequest(this);
        }

        // RVA: 0x1A396FC
        public string get_Platform()
        {
            return platform_;
        }

        // RVA: 0x1A39704
        public void set_Platform(string value)
        {
            platform_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A39774
        public string get_Lang()
        {
            return lang_;
        }

        // RVA: 0x1A3977C
        public void set_Lang(string value)
        {
            lang_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A397EC
        public RepeatedField<string> get_AssetKeys()
        {
            return assetKeys_;
        }

        // RVA: 0x1A397F4
        public string get_ResVersion()
        {
            return resVersion_;
        }

        // RVA: 0x1A397FC
        public void set_ResVersion(string value)
        {
            resVersion_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A3986C
        [DebuggerNonUserCode]
        public override bool Equals(object other)
        {
            return Equals(other as AssetUrlsRequest);
        }

        // RVA: 0x1A398E0
        [DebuggerNonUserCode]
        public bool Equals(AssetUrlsRequest other)
        {
            if (ReferenceEquals(other, null)) {
                return false;
            }
            if (ReferenceEquals(other, this)) {
                return true;
            }
            if (Platform != other.Platform) return false;
            if (Lang != other.Lang) return false;
            if (!assetKeys_.Equals(other.assetKeys_)) return false;
            if (ResVersion != other.ResVersion) return false;
            return Equals(_unknownFields, other._unknownFields);
        }

        // RVA: 0x1A399C0
        [DebuggerNonUserCode]
        public override int GetHashCode()
        {
            int hash = 1;
            if (Platform.Length != 0) hash ^= Platform.GetHashCode();
            if (Lang.Length != 0) hash ^= Lang.GetHashCode();
            hash ^= assetKeys_.GetHashCode();
            if (ResVersion.Length != 0) hash ^= ResVersion.GetHashCode();
            if (_unknownFields != null) {
                hash ^= _unknownFields.GetHashCode();
            }
            return hash;
        }

        // RVA: 0x1A39A80
        [DebuggerNonUserCode]
        public override string ToString()
        {
            return JsonFormatter.ToDiagnosticString(this);
        }

        // RVA: 0x1A39AE8
        [DebuggerNonUserCode]
        public void WriteTo(CodedOutputStream output)
        {
            if (Platform.Length != 0) {
                output.WriteRawTag(10);
                output.WriteString(Platform);
            }
            if (Lang.Length != 0) {
                output.WriteRawTag(18);
                output.WriteString(Lang);
            }
            assetKeys_.WriteTo(output, _repeated_assetKeys_codec);
            if (ResVersion.Length != 0) {
                output.WriteRawTag(34);
                output.WriteString(ResVersion);
            }
            if (_unknownFields != null) {
                _unknownFields.WriteTo(output);
            }
        }

        // RVA: 0x1A39C40
        [DebuggerNonUserCode]
        public int CalculateSize()
        {
            int size = 0;
            if (Platform.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(Platform);
            }
            if (Lang.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(Lang);
            }
            size += assetKeys_.CalculateSize(_repeated_assetKeys_codec);
            if (ResVersion.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(ResVersion);
            }
            if (_unknownFields != null) {
                size += _unknownFields.CalculateSize();
            }
            return size;
        }

        // RVA: 0x1A39DC0
        [DebuggerNonUserCode]
        public void MergeFrom(AssetUrlsRequest other)
        {
            if (other == null) {
                return;
            }
            if (other.Platform.Length != 0) {
                Platform = other.Platform;
            }
            if (other.Lang.Length != 0) {
                Lang = other.Lang;
            }
            assetKeys_.Add(other.assetKeys_);
            if (other.ResVersion.Length != 0) {
                ResVersion = other.ResVersion;
            }
            _unknownFields = UnknownFieldSet.MergeFrom(_unknownFields, other._unknownFields);
        }

        // RVA: 0x1A39E8C
        [DebuggerNonUserCode]
        public void MergeFrom(CodedInputStream input)
        {
            uint tag;
            while ((tag = input.ReadTag()) != 0) {
                switch (tag) {
                    default:
                        _unknownFields = UnknownFieldSet.MergeFieldFrom(_unknownFields, input);
                        break;
                    case 10: {
                        Platform = input.ReadString();
                        break;
                    }
                    case 18: {
                        Lang = input.ReadString();
                        break;
                    }
                    case 26: {
                        assetKeys_.AddEntriesFrom(input, _repeated_assetKeys_codec);
                        break;
                    }
                    case 34: {
                        ResVersion = input.ReadString();
                        break;
                    }
                }
            }
        }

        // RVA: 0x1A39FE8
        static AssetUrlsRequest()
        {
            _repeated_assetKeys_codec = FieldCodec.ForString(26);
            _parser = new MessageParser<AssetUrlsRequest>(() => new AssetUrlsRequest());
        }
    }
}
