-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoResourceBanner.lua

local data = require("luaData/ResourceBanner")

InfoResourceBanner = class("InfoResourceBanner", InfoBase)

function InfoResourceBanner:ctor(id)
	self.id = id
	self.data = data[id]

	if self.id and self.id > 0 then
		ResourceBannerMgr.dict:Set(self.id, self)
	end
end

ResourceBannerMgr = {}
ResourceBannerMgr.dict = ResourceBannerMgr.dict or Record()

function ResourceBannerMgr:Get(id)
	local info = self.dict:GetValue(id)

	if info == nil then
		info = InfoResourceBanner(id)
	end

	if info.data == nil then
		return nil
	end

	return info
end

function ResourceBannerMgr:GetBannerByPage(pagename, extra)
	local bannerId = self.GetBannerID(pagename, extra)
	local info = self:Get(bannerId)

	if info == nil or info.data == nil then
		return nil
	end

	return info
end

function ResourceBannerMgr.GetBannerID(pagename, extra)
	if not pagename then
		return 1
	end

	if pagename == "PageMainStage" then
		return ResourceBannerType.MainStage
	elseif pagename == "PageChapter" then
		extra = ChapterMgr:GetBatteleTypeEnumID() == 0 and 1 or 2

		if extra == 1 then
			return ResourceBannerType.Chapter_Common
		elseif extra == 2 then
			return ResourceBannerType.Chapter_Diffcult
		end
	elseif pagename == "PageTower" then
		return ResourceBannerType.Tower
	elseif pagename == "PageTeamPass" then
		return ResourceBannerType.CombPass
	elseif pagename == "PageCardStage" then
		return ResourceBannerType.CardPass
	elseif pagename == "PageAssetStage" then
		return ResourceBannerType.AssetPass
	elseif pagename == "PageBosslive" then
		return ResourceBannerType.BossLive
	elseif pagename == "PageBossActivity" then
		return ResourceBannerType.TeaParty
	elseif pagename == "PageRoleCard" then
		return ResourceBannerType.CardDevelop
	elseif pagename == "PageRole" then
		return ResourceBannerType.RoleInfo
	elseif pagename == "PageEquip" then
		return ResourceBannerType.Equipment
	elseif pagename == "PageFittingroom" then
		return ResourceBannerType.Fitting
	elseif pagename == "PageWork" then
		return ResourceBannerType.Work
	elseif pagename == "PageUnion" then
		return ResourceBannerType.Union
	elseif pagename == "PageTask" then
		return ResourceBannerType.Task
	elseif pagename == "PagePVPMain" then
		return ResourceBannerType.PVP
	elseif pagename == "PageManualMain" then
		return ResourceBannerType.Manual
	elseif pagename == "PageCardShop" then
		return ResourceBannerType.CardPool
	elseif pagename == "PageTheme" then
		return ResourceBannerType.Theme
	elseif pagename == "PageShop" then
		return ResourceBannerType.Shop
	elseif pagename == "PageRank" then
		return ResourceBannerType.Rank
	elseif pagename == "PageUnionSkill" then
		return ResourceBannerType.UnionSKill
	elseif pagename == "PageUnionWish" then
		return ResourceBannerType.UnionWish
	elseif pagename == "PageUnionRaid" then
		return ResourceBannerType.UnionRaid
	elseif pagename == "PageUnionTask" then
		return ResourceBannerType.UnionTask
	elseif pagename == "PageBossActivityShop" then
		return ResourceBannerType.TeaPool
	elseif pagename == "PageBossActivityStage" then
		return ResourceBannerType.TeaCommon
	elseif pagename == "PageBossActivityStory" then
		return ResourceBannerType.TeaStory
	elseif pagename == "PageStage" then
		if extra then
			if extra == ChapterFromType.main then
				return ResourceBannerType.MainCommonStage
			elseif extra == ChapterFromType.mainhard then
				return ResourceBannerType.MainDiffcultStage
			elseif extra == ChapterFromType.comb then
				return ResourceBannerType.CombSatge
			end
		end
	elseif pagename == "PageTowerStage" then
		return ResourceBannerType.TowerStage
	elseif pagename == "PageEquipDevelop" then
		return ResourceBannerType.EquipDevelop
	elseif pagename == "PageInteraction" then
		return ResourceBannerType.Interaction
	elseif pagename == "PageUnionJoin" then
		return ResourceBannerType.JoinUnion
	elseif pagename == "PageUnionCreate" then
		return ResourceBannerType.CreateUnion
	elseif pagename == "PageUnionMember" then
		return ResourceBannerType.UnionMember
	elseif pagename == "PageOperationActiveNew" then
		return ResourceBannerType.Operation
	elseif pagename == "PageBondage" then
		return ResourceBannerType.Bondage
	elseif pagename == "PageImpression" then
		return ResourceBannerType.ManualMovie
	elseif pagename == "PagePictureTeam" then
		return ResourceBannerType.ManualNote
	elseif pagename == "PageStoryVideo" then
		return ResourceBannerType.ManualStory
	elseif pagename == "PageBag" then
		return ResourceBannerType.Bag
	elseif pagename == "PagePlayerInfo" then
		return ResourceBannerType.PlayerInfo
	end
end

ResourceBannerType = numEnumWithStartNum({
	"MainStage",
	"Chapter_Common",
	"Chapter_Diffcult",
	"Tower",
	"CombPass",
	"CardPass",
	"AssetPass",
	"BossLive",
	"TeaParty",
	"CardDevelop",
	"RoleInfo",
	"Equipment",
	"Fitting",
	"Work",
	"Union",
	"Task",
	"PVP",
	"Manual",
	"CardPool",
	"Theme",
	"Shop",
	"Rank",
	"UnionSKill",
	"UnionWish",
	"UnionRaid",
	"UnionTask",
	"TeaPool",
	"TeaCommon",
	"TeaStory",
	"BossRaid",
	"MainCommonStage",
	"MainDiffcultStage",
	"CombSatge",
	"TowerStage",
	"EquipDevelop",
	"Interaction",
	"JoinUnion",
	"CreateUnion",
	"UnionMember",
	"Operation",
	"Bondage",
	"ManualMovie",
	"ManualNote",
	"ManualStory",
	"Bag",
	"PlayerInfo"
}, 1)
