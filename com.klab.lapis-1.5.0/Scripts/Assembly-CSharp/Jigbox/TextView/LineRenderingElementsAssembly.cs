// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.LineRenderingElementsAssembly
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（已还原成员）
//  说明：把逻辑行（SplitDenyGlyphSpecs）装配成可断行的 LineRenderingElements。
//        已还原：AssembleOption / Spacing / TemporarySubRenderingFontElement /
//        TemporaryMainRenderingElement / TemporaryElementOption /
//        TemporaryFontElementOption / TemporaryImageElementOption。
//        未还原：Assemble(0x181A778) 尾部、CalculateSpacing(0x181B8D8)、
//        CreateTemporaryMainRenderingElement(0x181ADAC)、
//        CreateTemporarySubRenderingFontElement(0x181BAB0)、
//        CreateMainRenderingElementFromTemporary(0x181C584)、
//        GetMainTextWidth(0x181CA4C)、GetRubyTextWidth(0x181D00C)、
//        TemporaryImageElementOption.CreateImmutable(0x181D6CC)。
// =============================================================================

using System.Collections.Generic;
using Jigbox.Components;
using UnityEngine;

namespace Jigbox.TextView
{
    public class LineRenderingElementsAssembly
    {
        protected static List<TemporaryMainRenderingElement> cachedTemporaryMainElements;   // 0x0
        protected static List<TemporarySubRenderingFontElement> cachedTemporaryRubyElements; // 0x8

        // RVA: 0x181D384
        static LineRenderingElementsAssembly()
        {
            cachedTemporaryMainElements = new List<TemporaryMainRenderingElement>();
            cachedTemporaryRubyElements = new List<TemporarySubRenderingFontElement>();
        }

        // RVA: 0x181A778
        public static LineRenderingElements Assemble(
            List<SplitDenyGlyphSpecs> data,
            GlyphCatalog catalog,
            AssembleOption option)
        {
            ISplitDenyZone[] zones = new ISplitDenyZone[data.Count];

            for (int z = 0; z < data.Count; z++)
            {
                SplitDenyGlyphSpecs specs = data[z];
                MainRenderingElement[] mainRenderingElements = new MainRenderingElement[specs.MainsCount];
                int count = 0;

                foreach (IGlyphSpecGroup group in specs.Groups)
                {
                    if (group.RubiesCount == 0)
                    {
                        Spacing spacing = new Spacing();
                        CreateTemporaryMainRenderingElement(group, catalog, option, spacing);
                        cachedTemporaryRubyElements.Clear();   // 0x181A990
                    }
                    else
                    {
                        Spacing spacing = CalculateSpacing(group, catalog, option);
                        CreateTemporaryMainRenderingElement(group, catalog, option, spacing);
                        CreateTemporarySubRenderingFontElement(group, catalog, spacing);
                    }

                    count += CreateMainRenderingElementFromTemporary(
                        ref mainRenderingElements,
                        count,
                        group.MainsCount);
                }

                if (mainRenderingElements.Length == 1)
                {
                    zones[z] = new MinimumSplitDenyZone(mainRenderingElements[0]);   // 0x181ACE8
                }
                else
                {
                    zones[z] = new SplitDenyZone(mainRenderingElements);             // 0x181A840
                }
            }

            return new LineRenderingElements(zones);                                 // 0x181AD50
        }

