-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageBuff/PageBuff.lua

require("UI/Page/PageBuff/CellBuffInfo")

PageBuff = class("PageBuff", UIPanel)

function PageBuff:ctor()
	self.UIPrefabPath = "UI/PanelBuff/PanelBuff"
end

function PageBuff:OnRegisterEvent()
	Event.Instance:Add("ClosePageBuff", self.OnClickBtnClose, self)
end

function PageBuff:OnUnRegisterEvent()
	Event.Instance:Remove("ClosePageBuff", self.OnClickBtnClose, self)
end

function PageBuff:PreLoad(vParam)
	self:LoadResAsync("UI/PanelBuff/CellBuffInfo", "CellPrefab")
end

function PageBuff:Purge()
	PageBuff.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	ResourceMgr.Unload(self.CellPrefab)
end

function PageBuff:OnEnter(vParam)
	self.data = vParam.data
	self.type = vParam.type
	self.DownPanel = self:GetChildGameObject("DownPanel")
	self.LeftPanel = self:GetChildGameObject("LeftPanel")

	local clickBuffInfo = self:GetChildComponent("", "ClickBuffInfo")

	clickBuffInfo:SetFunction(self.CloseMySelf, self)

	self.UIRootObject.transform.position = Vector3(vParam.x, vParam.y, vParam.z)

	self:InitScrollViewPanel()
end

function PageBuff:CloseMySelf()
	self:Close()
end

function PageBuff:InitScrollViewPanel()
	local count = #self.data
	local panel, ScrollArea, content
	local position = self.UIRootObject.transform.localPosition

	if self.type == 1 then
		self.DownPanel:SetActive(false)

		panel = self:GetChildComponent("LeftPanel", "Transform")
		ScrollArea = self:GetChildGameObject("LeftPanel/ScrollArea")
		content = self:GetChildComponent("LeftPanel/ScrollArea/Content", "Transform")
		self.UIRootObject.transform.localPosition = Vector3(position.x - 20, position.y, 0)
	elseif self.type == 2 then
		self.LeftPanel:SetActive(false)

		panel = self:GetChildComponent("DownPanel", "Transform")
		ScrollArea = self:GetChildGameObject("DownPanel/ScrollArea")
		content = self:GetChildComponent("DownPanel/ScrollArea/Content", "Transform")
		self.UIRootObject.transform.localPosition = Vector3(position.x, position.y - 55, 0)
	end

	if count == 1 then
		panel.sizeDelta = Vector2(panel.sizeDelta.x, 210)
	elseif count == 2 then
		panel.sizeDelta = Vector2(panel.sizeDelta.x, 410)
	end

	local function AddClick(item)
		return
	end

	local function CellUpdate(item, index)
		item:UpdateData(self.data[index], self.type)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.CellPrefab, CellBuffInfo, self, false, AddClick, CellUpdate)
end

function PageBuff:OnClickBtnClose()
	self:Close()
end
