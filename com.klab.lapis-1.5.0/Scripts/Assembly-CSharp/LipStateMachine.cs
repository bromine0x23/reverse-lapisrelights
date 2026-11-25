// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LipStateMachine
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  口型状态机：按 (当前状态, 指令) 选择随机中间状态，再回落到目标状态。
// =============================================================================

using System.Collections.Generic;
using Jigbox.Tween;
using UnityEngine;

public class LipStateMachine
{
    private static readonly float Duration = 0.1f;
    private readonly Dictionary<LipSyncTransition, List<LipState>> transitions;
    private LipSync _voice;
    private LipState _currentState;
    private float _currentLipSize;
    private TweenSingle _tween;

    public LipState CurrentState
    {
        // RVA: 0x1337CD4
        get { return _currentState; }
    }

    // RVA: 0x1337CDC
    public LipStateMachine(LipSync voice)
    {
        transitions = new Dictionary<LipSyncTransition, List<LipState>>();
        transitions.Add(new LipSyncTransition(LipState.Close, LipCommand.ToHalf), new List<LipState> { LipState.HalfOpen });
        transitions.Add(new LipSyncTransition(LipState.FullOpen, LipCommand.ToHalf), new List<LipState> { LipState.HalfOpen });
        transitions.Add(new LipSyncTransition(LipState.HalfOpen, LipCommand.ToHalf), new List<LipState> { LipState.Close });
        transitions.Add(new LipSyncTransition(LipState.Close, LipCommand.ToFull), new List<LipState> { LipState.FullOpen });
        transitions.Add(new LipSyncTransition(LipState.FullOpen, LipCommand.ToFull), new List<LipState> { LipState.HalfOpen });
        transitions.Add(new LipSyncTransition(LipState.HalfOpen, LipCommand.ToFull), new List<LipState> { LipState.FullOpen });
        transitions.Add(new LipSyncTransition(LipState.Close, LipCommand.ToClose), new List<LipState> { LipState.Close });
        transitions.Add(new LipSyncTransition(LipState.FullOpen, LipCommand.ToClose), new List<LipState> { LipState.Close });
        transitions.Add(new LipSyncTransition(LipState.HalfOpen, LipCommand.ToClose), new List<LipState> { LipState.Close });

        _currentState = LipState.Close;
        _voice = voice;
        _tween = new TweenSingle(t => { });
        _tween.Play();
    }

    // RVA: 0x13381C0
    public LipState GetMiddleState(LipCommand command)
    {
        List<LipState> list;
        if (transitions.TryGetValue(new LipSyncTransition(_currentState, command), out list))
        {
            return list[Random.Range(0, list.Count)];
        }
        return LipState.Invalid;
    }

    // RVA: 0x13382B0
    public void MoveNext(LipCommand command)
    {
        LipState middle = GetMiddleState(command);
        if (middle == LipState.Invalid)
        {
            return;
        }

        LipState final = command == LipCommand.ToFull
            ? LipState.FullOpen
            : command == LipCommand.ToHalf ? LipState.HalfOpen : LipState.Close;
        AnimateMouth(_currentState, middle, final);
    }

    // RVA: 0x1338304
    private void AnimateMouth(LipState current, LipState middle, LipState final)
    {
        if (_currentState == middle)
        {
            return;
        }

        _tween.Stop();
        _currentState = middle;
        _tween.Duration = _currentLipSize;
        _tween.Value = GetStateValue(middle);
        _currentLipSize = GetStateValue(middle);
        _tween.OnComplete(t => Fallback(middle, final));
        _tween.Play();
    }

    // RVA: 0x13384F8
    private void Fallback(LipState middle, LipState final)
    {
        if (middle == final)
        {
            return;
        }

        _tween.Stop();
        _currentState = final;
        _tween.Duration = _currentLipSize;
        _tween.Value = GetStateValue(final);
        _currentLipSize = GetStateValue(final);
        _tween.OnComplete(t => { _currentLipSize = GetStateValue(final); });
        _tween.Play();
    }

    // RVA: 0x13384B4
    private float GetStateValue(LipState state)
    {
        if (state == LipState.HalfOpen)
        {
            return _voice.LipHalfSize;
        }
        if (state == LipState.FullOpen)
        {
            return _voice.LipFullSize;
        }
        return 0f;
    }

    // RVA: 0x1338674
    public void Exit()
    {
        _tween.Stop();
        MoveNext(LipCommand.ToClose);
    }

    // RVA: 0x13386B4
    static LipStateMachine()
    {
    }
}
