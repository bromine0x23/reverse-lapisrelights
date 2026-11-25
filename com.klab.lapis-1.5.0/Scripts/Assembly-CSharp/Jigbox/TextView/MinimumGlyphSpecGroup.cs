// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.MinimumGlyphSpecGroup
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（成员）
//  说明：单字形组的免分配快速实现。Mains/Rubies 返回静态单元素序列容器。
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;

namespace Jigbox.TextView
{
    public sealed class MinimumGlyphSpecGroup : IGlyphSpecGroup
    {
        private static readonly RubyEnumerable rubiesContainer; // 0x0
        private static Enumerable mainContainer;                // 0x8
        private MainGlyphPlacementSpec mainGlyphSpec;           // 0x10

        public int MainsCount
        {
            // RVA: 0x1822108
            get { return 1; }
        }

        public int RubiesCount
        {
            // RVA: 0x1822110
            get { return 0; }
        }

        public float? RubyOffset
        {
            // RVA: 0x1822118
            get { return null; }
        }

        public float? RubyScale
        {
            // RVA: 0x1822120
            get { return null; }
        }

        public IEnumerable<MainGlyphPlacementSpec> Mains
        {
            // RVA: 0x1822128
            get
            {
                mainContainer.Main = mainGlyphSpec;
                return mainContainer;
            }
        }

        public IEnumerable<FontGlyphSpec> Rubies
        {
            // RVA: 0x18221D0
            get { return rubiesContainer; }
        }

        // RVA: 0x1822238
        public MinimumGlyphSpecGroup(MainGlyphPlacementSpec mainGlyphSpec)
        {
            if (mainGlyphSpec == null)
            {
                throw new ArgumentNullException("mainGlyphSpec");
            }

            this.mainGlyphSpec = mainGlyphSpec;
        }

        // RVA: 0x18222D4
        static MinimumGlyphSpecGroup()
        {
            mainContainer = new Enumerable();
            rubiesContainer = new RubyEnumerable();
        }

        public sealed class Enumerable : IEnumerable<MainGlyphPlacementSpec>
        {
            private Enumerator enumerator; // 0x10

            public MainGlyphPlacementSpec Main
            {
                // RVA: 0x1822430
                get { return enumerator.Main; }
                // RVA: 0x18221B8
                set { enumerator.Main = value; }
            }

            // RVA: 0x1822580
            public IEnumerator<MainGlyphPlacementSpec> GetEnumerator()
            {
                return enumerator;
            }

            // RVA: 0x18225A8
            IEnumerator IEnumerable.GetEnumerator()
            {
                return enumerator;
            }

            // RVA: 0x18223C8
            public Enumerable()
            {
                enumerator = new Enumerator();
            }

            public sealed class Enumerator : IEnumerator<MainGlyphPlacementSpec>
            {
                private static MainGlyphPlacementSpec[] container; // 0x0
                private MainGlyphPlacementSpec current;            // 0x10
                private int state;                                 // 迭代位置

                public MainGlyphPlacementSpec Main
                {
                    // RVA: 0x1822448
                    get { return current; }
                    // RVA: 0x18224D0
                    set
                    {
                        current = value;
                        container = null;
                        state = -1;
                    }
                }

                public MainGlyphPlacementSpec Current
                {
                    // RVA: 0x18225D0
                    get { return current; }
                }

                object IEnumerator.Current
                {
                    // RVA: 0x18225D8
                    get { return current; }
                }

                // RVA: 0x18225E0
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

                // RVA: 0x18225A0
                public void Reset()
                {
                    state = -1;
                }

                // RVA: 0x1822688
                public void Dispose()
                {
                }

                // RVA: 0x18225C8
                public Enumerator()
                {
                    state = -1;
                }

                // RVA: 0x182268C
                static Enumerator()
                {
                }
            }
        }

        public sealed class RubyEnumerable : IEnumerable<FontGlyphSpec>
        {
            // RVA: 0x18226F0
            public IEnumerator<FontGlyphSpec> GetEnumerator()
            {
                return new Enumerator();
            }

            // RVA: 0x182270C
            IEnumerator IEnumerable.GetEnumerator()
            {
                return new Enumerator();
            }

            // RVA: 0x1822360
            public RubyEnumerable()
            {
            }

            public sealed class Enumerator : IEnumerator<FontGlyphSpec>
            {
                public FontGlyphSpec Current
                {
                    // RVA: 0x182272C
                    get { return null; }
                }

                object IEnumerator.Current
                {
                    // RVA: 0x1822734
                    get { return null; }
                }

                // RVA: 0x182273C
                public bool MoveNext()
                {
                    return false;
                }

                // RVA: 0x1822708
                public void Reset()
                {
                }

                // RVA: 0x1822744
                public void Dispose()
                {
                }

                // RVA: 0x1822724
                public Enumerator()
                {
                }
            }
        }
    }
}
