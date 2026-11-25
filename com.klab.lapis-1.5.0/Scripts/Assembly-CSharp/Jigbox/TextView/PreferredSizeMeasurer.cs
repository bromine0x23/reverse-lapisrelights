// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.PreferredSizeMeasurer (+ nested PreferredSizeMeasurerProperty)
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

namespace Jigbox.TextView
{
    public class PreferredSizeMeasurer
    {
        protected PreferredSizeMeasurerProperty property;
        protected PreferredWidthMeasurer widthMeasurer;
        protected PreferredHeightMeasurer heightMeasurer;

        public bool HasCache
        {
            // RVA: 0x1683424
            get { return widthMeasurer.HasCache && heightMeasurer.HasCache; }
        }

        public float PreferredWidth
        {
            // RVA: 0x168347C
            get { return widthMeasurer.Value; }
        }

        public float PreferredHeight
        {
            // RVA: 0x1683498
            get { return heightMeasurer.Value; }
        }

        // RVA: 0x16834B4
        public PreferredSizeMeasurer(Jigbox.Components.TextView textView)
        {
            if (textView != null)
            {
                property = new PreferredSizeMeasurerProperty(textView);

                widthMeasurer = new PreferredWidthMeasurer(property);
                widthMeasurer.IsCacheInvalid = true;

                heightMeasurer = new PreferredHeightMeasurer(property);
            }
        }

        // RVA: 0x1683614
        public void CalculatePreferredWidth(
            List<LineRenderingElements> renderingElements,
            PreferredWidthType type = PreferredWidthType.FirstLine)
        {
            if (widthMeasurer.Type != type)
            {
                widthMeasurer = CreateWidthMeasurer(type);
            }

            if (!widthMeasurer.HasCache)
            {
                widthMeasurer.CalculateWidth(renderingElements);
            }
        }

        // RVA: 0x1683798
        public void CalculatePreferredHeight(
            List<TextLine> textLines,
            PreferredHeightType type = PreferredHeightType.AllLine)
        {
            if (heightMeasurer.Type != type)
            {
                heightMeasurer = CreateHeightMeasurer(type);
            }

            if (!heightMeasurer.HasCache)
            {
                heightMeasurer.CalculateHeight(textLines);
            }
        }

        // RVA: 0x1683910
        public void InvalidateCache()
        {
            widthMeasurer.IsCacheInvalid = true;
            heightMeasurer.IsCacheInvalid = true;
        }

        // RVA: 0x16836B4
        protected PreferredWidthMeasurer CreateWidthMeasurer(PreferredWidthType type)
        {
            switch (type)
            {
                case PreferredWidthType.FirstLine:
                    return new PreferredWidthMeasurer(property);
                case PreferredWidthType.AllLogicalLine:
                    return new LogicalPreferredWidthMeasurer(property);
                case PreferredWidthType.Visibled:
                    return new VisibledPreferredWidthMeasurer(property);
                default:
                    return widthMeasurer;
            }
        }

        // RVA: 0x1683838
        protected PreferredHeightMeasurer CreateHeightMeasurer(PreferredHeightType type)
        {
            switch (type)
            {
                case PreferredHeightType.AllLine:
                    return new PreferredHeightMeasurer(property);
                case PreferredHeightType.AllLogicalLine:
                    return new LogicalPreferredHeightMeasurer(property);
                case PreferredHeightType.Visibled:
                    return new VisibledPreferredHeightMeasurer(property);
                default:
                    return heightMeasurer;
            }
        }

        public class PreferredSizeMeasurerProperty
        {
            protected Jigbox.Components.TextView textView;

            public virtual Font Font
            {
                // RVA: 0x16839E4
                get { return textView.Font; }
            }

            public virtual int FontSize
            {
                // RVA: 0x1683A00
                get { return textView.FontSize; }
            }

            public virtual bool IsLineHeightFixed
            {
                // RVA: 0x1683A1C
                get { return textView.IsLineHeightFixed; }
            }

            public virtual int VisibleLineStart
            {
                // RVA: 0x1683A38
                get { return textView.VisibleLineStart; }
            }

            public virtual int VisibleLength
            {
                // RVA: 0x1683A54
                get { return textView.VisibleLength; }
            }

            public virtual float LineGap
            {
                // RVA: 0x1683A70
                get { return textView.LineGap; }
            }

            // RVA: 0x16835B4
            public PreferredSizeMeasurerProperty(Jigbox.Components.TextView textView)
            {
                this.textView = textView;
            }
        }
    }
}
