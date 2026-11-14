-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCombatReadiness/DlgMayFall.lua

local BattleStageData = require("luaData/BattleStage")
local DropGroupData = require("luaData/DropGroup")

DlgMayFall = class("DlgMayFall", UIPanel)

function DlgMayFall:ctor()
	self.UIPrefabPath = "UI/PanelCombatReadiness/DlgMayFall"
end

function DlgMayFall:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
end

function DlgMayFall:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.UIPrefabCache)
	self:OnLeave()
end

function DlgMayFall:OnEnter(vParam)
	self.infoStage = vParam.infoStage
	self.btnClose = GOUtil.FindChildGameObject(self.UIRootObject, "Btnclose")
	self.leftNum = GOUtil.FindChildComponent(self.UIRootObject, "TextNum", "Text")
	self.leftSlider = GOUtil.FindChildComponent(self.UIRootObject, "sliderNum", "Image")
	self.scrollGold = GOUtil.FindChildGameObject(self.UIRootObject, "RewardScroll1")
	self.scrollSilver = GOUtil.FindChildGameObject(self.UIRootObject, "RewardScroll2")
	self.scrollCopper = GOUtil.FindChildGameObject(self.UIRootObject, "RewardScroll3")
	self.awardList = {}

	local Text = self:GetChildComponent("bg1/Text1", "Text")

	Text.text = "Extra宝箱"
	Text = self:GetChildComponent("bg1/Text2", "Text")
	Text.text = _("Desc_HitDeadWillGetReward")
	Text = self:GetChildComponent("bg1/tex1", "Text")
	Text.text = _("Desc_RewardBossTimes")
	Text = self:GetChildComponent("bg1/tex2", "Text")
	Text.text = _("Desc_RewardBossTimes")
	Text = self:GetChildComponent("bg1/bg1/Text", "Text")
	Text.text = _("Desc_CombatReadiness_DropList")
	Text = self:GetChildComponent("bg1/bg2/Text", "Text")
	Text.text = _("Desc_CombatReadiness_DropList")
	Text = self:GetChildComponent("bg1/bg2/Text", "Text")
	Text.text = _("Desc_CombatReadiness_DropList")

	self:InitAll()
end

function DlgMayFall:OnLeave()
	if self.awardList then
		for i = 1, #self.awardList do
			self.awardList[i]:OnLeave()
		end
	end

	self:OnUnRegisterEvent()
end

function DlgMayFall:OnRegisterEvent()
	self:AddClick(self.btnClose, self.OnClickClose)
end

function DlgMayFall:OnUnRegisterEvent()
	self:RemoveClick(self.btnClose, self.OnClickClose)
end

function DlgMayFall:OnClickClose()
	self:Close()
end

function DlgMayFall:InitAll()
	local cur = InfoGameInst:GetWhipAwardBoxNum()
	local max = GetConfigArgInt("StageWhipAwardBoxMaxNum")

	cur = max - cur
	self.leftNum.text = cur .. "/" .. max

	self:GetDropInfo()
	self:InitRewardScrollView(self.scrollCopper, self.dropInfo[1])
	self:InitRewardScrollView(self.scrollSilver, self.dropInfo[2])
	self:InitRewardScrollView(self.scrollGold, self.dropInfo[3])
end

function DlgMayFall:GetDropInfo()
	self.dropInfo = {
		{},
		{},
		{}
	}

	local stageDrop = BattleStageData[self.infoStage.data.BattleStageID].OverDropGroupList

	for i = 1, #stageDrop do
		for _, v in pairs(DropGroupData) do
			if v.GroupID == tonumber(stageDrop[i]) then
				table.insert(self.dropInfo[i], v.ItemID)
			end
		end
	end
end

function DlgMayFall:InitRewardScrollView(scrollRoot, itemList)
	local ScrollArea = scrollRoot
	local content = GOUtil.FindChildComponent(scrollRoot, "Content", "Transform")
	local count = #itemList

	local function ListUpdate(item, index)
		local id = itemList[index]
		local infoItem = ItemManager:Get(id)

		item:UpdateNoNumType(infoItem)
		table.insert(self.awardList, item)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.PrefabCellItem, CellItem, self, true, nil, ListUpdate)
end

function DlgMayFall:AddCellClick()
	return
end
