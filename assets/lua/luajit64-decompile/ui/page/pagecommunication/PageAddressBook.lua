-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCommunication/PageAddressBook.lua

require("UI/Page/PageCommunication/CellAddress")

PageAddressBook = class("PageAddressBook", UIPanel)

function PageAddressBook:ctor()
	self.UIPrefabPath = "UI/PageCommunication/PageAddressBook"

	self:AddChildPanel(DlgExit(), {
		type = 2,
		title = _("eReturn_commc"),
		callback = self.OnBack,
		panel = self
	})
end

function PageAddressBook:PreLoad()
	self:LoadResAsync("UI/PageCommunication/CellAddress", "PrefabCell")
end

function PageAddressBook:Purge()
	PageAddressBook.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	ResourceMgr.Unload(self.PrefabCell)
end

function PageAddressBook:OnRegisterEvent()
	self:AddClick(self.Button1, self.OnClickedTag1)
	self:AddClick(self.Button2, self.OnClickedTag2)
	self:AddClick(self.ButtonModify, self.OnClickedModifyName)
	self:AddClick(self.ButtonCancel, self.OnClickedCancelName)
end

function PageAddressBook:OnUnRegisterEvent()
	self:RemoveClick(self.Button1, self.OnClickedTag1)
	self:RemoveClick(self.Button2, self.OnClickedTag2)
	self:RemoveClick(self.ButtonModify, self.OnClickedModifyName)
	self:RemoveClick(self.ButtonCancel, self.OnClickedCancelName)
end

function PageAddressBook:OnEnter()
	self.Button1 = self:GetChildGameObject("Panel/Button1")
	self.Button2 = self:GetChildGameObject("Panel/Button2")
	self.BtnBg1 = self:GetChildGameObject("Panel/Button1/Image")
	self.BtnBg2 = self:GetChildGameObject("Panel/Button2/Image")
	self.ButtonCancel = self:GetChildGameObject("ButtonCancel")
	self.ButtonModify = self:GetChildGameObject("ButtonModify")

	self:DealWithLocalization()
	self:InitData()
	self:InitScrollView()

	if self.tabIndex == 2 then
		self.BtnBg1:SetActive(false)
		self.BtnBg2:SetActive(true)

		PhoneCallManager.tagIndex = 0
	end

	local TextAuto

	TextAuto = self:GetChildComponent("Panel/Button1/Text/", "Text")
	TextAuto.text = Lang(5000060)
	TextAuto = self:GetChildComponent("Panel/Button2/Text/", "Text")
	TextAuto.text = Lang(5000061)
	TextAuto = self:GetChildComponent("ButtonCancel/Text/", "Text")
	TextAuto.text = Lang(5000062)
	TextAuto = self:GetChildComponent("ButtonModify/Text/", "Text")
	TextAuto.text = Lang(5000063)
end

function PageAddressBook:OnBack()
	UIMgr.PopPanel()
	PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_NEW_TOPIC, {})
	PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_NEW_PHONE_CALL, {})
end

function PageAddressBook:DealWithLocalization()
	return
end

function PageAddressBook:InitData()
	self.listRoleId = RoleMgr:GetAllRoleId()
	self.tabIndex = 1
	self.showModify = false

	if PhoneCallManager.tagIndex ~= 0 then
		self.tabIndex = PhoneCallManager.tagIndex
	end

	local hasTopic = false
	local hasCall = false

	for i = 1, #self.listRoleId do
		local roleId = self.listRoleId[i]
		local listTopic = TopicManager:GetListTopic(roleId, 0)
		local listCall = PhoneCallManager:GetListTopic(roleId, 0)

		if #listTopic > 0 then
			hasTopic = true
		end

		if #listCall > 0 then
			hasCall = true
		end
	end

	if hasTopic then
		-- block empty
	end

	if hasCall then
		-- block empty
	end
end

function PageAddressBook:InitScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")
	local count = #self.listRoleId

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.PrefabCell, CellAddress, self, false)

	self.UIScrollTool.ScrollView.verticalScrollbar = self:GetChildComponent("Panel/Scrollbar", "Scrollbar")
end

function PageAddressBook:UpdateCell(item, index)
	local roleId = self.listRoleId[index]

	item:UpdateData(roleId, self.tabIndex, self.showModify)
end

function PageAddressBook:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCell)
end

function PageAddressBook:OnClickedCell(data)
	local go = data.pointerPress
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)

	self.selectIndex = info.Item.Index

	if info.Item.topicNum == 0 and info.Item.topicGetNum == 0 then
		UIMgr.ShowMsg(_("Desc_NoCallMsg"))

		return
	end

	if self.showModify then
		return
	end

	if self.tabIndex == 1 then
		SceneMgr.LoadScene("Communication", info.Item.roleId)
	else
		SceneMgr.LoadScene("Call", {
			from = 1,
			roleId = info.Item.roleId
		})
	end
end

function PageAddressBook:OnClickedTag1()
	self.showModify = false

	self.ButtonCancel:SetActive(false)
	self.ButtonModify:SetActive(true)
	self.BtnBg1:SetActive(true)
	self.BtnBg2:SetActive(false)

	self.tabIndex = 1

	self.UIScrollTool:UpdateListData(self.listRoleId)

	PhoneCallManager.tagIndex = self.tabIndex
end

function PageAddressBook:OnClickedTag2()
	self.showModify = false

	self.ButtonCancel:SetActive(false)
	self.ButtonModify:SetActive(true)
	self.BtnBg1:SetActive(false)
	self.BtnBg2:SetActive(true)

	self.tabIndex = 2

	self.UIScrollTool:UpdateListData(self.listRoleId)

	PhoneCallManager.tagIndex = self.tabIndex
end

function PageAddressBook:OnClickedModifyName()
	self.showModify = true

	self.ButtonCancel:SetActive(true)
	self.ButtonModify:SetActive(false)
	self.UIScrollTool:UpdateListData(self.listRoleId)
end

function PageAddressBook:OnClickedCancelName()
	self.showModify = false

	self.ButtonCancel:SetActive(false)
	self.ButtonModify:SetActive(true)
	self.UIScrollTool:UpdateListData(self.listRoleId)
end
