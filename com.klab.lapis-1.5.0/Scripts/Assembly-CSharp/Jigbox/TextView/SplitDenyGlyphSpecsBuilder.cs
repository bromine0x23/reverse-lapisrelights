// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.SplitDenyGlyphSpecsBuilder
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（全部方法）
//  说明：把 TextRun 流按行/组/字形逐层累积为 SplitDenyGlyphSpecs。
//        - Span 上下文（<span>）把若干主字形聚成一个 GlyphSpecGroup；
//        - Ruby 上下文（<ruby>）为主字形附加注音字形；
//        - 顶层字形直接以 Minimum* 免分配包装挂在当前行。
// =============================================================================

using System.Collections.Generic;

namespace Jigbox.TextView
{
    public class SplitDenyGlyphSpecsBuilder
    {
        protected Stack<Context> context;                             // 0x10
        protected List<List<SplitDenyGlyphSpecs>> result;             // 0x18
        protected MutableSplitDenyGlyphSpecs currentSplitDenyGlyphSpecs; // 0x20
        protected MutableGlyphSpecGroup currentGlyphSpecGroup;        // 0x28
        protected bool? isInRuby;                                     // 0x30
        protected bool? isInSpan;                                     // 0x32

        public virtual bool IsInRuby
        {
            // RVA: 0x1683D64
            get
            {
                if (!isInRuby.HasValue)
                {
                    isInRuby = context.Contains(Context.Ruby);
                }

                return isInRuby.Value;
            }
        }

        public virtual bool IsInSpan
        {
            // RVA: 0x1683E14
            get
            {
                if (!isInSpan.HasValue)
                {
                    isInSpan = context.Contains(Context.Span);
                }

                return isInSpan.Value;
            }
        }

        protected virtual List<SplitDenyGlyphSpecs> CurrentLine
        {
            // RVA: 0x1683EC4
            get { return result[result.Count - 1]; }
        }

        // RVA: 0x1683F30
        public SplitDenyGlyphSpecsBuilder()
        {
            context = new Stack<Context>();
            result = new List<List<SplitDenyGlyphSpecs>>();
            result.Add(new List<SplitDenyGlyphSpecs>());
        }

        // RVA: 0x168400C
        public virtual void PushTextModifier(TextModifier textModifier)
        {
            // 反汇编 0x168404C 的 isinst 目标为 TextCharactersSpanGroup：
            // 只有 <span> 起始才开启 Span 上下文，其余修饰器只压 TextModifier。
            if (!(textModifier is TextCharactersSpanGroup))
            {
                context.Push(Context.TextModifier);
                isInSpan = null;
                return;
            }

            if (!IsInSpan)
            {
                currentSplitDenyGlyphSpecs = new MutableSplitDenyGlyphSpecs();
            }

            context.Push(Context.Span);
            isInSpan = null;
        }

        // RVA: 0x168416C
        public virtual void PopTextModifier()
        {
            if (context.Count == 0)
            {
                return;
            }

            Context top = context.Peek();
            if (top == Context.Ruby)
            {
                return;
            }

            Context popped = context.Pop();
            if (popped == Context.Span)
            {
                isInSpan = null;
            }

            if (popped == Context.TextModifier)
            {
                return;
            }

            if (IsInRuby || IsInSpan)
            {
                return;
            }

            if (currentGlyphSpecGroup.Mains.Count >= 1)
            {
                currentSplitDenyGlyphSpecs.Groups.Add(currentGlyphSpecGroup.CreateImmutable());
            }

            if (currentSplitDenyGlyphSpecs.Groups.Count >= 1)
            {
                CurrentLine.Add(currentSplitDenyGlyphSpecs.CreateImmutable());
            }

            currentSplitDenyGlyphSpecs = null;
            currentGlyphSpecGroup = null;
        }

        // RVA: 0x16842E8
        public virtual void StartRuby(TextModifierScope modifierScope)
        {
            if (!IsInRuby)
            {
                if (IsInSpan)
                {
                    currentSplitDenyGlyphSpecs.Groups.Add(currentGlyphSpecGroup.CreateImmutable());
                }
                else
                {
                    currentSplitDenyGlyphSpecs = new MutableSplitDenyGlyphSpecs();
                }

                currentGlyphSpecGroup = new MutableGlyphSpecGroup();

                if (modifierScope != null)
                {
                    currentGlyphSpecGroup.RubyOffset = modifierScope.RubyOffset;
                    currentGlyphSpecGroup.RubyScale = modifierScope.RubyFontScale;
                }
            }

            context.Push(Context.Ruby);
            isInRuby = null;
        }

