// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  SwitchController
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  分支 UI 控制器：把 OnSwitch/OnSelect 事件接到相机、历史记录、存档与 Lua。
// =============================================================================

using System.Collections.Generic;
using LuaInterface;
using UnityEngine.Playables;

public class SwitchController : UIController
{
    // RVA: 0x1ACD494
    public override void RegistEvent()
    {
        base.RegistEvent();
        Kit.Events.OnSelect.AddEventListener(OnSelect);
        Kit.Events.OnSwitch.AddEventListener(OnSwitch);
    }

    // RVA: 0x1ACD5BC
    protected virtual void OnSwitch(Switch option, List<Switch.Case> obj)
    {
        ScenarioKit.Instance.Cameras.Priority();
        Kit.Events.OnShowSwitch.Dispatch(option, obj);
    }

    // RVA: 0x1ACD660
    public override void UnRegistEvent()
    {
        base.UnRegistEvent();
        Kit.Events.OnSelect.RemoveEventListener(OnSelect);
        Kit.Events.OnSwitch.RemoveEventListener(OnSwitch);
    }

    // RVA: 0x1ACD788
    protected virtual void OnSelect(Switch options, Switch.Case _case)
    {
        ScenarioKit.Instance.UI.DialogPanel.gameObject.SetActive(true);
        _case.Selected = true;

        if (_case._timeline != null)
        {
            if (_case._timeline.time > 0.0)
            {
                _case._timeline.Resume();
            }
            else
            {
                _case._timeline.Play();
            }

            if (!string.IsNullOrEmpty(_case.GotoDialogID))
            {
                Dialog dialog = Kit.Timelines.GetDialog(_case._timeline, _case.GotoDialogID);
                if (dialog)
                {
                    _case._timeline.time = dialog.clipInfo.start;
                }
            }
        }

        if (!string.IsNullOrEmpty(_case._timeline.name))
        {
            ScenarioKit.Instance.UI.DialogPanel.gameObject.SetActive(false);
        }

        ScenarioKit.Instance.UI.Switch.gameObject.SetActive(false);
        ScenarioKit.Instance.Cameras.UnPriority();

        if (ScenarioKit.Instance.UI.History)
        {
            HistoryLine.Data data = new HistoryLine.Data();
            data.actorId = -1;
            data.actorName = options.NameKey;
            data.Txt = _case.CaseKey;
            ScenarioKit.Instance.UI.History.AddData(data);
        }

        ScenarioSaveLoadData.CheckPoint checkPoint = new ScenarioSaveLoadData.CheckPoint();
        checkPoint.Line = _case._timeline.name;
        checkPoint.flag = 1;
        checkPoint.PrizeId = _case.PrizeId;
        Kit.saveLoad.AddCheckPoint(checkPoint);

        ToLuaModule.ToLuaAPI api;
        LuaFunction function = Kit.Lua.GetFunction("OnSelectOption", out api, null);
        if (function != null)
        {
            LuaTable table = Kit.Lua.GetEmptyTable();
            table["PrizeId"] = _case.PrizeId;
            table["DialogId"] = _case.behaviour.context.clip.clipInfo.displayName;
            function.Call(api.table, table);
        }
    }

    // RVA: 0x1ACDBDC
    public SwitchController()
    {
    }
}
