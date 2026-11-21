// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Social.GameService.GameServiceError
//  来源：libil2cpp.so (ARM64) 反汇编 + Il2CppDumper 元数据
// =============================================================================

using System;

namespace Jackpot.Social.GameService
{
    public class GameServiceError
    {
        public string Message { get; private set; }

        public GameServiceErrorType Type { get; private set; }

        public bool IsFailedAuthentication
        {
            get { return Type == GameServiceErrorType.FailedAuthentication; }
        }

        public bool IsFailedReportAchievement
        {
            get { return Type == GameServiceErrorType.FailedReportAchievement; }
        }

        public bool IsFailedReportLeaderboard
        {
            get { return Type == GameServiceErrorType.FailedReportLeaderboard; }
        }

        public bool IsFailedLoadSharedData
        {
            get { return Type == GameServiceErrorType.FailedLoadSharedData; }
        }

        public bool IsFailedSaveSharedData
        {
            get { return Type == GameServiceErrorType.FailedSaveSharedData; }
        }

        public bool IsNotImplemented
        {
            get { return Type == GameServiceErrorType.NotImplemented; }
        }

        // RVA: 0x16B4E1C
        private GameServiceError(string message, GameServiceErrorType type)
        {
            Message = message;
            Type = type;
        }

        // RVA: 0x16B4DB4
        public static GameServiceError FailedAuthentication(string message)
        {
            return new GameServiceError(message, GameServiceErrorType.FailedAuthentication);
        }

        // RVA: 0x16B4E58
        public static GameServiceError FailedReportAchievement(string message)
        {
            return new GameServiceError(message, GameServiceErrorType.FailedReportAchievement);
        }

        // RVA: 0x16B40EC
        public static GameServiceError FailedReportLeaderboard(string message)
        {
            return new GameServiceError(message, GameServiceErrorType.FailedReportLeaderboard);
        }

        // RVA: 0x16B44E0
        public static GameServiceError FailedLoadSharedData(string message)
        {
            return new GameServiceError(message, GameServiceErrorType.FailedLoadSharedData);
        }

        // RVA: 0x16B4B64
        public static GameServiceError FailedSaveSharedData(string message)
        {
            return new GameServiceError(message, GameServiceErrorType.FailedSaveSharedData);
        }

        // RVA: 0x16B4EC4
        public static GameServiceError NotImplemented(string message)
        {
            return new GameServiceError(message, GameServiceErrorType.NotImplemented);
        }

        // RVA: 0x16B4F30
        public override string ToString()
        {
            if (Type == GameServiceErrorType.FailedAuthentication)
            {
                return string.Format("FailedAuthentication: {0}", Message);
            }

            if (Type == GameServiceErrorType.FailedReportAchievement)
            {
                return string.Format("IsFailedReportAchievement: {0}", Message);
            }

            return Message;
        }
    }
}
