// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.TextModifierScope
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using UnityEngine;

namespace Jigbox.TextView
{
    public class TextModifierScope : IRubyTextModifierScope
    {
        public TextModifierScope Parent { get; protected set; }   // 0x10
        public TextModifier TextModifier { get; protected set; }  // 0x18

        public float? Spacing
        {
            // RVA: 0x1686838
            get
            {
                for (TextModifierScope scope = this; scope != null; scope = scope.Parent)
                {
                    float? value = scope.TextModifier.Spacing;
                    if (value.HasValue)
                    {
                        return value;
                    }
                }

                return null;
            }
            // RVA: 0x16868AC
            set { TextModifier.Spacing = value; }
        }

        public float? RubyOffset
        {
            // RVA: 0x1684498
            get
            {
                for (TextModifierScope scope = this; scope != null; scope = scope.Parent)
                {
                    float? value = scope.TextModifier.RubyOffset;
                    if (value.HasValue)
                    {
                        return value;
                    }
                }

                return null;
            }
            // RVA: 0x16868C8
            set { TextModifier.RubyOffset = value; }
        }

        public Color? RubyColor
        {
            // RVA: 0x16868E4
            get
            {
                for (TextModifierScope scope = this; scope != null; scope = scope.Parent)
                {
                    Color? value = scope.TextModifier.RubyColor;
                    if (value.HasValue)
                    {
                        return value;
                    }
                }

                return null;
            }
            // RVA: 0x16869AC
            set { TextModifier.RubyColor = value; }
        }

        public FontStyle? RubyFontStyle
        {
            // RVA: 0x16869F0
            get
            {
                for (TextModifierScope scope = this; scope != null; scope = scope.Parent)
                {
                    FontStyle? value = scope.TextModifier.RubyFontStyle;
                    if (value.HasValue)
                    {
                        return value;
                    }
                }

                return null;
            }
            // RVA: 0x1686A64
            set { TextModifier.RubyFontStyle = value; }
        }

        public float? RubyFontScale
        {
            // RVA: 0x168450C
            get
            {
                for (TextModifierScope scope = this; scope != null; scope = scope.Parent)
                {
                    float? value = scope.TextModifier.RubyFontScale;
                    if (value.HasValue)
                    {
                        return value;
                    }
                }

                return null;
            }
            // RVA: 0x1686A80
            set { TextModifier.RubyFontScale = value; }
        }

        public int? FontSize
        {
            // RVA: 0x1686A9C
            get
            {
                for (TextModifierScope scope = this; scope != null; scope = scope.Parent)
                {
                    int? value = scope.TextModifier.FontSize;
                    if (value.HasValue)
                    {
                        return value;
                    }
                }

                return null;
            }
            // RVA: 0x1686B10
            set { TextModifier.FontSize = value; }
        }

        public FontStyle? FontStyle
        {
            // RVA: 0x1686B2C
            get
            {
                for (TextModifierScope scope = this; scope != null; scope = scope.Parent)
                {
                    FontStyle? value = scope.TextModifier.FontStyle;
                    if (value.HasValue)
                    {
                        return value;
                    }
                }

                return null;
            }
            // RVA: 0x1686C0C
            set { TextModifier.FontStyle = value; }
        }

        public Color? Color
        {
            // RVA: 0x1686C28
            get
            {
                for (TextModifierScope scope = this; scope != null; scope = scope.Parent)
                {
                    Color? value = scope.TextModifier.Color;
                    if (value.HasValue)
                    {
                        return value;
                    }
                }

                return null;
            }
            // RVA: 0x1686CF0
            set { TextModifier.Color = value; }
        }

        public Color? ModifiedColor
        {
            // RVA: 0x1686D34
            get
            {
                if (Parent == null)
                {
                    return null;
                }

                if (TextModifier.Color.HasValue)
                {
                    return TextModifier.Color;
                }

                return Parent.ModifiedColor;
            }
        }

        public virtual TextModifierScope RubyScope
        {
            // RVA: 0x1686F94
            get
            {
                TextModifier modifier = new TextModifier();
                modifier.Color = RubyColor;

                float fontSize = FontSize ?? 1f;
                float fontScale = RubyFontScale ?? 1f;
                modifier.FontSize = (int)(fontSize * fontScale);
                modifier.FontStyle = RubyFontStyle;

                return new TextModifierScope(this, modifier);
            }
        }

        // RVA: 0x1686E08
        public TextModifierScope(TextModifierScope parent, TextModifier modifier)
        {
            Parent = parent;
            TextModifier = new TextModifier();

            if (modifier != null)
            {
                Apply(modifier);
            }
        }

        // RVA: 0x1686EA4
        public void Apply(TextModifier modifier)
        {
            TextModifier.Spacing = modifier.Spacing;
            TextModifier.RubyOffset = modifier.RubyOffset;
            TextModifier.RubyColor = modifier.RubyColor;
            TextModifier.RubyFontScale = modifier.RubyFontScale;
            TextModifier.RubyFontStyle = modifier.RubyFontStyle;
            TextModifier.FontSize = modifier.FontSize;
            TextModifier.FontStyle = modifier.FontStyle;
            TextModifier.Color = modifier.Color;
        }

        // RVA: 0x16870B0
        public int VerticalRubyOffset(int baseHeight)
        {
            if (!RubyOffset.HasValue || !RubyFontScale.HasValue)
            {
                return baseHeight;
            }

            float rate = RubyOffset.Value * RubyFontScale.Value + 1f;
            return (int)System.Math.Floor(rate * baseHeight);
        }
    }
}