        // RVA: 0x181ADAC
        // 未完整还原：ImageGlyphSpec 分支依赖 InlineImageSizeExtension.CalculatePixel（未还原），
        // 该分支抛 NotImplementedException；FontGlyphSpec（含 ThaiFontGlyphSpec）路径已完整实现。
        protected static void CreateTemporaryMainRenderingElement(
            IGlyphSpecGroup group,
            GlyphCatalog catalog,
            AssembleOption option,
            Spacing spacing)
        {
            List<TemporaryMainRenderingElement> list = cachedTemporaryMainElements;

            if (group.MainsCount > list.Count)                  // 0x181AEB4
            {
                list.Capacity = group.MainsCount;               // 0x181AF58

                for (int i = list.Count; i < group.MainsCount; i++)
                {
                    list.Add(new TemporaryMainRenderingElement());   // 0x181AFCC
                }
            }

            int index = 0;                                      // W23（0x181B130 置 0）

            foreach (MainGlyphPlacementSpec main in group.Mains) // 0x181B094 itf slot 4
            {
                TemporaryMainRenderingElement temporary = list[index];   // 0x181B1FC
                IGlyphSpec glyphSpec = main.GlyphSpec;                   // 0x181B1B8

                if (glyphSpec is FontGlyphSpec fontSpec)                 // 0x181B288
                {
                    TemporaryFontElementOption elementOption =
                        temporary.ElementOption as TemporaryFontElementOption;

                    if (elementOption == null)
                    {
                        elementOption = new TemporaryFontElementOption();   // 0x181B308
                    }

                    Glyph glyph = catalog.Get(fontSpec);                   // 0x181B318
                    elementOption.glyph = glyph;                           // 0x181B324
                    temporary.width = glyph.Width;                         // 0x181B32C
                    temporary.characterSpacingRight = CalculateCharacterSpacing(option, main, glyph.Width);

                    SplitRubySpacing(spacing, out float left, out float right);
                    temporary.rubySpacingLeft = left;                      // 0x181B3E0 (0x1C)
                    temporary.rubySpacingRight = right;                    // 0x181B3E0 (0x20)
                    temporary.glyphIndex = main.Index;                     // 0x181B3E4
                    temporary.option = option;                             // 0x181B3EC

                    if (fontSpec is ThaiFontGlyphSpec thaiSpec)            // 0x181B3F4 → 0x181B52C
                    {
                        elementOption.offsetX = thaiSpec.OffsetX;          // 0x44
                        elementOption.offsetY = thaiSpec.OffsetY;          // 0x48
                    }
                    else
                    {
                        elementOption.offsetX = 0;                         // 0x181B424
                        elementOption.offsetY = 0;
                    }

                    temporary.ElementOption = elementOption;               // 0x181B430
                }
                else if (glyphSpec is ImageGlyphSpec imageSpec)            // 0x181B264 → 0x181B438
                {
                    TemporaryImageElementOption elementOption =
                        temporary.ElementOption as TemporaryImageElementOption;

                    if (elementOption == null)
                    {
                        elementOption = new TemporaryImageElementOption();   // 0x181B494
                    }

                    // 0x181B4A8–0x181B5A8
                    Glyph baseGlyph = catalog.Get(imageSpec.SizeBaseGlyphSpec);
                    int basicSize = (int)System.Math.Round(baseGlyph.RawWidth * 0.9f);
                    temporary.width = option.GlyphScaleX * imageSpec.Width.CalculatePixel(basicSize);
                    elementOption.height = imageSpec.Height.CalculatePixel(basicSize);
                    elementOption.source = imageSpec.Source;
                    elementOption.name = imageSpec.Name;

                    temporary.characterSpacingRight = CalculateCharacterSpacing(option, main, temporary.width);
                    SplitRubySpacing(spacing, out float rubyLeft, out float rubyRight);
                    temporary.rubySpacingLeft = rubyLeft;                     // 0x181B654
                    temporary.rubySpacingRight = rubyRight;

                    elementOption.marginLeft = main.MarginLeft;               // 0x181B658
                    elementOption.marginRight = main.MarginRight;             // 0x181B660
                    elementOption.offsetY = main.OffsetY;                     // 0x181B668

                    temporary.glyphIndex = main.Index;                        // 0x181B678
                    temporary.option = option;                                // 0x181B674
                    temporary.ElementOption = elementOption;
                }

                list[index] = temporary;                                   // 0x181B6C4 List.set_Item
                index++;
            }
        }

        // RVA: 0x181B348 / 0x181B5B0（两处同型逻辑）
        private static float CalculateCharacterSpacing(
            AssembleOption option,
            MainGlyphPlacementSpec main,
            float width)
        {
            if (option.SpacingUnit == SpacingUnit.BeforeCharacterWidth)     // 0x181B398
            {
                return (int)(main.BaseSpacing * width);
            }

            if (option.SpacingUnit == SpacingUnit.FontSize)                 // 0x181B358
            {
                return option.GlyphScaleX * (int)(main.BaseSpacing * option.FontSize);
            }

            return 0f;
        }

        // RVA: 0x181B3C0 / 0x181B630（两处同型逻辑）
        private static void SplitRubySpacing(Spacing spacing, out float left, out float right)
        {
            float even = (int)(spacing.rubyParentSpacing * 2f);
            left = (int)(even * 0.5f);
            right = even - left;
        }

