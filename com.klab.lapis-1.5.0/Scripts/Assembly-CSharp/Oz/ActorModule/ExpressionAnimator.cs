// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.ExpressionAnimator
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
    public class ExpressionAnimator : MonoBehaviour
    {
        private const string eyebrowPrefix = "brow";
        private const string mouthPrefix = "mouth";
        private const string eyePrefix = "eye";
        private const int ShapeIndexL = 0;
        private const int ShapeIndexR = 1;
        private const int ShapeIndexC = 2;
        [SerializeField]
        private float m_EyeBlinkRate;
        [SerializeField]
        private float m_TimeRemaining;
        [SerializeField]
        private float m_TimeInterval;
        private Coroutine blinkRoutine;
        [SerializeField]
        private FacialSettings m_FacialSettings;
        [SerializeField]
        private VowelSetting m_VowelSetting;
        [SerializeField]
        private EyeDirection m_EyeDirection;
        [SerializeField]
        private SkinnedMeshRenderer m_BrowSMR;
        [SerializeField]
        private SkinnedMeshRenderer m_FaceSMR;
        [SerializeField]
        private IntFaceStateDictionary m_ExpressionState;
        [SerializeField]
        private BlendWeight[] m_BrowList;
        [SerializeField]
        private BlendWeight[] m_EyeList;
        [SerializeField]
        private BlendWeight[] m_MouthList;
        [SerializeField]
        private float m_CheekPower;
        [SerializeField]
        private float m_ForeheadShade;
        [SerializeField]
        private float m_EyeHighlight;
        [SerializeField]
        private float m_EyeScale;
        [SerializeField]
        private eFaceExpression m_NowExpression;
        [SerializeField]
        private bool m_NowMouthOpen;
        private FaceTransition m_Transition;
        [field: SerializeField]
        public bool IsBlinkActive { get; private set; }
        public bool IsBlinkAnimating { get; }
        public VoiceVowel Voice { get; private set; }
        public LipSync LipSyncVoice { get; private set; }
        public MaterialPropertyBlock MaterialPropertyBlock { get; private set; }

        // RVA: 0x16B0DBC
        public bool get_IsBlinkAnimating()
        {
            return m_TimeRemaining > 0f;
        }

        // RVA: 0x16B0DDC
        public LipSync get_LipSyncVoice()
        {
            if (LipSyncVoice == null && m_FaceSMR != null)
            {
                LipSyncVoice = new LipSync(m_FaceSMR);
            }
            return LipSyncVoice;
        }

        // RVA: 0x16B0E98
        public MaterialPropertyBlock get_MaterialPropertyBlock()
        {
            if (MaterialPropertyBlock == null)
            {
                MaterialPropertyBlock = new MaterialPropertyBlock();
            }
            return MaterialPropertyBlock;
        }

        // RVA: 0x16B0F04
        public void Init(AvatarSystem avatarSystem, FacialSettings facialSettings, VowelSetting vowelSetting, EyeDirection eyeDirection)
        {
            m_FacialSettings = facialSettings;
            m_VowelSetting = vowelSetting;
            m_EyeDirection = eyeDirection;
            m_ExpressionState = new IntFaceStateDictionary();
            m_Transition = null;
            m_CheekPower = 0f;
            m_ForeheadShade = 0f;
            m_EyeHighlight = 0f;
            m_EyeScale = 0f;

            AvatarPart part = avatarSystem.GetAvatarPart(4);
            if (part == null)
            {
                return;
            }

            m_BrowSMR = part.FindRenderer(t => t.name.ToUpper().Contains("BROW_GEO")) as SkinnedMeshRenderer;
            m_FaceSMR = part.FindRenderer(t => t.name.ToUpper().Contains("FACE_GEO")) as SkinnedMeshRenderer;

            if (m_FaceSMR != null)
            {
                LipSyncVoice = new LipSync(m_FaceSMR);
            }
        }

        // RVA: 0x16B11BC
        public void Init(FacialSettings facialSettings, VowelSetting vowelSetting)
        {
            m_FacialSettings = facialSettings;
            m_VowelSetting = vowelSetting;
            m_ExpressionState = new IntFaceStateDictionary();
            m_CheekPower = 0f;
            m_ForeheadShade = 0f;
            m_EyeHighlight = 0f;
            m_EyeScale = 0f;

            Transform brow = TransformExtentions.RecursiveFind(transform, t => t.name.ToUpper().Contains("BROW_GEO"));
            if (brow != null)
            {
                m_BrowSMR = brow.GetComponent<SkinnedMeshRenderer>();
            }

            Transform face = TransformExtentions.RecursiveFind(transform, t => t.name.ToUpper().Contains("FACE_GEO"));
            if (face != null)
            {
                m_FaceSMR = face.GetComponent<SkinnedMeshRenderer>();
                if (m_FaceSMR != null)
                {
                    LipSyncVoice = new LipSync(m_FaceSMR);
                }
            }
        }

        // RVA: 0x16B14A8
        private void OnDestroy()
        {
        }

        // RVA: 0x16B14AC
        private void Start()
        {
            BlendShapeHandle[] browHandles = new BlendShapeHandle[0];
            BlendShapeHandle[] eyeHandles = new BlendShapeHandle[0];
            BlendShapeHandle[] mouthHandles = new BlendShapeHandle[0];

            if (m_BrowSMR != null)
            {
                browHandles = InitShapeList(m_BrowSMR, "brow");
                mouthHandles = InitShapeList(m_FaceSMR, "mouth");
                eyeHandles = InitShapeList(m_FaceSMR, "eye");
            }

            if (m_FacialSettings != null)
            {
                for (int i = 0; i < m_FacialSettings.FacialData.Count; i++)
                {
                    FacialData data = m_FacialSettings.FacialData[i];
                    FaceState state = new FaceState();
                    state.Expression = data.Expression;
                    state.BrowBlend = new BlendParts(eFacialParts.BROW, browHandles);
                    state.EyeBlend = new BlendParts(eFacialParts.EYE, eyeHandles);
                    state.MouthBlendOpen = new BlendParts(eFacialParts.MOUTH_OPEN, mouthHandles);
                    state.MouthBlendHalfClose = new BlendParts(eFacialParts.MOUTH_HALFCLOSE, mouthHandles);
                    state.MouthBlendClose = new BlendParts(eFacialParts.MOUTH_CLOSE, mouthHandles);
                    state.CheekPower = data.CheekPower;
                    state.AutoBlink = data.Blink;
                    state.ForeheadShade = data.ForeheadShade;
                    state.EyeHighlight = data.EyeHighlight;
                    state.EyeScale = data.EyeScale;

                    for (int j = 0; j < data.BlendData.Count; j++)
                    {
                        BlendData blend = data.BlendData[j];
                        switch (blend.Parts)
                        {
                            case eFacialParts.BROW:
                                state.BrowBlend.SetShapeWeight(blend.ShapeId, blend.BlendValue);
                                break;
                            case eFacialParts.EYE:
                                state.EyeBlend.SetShapeWeight(blend.ShapeId, blend.BlendValue);
                                break;
                            case eFacialParts.MOUTH_OPEN:
                                state.MouthBlendOpen.SetShapeWeight(blend.ShapeId, blend.BlendValue);
                                break;
                            case eFacialParts.MOUTH_HALFCLOSE:
                                state.MouthBlendHalfClose.SetShapeWeight(blend.ShapeId, blend.BlendValue);
                                break;
                            case eFacialParts.MOUTH_CLOSE:
                                state.MouthBlendClose.SetShapeWeight(blend.ShapeId, blend.BlendValue);
                                break;
                        }
                    }

                    m_ExpressionState[state.Expression] = state;
                }
            }

            InitParam(browHandles, eyeHandles, mouthHandles);

            if (m_NowExpression == (int)eFaceExpression.UNKNOWN)
            {
                m_NowExpression = (int)eFaceExpression.USUALLY;
            }
            SetExpression(m_NowExpression, m_NowMouthOpen);
            IsBlinkActive = true;

            if (m_VowelSetting != null && m_FaceSMR != null)
            {
                Voice = new VoiceVowel(m_FaceSMR, mouthHandles, m_VowelSetting);
            }
        }

        // RVA: 0x16B1F24
        private void Update()
        {
            if (m_Transition != null)
            {
                m_Transition.UpdateWeight();
                m_Transition.SetBlendWeight(m_BrowList, m_EyeList, m_MouthList);
                m_Transition.SetCheekPower(ref m_CheekPower);
                m_Transition.SetForeheadShade(ref m_ForeheadShade);
                m_Transition.SetEyeHighlight(ref m_EyeHighlight);
                m_Transition.SetEyeScale(ref m_EyeScale);

                if (m_Transition.isDone)
                {
                    m_Transition = null;
                }
            }

            UpdateBlink();
        }

        // RVA: 0x16B213C
        private void LateUpdate()
        {
            ApplyChanges();

            LipSync lipSync = LipSyncVoice;
            if (lipSync != null)
            {
                lipSync.OnUpdate();
            }

            if (Voice != null)
            {
                Voice.OnVoiceUpdate(m_MouthList);
            }
        }

        // RVA: 0x16B191C
        private BlendShapeHandle[] InitShapeList(SkinnedMeshRenderer mesh, string name)
        {
            List<BlendShapeHandle> list = new List<BlendShapeHandle>();
            if (mesh == null || mesh.sharedMesh == null)
            {
                return list.ToArray();
            }

            string prefix = "." + name;
            string prefixUnder = "." + name + "_";

            for (int i = 0; i < mesh.sharedMesh.blendShapeCount; i++)
            {
                string shapeName = mesh.sharedMesh.GetBlendShapeName(i);
                string key = null;
                if (shapeName.Contains(prefixUnder))
                {
                    key = prefixUnder;
                }
                else if (shapeName.Contains(prefix))
                {
                    key = prefix;
                }

                if (key == null)
                {
                    continue;
                }

                string suffix = shapeName.Substring(shapeName.IndexOf(key) + key.Length, 1);
                list.Add(new BlendShapeHandle(suffix, i));
            }
            return list.ToArray();
        }

        // RVA: 0x16B1B58
        public void InitParam(BlendShapeHandle[] browList, BlendShapeHandle[] eyeList, BlendShapeHandle[] mouthList)
        {
            if (browList != null)
            {
                m_BrowList = new BlendWeight[browList.Length];
                for (int i = 0; i < m_BrowList.Length; i++)
                {
                    m_BrowList[i] = new BlendWeight(browList[i], 0f);
                }
            }

            if (eyeList != null)
            {
                m_EyeList = new BlendWeight[eyeList.Length];
                for (int i = 0; i < m_EyeList.Length; i++)
                {
                    m_EyeList[i] = new BlendWeight(eyeList[i], 0f);
                }
            }

            if (mouthList != null)
            {
                m_MouthList = new BlendWeight[mouthList.Length];
                for (int i = 0; i < m_MouthList.Length; i++)
                {
                    m_MouthList[i] = new BlendWeight(mouthList[i], 0f);
                }
            }
        }

        // RVA: 0x16B21E4
        public void ClearChanges()
        {
            ClearBlendWeight(m_BrowList);
            ClearBlendWeight(m_EyeList);
            ClearBlendWeight(m_MouthList);
            m_CheekPower = 0f;
            m_ForeheadShade = 0f;
            m_EyeHighlight = 0f;
            m_EyeScale = 0f;
        }

        // RVA: 0x16B221C
        public void ClearBlendWeight(BlendWeight[] targetList)
        {
            if (targetList == null)
            {
                return;
            }
            for (int i = 0; i < targetList.Length; i++)
            {
                targetList[i].Weight = 0f;
            }
        }

        // RVA: 0x16B2278
        public void ClearCheekPower()
        {
            m_CheekPower = 0f;
        }

        // RVA: 0x16B2280
        public void ClearForeheadShade()
        {
            m_ForeheadShade = 0f;
        }

        // RVA: 0x16B2288
        public void ClearEyeHighlight()
        {
            m_EyeHighlight = 0f;
        }

        // RVA: 0x16B2290
        public void ClearEyeScale()
        {
            m_EyeScale = 0f;
        }

        // RVA: 0x16B2298
        public void MixExpression(int expression, bool mouthOpen, float weight)
        {
            FaceState state = null;
            if (m_ExpressionState == null || !m_ExpressionState.TryGetValue(expression, out state))
            {
                return;
            }

            MixBlendWeight(m_BrowList, state.BrowBlend.BlendWeightList, weight);
            MixBlendWeight(m_EyeList, state.EyeBlend.BlendWeightList, weight);
            MixBlendWeight(m_MouthList, mouthOpen
                ? state.MouthBlendOpen.BlendWeightList
                : state.MouthBlendClose.BlendWeightList,
                weight);

            m_CheekPower += state.CheekPower * weight;
            m_ForeheadShade += state.ForeheadShade * weight;
            m_EyeHighlight += state.EyeHighlight * weight;
            m_EyeScale += state.EyeScale * weight;
        }

        // RVA: 0x16B23E0
        public void MixBlendWeight(BlendWeight[] targetList, BlendWeight[] blendList, float weight)
        {
            if (targetList == null || blendList == null)
            {
                return;
            }
            for (int i = 0; i < targetList.Length; i++)
            {
                targetList[i].Weight = targetList[i].Weight + blendList[i].Weight * weight;
            }
        }

        // RVA: 0x16B2468
        public void MixCheekPower(float cheekPower, float weight)
        {
            m_CheekPower = cheekPower * weight + m_CheekPower;
        }

        // RVA: 0x16B247C
        public void MixForeheadShade(float foreheadShade, float weight)
        {
            m_ForeheadShade = foreheadShade * weight + m_ForeheadShade;
        }

        // RVA: 0x16B2490
        public void MixEyeHighlight(float highlight, float weight)
        {
            m_EyeHighlight = highlight * weight + m_EyeHighlight;
        }

        // RVA: 0x16B24A4
        public void MixEyeScale(float eyeScale, float weight)
        {
            m_EyeScale = eyeScale * weight + m_EyeScale;
        }

        // RVA: 0x16B24B8
        public void SetExpressionMouth(int expression, bool mouthOpen)
        {
            FaceState state = null;
            if (m_ExpressionState == null || !m_ExpressionState.TryGetValue(expression, out state))
            {
                return;
            }

            if (LipSyncVoice != null)
            {
                LipSyncVoice.SetBlendShapeList(
                    state.MouthBlendOpen.BlendWeightList,
                    state.MouthBlendHalfClose.BlendWeightList,
                    state.MouthBlendClose.BlendWeightList);
            }
        }

        // RVA: 0x16B1DC8
        public void SetExpression(int expression, bool mouthOpen)
        {
            FaceState state = null;
            if (m_ExpressionState == null || !m_ExpressionState.TryGetValue(expression, out state))
            {
                return;
            }

            SetBlendWeight(m_BrowList, state.BrowBlend.BlendWeightList);
            SetBlendWeight(m_EyeList, state.EyeBlend.BlendWeightList);
            SetBlendWeight(m_MouthList, mouthOpen
                ? state.MouthBlendOpen.BlendWeightList
                : state.MouthBlendClose.BlendWeightList);

            m_CheekPower = state.CheekPower;
            m_ForeheadShade = state.ForeheadShade;
            m_EyeHighlight = state.EyeHighlight;
            m_EyeScale = state.EyeScale;

            if (LipSyncVoice != null)
            {
                LipSyncVoice.SetBlendShapeList(
                    state.MouthBlendOpen.BlendWeightList,
                    state.MouthBlendHalfClose.BlendWeightList,
                    state.MouthBlendClose.BlendWeightList);
            }
        }

        // RVA: 0x16B257C
        public void SetBlendWeight(BlendWeight[] targetList, BlendWeight[] blendList)
        {
            if (targetList == null || blendList == null)
            {
                return;
            }
            for (int i = 0; i < targetList.Length; i++)
            {
                targetList[i].Weight = blendList[i].Weight;
            }
        }

        // RVA: 0x16B25F8
        public void SetCheekPower(float cheekPower)
        {
            m_CheekPower = cheekPower;
        }

        // RVA: 0x16B2600
        public void SetForeheadShade(float foreheadShade)
        {
            m_ForeheadShade = foreheadShade;
        }

        // RVA: 0x16B2608
        public void SetEyeHighlight(float highlight)
        {
            m_EyeHighlight = highlight;
        }

        // RVA: 0x16B2610
        public void SetEyeScale(float scale)
        {
            m_EyeScale = scale;
        }

        // RVA: 0x16B219C
        public void ApplyChanges()
        {
            ApplyBlendWeight(m_BrowList, m_EyeList, m_MouthList);
            ApplyFaceMaterial(m_CheekPower, m_ForeheadShade);
            ApplyEyeHighlight(m_EyeHighlight);
            ApplyEyeScale(m_EyeScale);
        }

        // RVA: 0x16B2618
        public void ApplyBlendWeight(BlendWeight[] browList, BlendWeight[] eyeList, BlendWeight[] mouthList)
        {
            if (browList != null && m_BrowSMR != null)
            {
                for (int i = 0; i < browList.Length; i++)
                {
                    m_BrowSMR.SetBlendShapeWeight(browList[i].Handle.ShapeIndex, browList[i].Weight);
                }
            }

            if (eyeList != null && m_FaceSMR != null)
            {
                for (int i = 0; i < eyeList.Length; i++)
                {
                    int shapeIndex = eyeList[i].Handle.ShapeIndex;
                    float from = shapeIndex > 1 ? 0f : 100f;
                    m_FaceSMR.SetBlendShapeWeight(shapeIndex, Mathf.Lerp(from, eyeList[i].Weight, m_EyeBlinkRate));
                }
            }

            if (mouthList != null && m_FaceSMR != null)
            {
                for (int i = 0; i < mouthList.Length; i++)
                {
                    m_FaceSMR.SetBlendShapeWeight(mouthList[i].Handle.ShapeIndex, mouthList[i].Weight);
                }
            }
        }

        // RVA: 0x16B28B4
        public void ApplyFaceMaterial(float cheekPower, float foreheadShade)
        {
            if (m_FaceSMR == null)
            {
                return;
            }
            m_FaceSMR.GetPropertyBlock(MaterialPropertyBlock);
            MaterialPropertyBlock.SetFloat("_CheekPower", cheekPower);
            MaterialPropertyBlock.SetFloat("_ForeheadShade", foreheadShade);
            m_FaceSMR.SetPropertyBlock(MaterialPropertyBlock);
        }

        // RVA: 0x16B29D4
        public void ApplyEyeHighlight(float highlight)
        {
            if (m_EyeDirection != null)
            {
                m_EyeDirection.SetHighlight(highlight);
            }
        }

        // RVA: 0x16B2A7C
        public void ApplyEyeScale(float scale)
        {
            if (m_EyeDirection != null)
            {
                m_EyeDirection.SetEyeScale(scale);
            }
        }

        // RVA: 0x16B2B24
        public void Play(eFaceExpression expression, bool mouthOpen)
        {
            FaceState state = null;
            if (m_ExpressionState == null || !m_ExpressionState.TryGetValue(expression, out state))
            {
                return;
            }

            SetExpression(expression, mouthOpen);

            if (IsBlinkActive && state.AutoBlink && m_NowExpression != expression && m_FacialSettings != null)
            {
                m_TimeRemaining = m_FacialSettings.BlinkDuration;
            }

            m_NowExpression = expression;
            m_NowMouthOpen = mouthOpen;
            IsBlinkActive = state.AutoBlink;
        }

        // RVA: 0x16B2C34
        public void CrossFade(eFaceExpression expression, bool mouthOpen, float duration)
        {
            FaceState state = null;
            if (m_ExpressionState == null || !m_ExpressionState.TryGetValue(expression, out state))
            {
                return;
            }

            m_NowExpression = expression;
            m_NowMouthOpen = mouthOpen;

            m_Transition = new FaceTransition(
                duration,
                m_BrowList, m_EyeList, m_MouthList,
                m_CheekPower, m_ForeheadShade, m_EyeHighlight, m_EyeScale,
                state.BrowBlend.BlendWeightList,
                state.EyeBlend.BlendWeightList,
                mouthOpen ? state.MouthBlendOpen.BlendWeightList : state.MouthBlendClose.BlendWeightList,
                state.CheekPower, state.ForeheadShade, state.EyeHighlight, state.EyeScale);

            if (LipSyncVoice != null)
            {
                LipSyncVoice.SetBlendShapeList(
                    state.MouthBlendOpen.BlendWeightList,
                    state.MouthBlendHalfClose.BlendWeightList,
                    state.MouthBlendClose.BlendWeightList);
            }
        }

        // RVA: 0x16B2C08
        public void ForceBlink()
        {
            m_TimeRemaining = m_FacialSettings.BlinkDuration;
        }

        // RVA: 0x16B2C28
        public void SetAutoBlink(bool flag)
        {
            IsBlinkActive = flag;
        }

        // RVA: 0x16B2E44
        public void SetBlinkRatio(float ratio)
        {
            m_EyeBlinkRate = ratio;
        }

        // RVA: 0x16B1FD8
        private void UpdateBlink()
        {
            if (m_FacialSettings != null && IsBlinkActive)
            {
                m_TimeInterval -= Time.deltaTime;
                if (m_TimeInterval <= 0f)
                {
                    m_TimeInterval = m_FacialSettings.BlinkInterval;
                    if (Random.Range(0f, 1f) > m_FacialSettings.BlinkThreshold)
                    {
                        m_TimeRemaining = m_FacialSettings.BlinkDuration;
                    }
                }
            }

            if (m_TimeRemaining <= 0f)
            {
                return;
            }

            m_TimeRemaining -= Time.deltaTime;
            float ratio = Mathf.Clamp(m_TimeRemaining / m_FacialSettings.BlinkDuration, 0f, 1f);
            m_EyeBlinkRate = m_FacialSettings.BlinkCurve.Evaluate(1f - ratio);
        }

        // RVA: 0x16B2E4C
        private void OnAnimationEvent(Object data)
        {
            ExpressionEventData eventData = data as ExpressionEventData;
            if (eventData == null)
            {
                return;
            }

            if (eventData.transitionDuration <= 0f)
            {
                Play(eventData.expression, eventData.mouthOpen);
            }
            else
            {
                CrossFade(eventData.expression, eventData.mouthOpen, eventData.transitionDuration);
            }
        }

        // RVA: 0x16B2F60
        public ExpressionAnimator()
        {
            m_EyeBlinkRate = 1f;
            m_NowExpression = (int)eFaceExpression.UNKNOWN;
        }
    }
}
