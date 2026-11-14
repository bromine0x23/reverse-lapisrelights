-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivityBossRaid/DlgTreasureBoxtPreview.lua

DlgTreasureBoxtPreview = class("DlgTreasureBoxtPreview", UIPanel)

function DlgTreasureBoxtPreview:ctor()
	self.UIPrefabPath = "UI/PanelActivityBossRaid/DlgTreasureBoxtPreview"
end

function DlgTreasureBoxtPreview:Purge()
	DlgTreasureBoxtPreview.base.Purge(self)

	if self.PrefabCellItem then
		ResourceMgr.Unload(self.PrefabCellItem)

		self.PrefabCellItem = nil
	end

	if self.listItem and #self.listItem > 0 then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end
end

function DlgTreasureBoxtPreview:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
end

function DlgTreasureBoxtPreview:OnEnter(vParam)
	if vParam and vParam.percent then
		self.percent = vParam.percent
	end

	self:Localization()

	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")

	for i = 1, 3 do
		self["Box" .. i] = {}
		self["Box" .. i].Name = self:GetChildComponent("BoxList/Box" .. i .. "/Name", "Text")
		self["Box" .. i].Icon = self:GetChildComponent("BoxList/Box" .. i .. "/ImageBG/Icon", "Image")
		self["Box" .. i].DropFrom = self:GetChildComponent("BoxList/Box" .. i .. "/DropFrom", "Text")
		self["Box" .. i].Tip = self:GetChildComponent("BoxList/Box" .. i .. "/Tip", "Text")
		self["Box" .. i].ItemList = self:GetChildGameObject("BoxList/Box" .. i .. "/ItemList")
		self["Box" .. i].Percent = self:GetChildComponent("BoxList/Box" .. i .. "/Percent", "Text")
	end

	self:InitData()
end

function DlgTreasureBoxtPreview:Localization(...)
	local TextAuto

	TextAuto = self:GetChildComponent("Panel/bg_title/Text", "Text")
	TextAuto.text = _("RaidBoss_BoxPreview")
end

function DlgTreasureBoxtPreview:OnRegisterEvent()
	self:AddClick(self.BtnClose, self.OnButtonExit)
end

function DlgTreasureBoxtPreview:OnUnRegisterEvent()
	self:RemoveClick(self.BtnClose, self.OnButtonExit)
end

function DlgTreasureBoxtPreview:OnButtonExit()
	self:Close()
end

function DlgTreasureBoxtPreview:InitData()
	self.infoBox = ActivityBossRaidMgr:GetBossRaidBox()
	self.listItem = {}

	local total = 0

	if self.percent then
		for i, v in ipairs(self.percent) do
			total = total + v[2]
		end
	end

	for i = 1, 3 do
		local infoItem = ItemManager:Get(self.infoBox[i].itemId)

		self["Box" .. i].Name.text, self["Box" .. i].Tip.text = infoItem:GetNameAndDesc()
		self["Box" .. i].DropFrom.text = string.format(_("RaidBoss_BoxDropLevel"), self.infoBox[i].BeginLevel, self.infoBox[i].EndLevel)

		if self.percent then
			self["Box" .. i].Percent.text = string.format(_("RaidBoss_Percent"), self.percent[i][2] / total * 100)
		else
			self["Box" .. i].Percent.text = ""
		end

		UIUtil.SetImageSprite(self["Box" .. i].Icon, infoItem.data.Icon, self)

		local RewardPack = require("luaData/RewardPack")
		local list = RewardPack[self.infoBox[i].rewardPacketId].PackItem

		for j = 1, #list do
			infoItem = ItemManager:GetValueItem(list[j][1], list[j][2])

			local item = CellItem(self.PrefabCellItem, self["Box" .. i].ItemList, self)

			item:Create()
			item:UpdateData(j, infoItem, false, true)
			GOUtil.SetTransformLocalScale(item.UIRootObject, 0.65)
			table.insert(self.listItem, item)
		end
	end
end
