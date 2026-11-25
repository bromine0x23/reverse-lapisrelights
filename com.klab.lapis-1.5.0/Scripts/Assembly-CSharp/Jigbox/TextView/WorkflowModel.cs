// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.WorkflowModel
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  说明：静态构造函数中的处理链与 {6,5,4,3} 进程掩码来自 libil2cpp.so
//        反汇编（0x1689B54）与 global-metadata.dat（字段 0x5355AC）。
// =============================================================================

using System;
using System.Collections.Generic;

namespace Jigbox.TextView
{
    [Serializable]
    public sealed class WorkflowModel
    {
        private int flags;
        private static List<WorkflowProcessInfo> TextViewWorkflowDataList;

        // RVA: 0x1689B54
        static WorkflowModel()
        {
            TextViewWorkflowDataList = new List<WorkflowProcessInfo>();

            var rendering = new WorkflowProcessInfo(WorkflowProcess.Rendering);
            var fontTextureUVUpdate = new WorkflowProcessInfo(WorkflowProcess.FontTextureUVUpdate);
            var inlineImagePlacement = new WorkflowProcessJoinInfo(WorkflowProcess.InlineImagePlacement);
            var currentOffsetYCalculate = new WorkflowProcessInfo(WorkflowProcess.CurrentOffsetYCalculate);
            var displayableElementIndexCalculate =
                new WorkflowProcessInfo(WorkflowProcess.DisplayableElementIndexCalculate);
            var textLinesPositionXCalculate =
                new WorkflowProcessInfo(WorkflowProcess.TextLinesPositionXCalculate);
            var linesOffsetYCalculate = new WorkflowProcessInfo(WorkflowProcess.LinesOffsetYCalculate);
            var process4AllPassed = new WorkflowProcessSplitInfo(WorkflowProcess.Process4AllPassed);
            var ellipsisCalculate = new WorkflowProcessInfo(WorkflowProcess.EllipsisCalculate);
            var glyphPlacement = new WorkflowProcessInfo(WorkflowProcess.GlyphPlacement);
            var shrink = new WorkflowProcessInfo(WorkflowProcess.Shrink);
            var squeeze = new WorkflowProcessInfo(WorkflowProcess.Squeeze);
            var createGlyph = new WorkflowProcessInfo(WorkflowProcess.CreateGlyph);
            var requestGlyphSpecsCreate =
                new WorkflowProcessInfo(WorkflowProcess.RequestGlyphSpecsCreate);
            var logicalLinesCreate = new WorkflowProcessInfo(WorkflowProcess.LogicalLinesCreate);
            var textParse = new WorkflowProcessInfo(WorkflowProcess.TextParse);
            var initialize = new WorkflowProcessInfo(WorkflowProcess.Initialize);

            WorkflowProcess[] parallelProcesses =
            {
                WorkflowProcess.LinesOffsetYCalculate,
                WorkflowProcess.TextLinesPositionXCalculate,
                WorkflowProcess.DisplayableElementIndexCalculate,
                WorkflowProcess.CurrentOffsetYCalculate
            };

            initialize.Initialize(null, textParse);
            textParse.Initialize(initialize, logicalLinesCreate);
            logicalLinesCreate.Initialize(textParse, requestGlyphSpecsCreate);
            requestGlyphSpecsCreate.Initialize(logicalLinesCreate, createGlyph);
            createGlyph.Initialize(requestGlyphSpecsCreate, squeeze);
            squeeze.Initialize(createGlyph, shrink);
            shrink.Initialize(squeeze, glyphPlacement);
            glyphPlacement.Initialize(shrink, process4AllPassed);
            ellipsisCalculate.Initialize(glyphPlacement, process4AllPassed);
            process4AllPassed.Initialize(glyphPlacement, inlineImagePlacement, parallelProcesses);
            linesOffsetYCalculate.Initialize(glyphPlacement, inlineImagePlacement);
            textLinesPositionXCalculate.Initialize(glyphPlacement, inlineImagePlacement);
            displayableElementIndexCalculate.Initialize(glyphPlacement, inlineImagePlacement);
            currentOffsetYCalculate.Initialize(glyphPlacement, inlineImagePlacement);
            inlineImagePlacement.Initialize(process4AllPassed, fontTextureUVUpdate, parallelProcesses);
            fontTextureUVUpdate.Initialize(glyphPlacement, rendering);
            rendering.Initialize(fontTextureUVUpdate, null);

            TextViewWorkflowDataList.Add(rendering);
            TextViewWorkflowDataList.Add(fontTextureUVUpdate);
            TextViewWorkflowDataList.Add(inlineImagePlacement);
            TextViewWorkflowDataList.Add(currentOffsetYCalculate);
            TextViewWorkflowDataList.Add(displayableElementIndexCalculate);
            TextViewWorkflowDataList.Add(textLinesPositionXCalculate);
            TextViewWorkflowDataList.Add(linesOffsetYCalculate);
            TextViewWorkflowDataList.Add(process4AllPassed);
            TextViewWorkflowDataList.Add(ellipsisCalculate);
            TextViewWorkflowDataList.Add(glyphPlacement);
            TextViewWorkflowDataList.Add(shrink);
            TextViewWorkflowDataList.Add(squeeze);
            TextViewWorkflowDataList.Add(createGlyph);
            TextViewWorkflowDataList.Add(requestGlyphSpecsCreate);
            TextViewWorkflowDataList.Add(logicalLinesCreate);
            TextViewWorkflowDataList.Add(textParse);
            TextViewWorkflowDataList.Add(initialize);
        }

