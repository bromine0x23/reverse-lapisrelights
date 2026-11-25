// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ScenarioActors
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  按 actorId 通过 Lua 构建 ActorFactory，并维护演员列表。
// =============================================================================

using System;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;

public class ScenarioActors : Module
{
    public RuntimeAnimatorController DefaultController;
    public ActorPositions Positions;
    public List<ActorFactory> ActorFactories;
    public List<Actor> Actors;
    public Dictionary<int, AvatarFactory> AvatarFactories;

    // RVA: 0x1B792D0
    public ActorFactory NewActorFactory(ScenarioActors.actorParam param)
    {
        if (param == null)
        {
            throw new NullReferenceException();
        }

        ActorFactory factory;
        if (param.defaultAvator)
        {
            factory = (ActorFactory)Kit.Lua.Invoke<int, object>("ActorUtil.BuildActorFactory", param.actorId);
        }
        else
        {
            ToLuaModule.ToLuaAPI api;
            LuaFunction func = Kit.Lua.GetFunction("ActorUtil.BuildActorFactory", out api, null);
            if (func != null)
            {
                LuaTable table = Kit.Lua.GetEmptyTable();
                for (int i = 0; i < param.avatas.Count; i++)
                {
                    table.set_Item(i, param.avatas[i]);
                }
                factory = (ActorFactory)func.Invoke<int, object, object>(param.actorId, table);
                table.Dispose();
            }
            else
            {
                factory = null;
            }
        }

        ActorFactories.Add(factory);
        Actors.Add(factory.Product);
        return factory;
    }

    // RVA: 0x1B795A4
    public Actor GetActor(string Key)
    {
        return Actors.Find(e => e.name == Key);
    }

    // RVA: 0x1B79670
    public override void Init()
    {
        base.Init();
        Positions.Init();
    }

    // RVA: 0x1B796A8
    public override void Dispose()
    {
        ActorFactories.Clear();
        Positions.Dispose();
    }

    // RVA: 0x1B79714
    public ScenarioActors()
    {
        ActorFactories = new List<ActorFactory>();
        Actors = new List<Actor>();
        AvatarFactories = new Dictionary<int, AvatarFactory>();
    }

    [Serializable]
    public class actorParam
    {
        public int actorId;
        public bool defaultAvator;
        public List<int> avatas;
        public bool loli;

        // RVA: 0x1B7980C
        public actorParam()
        {
            avatas = new List<int>();
        }
    }
}
