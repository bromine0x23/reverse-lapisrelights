// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.Delegatable.IEventDelegate
//  来源：Il2CppDumper 元数据
// =============================================================================

using System.Reflection;
using UnityEngine;

namespace Jigbox.Delegatable
{
    public interface IEventDelegate
    {
        Object Target { get; }
        MethodInfo Method { get; }

        bool Invoke(object[] args);
        bool Equals(IEventDelegate other);
    }
}
