// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Game.CommonRequest
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
    public sealed class CommonRequest : IMessage<CommonRequest>, IMessage, IEquatable<CommonRequest>, IDeepCloneable<CommonRequest>
    {
        private static readonly MessageParser<CommonRequest> _parser;
        private UnknownFieldSet _unknownFields;
        public const int PayloadFieldNumber = 1;
        private ByteString payload_;
        public const int SignatureFieldNumber = 2;
        private string signature_;
        public const int PlayerIdFieldNumber = 3;
        private long playerId_;
        public const int PlatformFieldNumber = 4;
        private string platform_;
        public const int IdFieldNumber = 5;
        private string id_;
        public const int LangFieldNumber = 6;
        private string lang_;
        public const int TsFieldNumber = 7;
        private long ts_;
        public const int LuaHashFieldNumber = 8;
        private string luaHash_;
        public const int ResVersionFieldNumber = 9;
        private string resVersion_;
        public const int MainResVersionFieldNumber = 10;
        private string mainResVersion_;
        public static MessageParser<CommonRequest> Parser { get; }
        public static MessageDescriptor Descriptor { get; }
        private MessageDescriptor pb::Google.Protobuf.IMessage.Descriptor { get; }
        public ByteString Payload { get; set; }
        public string Signature { get; set; }
        public long PlayerId { get; set; }
        public string Platform { get; set; }
        public string Id { get; set; }
        public string Lang { get; set; }
        public long Ts { get; set; }
        public string LuaHash { get; set; }
        public string ResVersion { get; set; }
        public string MainResVersion { get; set; }

        // RVA: 0x1A3CE9C
        public static MessageParser<CommonRequest> get_Parser()
        {
            return _parser;
        }

        // RVA: 0x1A3CF04
        public static MessageDescriptor get_Descriptor()
        {
            return CommonReflection.Descriptor.MessageTypes[0];
        }

        // RVA: 0x1A3D020
        private MessageDescriptor pb::Google.Protobuf.IMessage.get_Descriptor()
        {
            return Descriptor;
        }

        // RVA: 0x1A3D07C
        [DebuggerNonUserCode]
        public CommonRequest()
        {
            payload_ = ByteString.Empty;
            signature_ = "";
            platform_ = "";
            id_ = "";
            lang_ = "";
            luaHash_ = "";
            resVersion_ = "";
            mainResVersion_ = "";
        }

        // RVA: 0x1A3D158
        [DebuggerNonUserCode]
        public CommonRequest(CommonRequest other)
        {
            payload_ = other.payload_;
            signature_ = other.signature_;
            playerId_ = other.playerId_;
            platform_ = other.platform_;
            id_ = other.id_;
            lang_ = other.lang_;
            ts_ = other.ts_;
            luaHash_ = other.luaHash_;
            resVersion_ = other.resVersion_;
            mainResVersion_ = other.mainResVersion_;
            _unknownFields = UnknownFieldSet.Clone(other._unknownFields);
        }

        // RVA: 0x1A3D1E4
        [DebuggerNonUserCode]
        public CommonRequest Clone()
        {
            return new CommonRequest(this);
        }

        // RVA: 0x1A3D244
        public ByteString get_Payload()
        {
            return payload_;
        }

        // RVA: 0x1A3D24C
        public void set_Payload(ByteString value)
        {
            payload_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A3D2BC
        public string get_Signature()
        {
            return signature_;
        }

        // RVA: 0x1A3D2C4
        public void set_Signature(string value)
        {
            signature_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A3D334
        public long get_PlayerId()
        {
            return playerId_;
        }

        // RVA: 0x1A3D33C
        public void set_PlayerId(long value)
        {
            playerId_ = value;
        }

        // RVA: 0x1A3D344
        public string get_Platform()
        {
            return platform_;
        }

        // RVA: 0x1A3D34C
        public void set_Platform(string value)
        {
            platform_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A3D3BC
        public string get_Id()
        {
            return id_;
        }

        // RVA: 0x1A3D3C4
        public void set_Id(string value)
        {
            id_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A3D434
        public string get_Lang()
        {
            return lang_;
        }

        // RVA: 0x1A3D43C
        public void set_Lang(string value)
        {
            lang_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A3D4AC
        public long get_Ts()
        {
            return ts_;
        }

        // RVA: 0x1A3D4B4
        public void set_Ts(long value)
        {
            ts_ = value;
        }

        // RVA: 0x1A3D4BC
        public string get_LuaHash()
        {
            return luaHash_;
        }

        // RVA: 0x1A3D4C4
        public void set_LuaHash(string value)
        {
            luaHash_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A3D534
        public string get_ResVersion()
        {
            return resVersion_;
        }

        // RVA: 0x1A3D53C
        public void set_ResVersion(string value)
        {
            resVersion_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A3D5AC
        public string get_MainResVersion()
        {
            return mainResVersion_;
        }

        // RVA: 0x1A3D5B4
        public void set_MainResVersion(string value)
        {
            mainResVersion_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A3D624
        [DebuggerNonUserCode]
        public override bool Equals(object other)
        {
            return Equals(other as CommonRequest);
        }

        // RVA: 0x1A3D698
        [DebuggerNonUserCode]
        public bool Equals(CommonRequest other)
        {
            if (ReferenceEquals(other, null)) {
                return false;
            }
            if (ReferenceEquals(other, this)) {
                return true;
            }
            if (Payload != other.Payload) return false;
            if (Signature != other.Signature) return false;
            if (PlayerId != other.PlayerId) return false;
            if (Platform != other.Platform) return false;
            if (Id != other.Id) return false;
            if (Lang != other.Lang) return false;
            if (Ts != other.Ts) return false;
            if (LuaHash != other.LuaHash) return false;
            if (ResVersion != other.ResVersion) return false;
            if (MainResVersion != other.MainResVersion) return false;
            return Equals(_unknownFields, other._unknownFields);
        }

        // RVA: 0x1A3D800
        [DebuggerNonUserCode]
        public override int GetHashCode()
        {
            int hash = 1;
            if (Payload.Length != 0) hash ^= Payload.GetHashCode();
            if (Signature.Length != 0) hash ^= Signature.GetHashCode();
            if (PlayerId != 0) hash ^= PlayerId.GetHashCode();
            if (Platform.Length != 0) hash ^= Platform.GetHashCode();
            if (Id.Length != 0) hash ^= Id.GetHashCode();
            if (Lang.Length != 0) hash ^= Lang.GetHashCode();
            if (Ts != 0) hash ^= Ts.GetHashCode();
            if (LuaHash.Length != 0) hash ^= LuaHash.GetHashCode();
            if (ResVersion.Length != 0) hash ^= ResVersion.GetHashCode();
            if (MainResVersion.Length != 0) hash ^= MainResVersion.GetHashCode();
            if (_unknownFields != null) {
                hash ^= _unknownFields.GetHashCode();
            }
            return hash;
        }

        // RVA: 0x1A3D994
        [DebuggerNonUserCode]
        public override string ToString()
        {
            return JsonFormatter.ToDiagnosticString(this);
        }

        // RVA: 0x1A3D9FC
        [DebuggerNonUserCode]
        public void WriteTo(CodedOutputStream output)
        {
            if (Payload.Length != 0) {
                output.WriteRawTag(10);
                output.WriteBytes(Payload);
            }
            if (Signature.Length != 0) {
                output.WriteRawTag(18);
                output.WriteString(Signature);
            }
            if (PlayerId != 0) {
                output.WriteRawTag(24);
                output.WriteInt64(PlayerId);
            }
            if (Platform.Length != 0) {
                output.WriteRawTag(34);
                output.WriteString(Platform);
            }
            if (Id.Length != 0) {
                output.WriteRawTag(42);
                output.WriteString(Id);
            }
            if (Lang.Length != 0) {
                output.WriteRawTag(50);
                output.WriteString(Lang);
            }
            if (Ts != 0) {
                output.WriteRawTag(56);
                output.WriteInt64(Ts);
            }
            if (LuaHash.Length != 0) {
                output.WriteRawTag(66);
                output.WriteString(LuaHash);
            }
            if (ResVersion.Length != 0) {
                output.WriteRawTag(74);
                output.WriteString(ResVersion);
            }
            if (MainResVersion.Length != 0) {
                output.WriteRawTag(82);
                output.WriteString(MainResVersion);
            }
            if (_unknownFields != null) {
                _unknownFields.WriteTo(output);
            }
        }

        // RVA: 0x1A3DC38
        [DebuggerNonUserCode]
        public int CalculateSize()
        {
            int size = 0;
            if (Payload.Length != 0) {
                size += 1 + CodedOutputStream.ComputeBytesSize(Payload);
            }
            if (Signature.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(Signature);
            }
            if (PlayerId != 0) {
                size += 1 + CodedOutputStream.ComputeInt64Size(PlayerId);
            }
            if (Platform.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(Platform);
            }
            if (Id.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(Id);
            }
            if (Lang.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(Lang);
            }
            if (Ts != 0) {
                size += 1 + CodedOutputStream.ComputeInt64Size(Ts);
            }
            if (LuaHash.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(LuaHash);
            }
            if (ResVersion.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(ResVersion);
            }
            if (MainResVersion.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(MainResVersion);
            }
            if (_unknownFields != null) {
                size += _unknownFields.CalculateSize();
            }
            return size;
        }

        // RVA: 0x1A3DF40
        [DebuggerNonUserCode]
        public void MergeFrom(CommonRequest other)
        {
            if (other == null) {
                return;
            }
            if (other.Payload.Length != 0) {
                Payload = other.Payload;
            }
            if (other.Signature.Length != 0) {
                Signature = other.Signature;
            }
            if (other.PlayerId != 0) {
                PlayerId = other.PlayerId;
            }
            if (other.Platform.Length != 0) {
                Platform = other.Platform;
            }
            if (other.Id.Length != 0) {
                Id = other.Id;
            }
            if (other.Lang.Length != 0) {
                Lang = other.Lang;
            }
            if (other.Ts != 0) {
                Ts = other.Ts;
            }
            if (other.LuaHash.Length != 0) {
                LuaHash = other.LuaHash;
            }
            if (other.ResVersion.Length != 0) {
                ResVersion = other.ResVersion;
            }
            if (other.MainResVersion.Length != 0) {
                MainResVersion = other.MainResVersion;
            }
            _unknownFields = UnknownFieldSet.MergeFrom(_unknownFields, other._unknownFields);
        }

        // RVA: 0x1A3E05C
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
                        Payload = input.ReadBytes();
                        break;
                    }
                    case 18: {
                        Signature = input.ReadString();
                        break;
                    }
                    case 24: {
                        PlayerId = input.ReadInt64();
                        break;
                    }
                    case 34: {
                        Platform = input.ReadString();
                        break;
                    }
                    case 42: {
                        Id = input.ReadString();
                        break;
                    }
                    case 50: {
                        Lang = input.ReadString();
                        break;
                    }
                    case 56: {
                        Ts = input.ReadInt64();
                        break;
                    }
                    case 66: {
                        LuaHash = input.ReadString();
                        break;
                    }
                    case 74: {
                        ResVersion = input.ReadString();
                        break;
                    }
                    case 82: {
                        MainResVersion = input.ReadString();
                        break;
                    }
                }
            }
        }

        // RVA: 0x1A3E21C
        static CommonRequest()
        {
            _parser = new MessageParser<CommonRequest>(() => new CommonRequest());
        }
    }
}
