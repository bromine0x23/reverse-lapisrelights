// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.Components.TextView
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（已还原成员）
//  说明：Jigbox 文本渲染引擎体量较大（169 个方法），这里先还原游戏代码
//        实际引用的成员以及 PreferredSizeMeasurer 用到的排版参数：
//        Font / Text / VisibleLength / FontSize / LineGap /
//        IsLineHeightFixed / VisibleLineStart / GetPreferredHeight。
//        完整排版与网格生成管线仍未还原；FontSize 的
//        TextViewOverflowExtension 分支亦未还原。
// =============================================================================

using System;
using System.Collections.Generic;
using Jigbox.Delegatable;
using Jigbox.TextView;
using UnityEngine;
using UnityEngine.UI;

namespace Jigbox.Components
{
    public class TextView : MaskableGraphic
    {
        public const int UnlimitedVisibleLength = -1;
        public const float DefaultGlyphScaleX = 1f;

        [SerializeField] private Font font;              // 0x138
        [SerializeField] private int fontSize = 24;      // 0x140
        [SerializeField] private string text = string.Empty; // 0x158
        [SerializeField] private bool isLineHeightFixed; // 0x169
        [SerializeField] private float characterSpacing;  // 0x160
        [SerializeField] private SpacingUnit spacingUnit;  // 0x164
        [SerializeField] private bool trimLineTailSpacing; // 0x168
        [SerializeField] private float lineHeight = 1.5f; // 0x16C
        [SerializeField] private bool treatNewLineAsLineBreak = true; // 0x17C
        [SerializeField] private TextLineBreakRule lineBreakRule; // 0x180
        [SerializeField] private bool isBold;             // 0x1B0
        [SerializeField] private bool isItalic;           // 0x1B1
        [SerializeField] private TextLanguageType languageType; // 0x1B4
        [SerializeField] private int visibleLength = -1;  // 0x170
        [SerializeField] private int visibleLineStart;   // 0x1C4

        protected static Action<TextView> onInitialize; // 0x8

        [SerializeField] protected ExtensibilityProvider extensibilityProvider; // 0x128
        [SerializeField] private TextViewOverflowExtension overflowExtensionComponent; // 0x188

        private Jigbox.TextView.Markup.MarkupParser markupParser; // 0xC0
        private TextSource textSource;            // 0xC8
        private WorkflowModel workflow = new WorkflowModel(); // 0xD0
        private bool isNeedRefreshTextSource = true; // 0x108
        private bool isPropertiesUpdating;        // 0x120
        private PreferredSizeMeasurer measurer;   // 0xD8
        private List<List<SplitDenyGlyphSpecs>> logicalLines = new List<List<SplitDenyGlyphSpecs>>(); // 0xE0
        private List<LineRenderingElements> assembledLogicalLines = new List<LineRenderingElements>(); // 0xE8
        private List<FontGlyphSpec> allGlyphSpecs = new List<FontGlyphSpec>(); // 0xF0
        private List<TextLine> allTextLines = new List<TextLine>(); // 0xF8
        private Vector2 lastSize = Vector2.zero;  // 0x110
        private Vector2 lastPivot = Vector2.zero; // 0x118
        private bool? dimensionChangedAfterFirstUpdate = false; // 0x10B
        private bool isSkipRecalculate;            // 0x10D
        private bool enableMirror;                // 0x122
        private TextAlign alignment;              // 0x144
        private TextAlign viewAlignment;          // 0x148
        private TextVerticalAlign verticalAlignment; // 0x14C
        private VerticalWrapMode verticalOverflow = VerticalWrapMode.Truncate; // 0x178
        private HorizontalLayout horizontalLayout = new HorizontalLayout(); // 0x1A0

        protected DelegatableList onOverflowTextLines = new DelegatableList(); // 0x1C8
        protected DelegatableList onTextParseError = new DelegatableList();    // 0x1D0

        private int maxIndex;                     // 0x1B8
        private int visibleMinIndex;              // 0x1BC
        private int visibleMaxIndex;              // 0x1C0

        public Font Font
        {
            // RVA: 0x1913FDC
            get { return font; }
            // RVA: 0x1913FE4
            set
            {
                if (font != value)
                {
                    font = value;
                    SetVerticesDirty();
                    SetMaterialDirty();
                }
            }
        }

        public string Text
        {
            // RVA: 0x19148E0
            get { return text; }
            // RVA: 0x19148E8
            set
            {
                if (text != value)
                {
                    text = value;
                    SetVerticesDirty();
                }
            }
        }

