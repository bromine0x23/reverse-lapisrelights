// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.DialogBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        OnGraphStart 取 ScenarioUI.GetController<TimelineController>()，
//        ProcessFrame 在 context.localTime > dialog.DelayStart 时触发 OnDialogPlay
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class DialogBehaviour : ScenarioBehaviour
    {
        public bool RuntimeAwait;
        public bool video0Played;
        public bool videoPlayed;
        private bool played;
        public DialogController Controller;
        public override bool Await { get; }
        public Dialog dialogData { get; }

        // RVA: 0x13D6DE4
        public override bool get_Await()
        {
            if (ScenarioKit.Instance != null)
            {
                Dialog data = get_dialogData();
                if (data != null && data.video != null)
                {
                    return true;
                }

                DialogController controller =
                    (DialogController)ScenarioKit.Instance.UI.GetController<TimelineController>();
                if (controller != null)
                {
                    return true;
                }
            }
            return RuntimeAwait;
        }

        // RVA: 0x13D6F1C
        public Dialog get_dialogData()
        {
            if (context == null)
            {
                return null;
            }
            return context.clip as Dialog;
        }

        // RVA: 0x13D6FA8
        public override void SetContext(TimeLine.Clip clip)
        {
            RuntimeAwait = ((Dialog)clip).Await;
        }

        // RVA: 0x13D7038
        public override void OnGraphStart(Playable playable)
        {
            base.OnGraphStart(playable);

            if (ScenarioKit.Instance != null)
            {
                Controller = (DialogController)ScenarioKit.Instance.UI.GetController<TimelineController>();
            }
        }

        // RVA: 0x13D7108
        public override void OnBehaviourPlay(Playable playable, FrameData info)
        {
            base.OnBehaviourPlay(playable, info);

            if (Controller != null)
            {
                Controller.OnDialogStart(this);
            }
        }

        // RVA: 0x13D71E8
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            base.ProcessFrame(playable, info, playerData);

            if (played || context.frameCount < 2)
            {
                return;
            }

            Dialog data = get_dialogData();
            if (data != null && context.localTime > data.DelayStart)
            {
                played = true;
                if (Controller != null)
                {
                    Controller.OnDialogPlay(this);
                }
            }
        }

        // RVA: 0x13D731C
        public override void PauseOnPlaying(Playable playable, FrameData info)
        {
            base.PauseOnPlaying(playable, info);

            played = false;
            if (Controller != null)
            {
                Controller.OnDialogEnd(this);
            }
        }

        // RVA: 0x13D7400
        public DialogBehaviour()
        {
        }
    }
}
