// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.Components.TextViewObserver
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（已还原成员）
//  说明：已还原 Instance（隐藏 GameObject 懒创建）与 AlreadyBatched。
//        Register/Unregister、字体重建与帧末观察等其余成员待还原。
// =============================================================================

using UnityEngine;

namespace Jigbox.Components
{
    public sealed class TextViewObserver : MonoBehaviour
    {
        private static TextViewObserver instance; // 0x0

        public static TextViewObserver Instance
        {
            // RVA: 0x1916EB4
            get
            {
                if (instance == null)
                {
                    GameObject gameObject = new GameObject("TextViewObserver");
                    gameObject.hideFlags = (HideFlags)0x35;
                    instance = gameObject.AddComponent<TextViewObserver>();
                }

                return instance;
            }
        }

        public bool AlreadyBatched { get; private set; } // 0x23

        // RVA: 0x191EBB0
        public TextViewObserver()
        {
        }
    }
}
