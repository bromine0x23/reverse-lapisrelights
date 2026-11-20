// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.LipsyncAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        CreatePlayable: new LipsyncBehaviour(this) 作为 template 传入 Create(graph, template, 0)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public sealed class LipsyncAsset : PlayableAsset
    {
        [SerializeField]
        private AnimationIndex index;
        [SerializeField]
        private string originWord;
        [SerializeField]
        private int volume;
        [SerializeField]
        private float weight;
        [SerializeField]
        private LipsyncMixer <Mixer>k__BackingField;
        [SerializeField]
        private int <ClipIdx>k__BackingField;

        // RVA: 0x13DA8FC
        public AnimationIndex get_Index()
        {
            return index;
        }

        // RVA: 0x13DA904
        public float get_Weight()
        {
            return weight;
        }

        // RVA: 0x13DA90C
        public LipsyncMixer get_Mixer()
        {
            return Mixer;
        }

        // RVA: 0x13DA914
        internal void set_Mixer(LipsyncMixer value)
        {
            Mixer = value;
        }

        // RVA: 0x13DA91C
        public int get_ClipIdx()
        {
            return ClipIdx;
        }

        // RVA: 0x13DA924
        internal void set_ClipIdx(int value)
        {
            ClipIdx = value;
        }

        // RVA: 0x13DA92C
        public override Playable CreatePlayable(PlayableGraph graph, GameObject go)
        {
            LipsyncBehaviour behaviour = new LipsyncBehaviour(this);
            return ScriptPlayable<LipsyncBehaviour>.Create(graph, behaviour, 0);
        }

        // RVA: 0x13DAA14
        public void SetParameters(string word, AnimationIndex animationId, float weight, int volume)
        {
            index = animationId;
            this.weight = weight;
            originWord = word;
            this.volume = volume;
        }

        // RVA: 0x13DAA28
        public LipsyncAsset()
        {
        }
    }
}