        public int VisibleLength
        {
            // RVA: 0x1914E4C
            get { return visibleLength; }
            // RVA: 0x1914E54
            set
            {
                if (visibleLength != value)
                {
                    visibleLength = value;
                    SetVerticesDirty();
                }
            }
        }

        public int FontSize
        {
            // RVA: 0x1914344
            // 真实实现会先查询 overflowExtensionComponent（0x188）后再回退到 fontSize。
            get { return fontSize; }
        }

        public float LineGap
        {
            // RVA: 0x1915428
            get { return FontSize * 0.5f * (lineHeight - 1f); }
        }

        public bool IsLineHeightFixed
        {
            // RVA: 0x1914C4C
            get { return isLineHeightFixed; }
        }

        public int VisibleLineStart
        {
            // RVA: 0x1915C7C
            get { return visibleLineStart; }
            // RVA: 0x1915C84
            set
            {
                int newValue = Math.Max(value, 0);
                if (newValue == visibleLineStart)
                {
                    return;
                }

                visibleLineStart = newValue;

                if (overflowExtensionComponent != null &&
                    overflowExtensionComponent.EllipsisEnabled)
                {
                    RequireProcessByUpdateProperty(new[]
                    {
                        WorkflowProcess.GlyphPlacement
                    });
                }
                else
                {
                    RequireProcessByUpdateProperty(new[]
                    {
                        WorkflowProcess.DisplayableElementIndexCalculate,
                        WorkflowProcess.CurrentOffsetYCalculate
                    });
                }
            }
        }

        public bool TreatNewLineAsLineBreak
        {
            // RVA: 0x1915100
            get { return treatNewLineAsLineBreak; }
            // RVA: 0x1915108
            set
            {
                if (treatNewLineAsLineBreak != value)
                {
                    treatNewLineAsLineBreak = value;
                    isNeedRefreshTextSource = true;
                    RequireProcessByUpdateProperty(new[] { WorkflowProcess.TextParse });
                }
            }
        }

        public float GlyphScaleX
        {
            // RVA: 0x1913C34
            get
            {
                if (overflowExtensionComponent == null)
                {
                    return 1f;
                }

                if (!overflowExtensionComponent.SqueezeEnabled)
                {
                    return 1f;
                }

                if (overflowExtensionComponent.IsNeedSqueeze())
                {
                    return 1f;
                }

                return overflowExtensionComponent.SqueezedSize;
            }
        }

        public float CharacterSpacing
        {
            // RVA: 0x19149C4
            get { return characterSpacing; }
        }

        public SpacingUnit SpacingUnit
        {
            get { return spacingUnit; }
            set { spacingUnit = value; }
        }

        public bool TrimLineTailSpacing
        {
            get { return trimLineTailSpacing; }
            set { trimLineTailSpacing = value; }
        }

        public TextLineBreakRule LineBreakRule
        {
            // RVA: 0x19151D4
            get { return lineBreakRule; }
        }

        public FontStyle DefaultFontStyle
        {
            // RVA: 0x191560C
            get
            {
                if (isItalic)
                {
                    return isBold ? FontStyle.BoldAndItalic : FontStyle.Italic;
                }

                return isBold ? FontStyle.Bold : FontStyle.Normal;
            }
        }

        // RVA: 0x1918FC0
        public float GetPreferredHeight(PreferredHeightType type = PreferredHeightType.AllLine)
        {
            if (Font == null)
            {
                return 0f;
            }

            ForceUpdate();

            if (measurer == null)
            {
                measurer = new PreferredSizeMeasurer(this);
            }

            measurer.CalculatePreferredHeight(allTextLines, type);
            return measurer.PreferredHeight;
        }

        // RVA: 0x191B060
        public float GetPreferredHeight(bool isHeightDependingOnVisibleLength)
        {
            if (Font == null)
            {
                return 0f;
            }

            ForceUpdate();

            if (measurer == null)
            {
                measurer = new PreferredSizeMeasurer(this);
            }

            measurer.CalculatePreferredHeight(
                allTextLines,
                isHeightDependingOnVisibleLength
                    ? PreferredHeightType.Visibled
                    : PreferredHeightType.AllLine);

            return measurer.PreferredHeight;
        }

        // RVA: 0x19178BC
        protected virtual void RequireProcessByUpdateProperty(WorkflowProcess[] processes)
        {
            for (int i = 0; i < processes.Length; i++)
            {
                workflow.RequireProcess(processes[i], true);
            }

            SetVerticesDirty();

            if (TextViewObserver.Instance != null &&
                TextViewObserver.Instance.AlreadyBatched &&
                !isPropertiesUpdating)
            {
                ForceUpdate();
            }
        }

