// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.TextSourceCompiler
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  说明：已还原 CompilerProperty/构造/Compile/CompileSingleTextRun/
//        IntParseNullableFloatValue/CreateDefaultTextModifier/CreateTextModifierScope。
//        CompileSingleTextRun 的 8 个分支均由分派链目标类型的 TypeInfo 槽反查确认。
// =============================================================================

using System;
using System.Collections.Generic;
using ThaiUtils;
using UnityEngine;

namespace Jigbox.TextView
{
    public class TextSourceCompiler
    {
        protected readonly TextSourceCompilerProperty compilerProperty; // 0x10

        protected TextSourceCompilerProperty CompilerProperty
        {
            // RVA: 0x16876FC
            get { return compilerProperty; }
        }

        // RVA: 0x1687704
        public TextSourceCompiler(TextSourceCompilerProperty compilerProperty)
        {
            this.compilerProperty = compilerProperty;
        }

        // RVA: 0x1687730
        public virtual List<List<SplitDenyGlyphSpecs>> Compile(TextSource source)
        {
            TextRunPointer pointer = new TextRunPointer(source);
            if (pointer.EndOfSource)
            {
                return new List<List<SplitDenyGlyphSpecs>>();
            }

            SplitDenyGlyphSpecsBuilder builder = new SplitDenyGlyphSpecsBuilder();
            int glyphIndex = 0;
            TextModifierScope textModifierScope = CreateTextModifierScope(null, null);

            while (!pointer.EndOfSource)
            {
                CompileSingleTextRun(pointer, builder, ref glyphIndex, ref textModifierScope);
            }

            return builder.Build();
        }

