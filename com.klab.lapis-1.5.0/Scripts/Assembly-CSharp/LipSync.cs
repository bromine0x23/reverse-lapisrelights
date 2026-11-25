// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LipSync
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  CSV 行格式：<time>,<vowel>_<volume>；time 以 48kHz 采样位置计。
// =============================================================================

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Oz.ActorModule;
using Oz.GameFramework.Runtime.Resource;
using UnityEngine;

public class LipSync
{
    private static readonly string LipsyncCsvPath = "Story/ScenarioResources/Lipsync/{0}";

    private LipStateMachine _lipSyncMachine;
    private string _vowel;
    private float _volume;
    private float _volumeThreshold;
    private float _volumeMaxThreshold;
    private MouthBlend[] _mouthBlendList;
    private BlendWeight[] _mouthList;
    private SkinnedMeshRenderer _meshFace;
    public static readonly double PositionToSecond = 1.0 / 48000.0;
    private List<LipSync.LipsyncData> _lipsyncDataList;
    private int _indexData;
    private double _time;
    private bool _voiceDownload;
    private string _voiceName;

    public bool LipSyncEnabled { get; private set; }
    public float LipFullSize { get; internal set; }
    public float LipHalfSize { get; internal set; }

    // RVA: 0x13389D8
    public LipSync(SkinnedMeshRenderer mesh)
    {
        _volumeThreshold = 15f;
        _volumeMaxThreshold = 50f;
        _vowel = string.Empty;
        _lipsyncDataList = new List<LipsyncData>();
        _voiceName = string.Empty;
        LipFullSize = 100f;
        LipHalfSize = 50f;
        LipSyncEnabled = false;
        _meshFace = mesh;
        _lipSyncMachine = new LipStateMachine(this);
    }

    // RVA: 0x1338AC0
    public void SetBlendShapeList(BlendWeight[] openList, BlendWeight[] halfList, BlendWeight[] closeList)
    {
        _mouthList = new BlendWeight[openList.Length];
        for (int i = 0; i < openList.Length; i++)
        {
            _mouthList[i] = new BlendWeight(openList[i].Handle, 0f);
        }

        _mouthBlendList = new MouthBlend[openList.Length];
        for (int i = 0; i < openList.Length; i++)
        {
            _mouthBlendList[i].ShapeIndex = openList[i].Handle.ShapeIndex;
            _mouthBlendList[i].OpenWeight = openList[i].Weight;
            _mouthBlendList[i].HalfCloseWeight = halfList[i].Weight;
            _mouthBlendList[i].CloseWeight = closeList[i].Weight;
        }
    }

    // RVA: 0x1338D24
    public void OnStart()
    {
        LipSyncEnabled = true;
    }

    // RVA: 0x1338D30
    public void OnEnd()
    {
        _lipSyncMachine.Exit();
        LipSyncEnabled = false;
    }

    // RVA: 0x1338D60
    public void OnUpdate()
    {
        if (!LipSyncEnabled)
        {
            return;
        }

        if (_voiceDownload)
        {
            int position;
            ScenarioKit.Instance.Sounds.GetPosition(_voiceName, out position);
            _time = position * PositionToSecond;
        }
        else
        {
            _time += Time.deltaTime;
        }

        while (_indexData < _lipsyncDataList.Count && _time >= _lipsyncDataList[_indexData].time)
        {
            LipsyncData data = _lipsyncDataList[_indexData];
            _indexData++;
            OnLipMarker(data.vowel.ToString(), data.volume);
        }

        if (_indexData == _lipsyncDataList.Count)
        {
            OnEnd();
            return;
        }

        for (int i = 0; i < _mouthBlendList.Length; i++)
        {
            if (_mouthBlendList[i].ShapeIndex >= 0)
            {
                _meshFace.SetBlendShapeWeight(_mouthBlendList[i].ShapeIndex, _mouthList[i].Weight);
            }
        }
    }

