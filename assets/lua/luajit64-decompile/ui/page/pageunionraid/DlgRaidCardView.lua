-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionRaid/DlgRaidCardView.lua

require("UI/Page/PageUnionRaid/CellCardHp")

DlgRaidCardView = class("DlgRaidCardView", UIPanel)

function DlgRaidCardView:ctor()
	self.UIPrefabPath = "UI/PanelUnionRaid/DlgRaidCardView"
end

function DlgRaidCardView:PreLoad()
	self:LoadResAsync("UI/Common/CellCard/CellCardHp", "PrefabCellCardHp", GameObject)
end

function DlgRaidCardView:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellCardHp)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function DlgRaidCardView:OnRegisterEvent()
	self:AddClick(self.BtnClose, self.OnClickBtnClose)
	self:AddClick(self.BtnGotoReply, self.OnClickBtnGotoReply)
end

function DlgRaidCardView:OnUnRegisterEvent()
	self:RemoveClick(self.BtnClose, self.OnClickBtnClose)
	self:RemoveClick(self.BtnGotoReply, self.OnClickBtnGotoReply)
end

function DlgRaidCardView:OnEnter(vParam)
	local txt = self:GetChildComponent("Panel/Title/Text", "Text")

	txt.text = _("Desc_Raid_Card_View")
	txt = self:GetChildComponent("Panel/BtnHpReply/Text", "Text")
	txt.text = _("Raid_Item_Reply")
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")
	self.BtnGotoReply = self:GetChildGameObject("Panel/BtnHpReply")

	self:Init()
end

function DlgRaidCardView:Init()
	self.listCard = RoleCardMgr:GetAllHoldCard()

	local unused = {}

	for i = #self.listCard, 1, -1 do
		local card = self.listCard[i]

		if card.curCommRaidHpPer == 0 then
			table.insert(unused, card)
			table.remove(self.listCard, i)
		end
	end

	local function SortCard(a, b)
		local va = RoleCardMgr:GetCardFightValue(a)
		local vb = RoleCardMgr:GetCardFightValue(b)

		return vb < va
	end

	table.sort(self.listCard, SortCard)
	table.sort(unused, SortCard)

	for _, v in ipairs(unused) do
		table.insert(self.listCard, v)
	end

	local scrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "RectTransform")
	local count = #self.listCard

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCell)
	end

	local function updateCallback(item, index)
		local infoCard = self.listCard[index]
		local isShow = RoleCardMgr.ShowCardEffect(infoCard)

		item:UpdateData(infoCard, nil, nil, isShow)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellCardHp, CellCardHp, self, false, addCallback, updateCallback)
end

function DlgRaidCardView:OnClickBtnClose()
	self:Close()
end

function DlgRaidCardView:OnClickBtnGotoReply()
	self:Close()
	require("UI/Page/PageUnionRaid/DlgCardHpReply")
	UIMgr.AddPanel(DlgCardHpReply(), true)
end
