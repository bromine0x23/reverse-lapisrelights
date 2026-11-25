// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LightSettings
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  像素光照通过全局 Shader 关键字与全局量驱动。
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

public class LightSettings
{
    public const string PixelLight1 = "PIXELLIGHT1";
    public const string PixelLight2 = "PIXELLIGHT2";
    public const string PLight1_Pos = "P_Light1_pos";
    public const string PLight2_Pos = "P_Light2_pos";
    public const string PLight1_Col = "P_Light1_col";
    public const string PLight2_Col = "P_Light2_col";

    public bool UsePixelLights;
    public List<Light> PixelLights;

    // RVA: 0x1336030
    public void SetLight1()
    {
        Light light = PixelLights[0];
        if (!(light != null) || !light.enabled || !light.gameObject.activeInHierarchy)
        {
            Shader.DisableKeyword(PixelLight1);
            return;
        }

        Shader.EnableKeyword(PixelLight1);
        Shader.SetGlobalColor(PLight1_Col, light.color * light.intensity);
        if (light.type == LightType.Directional)
        {
            Vector3 forward = light.transform.forward;
            Shader.SetGlobalVector(PLight1_Pos, new Vector4(forward.x, forward.y, forward.z, -1f));
        }
        else
        {
            Vector3 position = light.transform.position;
            Shader.SetGlobalVector(PLight1_Pos, new Vector4(position.x, position.y, position.z, light.range));
        }
    }

    // RVA: 0x1336298
    public void SetLight2()
    {
        Light light = PixelLights[1];
        if (!(light != null) || !light.enabled || !light.gameObject.activeInHierarchy)
        {
            Shader.DisableKeyword(PixelLight2);
            return;
        }

        Shader.EnableKeyword(PixelLight2);
        Shader.SetGlobalColor(PLight2_Col, light.color * light.intensity);
        if (light.type == LightType.Directional)
        {
            Vector3 forward = light.transform.forward;
            Shader.SetGlobalVector(PLight2_Pos, new Vector4(forward.x, forward.y, forward.z, -1f));
        }
        else
        {
            Vector3 position = light.transform.position;
            Shader.SetGlobalVector(PLight2_Pos, new Vector4(position.x, position.y, position.z, light.range));
        }
    }

    // RVA: 0x1336504
    public void Clear()
    {
        Shader.DisableKeyword(PixelLight1);
        Shader.DisableKeyword(PixelLight2);
    }

    // RVA: 0x1336564
    public LightSettings()
    {
        PixelLights = new List<Light>();
    }
}
