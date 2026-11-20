// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.Dialog
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Video;

namespace Oz.Timeline
{
    /// <summary>对话片段数据与 Playable 创建。</summary>
    public class Dialog : Clip
    {
        public bool IgnoreSkip;
        public int ActorId;
        public string NameKey;
        public string Textkey;
        public string PlayVoice;
        public string StrHeadIcon;
        public Color Txtcolor;
        public VideoClip video0;
        public VideoClip video;
        public flag Flag;
        public float DelayStart;
        public string CallStart;
        public string CallEnd;

        // RVA: 0x13D6C64
        public override Playable CreatePlayable(PlayableGraph graph, GameObject go)
        {
            ScriptPlayable<DialogBehaviour> playable = ScriptPlayable<DialogBehaviour>.Create(graph, 0);
            DialogBehaviour behaviour = playable.GetBehaviour();
            SetContext(behaviour);
            return playable;
        }

        // RVA: 0x13D6D40
        public Dialog()
        {
            ActorId = -1;
            NameKey = string.Empty;
            Textkey = string.Empty;
            PlayVoice = string.Empty;
            StrHeadIcon = string.Empty;
            Txtcolor = Color.black;
        }
    }
}
