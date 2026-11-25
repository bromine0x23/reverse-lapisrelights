// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ScenarioSaveLoadData
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections.Generic;

[Serializable]
public class ScenarioSaveLoadData
{
    public List<ScenarioSaveLoadData.CheckPoint> CheckPoints;

    // RVA: 0x1B87930
    public ScenarioSaveLoadData()
    {
        CheckPoints = new List<CheckPoint>();
    }

    [Serializable]
    public class CheckPoint
    {
        public string Line;
        public string DialogID;
        public string PrizeId;
        public int flag;
        public int Actorid;
        public string TextKey;

        // RVA: 0x1B879A0
        public CheckPoint()
        {
        }
    }
}
