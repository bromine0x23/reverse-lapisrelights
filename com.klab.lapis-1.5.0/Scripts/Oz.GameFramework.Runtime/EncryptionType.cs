// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.EncryptionType
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + ARM64 汇编核对
//        （get_ValueLong: 0x2E92174 为 `EOR` 组合 _value 与 _key0/_key1）
// =============================================================================

using System;
using System.Runtime.InteropServices;

namespace Oz.GameFramework.Runtime
{
    /// <summary>
    /// 轻量混淆值容器：数值以「随机密钥 XOR」形式存放，
    /// 读写走 <see cref="Value32"/> / <see cref="Value64"/>，并通过隐式转换包装成
    /// INT/UINT/FLOAT/LONG/ULONG/DOUBLE。
    /// </summary>
    public class EncryptionType
    {
        private static Random _random;

        // RVA: 0x2E917F8
        private static uint de_value_uint(uint value, uint key)
        {
            return key ^ value;
        }

        // RVA: 0x2E91800
        private static uint en_value_uint(uint value, uint key)
        {
            return key ^ value;
        }

        // RVA: 0x2E91808
        public EncryptionType()
        {
        }

        // RVA: 0x2E91810
        static EncryptionType()
        {
            _random = new Random(Environment.TickCount);
        }

        [StructLayout(LayoutKind.Explicit)]
        private struct UnionValue32
        {
            [FieldOffset(0)] public int int_val;
            [FieldOffset(0)] public uint uint_val;
            [FieldOffset(0)] public float float_val;
            [FieldOffset(0)] public UnionValueByte32 byte_array;
            [FieldOffset(0)] public uint encryp_val;
        }

        [StructLayout(LayoutKind.Explicit)]
        private struct UnionValueByte32
        {
            [FieldOffset(0)] public uint uint_val;
            [FieldOffset(0)] public byte byte0_val;
            [FieldOffset(1)] public byte byte1_val;
            [FieldOffset(2)] public byte byte2_val;
            [FieldOffset(3)] public byte byte3_val;
        }

        [StructLayout(LayoutKind.Explicit)]
        private struct UnionValue64
        {
            [FieldOffset(0)] public long long_val;
            [FieldOffset(0)] public ulong ulong_val;
            [FieldOffset(0)] public double double_val;
            [FieldOffset(0)] public UnionValueByte64 byte_array;
            [FieldOffset(0)] public UnionValueUint64 uint_array;
            [FieldOffset(0)] public UnionValueInt64 int_array;
        }

        [StructLayout(LayoutKind.Explicit)]
        private struct UnionValueByte64
        {
            [FieldOffset(0)] public ulong ulong_val;
            [FieldOffset(0)] public byte byte0_val;
            [FieldOffset(1)] public byte byte1_val;
            [FieldOffset(2)] public byte byte2_val;
            [FieldOffset(3)] public byte byte3_val;
            [FieldOffset(4)] public byte byte4_val;
            [FieldOffset(5)] public byte byte5_val;
            [FieldOffset(6)] public byte byte6_val;
            [FieldOffset(7)] public byte byte7_val;
        }

        [StructLayout(LayoutKind.Explicit)]
        private struct UnionValueUint64
        {
            [FieldOffset(0)] public ulong ulong_val;
            [FieldOffset(0)] public uint uint0_val;
            [FieldOffset(4)] public uint uint1_val;
        }

        [StructLayout(LayoutKind.Explicit)]
        private struct UnionValueInt64
        {
            [FieldOffset(0)] public ulong ulong_val;
            [FieldOffset(0)] public int int0_val;
            [FieldOffset(4)] public int int1_val;
        }

        /// <summary>32 位混淆值。密钥 <c>_key</c> 由构造时的随机掩码充当。</summary>
        public class Value32
        {
            private UnionValue32 _value;
            private uint _key;

            // RVA: 0x2E91C78
            protected Value32()
            {
                _value.uint_val = 0;
                uint v = 0;
                v |= (uint)EncryptionType._random.Next(1, 255);
                v |= (uint)EncryptionType._random.Next(1, 255) << 8;
                v |= (uint)EncryptionType._random.Next(1, 255) << 16;
                v |= (uint)EncryptionType._random.Next(1, 255) << 24;
                _value.uint_val = v;
            }

            public int ValueInt
            {
                // RVA: 0x2E91FD8
                get { return unchecked(_value.int_val ^ (int)_key); }
                // RVA: 0x2E91F48
                set { _value.int_val = unchecked(value ^ (int)_key); }
            }

            public uint ValueUint
            {
                // RVA: 0x2E9231C
                get { return _value.uint_val ^ _key; }
                // RVA: 0x2E9228C
                set { _value.uint_val = value ^ _key; }
            }

