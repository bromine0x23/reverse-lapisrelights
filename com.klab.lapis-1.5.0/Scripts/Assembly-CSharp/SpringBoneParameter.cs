// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  SpringBoneParameter
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using UnityEngine;

public class SpringBoneParameter
{
    public string nodeName;
    public string childPath;
    public string sibilingPath;
    public Vector3 boneAxis;
    public float radius;
    public float stiffnessForce;
    public float dragForce;
    public Vector3 externalForce;
    public Vector3 lowRotationLimit;
    public Vector3 highRotationLimit;
    public bool enableRotationLimit;
    public int[] colliderIDs;

    private const string BonePathPrefix = "Reference/Bip001/Route_Bone/";

    public int boneLevel
    {
        get
        {
            if (nodeName.IndexOf(BonePathPrefix) < 0)
            {
                return 1;
            }
            return nodeName.Replace(BonePathPrefix, "").Split('/').Length;
        }
    }

    // RVA: 0x1D6EFB0
    public SpringBoneParameter()
    {
    }
}
