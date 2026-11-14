-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCommunication/DlgCallChooseBg.lua

require("UI/Dlg/Common/CellRoleCard")

DlgCallChooseBg = class("DlgCallChooseBg", UIPanel, true)

function DlgCallChooseBg:ctor()
	self.UIPrefabPath = "UI/PageCommunication/DlgChooseBg"
end

function DlgCallChooseBg:PreLoad()
	self:LoadResAsync("UI/Common/CellCard/CellRoleCard", "PrefabCell")
end

function DlgCallChooseBg:Purge()
	DlgCallChooseBg.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	ResourceMgr.Unload(self.PrefabCell)
end

function DlgCallChooseBg:OnRegisterEvent()
	self:AddClick(self.ButtonQuit, self.OnClickedQuit, PATH_SFX_UI_CANCEL)
end

function DlgCallChooseBg:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonQuit, self.OnClickedQuit)
end

function DlgCallChooseBg:OnEnter(roleId)
	self.roleId = roleId
	self.ButtonQuit = self:GetChildGameObject("Panel/Button")

	self:DealWithLocalization()
	self:InitData()
	self:InitScrollView()
end

function DlgCallChooseBg:DealWithLocalization()
	local Text = self:GetChildComponent("Panel/Title/Text", "Text")

	Text.text = _("DlgChooseBg_Title")
end

function DlgCallChooseBg:InitData()
	self.infoRole = RoleMgr:GetRole(self.roleId)
	self.listRoleCard = RoleCardMgr:GetRoleHoldCard(self.roleId)
	self.pickCardId = self.infoRole:GetPhoneBgId()
end

function DlgCallChooseBg:OnClickedQuit()
	self:Close()
end

function DlgCallChooseBg:InitScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")
	local count = #self.listRoleCard

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.PrefabCell, CellRoleCard, self, true)
end

function DlgCallChooseBg:UpdateCell(item, index)
	local data = {}

	data.cardId = self.listRoleCard[index].id

	local pickIdx = 0

	if self.pickCardId == data.cardId then
		pickIdx = index
	end

	data.pickIdx = pickIdx

	item:UpdateData(data)
end

function DlgCallChooseBg:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCell)
end

function DlgCallChooseBg:OnClickedCell(data)
	local go = data.pointerPress
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local roleCardId = self.listRoleCard[info.Item.Index].id

	if roleCardId == self.pickCardId then
		return
	end

	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			self.pickCardId = roleCardId
			self.infoRole.pb.phoneBgId = roleCardId

			self:OnClickedQuit()
			Event.Instance:Fire("UpdatePhoneBg", roleCardId)
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetManager:RequestModifyPhoneBg(self.roleId, roleCardId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end