        // RVA: 0x1917EE8
        private void CreateTextSource()
        {
            if (textSource != null && markupParser != null && !isNeedRefreshTextSource)
            {
                return;
            }

            if (markupParser == null)
            {
                markupParser = CreateMarkupParser();

                if (markupParser == null)
                {
                    throw new NullReferenceException();
                }
            }

            markupParser.TreatNewLineAsLineBreak = treatNewLineAsLineBreak;
            textSource = markupParser.ParseTextSource(text, languageType);
            VisibleLineStart = 0;
            isNeedRefreshTextSource = false;

            if (textSource.HasError)
            {
                TextParseError();
            }
        }

        // RVA: 0x1915EB0
        public void ParseText()
        {
            OnInitializeIfNeeded();

            if (workflow.CanExecuteProcess(WorkflowProcess.TextParse))
            {
                CreateTextSource();
                workflow.ProcessExecuted(WorkflowProcess.TextParse);
            }
        }

        // RVA: 0x1917FA0
        private void CreateLogicalLines()
        {
            if (textSource == null || string.IsNullOrEmpty(text))
            {
                if (logicalLines != null)
                {
                    logicalLines.Clear();
                }

                return;
            }

            TextSourceCompilerProperty compilerProperty = new TextSourceCompilerProperty(this);

            TextSourceCompiler compiler;
            if (extensibilityProvider == null)
            {
                compiler = new TextSourceCompiler(compilerProperty);
            }
            else
            {
                compiler = extensibilityProvider.CreateTextSourceCompiler(compilerProperty);
            }

            logicalLines = compiler.Compile(textSource);

            if (compilerProperty.ModifyAlign.HasValue)
            {
                alignment = compilerProperty.ModifyAlign.Value;
            }

            if (languageType == TextLanguageType.Arabic)
            {
                bool hasArabic = GetHasArabic();
                TextAlign viewAlign = alignment;

                if (hasArabic)
                {
                    if (viewAlign == TextAlign.Left)
                    {
                        viewAlign = TextAlign.Right;
                    }
                    else if (viewAlign == TextAlign.Right)
                    {
                        viewAlign = TextAlign.Left;
                    }
                }

                viewAlignment = viewAlign;
                enableMirror = hasArabic;
            }
            else
            {
                enableMirror = false;
                viewAlignment = alignment;
            }
        }

        // RVA: 0x191994C
        private void CreateAllTextLines(float width)
        {
            GlyphCatalog catalog = GlyphCatalog.GetCatalog(font);
            LineRenderingElementsAssembly.AssembleOption assembleOption =
                new LineRenderingElementsAssembly.AssembleOption(this);

            allTextLines.Clear();

            // 1) 补齐 assembledLogicalLines 与 logicalLines 的差值（0x1919A20–0x1919ABC）
            for (int i = assembledLogicalLines.Count; i < logicalLines.Count; i++)
            {
                LineRenderingElements elements = LineRenderingElementsAssembly.Assemble(
                    logicalLines[i], catalog, assembleOption);

                assembledLogicalLines.Add(elements);
            }

            // 2) 每行做自动断行后加入 allTextLines（0x1919AD8–0x1919BC4）
            foreach (LineRenderingElements elements in assembledLogicalLines)
            {
                List<TextLine> lines = AutoLineBreakRule.Apply(
                    elements,
                    width,
                    LineBreakRule.GetLineBreakRule(lineBreakRule),
                    useBurasage,
                    null);

                for (int i = 1; i < lines.Count; i++)
                {
                    lines[i].IsAutoLineBreak = true;   // TextLine 0x21
                }

                allTextLines.AddRange(lines);
            }

            // 3) 标记最后一行（0x1919BDC–0x1919C08）
            if (allTextLines.Count > 0)
            {
                allTextLines[allTextLines.Count - 1].IsLastLine = true;   // TextLine 0x20
            }

            // 4) 计算 maxIndex（0x1919C10–0x1919C84）
            maxIndex = 0;
            for (int i = allTextLines.Count - 1; i >= 0; i--)
            {
                int value = allTextLines[i].MaxIndex();
                if (value == -1)
                {
                    continue;
                }

                maxIndex = value;
                break;
            }

            visibleMinIndex = 0;
            visibleMaxIndex = maxIndex;
        }

