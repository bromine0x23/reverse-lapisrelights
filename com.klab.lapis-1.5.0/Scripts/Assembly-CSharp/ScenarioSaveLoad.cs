// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ScenarioSaveLoad
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  剧情存档：检查点收集、JSON + UTF8 + GZip + Base64 序列化，
//  以及按语言资源生成本地化存档文本。
// =============================================================================

using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using ICSharpCode.SharpZipLib.GZip;
using Oz.GameFramework.Runtime.Resource;
using UnityEngine;

public class ScenarioSaveLoad : Module
{
    public ScenarioSaveLoadData SaveData;

    // RVA: 0x1B86C00
    public override void RegistEvent()
    {
        base.RegistEvent();
        Kit.Events.NewCheckPoint.AddEventListener(AddCheckPoint);
    }

    // RVA: 0x1B86CC0
    public override void UnRegistEvent()
    {
        base.UnRegistEvent();
        Kit.Events.NewCheckPoint.RemoveEventListener(AddCheckPoint);
    }

    // RVA: 0x1B86D80
    public void AddCheckPoint(ScenarioSaveLoadData.CheckPoint checkPoint)
    {
        SaveData.CheckPoints.Add(checkPoint);
    }

    // RVA: 0x1B86DF0
    public virtual string Save()
    {
        byte[] bytes = Encoding.UTF8.GetBytes(JsonUtility.ToJson(SaveData));
        return Convert.ToBase64String(CompressBytes(bytes));
    }

    // RVA: 0x1B86F70
    public static ScenarioSaveLoadData LoadStr(string CompressJson)
    {
        byte[] bytes = DecompressBytes(Convert.FromBase64String(CompressJson));
        string json = Encoding.UTF8.GetString(bytes);
        return JsonUtility.FromJson<ScenarioSaveLoadData>(json);
    }

    // RVA: 0x1B87150
    public virtual bool Load(string Json)
    {
        SaveData = LoadStr(Json);

        if (SaveData.CheckPoints.Count > 0)
        {
            ScenarioSaveLoadData.CheckPoint checkPoint =
                SaveData.CheckPoints[SaveData.CheckPoints.Count - 1];

            Kit.Timelines.GoTo(checkPoint.Line, checkPoint.DialogID, true);
            return true;
        }

        return false;
    }

    // RVA: 0x1B8720C
    public virtual List<ScenarioSaveLoadStringData> GetSaveString(string Json)
    {
        SaveData = LoadStr(Json);

        List<ScenarioSaveLoadStringData> list = new List<ScenarioSaveLoadStringData>();
        ScenarioTrackRef timeline = null;

        foreach (ScenarioSaveLoadData.CheckPoint checkPoint in SaveData.CheckPoints)
        {
            if (timeline == null || timeline.director.name != checkPoint.Line)
            {
                timeline = Kit.Timelines.GetTimeline(checkPoint.Line);
            }

            Dialog dialog = timeline.GetDialog(checkPoint.DialogID);

            ScenarioSaveLoadStringData data = new ScenarioSaveLoadStringData();
            data.ActorId = checkPoint.Actorid;
            data.Text = dialog
                ? Kit.Language.Get(dialog.Textkey)
                : string.Empty;
            data.flag = checkPoint.flag;
            data.PrizeId = checkPoint.PrizeId;
            list.Add(data);
        }

        return list;
    }

    // RVA: 0x1B8751C
    public static List<ScenarioSaveLoadStringData> LoadLanguageGetSaveString(
        string Language,
        string Json)
    {
        AssetRef assetRef = ResourceManager.LoadSync(Language, typeof(TextAsset));
        ScenarioLanguage.LanguageData languageData =
            JsonUtility.FromJson<ScenarioLanguage.LanguageData>(
                ((TextAsset)assetRef.Asset).text);
        ResourceManager.Unload(assetRef);
        languageData.Init();

        ScenarioSaveLoadData saveData = LoadStr(Json);
        List<ScenarioSaveLoadStringData> list = new List<ScenarioSaveLoadStringData>();

        foreach (ScenarioSaveLoadData.CheckPoint checkPoint in saveData.CheckPoints)
        {
            ScenarioSaveLoadStringData data = new ScenarioSaveLoadStringData();
            data.ActorId = checkPoint.Actorid;
            data.Text = languageData.Get(checkPoint.TextKey);
            data.flag = checkPoint.flag;
            data.PrizeId = checkPoint.PrizeId;
            list.Add(data);
        }

        return list;
    }

    // RVA: 0x1B877CC
    public void ShowSave()
    {
        List<ScenarioSaveLoadStringData> saveString = GetSaveString(Save());
        foreach (ScenarioSaveLoadStringData item in saveString)
        {
        }
    }

    // RVA: 0x1B86E98
    public static byte[] CompressBytes(byte[] bytes)
    {
        MemoryStream memoryStream = new MemoryStream();
        GZipOutputStream gZipOutputStream = new GZipOutputStream(memoryStream);
        gZipOutputStream.Write(bytes, 0, bytes.Length);
        gZipOutputStream.Finish();
        return memoryStream.ToArray();
    }

    // RVA: 0x1B87014
    public static byte[] DecompressBytes(byte[] bytes)
    {
        MemoryStream inputStream = new MemoryStream(bytes);
        GZipInputStream gZipInputStream = new GZipInputStream(inputStream);

        MemoryStream memoryStream = new MemoryStream();
        byte[] array = new byte[4096];

        int num;
        while ((num = gZipInputStream.Read(array, 0, array.Length)) > 0)
        {
            memoryStream.Write(array, 0, num);
        }

        return memoryStream.ToArray();
    }

    // RVA: 0x1B878CC
    public ScenarioSaveLoad()
    {
        SaveData = new ScenarioSaveLoadData();
    }
}
