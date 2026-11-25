// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.GlyphSpecGroup
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（构造）
// =============================================================================

using System;
using System.Collections.Generic;

namespace Jigbox.TextView
{
    public class GlyphSpecGroup : IGlyphSpecGroup
    {
        private readonly List<MainGlyphPlacementSpec> mains;  // 0x10
        private readonly List<FontGlyphSpec> rubies;          // 0x18
        protected readonly int mainsCount;                    // 0x20
        protected readonly int rubiesCount;                   // 0x24
        protected readonly float? rubyOffset;                 // 0x28
        protected readonly float? rubyScale;                  // 0x30

        public int MainsCount
        {
            // RVA: 0x181325C
            get { return mainsCount; }
        }

        public int RubiesCount
        {
            // RVA: 0x1813264
            get { return rubiesCount; }
        }

        public float? RubyOffset
        {
            // RVA: 0x181326C
            get { return rubyOffset; }
        }

        public float? RubyScale
        {
            // RVA: 0x1813274
            get { return rubyScale; }
        }

        public IEnumerable<MainGlyphPlacementSpec> Mains
        {
            // RVA: 0x181327C
            get { return mains; }
        }

        public IEnumerable<FontGlyphSpec> Rubies
        {
            // RVA: 0x1813284
            get { return rubies; }
        }

        // RVA: 0x181328C
        public GlyphSpecGroup(IEnumerable<MainGlyphPlacementSpec> mains, IEnumerable<FontGlyphSpec> rubies, float? rubyOffset, float? rubyScale)
        {
            if (mains == null)
            {
                throw new ArgumentNullException("mains");
            }

            this.mains = new List<MainGlyphPlacementSpec>(mains);
            mainsCount = this.mains.Count;

            if (mainsCount == 0)
            {
                throw new ArgumentException("mains");
            }

            this.rubies = rubies != null
                ? new List<FontGlyphSpec>(rubies)
                : new List<FontGlyphSpec>();
            rubiesCount = this.rubies.Count;

            this.rubyOffset = rubyOffset;
            this.rubyScale = rubyScale;
        }
    }
}
