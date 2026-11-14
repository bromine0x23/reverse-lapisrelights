-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionRaid/CellUnionBossRaidHarm.lua

require("UI/Item/UIItemBase")

CellUnionBossRaidHarm = class("CellUnionBossRaidHarm", UIItemBase)

function CellUnionBossRaidHarm:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellUnionBossRaidHarm:OnEnter(vParam)
	local g = self.UIRootObject
	local txt = GOUtil.FindChildComponent(g, "Data/Harm/Text", "Text")

	txt.text = _("Desc_AllDps")
	txt = GOUtil.FindChildComponent(g, "BtnTeam/Text", "Text")
	txt.text = _("Desc_LookTeam")
	self.GoRank1 = GOUtil.FindChildGameObject(g, "Data/TypeNum1")
	self.ImgRankNum = GOUtil.GetComponent(self.GoRank1, "Image")
	self.GoRank2 = GOUtil.FindChildGameObject(g, "Data/TypeNum2")
	self.TxtRankNum = GOUtil.FindChildComponent(self.GoRank2, "Text", "Text")
	self.ImgHeadIcon = GOUtil.FindChildComponent(g, "Data/Head/HeadIcon", "Image")
	self.ImgHeadFream = GOUtil.FindChildComponent(g, "Data/Head/HeadFream", "Image")
	self.TextLevel = GOUtil.FindChildComponent(g, "Data/Level/Text", "Text")
	self.TxtName = GOUtil.FindChildComponent(g, "Data/TxtName", "Text")
	self.TextValue = GOUtil.FindChildComponent(g, "Data/Harm/TextValue", "Text")
	self.BtnTeam = GOUtil.FindChildGameObject(g, "BtnTeam")

	self:AddClick(self.BtnTeam, self.OnClickedBtnTeam)
end

function CellUnionBossRaidHarm:OnLeave()
	UnloadAllImageSprite(self)
	self:RemoveClick(self.BtnTeam, self.OnClickedBtnTeam)
end

function CellUnionBossRaidHarm:UpdateData(data, isMine)
	local player

	if isMine and data == nil then
		player = PlayerInst.InfoPlayer.pb
		self.TextValue.text = 0

		GOUtil.SetActive(self.GoRank1, false)
		GOUtil.SetActive(self.GoRank2, true)

		self.TxtRankNum.text = Lang(40600009)
	else
		player = data.player
		self.TextValue.text = player.extras[1]

		if data.index <= 3 and not isMine then
			GOUtil.SetActive(self.GoRank1, true)
			GOUtil.SetActive(self.GoRank2, false)
			SetImageSprite(self.ImgRankNum, "UI/PanelUnionRaid/AtlasBossRaidHarmRank/IC_pvp_crown_0" .. data.index, self, true)
		else
			GOUtil.SetActive(self.GoRank1, false)
			GOUtil.SetActive(self.GoRank2, true)

			self.TxtRankNum.text = data.index
		end
	end

	self.player = player
	self.isMine = isMine
	self.TxtName.text = player.nickname

	local lv = LevelManager:GetPlayerLevel(player.levelExp)

	lv = Mathf.Min(lv, GetConfigArgInt("TeamMaxLevel"))
	self.TextLevel.text = string.format(_("Desc_Level"), lv)

	local infoItem = ItemManager:Get(player.headId)

	SetImageSprite(self.ImgHeadIcon, infoItem:GetIcon(), self)

	infoItem = ItemManager:Get(player.headFrame)

	SetImageSprite(self.ImgHeadFream, infoItem:GetIcon(), self)
end

function CellUnionBossRaidHarm:OnClickedBtnTeam()
	require("UI/Page/PageRank/DlgRank")
	DlgRank.RequestData(self.player, true)
end
