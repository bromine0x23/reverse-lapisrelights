// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.ContextQueue
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System.Collections.Generic;

namespace Jackpot
{
    public class ContextQueue<T>
    {
        private static ILogger logger;
        private IContextExecutor<T> executor;
        private Queue<T> queue;

        public ContextQueue(IContextExecutor<T> executor)
        {
            this.executor = executor;
            queue = new Queue<T>();
        }

        public void Enqueue(T context)
        {
            queue.Enqueue(context);
        }

        public void ProcessQueue()
        {
            if (queue.Count < 1)
            {
                return;
            }

            while (queue.Count > 0)
            {
                T context = queue.Dequeue();
                if (!executor.CanExecute(context))
                {
                    return;
                }

                executor.Execute(context);
            }
        }

        static ContextQueue()
        {
            logger = Logger.Get("Jackpot.ContextQueue");
        }
    }
}
