// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  TimeLine.Mixer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  混合两个相邻片段上下文，并按输入数量分发到 ProcessZero/One/Two。
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace TimeLine
{
    public class Mixer : Behaviour
    {
        public Behaviour.Context clipA;
        public Behaviour.Context clipB;
        public int lastInputCount;

        // RVA: 0x144DBF4
        public override void PrepareFrame(Playable playable, FrameData info)
        {
            if (clipA != null && clipA.behaviour.IsTimeOut())
            {
                clipA = null;
            }
            if (clipB != null && clipB.behaviour.IsTimeOut())
            {
                clipB = null;
            }
            if (clipA == null && clipB != null)
            {
                clipA = clipB;
                clipB = null;
            }
        }

        // RVA: 0x144DC8C
        public override bool IsTimeOut()
        {
            return false;
        }

        // RVA: 0x144DC94
        public override void OnBehaviourPause(Playable playable, FrameData info)
        {
            context.state = InternalState.Pause;
        }

        // RVA: 0x144DCB4
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            context.BindObject = playerData as Object;

            if (clipA != null)
            {
                if (clipB != null)
                {
                    if (lastInputCount != 2)
                    {
                        InputChanged(lastInputCount, 2);
                    }
                    ProcessTwo(playable, info, playerData);
                    lastInputCount = 2;
                }
                else
                {
                    if (lastInputCount != 1)
                    {
                        InputChanged(lastInputCount, 1);
                    }
                    ProcessOne(playable, info, playerData);
                    lastInputCount = 1;
                }
            }
            else
            {
                if (lastInputCount != 0)
                {
                    InputChanged(lastInputCount, 0);
                }
                ProcessZero(playable, info, playerData);
                lastInputCount = 0;
            }
        }

        // RVA: 0x144DECC
        public virtual void ProcessZero(Playable playable, FrameData info, object playerData)
        {
        }

        // RVA: 0x144DED0
        public virtual void ProcessOne(Playable playable, FrameData info, object playerData)
        {
        }

        // RVA: 0x144DED4
        public virtual void ProcessTwo(Playable playable, FrameData info, object playerData)
        {
        }

        // RVA: 0x144DED8
        public override void OnPlayableDestroy(Playable playable)
        {
            base.OnPlayableDestroy(playable);
            clipA = null;
            clipB = null;
        }

        // RVA: 0x144DEFC
        public virtual void InputChanged(int from, int to)
        {
        }

        // RVA: 0x144D298
        public void SetMixContext(Behaviour.Context context)
        {
            if (clipA == null)
            {
                clipA = context;
                if (context == null)
                {
                    return;
                }
            }
            else if (clipB == null)
            {
                clipB = context;
            }

            if (clipB == context || clipA == context || clipB == null)
            {
                return;
            }

            clipA = clipB;
            clipB = context;
        }

        // RVA: 0x144DF00
        public Behaviour.Context MaxWeight()
        {
            if (clipA == null)
            {
                return clipB;
            }
            if (clipB == null)
            {
                return clipA;
            }
            return clipA.weight <= clipB.weight ? clipB : clipA;
        }

        // RVA: 0x144DF2C
        public Mixer()
        {
        }
    }
}
