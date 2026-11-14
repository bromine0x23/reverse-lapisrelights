-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivityBossRaid/CellBossRaidDamage.lua

require("Info/InfoChapter")

CellBossRaidDamage = class("CellBossRaidDamage", UIItemBase)

local rankImagePathList = {
	"UI/PanelCombatReadiness/AtlasCombatReadiness/IC_crown_1st_01",
	"UI/PanelCombatReadiness/AtlasCombatReadiness/IC_crown_2nd_01",
	"UI/PanelCombatReadiness/AtlasCombatReadiness/IC_crown_3rd_01"
}

function CellBossRaidDamage:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellBossRaidDamage:PreLoad()
	return
end

function CellBossRaidDamage:Create(vParam)
	CellBossRaidDamage.base.Create(self, vParam)
end

function CellBossRaidDamage:OnLeave()
	return
end

function CellBossRaidDamage:OnEnter(vParam)
	local g = self.UIRootObject

	self:Init(vParam)
	self:UpdateData(vParam)
end

function CellBossRaidDamage:Init(vParam)
	local g = self.UIRootObject

	if vParam.type == 1 then
		self.OtherBg = GOUtil.FindChildGameObject(g, "OtherBg")
		self.SelfBg = GOUtil.FindChildGameObject(g, "SelfBg")
		self.PlayerName = GOUtil.FindChildComponent(g, "Info/Name", "Text")
		self.RankCount1 = GOUtil.FindChildComponent(g, "Info/Rank1", "Text")
		self.RankCount2 = GOUtil.FindChildComponent(g, "Info/Rank2", "Text")
		self.RankImage = GOUtil.FindChildComponent(g, "Info/RankImage", "Image")
		self.RankNormal = GOUtil.FindChildGameObject(g, "Info/RankNormal")
		self.Level = GOUtil.FindChildComponent(g, "Info/Level", "Text")
		self.HPBar = GOUtil.FindChildComponent(g, "Info/HPBar", "Slider")
		self.DamageCount = GOUtil.FindChildComponent(g, "Info/DamageNum", "Text")
		self.head = GOUtil.FindChildComponent(g, "Info/HeadIcon", "Image")
		self.headBox = GOUtil.FindChildComponent(g, "Info/HeadIcon/ImageBox", "Image")
		self.MyRank = self:GetChildGameObject("Info/MyRank")

		local TextAuto

		TextAuto = self:GetChildComponent("Info/DamageText", "Text")
		TextAuto.text = _("RaidBoss_Hurtcensus")
	else
		self.PlayerName = GOUtil.FindChildComponent(g, "Name", "Text")
		self.RankCount = GOUtil.FindChildComponent(g, "Count", "Text")
		self.Level = GOUtil.FindChildComponent(g, "Level", "Text")
		self.HPBar = GOUtil.FindChildComponent(g, "HPBar", "Slider")
		self.DamageCount = GOUtil.FindChildComponent(g, "DamageCount", "Text")
		self.head = GOUtil.FindChildComponent(g, "HeadIcon", "Image")
		self.headBox = GOUtil.FindChildComponent(g, "HeadIcon/ImageBox", "Image")

		local TextAuto

		TextAuto = self:GetChildComponent("Damage", "Text")
		TextAuto.text = _("RaidBoss_Hurtcensus")
	end
end

function CellBossRaidDamage:UpdateData(vParam)
	self.HPBar.value = vParam.damage.harm / vParam.bossHp
	self.DamageCount.text = vParam.damage.harm
	self.PlayerName.text = vParam.damage.nickname

	local infoItem = ItemManager:Get(vParam.damage.headId)

	UIUtil.SetImageSprite(self.head, infoItem:GetIcon(), self.page)

	local infoItem = ItemManager:Get(vParam.damage.headFrame)

	UIUtil.SetImageSprite(self.headBox, infoItem:GetIcon(), self.page)

	self.Level.text = string.format(_("Desc_Level"), vParam.damage.level)

	if vParam.type == 1 then
		if PlayerInst.InfoPlayer.pid == vParam.damage.playerId then
			self.OtherBg:SetActive(false)
			self.SelfBg:SetActive(true)
			self.MyRank:SetActive(true)
		else
			self.OtherBg:SetActive(true)
			self.SelfBg:SetActive(false)
		end

		if vParam.rank > 3 then
			SetActiveFunc(self.RankImage.gameObject, false)
			SetActiveFunc(self.RankNormal, true)

			self.RankCount2.text = vParam.rank
		else
			SetActiveFunc(self.RankImage.gameObject, true)
			SetActiveFunc(self.RankNormal, false)
			UIUtil.SetImageSprite(self.RankImage, rankImagePathList[vParam.rank], self.page)

			self.RankCount1.text = vParam.rank
		end
	else
		self.RankCount.text = vParam.rank
	end
end
