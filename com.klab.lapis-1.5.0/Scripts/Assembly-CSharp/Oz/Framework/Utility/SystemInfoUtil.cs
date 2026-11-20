// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.Utility.SystemInfoUtil
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//  说明：本类绝大多数成员是对 UnityEngine.SystemInfo 的直接转发。
// =============================================================================

using UnityEngine;

namespace Oz.Framework.Utility
{
    /// <summary>设备/图形能力查询，转发 UnityEngine.SystemInfo。</summary>
    public static class SystemInfoUtil
    {
        // RVA: 0x2EED314
        public static bool supportsSparseTextures
        {
            get { return SystemInfo.supportsSparseTextures; }
        }

        // RVA: 0x2EED31C
        public static bool supports32bitsIndexBuffer
        {
            get { return SystemInfo.supports32bitsIndexBuffer; }
        }

        // RVA: 0x2EED324
        public static bool supportsHardwareQuadTopology
        {
            get { return SystemInfo.supportsHardwareQuadTopology; }
        }

        // RVA: 0x2EED32C
        public static bool supportsInstancing
        {
            get { return SystemInfo.supportsInstancing; }
        }

        // RVA: 0x2EED334
        public static bool supportsComputeShaders
        {
            get { return SystemInfo.supportsComputeShaders; }
        }

        // RVA: 0x2EED33C
        public static int copyTextureSupport
        {
            get { return SystemInfo.copyTextureSupport; }
        }

        // RVA: 0x2EED344
        public static bool supportsCubemapArrayTextures
        {
            get { return SystemInfo.supportsCubemapArrayTextures; }
        }

        // RVA: 0x2EED34C
        public static bool supports3DRenderTextures
        {
            get { return SystemInfo.supports3DRenderTextures; }
        }

        // RVA: 0x2EED354
        public static bool supports2DArrayTextures
        {
            get { return SystemInfo.supports2DArrayTextures; }
        }

        // RVA: 0x2EED35C
        public static bool supports3DTextures
        {
            get { return SystemInfo.supports3DTextures; }
        }

        // RVA: 0x2EED36C
        public static int supportedRenderTargetCount
        {
            get { return SystemInfo.supportedRenderTargetCount; }
        }

        // RVA: 0x2EED374
        public static bool supportsSeparatedRenderTargetsBlend
        {
            get { return SystemInfo.supportsSeparatedRenderTargetsBlend; }
        }

        // RVA: 0x2EED37C
        public static int supportsMultisampledTextures
        {
            get { return SystemInfo.supportsMultisampledTextures; }
        }

        // RVA: 0x2EED384
        public static bool supportsMultisampleAutoResolve
        {
            get { return SystemInfo.supportsMultisampleAutoResolve; }
        }

        // RVA: 0x2EED38C
        public static bool supportsMipStreaming
        {
            get { return SystemInfo.supportsMipStreaming; }
        }

        // RVA: 0x2EED394
        public static bool hasMipMaxLevel
        {
            get { return SystemInfo.hasMipMaxLevel; }
        }

        // RVA: 0x2EED39C
        public static bool minConstantBufferOffsetAlignment
        {
            get { return SystemInfo.minConstantBufferOffsetAlignment; }
        }

        // RVA: 0x2EED3A4
        public static bool supportsSetConstantBuffer
        {
            get { return SystemInfo.supportsSetConstantBuffer; }
        }

        // RVA: 0x2EED3AC
        public static bool supportsAsyncGPUReadback
        {
            get { return SystemInfo.supportsAsyncGPUReadback; }
        }

        // RVA: 0x2EED3B4
        public static bool supportsRawShadowDepthSampling
        {
            get { return SystemInfo.supportsRawShadowDepthSampling; }
        }

        // RVA: 0x2EED3BC
        public static bool supportsGraphicsFence
        {
            get { return SystemInfo.supportsGraphicsFence; }
        }

        // RVA: 0x2EED3C4
        public static int maxCubemapSize
        {
            get { return SystemInfo.maxCubemapSize; }
        }

        // RVA: 0x2EED3CC
        public static int maxTextureSize
        {
            get { return SystemInfo.maxTextureSize; }
        }

        // RVA: 0x2EED3D4
        public static int npotSupport
        {
            get { return SystemInfo.npotSupport; }
        }

        // RVA: 0x2EED3DC
        public static bool usesReversedZBuffer
        {
            get { return SystemInfo.usesReversedZBuffer; }
        }

        // RVA: 0x2EED3E4
        public static int supportsTextureWrapMirrorOnce
        {
            get { return SystemInfo.supportsTextureWrapMirrorOnce; }
        }

        // RVA: 0x2EED3EC
        public static bool supportsAsyncCompute
        {
            get { return SystemInfo.supportsAsyncCompute; }
        }

        // RVA: 0x2EED3F4
        public static bool supportsShadows
        {
            get { return SystemInfo.supportsShadows; }
        }

        // RVA: 0x2EED3FC
        public static bool hasDynamicUniformArrayIndexingInFragmentShaders
        {
            get { return SystemInfo.hasDynamicUniformArrayIndexingInFragmentShaders; }
        }

        // RVA: 0x2EED404
        public static bool hasHiddenSurfaceRemovalOnGPU
        {
            get { return SystemInfo.hasHiddenSurfaceRemovalOnGPU; }
        }

