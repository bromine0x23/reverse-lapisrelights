// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.UploadProgressChangedEventArgs
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
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
    public class UploadProgressChangedEventArgs : ProgressChangedEventArgs
    {
        private readonly HTTPProgress progress;
        private readonly long bytesReceived;
        private readonly long bytesSent;
        private readonly long totalBytesToReceive;
        private readonly long totalBytesToSend;
        public HTTPProgress Progress { get { return progress; } }
        public long BytesReceived { get { return bytesReceived; } }
        public long TotalBytesToReceive { get { return totalBytesToReceive; } }
        public long BytesSent { get { return bytesSent; } }
        public long TotalBytesToSend { get { return totalBytesToSend; } }
        // RVA: 0x1E9AA88
        public UploadProgressChangedEventArgs(HTTPProgress progress, object userState)
            : base((progress.TotalBytesSend > 0) ? ((int)(progress.BytesSent * 100 / progress.TotalBytesSend)) : 0, userState)
        {
            this.progress = progress;
            bytesSent = progress.BytesSent;
            totalBytesToSend = progress.TotalBytesSend;
        }

        // RVA: 0x1E9AF5C
        public UploadProgressChangedEventArgs(long bytesSent, long totalBytesToSend, object userState)
            : base((totalBytesToSend > 0) ? ((int)(bytesSent * 100 / totalBytesToSend)) : 0, userState)
        {
            this.bytesSent = bytesSent;
            this.totalBytesToSend = totalBytesToSend;
        }

        // RVA: 0x1E9AFC4
        public UploadProgressChangedEventArgs(long bytesReceived, long totalBytesToReceive, long bytesSent, long totalBytesToSend, int progressPercentage)
            : base(progressPercentage, null)
        {
            this.bytesReceived = bytesReceived;
            this.totalBytesToReceive = totalBytesToReceive;
            this.bytesSent = bytesSent;
            this.totalBytesToSend = totalBytesToSend;
        }

        // RVA: 0x1E9B018
        public UploadProgressChangedEventArgs(long bytesReceived, long totalBytesToReceive, long bytesSent, long totalBytesToSend, int progressPercentage, object userState)
            : base(progressPercentage, userState)
        {
            this.bytesReceived = bytesReceived;
            this.totalBytesToReceive = totalBytesToReceive;
            this.bytesSent = bytesSent;
            this.totalBytesToSend = totalBytesToSend;
        }

        // RVA: 0x1E9B06C
        public HTTPProgress get_Progress()
        {
            return progress;
        }

        // RVA: 0x1E9B074
        public long get_BytesReceived()
        {
            return bytesReceived;
        }

        // RVA: 0x1E9B07C
        public long get_TotalBytesToReceive()
        {
            return totalBytesToReceive;
        }

        // RVA: 0x1E9B084
        public long get_BytesSent()
        {
            return bytesSent;
        }

        // RVA: 0x1E9B08C
        public long get_TotalBytesToSend()
        {
            return totalBytesToSend;
        }
    }
}
