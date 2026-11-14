-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/pagePVP/PagePVPRecord.lua

require("UI/Page/pagePVP/CellPVPRecord")

local InfoPVP = require("Info/InfoPVP")

PagePVPRecord = class("PagePVPRecord", UIPanel)

function PagePVPRecord:ctor()
	self.UIPrefabPath = "UI/PanelPVP/PanelPVPRecord"
end

function PagePVPRecord:Purge()
	PagePVPRecord.base.Purge(self)

	if self.cellPreLoad then
		ResourceMgr.Unload(self.cellPreLoad)

		self.cellPreLoad = nil
	end

	self.UIScrollTool:Purge()
	self.uiTab:Dispose()
end

function PagePVPRecord:PreLoad()
	self.cellPreLoad = ResourceMgr.LoadSync("UI/PanelPVP/Cell")
end

function PagePVPRecord:OnRegisterEvent()
	self:AddClick(self.closeBtn, self.OnClickedBtnQuit)
	Event.Instance:Add("PVPAutoClose", self.OnClickedBtnQuit, self)
end

function PagePVPRecord:OnUnRegisterEvent()
	self:RemoveClick(self.closeBtn, self.OnClickedBtnQuit)
	Event.Instance:Remove("PVPAutoClose", self.OnClickedBtnQuit, self)
end

function PagePVPRecord:OnEnter(vParam)
	self.listData = {}
	self.closeBtn = self:GetChildGameObject("Panel/Close")
	self.tabGo = self:GetChildGameObject("Panel/Tab")
	self.Empty = self:GetChildGameObject("Panel/Empty")
	self.ListTitle = self:GetChildGameObject("Panel/ListTitle")
	self.uiTab = UITab(self.tabGo, 2, self.TabClick, self, 1)

	self:InitData()
	self:InitScroll()
	SetActiveFunc(self.Empty, #self.listData[self.uiTab.index] == 0)
	SetActiveFunc(self.ListTitle, #self.listData[self.uiTab.index] ~= 0)
	self:Localization()
end

function PagePVPRecord:Localization()
	local TextAuto

	TextAuto = self:GetChildComponent("Panel/Title/Text", "Text")
	TextAuto.text = _("Desc_Record")

	GOUtil.SetFont(TextAuto, UIMgr.JPFonts.YukiB)

	TextAuto = self:GetChildComponent("Panel/Tab/Btn1/Select/Text", "Text")
	TextAuto.text = _("Desc_Attack")
	TextAuto = self:GetChildComponent("Panel/Tab/Btn1/1/Text", "Text")
	TextAuto.text = _("Desc_Attack")
	TextAuto = self:GetChildComponent("Panel/Tab/Btn2/2/Text", "Text")
	TextAuto.text = _("Desc_Defense")
	TextAuto = self:GetChildComponent("Panel/Tab/Btn2/Select/Text", "Text")
	TextAuto.text = _("Desc_Defense")
	TextAuto = self:GetChildComponent("Panel/ListTitle/Text", "Text")
	TextAuto.text = _("Desc_Rank")
	TextAuto = self:GetChildComponent("Panel/ListTitle/Text (1)", "Text")
	TextAuto.text = _("Desc_PVPScore")
	TextAuto = self:GetChildComponent("Panel/ListTitle/Text (2)", "Text")
	TextAuto.text = _("Desc_Opponent")
	TextAuto = self:GetChildComponent("Panel/ListTitle/Text (3)", "Text")
	TextAuto.text = _("Desc_Time")
	TextAuto = self:GetChildComponent("Panel/Empty/Text", "Text")
	TextAuto.text = _("Desc_PVPRecordEmpty")
end

function PagePVPRecord:AddCellClick(item)
	return
end

function PagePVPRecord:InitData()
	self.listData[1] = InfoPVP:GetRecordData().attackingBattle
	self.listData[2] = InfoPVP:GetRecordData().defensiveBattle
end

function PagePVPRecord:InitScroll()
	local function ListUpdate(item, index)
		local data = {}

		data.type = self.uiTab.index
		data.battleinfo = self.listData[self.uiTab.index][index]

		item:UpdateData(data)
	end

	self.ScrollArea = self:GetChildGameObject("Panel/ScrollArea")

	local content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")
	local count = #self.listData[self.uiTab.index]

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.ScrollArea, content, count, self.cellPreLoad, CellPVPRecord, self, false, nil, ListUpdate)
end

function PagePVPRecord:TabClick()
	if self.uiTab.index == 1 then
		self.UIScrollTool:UpdateListDataKeepPos(self.listData[self.uiTab.index])
	else
		self.UIScrollTool:UpdateListDataKeepPos(self.listData[self.uiTab.index])
	end

	SetActiveFunc(self.Empty, #self.listData[self.uiTab.index] == 0)
	SetActiveFunc(self.ListTitle, #self.listData[self.uiTab.index] ~= 0)
end

function PagePVPRecord:OnClickedBtnQuit()
	self:Close()
end