        // RVA: 0x1918174
        private void CreateRequestGlyphSpecs()
        {
            allGlyphSpecs.Clear();

            foreach (List<SplitDenyGlyphSpecs> logicalLine in logicalLines)
            {
                foreach (SplitDenyGlyphSpecs splitDenyGlyphSpecs in logicalLine)
                {
                    foreach (IGlyphSpecGroup glyphSpecGroup in splitDenyGlyphSpecs.Groups)
                    {
                        foreach (MainGlyphPlacementSpec main in glyphSpecGroup.Mains)
                        {
                            if (main.GlyphSpec is FontGlyphSpec fontGlyphSpec)
                            {
                                allGlyphSpecs.Add(fontGlyphSpec);
                            }
                            else if (main.GlyphSpec is ImageGlyphSpec imageGlyphSpec)
                            {
                                allGlyphSpecs.Add(imageGlyphSpec.SizeBaseGlyphSpec);
                            }
                        }

                        if (glyphSpecGroup.RubiesCount >= 1)
                        {
                            allGlyphSpecs.AddRange(glyphSpecGroup.Rubies);
                        }
                    }
                }
            }

            if (overflowExtensionComponent != null && overflowExtensionComponent.EllipsisEnabled)
            {
                FontStyle fontStyle = isBold
                    ? (isItalic ? FontStyle.BoldAndItalic : FontStyle.Bold)
                    : (isItalic ? FontStyle.Italic : FontStyle.Normal);

                allGlyphSpecs.Add(overflowExtensionComponent.CreateFontGlyphSpec(
                    font,
                    FontSize,
                    fontStyle,
                    color,
                    GlyphScaleX));
            }
        }

        // RVA: 0x191B15C
        public bool CreateGlyphs()
        {
            assembledLogicalLines.Clear();
            return GlyphCatalog.GetCatalog(font).CreateGlyphs(allGlyphSpecs);
        }

        // RVA: 0x191AE70
        private void UpdateGlyph()
        {
            horizontalLayout.UpdateGlyph(font);
        }

        // RVA: 0x1914670
        protected bool GetHasArabic()
        {
            TextRun[] textRuns = textSource.TextRuns;

            for (int i = 0; i < textRuns.Length; i++)
            {
                if (textRuns[i] is ArabicTextCharacters)
                {
                    return true;
                }
            }

            return false;
        }

        // RVA: 0x1917A6C
        protected virtual Jigbox.TextView.Markup.MarkupParser CreateMarkupParser()
        {
            if (extensibilityProvider != null)
            {
                return extensibilityProvider.CreateMarkupParser();
            }

            return new Jigbox.TextView.Markup.MarkupParser();
        }

        // RVA: 0x1917D48
        private void TextParseError()
        {
            if (onTextParseError.Count >= 1)
            {
                onTextParseError.Execute<string>(textSource.ErrorMessage);
            }
            else
            {
                Debug.LogError(textSource.ErrorMessage);
            }
        }

        // RVA: 0x1916AB4
        public static void SetInitializer(Action<TextView> onInitialize)
        {
            TextView.onInitialize = onInitialize;
        }

        public bool AlreadyCalculatedLayout
        {
            // RVA: 0x1913D74
            get { return !workflow.IsNecessaryProcess(WorkflowProcess.GlyphPlacement); }
        }

        // RVA: 0x1917E04
        private void OnInitializeIfNeeded()
        {
            if (workflow.CanExecuteProcess(WorkflowProcess.Initialize))
            {
                workflow.ProcessExecuted(WorkflowProcess.Initialize);

                if (onInitialize != null)
                {
                    onInitialize(this);
                }
            }
        }

        // RVA: 0x1917054
        // 未完整还原：0x19170B0–0x1917108 为对 [0xA8] 成员的委托注册
        // （回调方法取自 TextView 元数据槽 0x548，目标类型属未还原的 Unity 内部程序集）。
        // 这里还原 base.Awake() 与工作流初始化，后者是整条排版管线的入口。
        protected override void Awake()
        {
            base.Awake();
            workflow.RequireProcess(WorkflowProcess.TextParse, true);
        }

