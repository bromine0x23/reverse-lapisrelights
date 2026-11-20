// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.UIEventTriggerHelper
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using Oz.GameFramework.Runtime;
using UnityEngine;

namespace Oz.Framework
{
    /// <summary>按 <see cref="UIEventID"/> 取得/补齐 GameObject 上对应的触发器组件。</summary>
    public class UIEventTriggerHelper
    {
        /// <summary>
        /// 确保 GameObject 上存在对应触发器（不存在则添加），Unknown 时使用基础 EventTrigger。
        /// </summary>
        // RVA: 0x2EEA1EC
        public static EventTrigger AddMissingTrigger(GameObject gameObject, UIEventID evenID)
        {
            switch (evenID)
            {
                case UIEventID.PointerEnter:
                    return gameObject.AddMissingComponent<PointEnterTrigger>();
                case UIEventID.PointerExit:
                    return gameObject.AddMissingComponent<PointerExitTrigger>();
                case UIEventID.PointerDown:
                    return gameObject.AddMissingComponent<PointerDownTrigger>();
                case UIEventID.PointerUp:
                    return gameObject.AddMissingComponent<PointerUpTrigger>();
                case UIEventID.PointerClick:
                    return gameObject.AddMissingComponent<PointerClickTrigger>();
                case UIEventID.Drag:
                    return gameObject.AddMissingComponent<DragTrigger>();
                case UIEventID.Drop:
                    return gameObject.AddMissingComponent<DropTrigger>();
                case UIEventID.Scroll:
                    return gameObject.AddMissingComponent<ScrollTrigger>();
                case UIEventID.UpdateSelected:
                    return gameObject.AddMissingComponent<UpdateSelectedTrigger>();
                case UIEventID.Select:
                    return gameObject.AddMissingComponent<SelectTrigger>();
                case UIEventID.Deselect:
                    return gameObject.AddMissingComponent<DeselectTrigger>();
                case UIEventID.Move:
                    return gameObject.AddMissingComponent<MoveTrigger>();
                case UIEventID.InitializePotentialDrag:
                    return gameObject.AddMissingComponent<InitializePotentialDragTrigger>();
                case UIEventID.BeginDrag:
                    return gameObject.AddMissingComponent<BeginDragTrigger>();
                case UIEventID.EndDrag:
                    return gameObject.AddMissingComponent<EndDragTrigger>();
                case UIEventID.Submit:
                    return gameObject.AddMissingComponent<SubmitTrigger>();
                case UIEventID.Cancel:
                    return gameObject.AddMissingComponent<CancelTrigger>();
                case UIEventID.PointerRepeat:
                    return gameObject.AddMissingComponent<PointerRepeatTrigger>();
                case UIEventID.PointerLongPress:
                    return gameObject.AddMissingComponent<PointerLongPressTrigger>();
                default:
                    return gameObject.AddMissingComponent<EventTrigger>();
            }
        }

        /// <summary>取得 GameObject 上已有的对应触发器，缺失时返回 null（Unknown 时取 EventTrigger）。</summary>
        // RVA: 0x2EEA260
        public static EventTrigger GetTrigger(GameObject gameObject, UIEventID evenID)
        {
            switch (evenID)
            {
                case UIEventID.PointerEnter:
                {
                    PointEnterTrigger component;
                    gameObject.TryGetComponent<PointEnterTrigger>(out component);
                    return component;
                }
                case UIEventID.PointerExit:
                {
                    PointerExitTrigger component;
                    gameObject.TryGetComponent<PointerExitTrigger>(out component);
                    return component;
                }
                case UIEventID.PointerDown:
                {
                    PointerDownTrigger component;
                    gameObject.TryGetComponent<PointerDownTrigger>(out component);
                    return component;
                }
                case UIEventID.PointerUp:
                {
                    PointerUpTrigger component;
                    gameObject.TryGetComponent<PointerUpTrigger>(out component);
                    return component;
                }
                case UIEventID.PointerClick:
                {
                    PointerClickTrigger component;
                    gameObject.TryGetComponent<PointerClickTrigger>(out component);
                    return component;
                }
                case UIEventID.Drag:
                {
                    DragTrigger component;
                    gameObject.TryGetComponent<DragTrigger>(out component);
                    return component;
                }
                case UIEventID.Drop:
                {
                    DropTrigger component;
                    gameObject.TryGetComponent<DropTrigger>(out component);
                    return component;
                }
                case UIEventID.Scroll:
                {
                    ScrollTrigger component;
                    gameObject.TryGetComponent<ScrollTrigger>(out component);
                    return component;
                }
                case UIEventID.UpdateSelected:
                {
                    UpdateSelectedTrigger component;
                    gameObject.TryGetComponent<UpdateSelectedTrigger>(out component);
                    return component;
                }
                case UIEventID.Select:
                {
                    SelectTrigger component;
                    gameObject.TryGetComponent<SelectTrigger>(out component);
                    return component;
                }
                case UIEventID.Deselect:
                {
                    DeselectTrigger component;
                    gameObject.TryGetComponent<DeselectTrigger>(out component);
                    return component;
                }
                case UIEventID.Move:
                {
                    MoveTrigger component;
                    gameObject.TryGetComponent<MoveTrigger>(out component);
                    return component;
                }
                case UIEventID.InitializePotentialDrag:
                {
                    InitializePotentialDragTrigger component;
                    gameObject.TryGetComponent<InitializePotentialDragTrigger>(out component);
                    return component;
                }
                case UIEventID.BeginDrag:
                {
                    BeginDragTrigger component;
                    gameObject.TryGetComponent<BeginDragTrigger>(out component);
                    return component;
                }
                case UIEventID.EndDrag:
                {
                    EndDragTrigger component;
                    gameObject.TryGetComponent<EndDragTrigger>(out component);
                    return component;
                }
                case UIEventID.Submit:
                {
                    SubmitTrigger component;
                    gameObject.TryGetComponent<SubmitTrigger>(out component);
                    return component;
                }
                case UIEventID.Cancel:
                {
                    CancelTrigger component;
                    gameObject.TryGetComponent<CancelTrigger>(out component);
                    return component;
                }
                case UIEventID.PointerRepeat:
                {
                    PointerRepeatTrigger component;
                    gameObject.TryGetComponent<PointerRepeatTrigger>(out component);
                    return component;
                }
                case UIEventID.PointerLongPress:
                {
                    PointerLongPressTrigger component;
                    gameObject.TryGetComponent<PointerLongPressTrigger>(out component);
                    return component;
                }
                default:
                    return gameObject.GetComponent<EventTrigger>();
            }
        }

        // RVA: 0x2EEA5C4
        public UIEventTriggerHelper()
        {
        }
    }
}
