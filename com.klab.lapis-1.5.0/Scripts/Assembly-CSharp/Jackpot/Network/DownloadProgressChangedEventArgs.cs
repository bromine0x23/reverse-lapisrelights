// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.DownloadProgressChangedEventArgs
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Jackpot.Network
{
    public class DownloadProgressChangedEventArgs : ProgressChangedEventArgs
    {
        private readonly HTTPProgress progress;
        private readonly long bytesReceived;
        private readonly long totalBytesToReceive;
        public HTTPProgress Progress { get { return progress; } }
        public long BytesReceived { get { return bytesReceived; } }
        public long TotalBytesToReceive { get { return totalBytesToReceive; } }
        // RVA: 0x1E90760
        public DownloadProgressChangedEventArgs(HTTPProgress progress, object userState)
            : base((progress.TotalBytesToReceive > 0) ? ((int)(progress.BytesReceived * 100 / progress.TotalBytesToReceive)) : 0, userState)
        {
            this.progress = progress;
            bytesReceived = progress.BytesReceived;
            totalBytesToReceive = progress.TotalBytesToReceive;
        }

        // RVA: 0x1E90C90
        public DownloadProgressChangedEventArgs(long bytesReceived, long totalBytesToReceive, object userState)
            : base((totalBytesToReceive > 0) ? ((int)(bytesReceived * 100 / totalBytesToReceive)) : 0, userState)
        {
            this.bytesReceived = bytesReceived;
            this.totalBytesToReceive = totalBytesToReceive;
        }

        // RVA: 0x1E90CF4
        public DownloadProgressChangedEventArgs(int progressPercentage, long bytesReceived, long totalBytesToReceive)
            : base(progressPercentage, null)
        {
            this.bytesReceived = bytesReceived;
            this.totalBytesToReceive = totalBytesToReceive;
        }

        // RVA: 0x1E90D30
        public DownloadProgressChangedEventArgs(int progressPercentage, object userToken, long bytesReceived, long totalBytesToReceive)
            : base(progressPercentage, userToken)
        {
            this.bytesReceived = bytesReceived;
            this.totalBytesToReceive = totalBytesToReceive;
        }

        // RVA: 0x1E90D68
        public HTTPProgress get_Progress()
        {
            return progress;
        }

        // RVA: 0x1E90D70
        public long get_BytesReceived()
        {
            return bytesReceived;
        }

        // RVA: 0x1E90D78
        public long get_TotalBytesToReceive()
        {
            return totalBytesToReceive;
        }
    }
}
