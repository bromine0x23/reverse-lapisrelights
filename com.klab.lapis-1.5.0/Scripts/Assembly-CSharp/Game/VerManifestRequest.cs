// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Game.VerManifestRequest
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
    public sealed class VerManifestRequest : IMessage<VerManifestRequest>, IMessage, IEquatable<VerManifestRequest>, IDeepCloneable<VerManifestRequest>
    {
        private static readonly MessageParser<VerManifestRequest> _parser;
        private UnknownFieldSet _unknownFields;
        public const int PlatformFieldNumber = 1;
        private string platform_;
        public const int LangFieldNumber = 2;
        private string lang_;
        public static MessageParser<VerManifestRequest> Parser { get; }
        public static MessageDescriptor Descriptor { get; }
        private MessageDescriptor pb::Google.Protobuf.IMessage.Descriptor { get; }
        public string Platform { get; set; }
        public string Lang { get; set; }

        // RVA: 0x19297A4
        public static MessageParser<VerManifestRequest> get_Parser()
        {
            return _parser;
        }

        // RVA: 0x192980C
        public static MessageDescriptor get_Descriptor()
        {
            return CommonReflection.Descriptor.MessageTypes[6];
        }

        // RVA: 0x1929928
        private MessageDescriptor pb::Google.Protobuf.IMessage.get_Descriptor()
        {
            return Descriptor;
        }

        // RVA: 0x1929984
        [DebuggerNonUserCode]
        public VerManifestRequest()
        {
            platform_ = "";
            lang_ = "";
        }

        // RVA: 0x19299DC
        [DebuggerNonUserCode]
        public VerManifestRequest(VerManifestRequest other)
        {
            platform_ = other.platform_;
            lang_ = other.lang_;
            _unknownFields = UnknownFieldSet.Clone(other._unknownFields);
        }

        // RVA: 0x1929A28
        [DebuggerNonUserCode]
        public VerManifestRequest Clone()
        {
            return new VerManifestRequest(this);
        }

        // RVA: 0x1929A88
        public string get_Platform()
        {
            return platform_;
        }

        // RVA: 0x1929A90
        public void set_Platform(string value)
        {
            platform_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1929B00
        public string get_Lang()
        {
            return lang_;
        }

        // RVA: 0x1929B08
        public void set_Lang(string value)
        {
            lang_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1929B78
        [DebuggerNonUserCode]
        public override bool Equals(object other)
        {
            return Equals(other as VerManifestRequest);
        }

        // RVA: 0x1929BEC
        [DebuggerNonUserCode]
        public bool Equals(VerManifestRequest other)
        {
            if (ReferenceEquals(other, null)) {
                return false;
            }
            if (ReferenceEquals(other, this)) {
                return true;
            }
            if (Platform != other.Platform) return false;
            if (Lang != other.Lang) return false;
            return Equals(_unknownFields, other._unknownFields);
        }

        // RVA: 0x1929C64
        [DebuggerNonUserCode]
        public override int GetHashCode()
        {
            int hash = 1;
            if (Platform.Length != 0) hash ^= Platform.GetHashCode();
            if (Lang.Length != 0) hash ^= Lang.GetHashCode();
            if (_unknownFields != null) {
                hash ^= _unknownFields.GetHashCode();
            }
            return hash;
        }

        // RVA: 0x1929CE8
        [DebuggerNonUserCode]
        public override string ToString()
        {
            return JsonFormatter.ToDiagnosticString(this);
        }

        // RVA: 0x1929D50
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
            if (_unknownFields != null) {
                _unknownFields.WriteTo(output);
            }
        }

        // RVA: 0x1929DF8
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
            if (_unknownFields != null) {
                size += _unknownFields.CalculateSize();
            }
            return size;
        }

        // RVA: 0x1929EE8
        [DebuggerNonUserCode]
        public void MergeFrom(VerManifestRequest other)
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
            _unknownFields = UnknownFieldSet.MergeFrom(_unknownFields, other._unknownFields);
        }

        // RVA: 0x1929F54
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
                }
            }
        }

        // RVA: 0x1929FEC
        static VerManifestRequest()
        {
            _parser = new MessageParser<VerManifestRequest>(() => new VerManifestRequest());
        }
    }
}
