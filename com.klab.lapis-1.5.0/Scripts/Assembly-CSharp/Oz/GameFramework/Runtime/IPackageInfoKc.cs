// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameFramework.Runtime.IPackageInfoKc
//  来源：Il2CppDumper 元数据（接口，无方法体）
// =============================================================================

namespace Oz.GameFramework.Runtime
{
    /// <summary>Kc 侧扩展的包信息接口（在 <see cref="IPackageInfo"/> 基础上增加版本与路径规则）。</summary>
    public interface IPackageInfoKc : IPackageInfo
    {
        new string Name { get; set; }
        int ID { get; set; }
        new ulong Size { get; set; }

        string Version { get; set; }
        new string Hash { get; set; }
        string ShortHash { get; set; }
        new int Flags { get; set; }

        string GetFilePathByLang(string lang);

        string GetFilePathByLangTSV(string lang);

        string GetDownloadPath(string version);
    }
}
