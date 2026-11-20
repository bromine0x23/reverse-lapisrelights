// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Utility.MiscUtil
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using Oz.GameFramework.Runtime.Coroutines;
using UnityEngine.Rendering;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Oz.Utility
{
    public static class MiscUtil
    {
        public static bool isIdle;

        // RVA: 0x13E7064
        public static Texture2D CaptureByCamera(Camera mCamera, GameObject goImage)
        {
            RawImage rawImage = goImage.GetComponent<RawImage>();

            Rect rect = new Rect(0f, 0f, 1920f, 1080f);
            RenderTexture renderTexture = new RenderTexture((int)rect.width, (int)rect.height, 16);
            mCamera.targetTexture = renderTexture;
            mCamera.Render();
            RenderTexture.active = renderTexture;

            Texture2D texture = new Texture2D((int)rect.width, (int)rect.height, TextureFormat.RGB24, false);
            texture.ReadPixels(new Rect(0f, 0f, rect.width, rect.height), 0, 0);
            texture.Apply();

            mCamera.targetTexture = null;
            RenderTexture.active = null;
            Object.Destroy(renderTexture);

            rawImage.texture = texture;
            return texture;
        }

        // RVA: 0x13E7254
        public static Texture2D CapturePicture(Camera mCamera, Camera mCamera2)
        {
            Rect rect = new Rect(0f, 0f, Screen.width, Screen.height);
            RenderTexture renderTexture = new RenderTexture((int)rect.width, (int)rect.height, 16);
            mCamera.targetTexture = renderTexture;
            mCamera.Render();

            if (mCamera2)
            {
                mCamera2.targetTexture = renderTexture;
                mCamera2.Render();
            }

            RenderTexture.active = renderTexture;

            Texture2D texture = new Texture2D((int)rect.width, (int)rect.height, TextureFormat.RGB24, false);
            texture.ReadPixels(new Rect(0f, 0f, rect.width, rect.height), 0, 0);
            texture.Apply();

            mCamera.targetTexture = null;
            RenderTexture.active = null;
            if (mCamera2)
            {
                mCamera2.targetTexture = null;
            }
            Object.Destroy(renderTexture);

            SeanPostProcessLayer postProcess = mCamera.GetComponent<SeanPostProcessLayer>();
            if (postProcess)
            {
                postProcess.RuntimeSetting.MarkAllSettingChanged = true;
            }

            return texture;
        }

        // RVA: 0x13E74E8
        public static void CaptureTexture(Action<Texture2D> _action)
        {
            IEnumerator RecordFrame()
            {
                yield return new WaitForEndOfFrame();
                _action?.Invoke(ScreenCapture.CaptureScreenshotAsTexture());
            }

            CoroutineManager.StartCoroutine(RecordFrame());
        }

        // RVA: 0x13E75D4
        public static Texture2D VerticalFlipTexture(Texture2D texture)
        {
            int width = texture.width;
            int height = texture.height;

            Texture2D flipped = new Texture2D(width, height);
            for (int y = 0; y < height; y++)
            {
                flipped.SetPixels(0, y, width, 1, texture.GetPixels(0, height - 1 - y, width, 1));
            }
            flipped.Apply();
            return flipped;
        }

        // RVA: 0x13E76F0
        public static void CaptureRenderTexture(Action<Texture2D> action)
        {
            if (SystemInfo.supportsAsyncGPUReadback)
            {
                CoroutineManager.StartCoroutine(StartSupportGPUReadback());
            }
            else
            {
                CoroutineManager.StartCoroutine(StartDontSupportGPUReadback());
            }

            IEnumerator StartSupportGPUReadback()
            {
                yield return new WaitForEndOfFrame();

                RenderTexture renderTexture = new RenderTexture(Screen.width, Screen.height, 0);
                ScreenCapture.CaptureScreenshotIntoRenderTexture(renderTexture);

                void ReadbackCompleted(AsyncGPUReadbackRequest request)
                {
                    if (!request.done || request.hasError)
                    {
                        return;
                    }

                    Object.DestroyImmediate(renderTexture);

                    Texture2D texture = new Texture2D(
                        request.width, request.height, TextureFormat.RGB24, false);
                    texture.LoadRawTextureData(request.GetData<byte>());
                    texture.Apply();

                    if (SystemInfo.graphicsUVStartsAtTop)
                    {
                        texture = VerticalFlipTexture(texture);
                    }

                    action?.Invoke(texture);
                }

                AsyncGPUReadback.Request(renderTexture, 0, TextureFormat.RGB24, ReadbackCompleted);
            }

            IEnumerator StartDontSupportGPUReadback()
            {
                yield return new WaitForEndOfFrame();

                RenderTexture renderTexture = new RenderTexture(Screen.width, Screen.height, 0);
                ScreenCapture.CaptureScreenshotIntoRenderTexture(renderTexture);

                RenderTexture active = RenderTexture.active;
                RenderTexture.active = renderTexture;

                Texture2D texture = new Texture2D(
                    Screen.width, Screen.height, TextureFormat.RGB24, false);
                texture.ReadPixels(new Rect(0f, 0f, Screen.width, Screen.height), 0, 0);
                texture.Apply();

                RenderTexture.active = active;
                Object.DestroyImmediate(renderTexture);

                if (SystemInfo.graphicsUVStartsAtTop)
                {
                    texture = VerticalFlipTexture(texture);
                }

                action?.Invoke(texture);
            }
        }

        // RVA: 0x13E7864
        public static bool GraphicsAtTop()
        {
            return SystemInfo.graphicsUVStartsAtTop && QualitySettings.antiAliasing > 0;
        }

        // RVA: 0x13E7898
        public static DirectorUpdateMode EnumDirectorUpdateMode(int number)
        {
            return (DirectorUpdateMode)number;
        }

        // RVA: 0x13E789C
        public static RNGUtil GenRNG(uint seed)
        {
            return new RNGUtil(seed);
        }

        // RVA: 0x13E792C
        public static bool IsIos()
        {
            return false;
        }

        // RVA: 0x13E7934
        static MiscUtil()
        {
        }
    }
}
