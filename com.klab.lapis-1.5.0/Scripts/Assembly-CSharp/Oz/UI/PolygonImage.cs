// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.UI.PolygonImage
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + IDA 反汇编核对
//        ModifyMesh 仅处理非 6 索引（非矩形）精灵：
//        把精灵顶点按包围盒归一化后映射到 RectTransform 左下/右上角之间。
//        （反汇编 0x13E0FF4/0x13E0FF8 证实使用 fourCorners[0] 与 fourCorners[2]）
// =============================================================================

using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace Oz.UI
{
    public class PolygonImage : BaseMeshEffect
    {
        private static Vector3[] fourCorners;
        private static UIVertex vertice;
        private RectTransform rectTransform;
        private Image image;

        // RVA: 0x13E0C34
        protected PolygonImage()
        {
        }

        // RVA: 0x13E0C3C
        public override void ModifyMesh(VertexHelper vh)
        {
            if (!isActiveAndEnabled)
            {
                return;
            }

            if (rectTransform == null)
            {
                rectTransform = GetComponent<RectTransform>();
            }
            if (image == null)
            {
                image = GetComponent<Image>();
                if (image == null)
                {
                    return;
                }
            }

            if (image.m_Type != Image.Type.Simple)
            {
                return;
            }

            Sprite sprite = image.overrideSprite;
            if (sprite == null)
            {
                return;
            }

            if (sprite.triangles.Length == 6)
            {
                return;
            }
            if (vh.currentVertCount != 4)
            {
                return;
            }

            rectTransform.GetLocalCorners(fourCorners);

            Vector2[] spriteVertices = sprite.vertices;
            int count = spriteVertices.Length;
            List<UIVertex> verts = new List<UIVertex>(count);

            Vector2 center = sprite.bounds.center;
            Vector2 sizeInv = new Vector2(1f / sprite.bounds.size.x, 1f / sprite.bounds.size.y);

            for (int i = 0; i < count; i++)
            {
                float tx = (sprite.vertices[i].x - center.x) * sizeInv.x + 0.5f;
                float ty = (sprite.vertices[i].y - center.y) * sizeInv.y + 0.5f;

                vertice.position = new Vector2(
                    Mathf.Lerp(fourCorners[0].x, fourCorners[2].x, tx),
                    Mathf.Lerp(fourCorners[0].y, fourCorners[2].y, ty));
                vertice.color = image.color;
                vertice.uv0 = sprite.uv[i];
                verts.Add(vertice);
            }

            ushort[] spriteTriangles = sprite.triangles;
            List<int> indices = new List<int>(spriteTriangles.Length);
            for (int i = 0; i < spriteTriangles.Length; i++)
            {
                indices.Add(spriteTriangles[i]);
            }

            vh.Clear();
            vh.AddUIVertexStream(verts, indices);
        }

        // RVA: 0x13E1264
        static PolygonImage()
        {
            fourCorners = new Vector3[4];
        }
    }
}