        // RVA: 0x168A2A0
        public WorkflowModel()
        {
            InternalRequireProcess(WorkflowProcess.Initialize, false);
        }

        // RVA: 0x168A3AC
        public bool IsNecessaryProcess(WorkflowProcess process)
        {
            return (flags & TextViewWorkflowDataList[(int)process].SelfMask) != 0;
        }

        // RVA: 0x168A460
        public bool CanExecuteProcess(WorkflowProcess process)
        {
            WorkflowProcessInfo info = TextViewWorkflowDataList[(int)process];
            if ((info.HigherProcessMask & flags) != 0)
            {
                return false;
            }

            return (info.SelfMask & flags) != 0;
        }

        // RVA: 0x168A580
        public void RequireProcess(WorkflowProcess process, bool requireLowerProcesses = true)
        {
            InternalRequireProcess(process, requireLowerProcesses);
        }

        // RVA: 0x168A588
        public void ProcessExecuted(WorkflowProcess process)
        {
            flags &= ~TextViewWorkflowDataList[(int)process].SelfMask;
        }

        // RVA: 0x168A2D0
        private void InternalRequireProcess(WorkflowProcess process, bool requireLowerProcesses = true)
        {
            WorkflowProcessInfo info = TextViewWorkflowDataList[(int)process];
            flags |= info.SelfMask;

            if (requireLowerProcesses)
            {
                while (info != null)
                {
                    flags |= info.LowerProcessMask;
                    info = info.LowerProcess;
                }
            }
        }

        private class WorkflowProcessInfo
        {
            public WorkflowProcessInfo HigherProcess { get; protected set; }
            public WorkflowProcessInfo LowerProcess { get; protected set; }
            public int SelfMask { get; protected set; }

            public virtual int HigherProcessMask
            {
                // RVA: 0x168A66C
                get { return HigherProcess == null ? 0 : HigherProcess.SelfMask; }
            }

            public virtual int LowerProcessMask
            {
                // RVA: 0x168A684
                get { return LowerProcess == null ? 0 : LowerProcess.SelfMask; }
            }

            // RVA: 0x168A11C
            public WorkflowProcessInfo(WorkflowProcess process)
            {
                SelfMask = 1 << (int)process;
            }

            // RVA: 0x168A1B8
            public void Initialize(WorkflowProcessInfo higher, WorkflowProcessInfo lower)
            {
                HigherProcess = higher;
                LowerProcess = lower;
            }

            // RVA: 0x168A534
            public bool IsExecutable(int flags)
            {
                if ((HigherProcessMask & flags) != 0)
                {
                    return false;
                }

                return (SelfMask & flags) != 0;
            }
        }

        private class WorkflowProcessJoinInfo : WorkflowProcessInfo
        {
            protected int higherMask;

            public override int HigherProcessMask
            {
                // RVA: 0x168A69C
                get { return higherMask; }
            }

            // RVA: 0x168A184
            public WorkflowProcessJoinInfo(WorkflowProcess process)
                : base(process)
            {
            }

            // RVA: 0x168A230
            public void Initialize(
                WorkflowProcessInfo higher,
                WorkflowProcessInfo lower,
                WorkflowProcess[] higherProcesses)
            {
                base.Initialize(higher, lower);

                for (int i = 0; i < higherProcesses.Length; i++)
                {
                    higherMask |= 1 << (int)higherProcesses[i];
                }
            }
        }

        private class WorkflowProcessSplitInfo : WorkflowProcessInfo
        {
            protected int lowerMask;

            public override int LowerProcessMask
            {
                // RVA: 0x168A6A4
                get
                {
                    int lowerSelfMask = LowerProcess == null ? 0 : LowerProcess.SelfMask;
                    return lowerSelfMask | lowerMask;
                }
            }

            // RVA: 0x168A150
            public WorkflowProcessSplitInfo(WorkflowProcess process)
                : base(process)
            {
            }

            // RVA: 0x168A1C0
            public void Initialize(
                WorkflowProcessInfo higher,
                WorkflowProcessInfo lower,
                WorkflowProcess[] lowerProcesses)
            {
                base.Initialize(higher, lower);

                for (int i = 0; i < lowerProcesses.Length; i++)
                {
                    lowerMask |= 1 << (int)lowerProcesses[i];
                }
            }
        }
    }
}