            public float ValueFloat
            {
                // RVA: 0x2E91E40
                get
                {
                    UnionValue32 u = _value;
                    u.encryp_val ^= _key;
                    return u.float_val;
                }
                // RVA: 0x2E91DA4
                set
                {
                    UnionValue32 u = _value;
                    u.float_val = value;
                    _value.encryp_val = u.encryp_val ^ _key;
                }
            }
        }

        /// <summary>64 位混淆值（双密钥 XOR）。</summary>
        public class Value64
        {
            private uint _key0;
            private uint _key1;

            // RVA: 0x2E918C4
            protected Value64()
            {
                _value.ulong_val = 0;
                ulong v = 0;
                v |= (ulong)(uint)EncryptionType._random.Next(1, 255);
                v |= (ulong)(uint)EncryptionType._random.Next(1, 255) << 8;
                v |= (ulong)(uint)EncryptionType._random.Next(1, 255) << 16;
                v |= (ulong)(uint)EncryptionType._random.Next(1, 255) << 24;
                v |= (ulong)(uint)EncryptionType._random.Next(1, 255) << 32;
                v |= (ulong)(uint)EncryptionType._random.Next(1, 255) << 40;
                v |= (ulong)(uint)EncryptionType._random.Next(1, 255) << 48;
                v |= (ulong)(uint)EncryptionType._random.Next(1, 255) << 56;
                _value.ulong_val = v;
            }

            private ulong Key
            {
                get { return _key0 | ((ulong)_key1 << 32); }
            }

            public long ValueLong
            {
                // RVA: 0x2E92174
                get { return unchecked((long)(_value.ulong_val ^ Key)); }
                // RVA: 0x2E920D4
                set { _value.ulong_val = unchecked((ulong)value ^ Key); }
            }

            public ulong ValueUlong
            {
                // RVA: 0x2E924B8
                get { return _value.ulong_val ^ Key; }
                // RVA: 0x2E92418
                set { _value.ulong_val = value ^ Key; }
            }

            public double ValueDouble
            {
                // RVA: 0x2E91B4C
                get
                {
                    UnionValue64 u = _value;
                    u.ulong_val ^= Key;
                    return u.double_val;
                }
                // RVA: 0x2E91AA0
                set
                {
                    UnionValue64 u = _value;
                    u.double_val = value;
                    _value.ulong_val = u.ulong_val ^ Key;
                }
            }
        }

        /// <summary>int 包装。</summary>
        public class INT : Value32
        {
            // RVA: 0x2E91F1C
            private INT(int v) : base()
            {
                ValueInt = v;
            }

            // RVA: 0x2E91FC4
            public static implicit operator int(INT v)
            {
                return v.ValueInt;
            }

            // RVA: 0x2E92040
            public static implicit operator INT(int v)
            {
                return new INT(v);
            }
        }

        /// <summary>uint 包装。</summary>
        public class UINT : Value32
        {
            // RVA: 0x2E92260
            private UINT(uint v) : base()
            {
                ValueUint = v;
            }

            // RVA: 0x2E92308
            public static implicit operator uint(UINT v)
            {
                return v.ValueUint;
            }

            // RVA: 0x2E92384
            public static implicit operator UINT(uint v)
            {
                return new UINT(v);
            }
        }

        /// <summary>float 包装。</summary>
        public class FLOAT : Value32
        {
            // RVA: 0x2E91C44
            private FLOAT(float v) : base()
            {
                ValueFloat = v;
            }

            // RVA: 0x2E91E2C
            public static implicit operator float(FLOAT v)
            {
                return v.ValueFloat;
            }

            // RVA: 0x2E91EAC
            public static implicit operator FLOAT(float v)
            {
                return new FLOAT(v);
            }
        }

        /// <summary>long 包装。</summary>
        public class LONG : Value64
        {
            // RVA: 0x2E920A8
            private LONG(long v) : base()
            {
                ValueLong = v;
            }

            // RVA: 0x2E91B38
            public static implicit operator long(LONG v)
            {
                return v.ValueLong;
            }

            // RVA: 0x2E921F8
            public static implicit operator LONG(long v)
            {
                return new LONG(v);
            }
        }

        /// <summary>ulong 包装。</summary>
        public class ULONG : Value64
        {
            // RVA: 0x2E923EC
            private ULONG(ulong v) : base()
            {
                ValueUlong = v;
            }

            // RVA: 0x2E924A4
            public static implicit operator ulong(ULONG v)
            {
                return v.ValueUlong;
            }

            // RVA: 0x2E9253C
            public static implicit operator ULONG(ulong v)
            {
                return new ULONG(v);
            }
        }

        /// <summary>double 包装。</summary>
        public class DOUBLE : Value64
        {
            // RVA: 0x2E91890
            private DOUBLE(double v) : base()
            {
                ValueDouble = v;
            }

            // RVA: 0x2E91B38
            public static implicit operator double(DOUBLE v)
            {
                return v.ValueDouble;
            }

            // RVA: 0x2E91BD4
            public static implicit operator DOUBLE(double v)
            {
                return new DOUBLE(v);
            }
        }
    }
}
