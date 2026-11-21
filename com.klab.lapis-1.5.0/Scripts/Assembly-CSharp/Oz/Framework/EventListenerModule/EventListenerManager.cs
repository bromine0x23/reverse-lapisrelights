// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.EventListenerModule.EventListenerManager
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using Oz.GameFramework.Runtime;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Oz.Framework.EventListenerModule
{
    public class EventListenerManager : MonoBehaviour
    {

        // RVA: 0x13FCCA4
        public static void AddUIListener(GameObject go, LuaFunction luafunc, LuaTable luaObject, int type)
        {
            if (go == null || luafunc == null)
            {
                luafunc?.Dispose();
                luaObject?.Dispose();
                return;
            }

            Oz.Framework.EventTrigger trigger = UIEventTriggerHelper.AddMissingTrigger(go, type);
            LuaUIEvent uiEvent = new LuaUIEvent();
            uiEvent.luaFunc = luafunc;
            uiEvent.luaObject = luaObject;
            trigger.Add(uiEvent);
        }

        // RVA: 0x13FCEB0
        public static void RemoveUIListener(GameObject go, LuaFunction luafunc, LuaTable luaObject, int type)
        {
            if (go == null || luafunc == null)
            {
                luafunc?.Dispose();
                luaObject?.Dispose();
                return;
            }

            Oz.Framework.EventTrigger trigger = UIEventTriggerHelper.GetTrigger(go, type);
            if (trigger != null)
            {
                trigger.RemoveAll(e =>
                {
                    if (e is LuaUIEvent luaEvent
                        && luaEvent.luaFunc == luafunc
                        && luaEvent.luaObject == luaObject)
                    {
                        luaEvent.luaFunc.Dispose();
                        luaEvent.luaObject.Dispose();
                        return true;
                    }
                    return false;
                });
            }
        }

        // RVA: 0x13FD0F4
        public static void AddUIListener(GameObject go, UnityAction<BaseEventData> callback, UIEventID type)
        {
            if (callback == null || go == null)
            {
                return;
            }

            Oz.Framework.EventTrigger trigger = UIEventTriggerHelper.AddMissingTrigger(go, (int)type);
            ActionUIEvent uiEvent = new ActionUIEvent();
            uiEvent.callback = callback;
            trigger.Add(uiEvent);
        }

        // RVA: 0x13FD1D4
        public static void RemoveUIListener(GameObject go, UnityAction<BaseEventData> callback, UIEventID type)
        {
            if (callback == null || go == null)
            {
                return;
            }

            Oz.Framework.EventTrigger trigger = UIEventTriggerHelper.GetTrigger(go, (int)type);
            if (trigger != null)
            {
                trigger.RemoveAll(e => e is ActionUIEvent actionEvent && actionEvent.callback == callback);
            }
        }

        // RVA: 0x13FD324
        public static void AddToggleListener(GameObject go, LuaFunction luafunc, LuaTable luaObject)
        {
            if (go == null || luafunc == null)
            {
                luafunc?.Dispose();
                luaObject?.Dispose();
                return;
            }

            go.AddMissingComponent<ToggleListener>().RegisterTriggerLua(luaObject, luafunc);
        }

        // RVA: 0x13FD450
        public static void RemoveToggleListener(GameObject go, LuaFunction luafunc, LuaTable luaObject)
        {
            if (go == null || luafunc == null)
            {
                luafunc?.Dispose();
                luaObject?.Dispose();
                return;
            }

            ToggleListener listener = go.GetComponent<ToggleListener>();
            if (listener != null)
            {
                listener.UnregisterTriggerLua(luaObject, luafunc);
            }
            else
            {
                luafunc.Dispose();
                luaObject?.Dispose();
            }
        }

        // RVA: 0x13FD5D4
        public static void AddToggleListener(GameObject go, UnityAction<bool> callback)
        {
            if (callback != null && go != null)
            {
                go.AddMissingComponent<ToggleListener>().RegisterTrigger(callback);
            }
        }

        // RVA: 0x13FD68C
        public static void RemoveToggleListener(GameObject go, UnityAction<bool> callback)
        {
            if (callback != null && go != null)
            {
                ToggleListener listener = go.GetComponent<ToggleListener>();
                if (listener != null)
                {
                    listener.UnregisterTrigger(callback);
                }
            }
        }

        // RVA: 0x13FD780
        public static bool ExecuteEvents(GameObject g, BaseEventData eventData, int type)
        {
            if (type == 4)
            {
                return UnityEngine.EventSystems.ExecuteEvents.Execute(
                    g, eventData, UnityEngine.EventSystems.ExecuteEvents.pointerClickHandler);
            }

            return UnityEngine.EventSystems.ExecuteEvents.Execute(
                g, eventData, UnityEngine.EventSystems.ExecuteEvents.pointerDownHandler);
        }

        // RVA: 0x13FD8BC
        public static void AddAnimListener(GameObject go, LuaFunction luafunc, LuaTable luaObject, int type)
        {
            if (go == null || luafunc == null)
            {
                luafunc?.Dispose();
                luaObject?.Dispose();
                return;
            }

            go.AddMissingComponent<AnimationEventListener>()
                .RegisterTriggerLua((eAnimEventType)type, luaObject, luafunc);
        }

        // RVA: 0x13FD9FC
        public static void RemoveAnimListener(GameObject go, LuaFunction luafunc, LuaTable luaObject, int type)
        {
            if (go == null || luafunc == null)
            {
                luafunc?.Dispose();
                luaObject?.Dispose();
                return;
            }

            AnimationEventListener listener = go.GetComponent<AnimationEventListener>();
            if (listener != null)
            {
                listener.UnregisterTriggerLua((eAnimEventType)type, luaObject, luafunc);
            }
        }

        // RVA: 0x13FDB78
        public static void AddAnimListenerEventID(
            GameObject go, LuaFunction luafunc, LuaTable luaObject, string enentID)
        {
            if (go == null || luafunc == null)
            {
                luafunc?.Dispose();
                luaObject?.Dispose();
                return;
            }

            go.AddMissingComponent<AnimationEventListener>()
                .RegisterTriggerLua(enentID, luaObject, luafunc);
        }

        // RVA: 0x13FDCB8
        public static void RemoveAnimListenerEventID(
            GameObject go, LuaFunction luafunc, LuaTable luaObject, string enentID)
        {
            if (go == null || luafunc == null)
            {
                luafunc?.Dispose();
                luaObject?.Dispose();
                return;
            }

            AnimationEventListener listener = go.GetComponent<AnimationEventListener>();
            if (listener != null)
            {
                listener.UnregisterTriggerLua(enentID, luaObject, luafunc);
            }
        }

        // RVA: 0x13FDE34
        public static void AddAnimListener(GameObject go, UnityAction callback, eAnimEventType type)
        {
            if (callback != null && go != null)
            {
                go.AddMissingComponent<AnimationEventListener>().RegisterTrigger(type, callback);
            }
        }

        // RVA: 0x13FDEF0
        public static void RemoveAnimListener(GameObject go, UnityAction callback, eAnimEventType type)
        {
            if (callback != null && go != null)
            {
                AnimationEventListener listener = go.GetComponent<AnimationEventListener>();
                if (listener != null)
                {
                    listener.UnregisterTrigger(type, callback);
                }
            }
        }

        // RVA: 0x13FDFE8
        public static void AddFingerGestureListener(LuaFunction luafunc, LuaTable luaObject, int type)
        {
            if (luafunc == null)
            {
                luafunc?.Dispose();
                luaObject?.Dispose();
                return;
            }

            FingerGestures.instance.gameObject
                .AddMissingComponent<FingerGesturesListener>()
                .RegisterTriggerLua((eFingerGesturesType)type, luaObject, luafunc);
        }

        // RVA: 0x13FE164
        public static void RemoveFingerGestureListener(LuaFunction luafunc, LuaTable luaObject, int type)
        {
            if (luafunc == null)
            {
                luafunc?.Dispose();
                luaObject?.Dispose();
                return;
            }

            FingerGesturesListener listener =
                FingerGestures.instance.gameObject.GetComponent<FingerGesturesListener>();
            if (listener != null)
            {
                listener.UnregisterTriggerLua((eFingerGesturesType)type, luaObject, luafunc);
            }
        }

        // RVA: 0x13FE324
        public static void AddFingerGestureListener(UnityAction<Gesture> callback, eFingerGesturesType type)
        {
            if (callback != null && FingerGestures.instance != null)
            {
                FingerGestures.instance.gameObject
                    .AddMissingComponent<FingerGesturesListener>()
                    .RegisterTrigger(type, callback);
            }
        }

        // RVA: 0x13FE4BC
        public static void RemoveFingerGestureListener(UnityAction<Gesture> callback, eFingerGesturesType type)
        {
            if (callback == null || FingerGestures.instance == null)
            {
                return;
            }

            FingerGesturesListener listener =
                FingerGestures.instance.gameObject.GetComponent<FingerGesturesListener>();
            if (listener != null)
            {
                listener.UnregisterTrigger(type, callback);
            }
        }

        // RVA: 0x13FE690
        public static void AddFingerListener(LuaFunction luafunc, LuaTable luaObject, int type)
        {
            if (luafunc == null)
            {
                luafunc?.Dispose();
                luaObject?.Dispose();
                return;
            }

            FingerGestures.instance.gameObject
                .AddMissingComponent<FingerEventListener>()
                .RegisterTriggerLua((eFingerEventType)type, luaObject, luafunc);
        }

        // RVA: 0x13FE80C
        public static void RemoveFingerListener(LuaFunction luaFunction, LuaTable luaObject, int type)
        {
            if (luaFunction == null)
            {
                luaFunction?.Dispose();
                luaObject?.Dispose();
                return;
            }

            FingerEventListener listener =
                FingerGestures.instance.gameObject.GetComponent<FingerEventListener>();
            if (listener != null)
            {
                listener.UnregisterTriggerLua((eFingerEventType)type, luaObject, luaFunction);
            }
        }

        // RVA: 0x13FE958
        public static void AddFingerListener(UnityAction<FingerEvent> callback, eFingerEventType type)
        {
            if (callback != null && FingerGestures.instance != null)
            {
                FingerGestures.instance.gameObject
                    .AddMissingComponent<FingerEventListener>()
                    .RegisterTrigger(type, callback);
            }
        }

        // RVA: 0x13FEA3C
        public static void RemoveFingerListener(UnityAction<FingerEvent> callback, eFingerEventType type)
        {
            if (callback == null || FingerGestures.instance == null)
            {
                return;
            }

            FingerEventListener listener =
                FingerGestures.instance.gameObject.GetComponent<FingerEventListener>();
            if (listener != null)
            {
                listener.UnregisterTrigger(type, callback);
            }
        }

        // RVA: 0x13FEB74
        public static void AddPlayableDirectorListener(
            GameObject go, LuaFunction luafunc, LuaTable luaObject, int type)
        {
            if (go == null || luafunc == null)
            {
                luafunc?.Dispose();
                luaObject?.Dispose();
                return;
            }

            go.AddMissingComponent<TimelineListener>()
                .RegisterTriggerLua((ePlayableDirectorEvent)type, luaObject, luafunc);
        }

        // RVA: 0x13FECB8
        public static void RemovePlayableDirectorListener(
            GameObject go, LuaFunction luaFunction, LuaTable luaObject, int type)
        {
            if (go == null || luaFunction == null)
            {
                luaFunction?.Dispose();
                luaObject?.Dispose();
                return;
            }

            TimelineListener listener = go.GetComponent<TimelineListener>();
            if (listener != null)
            {
                listener.UnregisterTriggerLua((ePlayableDirectorEvent)type, luaObject, luaFunction);
            }
        }

        // RVA: 0x13FED98
        public static void AddPlayableDirectorListener(
            GameObject go, UnityAction<PlayableDirector> callback, ePlayableDirectorEvent type)
        {
            if (callback != null && go != null)
            {
                go.AddMissingComponent<TimelineListener>().RegisterTrigger(type, callback);
            }
        }

        // RVA: 0x13FEE10
        public static void RemovePlayableDirectorListener(
            GameObject go, UnityAction<PlayableDirector> callback, ePlayableDirectorEvent type)
        {
            if (callback != null && go != null)
            {
                TimelineListener listener = go.GetComponent<TimelineListener>();
                if (listener != null)
                {
                    listener.UnregisterTrigger(type, callback);
                }
            }
        }

        // RVA: 0x13FEEDC
        public static void AddTimelineMarkerListener(
            GameObject go, LuaFunction luafunc, LuaTable luaObject, string eventName)
        {
            if (go == null || luafunc == null)
            {
                luafunc?.Dispose();
                luaObject?.Dispose();
                return;
            }

            go.AddMissingComponent<TimelineMarkerListener>()
                .RegisterTriggerLua(eventName, luaObject, luafunc);
        }

        // RVA: 0x13FF020
        public static void RemoveTimelineMarkerListener(
            GameObject go, LuaFunction luaFunction, LuaTable luaObject, string eventName)
        {
            if (go == null || luaFunction == null)
            {
                luaFunction?.Dispose();
                luaObject?.Dispose();
                return;
            }

            TimelineMarkerListener listener = go.GetComponent<TimelineMarkerListener>();
            if (listener != null)
            {
                listener.UnregisterTriggerLua(eventName, luaObject, luaFunction);
            }
        }

        // RVA: 0x13FF100
        public static void AddTimelineMarkerListener(
            GameObject go, UnityAction<Playable, EventData> callback, string eventName)
        {
            if (callback != null && go != null)
            {
                go.AddMissingComponent<TimelineMarkerListener>().RegisterTrigger(eventName, callback);
            }
        }

        // RVA: 0x13FF178
        public static void RemoveTimelineMarkerListener(
            GameObject go, UnityAction<Playable, EventData> callback, string eventName)
        {
            if (callback != null && go != null)
            {
                TimelineMarkerListener listener = go.GetComponent<TimelineMarkerListener>();
                if (listener != null)
                {
                    listener.UnregisterTrigger(eventName, callback);
                }
            }
        }

        // RVA: 0x13FF244
        public static void AddCinemachineEventListener(
            GameObject go, LuaFunction luafunc, LuaTable luaObject, int type)
        {
            if (go == null || luafunc == null)
            {
                luafunc?.Dispose();
                luaObject?.Dispose();
                return;
            }

            go.AddMissingComponent<CinemachineEventListener>()
                .RegisterTriggerLua((eCinemachineEventType)type, luaObject, luafunc);
        }

        // RVA: 0x13FF388
        public static void RemoveCinemachineEventListener(
            GameObject g, LuaFunction luaFunction, LuaTable luaObject, int type)
        {
            if (g == null || luaFunction == null)
            {
                luaFunction?.Dispose();
                luaObject?.Dispose();
                return;
            }

            CinemachineEventListener listener = g.GetComponent<CinemachineEventListener>();
            if (listener != null)
            {
                listener.UnregisterTriggerLua((eCinemachineEventType)type, luaObject, luaFunction);
            }
        }

        // RVA: 0x13FF468
        public void .ctor()
        {
        }
    }
}
