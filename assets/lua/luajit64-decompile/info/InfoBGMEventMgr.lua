-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoBGMEventMgr.lua

require("Const/Path")
require("UI/Page/PageBosslive/PageBosslive")

InfoBGMEventMgr = class("InfoBGMEventMgr", InfoBase)
InfoBGMEventMgr.Bank = {
	PageMainStage = "BGM_0036",
	PageOperationActiveNew = "BGM_0036",
	PageRole = "BGM_0036",
	PageTask = "BGM_0036",
	PageRoleCardList = "BGM_0036",
	PageAddressBookNew = "BGM_0049",
	PageInteraction = "BGM_0036",
	PagePictureAlbum = "BGM_0036",
	PageBag = "BGM_0036",
	PagePictureTask = "BGM_0036",
	PageWork = "BGM_0036",
	PageTalentTree = "BGM_0036",
	PageBosslive = "",
	PageFittingroom = PATH_BANK_FITROOM,
	PageCardShop = PATH_BANK_CARDSHOP,
	PageUnion = PATH_BANK_UNION,
	PageUnionRaid = PATH_BANK_UNIONRAID,
	PageUnionJoin = PATH_BANK_UNION,
	PageChapter = PATH_BANK_PageChapter,
	PagePlayerBirthday = PATH_BANK_ADDRESSBOOK,
	PageActivityBossRaid = PATH_BANK_PageChapter
}
InfoBGMEventMgr.BGM = {
	PageMainStage = "Play_BGM_0036",
	PageOperationActiveNew = "Play_BGM_0036",
	PageRole = "Play_BGM_0036",
	PageTask = "Play_BGM_0036",
	PageRoleCardList = "Play_BGM_0036",
	PageAddressBookNew = "Play_BGM_0049",
	PageInteraction = "Play_BGM_0036",
	PagePictureAlbum = "Play_BGM_0036",
	PageBag = "Play_BGM_0036",
	PagePictureTask = "Play_BGM_0036",
	PageWork = "Play_BGM_0036",
	PageTalentTree = "Play_BGM_0036",
	PageBosslive = "",
	PageFittingroom = PATH_BGM_FITROOM,
	PageCardShop = PATH_BGM_CARDSHOP,
	PageUnion = PATH_BGM_UNION,
	PageUnionRaid = PATH_BGM_UNIONRAID,
	PageUnionJoin = PATH_BGM_UNION,
	PageChapter = PATH_BGM_PageChapter,
	PagePlayerBirthday = PATH_BGM_ADDRESSBOOK,
	PageActivityBossRaid = PATH_BGM_PageChapter
}

function InfoBGMEventMgr:ctor()
	self:Reset()

	self.SceneMusic = {}
	self.SceneMusic.Bank = ""
	self.SceneMusic.BGM = ""
	self.SceneMusic.className = ""
end

function InfoBGMEventMgr:Cache()
	return
end

function InfoBGMEventMgr:Reset()
	self.SceneMusic = {}
end

function InfoBGMEventMgr:Clear()
	self.SceneMusic = {}
	self.SceneMusic.Bank = ""
	self.SceneMusic.BGM = ""
	self.SceneMusic.className = ""
end

function InfoBGMEventMgr:Purge()
	self:Reset()
end

function InfoBGMEventMgr:OnBack()
	self:Reset()
end

function InfoBGMEventMgr:LoadBank(className, isPlay)
	for k, v in pairs(InfoBGMEventMgr.Bank) do
		if tostring(k) == tostring(className) then
			if SceneBase.LastBank and SceneBase.LastBank == v then
				SoundMgr.DelayUnloadBank(SceneBase.LastBank, 1)

				SceneBase.LastBank = nil
			end

			if className == "PageBosslive" then
				InfoBGMEventMgr.Bank[k], InfoBGMEventMgr.BGM[k] = PageBosslive:GetBankBGM()
			end

			if self.SceneMusic.BGM ~= InfoBGMEventMgr.BGM[k] or self.SceneMusic.Bank ~= v or className == "PageRoleCardList" or className == "PageActivityBossRaid" or self.SceneMusic.className == "PageRoleCardList" or isPlay then
				if self.SceneMusic.Bank ~= "" and InfoBGMEventMgr.Bank[k] ~= self.SceneMusic.Bank then
					SoundMgr.DelayUnloadBank(self.SceneMusic.Bank, 1)
				end

				if InfoBGMEventMgr.Bank[k] ~= self.SceneMusic.Bank then
					SoundMgr.LoadBank(InfoBGMEventMgr.Bank[k], false, false)
				end

				if InfoBGMEventMgr.BGM[k] ~= self.SceneMusic.BGM then
					SoundMgr.PostEvent(InfoBGMEventMgr.BGM[k], UIMgr.UICamera.gameObject)
				end

				if self.SceneMusic.Bank == "BGM_0036" and className == "PageRoleCardList" then
					SoundMgr.PostEvent("Set_Upgrade", UIMgr.UICamera.gameObject)
				elseif InfoBGMEventMgr.BGM[k] == "Play_BGM_0036" then
					SoundMgr.PostEvent("Set_Home", UIMgr.UICamera.gameObject)
				end

				self.SceneMusic.Bank = InfoBGMEventMgr.Bank[k]
				self.SceneMusic.BGM = InfoBGMEventMgr.BGM[k]
				self.SceneMusic.className = className

				break
			end
		end
	end
end

function InfoBGMEventMgr:Play()
	self:OnVocalEvent()
end

function InfoBGMEventMgr:GetSceneMusic()
	return self.SceneMusic
end

function InfoBGMEventMgr:GetSceneMusic()
	return self.SceneMusic
end

function InfoBGMEventMgr:StopBGM()
	SoundMgr.Stop(self.SceneMusic.BGM)
end

function InfoBGMEventMgr:ReplayBGM()
	SoundMgr.PostEvent(self.SceneMusic.BGM, UIMgr.UICamera.gameObject)
end

function InfoBGMEventMgr:OnVocalEvent()
	SoundMgr.PostEvent(soundEvent, UIMgr.UICamera.gameObject)
end
