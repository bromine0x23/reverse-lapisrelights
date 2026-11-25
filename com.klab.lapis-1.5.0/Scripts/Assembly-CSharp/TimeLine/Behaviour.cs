// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  TimeLine.Behaviour
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  Timeline 播放片段的通用行为基类，维护片段上下文与播放状态。
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace TimeLine
{
    public class Behaviour : PlayableBehaviour
    {
        public Behaviour.Context context;

        public virtual bool Await
        {
            // RVA: 0x144CCC0
            get { return context.clip.Await; }
        }

        public bool IsEarly
        {
            // RVA: 0x144D3EC
            get
            {
                if (context.director == null)
                {
                    return true;
                }
                return context.director.time < context.clip.clipInfo.start;
            }
        }

        public bool IsLate
        {
            // RVA: 0x144CF20
            get
            {
                if (context.director == null)
                {
                    return false;
                }
                return context.director.time > context.clip.clipInfo.end;
            }
        }

        public float Time01
        {
            // RVA: 0x144D4B4
            get
            {
                if (context == null)
                {
                    return 0f;
                }
                return (float)(context.localTime / context.clip.clipInfo.duration);
            }
        }

        // RVA: 0x144CCBC
        public virtual void SetContext(Clip clip)
        {
        }

        // RVA: 0x144CCE8
        public override void OnBehaviourPause(Playable playable, FrameData info)
        {
            if (context.state < InternalState.Play)
            {
                PauseOnStart(playable, info);
            }
            else if (context.state == InternalState.Play)
            {
                PauseOnPlaying(playable, info);
            }

            Event.Instace.OnClipPause.Dispatch(context);
            context.state = InternalState.Pause;
        }

        // RVA: 0x144CE88
        public virtual void PauseOnStart(Playable playable, FrameData info)
        {
        }

        // RVA: 0x144CE8C
        public virtual void PauseOnPlaying(Playable playable, FrameData info)
        {
            if (Await && IsLate)
            {
                Event.Instace.OnAwait.Dispatch(context);
            }
        }

        // RVA: 0x144CFF8
        public override void OnGraphStart(Playable playable)
        {
            context.state = InternalState.Start;
        }

        // RVA: 0x144D018
        public override void OnGraphStop(Playable playable)
        {
            context.state = InternalState.Stop;
        }

        // RVA: 0x144D038
        public override void OnPlayableCreate(Playable playable)
        {
            context.state = InternalState.Create;
        }

        // RVA: 0x144D054
        public override void OnPlayableDestroy(Playable playable)
        {
            context.state = InternalState.Destroy;
            if (context.clip != null)
            {
                context.clip.mixer = null;
                context.clip.clipInfo = null;
                context.clip.behaviour = null;
            }
            context = null;
        }

        // RVA: 0x144D124
        public virtual void OnSecoundFrame(Playable playable, FrameData info, object playerData)
        {
        }

        // RVA: 0x144D128
        public override void OnBehaviourPlay(Playable playable, FrameData info)
        {
            Event.Instace.OnClipPlay.Dispatch(context);
            context.state = InternalState.Play;
            context.frameCount = 0;
        }

        // RVA: 0x144D1AC
        public override void PrepareFrame(Playable playable, FrameData info)
        {
            context.frameCount++;
            context.weight = info.weight;
            if (context.frameCount == 1)
            {
                context.mixer.SetMixContext(context);
            }
            context.localTime = playable.GetTime();
        }

        // RVA: 0x144D2DC
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            context.BindObject = playerData as Object;
            if (context.frameCount == 2)
            {
                OnSecoundFrame(playable, info, playerData);
            }
        }

        // RVA: 0x144D4F8
        public virtual bool IsTimeOut()
        {
            return IsLate || IsEarly;
        }

        // RVA: 0x144D530
        public Behaviour()
        {
            context = new Context();
        }

        public enum InternalState
        {
            Create = 0,
            Start = 1,
            Play = 2,
            Pause = 3,
            Stop = 4,
            Destroy = 5,
        }

        public class Context
        {
            public InternalState state;
            public Track track;
            public Mixer mixer;
            public Clip clip;
            public Behaviour behaviour;
            public PlayableDirector director;
            public Object BindObject;
            public int frameCount;
            public float weight;
            public double localTime;

            // RVA: 0x147D2BC
            public T Clip<T>()
            {
                return (T)(object)clip;
            }

            // RVA: 0x144D598
            public Context()
            {
            }
        }
    }
}
