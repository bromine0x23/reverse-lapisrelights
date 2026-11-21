// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.GuiLogHandler
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
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

namespace Jackpot
{
    public class GuiLogHandler : MonoBehaviour, ILoggerHandler
    {
        private const int DefaultLogSize = 1000;
        private static GuiLogHandler instance;
        private static object lockObject;
        private Queue<LoggerReport> reports;
        private int logSize;
        private bool isDisplay;
        private bool logHasBeenStarted;
        private Vector2 scrollPosition;
        private string searchString;
        public static GuiLogHandler Instance { get { return instance; } }

        // RVA: 0x19F1FB8
        public void StartLog(bool ignoreBuildConfiguration = False)
        {
                        if (!ignoreBuildConfiguration && !Debug.isDebugBuild)
                        {
                            return;
                        }

                        if (!logHasBeenStarted)
                        {
                            Logger.AddHandler(this);
                            logHasBeenStarted = true;
                        }
        }

        // RVA: 0x19F206C
        public void SetLogSize(int size)
        {
                        logSize = size;
                        Dequeue();
        }

        // RVA: 0x19F20E8
        public void Show()
        {
                        isDisplay = true;
        }

        // RVA: 0x19F20F4
        public void Hide()
        {
                        isDisplay = false;
        }

        // RVA: 0x19F20FC
        public void HandleLog(LoggerReport report)
        {
                        reports.Enqueue(report);
                        Dequeue();
        }

        // RVA: 0x19F216C
        private void Awake()
        {
                        UnityEngine.Object.DontDestroyOnLoad(gameObject);
                        reports = new Queue<LoggerReport>();
                        isDisplay = false;
                        logSize = 1000;
                        scrollPosition = Vector2.zero;
        }

        // RVA: 0x19F224C
        private void Update()
        {
                        ProcessTouch();
        }

        // RVA: 0x19F23E4
        private void OnGUI()
        {
                        if (!isDisplay)
                        {
                            return;
                        }

                        if (GUI.Button(new Rect(10f, 10f, 100f, 50f), "Clear"))
                        {
                            reports.Clear();
                        }

                        searchString = GUI.TextField(new Rect(120f, 10f, 300f, 50f), searchString);
                        int fontSize = GUI.skin.GetStyle("label").fontSize;
                        GUI.Box(new Rect(0f, 0f, Screen.width, Screen.height), string.Empty);
                        float lineHeight = (float)fontSize + 10f;
                        Rect viewRect = new Rect(0f, 80f, Screen.width, Screen.height - 80);
                        Rect contentRect = new Rect(0f, 80f, 10000f, lineHeight * (float)reports.Count - 80f);
                        scrollPosition = GUI.BeginScrollView(viewRect, scrollPosition, contentRect);
                        List<LoggerReport> list = new List<LoggerReport>(reports);
                        int num = 0;
                        for (int i = list.Count - 1; i >= 0; i--)
                        {
                            string text = list[i].ToString();
                            if (searchString.Length != 0 && text.IndexOf(searchString) < 0)
                            {
                                continue;
                            }

                            GUI.Label(new Rect(0f, (float)num * lineHeight + 80f, 10000f, lineHeight), text);
                            num++;
                        }

                        GUI.EndScrollView();
        }

        // RVA: 0x19F2074
        private void Dequeue()
        {
                        while (reports.Count > logSize)
                        {
                            reports.Dequeue();
                        }
        }

        // RVA: 0x19F2250
        private void ProcessTouch()
        {
                        Touch touch = default(Touch);
                        if (isDisplay && Input.touchCount >= 1)
                        {
                            touch = Input.touches[0];
                            if (touch.phase == TouchPhase.Moved)
                            {
                                scrollPosition = new Vector2(scrollPosition.x - touch.deltaPosition.x, scrollPosition.y + touch.deltaPosition.y);
                            }

                            if (Input.touchCount >= 3 && Input.touches[2].phase == TouchPhase.Ended)
                            {
                                isDisplay = false;
                            }
                        }

                        else if (Input.touchCount >= 3 && Input.touches[2].phase == TouchPhase.Ended)
                        {
                            isDisplay = true;
                        }
        }

        // RVA: 0x19F27A8
        public GuiLogHandler()
        {
                        searchString = string.Empty;
        }

        // RVA: 0x19F2800
        static GuiLogHandler()
        {
                        lockObject = new object();
        }
    }
}
