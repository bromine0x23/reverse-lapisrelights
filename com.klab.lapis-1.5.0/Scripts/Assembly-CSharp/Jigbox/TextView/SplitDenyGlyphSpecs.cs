// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.SplitDenyGlyphSpecs
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（构造）
// =============================================================================

using System;
using System.Collections.Generic;

namespace Jigbox.TextView
{
    public class SplitDenyGlyphSpecs
    {
        private readonly List<IGlyphSpecGroup> groups; // 0x10

        public virtual IEnumerable<IGlyphSpecGroup> Groups
        {
            // RVA: 0x1683B10
            get { return groups; }
        }

        public int MainsCount
        {
            // RVA: 0x1683B18
            get;
            // RVA: 0x1683B20
            protected set;
        } // 0x18

        // RVA: 0x1683B28
        public SplitDenyGlyphSpecs(IEnumerable<IGlyphSpecGroup> groups)
        {
            if (groups == null)
            {
                throw new ArgumentNullException("groups");
            }

            this.groups = new List<IGlyphSpecGroup>(groups);

            if (this.groups.Count == 0)
            {
                throw new ArgumentException("groups");
            }

            foreach (IGlyphSpecGroup group in this.groups)
            {
                MainsCount += group.MainsCount;
            }
        }

        // RVA: 0x1683D5C
        protected SplitDenyGlyphSpecs()
        {
        }
    }
}
