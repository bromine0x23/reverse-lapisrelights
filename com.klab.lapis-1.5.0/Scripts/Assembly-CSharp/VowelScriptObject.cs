// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  VowelScriptObject
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections.Generic;
using UnityEngine;

public class VowelScriptObject : ScriptableObject
{
    public double FrameRate;
    public List<VowelScriptObject.VowelClipInfo> ClipInfos;
    public int[] ClipInfoPos;
    private LinkedList<VowelScriptObject.VowelClipInfo> linklist;

    // RVA: 0x2C76DE4
    public void AddElement(AnimationIndex animationId, double start, double duration, double easeInDuration, double easeOutDuration)
    {
        VowelClipInfo info = new VowelClipInfo
        {
            Index = animationId,
            Start = start,
            Duration = duration,
            EaseInDuration = easeInDuration,
            EaseOutDuration = easeOutDuration
        };
        if (linklist == null)
        {
            linklist = new LinkedList<VowelClipInfo>();
        }
        linklist.AddLast(info);
        ClipInfos.Add(info);
    }

    // RVA: 0x2C76EEC
    public void Generate()
    {
        double total = linklist.Last.Value.Start + linklist.Last.Value.Duration;
        ClipInfoPos = new int[(int)(total * FrameRate)];
        for (int i = 0; i < ClipInfoPos.Length; i++)
        {
            ClipInfoPos[i] = -1;
        }
        if (ClipInfoPos.Length < 1)
        {
            return;
        }

        LinkedListNode<VowelClipInfo> node = linklist.First;
        int index = 0;
        for (int i = 0; i < ClipInfoPos.Length; i++)
        {
            ClipInfoPos[i] = index;
            VowelClipInfo info = node.Value;
            if ((double)i / FrameRate >= info.Start + info.Duration)
            {
                node = node.Next;
                index++;
            }
        }
    }

    // RVA: 0x2C77080
    public VowelScriptObject()
    {
        FrameRate = 30.0;
        ClipInfos = new List<VowelClipInfo>();
    }

    [Serializable]
    public class VowelClipInfo
    {
        public AnimationIndex Index;
        public double Start;
        public double Duration;
        public double EaseInDuration;
        public double EaseOutDuration;

        public double End
        {
            // RVA: 0x2C77074
            get { return Start + Duration; }
        }

        // RVA: 0x2C76EE4
        public VowelClipInfo()
        {
        }
    }
}
