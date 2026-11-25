// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.IndividualInlineImageLayout
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（已还原成员）
//  已还原：字段、构造（0x1816F24，含内部 receiver 的字段布局）。
//  未还原：Load(0x1817034)、Cancel(0x18170FC)，以及 receiver 的三个回调实现。
//  说明：构造中创建的 receiver 在反汇编里是编译器生成类型，字段为
//        identifier(0x10)、pool(0x18)、onInitializeGameObject(0x20)、
//        onCompleteLayout(0x28)、onError(0x30)；此处按同一布局声明为 ImageReceiver。
// =============================================================================

using System;
using UnityEngine;
using UnityEngine.UI;

namespace Jigbox.TextView
{
    public class IndividualInlineImageLayout
    {
        public readonly string Identifier;              // 0x10
        private readonly IInlineImageProvider provider; // 0x18
        private readonly IInlineImageReceiver receiver; // 0x20

        // RVA: 0x1816F24
        public IndividualInlineImageLayout(
            IInlineImageProvider provider,
            string identifier,
            InlineImageGameObjectPool pool,
            Action<GameObject> onInitializeGameObject,
            Action onCompleteLayout,
            Action<string> onError)
        {
            Identifier = identifier;                                            // 0x1816F88 (0x10)
            this.provider = provider;                                           // 0x1816F88 (0x18)

            receiver = new ImageReceiver(                                       // 0x1816FB0-0x1816FBC
                identifier, pool, onInitializeGameObject, onCompleteLayout, onError);
        }

        // RVA: 0x1817034
        public void Load()
        {
            throw new NotImplementedException("IndividualInlineImageLayout.Load 尚未还原");
        }

        // RVA: 0x18170FC
        public void Cancel()
        {
            throw new NotImplementedException("IndividualInlineImageLayout.Cancel 尚未还原");
        }

        private sealed class ImageReceiver : IInlineImageReceiver
        {
            private readonly string identifier;               // 0x10
            private readonly InlineImageGameObjectPool pool;  // 0x18
            private readonly Action<GameObject> onInitializeGameObject; // 0x20
            private readonly Action onCompleteLayout;         // 0x28
            private readonly Action<string> onError;          // 0x30

            public ImageReceiver(
                string identifier,
                InlineImageGameObjectPool pool,
                Action<GameObject> onInitializeGameObject,
                Action onCompleteLayout,
                Action<string> onError)
            {
                this.identifier = identifier;
                this.pool = pool;
                this.onInitializeGameObject = onInitializeGameObject;
                this.onCompleteLayout = onCompleteLayout;
                this.onError = onError;
            }

            public void Send(string identifier, Sprite sprite)
            {
                throw new NotImplementedException("ImageReceiver.Send(Sprite) 尚未还原");
            }

            public void Send(string identifier, Texture texture)
            {
                throw new NotImplementedException("ImageReceiver.Send(Texture) 尚未还原");
            }

            public void SendError(string identifier, string errorMessage)
            {
                throw new NotImplementedException("ImageReceiver.SendError 尚未还原");
            }
        }
    }
}
