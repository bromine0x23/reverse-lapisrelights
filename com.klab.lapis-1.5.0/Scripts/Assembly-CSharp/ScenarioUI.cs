// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ScenarioUI
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  统一管理剧情 UI 控制器与视图，按类型查找并统一初始化/销毁。
// =============================================================================

using System.Collections.Generic;

public class ScenarioUI : Module
{
    public List<UIController> Controllers;
    public List<UIView> Views;

    public UIDialogPannel DialogPanel
    {
        // RVA: 0x1943F38
        get { return GetView<UIDialogPannel>(); }
    }

    public UIChapterGroupPannel ChapterGroup
    {
        // RVA: 0x1943F88
        get { return GetView<UIChapterGroupPannel>(); }
    }

    public UIChapterPannel Chapter
    {
        // RVA: 0x1943FD8
        get { return GetView<UIChapterPannel>(); }
    }

    public UISwitchPannel Switch
    {
        // RVA: 0x1944028
        get { return GetView<UISwitchPannel>(); }
    }

    public UICG CG
    {
        // RVA: 0x1944078
        get { return GetView<UICG>(); }
    }

    public UISection Section
    {
        // RVA: 0x19440C8
        get { return GetView<UISection>(); }
    }

    public UIHistory History
    {
        // RVA: 0x194351C
        get { return GetView<UIHistory>(); }
    }

    public UIControlls controlls
    {
        // RVA: 0x1944118
        get { return GetView<UIControlls>(); }
    }

    public UICover cover
    {
        // RVA: 0x1944168
        get { return GetView<UICover>(); }
    }

    public ScenarioVideo video
    {
        // RVA: 0x19441B8
        get { return GetView<ScenarioVideo>(); }
    }

    public T GetController<T>()
    {
        UIController controller = Controllers.Find(x => x is T);
        return (T)(object)controller;
    }

    public T GetView<T>()
    {
        UIView view = Views.Find(x => x is T);
        return (T)(object)view;
    }

    // RVA: 0x1944208
    private void Awake()
    {
        if (ScenarioKit.Instance != null)
        {
            ScenarioKit.Instance.UI = this;
        }
    }

    // RVA: 0x194429C
    public override void Init()
    {
        base.Init();

        foreach (UIController controller in Controllers)
        {
            if (controller != null)
            {
                controller.Init();
            }
        }
        foreach (UIView view in Views)
        {
            if (view != null)
            {
                view.Init();
            }
        }

        if (ChapterGroup != null) ChapterGroup.Init();
        if (Chapter != null) Chapter.Init();
        if (Switch != null) Switch.Init();
        if (cover != null) cover.Init();
        if (CG != null) CG.Init();
        if (Section != null) Section.Init();
        if (History != null) History.Init();
        if (controlls != null) controlls.Init();
        if (video != null) video.Init();
    }

    // RVA: 0x19447B0
    public override void Dispose()
    {
        base.Dispose();

        foreach (UIController controller in Controllers)
        {
            if (controller != null)
            {
                controller.Dispose();
            }
        }
        foreach (UIView view in Views)
        {
            if (view != null)
            {
                view.Dispose();
            }
        }

        if (ChapterGroup != null) ChapterGroup.Dispose();
        if (Chapter != null) Chapter.Dispose();
        if (cover != null) cover.Dispose();
        if (Switch != null) Switch.Dispose();
        if (Section != null) Section.Dispose();
        if (History != null) History.Dispose();
        if (controlls != null) controlls.Dispose();
        if (video != null) video.Dispose();
    }

    // RVA: 0x1944C74
    public ScenarioUI()
    {
        Controllers = new List<UIController>();
        Views = new List<UIView>();
    }
}
