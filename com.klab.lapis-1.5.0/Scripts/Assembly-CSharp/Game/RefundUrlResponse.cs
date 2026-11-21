// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Game.RefundUrlResponse
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
    public sealed class RefundUrlResponse : IMessage<RefundUrlResponse>, IMessage, IEquatable<RefundUrlResponse>, IDeepCloneable<RefundUrlResponse>
    {
        private static readonly MessageParser<RefundUrlResponse> _parser;
        private UnknownFieldSet _unknownFields;
        public const int UrlFieldNumber = 1;
        private string url_;
        public static MessageParser<RefundUrlResponse> Parser { get; }
        private static MessageDescriptor _Descriptor;
        public static MessageDescriptor Descriptor { get { return _Descriptor; } }
        private MessageDescriptor pb::Google.Protobuf.IMessage.Descriptor { get; }
        public string Url { get; set; }

        // RVA: 0x1927B38
        public static MessageParser<RefundUrlResponse> get_Parser()
        {
            return _parser;
        }

        // RVA: 0x1927BA0
        public static MessageDescriptor get_Descriptor()
        {
            return CommonReflection.Descriptor.MessageTypes[11];
        }

        // RVA: 0x1927CBC
        private MessageDescriptor pb::Google.Protobuf.IMessage.get_Descriptor()
        {
            return _Descriptor;
        }

        // RVA: 0x1927D18
        [DebuggerNonUserCode]
        public RefundUrlResponse()
        {
            url_ = "";
        }

        // RVA: 0x1927D70
        [DebuggerNonUserCode]
        public RefundUrlResponse(RefundUrlResponse other)
        {
            url_ = other.url_;
            _unknownFields = UnknownFieldSet.Clone(other._unknownFields);
        }

        // RVA: 0x1927DB4
        [DebuggerNonUserCode]
        public RefundUrlResponse Clone()
        {
            return new RefundUrlResponse(this);
        }

        // RVA: 0x1927E14
        public string get_Url()
        {
            return url_;
        }

        // RVA: 0x1927E1C
        public void set_Url(string value)
        {
            url_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1927E8C
        [DebuggerNonUserCode]
        public override bool Equals(object other)
        {
            return Equals(other as RefundUrlResponse);
        }

        // RVA: 0x1927F00
        [DebuggerNonUserCode]
        public bool Equals(RefundUrlResponse other)
        {
            if (ReferenceEquals(other, null)) {
                return false;
            }
            if (ReferenceEquals(other, this)) {
                return true;
            }
            if (Url != other.Url) return false;
            return Equals(_unknownFields, other._unknownFields);
        }

        // RVA: 0x1927F64
        [DebuggerNonUserCode]
        public override int GetHashCode()
        {
            int hash = 1;
            if (Url.Length != 0) hash ^= Url.GetHashCode();
            if (_unknownFields != null) {
                hash ^= _unknownFields.GetHashCode();
            }
            return hash;
        }

        // RVA: 0x1927FC8
        [DebuggerNonUserCode]
        public override string ToString()
        {
            return JsonFormatter.ToDiagnosticString(this);
        }

        // RVA: 0x1928030
        [DebuggerNonUserCode]
        public void WriteTo(CodedOutputStream output)
        {
            if (Url.Length != 0) {
                output.WriteRawTag(10);
                output.WriteString(Url);
            }
            if (_unknownFields != null) {
                _unknownFields.WriteTo(output);
            }
        }

        // RVA: 0x19280A4
        [DebuggerNonUserCode]
        public int CalculateSize()
        {
            int size = 0;
            if (Url.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(Url);
            }
            if (_unknownFields != null) {
                size += _unknownFields.CalculateSize();
            }
            return size;
        }

        // RVA: 0x1928148
        [DebuggerNonUserCode]
        public void MergeFrom(RefundUrlResponse other)
        {
            if (other == null) {
                return;
            }
            if (other.Url.Length != 0) {
                Url = other.Url;
            }
            _unknownFields = UnknownFieldSet.MergeFrom(_unknownFields, other._unknownFields);
        }

        // RVA: 0x192819C
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
                        Url = input.ReadString();
                        break;
                    }
                }
            }
        }

        // RVA: 0x1928210
        static RefundUrlResponse()
        {
            _parser = new MessageParser<RefundUrlResponse>(() => new RefundUrlResponse());
        }
    }
}
