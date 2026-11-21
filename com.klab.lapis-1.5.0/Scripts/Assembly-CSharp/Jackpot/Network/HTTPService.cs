// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.HTTPService
//  来源：libil2cpp.so (ARM64) 反汇编 + Il2CppDumper 元数据
// =============================================================================

using System;
using System.Collections.Generic;
using UnityEngine;

namespace Jackpot.Network
{
    public class HTTPService : MonoBehaviour
    {
        private static readonly ILogger logger;
        private static HTTPService instance;
        private static object lockObject;
        private HTTPService.HTTPServiceImpl<HTTPWorker> clientImpl;
        private static bool isInitialized;

        public static HTTPService Instance
        {
            get
            {
                lock (lockObject)
                {
                    if (instance == null)
                    {
                        instance = new GameObject("HTTPService").AddComponent<HTTPService>();
                        instance.Setup();
                    }

                    return instance;
                }
            }
        }

        // RVA: 0x1E9556C
        public static HTTPService get_Instance()
        {
            return Instance;
        }

        // RVA: 0x1E96C48
        private void Update()
        {
            if (clientImpl != null)
            {
                clientImpl.ProcessRequestQueue();
            }
        }

        // RVA: 0x1E96CA0
        private void OnDestroy()
        {
            CancelAll();
            instance = null;
        }

        // RVA: 0x1E96D6C
        public static void Clean()
        {
            if (instance != null)
            {
                UnityEngine.Object.Destroy(instance.gameObject);
            }
        }

        // RVA: 0x1E95744
        public void Request(HTTPRequest request)
        {
            if (clientImpl != null)
            {
                clientImpl.Request(request);
                clientImpl.ProcessRequestQueue();
            }
        }

        // RVA: 0x1E95834
        public void Cancel(HTTPRequest request)
        {
            if (clientImpl != null)
            {
                clientImpl.Cancel(request);
            }
        }

        // RVA: 0x1E96D14
        public void CancelAll()
        {
            if (clientImpl != null)
            {
                clientImpl.CancelAll();
            }
        }

        // RVA: 0x1E96E80
        public int QueueCount()
        {
            return clientImpl.QueueCount();
        }

        // RVA: 0x1E96ED8
        public int ConnectedCount()
        {
            return clientImpl.ConnectedCount();
        }

        // RVA: 0x1E96F30
        public static HTTPService Initialize()
        {
            if (!MainThreadDispatcher.IsMainThread)
            {
                Exception ex = new Exception("Require a HTTPService create on main thread.");
                Logger.Get<HTTPService>().Fatal(ex, new object[0]);
                throw ex;
            }

            HTTPService result;
            lock (lockObject)
            {
                if (isInitialized)
                {
                    result = null;
                }
                else
                {
                    logger.Info("HTTPService Initialize.");
                    HTTPClient.Initialize();
                    isInitialized = true;
                    result = Instance;
                }
            }

            return result;
        }

        // RVA: 0x1E96AD4
        private void Setup()
        {
            UnityEngine.Object.DontDestroyOnLoad(base.gameObject);
            clientImpl = new HTTPServiceImpl<HTTPWorker>(CreateConnectionPool<HTTPWorker>(base.gameObject, Config.WebConnectionPoolSize));
        }

        // RVA: 0x19FFA5C (HTTPService.CreateConnectionPool<HTTPWorker>)
        private static List<T> CreateConnectionPool<T>(GameObject parent, int poolSize) where T : HTTPWorker
        {
            List<T> list = new List<T>(poolSize);
            if (poolSize <= 0)
            {
                logger.Error("HTTPWorker object was not created because pool size less than equal to 0.");
            }

            for (int i = 0; i < poolSize; i++)
            {
                GameObject gameObject = new GameObject(typeof(T).Name);
                UnityEngine.Object.DontDestroyOnLoad(gameObject);
                gameObject.transform.SetParent(parent.transform);
                T component = gameObject.AddComponent<T>();
                component.Initialize();
                list.Add(component);
            }

            return list;
        }

        // RVA: 0x1E97200
        public HTTPService()
        {
        }

        // RVA: 0x1E97208
        static HTTPService()
        {
            logger = Logger.Get<HTTPService>();
            lockObject = new object();
        }

        private class HTTPServiceImpl<T> where T : HTTPWorker
        {
            private List<T> connectionPool;
            private Queue<HTTPRequest> requestQueue;
            private Queue<T> usableConnections;

            // RVA: 0x221CDB4
            public HTTPServiceImpl(List<T> connectionPool)
            {
                this.connectionPool = connectionPool;
                requestQueue = new Queue<HTTPRequest>();
                usableConnections = new Queue<T>(connectionPool);
            }

            // RVA: 0x221CE84
            public void Request(HTTPRequest request)
            {
                requestQueue.Enqueue(request);
            }

            // RVA: 0x221CEEC
            public void Cancel(HTTPRequest request)
            {
                foreach (T connection in connectionPool)
                {
                    if (connection.Request == request)
                    {
                        connection.Disconnect();
                    }
                }
            }

            // RVA: 0x221D0A8
            public void CancelAll()
            {
                foreach (T connection in connectionPool)
                {
                    connection.Disconnect();
                }

                requestQueue.Clear();
            }

            // RVA: 0x221D26C
            public void ProcessRequestQueue()
            {
                if (requestQueue.Count == 0)
                {
                    return;
                }

                foreach (T connection in connectionPool)
                {
                    if (!connection.IsConnected)
                    {
                        usableConnections.Enqueue(connection);
                    }
                }

                foreach (HTTPRequest request in new Queue<HTTPRequest>(requestQueue))
                {
                    if (usableConnections.Count == 0)
                    {
                        break;
                    }

                    T connection = usableConnections.Dequeue();
                    if (!connection.IsConnected)
                    {
                        requestQueue.Dequeue();
                        connection.Connect(request);
                    }
                }
            }

            // RVA: 0x221D5A0 (QueueCount)
            public int QueueCount()
            {
                return requestQueue.Count;
            }

            // RVA: 0x221D6A8 (ConnectedCount)
            public int ConnectedCount()
            {
                int num = 0;
                foreach (T connection in connectionPool)
                {
                    if (connection.IsConnected)
                    {
                        num++;
                    }
                }

                return num;
            }
        }
    }
}
