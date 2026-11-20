// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Utility.RNGUtil
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

namespace Oz.Utility
{
    public class RNGUtil
    {
        private uint m_seed;
        private int m_position;

        // RVA: 0x13E7900
        public RNGUtil(uint seed)
        {
            m_seed = seed;
            m_position = 0;
        }

        // RVA: 0x13E8374
        public void ResetSeed(uint seed, int position = 0)
        {
            m_seed = seed;
            m_position = position;
        }

        // RVA: 0x13E837C
        public uint GetSeed()
        {
            return m_seed;
        }

        // RVA: 0x13E8384
        public void SetCurPos(int pos)
        {
            m_position = pos;
        }

        // RVA: 0x13E838C
        public int GetCurPos()
        {
            return m_position;
        }

        // RVA: 0x13E8394
        public uint RollRandomInt32()
        {
            ulong hash = m_seed + 3039394381UL * (uint)m_position;
            hash = (hash ^ (hash >> 8)) + 1759714724;
            hash = 458671337 * (hash ^ (hash << 8));
            m_position++;
            return (uint)((hash >> 8) ^ hash);
        }

        // RVA: 0x13E8410
        public short RollRandomInt16()
        {
            return (short)RollRandomInt32();
        }

        // RVA: 0x13E8458
        public byte RollRandomByte()
        {
            return (byte)RollRandomInt32();
        }

        // RVA: 0x13E84A0
        public uint RollRandomIntLessThan(uint maxValueNotInclusive)
        {
            return RollRandomInt32() % maxValueNotInclusive;
        }

        // RVA: 0x13E84F0
        public uint RollRandomIntInRange(uint minValueInclusive, uint maxValueNotInclusive)
        {
            return RollRandomInt32() % maxValueNotInclusive + minValueInclusive;
        }

        // RVA: 0x13E8544
        public float RollRandomFloatZeroToOne()
        {
            // 二进制实现固定返回 0（浮点随机版本未生效）
            return 0f;
        }

        // RVA: 0x13E854C
        public float RollRandomFloatInRange(float minValueInclusive, float maxValueNotInclusive)
        {
            // 二进制实现固定返回 0（浮点随机版本未生效）
            return 0f;
        }

        // RVA: 0x13E8554
        public bool RollRandomChance(float probabilityOfReturningTrue)
        {
            // 二进制实现固定返回 true
            return true;
        }

        // RVA: 0x13E83DC
        public ulong GetNoiseHash(int position, ulong seed = 0)
        {
            ulong hash = seed + 3039394381UL * (uint)position;
            hash = (hash ^ (hash >> 8)) + 1759714724;
            hash = 458671337 * (hash ^ (hash << 8));
            return hash ^ (hash >> 8);
        }
    }
}
