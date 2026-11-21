// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.PropertyChangedEventArgs
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;

namespace Jackpot
{
    public class PropertyChangedEventArgs<T> : EventArgs
    {
        public PropertyChangedEventKind Kind { get; private set; }
        public T OldValue { get; private set; }
        public T NewValue { get; private set; }

        public static PropertyChangedEventArgs<T> ForceUpdate(T value)
        {
            return new PropertyChangedEventArgs<T>(PropertyChangedEventKind.ForceUpdate, value, value);
        }

        public static PropertyChangedEventArgs<T> Update(T oldValue, T newValue)
        {
            return new PropertyChangedEventArgs<T>(PropertyChangedEventKind.Update, oldValue, newValue);
        }

        private PropertyChangedEventArgs(PropertyChangedEventKind kind, T oldValue, T newValue)
        {
            Kind = kind;
            OldValue = oldValue;
            NewValue = newValue;
        }
    }
}
