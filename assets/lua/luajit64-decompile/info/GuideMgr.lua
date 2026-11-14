-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/GuideMgr.lua

local GuideData = require("luaData/GuideShow")
local NewbieData = require("luaData/Newbie")

GuideMgr = {}

function GuideMgr.GetGuid(guideId)
	return GuideData[guideId]
end

function GuideMgr:GetGuidTextures(guideId)
	local tbl = {}
	local newbie = GuideData[guideId].UnlockShow

	for k, v in ipairs(GuideData[guideId].Pic) do
		if newbie[k] == nil or newbie[k] == 0 or TutorialMgr:IsOpenNoMsg(newbie[k]) then
			table.insert(tbl, v)
		end
	end

	return tbl, GuideData[guideId].Pic
end

function GuideMgr:GetGuidName(guideId)
	return GuideData[guideId].Name
end

function GuideMgr:GetGuidPopup(guideId)
	return GuideData[guideId].Popup
end

function GuideMgr:Record(guideId, preIndex, curIndex)
	local str = PlayerPrefs.GetString(PlayerInst.InfoPlayer.pid .. "HaveGuided", "")

	if preIndex ~= nil then
		str = string.gsub(str, "#" .. guideId .. "_" .. preIndex, "")
	end

	PlayerPrefs.SetString(PlayerInst.InfoPlayer.pid .. "HaveGuided", str .. "#" .. guideId .. "_" .. (curIndex or 0))
end

function GuideMgr:ResetRecord(newbieId)
	local guideId = 0
	local index = 0

	for k, v in pairsByKeys(GuideData) do
		guideId = k

		for i, j in ipairs(v.UnlockShow) do
			if j == newbieId then
				index = i

				break
			end
		end

		if index ~= 0 then
			break
		end
	end

	if index == 0 then
		return
	end

	local isGuided, idx = self:IsGuided(guideId)

	if isGuided and (idx == 0 or index < idx) then
		self:Record(guideId, idx, index)
	end
end

function GuideMgr:IsGuided(guideId)
	if self:GetGuidPopup(guideId) ~= 1 then
		return true, 0
	end

	local isHide = false
	local index = 0
	local str = PlayerPrefs.GetString(PlayerInst.InfoPlayer.pid .. "HaveGuided", "")
	local list = SplitByParam(str, "#")

	for i = 1, #list do
		local t = SplitByParam(list[i], "_")

		index = tonumber(t[2] or 0)

		if tonumber(t[1]) == guideId and index == 0 then
			isHide = true

			break
		end
	end

	return isHide, index
end

GuideFunctionType = numEnumWithStartNum({
	"CardAttribute",
	"CardLevel",
	"CardStar",
	"CardPetal",
	"Equip",
	"EquipAvatar",
	"EquipIntense",
	"EquipEnchant",
	"Union",
	"UnionWish",
	"UnionSkill",
	"UnionRaid",
	"Tower",
	"EventStage",
	"GiftBag",
	"PVP",
	"TalentTree",
	"ScenceSetting",
	"AssetPass",
	"ScenceChange",
	"TeaPartyStory",
	"BOSS",
	"Avatar",
	"BossLive",
	"BossRaid",
	"Work",
	"Bondage",
	"BattlePass",
	"JobIntroduce",
	"YellowBall",
	"BigMap",
	"Interaction",
	"SendGIft",
	"AR",
	"SetTeam",
	"PlayerInfo",
	"Friend",
	"Shop",
	"FightGuide1",
	"FightGuide2",
	"FightGuide3",
	"FightGuide4",
	"FightGuide5",
	"Stage",
	"CardPass",
	"Gvg",
	"EquipSynthetize",
	"TimeSpace"
}, 1)

function GuideMgr:InitListHelp()
	if self.listMain ~= nil and next(self.listMain) ~= nil then
		return self.listMain
	end

	self.listMain = {}

	for i = 1, #GuideData do
		local info = {}

		info.data = GuideData[i]
		self.listMain[info.data.HelpOrder] = self.listMain[info.data.HelpOrder] or {}

		if info.data.UnlockHelpShow == 0 then
			info.isLockValue = TenaryOp(self:IsLock(info.data.NewBieId), 1, 0)

			table.insert(self.listMain[info.data.HelpOrder], info)
		end
	end

	for i = 1, #self.listMain do
		local function func(a, b)
			if a.isLockValue == b.isLockValue then
				return a.data.NewBieId < b.data.NewBieId
			else
				return a.isLockValue < b.isLockValue
			end
		end

		table.sort(self.listMain[i], func)
	end

	return self.listMain
end

function GuideMgr:IsLock(NewBieId)
	local isLock = false
	local stageId = NewbieData[NewBieId].Stage

	if stageId ~= 0 then
		local infoStage = ChapterMgr:GetStage(stageId)

		isLock = not infoStage or not infoStage:IsPass()
	end

	return isLock
end
