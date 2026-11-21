// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Game.SignedURL
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
    public sealed class SignedURL : IMessage<SignedURL>, IMessage, IEquatable<SignedURL>, IDeepCloneable<SignedURL>
    {
        private static readonly MessageParser<SignedURL> _parser;
        private UnknownFieldSet _unknownFields;
        public const int PackHashFieldNumber = 1;
        private string packHash_;
        public const int SignedSegFieldNumber = 2;
        private string signedSeg_;
        public static MessageParser<SignedURL> Parser { get; }
        private static MessageDescriptor _Descriptor;
        public static MessageDescriptor Descriptor { get { return _Descriptor; } }
        private MessageDescriptor pb::Google.Protobuf.IMessage.Descriptor { get; }
        public string PackHash { get; set; }
        public string SignedSeg { get; set; }

        // RVA: 0x19283AC
        public static MessageParser<SignedURL> get_Parser()
        {
            return _parser;
        }

        // RVA: 0x1928414
        public static MessageDescriptor get_Descriptor()
        {
            return CommonReflection.Descriptor.MessageTypes[3];
        }

        // RVA: 0x1928530
        private MessageDescriptor pb::Google.Protobuf.IMessage.get_Descriptor()
        {
            return _Descriptor;
        }

        // RVA: 0x192858C
        [DebuggerNonUserCode]
        public SignedURL()
        {
            packHash_ = "";
            signedSeg_ = "";
        }

        // RVA: 0x19285E4
        [DebuggerNonUserCode]
        public SignedURL(SignedURL other)
        {
            packHash_ = other.packHash_;
            signedSeg_ = other.signedSeg_;
            _unknownFields = UnknownFieldSet.Clone(other._unknownFields);
        }

        // RVA: 0x1928630
        [DebuggerNonUserCode]
        public SignedURL Clone()
        {
            return new SignedURL(this);
        }

        // RVA: 0x1928690
        public string get_PackHash()
        {
            return packHash_;
        }

        // RVA: 0x1928698
        public void set_PackHash(string value)
        {
            packHash_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1928708
        public string get_SignedSeg()
        {
            return signedSeg_;
        }

        // RVA: 0x1928710
        public void set_SignedSeg(string value)
        {
            signedSeg_ = ProtoPreconditions.CheckNotNull(value, "value");
        }

        // RVA: 0x1928780
        [DebuggerNonUserCode]
        public override bool Equals(object other)
        {
            return Equals(other as SignedURL);
        }

        // RVA: 0x19287F4
        [DebuggerNonUserCode]
        public bool Equals(SignedURL other)
        {
            if (ReferenceEquals(other, null)) {
                return false;
            }
            if (ReferenceEquals(other, this)) {
                return true;
            }
            if (PackHash != other.PackHash) return false;
            if (SignedSeg != other.SignedSeg) return false;
            return Equals(_unknownFields, other._unknownFields);
        }

        // RVA: 0x192886C
        [DebuggerNonUserCode]
        public override int GetHashCode()
        {
            int hash = 1;
            if (PackHash.Length != 0) hash ^= PackHash.GetHashCode();
            if (SignedSeg.Length != 0) hash ^= SignedSeg.GetHashCode();
            if (_unknownFields != null) {
                hash ^= _unknownFields.GetHashCode();
            }
            return hash;
        }

        // RVA: 0x19288F0
        [DebuggerNonUserCode]
        public override string ToString()
        {
            return JsonFormatter.ToDiagnosticString(this);
        }

        // RVA: 0x1928958
        [DebuggerNonUserCode]
        public void WriteTo(CodedOutputStream output)
        {
            if (PackHash.Length != 0) {
                output.WriteRawTag(10);
                output.WriteString(PackHash);
            }
            if (SignedSeg.Length != 0) {
                output.WriteRawTag(18);
                output.WriteString(SignedSeg);
            }
            if (_unknownFields != null) {
                _unknownFields.WriteTo(output);
            }
        }

        // RVA: 0x1928A00
        [DebuggerNonUserCode]
        public int CalculateSize()
        {
            int size = 0;
            if (PackHash.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(PackHash);
            }
            if (SignedSeg.Length != 0) {
                size += 1 + CodedOutputStream.ComputeStringSize(SignedSeg);
            }
            if (_unknownFields != null) {
                size += _unknownFields.CalculateSize();
            }
            return size;
        }

        // RVA: 0x1928AF0
        [DebuggerNonUserCode]
        public void MergeFrom(SignedURL other)
        {
            if (other == null) {
                return;
            }
            if (other.PackHash.Length != 0) {
                PackHash = other.PackHash;
            }
            if (other.SignedSeg.Length != 0) {
                SignedSeg = other.SignedSeg;
            }
            _unknownFields = UnknownFieldSet.MergeFrom(_unknownFields, other._unknownFields);
        }

        // RVA: 0x1928B5C
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
                        PackHash = input.ReadString();
                        break;
                    }
                    case 18: {
                        SignedSeg = input.ReadString();
                        break;
                    }
                }
            }
        }

        // RVA: 0x1928BF4
        static SignedURL()
        {
            _parser = new MessageParser<SignedURL>(() => new SignedURL());
        }
    }
}