        // RVA: 0x1915F10
        // 未完整还原：完整流程为
        //   CheckSqueezeAndShrinkByRectTransform();
        //   if (CanExecuteProcess(LogicalLinesCreate))    { CreateLogicalLines();        ProcessExecuted(...); }
        //   if (CanExecuteProcess(RequestGlyphSpecsCreate)){ CreateRequestGlyphSpecs();   ProcessExecuted(...); }
        //   if (CanExecuteProcess(CreateGlyph))           { if (!CreateGlyphs()) return false;
        //                                                   ProcessExecuted(...);
        //                                                   if (AlreadyCalculatedLayout) UpdateGlyph(); }
        //   if (CanExecuteProcess(Squeeze)) { if (SqueezeIfNeeded()) goto restart; ProcessExecuted(...); }
        //   if (CanExecuteProcess(Shrink))  { if (ShrinkIfNeeded())  goto restart; ProcessExecuted(...); }
        //   return false;
        // restart:
        //   RequireProcess(LogicalLinesCreate, true);
        //   return true;
        // RVA: 0x1915F10
        // 未完整还原：完整流程为
        //   CheckSqueezeAndShrinkByRectTransform();
        //   if (CanExecuteProcess(LogicalLinesCreate))    { CreateLogicalLines();        ProcessExecuted(...); }
        //   if (CanExecuteProcess(RequestGlyphSpecsCreate)){ CreateRequestGlyphSpecs();   ProcessExecuted(...); }
        //   if (CanExecuteProcess(CreateGlyph))           { if (!CreateGlyphs()) return false;
        //                                                   ProcessExecuted(...);
        //                                                   if (AlreadyCalculatedLayout) UpdateGlyph(); }
        //   if (CanExecuteProcess(Squeeze)) { if (SqueezeIfNeeded()) goto restart; ProcessExecuted(...); }
        //   if (CanExecuteProcess(Shrink))  { if (ShrinkIfNeeded())  goto restart; ProcessExecuted(...); }
        //   return false;
        // restart:
        //   RequireProcess(LogicalLinesCreate, true);
        //   return true;
        // 已落地 LogicalLinesCreate / RequestGlyphSpecsCreate / CreateGlyph 三个阶段；
        // CheckSqueezeAndShrinkByRectTransform、SqueezeIfNeeded、ShrinkIfNeeded 未还原。
        // RVA: 0x1916084
        // 未完整还原：完整实现依次执行
        //   CheckRecalculateByRectTransform / CreateTextLinesIncludeEllipsis / CreateHorizontalLayoutedElements /
        //   CalculateLinesOffsetY / CalculateTextLinesPositionX / PickUpDisplayableHorizontalLayoutedElements /
        //   CalculateCurrentOffsetY / PlacementInlineImage / UpdateGlyph 等阶段（共 9 个辅助方法）。
        // 目前仅保留「按当前 rect 宽度生成 allTextLines」这一阶段。
        // RVA: 0x1917B24
        private TextLine[] SplitTextLines(int startLine, List<TextLine> textLines)
        {
            List<TextLine> splitted = new List<TextLine>();      // 0x1917B80

            for (int i = startLine; i < textLines.Count; i++)    // 0x1917B8C–0x1917BE0
            {
                splitted.Add(textLines[i]);                      // 0x1917BCC
            }

            return splitted.ToArray();                           // 0x1917C04
        }

        // RVA: 0x191B1F4
        private void CreateHorizontalLayoutedElements()
        {
            horizontalLayout.Clear();                                  // 0x191B250

            foreach (TextLine line in allTextLines)                    // 0x191B254
            {
                GlyphPlacement[] glyphs = line.PlacedGlyphs;            // 0x191B2B8
                if (glyphs == null || glyphs.Length < 1)
                {
                    continue;
                }

                for (int i = 0; i < glyphs.Length; i++)
                {
                    GlyphPlacement placement = glyphs[i];

                    if (placement.Glyph is InlineImageGlyph)            // 0x191B2E4–0x191B314
                    {
                        horizontalLayout.Add(new HorizontalLayoutedImage(placement));   // 0x1816E18
                    }
                    else
                    {
                        horizontalLayout.Add(new HorizontalLayoutedGlyph(placement));   // 0x1816690
                    }
                }
            }
        }

        // RVA: 0x191B590
        private void CalculateTextLinesPositionX()
        {
            HorizontalAlignmentCalculator.Apply(
                allTextLines,
                alignment,                                              // 0x191B5E0 (0x148)
                justify,                                                // 0x191B5E4 (0x150)
                rectTransform.rect.width);                              // 0x191B610

            float xMin = rectTransform.rect.xMin;                       // 0x191B650

            foreach (TextLine line in allTextLines)
            {
                line.LineX += xMin;                                     // 0x191B688–0x191B690
            }
        }

        // RVA: 0x19198B0
        // 未还原：刷新行内图片提供者（依赖 MonoBehaviour inlineImageProvider 0x130）。
        private void RefreshInlineImageIfNeeded()
        {
            throw new NotImplementedException("RefreshInlineImageIfNeeded 尚未还原");
        }