        // RVA: 0x181BAB0
        // 未完整还原：主字形为 ImageGlyphSpec 时依赖 InlineImageSizeExtension.CalculatePixel（未还原），
        // 该分支抛 NotImplementedException；FontGlyphSpec 路径已完整实现。
        protected static void CreateTemporarySubRenderingFontElement(
            IGlyphSpecGroup group,
            GlyphCatalog catalog,
            Spacing spacing)
        {
            List<TemporarySubRenderingFontElement> list = cachedTemporaryRubyElements; // 0x181BB4C
            list.Clear();                                                             // 0x181BB60

            // 1) 求主字形最大高度（0x181BC8C–0x181BE88）
            float maxHeight = 0f;

            foreach (MainGlyphPlacementSpec main in group.Mains)
            {
                IGlyphSpec glyphSpec = main.GlyphSpec;
                float height = 0f;

                if (glyphSpec is FontGlyphSpec)
                {
                    height = catalog.Get(glyphSpec).Height;              // 0x181BE38
                }
                else if (glyphSpec is ImageGlyphSpec imageGlyphSpec)
                {
                    // 0x181BDB4–0x181BE80
                    Glyph baseGlyph = catalog.Get(imageGlyphSpec.SizeBaseGlyphSpec);
                    int basicSize = (int)System.Math.Round(baseGlyph.Width * 0.9f);
                    height = imageGlyphSpec.Height.CalculatePixel(basicSize);
                }

                if (height > maxHeight)
                {
                    maxHeight = height;                                  // 0x181BC88
                }
            }

            // 注音整体高度按 RubyOffset/RubyScale 放大（0x181BFBC–0x181C158）
            if (group.RubyOffset.HasValue && group.RubyScale.HasValue)
            {
                maxHeight = (int)Mathf.Floor(maxHeight * (group.RubyOffset.Value * group.RubyScale.Value + 1f));
            }

            // 2) 依 spacing.rubySpacing 布置注音（0x181C15C–0x181C38C）
            float cumulativeX = spacing.rubySpacing;   // 0x181C164
            float previousRight = 0f;                  // s10
            int index = 0;                             // W24

            foreach (FontGlyphSpec ruby in group.Rubies)
            {
                TemporarySubRenderingFontElement temporary = new TemporarySubRenderingFontElement();
                Glyph glyph = catalog.Get(ruby);       // 0x181C2F4
                temporary.glyph = glyph;

                index++;
                float left = (int)(spacing.rubySpacing * 2f * index);    // 0x181C308–0x181C31C
                temporary.width = left - previousRight + glyph.Width;    // 0x181C320–0x181C328
                temporary.glyphWidth = glyph.Width;                      // 0x181C33C
                temporary.offsetX = (int)cumulativeX;                    // 0x181C330/0x181C338
                temporary.offsetY = -maxHeight;                          // 0x181C260

                list.Add(temporary);                   // 0x181C380

                previousRight = left;
                cumulativeX += temporary.width;        // 0x181C38C
            }
        }

        // RVA: 0x181C584
        protected static int CreateMainRenderingElementFromTemporary(
            ref MainRenderingElement[] mainRenderingElements,
            int index,
            int mainsLength)
        {
            int rubyCount = cachedTemporaryRubyElements.Count;   // 0x181C610

            if (rubyCount == 0)
            {
                // 无注音：逐个直接转成不可变元素（0x181C92C）
                for (int i = 0; i < mainsLength; i++)
                {
                    MainRenderingElement element =
                        cachedTemporaryMainElements[i].CreateImmutable(null);

                    mainRenderingElements[index + i] = element;
                }

                return mainsLength;
            }

            List<SubRenderingFontElement> subs = new List<SubRenderingFontElement>(); // 0x181C628
            int rubyIndex = 0;     // W28
            float offsetX = 0f;    // S11
            int lastIndex = mainsLength - 1;

            for (int i = 0; i < mainsLength; i++)
            {
                TemporaryMainRenderingElement temporary = cachedTemporaryMainElements[i];
                float mainWidth = temporary.TotalWidth;    // 0x181C6BC elementOption.TotalWidth(temp)
                subs.Clear();                              // 0x181C6D8

                if (i == lastIndex)
                {
                    // 最后一个主元素吃掉所有剩余注音（0x181C6E8）
                    while (rubyIndex < rubyCount)
                    {
                        TemporarySubRenderingFontElement ruby = cachedTemporaryRubyElements[rubyIndex];
                        subs.Add(new SubRenderingFontElement(
                            ruby.glyph,
                            ruby.width,
                            ruby.offsetX - offsetX,
                            ruby.offsetY));

                        rubyIndex++;
                    }
                }
                else
                {
                    // 按宽度把注音分配到当前主元素（0x181C79C–0x181C85C）
                    float limit = offsetX + mainWidth;

                    while (rubyIndex < rubyCount)
                    {
                        TemporarySubRenderingFontElement ruby = cachedTemporaryRubyElements[rubyIndex];
                        if (limit < ruby.offsetX + ruby.glyphWidth)
                        {
                            break;
                        }

                        subs.Add(new SubRenderingFontElement(
                            ruby.glyph,
                            ruby.width,
                            ruby.offsetX - offsetX,
                            ruby.offsetY));

                        rubyIndex++;
                    }
                }

                mainRenderingElements[index + i] = temporary.CreateImmutable(subs);  // 0x181C8D4/0x181C910
                offsetX += mainWidth;                                                 // 0x181C91C
            }

            return mainsLength;
        }
        public class AssembleOption : MainRenderingElementOption
        {
            protected TextView textView; // 0x10

