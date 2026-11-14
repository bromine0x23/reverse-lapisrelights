-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCommunication/PagePhoneMsgList.lua

require("UI/Page/PageCommunication/DlgCallChooseBg")

PagePhoneMsgList = class("PagePhoneMsgList", UIPanel)

function PagePhoneMsgList:ctor()
	self.UIPrefabPath = "UI/PageCommunication/PagePhoneMsgList"

	self:AddChildPanel(DlgExit(), {
		type = 2,
		title = _("eReturn_commc"),
		callback = self.OnBack,
		panel = self
	})
end

function PagePhoneMsgList:PreLoad()
	return
end

function PagePhoneMsgList:Purge()
	PagePhoneMsgList.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end
end

function PagePhoneMsgList:OnRegisterEvent()
	self:AddClick(self.ButtonChangeBg, self.OnClickedChangeBg)
	Event.Instance:Add("UpdatePhoneBg", self.UpdatePhoneBg, self)
end

function PagePhoneMsgList:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonChangeBg, self.OnClickedChangeBg)
	Event.Instance:Remove("UpdatePhoneBg", self.UpdatePhoneBg, self)
end

function PagePhoneMsgList:OnEnter(vParam)
	self.roleId = vParam
	self.ButtonChangeBg = self:GetChildGameObject("Button")
	self.CardIcon = self:GetChildComponent("Image", "RawImage")

	self:DealWithLocalization()

	self.infoRole = RoleMgr:GetRole(self.roleId)
end

function PagePhoneMsgList:UpdatePhoneBg(cardId)
	local infoRoleCard = RoleCardMgr:GetRoleCard(cardId)
end

function PagePhoneMsgList:OnBack()
	SceneMgr.LoadScene("MainStage", {
		from = 1
	})
end

function PagePhoneMsgList:DealWithLocalization()
	local Text = self:GetChildComponent("Button/Text", "Text")

	Text.text = _("UI_ChangeBg")
end

function PagePhoneMsgList:InitData()
	local listNew = PhoneCallManager:GetListTopic(self.roleId, 0)
	local listOld = PhoneCallManager:GetListTopic(self.roleId, 1)

	for i = 1, #listNew do
		local info = listNew[i]

		info.isNew = true
	end

	for i = 1, #listOld do
		local info = listOld[i]

		info.isNew = false

		table.insert(listNew, info)
	end

	self.listCall = listNew
end

function PagePhoneMsgList:InitScrollView()
	local ScrollArea = self:GetChildGameObject("Bg/ScrollArea")
	local content = self:GetChildComponent("Bg/ScrollArea/Content", "Transform")
	local count = #self.listCall

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.PrefabCell, CellPhoneMsg, self, false)

	self.UIScrollTool.ScrollView.verticalScrollbar = self:GetChildComponent("Bg/Scrollbar", "Scrollbar")
end

function PagePhoneMsgList:UpdateCell(item, index)
	local infoCall = self.listCall[index]

	item:UpdateData(infoCall)
end

function PagePhoneMsgList:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCell)
end

function PagePhoneMsgList:OnClickedCell(data)
	local go = data.pointerPress
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)

	if info.Item.Index == self.selectIndex then
		return
	end

	self.selectIndex = info.Item.Index
end

function PagePhoneMsgList:OnClickedChangeBg()
	UIMgr.AddPanel(DlgCallChooseBg(), self.roleId)
end
