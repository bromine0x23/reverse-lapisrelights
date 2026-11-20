// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Game.RefundUrlRequest
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
    public sealed class RefundUrlRequest : IMessage<RefundUrlRequest>, IMessage, IEquatable<RefundUrlRequest>, IDeepCloneable<RefundUrlRequest>
    {
        private static readonly MessageParser<RefundUrlRequest> _parser;
        private UnknownFieldSet _unknownFields;
        public const int PlayerIdFieldNumber = 1;
        private long playerId_;
        public static MessageParser<RefundUrlRequest> Parser { get; }
        public static MessageDescriptor Descriptor { get; }
        private MessageDescriptor pb::Google.Protobuf.IMessage.Descriptor { get; }
        public long PlayerId { get; set; }

        // RVA: 0x19273D0
        public static MessageParser<RefundUrlRequest> get_Parser()
        {
            return _parser;
        }

        // RVA: 0x1927438
        public static MessageDescriptor get_Descriptor()
        {
            return CommonReflection.Descriptor.MessageTypes[10];
        }

        // RVA: 0x1927554
        private MessageDescriptor pb::Google.Protobuf.IMessage.get_Descriptor()
        {
            return Descriptor;
        }

        // RVA: 0x19275B0
        [DebuggerNonUserCode]
        public RefundUrlRequest()
        {

        }

        // RVA: 0x19275B8
        [DebuggerNonUserCode]
        public RefundUrlRequest(RefundUrlRequest other)
        {
            playerId_ = other.playerId_;
            _unknownFields = UnknownFieldSet.Clone(other._unknownFields);
        }

        // RVA: 0x1927600
        [DebuggerNonUserCode]
        public RefundUrlRequest Clone()
        {
            return new RefundUrlRequest(this);
        }

        // RVA: 0x1927660
        public long get_PlayerId()
        {
            return playerId_;
        }

        // RVA: 0x1927668
        public void set_PlayerId(long value)
        {
            playerId_ = value;
        }

        // RVA: 0x1927670
        [DebuggerNonUserCode]
        public override bool Equals(object other)
        {
            return Equals(other as RefundUrlRequest);
        }

        // RVA: 0x19276E4
        [DebuggerNonUserCode]
        public bool Equals(RefundUrlRequest other)
        {
            if (ReferenceEquals(other, null)) {
                return false;
            }
            if (ReferenceEquals(other, this)) {
                return true;
            }
            if (PlayerId != other.PlayerId) return false;
            return Equals(_unknownFields, other._unknownFields);
        }

        // RVA: 0x1927720
        [DebuggerNonUserCode]
        public override int GetHashCode()
        {
            int hash = 1;
            if (PlayerId != 0) hash ^= PlayerId.GetHashCode();
            if (_unknownFields != null) {
                hash ^= _unknownFields.GetHashCode();
            }
            return hash;
        }

        // RVA: 0x1927788
        [DebuggerNonUserCode]
        public override string ToString()
        {
            return JsonFormatter.ToDiagnosticString(this);
        }

        // RVA: 0x19277F0
        [DebuggerNonUserCode]
        public void WriteTo(CodedOutputStream output)
        {
            if (PlayerId != 0) {
                output.WriteRawTag(8);
                output.WriteInt64(PlayerId);
            }
            if (_unknownFields != null) {
                _unknownFields.WriteTo(output);
            }
        }

        // RVA: 0x192785C
        [DebuggerNonUserCode]
        public int CalculateSize()
        {
            int size = 0;
            if (PlayerId != 0) {
                size += 1 + CodedOutputStream.ComputeInt64Size(PlayerId);
            }
            if (_unknownFields != null) {
                size += _unknownFields.CalculateSize();
            }
            return size;
        }

        // RVA: 0x19278EC
        [DebuggerNonUserCode]
        public void MergeFrom(RefundUrlRequest other)
        {
            if (other == null) {
                return;
            }
            if (other.PlayerId != 0) {
                PlayerId = other.PlayerId;
            }
            _unknownFields = UnknownFieldSet.MergeFrom(_unknownFields, other._unknownFields);
        }

        // RVA: 0x192792C
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
                        PlayerId = input.ReadInt64();
                        break;
                    }
                }
            }
        }

        // RVA: 0x1927998
        static RefundUrlRequest()
        {
            _parser = new MessageParser<RefundUrlRequest>(() => new RefundUrlRequest());
        }
    }
}
