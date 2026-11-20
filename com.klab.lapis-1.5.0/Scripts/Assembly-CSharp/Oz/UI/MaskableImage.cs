// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.UI.MaskableImage
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        仅处理 Simple 类型：OnPopulateMesh → GenerateSimpleSprite，
//        四个顶点额外写入归一化 uv1（供渐变着色器使用）。
// =============================================================================

using UnityEngine;
using UnityEngine.Sprites;
using UnityEngine.UI;

namespace Oz.UI
{
    public class MaskableImage : Image
    {
        private static readonly Vector4 s_DefaultTangent = new Vector4(1f, 0f, 0f, -1f);
        private static readonly Vector3 s_DefaultNormal = Vector3.back;

        // RVA: 0x13DF16C
        protected override void OnPopulateMesh(VertexHelper toFill)
        {
            Sprite sprite = overrideSprite != null ? overrideSprite : m_Sprite;
            if (sprite == null)
            {
                base.OnPopulateMesh(toFill);
            }
            else if (m_Type == Type.Simple)
            {
                GenerateSimpleSprite(toFill, m_PreserveAspect);
            }
        }

        // RVA: 0x13DF284
        private void GenerateSimpleSprite(VertexHelper vh, bool lPreserveAspect)
        {
            Vector4 v = GetDrawingDimensions(lPreserveAspect);
            Vector4 uv = overrideSprite != null ? DataUtility.GetOuterUV(overrideSprite) : Vector4.zero;

            bool hasUV = (uv.z - uv.x) != 0f && (uv.w - uv.y) != 0f;

            Color color = this.color;
            vh.Clear();

            Vector2 uv1 = hasUV
                ? new Vector2((uv.x - uv.x) / (uv.z - uv.x), (uv.y - uv.y) / (uv.w - uv.y))
                : Vector2.zero;
            vh.AddVert(new Vector3(v.x, v.y), color, new Vector2(uv.x, uv.y),
                uv1, s_DefaultNormal, s_DefaultTangent);

            uv1 = hasUV
                ? new Vector2((uv.x - uv.x) / (uv.z - uv.x), (uv.w - uv.y) / (uv.w - uv.y))
                : Vector2.zero;
            vh.AddVert(new Vector3(v.x, v.w), color, new Vector2(uv.x, uv.w),
                uv1, s_DefaultNormal, s_DefaultTangent);

            uv1 = hasUV
                ? new Vector2((uv.z - uv.x) / (uv.z - uv.x), (uv.w - uv.y) / (uv.w - uv.y))
                : Vector2.zero;
            vh.AddVert(new Vector3(v.z, v.w), color, new Vector2(uv.z, uv.w),
                uv1, s_DefaultNormal, s_DefaultTangent);

            uv1 = hasUV
                ? new Vector2((uv.z - uv.x) / (uv.z - uv.x), (uv.y - uv.y) / (uv.w - uv.y))
                : Vector2.zero;
            vh.AddVert(new Vector3(v.z, v.y), color, new Vector2(uv.z, uv.y),
                uv1, s_DefaultNormal, s_DefaultTangent);

            vh.AddTriangle(0, 1, 2);
            vh.AddTriangle(2, 3, 0);
        }

        // RVA: 0x13DF8FC
        private Vector4 GetDrawingDimensions(bool shouldPreserveAspect)
        {
            Sprite sprite = overrideSprite != null ? overrideSprite : m_Sprite;

            Vector4 padding = sprite == null ? Vector4.zero : DataUtility.GetPadding(sprite);
            Vector2 size = sprite == null
                ? Vector2.zero
                : new Vector2(sprite.rect.width, sprite.rect.height);

            Rect r = GetPixelAdjustedRect();
            int spriteW = Mathf.RoundToInt(size.x);
            int spriteH = Mathf.RoundToInt(size.y);

            Vector4 v = new Vector4(
                padding.x / spriteW,
                padding.y / spriteH,
                (spriteW - padding.z) / spriteW,
                (spriteH - padding.w) / spriteH);

            if (shouldPreserveAspect && size.sqrMagnitude > 0f)
            {
                PreserveSpriteAspectRatio(ref r, size);
            }

            v = new Vector4(
                r.x + r.width * v.x,
                r.y + r.height * v.y,
                r.x + r.width * v.z,
                r.y + r.height * v.w);

            return v;
        }

        // RVA: 0x13DFDB4
        public MaskableImage()
        {
        }

        // RVA: 0x13DFE1C
        static MaskableImage()
        {
        }
    }
}
