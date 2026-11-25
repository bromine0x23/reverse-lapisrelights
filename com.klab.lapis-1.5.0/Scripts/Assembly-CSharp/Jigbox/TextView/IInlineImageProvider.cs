// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.IInlineImageProvider / IInlineImageReceiver
//  来源：Il2CppDumper 元数据（接口，无实现）
// =============================================================================

using UnityEngine;

namespace Jigbox.TextView
{
    public interface IInlineImageProvider
    {
        void Request(string identifier, IInlineImageReceiver receiver);

        void Cancel(string identifier, IInlineImageReceiver receiver);
    }

    public interface IInlineImageReceiver
    {
        void Send(string identifier, Sprite sprite);

        void Send(string identifier, Texture texture);

        void SendError(string identifier, string errorMessage);
    }
}
