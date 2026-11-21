// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Utility.UIBehaviourUtil
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using Oz.GameFramework.Runtime.Resource;
using Oz.Framework.UIModule;
using Oz.Framework;
using System.Linq;
using Spine;
using Spine.Unity;
using UnityEngine.Rendering;
using UnityEngine.Video;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Oz.Utility
{
    public static class UIBehaviourUtil
    {

        // RVA: 0x13E863C
        public static void SetRectTransformOffsetMax(Graphic graphic, float x, float y)
        {
            graphic.rectTransform.offsetMax = new Vector2(x, y);
        }

        // RVA: 0x13E86A4
        public static void SetRectTransformOffsetMin(Graphic graphic, float x, float y)
        {
            graphic.rectTransform.offsetMin = new Vector2(x, y);
        }

        // RVA: 0x13E870C
        public static void SetRectTransformOffsetType(Graphic graphic, int type, int offx, int offy)
        {
            RectTransform rectTransform = graphic.rectTransform;

            switch (type)
            {
                case 1:
                    rectTransform.anchorMin = new Vector2(1f, 1f);
                    rectTransform.anchorMax = new Vector2(1f, 1f);
                    break;
                case 2:
                    rectTransform.anchorMin = new Vector2(0f, 1f);
                    rectTransform.anchorMax = new Vector2(0f, 1f);
                    break;
                case 3:
                    rectTransform.anchorMin = new Vector2(0f, 0.5f);
                    rectTransform.anchorMax = new Vector2(0f, 0.5f);
                    break;
                default:
                    rectTransform.anchorMin = new Vector2(0.5f, 0.5f);
                    rectTransform.anchorMax = new Vector2(0.5f, 0.5f);
                    break;
            }

            rectTransform.anchoredPosition = new Vector2(offx, offy);
        }

        // RVA: 0x13E88BC
        public static void SetRectTransformPivot(Graphic graphic, float x, float y)
        {
            graphic.rectTransform.pivot = new Vector2(x, y);
        }

        // RVA: 0x13E8924
        public static void SetRectTransformSizeDelta(Graphic graphic, float x, float y)
        {
            graphic.rectTransform.sizeDelta = new Vector2(x, y);
        }

        // RVA: 0x13E898C
        public static int GetRectTransformSizeDeltaWidth(Graphic graphic)
        {
            return (int)graphic.rectTransform.sizeDelta.x;
        }

        // RVA: 0x13E89BC
        public static void SetRectTransformAnchoredPosition(Graphic graphic, float x, float y)
        {
            graphic.rectTransform.anchoredPosition = new Vector2(x, y);
        }

        // RVA: 0x13E8A24
        public static void SetRectTransformAnchoredPosition3D(Graphic graphic, float x, float y, float z)
        {
            graphic.rectTransform.anchoredPosition3D = new Vector3(x, y, z);
        }

        // RVA: 0x13E8AAC
        public static void SetRectTransformAnchorMax(Graphic graphic, float x, float y)
        {
            graphic.rectTransform.anchorMax = new Vector2(x, y);
        }

        // RVA: 0x13E8B14
        public static void SetRectTransformAnchorMin(Graphic graphic, float x, float y)
        {
            graphic.rectTransform.anchorMin = new Vector2(x, y);
        }

        // RVA: 0x13E8B7C
        public static void SetGraphicAlpha(Graphic graphic, float alpha)
        {
            Color color = graphic.color;
            color.a = alpha;
            graphic.color = color;
        }

        // RVA: 0x13E8BD0
        public static void SetCanvasGroupAlpha(CanvasGroup canvasGroup, float alpha)
        {
            canvasGroup.alpha = alpha;
        }

        // RVA: 0x13E8BE8
        public static void SetCanvasGroupRaycast(CanvasGroup canvasGroup, bool vbool)
        {
            canvasGroup.blocksRaycasts = vbool;
        }

        // RVA: 0x13E8C04
        public static void SetGraphicColorRGBA(Graphic graphic, float r, float g, float b, float a)
        {
            graphic.color = new Color(r, g, b, a);
        }

        // RVA: 0x13E8C5C
        public static void SetGraphicColorRGB(Graphic graphic, float r, float g, float b)
        {
            graphic.color = new Color(r, g, b);
        }

        // RVA: 0x13E8CB4
        public static void SetOutlineColorRGBA(GameObject go, float r, float g, float b, float a)
        {
            Outline outline = go.GetComponent<Outline>();
            if (outline == null)
            {
                return;
            }

            if (r == -1f)
            {
                outline.enabled = false;
                return;
            }

            outline.enabled = true;
            outline.effectColor = new Color(r, g, b, a);
        }

        // RVA: 0x13E8DEC
        public static void SetGraphicEnabled(Graphic graphic, bool enabled)
        {
            graphic.enabled = enabled;
        }

        // RVA: 0x13E8E08
        public static void SetTextString(Text text, string content)
        {
            text.text = content;
        }

        // RVA: 0x13E8E28
        public static void SetTextAlignment(Text text, int anchor)
        {
            text.alignment = (TextAnchor)anchor;
        }

        // RVA: 0x13E8E40
        public static void SetImageSprite(Image image, AssetRef sprite)
        {
            if (image != null)
            {
                image.sprite = sprite.Asset as Sprite;
            }
        }

        // RVA: 0x13E8F0C
        public static void SetImageOverrideSprite(Image image, AssetRef sprite)
        {
            if (image != null)
            {
                image.overrideSprite = sprite.Asset as Sprite;
            }
        }

        // RVA: 0x13E8FD8
        public static AssetRef SetImageSprite(Image image, string spritePath)
        {
            AssetRef sprite = ResourceManager.LoadSync(spritePath, typeof(Sprite));
            if (sprite != null)
            {
                SetImageSprite(image, sprite);
            }
            return sprite;
        }

        // RVA: 0x13E90AC
        public static AssetRef SetImageOverrideSprite(Image image, string spritePath)
        {
            AssetRef sprite = ResourceManager.LoadSync(spritePath, typeof(Sprite));
            if (sprite != null)
            {
                SetImageOverrideSprite(image, sprite);
            }
            return sprite;
        }

        // RVA: 0x13E9180
        public static void SetImageSprite(Image image, AssetRef sprite, bool bNativeSize)
        {
            image.sprite = sprite.Asset as Sprite;
            if (bNativeSize)
            {
                image.SetNativeSize();
            }
        }

        // RVA: 0x13E9234
        public static void SetImageOverrideSprite(Image image, AssetRef sprite, bool bNativeSize)
        {
            image.overrideSprite = sprite.Asset as Sprite;
            if (bNativeSize)
            {
                image.SetNativeSize();
            }
        }

        // RVA: 0x13E92E8
        public static AssetRef SetImageSprite(Image image, string spritePath, bool bNativeSize)
        {
            AssetRef sprite = SetImageSprite(image, spritePath);
            if (bNativeSize)
            {
                image.SetNativeSize();
            }
            return sprite;
        }

        // RVA: 0x13E933C
        public static AssetRef SetImageOverrideSprite(Image image, string spritePath, bool bNativeSize)
        {
            AssetRef sprite = SetImageOverrideSprite(image, spritePath);
            if (bNativeSize)
            {
                image.SetNativeSize();
            }
            return sprite;
        }

        // RVA: 0x13E9390
        public static void SetImageType(Image image, int type)
        {
            image.type = (Image.Type)type;
        }

        // RVA: 0x13E93A8
        public static AssetRef SetImageMaterial(Image image, string materialPath)
        {
            AssetRef material = ResourceManager.LoadSync(materialPath, typeof(Material));
            if (material != null)
            {
                image.material = material.Asset as Material;
            }
            return material;
        }

        // RVA: 0x13E94D0
        public static AssetRef SetImageGray(Image image, int isGray)
        {
            if (isGray != 1)
            {
                image.material = null;
                return null;
            }

            AssetRef material = ResourceManager.LoadSync("UI/Materials/GrayMat", typeof(Material));
            if (material != null)
            {
                image.material = material.Asset as Material;
            }
            return material;
        }

        // RVA: 0x13E962C
        public static AssetRef SetImageMaskGray(Image image, int isGray)
        {
            string path = isGray == 1 ? "UI/Materials/HeadMaskGary" : "UI/Materials/HeadMask";
            AssetRef material = ResourceManager.LoadSync(path, typeof(Material));
            if (material != null)
            {
                image.material = material.Asset as Material;
            }
            return material;
        }

        // RVA: 0x13E97CC
        public static void SetRawImageTexture(RawImage rawImage, AssetRef texture)
        {
            rawImage.texture = texture.Asset as Texture;
        }

        // RVA: 0x13E9870
        public static AssetRef SetRawImageTexture(RawImage rawImage, string texturePath)
        {
            AssetRef texture = ResourceManager.LoadSync(texturePath, typeof(Texture));
            if (texture != null)
            {
                SetRawImageTexture(rawImage, texture);
            }
            return texture;
        }

        // RVA: 0x13E9944
        public static void SetRawImageTexture(RawImage rawImage, AssetRef texture, bool bNativeSize)
        {
            rawImage.texture = texture.Asset as Texture;
            if (bNativeSize)
            {
                rawImage.SetNativeSize();
            }
        }

        // RVA: 0x13E9A14
        public static AssetRef SetRawImageTexture(RawImage rawImage, string texturePath, bool bNativeSize)
        {
            AssetRef texture = SetRawImageTexture(rawImage, texturePath);
            if (bNativeSize)
            {
                rawImage.SetNativeSize();
            }
            return texture;
        }

        // RVA: 0x13E9A68
        public static AssetRef SetRawImageMaterial(RawImage rawImage, string materialPath)
        {
            AssetRef material = ResourceManager.LoadSync(materialPath, typeof(Material));
            if (material != null)
            {
                rawImage.material = material.Asset as Material;
            }
            return material;
        }

        // RVA: 0x13E9B90
        public static void SetRawImageMaterial(RawImage rawImage, AssetRef material)
        {
            if (material != null)
            {
                rawImage.material = material.Asset as Material;
            }
        }

        // RVA: 0x13E9C4C
        public static void SetRawImageUVRect(RawImage rawImage, float x, float y, float width, float height)
        {
            rawImage.uvRect = new Rect(x, y, width, height);
        }

        // RVA: 0x13E9C9C
        public static void SetInteractable(Selectable selectable, bool interactable)
        {
            selectable.interactable = interactable;
        }

        // RVA: 0x13E9CB8
        public static void SetButtonOnClickedEvent(Button button, Button.ButtonClickedEvent onClick)
        {
            button.onClick = onClick;
        }

        // RVA: 0x13E9CD0
        public static void AddButtonOnClickListener(Button button, UnityAction action)
        {
            button.onClick.AddListener(action);
        }

        // RVA: 0x13E9CF4
        public static void RemoveButtonOnClickListener(Button button, UnityAction action)
        {
            button.onClick.RemoveListener(action);
        }

        // RVA: 0x13E9D18
        public static void RemoveAllButtonOnClickListener(Button button)
        {
            button.onClick.RemoveAllListeners();
        }

        // RVA: 0x13E9D3C
        public static void SetToggle(Toggle toggle)
        {
        }

        // RVA: 0x13E9D40
        public static void SetSlider(Slider slider)
        {
        }

        // RVA: 0x13E9D44
        public static void SetScrollbar(Scrollbar scrollbar)
        {
        }

        // RVA: 0x13E9D48
        public static void SetDropdown(Dropdown dropdown)
        {
        }

        // RVA: 0x13E9D4C
        public static void SetInputFieldText(InputField inputField, string content)
        {
            inputField.text = content;
        }

        // RVA: 0x13E9D64
        public static void SetButtonBright(GameObject obj, float num)
        {
            Button button = obj.GetComponent<Button>();
            button.transition = Selectable.Transition.ColorTint;

            ColorBlock colors = button.colors;
            Color color = new Color(num / 255f, num / 255f, num / 255f, 1f);
            colors.normalColor = color;
            colors.highlightedColor = color;
            button.colors = colors;
        }

        // RVA: 0x13E9E7C
        public static Vector2 ScreenPointToLocalPoint(GameObject obj, Vector2 screenPoint)
        {
            RectTransformUtility.ScreenPointToLocalPointInRectangle(
                obj.transform as RectTransform, screenPoint, UIManager.UICamera, out Vector2 localPoint);
            return localPoint;
        }

        // RVA: 0x13E9F64
        public static Vector3 ScreenToWorldPoint(GameObject RtCameraGo, Vector3 position)
        {
            return RtCameraGo.GetComponent<Camera>().ScreenToWorldPoint(position);
        }

        // RVA: 0x13E9FF0
        public static Vector2 GetTipsPos(
            GameObject tipsLayer, Vector2 screenClickPoint, GameObject tips, float offset = 200)
        {
            ForceRebuildLayoutImmediate(tips);

            RectTransform layerRect = tipsLayer.transform as RectTransform;
            RectTransform tipsRect = tips.transform as RectTransform;

            float scaleFactor = UIManager.RootCanvas.scaleFactor;
            Vector2 pos = screenClickPoint + Vector2.up * offset * scaleFactor;

            float w = tipsRect.sizeDelta.x * scaleFactor;
            float h = tipsRect.sizeDelta.y * scaleFactor;
            Vector2 pivot = tipsRect.pivot;

            float x = pos.x;
            float y = pos.y;

            Rect safeArea = Screen.safeArea;
            if (x - w * pivot.x < safeArea.x)
            {
                x = safeArea.x + w * pivot.x;
            }
            else if (x - w * pivot.x + w > safeArea.x + safeArea.width)
            {
                x = safeArea.x + safeArea.width - w + w * pivot.x;
            }

            if (y + h * (1f - pivot.y) - h < safeArea.y)
            {
                y = safeArea.y + h * pivot.y;
            }
            else if (y + h * (1f - pivot.y) > safeArea.y + safeArea.height)
            {
                y = safeArea.y + safeArea.height - h + h * pivot.y;
            }

            RectTransformUtility.ScreenPointToLocalPointInRectangle(
                layerRect, new Vector2(x, y), UIManager.UICamera, out Vector2 localPoint);
            return localPoint;
        }

        // RVA: 0x13EA46C
        public static void ForceRebuildLayoutImmediate(GameObject go)
        {
            LayoutRebuilder.ForceRebuildLayoutImmediate(go.transform as RectTransform);
        }

        // RVA: 0x13EA570
        public static void SetLongPressTime(GameObject go, float pTime)
        {
            PointerLongPressTrigger trigger = go.GetComponent<PointerLongPressTrigger>();
            if (trigger != null)
            {
                trigger.StartAfter = pTime;
            }
        }

        // RVA: 0x13EA61C
        public static AssetRef SetVideoPlayerClip(VideoPlayer player, string clippath)
        {
            AssetRef clip = ResourceManager.LoadSync(clippath, typeof(VideoClip));
            if (clip != null)
            {
                SetVideoPlayerClip(player, clip);
            }
            return clip;
        }

        // RVA: 0x13EA6F0
        public static void SetVideoPlayerClip(VideoPlayer player, AssetRef clip)
        {
            if (player == null)
            {
                return;
            }

            player.clip = clip.Asset as VideoClip;
            if (player.targetTexture == null)
            {
                return;
            }

            RenderBuffer colorBuffer = Graphics.activeColorBuffer;
            RenderBuffer depthBuffer = Graphics.activeDepthBuffer;
            Graphics.SetRenderTarget(player.targetTexture);

            CommandBuffer commandBuffer = new CommandBuffer();
            commandBuffer.SetRenderTarget(player.targetTexture);
            commandBuffer.ClearRenderTarget(false, true, Color.black);
            commandBuffer.SetRenderTarget(colorBuffer, depthBuffer);
            Graphics.ExecuteCommandBuffer(commandBuffer);
            commandBuffer.Release();
        }

        // RVA: 0x13EA948
        public static AssetRef SetGradientImageMaterial(
            Image image, string matPath, Color colT, Color colB, float powValue)
        {
            AssetRef material = ResourceManager.LoadSync(matPath, typeof(Material));
            if (material != null)
            {
                Material mat = material.Asset as Material;
                mat.SetColor("_ColorTop", colT);
                mat.SetColor("_ColorBottom", colB);
                mat.SetFloat("_Gradient", powValue);
                image.material = mat;
            }
            return material;
        }

        // RVA: 0x13EAB20
        public static AssetRef SetAnimatorController(string path, Animator anim)
        {
            AssetRef controller = ResourceManager.LoadSync(path, typeof(RuntimeAnimatorController));
            if (controller != null)
            {
                anim.runtimeAnimatorController = controller.Asset as RuntimeAnimatorController;
            }
            return controller;
        }

        // RVA: 0x13EAC40
        public static void SetWorldToScreenPoint(GameObject RtCameraGo, GameObject go, Vector3 pos)
        {
            Camera camera = RtCameraGo.GetComponent<Camera>();

            float depth = camera.WorldToScreenPoint(go.transform.position).z;

            Vector3 a = camera.ScreenToWorldPoint(go.transform.position);
            Vector3 b = camera.ScreenToWorldPoint(
                new Vector3(Input.mousePosition.x, Input.mousePosition.y, depth));

            Vector3 offset = a - b;
            offset = new Vector3(offset.x, offset.y, 0f);

            // 原代码此处还计算了一次当前鼠标的世界坐标，但结果未参与后续运算
            camera.ScreenToWorldPoint(new Vector3(Input.mousePosition.x, Input.mousePosition.y, depth));

            go.transform.position = new Vector3(0f, 2f, 0f) - offset - pos;
        }

        // RVA: 0x13EAEB0
        public static Vector3 GetWorldToScreenPoint(GameObject RtCameraGo, GameObject go, Vector3 pos)
        {
            Camera camera = RtCameraGo.GetComponent<Camera>();

            float depth = camera.WorldToScreenPoint(go.transform.position).z;

            Vector3 a = camera.ScreenToWorldPoint(go.transform.position);
            Vector3 b = camera.ScreenToWorldPoint(
                new Vector3(Input.mousePosition.x, Input.mousePosition.y, depth));

            Vector3 offset = a - b;
            offset = new Vector3(offset.x, offset.y, 0f);

            // 原代码此处还计算了一次当前鼠标的世界坐标，但结果未参与后续运算
            camera.ScreenToWorldPoint(new Vector3(Input.mousePosition.x, Input.mousePosition.y, depth));

            Vector3 result = new Vector3(0f, 2f, 0f) - offset;
            return new Vector3(result.x, result.y, 1f);
        }

        // RVA: 0x13EB0D4
        public static void PlaySpineAni(GameObject g)
        {
            SkeletonGraphic skeleton = g.GetComponent<SkeletonGraphic>();
            if (skeleton != null)
            {
                skeleton.AnimationState.SetAnimation(0, skeleton.startingAnimation, false);
            }
        }

        // RVA: 0x13EB19C
        public static void PlaySpineAniWithName(GameObject g, string name)
        {
            SkeletonGraphic skeleton = g.GetComponent<SkeletonGraphic>();
            if (skeleton != null)
            {
                skeleton.startingAnimation = name;
                skeleton.AnimationState.SetAnimation(0, name, true);
            }
        }

        // RVA: 0x13EB278
        public static void SetSpineSkeletonDataAsset(
            GameObject go,
            string skeletonAssetDataPath,
            string materialPath,
            out AssetRef skeletonDataAssetRef,
            out AssetRef materialRef)
        {
            skeletonDataAssetRef = ResourceManager.LoadSync(
                skeletonAssetDataPath, typeof(SkeletonDataAsset));
            materialRef = ResourceManager.LoadSync(materialPath, typeof(Material));

            if (skeletonDataAssetRef != null && materialRef != null)
            {
                SetSpineSkeletonDataAsset(go, skeletonDataAssetRef, materialRef);
            }
        }

        // RVA: 0x13EB39C
        public static void SetSpineSkeletonDataAsset(
            GameObject go, AssetRef skeletonDataAssetRef, AssetRef materialRef)
        {
            SkeletonGraphic skeleton = go.GetComponent<SkeletonGraphic>();
            if (materialRef == null || skeletonDataAssetRef == null || skeleton == null)
            {
                return;
            }

            skeleton.skeletonDataAsset = skeletonDataAssetRef.Asset as SkeletonDataAsset;
            skeleton.material = materialRef.Asset as Material;
            skeleton.Initialize(true);
        }

        // RVA: 0x13EB50C
        public static void SetSpineAnimationState(GameObject go, string animName, bool playFirst, bool loop)
        {
            SkeletonGraphic skeleton = go.GetComponent<SkeletonGraphic>();
            if (skeleton == null || skeleton.skeletonDataAsset == null)
            {
                return;
            }

            SkeletonData skeletonData = skeleton.skeletonDataAsset.GetSkeletonData(false);
            if (skeletonData == null)
            {
                return;
            }

            Animation animation = skeletonData.FindAnimation(animName);
            if (animation != null)
            {
                skeleton.AnimationState.SetAnimation(0, animation, loop);
                return;
            }

            if (playFirst)
            {
                skeleton.AnimationState.SetAnimation(
                    0, skeleton.skeletonDataAsset.GetSkeletonData(false).animations.First(), loop);
            }
            else
            {
                skeleton.AnimationState.SetEmptyAnimation(0, 0f);
            }
        }

        // RVA: 0x13EB6DC
        public static void PrintDebugError(string str)
        {
            Debug.LogError(str);
        }

        // RVA: 0x13EB744
        public static void SetConstraintType(GameObject go, int constraint, int constraintCount)
        {
            GridLayoutGroup gridLayoutGroup = go.GetComponent<GridLayoutGroup>();

            switch (constraint)
            {
                case 1:
                    gridLayoutGroup.constraint = GridLayoutGroup.Constraint.FixedColumnCount;
                    break;
                case 2:
                    gridLayoutGroup.constraint = GridLayoutGroup.Constraint.FixedRowCount;
                    break;
                default:
                    gridLayoutGroup.constraint = GridLayoutGroup.Constraint.Flexible;
                    break;
            }

            gridLayoutGroup.constraintCount = constraintCount;
        }

        // RVA: 0x13EB80C
        public static void ReplaySpineAnimation(GameObject go)
        {
            SkeletonGraphic skeleton = go.GetComponent<SkeletonGraphic>();
            if (skeleton == null)
            {
                return;
            }

            SpineAnimController controller = go.GetComponent<SpineAnimController>();
            if (controller != null)
            {
                if (string.IsNullOrEmpty(controller.FirstAnimName))
                {
                    return;
                }

                skeleton.AnimationState.ClearTrack(0);
                skeleton.AnimationState.SetAnimation(0, controller.FirstAnimName, controller.FirstAnimLoop);

                if (!string.IsNullOrEmpty(controller.SecondAnimName))
                {
                    skeleton.AnimationState.AddAnimation(
                        0, controller.SecondAnimName, controller.SecondAnimLoop, controller.DelayTime);
                }
            }
            else
            {
                TrackEntry current = skeleton.AnimationState.GetCurrent(0);
                if (current != null)
                {
                    current.trackTime = current.animationStart;
                }
            }
        }
    }
}