    // RVA: 0x1338858
    public void SetLipSyncParameter(float value)
    {
        for (int i = 0; i < _mouthBlendList.Length; i++)
        {
            if (_mouthBlendList[i].ShapeIndex < 0)
            {
                continue;
            }

            float weight;
            if (LipHalfSize < value)
            {
                float t = (value - LipHalfSize) / LipHalfSize;
                weight = Mathf.Lerp(_mouthBlendList[i].HalfCloseWeight, _mouthBlendList[i].OpenWeight, t);
            }
            else
            {
                float t = value / LipHalfSize;
                weight = Mathf.Lerp(_mouthBlendList[i].CloseWeight, _mouthBlendList[i].HalfCloseWeight, t);
            }
            _mouthList[i].Weight = weight;
        }
    }

    // RVA: 0x1338FB8
    public void OnLipMarker(string vowel, float volume)
    {
        if (!LipSyncEnabled)
        {
            return;
        }

        _volume = volume;
        _vowel = vowel;

        if (_volumeThreshold > volume)
        {
            _lipSyncMachine.Exit();
            return;
        }
        if (vowel == Vowel.N.ToString())
        {
            _lipSyncMachine.Exit();
            return;
        }
        if (_volume < _volumeThreshold)
        {
            return;
        }

        _lipSyncMachine.MoveNext(_volume < _volumeMaxThreshold ? LipCommand.ToHalf : LipCommand.ToFull);
    }

    // RVA: 0x13390CC
    public void SetData(string voiceName, bool voiceDownload)
    {
        string path = string.Format(LipsyncCsvPath, voiceName.Replace("Play_", ""));
        AssetRef asset = ResourceManager.LoadSync(path, typeof(TextAsset));
        if (asset == null)
        {
            return;
        }

        TextAsset textAsset = asset.Asset as TextAsset;
        string csv = textAsset.text;

        StringReader reader = new StringReader(csv);
        List<string> lines = new List<string>();
        string line;
        while ((line = reader.ReadLine()) != null)
        {
            lines.Add(line);
        }
        ResourceManager.Unload(asset);

        _lipsyncDataList.Clear();
        _indexData = 0;
        _time = 0.0;

        string[][] rows = lines.Select(x => x.Split(',')).ToArray();
        for (int i = 0; i < rows.Length; i++)
        {
            string[] parts = rows[i];
            LipsyncData data = new LipsyncData();
            data.time = float.Parse(parts[0]) * (float)PositionToSecond;
            data.vowel = parts[1].Split('_')[0].ToCharArray()[0];
            data.volume = byte.Parse(parts[1].Split('_')[1]);
            _lipsyncDataList.Add(data);
        }

        _voiceDownload = voiceDownload;
        _voiceName = voiceName;
        LipSyncEnabled = true;
    }

    // RVA: 0x13395C4
    public void SetData(string voiceName)
    {
        if (ScenarioKit.Instance != null)
        {
            _indexData = 0;
            _time = 0.0;
            _lipsyncDataList = ScenarioKit.Instance.GetModule<ActorLipSync>().Get(voiceName);
            _voiceName = voiceName;
            if (_lipsyncDataList != null && _lipsyncDataList.Count > 0)
            {
                LipSyncEnabled = true;
            }
        }
    }

    // RVA: 0x13396A8
    public void SetData(string PlayVoice, List<LipSync.LipsyncData> datas)
    {
        _indexData = 0;
        _time = 0.0;
        _lipsyncDataList = datas;
        _voiceName = PlayVoice;
        if (datas != null && datas.Count > 0)
        {
            LipSyncEnabled = true;
        }
    }

    // RVA: 0x1339720
    static LipSync()
    {
    }

    [Serializable]
    public class LipsyncData
    {
        [SerializeField]
        public float time;
        [SerializeField]
        public char vowel;
        [SerializeField]
        public byte volume;

        // RVA: 0x13395BC
        public LipsyncData()
        {
        }
    }
}
