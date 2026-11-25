// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.Components.TextViewOverflowExtension
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（已还原成员）
//  说明：已还原字段、基础属性、Ellipsis 判定、Squeeze/Shrink 判定与构造。
//        CreateFontGlyphSpec/GetEllipsisGlyph/EllipsisOffsetWidth/
//        SetEllipsisParameter/CalculateSqueezedSize/CalculateShrinkedFontSize/
//        RequireCalculate/Unnecessary*/参数类仍待还原。
// =============================================================================

using Jigbox.TextView;
using UnityEngine;

namespace Jigbox.Components
{
    public class TextViewOverflowExtension : MonoBehaviour
    {
        public enum SqueezeAndShrinkCriterionSize
        {
            FirstLineWidth = 0,
            AllLineHeight = 1
        }

        // 说明：构造 (TextViewOverflowExtension overflowExtension, int currentAllTextLineSize)
        //       位于 0x191A130，尚未还原；当前仅声明字段布局。
        public struct AutoLineEllipsisParameter
        {
            public readonly int EllipsisLine;  // 0x0
            public readonly float OffsetWidth; // 0x4

            // RVA: 0x191A130
            public AutoLineEllipsisParameter(TextViewOverflowExtension overflowExtension, int currentAllTextLineSize)
            {
                EllipsisLine = overflowExtension.EllipsisLine - currentAllTextLineSize;   // 0x191A140–0x191A150
                OffsetWidth = overflowExtension.EllipsisOffsetWidth();                     // 0x191A160
            }
        }

        protected static readonly char EllipsisChar = '\u2026'; // 0x2026

        [SerializeField] protected bool ellipsisEnabled;   // 0x18
        [SerializeField] protected bool squeezeEnabled;    // 0x19
        [SerializeField] protected int squeezeMaxSize;     // 0x1C
        [SerializeField] protected int squeezeStepSize;    // 0x20
        [SerializeField] protected bool shrinkEnabled;     // 0x24
        [SerializeField] protected int shrinkMinFontSize;  // 0x28
        [SerializeField] protected SqueezeAndShrinkCriterionSize criterionSize; // 0x2C

        protected float? cachedSqueezedSize;  // 0x30
        protected int? cachedShrinkedSize;    // 0x38
        protected RectTransform rectTransform; // 0x40
        protected float characterSpacing;     // 0x4C
        protected SpacingUnit spacingUnit;    // 0x50
        protected FontGlyphSpec fontGlyphSpec; // 0x58

        public bool EllipsisEnabled
        {
            // RVA: 0x191ED74
            get { return ellipsisEnabled; }
            // RVA: 0x191ED7C
            set { ellipsisEnabled = value; }
        }

        public bool SqueezeEnabled
        {
            // RVA: 0x191ED88
            get { return squeezeEnabled; }
            // RVA: 0x191ED90
            set { squeezeEnabled = value; }
        }

        public int SqueezeMaxSize
        {
            // RVA: 0x191ED9C
            get { return squeezeMaxSize; }
        }

        public int SqueezeStepSize
        {
            // RVA: 0x191EDA4
            get { return squeezeStepSize; }
        }

        public bool ShrinkEnabled
        {
            // RVA: 0x191EDAC
            get { return shrinkEnabled; }
            // RVA: 0x191EDB4
            set { shrinkEnabled = value; }
        }

        public int ShrinkMinFontSize
        {
            // RVA: 0x191EDC0
            get { return shrinkMinFontSize; }
            // RVA: 0x191EDC8
            set { shrinkMinFontSize = value; }
        }

        public virtual SqueezeAndShrinkCriterionSize CriterionSize
        {
            // RVA: 0x191EDD0
            get { return criterionSize; }
        }

        public float SqueezedSize
        {
            // RVA: 0x1913D20
            get { return cachedSqueezedSize ?? 1f; }
        }

        public int ShrinkedSize
        {
            // RVA: 0x1914424
            get { return cachedShrinkedSize ?? 1; }
        }

        public RectTransform RectTransform
        {
            // RVA: 0x191EDD8
            get
            {
                if (rectTransform == null)
                {
                    rectTransform = transform as RectTransform;
                }

                return rectTransform;
            }
        }

        public bool IsEllipsisFlow
        {
            // RVA: 0x191AD24
            get { return EllipsisLine >= 0; }
        }

        public int EllipsisLine { get; private set; } // 0x48

        // RVA: 0x191EE94
        public virtual FontGlyphSpec CreateFontGlyphSpec(Font font, int fontSize, FontStyle fontStyle, Color color, float glyphScaleX)
        {
            fontGlyphSpec = new FontGlyphSpec(EllipsisChar, font, fontSize, fontStyle, color, glyphScaleX);
            return fontGlyphSpec;
        }

        // RVA: 0x191F0E0
        public virtual void SetEllipsisParameter(int ellipsisLine, float characterSpacing, SpacingUnit spacingUnit)
        {
            EllipsisLine = ellipsisLine;      // 0x48
            this.characterSpacing = characterSpacing; // 0x4C
            this.spacingUnit = spacingUnit;   // 0x50
        }

        // RVA: 0x191EFC8
        public virtual Glyph GetEllipsisGlyph()
        {
            GlyphCatalog catalog = GlyphCatalog.GetCatalog(fontGlyphSpec.Font);   // 0x191F00C/0x191F030
            return catalog.Get(fontGlyphSpec);                                    // 0x191F048
        }

        // RVA: 0x191F050
        public virtual float EllipsisOffsetWidth()
        {
            Glyph glyph = GetEllipsisGlyph();   // 0x191F068 (vtbl 0x190)

            float offset;
            switch (spacingUnit)                // 0x191F06C (0x50)
            {
                case SpacingUnit.FontSize:      // 0x191F09C
                    offset = fontGlyphSpec.Size * characterSpacing;          // 0x191F0A4–0x191F0B8
                    offset = (int)offset;
                    offset = fontGlyphSpec.GlyphScaleX * offset;             // 0x191F0C0
                    break;

                case SpacingUnit.BeforeCharacterWidth:   // 0x191F080
                    offset = characterSpacing * glyph.Width;                 // 0x191F084–0x191F094
                    offset = (int)offset;
                    break;

                default:                        // 0x191F078
                    offset = 0f;
                    break;
            }

            return offset + glyph.Width;        // 0x191F0C8/0x191F0D0
        }

        // RVA: 0x191F8A0
        public virtual bool IsNeedSqueeze()
        {
            return squeezeEnabled && !cachedSqueezedSize.HasValue;
        }

        // RVA: 0x191F8FC
        public virtual bool IsNeedShrink()
        {
            return shrinkEnabled && !cachedShrinkedSize.HasValue;
        }

        // RVA: 0x191F958
        public TextViewOverflowExtension()
        {
            squeezeMaxSize = 50;
            squeezeStepSize = 1;
            shrinkEnabled = true;
            shrinkMinFontSize = 1;
        }

        // RVA: 0x191F978
        static TextViewOverflowExtension()
        {
        }
    }
}
