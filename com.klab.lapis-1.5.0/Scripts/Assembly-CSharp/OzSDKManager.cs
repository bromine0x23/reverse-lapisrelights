// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  OzSDKManager
//  来源：Il2CppDumper 元数据 + 反汇编（0x207ED80 起）
//  说明：本构建中 Android 桥接方法（_Platform*）为空实现，公共方法保留原逻辑。
// =============================================================================

using System;
using System.Diagnostics;
using UnityEngine;

/// <summary>平台 SDK 管理（登录、支付、分享、相册等）。</summary>
public class OzSDKManager : MonoBehaviour
{
    public static OzSDKManager Instance { get; set; }
    public OzExtendData extendData;
    private static AndroidJavaClass ajc_SDKCall;
    private Action<string> actionResult;
    public string uid;
    public string username;
    public string role;
    public string serverId;
    public int total_fee;
    public int game_money;
    public string out_trade_no;
    public string subject;
    public string body;
    public string extension_info;
    public string notify_url;
    public string order_sign;
    public string productId;



    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
    }

    private void Start()
    {
        extendData = new OzExtendData();
    }

    public string GetSdkAntiData()
    {
        return "";
    }

    private static void _PlatformInit()
    {
    }

    private static void _PlatformLogin()
    {
    }

    private static void _PlatformLogout()
    {
    }

    private static void _PlatformPay(string json)
    {
    }

    private static void _PlatformGetUserInfo()
    {
    }

    private static void _PlatformDoExtend(string json)
    {
    }

    private static void _CopyTextToClipboard(string str)
    {
    }

    private static void _Share(string base64Img, string platform)
    {
    }

    private static void _LoginArea(string areaId)
    {
    }

    private static void _ShowFloatIcon(bool isShow)
    {
    }

    private static void _KickOff()
    {
    }

    private static string _GetDeviceId()
    {
        return "";
    }

    private static string _GetSuperChannelId()
    {
        return "";
    }

    private static string _GetChannelId()
    {
        return "";
    }

    private static int _GetMemeryInfo()
    {
        return (int)Jackpot.Platform.GetFreeMemory() / 1024;
    }

    private static bool _HasPermissionForPhotoGallery()
    {
        return true;
    }

    private static bool _GetIsInit()
    {
        return false;
    }

    private static void _OnApplicationPause()
    {
    }

    private static void _OnApplicationFocus()
    {
    }

    private static void _OnApplicationQuit()
    {
    }

    public void Init()
    {
    }

    public void InitSDK(Action<string> _action)
    {
    }

    public void LoginSDK(Action<string> _action)
    {
        actionResult = _action;
    }

    public void LoginOutSDK(Action<string> _action)
    {
        actionResult = _action;
    }

    public void Pay(Action<string> _action)
    {
        string.Concat(new string[]
        {
            "{\"uid\":\"",
            uid,
            "\",\"productId\":\"",
            productId,
            "\",\"username\":\"",
            username,
            "\",\"role\":\"",
            role,
            "\",\"serverId\":\"",
            serverId,
            "\",\"total_fee\":\"",
            total_fee.ToString(),
            "\",\"game_money\":\"",
            game_money.ToString(),
            "\",\"out_trade_no\":\"",
            out_trade_no,
            "\",\"subject\":\"",
            subject,
            "\",\"body\":\"",
            body,
            "\",\"extension_info\":\"",
            extension_info,
            "\",\"notify_url\":\"",
            notify_url,
            "\",\"order_sign\":\"",
            order_sign,
            "\"}",
        });
        actionResult = _action;
    }

    public void Tp2UserLogin(int world_id, string open_id, string role_id)
    {
    }

    public void DoExtend(int _type, int _sType)
    {
        if (_type == 1)
        {
            switch (_sType)
            {
                case 1:
                    extendData.submitType = "createRole";
                    break;
                case 2:
                    extendData.submitType = "selectServer";
                    break;
                case 3:
                    extendData.submitType = "enterServer";
                    break;
                case 4:
                    extendData.submitType = "levelUp";
                    break;
                case 5:
                    extendData.submitType = "exitServer";
                    break;
            }

            JsonUtility.ToJson(extendData);
        }
        else
        {
            string.Concat("{'commondId':'", _type, "'}");
        }
    }

    public void CopyTextToClipboard(string str)
    {
    }

    private void OnPhotoSaved(string result)
    {
        PlayerPrefs.SetString("IOS_PHOTO_RESULT", result);
    }

    public bool SaveToAlbum(Texture2D texture2D, string fileName)
    {
        string filename = DateTime.Now.ToString("yyyy-MM-dd-HH-mm-ss-ff") + ".jpg";
        return NativeGallery.SaveImageToGallery(texture2D, "LapisGallery", filename, null) == NativeGallery.Permission.Granted;
    }

    public void ShareSDK(Action<string> _action, Texture2D texture2D, string platform)
    {
        actionResult = _action;
        Convert.ToBase64String(texture2D.EncodeToJPG());
    }

    private void OnGameSdkCallback(string str)
    {
        print("OnGameSdkCallback str is" + str);

        if (actionResult != null)
        {
            actionResult(str);
            actionResult = null;
        }
    }

    public void GetUserInfo(Action<string> _action)
    {
        actionResult = _action;
    }

    public void LoginArea(string areaId)
    {
    }

    public void ShowFloatIcon(bool isShow)
    {
    }

    public void KickOff()
    {
    }

    public string GetDeviceId()
    {
        return "";
    }

    public string GetAppId()
    {
        return "4774";
    }

    public string GetSuperChannelId()
    {
        return "";
    }

    public string GetChannelId()
    {
        return "";
    }

    public static int GetMemeryInfo()
    {
        return (int)Jackpot.Platform.GetFreeMemory() / 1024;
    }

    public bool GetIsInit()
    {
        return false;
    }

    private void OnApplicationPause(bool isPause)
    {
    }

    private void OnApplicationFocus(bool isFocus)
    {
    }

    private void OnApplicationQuit()
    {
    }

    public void GoToComment()
    {
    }

    public bool CheckNotifySetting()
    {
        return true;
    }

    public void GoToSetNotify()
    {
    }

    public void Quit()
    {
        Application.Quit();
    }

    public bool HasPermissionForPhotoGallery()
    {
        return UnityEngine.Android.Permission.HasUserAuthorizedPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    }

    private void OnDestroy()
    {
        Debug.Log("当前进程名：" + Process.GetCurrentProcess().ProcessName);
        Process.GetCurrentProcess().Kill();
    }

    public OzSDKManager()
    {
        uid = "";
        username = "";
        role = "";
        serverId = "3151";
        out_trade_no = "";
        body = "";
        notify_url = "";
        order_sign = "";
        productId = "";
    }

    static OzSDKManager()
    {
    }
}
