// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.MinimumSplitDenyGlyphSpecs
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（成员）
//  说明：单组 SplitDenyGlyphSpecs 的免分配快速实现。
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;

namespace Jigbox.TextView
{
    public sealed class MinimumSplitDenyGlyphSpecs : SplitDenyGlyphSpecs
    {
        private static Enumerable groupContainer; // 0x0
        private IGlyphSpecGroup group;            // 0x20

        public override IEnumerable<IGlyphSpecGroup> Groups
        {
            // RVA: 0x1822748
            get
            {
                groupContainer.Group = group;
                return groupContainer;
            }
        }

        // RVA: 0x18227F0
        public MinimumSplitDenyGlyphSpecs(IGlyphSpecGroup group)
        {
            if (group == null)
            {
                throw new ArgumentNullException("group");
            }

            this.group = group;
            MainsCount = 1;
        }

        // RVA: 0x1822894
        static MinimumSplitDenyGlyphSpecs()
        {
            groupContainer = new Enumerable();
        }

        public sealed class Enumerable : IEnumerable<IGlyphSpecGroup>
        {
            private Enumerator enumerator; // 0x10

            public IGlyphSpecGroup Group
            {
                // RVA: 0x1822964
                get { return enumerator.Group; }
                // RVA: 0x18227D8
                set { enumerator.Group = value; }
            }

            // RVA: 0x1822AB4
            public IEnumerator<IGlyphSpecGroup> GetEnumerator()
            {
                return enumerator;
            }

            // RVA: 0x1822ADC
            IEnumerator IEnumerable.GetEnumerator()
            {
                return enumerator;
            }

            // RVA: 0x18228FC
            public Enumerable()
            {
                enumerator = new Enumerator();
            }

            public sealed class Enumerator : IEnumerator<IGlyphSpecGroup>
            {
                private static IGlyphSpecGroup[] container; // 0x0
                private IGlyphSpecGroup current;            // 0x10
                private int state;

                public IGlyphSpecGroup Group
                {
                    // RVA: 0x182297C
                    get { return current; }
                    // RVA: 0x1822A04
                    set
                    {
                        current = value;
                        container = null;
                        state = -1;
                    }
                }

                public IGlyphSpecGroup Current
                {
                    // RVA: 0x1822B04
                    get { return current; }
                }

                object IEnumerator.Current
                {
                    // RVA: 0x1822B0C
                    get { return current; }
                }

                // RVA: 0x1822B14
                public bool MoveNext()
                {
                    if (state >= 0)
                    {
                        return false;
                    }

                    if (container == null)
                    {
                        container = new[] { current };
                    }

                    state = 0;
                    return true;
                }

                // RVA: 0x1822AD4
                public void Reset()
                {
                    state = -1;
                }

                // RVA: 0x1822BBC
                public void Dispose()
                {
                }

                // RVA: 0x1822AFC
                public Enumerator()
                {
                    state = -1;
                }

                // RVA: 0x1822BC0
                static Enumerator()
                {
                }
            }
        }
    }
}
