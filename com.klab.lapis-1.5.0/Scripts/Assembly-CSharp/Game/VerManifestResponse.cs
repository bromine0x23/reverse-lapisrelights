// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Game.VerManifestResponse
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
    public sealed class VerManifestResponse : IMessage<VerManifestResponse>, IMessage, IEquatable<VerManifestResponse>, IDeepCloneable<VerManifestResponse>
    {
        private static readonly MessageParser<VerManifestResponse> _parser;
        private UnknownFieldSet _unknownFields;
        public const int ResVerFieldNumber = 1;
        private string resVer_;
        public const int MainResVerFieldNumber = 2;
        private string mainResVer_;
        public static MessageParser<VerManifestResponse> Parser { get; }
        private static MessageDescriptor _Descriptor;
        public static MessageDescriptor Descriptor { get { return _Descriptor; } }
        private MessageDescriptor pb::Google.Protobuf.IMessage.Descriptor { get; }
        public string ResVer { get; set; }
        public string MainResVer { get; set; }

        // RVA: 0x192A188
        public static MessageParser<VerManifestResponse> get_Parser()
        {
            return _parser;
        }

        // RVA: 0x192A1F0
        public static MessageDescriptor get_Descriptor()
        {
            return CommonReflection.Descriptor.MessageTypes[7];
        }

        // RVA: 0x192A30C
        private MessageDescriptor pb::Google.Protobuf.IMessage.get_Descriptor()
        {
            return _Descriptor;
        }

        // RVA: 0x192A368
        [DebuggerNonUserCode]
        public VerManifestResponse()
        {
            resVer_ = "";
            mainResVer_ = "";
        }

        // RVA: 0x192A3C0
        [DebuggerNonUserCode]
        public VerManifestResponse(VerManifestResponse other)
        {
            resVer_ = other.resVer_;
            mainResVer_ = other.mainResVer_;
            _unknownFields = UnknownFieldSet.Clone(other._unknownFields);
        }

        // RVA: 0x192A40C
        [DebuggerNonUserCode]
        public VerManifestResponse Clone()
        {
            return new VerManifestResponse(this);
        }

        // RVA: 0x192A46C
        public string get_ResVer()
        {
            return resVer_;
        }

        // RVA: 0x192A474
        public void set_ResVer(string value)
        {
            resVer_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x192A4E4
        public string get_MainResVer()
        {
            return mainResVer_;
        }

        // RVA: 0x192A4EC
        public void set_MainResVer(string value)
        {
            mainResVer_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x192A55C
        [DebuggerNonUserCode]
        public override bool Equals(object other)
        {
            return Equals(other as VerManifestResponse);
        }

        // RVA: 0x192A5D0
        [DebuggerNonUserCode]
        public bool Equals(VerManifestResponse other)
        {
            if (ReferenceEquals(other, null)) {
                return false;
            }
            if (ReferenceEquals(other, this)) {
                return true;
            }
            if (ResVer != other.ResVer) return false;
            if (MainResVer != other.MainResVer) return false;
            return Equals(_unknownFields, other._unknownFields);
        }

        // RVA: 0x192A648
        [DebuggerNonUserCode]
        public override int GetHashCode()
        {
            int hash = 1;
            if (ResVer.Length != 0) hash ^= ResVer.GetHashCode();
            if (MainResVer.Length != 0) hash ^= MainResVer.GetHashCode();
            if (_unknownFields != null) {
                hash ^= _unknownFields.GetHashCode();
            }
            return hash;
        }

        // RVA: 0x192A6CC
        [DebuggerNonUserCode]
        public override string ToString()
        {
            return JsonFormatter.ToDiagnosticString(this);
        }

        // RVA: 0x192A734
        [DebuggerNonUserCode]
        public void WriteTo(CodedOutputStream output)
        {
            if (ResVer.Length != 0) {
                output.WriteRawTag(10);
                output.WriteString(ResVer);
            }
            if (MainResVer.Length != 0) {
                output.WriteRawTag(18);
                output.WriteString(MainResVer);
            }
            if (_unknownFields != null) {
                _unknownFields.WriteTo(output);
            }
        }

        // RVA: 0x192A7DC
        [DebuggerNonUserCode]
        public int CalculateSize()
        {
            int size = 0;
            if (ResVer.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(ResVer);
            }
            if (MainResVer.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(MainResVer);
            }
            if (_unknownFields != null) {
                size += _unknownFields.CalculateSize();
            }
            return size;
        }

        // RVA: 0x192A8CC
        [DebuggerNonUserCode]
        public void MergeFrom(VerManifestResponse other)
        {
            if (other == null) {
                return;
            }
            if (other.ResVer.Length != 0) {
                ResVer = other.ResVer;
            }
            if (other.MainResVer.Length != 0) {
                MainResVer = other.MainResVer;
            }
            _unknownFields = UnknownFieldSet.MergeFrom(_unknownFields, other._unknownFields);
        }

        // RVA: 0x192A938
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
                        ResVer = input.ReadString();
                        break;
                    }
                    case 18: {
                        MainResVer = input.ReadString();
                        break;
                    }
                }
            }
        }

        // RVA: 0x192A9D0
        static VerManifestResponse()
        {
            _parser = new MessageParser<VerManifestResponse>(() => new VerManifestResponse());
        }
    }
}
