// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  SceneTimelineRebinder
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  时间线绑定重定向：按 Rebingding 列表把 track 绑定到场景引用解析出的对象。
// =============================================================================

using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

[ExecuteInEditMode]
[RequireComponent(typeof(PlayableDirector))]
public class SceneTimelineRebinder : MonoBehaviour
{
    [SerializeField]
    public List<SceneTimelineRebinder.Rebingding> rebinding;
    [SerializeField]
    public bool PlayAfterBind;
    private PlayableDirector _playableDirector;

    public PlayableDirector Director
    {
        // RVA: 0x19419A0
        get
        {
            if (_playableDirector)
            {
                return _playableDirector;
            }

            _playableDirector = GetComponent<PlayableDirector>();
            return _playableDirector;
        }
    }

    // RVA: 0x194BD30
    private void Start()
    {
        if (!Application.isPlaying)
        {
            Rebind();
        }
    }

    // RVA: 0x194BD68
    public void ReKey()
    {
        List<SceneTimelineRebinder.Rebingding> list =
            new List<SceneTimelineRebinder.Rebingding>();

        foreach (PlayableBinding item in Director.playableAsset.outputs)
        {
            if (item.sourceObject == null)
            {
                continue;
            }

            SceneTimelineRebinder.Rebingding entry = rebinding.Find(
                e => e.Key != null && e.Key.name == item.sourceObject.name);

            if (entry == null)
            {
                entry = new SceneTimelineRebinder.Rebingding();
            }

            entry.Key = item.sourceObject;
            list.Add(entry);
        }

        rebinding = list;
    }

    // RVA: 0x19417EC
    public void Rebind()
    {
        foreach (SceneTimelineRebinder.Rebingding item in rebinding)
        {
            if (item.Value == null)
            {
                continue;
            }

            UnityEngine.Object resolve = item.Value.Resolve();
            if (resolve)
            {
                Director.SetGenericBinding(item.Key, resolve);
            }
        }

        if (PlayAfterBind && Application.isPlaying)
        {
            Director.Play();
        }
    }

    // RVA: 0x194C1D0
    public void RebindManually(string trackName, UnityEngine.Object bindObj)
    {
        SceneTimelineRebinder.Rebingding entry = rebinding.Find(
            e => e.Key != null && e.Key.name == trackName);

        Director.SetGenericBinding(entry.Key, bindObj);
    }

    // RVA: 0x194C2CC
    private void OnDestroy()
    {
        rebinding.Clear();
    }

    // RVA: 0x194C324
    public SceneTimelineRebinder()
    {
        rebinding = new List<SceneTimelineRebinder.Rebingding>();
    }

    [Serializable]
    public class Rebingding
    {
        public UnityEngine.Object Key;
        public SceneReference Value;

        // RVA: 0x194C1C8
        public Rebingding()
        {
        }
    }
}