        // RVA: 0x2EED40C
        public static float batteryLevel
        {
            get { return SystemInfo.batteryLevel; }
        }

        // RVA: 0x2EED414
        public static int batteryStatus
        {
            get { return SystemInfo.batteryStatus; }
        }

        // RVA: 0x2EED41C
        public static string operatingSystem
        {
            get { return SystemInfo.operatingSystem; }
        }

        // RVA: 0x2EED424
        public static int operatingSystemFamily
        {
            get { return SystemInfo.operatingSystemFamily; }
        }

        // RVA: 0x2EED42C
        public static string processorType
        {
            get { return SystemInfo.processorType; }
        }

        // RVA: 0x2EED434
        public static int processorFrequency
        {
            get { return SystemInfo.processorFrequency; }
        }

        // RVA: 0x2EED43C
        public static int processorCount
        {
            get { return SystemInfo.processorCount; }
        }

        // RVA: 0x2EED444
        public static int systemMemorySize
        {
            get { return SystemInfo.systemMemorySize; }
        }

        // RVA: 0x2EED44C
        public static string deviceUniqueIdentifier
        {
            get { return SystemInfo.deviceUniqueIdentifier; }
        }

        // RVA: 0x2EED454
        public static string deviceName
        {
            get { return SystemInfo.deviceName; }
        }

        // RVA: 0x2EED45C
        public static bool supportsAccelerometer
        {
            get { return SystemInfo.supportsAccelerometer; }
        }

        // RVA: 0x2EED464
        public static bool supportsGyroscope
        {
            get { return SystemInfo.supportsGyroscope; }
        }

        // RVA: 0x2EED46C
        public static string deviceModel
        {
            get { return SystemInfo.deviceModel; }
        }

        // RVA: 0x2EED474
        public static bool supportsVibration
        {
            get { return SystemInfo.supportsVibration; }
        }

        // RVA: 0x2EED47C
        public static bool graphicsMultiThreaded
        {
            get { return SystemInfo.graphicsMultiThreaded; }
        }

        // RVA: 0x2EED484
        public static int graphicsShaderLevel
        {
            get { return SystemInfo.graphicsShaderLevel; }
        }

        // RVA: 0x2EED48C
        public static bool supportsLocationService
        {
            get { return SystemInfo.supportsLocationService; }
        }

        // RVA: 0x2EED494
        public static bool graphicsUVStartsAtTop
        {
            get { return SystemInfo.graphicsUVStartsAtTop; }
        }

        // RVA: 0x2EED49C
        public static int graphicsDeviceType
        {
            get { return SystemInfo.graphicsDeviceType; }
        }

        // RVA: 0x2EED4A4
        public static int graphicsDeviceVendorID
        {
            get { return SystemInfo.graphicsDeviceVendorID; }
        }

        // RVA: 0x2EED4AC
        public static string graphicsDeviceVersion
        {
            get { return SystemInfo.graphicsDeviceVersion; }
        }

        // RVA: 0x2EED4B4
        public static string graphicsDeviceVendor
        {
            get { return SystemInfo.graphicsDeviceVendor; }
        }

        // RVA: 0x2EED4BC
        public static string graphicsDeviceName
        {
            get { return SystemInfo.graphicsDeviceName; }
        }

        // RVA: 0x2EED4C4
        public static int graphicsMemorySize
        {
            get { return SystemInfo.graphicsMemorySize; }
        }

        // RVA: 0x2EED4CC
        public static int deviceType
        {
            get { return SystemInfo.deviceType; }
        }

        // RVA: 0x2EED4D4
        public static bool supportsAudio
        {
            get { return SystemInfo.supportsAudio; }
        }

        // RVA: 0x2EED4DC
        public static int graphicsDeviceID
        {
            get { return SystemInfo.graphicsDeviceID; }
        }

        // RVA: 0x2EED4E4
        public static bool IsFormatSupported(int format, int usage)
        {
            return SystemInfo.IsFormatSupported((UnityEngine.Experimental.Rendering.GraphicsFormat)format, (UnityEngine.Experimental.Rendering.FormatUsage)usage);
        }

        // RVA: 0x2EED4EC
        public static bool SupportsBlendingOnRenderTextureFormat(int format)
        {
            return SystemInfo.SupportsBlendingOnRenderTextureFormat((RenderTextureFormat)format);
        }

        // RVA: 0x2EED4F4
        public static bool SupportsRenderTextureFormat(int format)
        {
            return SystemInfo.SupportsRenderTextureFormat((RenderTextureFormat)format);
        }

        // RVA: 0x2EED4FC
        public static bool SupportsTextureFormat(int format)
        {
            return SystemInfo.SupportsTextureFormat((TextureFormat)format);
        }

        // RVA: 0x2EED504
        public static void GDeviceU3DInterfaceInit()
        {
            GDeviceU3DInterface.Init();
        }

        // RVA: 0x2EED564
        public static string GDeviceU3DInterfaceDeviceLevelResult()
        {
            return GDeviceU3DInterface.GetDeviceLevelResult();
        }

        // RVA: 0x2EED5C4
        public SystemInfoUtil()
        {
        }
    }
}