        // RVA: 0x191969C
        // 注：0x19196E8 与 0x191974C 处的两个分支标志在过滤输出中被省略，
        // 这里按字段语义取 isSkipRecalculate(0x10D) 与 dimensionChangedAfterFirstUpdate(0x10B)。
        private void CheckRecalculateByRectTransform()
        {
            if (isSkipRecalculate)                                          // 0x19196E8
            {
                return;
            }

            Vector2 size = rectTransform.rect.size;                          // 0x191971C
            Vector2 pivot = rectTransform.pivot;                             // 0x191973C

            if (dimensionChangedAfterFirstUpdate.HasValue)                    // 0x191974C
            {
                dimensionChangedAfterFirstUpdate = null;                     // 0x1919758 (strh wzr)
                lastSize = size;                                             // 0x1919760
                lastPivot = pivot;                                           // 0x1919768
                workflow.RequireProcess(WorkflowProcess.GlyphPlacement, true); // 0x1919780
                RefreshInlineImageIfNeeded();                                // 0x1919788
                SetVerticesDirty();                                          // 0x191979C (vtable 0x2F0)
                return;
            }

            if (lastSize != size)                                            // 0x19197E0 Vector2.op_Inequality
            {
                lastSize = size;                                             // 0x19197EC
                lastPivot = pivot;                                           // 0x19197F4
                workflow.RequireProcess(WorkflowProcess.GlyphPlacement, true); // 0x191980C
                RefreshInlineImageIfNeeded();                                // 0x1919814
                return;
            }

            if (lastPivot != pivot)                                          // 0x1919850
            {
                lastPivot = pivot;                                           // 0x191985C
                workflow.RequireProcess(WorkflowProcess.LinesOffsetYCalculate, true);       // 0x1919874 (6)
                workflow.RequireProcess(WorkflowProcess.TextLinesPositionXCalculate, true); // 0x191988C (5)
            }
        }

        // RVA: 0x1919D14
        private void CreateTextLinesIncludeEllipsis(float width)
        {
            int ellipsisLine = overflowExtensionComponent.EllipsisLine;      // 0x1919D7C (0x48)
            int firstVisible = -1;                                          // w22
            int skipped = 0;                                                // w23

            // 从省略号行向前找非自动换行的起点（0x1919D88–0x1919DD4）
            for (int i = ellipsisLine; i >= 0; i--)
            {
                TextLine line = allTextLines[i];
                if (!line.IsAutoLineBreak)                                  // 0x1919DB4 (0x21)
                {
                    if (firstVisible == -1)
                    {
                        firstVisible = i;                                   // 0x1919DC0
                    }
                    else
                    {
                        skipped++;                                          // 0x1919DC4
                    }
                }
            }

            int span = allTextLines.Count - firstVisible;                   // 0x1919DDC
            for (int k = 0; k < span; k++)
            {
                allTextLines.RemoveAt(allTextLines.Count - 1);              // 0x1919E08
            }

            int processed = 0;                                              // w24
            foreach (LineRenderingElements logicalLine in assembledLogicalLines)   // 0x1919E24 (0xE8)
            {
                if (processed < skipped)                                    // 0x1919E7C
                {
                    processed++;
                    continue;
                }

                LineBreakRule rule = LineBreakRule.GetLineBreakRule(lineBreakRule);   // 0x1919EB4 (0x180)

                AutoLineEllipsisParameter? ellipsis = new AutoLineEllipsisParameter(
                    overflowExtensionComponent, allTextLines.Count);         // 0x1919EF4/0x1919F10

                List<TextLine> lines = AutoLineBreakRule.Apply(
                    logicalLine, width, rule, useBurasage, ellipsis);        // 0x1919F3C

                for (int i = 1; i < lines.Count; i++)                        // 0x1919F50
                {
                    lines[i].IsAutoLineBreak = true;                         // 0x1919F78 (0x21)
                }

                allTextLines.AddRange(lines);                                // 0x1919FA8
            }

            // 重算 maxIndex → visibleMaxIndex（0x1919FB0–0x191A080）
            maxIndex = 0;
            for (int i = allTextLines.Count - 1; i >= 0; i--)
            {
                int value = allTextLines[i].MaxIndex();                      // 0x191A04C
                if (value == -1)
                {
                    continue;                                               // 0x191A058
                }

                maxIndex = value;
                break;
            }

            visibleMaxIndex = maxIndex;                                      // 0x191A074/0x191A080
        }

