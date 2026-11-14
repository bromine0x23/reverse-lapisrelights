-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFittingroom/DlgNeedGet.lua

require("UI/Page/PageFittingroom/CellAvatarGotoBar")

DlgNeedGet = class("DlgNeedGet", UIPanel)

function DlgNeedGet:ctor()
	self.UIPrefabPath = "UI/PageFittingroom/DlgNeedGet"
	self.cb = nil
end

function DlgNeedGet:PreLoad()
	self:LoadResAsync("UI/PageFittingroom/CellAvatarGotoBar", "PrefabCell", GameObject)
end

function DlgNeedGet:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCell)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	self.page = nil
	self.cb = nil
end

function DlgNeedGet:OnRegisterEvent()
	self:AddClick(self.ButtonQuit, self.OnButtonQuit)
	self:AddClick(self.ButtonOK, self.OnButtonOK)
end

function DlgNeedGet:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonQuit, self.OnButtonQuit, PATH_SFX_UI_CANCEL)
	self:RemoveClick(self.ButtonOK, self.OnButtonOK, PATH_SFX_UI_CONFIRM)
end

function DlgNeedGet:OnEnter(vParam)
	self.list = vParam.list
	self.page = vParam.page
	self.cb = vParam.callback

	local hasNotBindBP = vParam.hasNotBindBP
	local txt = self:GetChildComponent("TweenRoot/Main/Title/Text", "Text")

	txt.text = _("Desc_Alert")
	txt = self:GetChildComponent("TweenRoot/Main/Button_OK/Label_OK", "Text")
	txt.text = _("UI_OK")

	if hasNotBindBP then
		txt = self:GetChildComponent("TweenRoot/Main/Text", "Text")

		GOUtil.SetActive(txt, true)

		txt.text = _("Desc_Avatar_Unload_Not_Bind")
	end

	self.ButtonQuit = self:GetChildGameObject("TweenRoot/Main/Button")
	self.ButtonOK = self:GetChildGameObject("TweenRoot/Main/Button_OK")

	self:InitScrollView()
end

function DlgNeedGet:InitScrollView()
	local ScrollArea = self:GetChildGameObject("TweenRoot/Main/ScrollArea")
	local content = self:GetChildComponent("TweenRoot/Main/ScrollArea/Content", "Transform")
	local count = #self.list

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.PrefabCell, CellAvatarGotoBar, self, false)
end

function DlgNeedGet:UpdateCell(item, index)
	item.Index = index

	item:UpdateData(self.list[index])

	item.GoToGet.name = index
end

function DlgNeedGet:AddCellClick(item)
	self:AddClick(item.GoToGet, self.OnClickedGoTo)
end

function DlgNeedGet:OnClickedGoTo(data)
	local index = tonumber(data.pointerPress.name)
	local avatarData = self.list[index]

	if avatarData then
		self.page:GotoFromWhere(avatarData.InfoAvatar, self.cb)
		self:Close()
	else
		UIMgr.ShowMsg("Error")
	end
end

function DlgNeedGet:OnButtonQuit()
	if self.cb then
		self.cb()

		self.cb = nil
	end

	self:Close()
end

function DlgNeedGet:OnButtonOK()
	if self.cb then
		self.cb()

		self.cb = nil
	end

	self:Close()
end
