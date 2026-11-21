// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Enumeration<TValue>
//  来源：libil2cpp.so (ARM64) 反汇编（GenericInstMethod 共享实例）+ Il2CppDumper 元数据
// =============================================================================

using System;

namespace Jackpot
{
    public abstract class Enumeration<TValue> : Enumeration
    {

        public new TValue Value { get; private set; }



        // RVA: 0x221A594 (Enumeration<object>..ctor / Enumeration<string>..ctor)
        protected Enumeration(TValue value, string name)
            : this(value, name, false)
        {
        }

        // RVA: 0x221A5BC (Enumeration<object>..ctor)
        protected Enumeration(TValue value, string name, bool isDefault)
            : base(value.GetHashCode(), name, isDefault)
        {
            Value = value;
        }

        // RVA: 0x221A644 (Enumeration<object>.Equals / Enumeration<string>.Equals)
        public override bool Equals(object that)
        {
            if (this == that)
            {
                return true;
            }

            if (that == null)
            {
                return false;
            }

            Enumeration<TValue> enumeration = that as Enumeration<TValue>;
            if (enumeration == null)
            {
                return false;
            }

            if (!Value.Equals(enumeration.Value))
            {
                return false;
            }

            return GetType() == enumeration.GetType();
        }

        // RVA: 0x221A754 (Enumeration<object>.CompareTo / Enumeration<string>.CompareTo)
        public override int CompareTo(object that)
        {
            if (this == that)
            {
                return 0;
            }

            if (that == null)
            {
                return 1;
            }

            Enumeration<TValue> enumeration = that as Enumeration<TValue>;
            if (enumeration == null)
            {
                return 1;
            }

            return ((IComparable)Value).CompareTo(enumeration.Value);
        }

        // RVA: 0x221A8A8 (Enumeration<object>.GetHashCode / Enumeration<string>.GetHashCode)
        public override int GetHashCode()
        {
            if (Value == null)
            {
                return base.GetHashCode();
            }

            return Value.GetHashCode();
        }

        // RVA: 0x221A920 (Enumeration<object>.ToString / Enumeration<string>.ToString)
        public override string ToString()
        {
            return Name;
        }
    }
}