        // RVA: 0x191B718
        private void PickUpDisplayableHorizontalLayoutedElements()
        {
            int startLine = Math.Max(visibleLineStart, 0);                        // 0x191B770–0x191B798
            if (startLine >= allTextLines.Count)                                  // 0x191B7AC
            {
                return;
            }

            int elementStart = 0;
            if (visibleLength >= 1)                                               // 0x191B7B4
            {
                for (int i = 0; i < startLine; i++)                               // 0x191B7C4–0x191B808
                {
                    elementStart += allTextLines[i].PlacedGlyphs.Length;
                }
            }

            visibleMinIndex = allTextLines[startLine].MinIndex();                 // 0x191B838
            visibleStartLineOffsetY = 0f;                                         // 0x191B844

            if (visibleLength >= 1)                                               // 0x191B83C
            {
                visibleStartLineOffsetY = rectTransform.rect.yMax                 // 0x191B8A0–0x191B8CC
                    - allTextLines[startLine].CalculateHeightUpperBaseLine(FontSize, isLineHeightFixed, -1);
            }

            horizontalLayout.DisplayableElementStartIndex = elementStart;          // 0x191B8EC
            horizontalLayout.ClearOverflowText();                                 // 0x191B8FC
            visibleMaxIndex = 0;                                                  // 0x191B904

            int glyphCount = 0;
            bool stop = false;
            int lastLineIndex = startLine;      // w20（0x191BA1C）
            int lastLineGlyphs = 0;             // w25（0x191BA14）

            for (int lineIndex = startLine; lineIndex < allTextLines.Count; lineIndex++)   // 0x191B924
            {
                TextLine line = allTextLines[lineIndex];

                bool overflown = verticalOverflow == VerticalWrapMode.Truncate    // 0x191B950
                    && rectTransform.rect.yMin > line.LineY - visibleStartLineOffsetY;  // 0x191B990

                bool ellipsisLine = overflowExtensionComponent != null             // 0x191B9C0
                    && overflowExtensionComponent.EllipsisLine == lineIndex - 1;   // 0x191B9DC

                if (overflown || ellipsisLine)                                    // → 0x191BA4C
                {
                    if (overflowExtensionComponent != null
                        && overflowExtensionComponent.EllipsisEnabled                 // 0x191BA80 (0x18)
                        && lineIndex - 1 >= 0                                         // 0x191BA88
                        && overflowExtensionComponent.EllipsisLine < 0)                // 0x191BA94
                    {
                        overflowExtensionComponent.SetEllipsisParameter(
                            lineIndex - 1, characterSpacing, spacingUnit);            // 0x191BAA8

                        workflow.RequireProcess(WorkflowProcess.EllipsisCalculate, true); // 0x191BAC4
                        return;                                                       // 0x191BAC8
                    }

                    horizontalLayout.SetOverflowText(                              // 0x191BAF0
                        lineIndex, SplitTextLines(lineIndex, allTextLines));       // 0x191BAD8
                }

                int maxIndex = line.MaxIndex();                                   // 0x191B9F0
                if (maxIndex != -1)
                {
                    visibleMaxIndex = maxIndex;                                   // 0x191B9FC
                }

                if (!stop)                                                        // 0x191BA00
                {
                    lastLineIndex = lineIndex;                                    // 0x191BA1C
                    lastLineGlyphs = line.PlacedGlyphs.Length;                    // 0x191BA14
                    glyphCount += lastLineGlyphs;                                 // 0x191BA20
                    stop = visibleLength >= 0 && maxIndex >= visibleLength;        // 0x191BA34
                }

                if (overflown || ellipsisLine)
                {
                    break;
                }

                if (lineIndex == allTextLines.Count - 1)
                {
                    // 循环自然结束后由下方统一收尾
                }
            }

            int elementEnd = elementStart + glyphCount;                           // 0x191BAF8

            if (visibleLength != -1)                                              // 0x191BAFC
            {
                elementEnd = elementEnd - lastLineGlyphs                         // 0x191BB3C
                    + allTextLines[lastLineIndex].GetPlacedGlyphCountAtVisibleIndex(visibleLength); // 0x191BB38
            }

            horizontalLayout.DisplayableElementEndIndex = elementEnd;              // 0x191BB54
        }

