// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.SoundPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        OnGraphStart: bankName 非空时 SoundManager.LoadBank(bankName, false, false)
//        OnGraphStop : ExecuteActionOnEvent(eventName, 0) + UnloadBank(bankName)
//        ProcessFrame: eventName 变化时 SoundManager.PostEvent(eventName, Launcher.Instance 的 GameObject)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using Oz.Framework.SoundModule;

namespace Oz.Timeline
{
    public class SoundPlayableBehaviour : PlayableBehaviour
    {
        public string lastEventName;
        public string eventName;
        public string bankName;
        public GameObject go;

        // RVA: 0x13DC1C8
        public ClipCaps get_clipCaps()
        {
            return ClipCaps.Looping | ClipCaps.Holding | ClipCaps.Extrapolation | ClipCaps.SpeedMultiplier;
        }

        // RVA: 0x13DC1D0
        public override void OnGraphStop(Playable playable)
        {
            base.OnGraphStop(playable);

            if (!string.IsNullOrEmpty(bankName))
            {
                SoundManager.ExecuteActionOnEvent(eventName, 0);
                SoundManager.UnloadBank(bankName);
            }
            lastEventName = string.Empty;
        }

        // RVA: 0x13DC278
        public override void OnGraphStart(Playable playable)
        {
            base.OnGraphStart(playable);

            if (!string.IsNullOrEmpty(bankName))
            {
                SoundManager.LoadBank(bankName, false, false);
            }
        }

        // RVA: 0x13DC2C8
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            if (string.IsNullOrEmpty(eventName) || lastEventName == eventName)
            {
                return;
            }

            lastEventName = eventName;

            GameObject eventObject = null;
            if (Launcher.Instance != null)
            {
                eventObject = Launcher.Instance.gameObject;
            }
            SoundManager.PostEvent(eventName, eventObject);
        }

        // RVA: 0x13DC46C
        public SoundPlayableBehaviour()
        {
        }
    }
}
