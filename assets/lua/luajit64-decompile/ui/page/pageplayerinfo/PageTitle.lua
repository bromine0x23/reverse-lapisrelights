-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePlayerInfo/PageTitle.lua

require("UI.Page.PagePlayerInfo.CellTitle")

PageTitle = class("PageTitle", UIPanel)

local ReputationData = require("luaData/Reputation")
local InfoTitle = require("Info/InfoTitle")

function PageTitle:ctor()
	self.UIPrefabPath = "UI/PanelPlayerInfo/PanelTitle"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_Title"),
		callback = self.OnBack,
		panel = self
	})
end

function PageTitle:PreLoad()
	self.PrefabCellTitle = ResourceMgr.LoadSync("UI/PanelPlayerInfo/CellTitle")
end

function PageTitle:Purge()
	PageTitle.base.Purge(self)

	if self.PrefabCellTitle then
		ResourceMgr.Unload(self.PrefabCellTitle)

		self.PrefabCellTitle = nil
	end

	self.UIScrollTool:Purge()
end

function PageTitle:OnBack()
	UIMgr.PopPanel()
end

function PageTitle:OnRegisterEvent()
	Event.Instance:Add(EventEnum.UpdatePlayerInfo, self.OnChangePlayerTitle, self)
end

function PageTitle:OnUnRegisterEvent()
	Event.Instance:Remove(EventEnum.UpdatePlayerInfo, self.OnChangePlayerTitle, self)
end

function PageTitle:OnChangePlayerTitle()
	self.UIScrollTool:UpdateListDataKeepPos(self.listData)
end

function PageTitle:OnEnter(vParam)
	self:OnLocalText()

	self.barFillGo = self:GetChildGameObject("Panel/Bar/Fill")

	GOUtil.SetRectTransformSizeDelta(self.barFillGo, InfoTitle:GetMedalsProgress() * 1145, 28)

	self.progText = self:GetChildComponent("Panel/Bar/ProgText", "Text")
	self.progText.text = #InfoTitle.medals .. "/" .. #InfoTitle.titleDataList

	self:InitData()
	self:InitScroll()
end

function PageTitle:InitData()
	self.listData = InfoTitle:GetTitleData()
end

function PageTitle:InitScroll()
	local function ListUpdate(item, index)
		local data = self.listData[index]

		item:UpdateData(data)
	end

	self.ScrollArea = self:GetChildGameObject("Panel/ScrollArea")

	local content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")
	local count = #self.listData

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.ScrollArea, content, count, self.PrefabCellTitle, CellTitle, self, false, nil, ListUpdate)
end

function PageTitle:AddCellClick(item)
	return
end

function PageTitle:OnLocalText()
	local Text = self:GetChildComponent("Panel/Bar/Text", "Text")

	Text.text = _("Title_Collection_Degree")
end
