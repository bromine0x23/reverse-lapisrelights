// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.VirtualCameraFollowAndLookAt
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        positionIndex < 0：按 followName / lookAtName 直接 GameObject.Find；
//        否则在 [Predeploy]/ActorLocation/<positionIndex> 下递归查找同名节点
// =============================================================================

using Cinemachine;
using Oz.GameFramework.Runtime;
using UnityEngine;

namespace Oz.Timeline
{
    public class VirtualCameraFollowAndLookAt : MonoBehaviour
    {
        public int positionIndex;
        public string followName;
        public string lookAtName;
        private CinemachineVirtualCamera _virtualCamera;

        // RVA: 0x13DE210
        public CinemachineVirtualCamera VirtualCamera
        {
            get
            {
                if (_virtualCamera == null)
                {
                    _virtualCamera = GetComponent<CinemachineVirtualCamera>();
                }
                return _virtualCamera;
            }
        }

        // RVA: 0x13DE2A8
        private void Start()
        {
            ApplyLookAt(VirtualCamera);
        }

        // RVA: 0x13DE2D0
        public void ApplyLookAt(ICinemachineCamera cinemachineCamera)
        {
            if (positionIndex < 0)
            {
                if (!string.IsNullOrEmpty(followName))
                {
                    GameObject follow = GameObject.Find(followName);
                    if (follow != null)
                    {
                        cinemachineCamera.Follow = follow.transform;
                    }
                }

                if (string.IsNullOrEmpty(lookAtName))
                {
                    return;
                }

                GameObject lookAt = GameObject.Find(lookAtName);
                if (lookAt == null)
                {
                    return;
                }
                cinemachineCamera.LookAt = lookAt.transform;
                return;
            }

            GameObject location = GameObject.Find("[Predeploy]/ActorLocation");
            if (location == null)
            {
                return;
            }

            Transform target = location.transform.Find(positionIndex.ToString());
            if (target == null)
            {
                return;
            }

            if (cinemachineCamera.Follow == null)
            {
                cinemachineCamera.Follow = TransformExtentions.RecursiveFind(target, t => t.name.Equals(followName));
            }
            if (cinemachineCamera.LookAt == null)
            {
                cinemachineCamera.LookAt = TransformExtentions.RecursiveFind(target, t => t.name.Equals(lookAtName));
            }
        }

        // RVA: 0x13DE82C
        public VirtualCameraFollowAndLookAt()
        {
        }

    }
}
