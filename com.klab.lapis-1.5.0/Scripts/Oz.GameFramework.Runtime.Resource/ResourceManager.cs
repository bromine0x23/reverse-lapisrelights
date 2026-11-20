// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Resource.dll
//  Oz.GameFramework.Runtime.Resource.ResourceManager
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace Oz.GameFramework.Runtime.Resource
{
    /// <summary>资源总控：同步/异步加载、请求分组、LRU 与卸载。</summary>
    public class ResourceManager : MonoBehaviour
    {
        private static uint maxLoadingRequest;
        private static Stack<RequestGroup> m_AcceptingRequestGroups;
        private static List<RequestGroup> m_Groups;
        private static List<int> m_GroupsToRemove;
        private static Dictionary<RequestInfo, Request> m_RequestsToLoad;
        private static Dictionary<int, Request> m_LoadingRequests;
        internal static AssetBundleLoader m_AssetBundleLoader;
        private static AssetsCacher m_AssetCacher;
        private static bool m_Use_LRU;

        private static ResourceManager Instance { get; set; }

        public static bool USE_LRU
        {
            // RVA: 0x2E6A434
            get { return m_Use_LRU; }
            // RVA: 0x2E6A49C
            set
            {
                m_Use_LRU = value;
                if (m_AssetCacher != null)
                {
                    m_AssetCacher.EnableLRUCache(value);
                }
            }
        }

        // RVA: 0x2E6A554
        public static int GetLRUCapacity()
        {
            return AssetsCacher.LRU_CAP;
        }

        /// <summary>开关 LRU 并设置容量；关闭时清空 LRU 缓存。</summary>
        // RVA: 0x2E6A5BC
        public static void SetLRUCacher(int _isEnable, int _capacity)
        {
            USE_LRU = _isEnable == 1;
            if (USE_LRU)
            {
                AssetsCacher.LRU_CAP = _capacity;
                if (AssetsCacher.LRUCache != null)
                {
                    AssetsCacher.LRUCache.SetCapacity(_capacity);
                }
            }
            else if (AssetsCacher.LRUCache != null)
            {
                AssetsCacher.LRUCache.Clear();
            }
        }

        // RVA: 0x2E6A70C
        private void Awake()
        {
            if (Instance == null)
            {
                Instance = this;
            }

            m_AcceptingRequestGroups = new Stack<RequestGroup>();
            m_Groups = new List<RequestGroup>();
            m_GroupsToRemove = new List<int>();
            m_RequestsToLoad = new Dictionary<RequestInfo, Request>();
            m_LoadingRequests = new Dictionary<int, Request>();
            m_AssetBundleLoader = new AssetBundleLoader();
            m_AssetCacher = new AssetsCacher();
        }

        // RVA: 0x2E6A9A4
        private void OnDestroy()
        {
            m_AssetCacher.Clear();
            m_AssetBundleLoader.Destroy();
            m_LoadingRequests.Clear();
            m_RequestsToLoad.Clear();
            m_GroupsToRemove.Clear();
            m_Groups.Clear();
            m_AcceptingRequestGroups.Clear();

            if (Instance != null)
            {
                Instance = null;
            }
        }

        /// <summary>
        /// 每帧调度：把待加载请求派发到空闲协程（受 maxLoadingRequest 限制），
        /// 清理待移除分组，倒序检查分组完成状态并回调。
        /// </summary>
        // RVA: 0x2E6AD6C
        private void Update()
        {
            while (m_RequestsToLoad.Count >= 1 && m_LoadingRequests.Count < maxLoadingRequest)
            {
                Request request = null;
                foreach (Request value in m_RequestsToLoad.Values)
                {
                    request = value;
                    break;
                }
                if (request == null)
                {
                    break;
                }

                m_RequestsToLoad.Remove(request.ResInfo);
                m_LoadingRequests.Add(request.Handle, request);
                request.coroutine = StartCoroutine(AsyncLoad(request));
            }

            if (m_GroupsToRemove.Count >= 1)
            {
                m_Groups.RemoveAll(group => m_GroupsToRemove.Contains(group.Handle));
                m_GroupsToRemove.Clear();
            }

            for (int i = m_Groups.Count - 1; i >= 0; i--)
            {
                RequestGroup group = m_Groups[i];
                if (group.IsComplete)
                {
                    m_Groups.RemoveAt(i);
                    group.OnComplete();
                }
                else if (group.IsEmpty)
                {
                    group.IsComplete = true;
                }
            }
        }

        // RVA: 0x2E6B1E8
        public static void Initialize(IAssetBundleManifest manifest)
        {
            if (manifest != null && m_AssetBundleLoader != null)
            {
                m_AssetBundleLoader.Initialize(manifest);
            }
        }

        // RVA: 0x2E6B270
        public static void SetMaxCoroutine(uint n)
        {
            maxLoadingRequest = Math.Max(n, 1u);
        }

        /// <summary>
        /// 同步加载：AB 模式下按资源路径解析包名/资源名并从包内加载（失败则回退），
        /// 否则或回退时使用 Resources.Load。
        /// </summary>
        // RVA: 0x2E6B314
        private static Object SyncLoad(string resourcesPath, Type type)
        {
            Object assetSync = null;

            if (AppConst.AssetBundleMode)
            {
                string bundleName;
                string assetName;
                if (PathUtility.ResourcePathToBundlePath(resourcesPath, out bundleName, out assetName)
                    && m_AssetBundleLoader.ExistAssetBundleName(bundleName))
                {
                    AssetBundleRef bundleRef = m_AssetBundleLoader.LoadAssetBundle(bundleName);
                    if (bundleRef != null && bundleRef.Bundle != null)
                    {
                        Type loadType = type != null ? type : typeof(GameObject);
                        assetSync = m_AssetBundleLoader.LoadAssetSync(bundleName, assetName, loadType);
                        if (assetSync == null)
                        {
                            m_AssetBundleLoader.UnloadAssetBundle(bundleName, false);
                        }
                    }
                }
            }

            if (assetSync == null)
            {
                return type != null
                    ? Resources.Load(resourcesPath, type)
                    : Resources.Load(resourcesPath);
            }
            return assetSync;
        }

        /// <summary>同步加载资源：先查缓存，未命中则加载并写入缓存，再取引用。</summary>
        // RVA: 0x2E6B64C
        public static AssetRef LoadSync(string resourcesPath, Type type)
        {
            RequestInfo info = new RequestInfo(resourcesPath, type);

            AssetRef cached = m_AssetCacher.GetFromCache(info);
            if (cached != null)
            {
                return cached;
            }

            Object asset = SyncLoad(resourcesPath, type);
            if (asset != null)
            {
                m_AssetCacher.PutIntoCache(info, asset, false);
                return m_AssetCacher.GetFromCache(info);
            }
            return null;
        }

        /// <summary>
        /// 异步加载：命中缓存直接回调；否则 AB 模式走 LoadAssetAsync、非 AB 模式走
        /// Resources.LoadAsync，完成后写入缓存并逐个回调请求节点，最后从加载中表移除。
        /// </summary>
        // RVA: 0x2E6B178（状态机 MoveNext: 0x2E6C418）
        private IEnumerator AsyncLoad(Request request)
        {
            RequestInfo assetInfo = request.ResInfo;

            if (m_AssetCacher.IsCached(assetInfo))
            {
                for (int i = 0; i < request.Nodes.Count; i++)
                {
                    request.Nodes[i].OnComplete(m_AssetCacher.GetFromCache(assetInfo));
                }
                request.Nodes.Clear();
                m_LoadingRequests.Remove(request.Handle);
                yield break;
            }

            Object asset = null;
            if (AppConst.AssetBundleMode)
            {
                string assetBundleName;
                string assetName;
                if (PathUtility.ResourcePathToBundlePath(assetInfo.path, out assetBundleName, out assetName))
                {
                    if (m_AssetBundleLoader.ExistAssetBundleName(assetBundleName))
                    {
                        AssetBundleRef bundleRef = m_AssetBundleLoader.LoadAssetBundle(assetBundleName);
                        if (bundleRef != null && bundleRef.Bundle != null)
                        {
                            AssetBundleRequest abr =
                                m_AssetBundleLoader.LoadAssetAsync(assetBundleName, assetName, assetInfo.type);
                            if (abr != null)
                            {
                                yield return abr;
                                asset = abr.asset;
                                if (asset == null)
                                {
                                    m_AssetBundleLoader.UnloadAssetBundle(assetBundleName, false);
                                }
                            }
                        }
                    }
                }
                else
                {
                    Debug.LogError("Invaild resource path: " + assetInfo.path);
                }
            }
            else if (!string.IsNullOrEmpty(assetInfo.path))
            {
                ResourceRequest rr = Resources.LoadAsync(assetInfo.path, assetInfo.type);
                yield return rr;
                asset = rr.asset;
            }

            if (asset != null)
            {
                m_AssetCacher.PutIntoCache(assetInfo, asset, true);
                for (int i = 0; i < request.Nodes.Count; i++)
                {
                    request.Nodes[i].OnComplete(m_AssetCacher.GetFromCache(assetInfo));
                }
                request.Nodes.Clear();
            }

            m_LoadingRequests.Remove(request.Handle);
        }

        // RVA: 0x2E6B8A0
        public static int Begin(UnityAction<int> onGroupComplete, UnityAction<int, float> onProgress)
        {
            RequestGroup group = new RequestGroup(onProgress, onGroupComplete);
            m_AcceptingRequestGroups.Push(group);
            return group.Handle;
        }

        /// <summary>结束当前分组：归并请求并转入待加载队列；栈空时打印不匹配错误。</summary>
        // RVA: 0x2E6B95C
        public static void End()
        {
            if (m_AcceptingRequestGroups.Count >= 1)
            {
                RequestGroup group = m_AcceptingRequestGroups.Pop();
                group.Prepare(m_RequestsToLoad);
                m_Groups.Add(group);
                return;
            }
            Debug.LogError("unexpect end() mismatch the begin()!");
        }

        /// <summary>
        /// 取消某请求组：从待加载/加载中队列的请求里移除该组节点，
        /// 空请求一并清理（加载中的还要停协程），最后登记到待移除分组表。
        /// </summary>
        // RVA: 0x2E6BA84
        public static void Cancel(int groupHandle)
        {
            List<Request> pending = new List<Request>(m_RequestsToLoad.Values);
            for (int i = 0; i < pending.Count; i++)
            {
                Request request = pending[i];
                request.RemoveNodes(groupHandle);
                if (request.IsEmpty)
                {
                    m_RequestsToLoad.Remove(request.ResInfo);
                }
            }

            List<Request> loading = new List<Request>(m_LoadingRequests.Values);
            for (int i = 0; i < loading.Count; i++)
            {
                Request request = loading[i];
                request.RemoveNodes(groupHandle);
                if (request.IsEmpty)
                {
                    Instance.StopCoroutine(request.coroutine);
                    m_LoadingRequests.Remove(request.Handle);
                }
            }

            m_GroupsToRemove.Add(groupHandle);
        }

        /// <summary>向当前分组提交请求，返回节点句柄；无分组或路径非法返回 -1。</summary>
        // RVA: 0x2E6BDD4
        public static int Request(string resourcesPath, Type type, UnityAction<int, int, AssetRef> onComplete)
        {
            if (m_AcceptingRequestGroups.Count < 1)
            {
                return -1;
            }
            if (string.IsNullOrEmpty(resourcesPath))
            {
                Debug.LogError("Null or empty resource path is not valid!");
                return -1;
            }

            RequestGroup group = m_AcceptingRequestGroups.Peek();
            RequestInfo info = new RequestInfo(resourcesPath, type);
            return group.AddRequestNode(info, onComplete);
        }

        // RVA: 0x2E6BF38
        public static AssetBundleLoader GetAssetBundleLoader()
        {
            return m_AssetBundleLoader;
        }

        /// <summary>释放一次引用；缓存真正移除且为 AB 模式时卸载对应 AssetBundle。</summary>
        // RVA: 0x2E6BFA0
        public static void Unload(AssetRef assetRef)
        {
            if (assetRef == null)
            {
                Debug.LogError("AssetRef is not exist");
                return;
            }

            if (!m_AssetCacher.RemoveFromCache(assetRef, false) || !AppConst.AssetBundleMode)
            {
                return;
            }

            string bundleName;
            string assetName;
            if (PathUtility.ResourcePathToBundlePath(assetRef.Info.path, out bundleName, out assetName))
            {
                m_AssetBundleLoader.UnloadAssetBundle(bundleName, true);
            }
        }

        /// <summary>遍历缓存快照逐个释放；未标记「全量卸载时保留」或强制时真正移除并卸载 AB。</summary>
        // RVA: 0x2E6C0CC
        public static void UnloadAll(bool forceUnload = false)
        {
            Dictionary<RequestInfo, AssetRef> cachedAssets = m_AssetCacher.GetAllCachedAssets();
            RequestInfo[] keys = new List<RequestInfo>(cachedAssets.Keys).ToArray();

            for (int i = 0; i < keys.Length; i++)
            {
                RequestInfo info = keys[i];
                if (!cachedAssets.ContainsKey(info))
                {
                    break;
                }

                AssetRef assetRef = cachedAssets[info];
                if (assetRef.DontDisposeOnUnloadAll && !forceUnload)
                {
                    continue;
                }

                if (!m_AssetCacher.RemoveFromCache(assetRef, true) || !AppConst.AssetBundleMode)
                {
                    continue;
                }

                string bundleName;
                string assetName;
                if (PathUtility.ResourcePathToBundlePath(info.path, out bundleName, out assetName))
                {
                    m_AssetBundleLoader.UnloadAssetBundle(bundleName, true);
                }
            }
        }

        // RVA: 0x2E6C2BC
        public ResourceManager()
        {
        }

        // RVA: 0x2E6C2C4
        static ResourceManager()
        {
            maxLoadingRequest = 4;
            m_Use_LRU = false;
        }
    }
}