        // RVA: 0x168786C
        // 分派链（0x16878F8 起，is 顺序与目标类型经 TypeInfo 槽解析确认）：
        //   LineBreak              → 0x1687EC8  AddLineBreak + Next
        //   TextModifier           → 0x1687EDC  CreateTextModifierScope + PushTextModifier + Next
        //   TextEndOfSegment       → 0x1687F14  scope = scope.Parent + PopTextModifier + Next
        //   TextAlignModifier      → 0x1687F3C  CompilerProperty.ModifyAlign = Align + Next
        //   TextBiDirectionOverride→ 0x1687F68  仅 Next
        //   TextCharacters         → 0x1687F94  逐字符 FontGlyphSpec（RubyGroup 先出注音）
        //   InlineImage            → 0x16881E4  ImageGlyphSpec + 边距，NextChunk
        //   ThaiTextCharacters     → 0x1687A74  逐 TextUnit（ThaiFontGlyphSpec / 普通字形）
        protected virtual void CompileSingleTextRun(TextRunPointer ptr, SplitDenyGlyphSpecsBuilder builder, ref int glyphIndex, ref TextModifierScope textModifierScope)
        {
            TextRun run = ptr.Current;

            if (run is LineBreak)
            {
                builder.AddLineBreak();
                ptr.Next();
            }
            else if (run is TextModifier textModifier)
            {
                textModifierScope = CreateTextModifierScope(textModifierScope, textModifier);
                builder.PushTextModifier(textModifier);
                ptr.Next();
            }
            else if (run is TextEndOfSegment)
            {
                if (textModifierScope != null)
                {
                    textModifierScope = textModifierScope.Parent;
                }

                builder.PopTextModifier();
                ptr.Next();
            }
            else if (run is TextAlignModifier alignModifier)
            {
                CompilerProperty.ModifyAlign = alignModifier.Align;
                ptr.Next();
            }
            else if (run is TextBiDirectionOverride)
            {
                ptr.Next();
            }
            else if (run is TextCharacters characters)
            {
                bool endRuby = false;

                if (run is TextCharactersRubyGroup rubyGroup)
                {
                    TextModifierScope rubyScope = textModifierScope.RubyScope;
                    int rubyFontSize = rubyScope.FontSize.Value;
                    FontStyle rubyFontStyle = rubyScope.FontStyle.Value;
                    Color? rubyColor = rubyScope.ModifiedColor;

                    builder.StartRuby(rubyScope);

                    string rubyCharacters = rubyGroup.RawRubyCharacters;
                    for (int i = 0; i < rubyCharacters.Length; i++)
                    {
                        builder.AddRubyFontRequestSpec(new FontGlyphSpec(
                            rubyCharacters[i],
                            CompilerProperty.Font,
                            rubyFontSize,
                            rubyFontStyle,
                            rubyColor,
                            CompilerProperty.GlyphScaleX));
                    }

                    endRuby = true;
                }

                float spacing = textModifierScope.Spacing.Value;
                int fontSize = textModifierScope.FontSize.Value;
                FontStyle fontStyle = textModifierScope.FontStyle.Value;
                Color? color = textModifierScope.ModifiedColor;
                char[] charactersArray = characters.RawCharacters.ToCharArray();

                while (!ptr.Next())
                {
                    builder.AddMainGlyphPlacementSpec(new MainGlyphPlacementSpec(
                        new FontGlyphSpec(
                            charactersArray[ptr.Position],
                            CompilerProperty.Font,
                            fontSize,
                            fontStyle,
                            color,
                            CompilerProperty.GlyphScaleX),
                        0,
                        0,
                        0,
                        glyphIndex++,
                        spacing));
                }

                if (endRuby)
                {
                    builder.EndRuby();
                }
            }
            else if (run is InlineImage inlineImage)
            {
                int marginLeft = Math.Max(IntParseNullableFloatValue(inlineImage.MarginLeftWithPixel), 0);
                int marginRight = Math.Max(IntParseNullableFloatValue(inlineImage.MarginRightWithPixel), 0);
                int offsetY = -Math.Max(IntParseNullableFloatValue(inlineImage.OffsetYWithPixel), 0);

                int fontSize = textModifierScope.FontSize.Value;
                FontStyle fontStyle = textModifierScope.FontStyle.Value;
                Color? color = textModifierScope.ModifiedColor;

                FontGlyphSpec sizeBaseGlyphSpec = new FontGlyphSpec(
                    'M',
                    CompilerProperty.Font,
                    fontSize,
                    fontStyle,
                    color,
                    CompilerProperty.GlyphScaleX);

                ImageGlyphSpec imageGlyphSpec = new ImageGlyphSpec(inlineImage, sizeBaseGlyphSpec);

                float spacing = textModifierScope.Spacing.Value;

                builder.AddMainGlyphPlacementSpec(new MainGlyphPlacementSpec(
                    imageGlyphSpec,
                    marginLeft,
                    marginRight,
                    offsetY,
                    glyphIndex++,
                    spacing));

                ptr.NextChunk();
            }
            else if (run is ThaiTextCharacters thaiCharacters)
            {
                float spacing = textModifierScope.Spacing.Value;
                int fontSize = textModifierScope.FontSize.Value;
                FontStyle fontStyle = textModifierScope.FontStyle.Value;
                Color? color = textModifierScope.ModifiedColor;

                foreach (TextUnit textUnit in thaiCharacters.Texts)
                {
                    if (textUnit.isLayouted)
                    {
                        if (textUnit.isStartSpan)
                        {
                            TextModifier spanModifier = new TextModifier();
                            textModifierScope = CreateTextModifierScope(textModifierScope, spanModifier);
                            builder.PushTextModifier(spanModifier);
                        }

                        for (int i = 0; i < textUnit.data.Length; i++)
                        {
                            builder.AddMainGlyphPlacementSpec(new MainGlyphPlacementSpec(
                                new ThaiFontGlyphSpec(
                                    textUnit.data[i],
                                    CompilerProperty.Font,
                                    fontSize,
                                    fontStyle,
                                    color,
                                    CompilerProperty.GlyphScaleX,
                                    textUnit.offsets[i].x,
                                    textUnit.offsets[i].y),
                                0,
                                0,
                                0,
                                glyphIndex++,
                                spacing));

                            ptr.Next();
                        }

                        if (textUnit.isEndSpan)
                        {
                            if (textModifierScope != null)
                            {
                                textModifierScope = textModifierScope.Parent;
                            }

                            builder.PopTextModifier();
                        }
                    }
                    else
                    {
                        for (int i = 0; i < textUnit.data.Length; i++)
                        {
                            builder.AddMainGlyphPlacementSpec(new MainGlyphPlacementSpec(
                                new FontGlyphSpec(
                                    textUnit.data[i],
                                    CompilerProperty.Font,
                                    fontSize,
                                    fontStyle,
                                    color,
                                    CompilerProperty.GlyphScaleX),
                                0,
                                0,
                                0,
                                glyphIndex++,
                                spacing));

                            ptr.Next();
                        }
                    }
                }
            }
        }

        // RVA: 0x16887D8
        protected static int IntParseNullableFloatValue(float? nullableValue)
        {
            if (!nullableValue.HasValue)
            {
                return 0;
            }

            return (int)Math.Round(nullableValue.Value);
        }

        // RVA: 0x1688A2C
        protected virtual TextModifier CreateDefaultTextModifier()
        {
            TextModifier modifier = new TextModifier();
            modifier.FontSize = CompilerProperty.FontSize;
            modifier.FontStyle = CompilerProperty.DefaultFontStyle;
            modifier.Spacing = CompilerProperty.CharacterSpacing;
            modifier.RubyFontScale = 0.5f;
            modifier.Color = CompilerProperty.Color;
            return modifier;
        }

        // RVA: 0x1688BA4
        protected virtual TextModifierScope CreateTextModifierScope(TextModifierScope parent, TextModifier modifier)
        {
            if (modifier == null)
            {
                modifier = CreateDefaultTextModifier();
            }

            return new TextModifierScope(parent, modifier);
        }
    }
}