            public virtual SpacingUnit SpacingUnit
            {
                // RVA: 0x181D428
                get { return textView.SpacingUnit; }
            }

            public virtual int FontSize
            {
                // RVA: 0x181D444
                get { return textView.FontSize; }
            }

            public virtual float GlyphScaleX
            {
                // RVA: 0x181D460
                get { return textView.GlyphScaleX; }
            }

            public virtual bool TrimLineTailSpacing
            {
                // RVA: 0x181D47C
                get { return textView.TrimLineTailSpacing; }
            }

            // RVA: 0x181D498
            public AssembleOption(TextView textView)
            {
                this.textView = textView;
            }
        }

        protected class Spacing
        {
            public float rubySpacing;       // 0x10
            public float rubyParentSpacing; // 0x14

            // RVA: 0x181ADA4
            public Spacing()
            {
            }
        }

        // RVA: 0x181D00C
        protected static float GetRubyTextWidth(IGlyphSpecGroup group, GlyphCatalog catalog)
        {
            float width = 0f;

            foreach (FontGlyphSpec spec in group.Rubies)
            {
                width += catalog.Get(spec).Width;   // Glyph.Width (0x50)
            }

            return width;
        }

        // RVA: 0x181CA4C
        // 未完整还原：ImageGlyphSpec 分支需要 InlineImageSizeExtension.CalculatePixel（未还原），
        // 该分支会抛 NotImplementedException；纯文本（FontGlyphSpec）路径已按反汇编实现。
        protected static float GetMainTextWidth(IGlyphSpecGroup group, GlyphCatalog catalog, AssembleOption option)
        {
            float total = 0f;
            int index = 0;
            int mainsCount = group.MainsCount;

            foreach (MainGlyphPlacementSpec main in group.Mains)
            {
                float width;
                FontGlyphSpec fontSpec = main.GlyphSpec as FontGlyphSpec;
                if (fontSpec != null)
                {
                    width = catalog.Get(fontSpec).Width;   // Glyph.Width (0x50)
                }
                else
                {
                    ImageGlyphSpec imageSpec = main.GlyphSpec as ImageGlyphSpec;
                    if (imageSpec == null)
                    {
                        throw new System.ArgumentException("unsupported glyph spec");
                    }

                    // 0x181CCF0–0x181CD80：基本尺寸 = RawWidth * 0.9f，再按 InlineImageSize 求像素
                    Glyph baseGlyph = catalog.Get(imageSpec.SizeBaseGlyphSpec);
                    int basicSize = (int)System.Math.Round(baseGlyph.RawWidth * 0.9f);
                    width = imageSpec.Width.CalculatePixel(basicSize);
                }

                // 非最后一个主元素才叠加字间距（0x181CDE4 处比较 index 与 MainsCount-1）
                if (index != mainsCount - 1)
                {
                    if (option.SpacingUnit == SpacingUnit.BeforeCharacterWidth)
                    {
                        width += (int)(width * main.BaseSpacing);
                    }
                    else if (option.SpacingUnit == SpacingUnit.FontSize)
                    {
                        width += option.GlyphScaleX * (int)(main.BaseSpacing * option.FontSize);
                    }
                }

                total += width;
                index++;
            }

            return total;
        }

        // RVA: 0x181B8D8
        protected static Spacing CalculateSpacing(IGlyphSpecGroup group, GlyphCatalog catalog, AssembleOption option)
        {
            Spacing spacing = new Spacing();

            float mainWidth = GetMainTextWidth(group, catalog, option);
            float rubyWidth = GetRubyTextWidth(group, catalog);

            if (mainWidth > rubyWidth)
            {
                // 主字形更宽：余量平摊到每个注音的两侧
                spacing.rubySpacing = (mainWidth - rubyWidth) / (group.RubiesCount * 2f);
            }
            else
            {
                // 注音更宽：余量平摊到每个主字形的两侧
                spacing.rubyParentSpacing = (rubyWidth - mainWidth) / (group.MainsCount * 2f);
            }

            return spacing;
        }

