// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Phone_SwitchController
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  手机端分支 UI：把 Switch.Case 转成 LuaCase 交给 Lua，并回传选择结果。
// =============================================================================

using System.Collections.Generic;

public class Phone_SwitchController : SwitchController
{
    private Dictionary<Phone_SwitchController.LuaCase, Switch.Case> cache;

    // RVA: 0x19B7630
    public override void RegistEvent()
    {
        base.RegistEvent();
        Kit.Events.OnShowSwitch.AddEventListener(OnShowSwitchLua);
        Kit.Events.OnSelectLua.AddEventListener(OnSelectLua);
    }

    // RVA: 0x19B775C
    public override void UnRegistEvent()
    {
        base.UnRegistEvent();
        Kit.Events.OnShowSwitch.RemoveEventListener(OnShowSwitchLua);
        Kit.Events.OnSelectLua.RemoveEventListener(OnSelectLua);
    }

    // RVA: 0x19B7888
    private void OnShowSwitchLua(Switch option, List<Switch.Case> obj)
    {
        cache.Clear();
        List<Phone_SwitchController.LuaCase> list = new List<Phone_SwitchController.LuaCase>();

        foreach (Switch.Case item in obj)
        {
            Phone_SwitchController.LuaCase luaCase = new Phone_SwitchController.LuaCase();
            luaCase.Text = Kit.Language.Get(item.CaseKey);
            luaCase.DialogId = item.behaviour.context.clip.clipInfo.displayName;
            luaCase.PrizeId = item.PrizeId;

            cache[luaCase] = item;
            list.Add(luaCase);
        }

        Kit.Lua.Call("GetAnswer", list);
    }

    // RVA: 0x19B7B30
    private void OnSelectLua(Phone_SwitchController.LuaCase obj)
    {
        Switch.Case value;
        if (cache.TryGetValue(obj, out value))
        {
            ScenarioSaveLoadData.CheckPoint checkPoint = new ScenarioSaveLoadData.CheckPoint();
            checkPoint.Line = value._timeline.name;
            checkPoint.flag = 1;
            checkPoint.PrizeId = value.PrizeId;
            Kit.saveLoad.AddCheckPoint(checkPoint);

            value.Selected = true;
            value._timeline.Play();
            ScenarioKit.Instance.Cameras.UnPriority();
        }

        if (ScenarioKit.Instance.UI.History)
        {
            HistoryLine.Data data = new HistoryLine.Data();
            data.actorId = -1;
            data.Txt = value.CaseKey;
            ScenarioKit.Instance.UI.History.AddData(data);
        }
    }

    // RVA: 0x19B7D24
    public Phone_SwitchController()
    {
        cache = new Dictionary<Phone_SwitchController.LuaCase, Switch.Case>();
    }

    public class LuaCase
    {
        public string Text;
        public string DialogId;
        public string PrizeId;

        // RVA: 0x19B7B28
        public LuaCase()
        {
        }
    }
}
