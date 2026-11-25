// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.Components.ExtensibilityProvider
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  说明：扩展点提供者；CreateMarkupParser 与 CreateTextSourceCompiler 均已还原。
// =============================================================================

using Jigbox.TextView;
using Jigbox.TextView.Markup;
using UnityEngine;

namespace Jigbox.Components
{
    public class ExtensibilityProvider : MonoBehaviour
    {
        // RVA: 0x1E16434
        public virtual MarkupParser CreateMarkupParser()
        {
            return new MarkupParser();
        }

        // RVA: 0x1E16490
        public virtual TextSourceCompiler CreateTextSourceCompiler(TextSourceCompilerProperty compilerProperty)
        {
            return new TextSourceCompiler(compilerProperty);
        }

        // RVA: 0x1E164F4
        public ExtensibilityProvider()
        {
        }
    }
}
