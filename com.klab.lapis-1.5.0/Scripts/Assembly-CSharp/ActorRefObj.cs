// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ActorRefObj
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  角色引用对象：序列化 actorParam，并在场景内按 CurrentPos 移动/隐藏角色。
// =============================================================================

using Oz.ActorModule;
using Oz.Utility;
using UnityEngine;

[DisallowMultipleComponent]
public class ActorRefObj : ReferenceObject
{
    public ScenarioActors.actorParam param;
    public string CurrentPos;
    public float MoveTime;
    private bool moving;
    private float movingClock;
    private Vector3 from;
    private Vector3 to;
    private Quaternion fromRot;
    private Quaternion toRot;
    public float Height;

    public override Color color
    {
        // RVA: 0x163A898
        get { return Color.green; }
    }

    // RVA: 0x163A8A0
    public override void SetSceneData()
    {
        base.SetSceneData();

        param = JsonUtility.FromJson<ScenarioActors.actorParam>(Data.AssetPath);
        Data.AssetPath = JsonUtility.ToJson(param);
    }

    // RVA: 0x163A924
    public override void PuToScene()
    {
        base.PuToScene();

        param = JsonUtility.FromJson<ScenarioActors.actorParam>(Data.AssetPath);
    }

    // RVA: 0x163A994
    public void MoveTo(string ToPos, float moveTime = 0.5f)
    {
        if (ToPos == CurrentPos)
        {
            return;
        }

        if (ToPos == string.Empty)
        {
            gameObject.SetActive(false);
        }
        else if (string.IsNullOrEmpty(CurrentPos))
        {
            HidePreviousActor(ToPos);
            GameObjectUtil.SetSpringPause(gameObject, true);
            gameObject.SetActive(true);

            Transform target = ReferenceRoot.Instance.Get(ToPos).transform;
            transform.position = target.position + new Vector3(0f, Height, 0f);
            transform.rotation = target.rotation;

            GameObjectUtil.SetSpringPause(gameObject, false);
            moving = false;
        }
        else
        {
            from = transform.position;
            MoveTime = moveTime;

            Transform target = ReferenceRoot.Instance.Get(ToPos).transform;
            to = target.position + new Vector3(0f, Height, 0f);
            fromRot = transform.rotation;
            toRot = target.rotation;
            movingClock = 0f;
            moving = true;
        }

        CurrentPos = ToPos;
    }

    // RVA: 0x163AD34
    private void HidePreviousActor(string ToPos)
    {
        foreach (Actor actor in ScenarioKit.Instance.Actors.Actors)
        {
            if (!actor.gameObject.activeSelf)
            {
                continue;
            }

            if (actor.GetComponent<ActorRefObj>().CurrentPos == ToPos)
            {
                actor.gameObject.SetActive(false);
            }
        }
    }

    // RVA: 0x163AEDC
    private void Update()
    {
        if (!moving)
        {
            return;
        }

        if (movingClock < MoveTime)
        {
            movingClock += Time.deltaTime;

            float t = movingClock / MoveTime + Time.deltaTime * 0.01f;

            transform.position = Vector3.LerpUnclamped(from, to, t);
            transform.rotation = Quaternion.LerpUnclamped(fromRot, toRot, t);
        }
        else
        {
            transform.position = to;
            transform.rotation = toRot;
            moving = false;
        }
    }

    // RVA: 0x163B10C
    public ActorRefObj()
    {
        MoveTime = 0.5f;
        movingClock = float.MaxValue;
    }
}