        protected class TemporarySubRenderingFontElement
        {
            public Glyph glyph;      // 0x10
            public float width;      // 0x18
            public float glyphWidth; // 0x1C
            public float offsetX;    // 0x20
            public float offsetY;    // 0x24

            // RVA: 0x181D324
            public TemporarySubRenderingFontElement()
            {
            }
        }

        protected class TemporaryMainRenderingElement
        {
            public int glyphIndex;              // 0x10
            public float width;                 // 0x14
            public float characterSpacingRight; // 0x18
            public float rubySpacingLeft;       // 0x1C
            public float rubySpacingRight;      // 0x20
            public MainRenderingElementOption option; // 0x28
            private TemporaryElementOption elementOption; // 0x30

            public TemporaryElementOption ElementOption
            {
                // RVA: 0x181D900
                get { return elementOption; }
                // RVA: 0x181D908
                set { elementOption = value; }
            }

            public float TotalWidth
            {
                // RVA: 0x181D358
                get { return elementOption.TotalWidth(this); }
            }

            // RVA: 0x181D32C
            public MainRenderingElement CreateImmutable(IEnumerable<SubRenderingFontElement> pairedRubies)
            {
                return elementOption.CreateImmutable(this, pairedRubies);
            }

            // RVA: 0x181D30C
            public TemporaryMainRenderingElement()
            {
            }
        }

        protected abstract class TemporaryElementOption
        {
            public abstract float TotalWidth(TemporaryMainRenderingElement element);

            public abstract MainRenderingElement CreateImmutable(
                TemporaryMainRenderingElement element,
                IEnumerable<SubRenderingFontElement> pairedRubies);

            // RVA: 0x181D4C4
            protected TemporaryElementOption()
            {
            }
        }

        protected class TemporaryFontElementOption : TemporaryElementOption
        {
            public Glyph glyph;  // 0x10
            public int offsetX;  // 0x18
            public int offsetY;  // 0x1C

            // RVA: 0x181D4CC
            public override float TotalWidth(TemporaryMainRenderingElement element)
            {
                return element.width
                    + element.rubySpacingLeft
                    + element.rubySpacingRight
                    + element.characterSpacingRight;
            }

            // RVA: 0x181D4F4
            public override MainRenderingElement CreateImmutable(
                TemporaryMainRenderingElement element,
                IEnumerable<SubRenderingFontElement> pairedRubies)
            {
                MainRenderingFontElement result = new MainRenderingFontElement(
                    glyph,
                    element.characterSpacingRight,
                    element.rubySpacingLeft,
                    element.rubySpacingRight,
                    pairedRubies,
                    element.glyphIndex,
                    element.option);

                result.OffsetX = offsetX;
                result.OffsetY = offsetY;
                return result;
            }

            // RVA: 0x181D314
            public TemporaryFontElementOption()
            {
            }
        }

        protected class TemporaryImageElementOption : TemporaryElementOption
        {
            public float height;   // 0x10
            public string source;  // 0x18
            public string name;    // 0x20
            public int marginLeft; // 0x28
            public int marginRight;// 0x2C
            public int offsetY;    // 0x30

            // RVA: 0x181D690
            public override float TotalWidth(TemporaryMainRenderingElement element)
            {
                return element.width
                    + element.rubySpacingLeft
                    + element.rubySpacingRight
                    + marginLeft
                    + marginRight
                    + element.characterSpacingRight;
            }

            // RVA: 0x181D6CC
            // 推断：0x234 条未逐指令解读，参数顺序按 MainRenderingImageElement..ctor 签名与
            // TemporaryImageElementOption 字段布局对应。
            public override MainRenderingElement CreateImmutable(
                TemporaryMainRenderingElement element,
                IEnumerable<SubRenderingFontElement> pairedRubies)
            {
                return new MainRenderingImageElement(
                    element.width,
                    height,
                    source,
                    name,
                    element.characterSpacingRight,
                    element.rubySpacingLeft,
                    element.rubySpacingRight,
                    marginLeft,
                    marginRight,
                    offsetY,
                    pairedRubies,
                    element.glyphIndex,
                    element.option);
            }

            // RVA: 0x181D31C
            public TemporaryImageElementOption()
            {
            }
        }
    }
}