        // RVA: 0x191BB80
        private float CalculateCurrentOffsetY()
        {
            float height = Mathf.Max(rectTransform.rect.height, 0f);   // 0x191BBEC–0x191BC20
            float pivotY = rectTransform.pivot.y;                      // 0x191BC3C
            float yMin = horizontalLayout.yMin;                        // 0x191BC50
            float layoutHeight = horizontalLayout.Height;              // 0x191BC64

            float value = height * pivotY + yMin - layoutHeight - visibleStartLineOffsetY; // 0x191BC68–0x191BC80

            switch (verticalAlignment)
            {
                case TextVerticalAlign.Top:                                   // 0x191BD08
                    return 0f;
                case TextVerticalAlign.Center:                                // 0x191BD10
                    return value * 0.5f;
                case TextVerticalAlign.Bottom:                                // 0x191BD18
                    return value;
                default:
                    Debug.LogWarning("unknown vertical alignment: " + (int)verticalAlignment); // 0x191BCD0–0x191BD04
                    return 0f;
            }
        }

        // RVA: 0x191B444
        private void CalculateLinesOffsetY()
        {
            float y = rectTransform.rect.yMax;                                  // 0x191B4B4
            float lineGap = (FontSize * 0.5f) * (lineHeight - 1f);              // 0x191B4CC–0x191B4E8

            for (int i = 0; i < allTextLines.Count; i++)
            {
                TextLine line = allTextLines[i];
                float upper = line.CalculateHeightUpperBaseLine(FontSize, isLineHeightFixed, -1);  // 0x191B534
                float under = line.CalculateHeightUnderBaseLine(font, isLineHeightFixed, -1);      // 0x191B550

                line.LineY = y - upper;                                          // 0x191B554/0x191B558
                y = line.LineY - (lineGap + under);                              // 0x191B560/0x191B564
            }
        }

        public void CalculateLayout(bool isPlacedGlyph = false)
        {
            CheckRecalculateByRectTransform();                       // 0x1916110
            float width = Mathf.Max(0f, rectTransform.rect.width);   // 0x19161A0–0x19161F4

            // 0x1916124–0x1916258：省略号流与普通流是互斥分支
            if (overflowExtensionComponent != null && overflowExtensionComponent.IsEllipsisFlow)
            {
                CreateTextLinesIncludeEllipsis(width);               // 0x19161FC
            }
            else
            {
                CreateAllTextLines(width);                           // 0x19162C4
            }
            CreateHorizontalLayoutedElements();                      // 0x19162CC
            CalculateLinesOffsetY();                                 // 0x1916314
            CalculateTextLinesPositionX();                           // 0x1916498
            PickUpDisplayableHorizontalLayoutedElements();           // 0x191669C
            offsetY = CalculateCurrentOffsetY();                     // 0x19166F8
            UpdateGlyph();                                           // 0x19167A8
        }

        public bool RequestFontAndCreateGlyph()
        {
            if (workflow.CanExecuteProcess(WorkflowProcess.LogicalLinesCreate))
            {
                CreateLogicalLines();
                workflow.ProcessExecuted(WorkflowProcess.LogicalLinesCreate);
            }

            if (workflow.CanExecuteProcess(WorkflowProcess.RequestGlyphSpecsCreate))
            {
                CreateRequestGlyphSpecs();
                workflow.ProcessExecuted(WorkflowProcess.RequestGlyphSpecsCreate);
            }

            if (workflow.CanExecuteProcess(WorkflowProcess.CreateGlyph))
            {
                if (!CreateGlyphs())
                {
                    return false;
                }

                workflow.ProcessExecuted(WorkflowProcess.CreateGlyph);

                if (AlreadyCalculatedLayout)
                {
                    UpdateGlyph();
                }
            }

            return false;
        }

        // RVA: 0x1915DF4
        // 已还原骨架：font 判空 → ParseText → CreateGlyph 循环 → CalculateLayout(false)。
        // CalculateLayout 目前只实现「生成 allTextLines」阶段（其余 8 个阶段未还原）。
        private void ForceUpdate()
        {
            if (font == null)
            {
                return;
            }

            ParseText();

            while (workflow.IsNecessaryProcess(WorkflowProcess.CreateGlyph))
            {
                // 原实现直接循环；当 allGlyphSpecs 为空时 CreateGlyphs 返回 false，
                // CreateGlyph 标志不会被清除而会死循环。这里在失败时退出。
                if (!RequestFontAndCreateGlyph())
                {
                    break;
                }
            }

            CalculateLayout(false);
        }

        // RVA: 0x1915B84
        private void EarlyUpdateIfNeeded()
        {
            if (Font == null)
            {
                maxIndex = 0;
                visibleMinIndex = 0;
                visibleMaxIndex = 0;
                return;
            }

            if (workflow.IsNecessaryProcess(WorkflowProcess.DisplayableElementIndexCalculate))
            {
                ForceUpdate();
            }
        }
    }
}