        // RVA: 0x1684580
        public virtual void EndRuby()
        {
            if (context.Count == 0)
            {
                return;
            }

            if (context.Peek() != Context.Ruby)
            {
                return;
            }

            context.Pop();
            isInRuby = null;

            if (IsInRuby)
            {
                return;
            }

            if (currentGlyphSpecGroup.Mains.Count >= 1)
            {
                currentSplitDenyGlyphSpecs.Groups.Add(currentGlyphSpecGroup.CreateImmutable());
            }

            currentGlyphSpecGroup = null;

            if (IsInSpan)
            {
                return;
            }

            if (currentSplitDenyGlyphSpecs.Groups.Count >= 1)
            {
                CurrentLine.Add(currentSplitDenyGlyphSpecs.CreateImmutable());
            }

            currentSplitDenyGlyphSpecs = null;
        }

        // RVA: 0x16846EC
        public virtual void AddMainGlyphPlacementSpec(MainGlyphPlacementSpec mainGlyphPlacementSpec)
        {
            if (!IsInSpan && !IsInRuby)
            {
                CurrentLine.Add(new MinimumSplitDenyGlyphSpecs(new MinimumGlyphSpecGroup(mainGlyphPlacementSpec)));
                return;
            }

            if (IsInSpan && currentGlyphSpecGroup == null)
            {
                currentGlyphSpecGroup = new MutableGlyphSpecGroup();
            }

            currentGlyphSpecGroup.Mains.Add(mainGlyphPlacementSpec);
        }

        // RVA: 0x1684824
        public virtual void AddRubyFontRequestSpec(FontGlyphSpec rubyGlyphSpec)
        {
            if (!IsInRuby)
            {
                return;
            }

            if (currentGlyphSpecGroup.Rubies == null)
            {
                currentGlyphSpecGroup.Rubies = new List<FontGlyphSpec>();
            }

            currentGlyphSpecGroup.Rubies.Add(rubyGlyphSpec);
        }

        // RVA: 0x16848F0
        public virtual void AddLineBreak()
        {
            if (IsInSpan || IsInRuby)
            {
                return;
            }

            result.Add(new List<SplitDenyGlyphSpecs>());
        }

        // RVA: 0x16849A8
        public virtual List<List<SplitDenyGlyphSpecs>> Build()
        {
            List<List<SplitDenyGlyphSpecs>> output = new List<List<SplitDenyGlyphSpecs>>();
            foreach (List<SplitDenyGlyphSpecs> line in result)
            {
                output.Add(new List<SplitDenyGlyphSpecs>(line));
            }

            List<IGlyphSpecGroup> groups = currentSplitDenyGlyphSpecs != null
                ? new List<IGlyphSpecGroup>(currentSplitDenyGlyphSpecs.Groups)
                : new List<IGlyphSpecGroup>();

            if (currentGlyphSpecGroup != null && currentGlyphSpecGroup.Mains.Count >= 1)
            {
                groups.Add(currentSplitDenyGlyphSpecs.CreateImmutable());
                CurrentLineOf(output).Add(new SplitDenyGlyphSpecs(groups));
            }

            return output;
        }

        private static List<SplitDenyGlyphSpecs> CurrentLineOf(List<List<SplitDenyGlyphSpecs>> lines)
        {
            return lines[lines.Count - 1];
        }

        protected enum Context
        {
            Span = 0,
            TextModifier = 1,
            Ruby = 2
        }

        protected class MutableSplitDenyGlyphSpecs
        {
            public readonly List<IGlyphSpecGroup> Groups; // 0x10

            // RVA: 0x1684CAC
            public virtual SplitDenyGlyphSpecs CreateImmutable()
            {
                return new SplitDenyGlyphSpecs(Groups);
            }

            // RVA: 0x16840FC
            public MutableSplitDenyGlyphSpecs()
            {
                Groups = new List<IGlyphSpecGroup>();
            }
        }

        protected class MutableGlyphSpecGroup
        {
            public readonly List<MainGlyphPlacementSpec> Mains; // 0x10
            public List<FontGlyphSpec> Rubies;                  // 0x18
            public float? RubyOffset;                           // 0x20
            public float? RubyScale;                            // 0x28

            // RVA: 0x1684C24
            public virtual GlyphSpecGroup CreateImmutable()
            {
                return new GlyphSpecGroup(Mains, Rubies, RubyOffset, RubyScale);
            }

            // RVA: 0x1684428
            public MutableGlyphSpecGroup()
            {
                Mains = new List<MainGlyphPlacementSpec>();
            }
        }
    }
}
