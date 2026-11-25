// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  HistoryDisplay
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  剧情历史列表：缓存数据并驱动 SuperScrollView 复用列表项。
// =============================================================================

using System.Collections.Generic;
using SuperScrollView;
using UnityEngine;

public class HistoryDisplay : MonoBehaviour
{
    public LoopListView2 scrollView;
    private List<HistoryLine.Data> Cache;

    // RVA: 0x180AF2C
    public void RefreshView(List<HistoryLine.Data> datas)
    {
        Cache = datas;

        if (!scrollView.mListViewInited)
        {
            scrollView.InitListView(-1, onGetItemByIndex, null);
        }

        scrollView.SetListItemCount(Cache.Count, true);
        scrollView.MovePanelToItemIndex(Cache.Count, 0f);
    }

    // RVA: 0x180B018
    private LoopListViewItem2 onGetItemByIndex(LoopListView2 Listview, int index)
    {
        if (index < 0 || Cache.Count <= index)
        {
            return null;
        }

        LoopListViewItem2 item = Listview.NewListViewItem("Line");
        HistoryLine line = item.GetComponent<HistoryLine>();

        if (!item.IsInitHandlerCalled)
        {
            item.IsInitHandlerCalled = true;
        }

        line.RefreshData(Cache[index]);
        return item;
    }

    // RVA: 0x180B26C
    public HistoryDisplay()
    {
    }
}
