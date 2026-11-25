// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  HistoryLine
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  剧情历史条目：刷新数据显示，并把数据转发给 Lua 刷新界面。
// =============================================================================

using UnityEngine;
using UnityEngine.UI;

public class HistoryLine : MonoBehaviour
{
    public string Lua_UpdateLine;
    public Image avator;
    public string volEventName;
    public Button VolButton;

    // RVA: 0x180B10C
    public void RefreshData(HistoryLine.Data data)
    {
        VolButton.onClick.RemoveListener(OnClickVoice);
        volEventName = data.vol;

        if (string.IsNullOrEmpty(volEventName))
        {
            VolButton.gameObject.SetActive(false);
        }
        else
        {
            VolButton.gameObject.SetActive(true);
            VolButton.onClick.AddListener(OnClickVoice);
        }

        ScenarioKit.Instance.Lua.Call<object, object>(Lua_UpdateLine, this, data);
    }

    // RVA: 0x180B274
    private void OnClickVoice()
    {
        ScenarioKit.Instance.Sounds.PlayVoice(volEventName);
    }

    // RVA: 0x180B2B0
    public HistoryLine()
    {
        Lua_UpdateLine = string.Empty;
    }

    public class Data
    {
        public int actorId;
        public string actorName;
        public string Txt;
        public string vol;
        public string strIcon;

        // RVA: 0x180B308
        public Data()
        {
        }
    }
}
