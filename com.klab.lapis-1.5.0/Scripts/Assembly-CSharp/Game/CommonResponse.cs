// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Game.CommonResponse
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
    public sealed class CommonResponse : IMessage<CommonResponse>, IMessage, IEquatable<CommonResponse>, IDeepCloneable<CommonResponse>
    {
        private static readonly MessageParser<CommonResponse> _parser;
        private UnknownFieldSet _unknownFields;
        public const int PayloadFieldNumber = 1;
        private ByteString payload_;
        public const int SignatureFieldNumber = 2;
        private string signature_;
        public const int StatusFieldNumber = 3;
        private StatusCode status_;
        public const int ResVerFieldNumber = 4;
        private string resVer_;
        public const int TsFieldNumber = 5;
        private long ts_;
        public static MessageParser<CommonResponse> Parser { get; }
        private static MessageDescriptor _Descriptor;
        public static MessageDescriptor Descriptor { get { return _Descriptor; } }
        private MessageDescriptor pb::Google.Protobuf.IMessage.Descriptor { get; }
        public ByteString Payload { get; set; }
        public string Signature { get; set; }
        public StatusCode Status { get; set; }
        public string ResVer { get; set; }
        public long Ts { get; set; }

        // RVA: 0x1A3E3B8
        public static MessageParser<CommonResponse> get_Parser()
        {
            return _parser;
        }

        // RVA: 0x1A3E420
        public static MessageDescriptor get_Descriptor()
        {
            return CommonReflection.Descriptor.MessageTypes[1];
        }

        // RVA: 0x1A3E53C
        private MessageDescriptor pb::Google.Protobuf.IMessage.get_Descriptor()
        {
            return _Descriptor;
        }

        // RVA: 0x1A3E598
        [DebuggerNonUserCode]
        public CommonResponse()
        {
            payload_ = ByteString.Empty;
            signature_ = "";
            resVer_ = "";
        }

        // RVA: 0x1A3E668
        [DebuggerNonUserCode]
        public CommonResponse(CommonResponse other)
        {
            payload_ = other.payload_;
            signature_ = other.signature_;
            status_ = other.status_;
            resVer_ = other.resVer_;
            ts_ = other.ts_;
            _unknownFields = UnknownFieldSet.Clone(other._unknownFields);
        }

        // RVA: 0x1A3E6CC
        [DebuggerNonUserCode]
        public CommonResponse Clone()
        {
            return new CommonResponse(this);
        }

        // RVA: 0x1A3E72C
        public ByteString get_Payload()
        {
            return payload_;
        }

        // RVA: 0x1A3E734
        public void set_Payload(ByteString value)
        {
            payload_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A3E7A4
        public string get_Signature()
        {
            return signature_;
        }

        // RVA: 0x1A3E7AC
        public void set_Signature(string value)
        {
            signature_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A3E81C
        public StatusCode get_Status()
        {
            return status_;
        }

        // RVA: 0x1A3E824
        public void set_Status(StatusCode value)
        {
            status_ = value;
        }

        // RVA: 0x1A3E82C
        public string get_ResVer()
        {
            return resVer_;
        }

        // RVA: 0x1A3E834
        public void set_ResVer(string value)
        {
            resVer_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A3E8A4
        public long get_Ts()
        {
            return ts_;
        }

        // RVA: 0x1A3E8AC
        public void set_Ts(long value)
        {
            ts_ = value;
        }

        // RVA: 0x1A3E8B4
        [DebuggerNonUserCode]
        public override bool Equals(object other)
        {
            return Equals(other as CommonResponse);
        }

        // RVA: 0x1A3E928
        [DebuggerNonUserCode]
        public bool Equals(CommonResponse other)
        {
            if (ReferenceEquals(other, null)) {
                return false;
            }
            if (ReferenceEquals(other, this)) {
                return true;
            }
            if (Payload != other.Payload) return false;
            if (Signature != other.Signature) return false;
            if (Status != other.Status) return false;
            if (ResVer != other.ResVer) return false;
            if (Ts != other.Ts) return false;
            return Equals(_unknownFields, other._unknownFields);
        }

        // RVA: 0x1A3EA2C
        [DebuggerNonUserCode]
        public override int GetHashCode()
        {
            int hash = 1;
            if (Payload.Length != 0) hash ^= Payload.GetHashCode();
            if (Signature.Length != 0) hash ^= Signature.GetHashCode();
            if (Status != StatusCode.Ok) hash ^= Status.GetHashCode();
            if (ResVer.Length != 0) hash ^= ResVer.GetHashCode();
            if (Ts != 0) hash ^= Ts.GetHashCode();
            if (_unknownFields != null) {
                hash ^= _unknownFields.GetHashCode();
            }
            return hash;
        }

        // RVA: 0x1A3EB24
        [DebuggerNonUserCode]
        public override string ToString()
        {
            return JsonFormatter.ToDiagnosticString(this);
        }

        // RVA: 0x1A3EB8C
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
            if (Status != StatusCode.Ok) {
                output.WriteRawTag(24);
                output.WriteEnum((int)Status);
            }
            if (ResVer.Length != 0) {
                output.WriteRawTag(34);
                output.WriteString(ResVer);
            }
            if (Ts != 0) {
                output.WriteRawTag(40);
                output.WriteInt64(Ts);
            }
            if (_unknownFields != null) {
                _unknownFields.WriteTo(output);
            }
        }

        // RVA: 0x1A3ECC4
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
            if (Status != StatusCode.Ok) {
                size += 1 + CodedOutputStream.ComputeEnumSize((int)Status);
            }
            if (ResVer.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(ResVer);
            }
            if (Ts != 0) {
                size += 1 + CodedOutputStream.ComputeInt64Size(Ts);
            }
            if (_unknownFields != null) {
                size += _unknownFields.CalculateSize();
            }
            return size;
        }

        // RVA: 0x1A3EE78
        [DebuggerNonUserCode]
        public void MergeFrom(CommonResponse other)
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
            if (other.Status != StatusCode.Ok) {
                Status = other.Status;
            }
            if (other.ResVer.Length != 0) {
                ResVer = other.ResVer;
            }
            if (other.Ts != 0) {
                Ts = other.Ts;
            }
            _unknownFields = UnknownFieldSet.MergeFrom(_unknownFields, other._unknownFields);
        }

        // RVA: 0x1A3EF1C
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
                        Status = (StatusCode)input.ReadEnum();
                        break;
                    }
                    case 34: {
                        ResVer = input.ReadString();
                        break;
                    }
                    case 40: {
                        Ts = input.ReadInt64();
                        break;
                    }
                }
            }
        }

        // RVA: 0x1A3F018
        static CommonResponse()
        {
            _parser = new MessageParser<CommonResponse>(() => new CommonResponse());
        }
    }
}
