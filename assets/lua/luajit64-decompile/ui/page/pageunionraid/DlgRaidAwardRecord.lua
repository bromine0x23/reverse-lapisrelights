-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionRaid/DlgRaidAwardRecord.lua

require("UI/Item/CellItem")

DlgRaidAwardRecord = class("DlgRaidAwardRecord", UIPanel)

function DlgRaidAwardRecord:ctor()
	self.UIPrefabPath = "UI/PanelUnionRaid/DlgRaidAwardRecord"
end

function DlgRaidAwardRecord:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem", GameObject)
end

function DlgRaidAwardRecord:Purge()
	self.base.Purge(self)
	self:OnLeave()
end

function DlgRaidAwardRecord:OnLeave()
	ResourceMgr.Unload(self.PrefabCellItem)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function DlgRaidAwardRecord:OnRegisterEvent()
	self:AddClick(self.BtnClose, self.OnClickedBtnClose)
end

function DlgRaidAwardRecord:OnUnRegisterEvent()
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
end

function DlgRaidAwardRecord:OnEnter(vParam)
	self.textTitle = self:GetChildComponent("Panel/Title/Text", "Text")
	self.textTitle.text = _("Raid_Award_Record")
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")
	self.type = vParam.type

	if vParam.raidId then
		self.raidId = vParam.raidId
	end

	self:UpdatePanel()
end

function DlgRaidAwardRecord:UpdatePanel()
	if not self.inited then
		self:InitScrollView()

		self.inited = true
	else
		self.UIScrollTool:UpdateListData(self.listAward)
	end
end

function DlgRaidAwardRecord:InitScrollView()
	self.listAward = {}

	if self.type == 1 then
		self.listAward = UnionRaidMgr.beingCommRaid.listAwardRecord
	else
		if self.raidId then
			local info = UnionRaidMgr:GetRaid(self.raidId)
			local award = infoRaid.data.Award

			for i = 1, #award do
				local info = ItemManager:GetValueItem(award[i][1], award[i][2])

				table.insert(self.listAward, info)
			end
		end

		self.textTitle.text = _("Desc_CombatReadiness_KillReward")
	end

	local scrollArea = self:GetChildGameObject("Panel/Group/ScrollArea")
	local content = self:GetChildComponent("Panel/Group/ScrollArea/Content", "RectTransform")
	local count = #self.listAward

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCell)
	end

	local function updateCallback(item, index)
		GOUtil.SetRectTransformSizeDelta(item.UIRootObject, 116, 116)

		local infoItem = self.listAward[index]

		item:UpdateWithNumType(infoItem)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellItem, CellItem, self, false, addCallback, updateCallback)
end

function DlgRaidAwardRecord:OnClickedBtnClose()
	self:Close()
end
