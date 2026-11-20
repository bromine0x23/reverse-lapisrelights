// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.IKParam
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Oz.ActorModule
{
    public struct IKParam
    {
        public AvatarIKGoal goal;
        public Vector3 position;
        public float positionWeight;
        public Quaternion rotation;
        public float rotationWeight;

        // RVA: 0x13F1520
        public IKParam(AvatarIKGoal goal, Vector3 position, float positionWeight, Quaternion rotation, float rotationWeight)
        {
            this.goal = goal;
            this.position = position;
            this.positionWeight = positionWeight;
            this.rotation = rotation;
            this.rotationWeight = rotationWeight;
        }
    }
}
