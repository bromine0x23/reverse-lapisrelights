-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageInteraction/DlgTouchAward.lua

require("UI/Page/PageInteraction/CellTouchAward")

DlgTouchAward = class("DlgTouchAward", UIPanel)

function DlgTouchAward:ctor()
	self.UIPrefabPath = "UI/PageInteraction/DlgTouchAward"
end

function DlgTouchAward:PreLoad()
	self.PrefabTouchAward = ResourceMgr.LoadSync("UI/PageInteraction/CellTouchAward")
end

function DlgTouchAward:OnEnter()
	self.ButtonExit = self:GetChildGameObject("Main/ButtonExit")
	self.listTouchIdolReward = GetConfigArgJson("TouchIdolReward")

	local Text = self:GetChildComponent("Main/bg_title/Text", "Text")

	Text.text = _("DlgTouchAward_title")

	self:InitScrollView()
end

function DlgTouchAward:Purge()
	DlgTouchAward.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end
end

function DlgTouchAward:OnRegisterEvent()
	self:AddClick(self.ButtonExit, self.OnClickCloseBtn)
end

function DlgTouchAward:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonExit, self.OnClickCloseBtn)
end

function DlgTouchAward:OnClickCloseBtn()
	self:Close()
end

function DlgTouchAward:InitScrollView()
	local ScrollArea = self:GetChildGameObject("Main/ScrollArea")
	local content = self:GetChildComponent("Main/ScrollArea/Content", "Transform")
	local count = #self.listTouchIdolReward

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.PrefabTouchAward, CellTouchAward, self, false)
end

function DlgTouchAward:UpdateCell(item, index)
	item.Index = index

	local info = self.listTouchIdolReward[index]

	item:UpdateData(info, index)
end

function DlgTouchAward:AddCellClick(item)
	return
end

function DlgTouchAward:OnClickedCell(data)
	return
end
