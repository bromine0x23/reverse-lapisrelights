// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ScenarioCamera
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  剧情相机模块：监听 Cinemachine 激活事件与时间线 Await/Resume，
//  在激活相机上应用机位参考点，并临时提升/恢复相机优先级。
// =============================================================================

using Cinemachine;
using UnityEngine;

public class ScenarioCamera : Module, IScenarioEvent
{
    public CinemachineBrain Brain;
    private CinemachineVirtualCamera cacheCamera;
    private int cachePriority;

    // RVA: 0x1B79BC8
    public override void Init()
    {
        base.Init();
        RegistEvent();
    }

    // RVA: 0x1B79BF8
    public override void Dispose()
    {
        base.Dispose();
        UnRegistEvent();
    }

    // RVA: 0x1B79C28
    public override void RegistEvent()
    {
        Brain.m_CameraActivatedEvent.AddListener(vcamActivatedEvent);
        Kit.Events.OnAwait.AddEventListener(PriorityOnAwait);
        Kit.Events.OnResume.AddEventListener(HandleEvent);
    }

    // RVA: 0x1B79DF0
    private void vcamActivatedEvent(ICinemachineCamera newVC, ICinemachineCamera oldVC)
    {
        CinemachineVirtualCameraBase virtualCamera = newVC as CinemachineVirtualCameraBase;
        if (!virtualCamera)
        {
            return;
        }

        ScenarioCameraPostion component = virtualCamera.GetComponent<ScenarioCameraPostion>();
        if (!component)
        {
            return;
        }

        Transform follow = component.Follow.Resolve<Transform>();
        if (follow)
        {
            virtualCamera.Follow = follow;
        }

        Transform lookAt = component.LookAt.Resolve<Transform>();
        if (lookAt)
        {
            virtualCamera.LookAt = lookAt;
        }
    }

    // RVA: 0x1B7A008
    private void PriorityOnAwait(TimeLine.Behaviour.Context obj)
    {
        Priority();
    }

    // RVA: 0x1B7A0E4
    public override void UnRegistEvent()
    {
        Brain.m_CameraActivatedEvent.RemoveListener(vcamActivatedEvent);
        Kit.Events.OnResume.RemoveEventListener(HandleEvent);
        Kit.Events.OnAwait.RemoveEventListener(PriorityOnAwait);
    }

    // RVA: 0x1B7A264
    public override void HandleEvent(object obj)
    {
        UnPriority();
    }

    // RVA: 0x1B7A268
    public void UnPriority()
    {
        if (cacheCamera)
        {
            if (cachePriority != -1)
            {
                cacheCamera.Priority = cachePriority;
                cachePriority = -1;
            }
        }
    }

    // RVA: 0x1B7A00C
    public void Priority()
    {
        CinemachineVirtualCamera activeVirtualCamera =
            Brain.ActiveVirtualCamera as CinemachineVirtualCamera;
        if (activeVirtualCamera)
        {
            Priority(activeVirtualCamera);
        }
    }

    // RVA: 0x1B7A300
    public void Priority(CinemachineVirtualCamera VCamera)
    {
        UnPriority();

        cacheCamera = VCamera;
        cachePriority = VCamera.Priority;

        if (Application.isPlaying)
        {
            VCamera.Priority = 1000;
        }

        VCamera.MoveToTopOfPrioritySubqueue();
    }

    // RVA: 0x1B7A354
    public ScenarioCamera()
    {
        cachePriority = -1;
    }
}
