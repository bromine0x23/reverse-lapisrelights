// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.VirtualCameraHook
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码（三个回调均为空实现）
// =============================================================================

using Cinemachine;
using UnityEngine;

namespace Oz.Timeline
{
    /// <summary>Cinemachine 事件钩子基类，由具体虚拟相机组件覆写。</summary>
    public class VirtualCameraHook : MonoBehaviour
    {
        // RVA: 0x13DE8AC
        public virtual void OnCinemachineCut(ICinemachineCamera camera)
        {
            // 空实现（伪代码仅有 return）
        }

        // RVA: 0x13DE8B0
        public virtual void OnCinemachineActived(
            ICinemachineCamera activeCamera,
            ICinemachineCamera activeCameraPreviousFrame)
        {
            // 空实现（伪代码仅有 return）
        }

        // RVA: 0x13DE8B4
        public virtual void OnCinemachineBlendComplete()
        {
            // 空实现（伪代码仅有 return）
        }

        // RVA: 0x13DE8B8
        public VirtualCameraHook()
        {
        }
    }
}
