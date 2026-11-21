// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Game.MaintenanceResponse
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
    public sealed partial class MaintenanceResponse : IMessage<MaintenanceResponse>, IMessage, IEquatable<MaintenanceResponse>, IDeepCloneable<MaintenanceResponse>
    {
        private static readonly MessageParser<MaintenanceResponse> _parser;
        private UnknownFieldSet _unknownFields;
        public const int BodyFieldNumber = 1;
        private string body_;
        public const int RefundUrlFieldNumber = 2;
        private string refundUrl_;
        public const int CodeFieldNumber = 3;
        private MaintenanceResponse.Types.ResponseCode code_;
        public static MessageParser<MaintenanceResponse> Parser { get; }
        private static MessageDescriptor _Descriptor;
        public static MessageDescriptor Descriptor { get { return _Descriptor; } }
        private MessageDescriptor pb::Google.Protobuf.IMessage.Descriptor { get; }
        public string Body { get; set; }
        public string RefundUrl { get; set; }
        public MaintenanceResponse.Types.ResponseCode Code { get; set; }

        // RVA: 0x1A42440
        public static MessageParser<MaintenanceResponse> get_Parser()
        {
            return _parser;
        }

        // RVA: 0x1A424A8
        public static MessageDescriptor get_Descriptor()
        {
            return CommonReflection.Descriptor.MessageTypes[9];
        }

        // RVA: 0x1A425C4
        private MessageDescriptor pb::Google.Protobuf.IMessage.get_Descriptor()
        {
            return _Descriptor;
        }

        // RVA: 0x1A42620
        [DebuggerNonUserCode]
        public MaintenanceResponse()
        {
            body_ = "";
            refundUrl_ = "";
        }

        // RVA: 0x1A42678
        [DebuggerNonUserCode]
        public MaintenanceResponse(MaintenanceResponse other)
        {
            body_ = other.body_;
            refundUrl_ = other.refundUrl_;
            code_ = other.code_;
            _unknownFields = UnknownFieldSet.Clone(other._unknownFields);
        }

        // RVA: 0x1A426CC
        [DebuggerNonUserCode]
        public MaintenanceResponse Clone()
        {
            return new MaintenanceResponse(this);
        }

        // RVA: 0x1A4272C
        public string get_Body()
        {
            return body_;
        }

        // RVA: 0x1A42734
        public void set_Body(string value)
        {
            body_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A427A4
        public string get_RefundUrl()
        {
            return refundUrl_;
        }

        // RVA: 0x1A427AC
        public void set_RefundUrl(string value)
        {
            refundUrl_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1A4281C
        public MaintenanceResponse.Types.ResponseCode get_Code()
        {
            return code_;
        }

        // RVA: 0x1A42824
        public void set_Code(MaintenanceResponse.Types.ResponseCode value)
        {
            code_ = value;
        }

        // RVA: 0x1A4282C
        [DebuggerNonUserCode]
        public override bool Equals(object other)
        {
            return Equals(other as MaintenanceResponse);
        }

        // RVA: 0x1A428A0
        [DebuggerNonUserCode]
        public bool Equals(MaintenanceResponse other)
        {
            if (ReferenceEquals(other, null)) {
                return false;
            }
            if (ReferenceEquals(other, this)) {
                return true;
            }
            if (Body != other.Body) return false;
            if (RefundUrl != other.RefundUrl) return false;
            if (Code != other.Code) return false;
            return Equals(_unknownFields, other._unknownFields);
        }

        // RVA: 0x1A42928
        [DebuggerNonUserCode]
        public override int GetHashCode()
        {
            int hash = 1;
            if (Body.Length != 0) hash ^= Body.GetHashCode();
            if (RefundUrl.Length != 0) hash ^= RefundUrl.GetHashCode();
            if (Code != MaintenanceResponse.Types.ResponseCode.Ok) hash ^= Code.GetHashCode();
            if (_unknownFields != null) {
                hash ^= _unknownFields.GetHashCode();
            }
            return hash;
        }

        // RVA: 0x1A429D4
        [DebuggerNonUserCode]
        public override string ToString()
        {
            return JsonFormatter.ToDiagnosticString(this);
        }

        // RVA: 0x1A42A3C
        [DebuggerNonUserCode]
        public void WriteTo(CodedOutputStream output)
        {
            if (Body.Length != 0) {
                output.WriteRawTag(10);
                output.WriteString(Body);
            }
            if (RefundUrl.Length != 0) {
                output.WriteRawTag(18);
                output.WriteString(RefundUrl);
            }
            if (Code != MaintenanceResponse.Types.ResponseCode.Ok) {
                output.WriteRawTag(24);
                output.WriteEnum((int)Code);
            }
            if (_unknownFields != null) {
                _unknownFields.WriteTo(output);
            }
        }

        // RVA: 0x1A42B10
        [DebuggerNonUserCode]
        public int CalculateSize()
        {
            int size = 0;
            if (Body.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(Body);
            }
            if (RefundUrl.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(RefundUrl);
            }
            if (Code != MaintenanceResponse.Types.ResponseCode.Ok) {
                size += 1 + CodedOutputStream.ComputeEnumSize((int)Code);
            }
            if (_unknownFields != null) {
                size += _unknownFields.CalculateSize();
            }
            return size;
        }

        // RVA: 0x1A42C3C
        [DebuggerNonUserCode]
        public void MergeFrom(MaintenanceResponse other)
        {
            if (other == null) {
                return;
            }
            if (other.Body.Length != 0) {
                Body = other.Body;
            }
            if (other.RefundUrl.Length != 0) {
                RefundUrl = other.RefundUrl;
            }
            if (other.Code != MaintenanceResponse.Types.ResponseCode.Ok) {
                Code = other.Code;
            }
            _unknownFields = UnknownFieldSet.MergeFrom(_unknownFields, other._unknownFields);
        }

        // RVA: 0x1A42CB4
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
                        Body = input.ReadString();
                        break;
                    }
                    case 18: {
                        RefundUrl = input.ReadString();
                        break;
                    }
                    case 24: {
                        Code = (MaintenanceResponse.Types.ResponseCode)input.ReadEnum();
                        break;
                    }
                }
            }
        }

        // RVA: 0x1A42D70
        static MaintenanceResponse()
        {
            _parser = new MessageParser<MaintenanceResponse>(() => new MaintenanceResponse());
        }
    }
}
