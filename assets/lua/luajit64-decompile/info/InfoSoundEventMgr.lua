-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoSoundEventMgr.lua

InfoSoundEventMgr = class("InfoSoundEventMgr", InfoBase)
InfoSoundEventMgr.enType = {
	VocalCommon9 = "VocalCommon9",
	VocalDispatch = "VocalDispatch",
	VocalCommon1 = "VocalCommon1",
	VocalCommon10 = "VocalCommon10",
	VocalCommon7 = "VocalCommon7",
	VocalCharaUp2 = "VocalCharaUp2",
	VocalCustomsclearance = "VocalCustomsclearance",
	VocalCommon2 = "VocalCommon2",
	VocalDrawCard = "VocalDrawCard",
	VocalBattlestation = "VocalBattlestation",
	VocalCommon4 = "VocalCommon4",
	VocalCustomsclearance2 = "VocalCustomsclearance2",
	VocalCustomsclearance3 = "VocalCustomsclearance3",
	VocalStart = "VocalStart",
	VocalCommon12 = "VocalCommon12",
	VocalCommon11 = "VocalCommon11",
	VocalCommon8 = "VocalCommon8",
	VocalCharaUp3 = "VocalCharaUp3",
	VocalCharaUp = "VocalCharaUp",
	VocalCommon6 = "VocalCommon6",
	VocalCommon5 = "VocalCommon5",
	VocalTeam = "VocalTeam",
	VocalCommon13 = "VocalCommon13",
	VocalCommon3 = "VocalCommon3"
}

local CDConfig = {
	{
		cd = 1.5,
		type = {
			InfoSoundEventMgr.enType.VocalCommon1,
			InfoSoundEventMgr.enType.VocalCommon2,
			InfoSoundEventMgr.enType.VocalCommon3,
			InfoSoundEventMgr.enType.VocalCommon4,
			InfoSoundEventMgr.enType.VocalCommon5,
			InfoSoundEventMgr.enType.VocalCommon6,
			InfoSoundEventMgr.enType.VocalCommon7,
			InfoSoundEventMgr.enType.VocalCommon8,
			InfoSoundEventMgr.enType.VocalCommon9,
			InfoSoundEventMgr.enType.VocalCommon10,
			InfoSoundEventMgr.enType.VocalCommon11,
			InfoSoundEventMgr.enType.VocalCommon12,
			InfoSoundEventMgr.enType.VocalCommon13,
			InfoSoundEventMgr.enType.VocalCharaUp,
			InfoSoundEventMgr.enType.VocalCharaUp2,
			InfoSoundEventMgr.enType.VocalCharaUp3,
			InfoSoundEventMgr.enType.VocalStart,
			InfoSoundEventMgr.enType.VocalCustomsclearance,
			InfoSoundEventMgr.enType.VocalDispatch,
			InfoSoundEventMgr.enType.VocalTeam,
			InfoSoundEventMgr.enType.VocalDrawCard,
			InfoSoundEventMgr.enType.VocalBattlestation,
			InfoSoundEventMgr.enType.VocalCustomsclearance3,
			InfoSoundEventMgr.enType.VocalCustomsclearance2
		}
	}
}

function InfoSoundEventMgr:ctor()
	self:Reset()

	for idx, config in ipairs(CDConfig) do
		for i, typeName in ipairs(config.type) do
			self.CD[typeName] = {}
			self.CD[typeName].now = 0
			self.CD[typeName].cd = config.cd
		end
	end

	self.LoadBankList = {}
end

function InfoSoundEventMgr:Cache()
	return
end

function InfoSoundEventMgr:Reset()
	self.CD = {}
end

function InfoSoundEventMgr:Purge()
	self:Reset()
end

function InfoSoundEventMgr:OnBack()
	self:Reset()

	for i = #self.LoadBankList, 1, -1 do
		if self.LoadBankList[i] then
			SoundMgr.UnloadBank(self.LoadBankList[i])
			table.remove(self.LoadBankList, i)
		end
	end
end

function InfoSoundEventMgr:UnloadBank(infoBank)
	if not infoBank then
		return
	end

	if infoBank == "" then
		return
	end

	for i = #self.LoadBankList, 1, -1 do
		if self.LoadBankList[i] and infoBank == self.LoadBankList[i] then
			SoundMgr.UnloadBank(self.LoadBankList[i])
			table.remove(self.LoadBankList, i)
		end
	end
end

function InfoSoundEventMgr:IsLoadBank(infoBank)
	if not infoBank then
		return false
	end

	if infoBank == "" then
		return false
	end

	if table.contains(self.LoadBankList, infoBank) then
		return true
	end

	return false
end

function InfoSoundEventMgr:LoadBank(infoBank)
	if not infoBank then
		return
	end

	if infoBank == "" then
		return
	end

	if not table.contains(self.LoadBankList, infoBank) then
		table.insert(self.LoadBankList, infoBank)
		SoundMgr.LoadBank(infoBank, false, false)
	end
end

function InfoSoundEventMgr:Play(enType, infoSound, isRoleCard)
	self:OnVocalEvent(enType, infoSound, isRoleCard)
end

function InfoSoundEventMgr:OnVocalEvent(enType, infoSound, isRoleCard)
	local soundEvent = infoSound

	if not soundEvent then
		return
	end

	if soundEvent == "" then
		return
	end

	if self:_IsCD(enType) == true then
		return
	end

	SoundMgr.PostEvent(soundEvent, UIMgr.UICamera.gameObject)
end

function InfoSoundEventMgr:_IsCD(enType)
	local val = false

	if self.CD[enType] then
		local now = os.clock()
		local last = self.CD[enType].now
		local t = now - last

		if t > self.CD[enType].cd then
			val = false
			self.CD[enType].now = now
		else
			val = true
		end
	else
		for idx, config in ipairs(CDConfig) do
			for i, typeName in ipairs(config.type) do
				local now = os.clock()

				self.CD[typeName] = {}
				self.CD[typeName].now = now
				self.CD[typeName].cd = config.cd
			end
		end
	end

	return val
end
