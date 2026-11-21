// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Social.GameService.GameServiceSharedData
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

namespace Jackpot.Social.GameService
{
    public class GameServiceSharedData
    {
        private AbstractGameService gameService;
        public BindableDictionary<string, object> Dictionary { get; private set; }
        internal ISavedGameMetadata MetaData { get; internal set; }
        public string Description { get; set; }
        public string Name { get; set; }








        // RVA: 0x16B5120
        private GameServiceSharedData(AbstractGameService gameService, string name)
        {
            this.gameService = gameService;
            Name = name;
                        Dictionary = new BindableDictionary<string, object>();
        }

        // RVA: 0x16B4440
        public static GameServiceSharedData GetDataFromXml(AbstractGameService gameService, string name, byte[] xmlData)
        {
                        GameServiceSharedData gameServiceSharedData = new GameServiceSharedData(gameService, name);
                        if (xmlData != null && xmlData.Length != 0)
                        {
                            XmlSerializeSupport.WriteFromXml(gameServiceSharedData.Dictionary, xmlData);
                        }

                        return gameServiceSharedData;
        }

        // RVA: 0x16B51A8
        public void Save(Action OnSuccess, Action<GameServiceError> OnError)
        {
                        gameService.Save(Name, this, OnSuccess, OnError);
        }

        // RVA: 0x16B51DC
        public byte[] GetXmlData()
        {
                        return XmlSerializeSupport.ToXml(Dictionary);
        }
    }
}
