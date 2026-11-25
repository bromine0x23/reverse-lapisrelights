// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ScenarioCameraPostion
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  相机机位参考点：把 Follow/LookAt 场景引用应用到同物体上的虚拟相机。
// =============================================================================

using Cinemachine;
using UnityEngine;

public class ScenarioCameraPostion : ReferenceObject
{
    public string Description;
    public SceneReference Follow;
    public SceneReference LookAt;

    public override Color color
    {
        // RVA: 0x1B7A364
        get { return Color.red; }
    }

    // RVA: 0x1B7A36C
    public void SynchronizeName()
    {
        if (string.IsNullOrEmpty(Description))
        {
            return;
        }
        gameObject.name = Description;
    }

    // RVA: 0x1B7A3C0
    private void Start()
    {
        Focal();
    }

    // RVA: 0x1B7A3C4
    public void Focal()
    {
        Transform follow = Follow.Resolve<Transform>();
        if (follow)
        {
            GetComponent<CinemachineVirtualCameraBase>().Follow = follow;
        }

        Transform lookAt = LookAt.Resolve<Transform>();
        if (lookAt)
        {
            GetComponent<CinemachineVirtualCameraBase>().LookAt = lookAt;
        }
    }

    // RVA: 0x1B7A544
    protected override void OnDrawGizmos()
    {
        Gizmos.color = color;
        Gizmos.DrawSphere(transform.position, 0.05f);
    }

    // RVA: 0x1B7A59C
    public ScenarioCameraPostion()
    {
        Follow = new SceneReference();
        LookAt = new SceneReference();
    }
}
