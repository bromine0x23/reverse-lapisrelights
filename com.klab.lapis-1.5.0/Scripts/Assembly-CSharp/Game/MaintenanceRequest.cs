// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Game.MaintenanceRequest
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
    public sealed class MaintenanceRequest : IMessage<MaintenanceRequest>, IMessage, IEquatable<MaintenanceRequest>, IDeepCloneable<MaintenanceRequest>
    {
        private static readonly MessageParser<MaintenanceRequest> _parser;
        private UnknownFieldSet _unknownFields;
        public const int PlayerIdFieldNumber = 1;
        private long playerId_;
        public static MessageParser<MaintenanceRequest> Parser { get; }
        private static MessageDescriptor _Descriptor;
        public static MessageDescriptor Descriptor { get { return _Descriptor; } }
        private MessageDescriptor pb::Google.Protobuf.IMessage.Descriptor { get; }
        public long PlayerId { get; set; }

        // RVA: 0x1A41CD8
        public static MessageParser<MaintenanceRequest> get_Parser()
        {
            return _parser;
        }

        // RVA: 0x1A41D40
        public static MessageDescriptor get_Descriptor()
        {
            return CommonReflection.Descriptor.MessageTypes[8];
        }

        // RVA: 0x1A41E5C
        private MessageDescriptor pb::Google.Protobuf.IMessage.get_Descriptor()
        {
            return _Descriptor;
        }

        // RVA: 0x1A41EB8
        [DebuggerNonUserCode]
        public MaintenanceRequest()
        {

        }

        // RVA: 0x1A41EC0
        [DebuggerNonUserCode]
        public MaintenanceRequest(MaintenanceRequest other)
        {
            playerId_ = other.playerId_;
            _unknownFields = UnknownFieldSet.Clone(other._unknownFields);
        }

        // RVA: 0x1A41F08
        [DebuggerNonUserCode]
        public MaintenanceRequest Clone()
        {
            return new MaintenanceRequest(this);
        }

        // RVA: 0x1A41F68
        public long get_PlayerId()
        {
            return playerId_;
        }

        // RVA: 0x1A41F70
        public void set_PlayerId(long value)
        {
            playerId_ = value;
        }

        // RVA: 0x1A41F78
        [DebuggerNonUserCode]
        public override bool Equals(object other)
        {
            return Equals(other as MaintenanceRequest);
        }

        // RVA: 0x1A41FEC
        [DebuggerNonUserCode]
        public bool Equals(MaintenanceRequest other)
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

        // RVA: 0x1A42028
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

        // RVA: 0x1A42090
        [DebuggerNonUserCode]
        public override string ToString()
        {
            return JsonFormatter.ToDiagnosticString(this);
        }

        // RVA: 0x1A420F8
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

        // RVA: 0x1A42164
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

        // RVA: 0x1A421F4
        [DebuggerNonUserCode]
        public void MergeFrom(MaintenanceRequest other)
        {
            if (other == null) {
                return;
            }
            if (other.PlayerId != 0) {
                PlayerId = other.PlayerId;
            }
            _unknownFields = UnknownFieldSet.MergeFrom(_unknownFields, other._unknownFields);
        }

        // RVA: 0x1A42234
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

        // RVA: 0x1A422A0
        static MaintenanceRequest()
        {
            _parser = new MessageParser<MaintenanceRequest>(() => new MaintenanceRequest());
        }
    }
}
