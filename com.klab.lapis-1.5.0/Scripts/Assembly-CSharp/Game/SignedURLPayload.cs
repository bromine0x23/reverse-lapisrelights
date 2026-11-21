// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Game.SignedURLPayload
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
    public sealed class SignedURLPayload : IMessage<SignedURLPayload>, IMessage, IEquatable<SignedURLPayload>, IDeepCloneable<SignedURLPayload>
    {
        private static readonly MessageParser<SignedURLPayload> _parser;
        private UnknownFieldSet _unknownFields;
        public const int UrlsFieldNumber = 1;
        private static readonly FieldCodec<SignedURL> _repeated_urls_codec;
        private readonly RepeatedField<SignedURL> urls_;
        public static MessageParser<SignedURLPayload> Parser { get; }
        private static MessageDescriptor _Descriptor;
        public static MessageDescriptor Descriptor { get { return _Descriptor; } }
        private MessageDescriptor pb::Google.Protobuf.IMessage.Descriptor { get; }
        public RepeatedField<SignedURL> Urls { get; }

        // RVA: 0x1928D90
        public static MessageParser<SignedURLPayload> get_Parser()
        {
            return _parser;
        }

        // RVA: 0x1928DF8
        public static MessageDescriptor get_Descriptor()
        {
            return CommonReflection.Descriptor.MessageTypes[4];
        }

        // RVA: 0x1928F14
        private MessageDescriptor pb::Google.Protobuf.IMessage.get_Descriptor()
        {
            return _Descriptor;
        }

        // RVA: 0x1928F70
        [DebuggerNonUserCode]
        public SignedURLPayload()
        {
            urls_ = new RepeatedField<SignedURL>();
        }

        // RVA: 0x1928FE0
        [DebuggerNonUserCode]
        public SignedURLPayload(SignedURLPayload other)
        {
            urls_ = other.urls_.Clone();
            _unknownFields = UnknownFieldSet.Clone(other._unknownFields);
        }

        // RVA: 0x1929068
        [DebuggerNonUserCode]
        public SignedURLPayload Clone()
        {
            return new SignedURLPayload(this);
        }

        // RVA: 0x19290C8
        public RepeatedField<SignedURL> get_Urls()
        {
            return urls_;
        }

        // RVA: 0x19290D0
        [DebuggerNonUserCode]
        public override bool Equals(object other)
        {
            return Equals(other as SignedURLPayload);
        }

        // RVA: 0x1929144
        [DebuggerNonUserCode]
        public bool Equals(SignedURLPayload other)
        {
            if (ReferenceEquals(other, null)) {
                return false;
            }
            if (ReferenceEquals(other, this)) {
                return true;
            }
            if (!urls_.Equals(other.urls_)) return false;
            return Equals(_unknownFields, other._unknownFields);
        }

        // RVA: 0x19291E8
        [DebuggerNonUserCode]
        public override int GetHashCode()
        {
            int hash = 1;
            hash ^= urls_.GetHashCode();
            if (_unknownFields != null) {
                hash ^= _unknownFields.GetHashCode();
            }
            return hash;
        }

        // RVA: 0x1929240
        [DebuggerNonUserCode]
        public override string ToString()
        {
            return JsonFormatter.ToDiagnosticString(this);
        }

        // RVA: 0x19292A8
        [DebuggerNonUserCode]
        public void WriteTo(CodedOutputStream output)
        {
            urls_.WriteTo(output, _repeated_urls_codec);
            if (_unknownFields != null) {
                _unknownFields.WriteTo(output);
            }
        }

        // RVA: 0x1929364
        [DebuggerNonUserCode]
        public int CalculateSize()
        {
            int size = 0;
            size += urls_.CalculateSize(_repeated_urls_codec);
            if (_unknownFields != null) {
                size += _unknownFields.CalculateSize();
            }
            return size;
        }

        // RVA: 0x1929418
        [DebuggerNonUserCode]
        public void MergeFrom(SignedURLPayload other)
        {
            if (other == null) {
                return;
            }
            urls_.Add(other.urls_);
            _unknownFields = UnknownFieldSet.MergeFrom(_unknownFields, other._unknownFields);
        }

        // RVA: 0x192949C
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
                        urls_.AddEntriesFrom(input, _repeated_urls_codec);
                        break;
                    }
                }
            }
        }

        // RVA: 0x1929578
        static SignedURLPayload()
        {
            _repeated_urls_codec = FieldCodec.ForMessage(10, SignedURL.Parser);
            _parser = new MessageParser<SignedURLPayload>(() => new SignedURLPayload());
        }
    }
}
