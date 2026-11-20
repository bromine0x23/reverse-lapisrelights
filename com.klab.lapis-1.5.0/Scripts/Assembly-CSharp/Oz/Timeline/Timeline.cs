// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.Timeline
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Lua 侧对 PlayableDirector 的薄封装：属性直接转发，
//        Create 由 AssetRef 实例化预制体并补挂 PlayableDirector。
// =============================================================================

using System.Collections;
using LuaInterface;
using Oz.GameFramework.Runtime;
using Oz.GameFramework.Runtime.Coroutines;
using Oz.GameFramework.Runtime.Resource;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    public class Timeline
    {
        private AssetRef timelinePrefab;
        public PlayableDirector playableDirector;
        public GameObject gameObject { get; set; }
        public PlayState state { get; }
        public double duration { get; }
        public double time { get; set; }
        public double initialTime { get; set; }
        public DirectorUpdateMode timeUpdateMode { get; set; }
        public DirectorWrapMode extrapolationMode { get; set; }
        public bool playOnAwake { get; set; }

        // RVA: 0x13DD014
        public GameObject get_gameObject()
        {
            return gameObject;
        }

        // RVA: 0x13DD01C
        public void set_gameObject(GameObject value)
        {
            gameObject = value;
        }

        // RVA: 0x13DD024
        public PlayState get_state()
        {
            return playableDirector.state;
        }

        // RVA: 0x13DD040
        public double get_duration()
        {
            return playableDirector.duration;
        }

        // RVA: 0x13DD05C
        public double get_time()
        {
            return playableDirector.time;
        }

        // RVA: 0x13DD078
        public void set_time(double value)
        {
            playableDirector.time = value;
        }

        // RVA: 0x13DD094
        public double get_initialTime()
        {
            return playableDirector.initialTime;
        }

        // RVA: 0x13DD0B0
        public void set_initialTime(double value)
        {
            playableDirector.initialTime = value;
        }

        // RVA: 0x13DD0CC
        public DirectorUpdateMode get_timeUpdateMode()
        {
            return playableDirector.timeUpdateMode;
        }

        // RVA: 0x13DD0E8
        public void set_timeUpdateMode(DirectorUpdateMode value)
        {
            playableDirector.timeUpdateMode = value;
        }

        // RVA: 0x13DD104
        public DirectorWrapMode get_extrapolationMode()
        {
            return playableDirector.extrapolationMode;
        }

        // RVA: 0x13DD120
        public void set_extrapolationMode(DirectorWrapMode value)
        {
            playableDirector.extrapolationMode = value;
        }

        // RVA: 0x13DD13C
        public bool get_playOnAwake()
        {
            return playableDirector.playOnAwake;
        }

        // RVA: 0x13DD158
        public void set_playOnAwake(bool value)
        {
            playableDirector.playOnAwake = value;
        }

        // RVA: 0x13DD178
        public Timeline(AssetRef prefab)
        {
            timelinePrefab = prefab;
        }

        // RVA: 0x13DD1A4
        public void Create(
            DirectorUpdateMode updateMode = DirectorUpdateMode.GameTime,
            DirectorWrapMode wrapMode = DirectorWrapMode.None,
            float initialTime = 0f)
        {
            gameObject = Object.Instantiate(timelinePrefab.m_Object as GameObject);
            playableDirector = gameObject.AddMissingComponent<PlayableDirector>();
            playableDirector.timeUpdateMode = updateMode;
            playableDirector.extrapolationMode = wrapMode;
            playableDirector.initialTime = initialTime;
            playableDirector.playOnAwake = false;
        }

        // RVA: 0x13DD2C8
        public void Destroy()
        {
            if (gameObject != null)
            {
                Object.Destroy(gameObject);
                gameObject = null;
            }
        }

        // RVA: 0x13DD374
        public void ClearGenericBinding(Object key)
        {
            if (playableDirector != null)
            {
                playableDirector.ClearGenericBinding(key);
            }
        }

        // RVA: 0x13DD41C
        public void ClearReferenceValue(PropertyName id)
        {
            if (playableDirector != null)
            {
                playableDirector.ClearReferenceValue(id);
            }
        }

        // RVA: 0x13DD4C4
        public bool PlayableAssetVaild()
        {
            return playableDirector.playableAsset != null;
        }

        // RVA: 0x13DD54C
        public void DeferredEvaluate()
        {
            if (playableDirector != null)
            {
                playableDirector.DeferredEvaluate();
            }
        }

        // RVA: 0x13DD5E0
        public void Evaluate()
        {
            if (playableDirector != null)
            {
                playableDirector.Evaluate();
            }
        }

        // RVA: 0x13DD674
        public Object GetGenericBinding(Object key)
        {
            if (playableDirector == null)
            {
                return null;
            }
            return playableDirector.GetGenericBinding(key);
        }

        // RVA: 0x13DD720
        public Object GetReferenceValue(PropertyName id, out bool idValid)
        {
            if (playableDirector == null)
            {
                idValid = false;
                return null;
            }
            return playableDirector.GetReferenceValue(id, out idValid);
        }

        // RVA: 0x13DD7D8
        public void Pause()
        {
            if (playableDirector != null)
            {
                playableDirector.Pause();
            }
        }

        // RVA: 0x13DD86C
        public void Play()
        {
            if (playableDirector != null)
            {
                playableDirector.Play();
            }
        }

        // RVA: 0x13DD900
        public void Play(PlayableAsset asset, DirectorWrapMode mode)
        {
            if (playableDirector != null)
            {
                playableDirector.Play(asset, mode);
            }
        }

        // RVA: 0x13DD9B0
        public void Play(PlayableAsset asset)
        {
            if (playableDirector != null)
            {
                playableDirector.Play(asset);
            }
        }

        // RVA: 0x13DDA58
        public void RebuildGraph()
        {
            if (playableDirector != null)
            {
                playableDirector.RebuildGraph();
            }
        }

        // RVA: 0x13DDAEC
        public void Resume()
        {
            if (playableDirector != null)
            {
                playableDirector.Resume();
            }
        }

        // RVA: 0x13DDB80
        public void SetGenericBinding(Object key, Object value)
        {
            if (playableDirector != null)
            {
                playableDirector.SetGenericBinding(key, value);
            }
        }

        // RVA: 0x13DDC30
        public void SetReferenceValue(PropertyName id, Object value)
        {
            if (playableDirector != null)
            {
                playableDirector.SetReferenceValue(id, value);
            }
        }

        // RVA: 0x13DDCE0
        public void Stop()
        {
            if (playableDirector != null)
            {
                playableDirector.Stop();
            }
        }

        // RVA: 0x13DDD74
        public void Skip(LuaFunction function)
        {
            CoroutineManager.StartCoroutine(_Skip(function));
        }

        // RVA: 0x13DDD8C
        // 迭代器状态机为 Timeline.<_Skip>d__45（MoveNext 见 RVA 0x13DE0E8）
        private IEnumerator _Skip(LuaFunction function)
        {
            yield return new WaitForEndOfFrame();
            function.Call();
            function.Dispose();
        }

        // RVA: 0x13DDE28
        public void MuteTrackByName(string trackName, bool isMute)
        {
            if (playableDirector == null)
            {
                return;
            }

            TimelineAsset asset = playableDirector.playableAsset as TimelineAsset;
            if (asset == null)
            {
                return;
            }

            foreach (TrackAsset track in asset.GetOutputTracks())
            {
                if (track.name == trackName)
                {
                    track.muted = isMute;
                    return;
                }
            }
        }
    }
}
