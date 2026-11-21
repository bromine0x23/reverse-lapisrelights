// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.GpuUtility
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Jackpot
{
    public class GpuUtility
    {
        private static readonly Regex Reg;

        // RVA: 0x19F15EC
        public static GpuKind GetGpuKind()
        {
                        return GetGpuKind(SystemInfo.graphicsDeviceName, SystemInfo.graphicsDeviceVersion);
        }

        // RVA: 0x19F166C
        public static GpuKind GetGpuKind(string graphicsDeviceName, string graphicsDeviceVersion)
        {
                        if (string.IsNullOrEmpty(graphicsDeviceName))
                        {
                            return GpuKind.Unknown;
                        }

                        if (Platform.IsIos)
                        {
                            if (graphicsDeviceName.StartsWith("PowerVR"))
                            {
                                return GpuKind.ApplePowerVR;
                            }

                            if (graphicsDeviceName.StartsWith("Apple A"))
                            {
                                return GpuKind.Apple;
                            }

                            return GpuKind.Other;
                        }

                        if (Platform.IsAndroid)
                        {
                            int openGlESVersion = GetOpenGlESVersion(graphicsDeviceVersion);
                            if (graphicsDeviceName.StartsWith("PowerVR"))
                            {
                                return GpuKind.AndroidPowerVR;
                            }

                            if (graphicsDeviceName.StartsWith("Adreno"))
                            {
                                string[] array = graphicsDeviceName.Split(' ');
                                for (int i = 0; i < array.Length; i++)
                                {
                                    if (array[i].IndexOf("Adreno") != -1 || array[i].IndexOf("(TM)") != -1)
                                    {
                                        return (int.Parse(array[i].Substring(0, 1)) > 3) ? GpuKind.Adreno4xxAndOver : GpuKind.Adreno3xxAndUnder;
                                    }
                                }
                            }

                            if (graphicsDeviceName.StartsWith("Mali"))
                            {
                                string text = regex.Replace(graphicsDeviceName, string.Empty);
                                if (string.IsNullOrEmpty(text))
                                {
                                    return GpuKind.Mali;
                                }

                                return (int.Parse(text.Substring(1)) >= 600 && openGlESVersion >= 3) ? GpuKind.MaliOther : GpuKind.Mali;
                            }

                            if (graphicsDeviceName.IndexOf("Tegra") != -1)
                            {
                                return (openGlESVersion > 2) ? GpuKind.TegraK1OrX1 : GpuKind.Tegra;
                            }

                            if (openGlESVersion < 1)
                            {
                                return GpuKind.Other;
                            }

                            return (openGlESVersion > 2) ? GpuKind.OtherOpenGLES3xAndOver : GpuKind.OtherOpenGLES2xAndUnder;
                        }

                        return GpuKind.Other;
        }

        // RVA: 0x19F199C
        private static int GetOpenGlESVersion(string openGlVersion)
        {
                        if (string.IsNullOrEmpty(openGlVersion) || openGlVersion.IndexOf("OpenGL") == -1)
                        {
                            return 0;
                        }

                        string[] array = openGlVersion.Split(' ');
                        for (int i = 0; i < array.Length; i++)
                        {
                            if (array[i].IndexOf("OpenGL") == -1 && array[i].IndexOf("ES") == -1)
                            {
                                return int.Parse(array[i].Substring(0, 1));
                            }
                        }

                        return 0;
        }

        // RVA: 0x19F1B0C
        public GpuUtility()
        {
        }

        // RVA: 0x19F1B14
        static GpuUtility()
        {
                        regex = new Regex("[^T0-9]");
        }
    }
}
