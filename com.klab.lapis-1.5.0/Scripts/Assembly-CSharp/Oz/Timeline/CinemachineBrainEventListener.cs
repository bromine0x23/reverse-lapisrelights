// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.CinemachineBrainEventListener
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Awake/OnDestroy 订阅/退订 CameraCutEvent 与 CameraActivatedEvent；
//        Update 在非混合状态下遍历 hooks 调用 OnCinemachineBlendComplete
// =============================================================================

using Cinemachine;
using UnityEngine;

namespace Oz.Timeline
{
    public class CinemachineBrainEventListener : MonoBehaviour
    {
        private CinemachineBrain _cinemachineBrain;
        private VirtualCameraHook[] _hooks;

        // RVA: 0x13D6884
        private void Awake()
        {
            _cinemachineBrain = GetComponent<CinemachineBrain>();
            if (_cinemachineBrain != null)
            {
                _cinemachineBrain.m_CameraCutEvent.AddListener(OnCinemachineCut);
                _cinemachineBrain.m_CameraActivatedEvent.AddListener(OnCinemachineActived);
            }
        }

        // RVA: 0x13D6998
        private void OnDestroy()
        {
            if (_cinemachineBrain != null)
            {
                _cinemachineBrain.m_CameraCutEvent.RemoveListener(OnCinemachineCut);
                _cinemachineBrain.m_CameraActivatedEvent.RemoveListener(OnCinemachineActived);
            }
        }

        // RVA: 0x13D6A98
        public void OnCinemachineCut(CinemachineBrain brain)
        {
            // 空实现（伪代码仅有 return）
        }

        // RVA: 0x13D6A9C
        public void OnCinemachineActived(
            ICinemachineCamera activeCamera,
            ICinemachineCamera activeCameraPreviousFrame)
        {
            _hooks = activeCamera.VirtualCameraGameObject.GetComponents<VirtualCameraHook>();

            for (int i = 0; i < _hooks.Length; i++)
            {
                if (_hooks[i] != null)
                {
                    _hooks[i].OnCinemachineActived(activeCamera, activeCameraPreviousFrame);
                }
            }
        }

        // RVA: 0x13D6BCC
        private void Update()
        {
            if (_hooks == null)
            {
                return;
            }
            if (_cinemachineBrain.IsBlending)
            {
                return;
            }

            for (int i = 0; i < _hooks.Length; i++)
            {
                if (_hooks[i] != null)
                {
                    _hooks[i].OnCinemachineBlendComplete();
                }
            }
        }

        // RVA: 0x13D6C5C
        public CinemachineBrainEventListener()
        {
        }
    }
}
