-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePlayerInfo/DlgSetRole.lua

require("UI/Page/PagePlayerInfo/CellTeamRole")

DlgSetRole = class("DlgSetRole", UIPanel)

function DlgSetRole:ctor()
	DlgSetRole.base.ctor(self, "UI/PanelPlayerInfo/DlgSetRole")
end

function DlgSetRole:PreLoad()
	self:LoadResAsync("UI/PanelPlayerInfo/CellTeamRole", "PrefabCell", GameObject)
end

function DlgSetRole:Purge()
	DlgSetRole.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.PrefabCell ~= nil then
		ResourceMgr.Unload(self.PrefabCell)

		self.PrefabCell = nil
	end
end

function DlgSetRole:OnRegisterEvent()
	self:AddClick(self.ButtonConfirm, self.OnClickBtnConfirm)
	self:AddClick(self.ButtonQuit, self.OnClickBtnQuit, PATH_SFX_UI_CANCEL)
	Event.Instance:Add("UpdateSelectRole", self.UpdateSelectRole, self)
end

function DlgSetRole:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonConfirm, self.OnClickBtnConfirm)
	self:RemoveClick(self.ButtonQuit, self.OnClickBtnQuit)
	Event.Instance:Remove("UpdateSelectRole", self.UpdateSelectRole, self)
end

function DlgSetRole:OnEnter(vParam)
	local Text = self:GetChildComponent("Panel/Title/Text", "Text")

	Text.text = Lang(42003)
	Text = self:GetChildComponent("Panel/ButtonConfirm/Text", "Text")
	Text.text = Lang(42620)
	self.ButtonConfirm = self:GetChildGameObject("Panel/ButtonConfirm")
	self.ButtonQuit = self:GetChildGameObject("Panel/ButtonQuit")

	self:Init(vParam)
end

function DlgSetRole:Init(vParam)
	self.listTeam = CombinationMgr:GetAllCombination()
	self.curRoleId = PlayerInst:GetShowRole()
	self.preRoleId = self.curRoleId

	local teamIdx, roleIdx = CombinationMgr.GetCombIdxAndRoleIdx(self.preRoleId)

	self.curTeamIdx = teamIdx
	self.curRoleIdx = roleIdx

	self:InitScrollView()
end

function DlgSetRole:InitScrollView()
	local scrollArea = self:GetChildGameObject("Panel/PanelRole/ScrollArea")
	local content = self:GetChildComponent("Panel/PanelRole/ScrollArea/Content", "RectTransform")
	local count = #self.listTeam

	local function addCallback(item)
		return
	end

	local function updateCallback(item, index)
		local info = self.listTeam[index]

		item:UpdateData(info, self.curTeamIdx, self.curRoleIdx)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCell, CellTeamRole, self, false, addCallback, updateCallback)
end

function DlgSetRole:UpdateSelectRole(data)
	local curRoleId

	if self.listTeam[data.teamIdx] and self.listTeam[data.teamIdx].data.MemberList[data.roleIdx] then
		curRoleId = self.listTeam[data.teamIdx].data.MemberList[data.roleIdx]
	end

	if curRoleId == nil or curRoleId == self.curRoleId then
		return
	end

	local infoRole = RoleMgr:GetRole(curRoleId)

	if not infoRole or not infoRole.hold then
		UIMgr.ShowMsg(_("Msg_IdolNotUnlock"))

		self.curRoleId = nil

		return
	end

	self.curTeamIdx = data.teamIdx
	self.curRoleIdx = data.roleIdx
	self.preRoleId = self.curRoleId
	self.curRoleId = curRoleId

	self.UIScrollTool:UpdateListDataKeepPos(self.listTeam)
end

function DlgSetRole:OnClickBtnConfirm()
	if self.curRoleId == self.preRoleId then
		self:Close()

		return
	end

	if self.curRoleId ~= self.preRoleId then
		local function wrap_cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vMsg.result.code == NetManager.Result_Sucess then
				Event.Instance:Fire(EventEnum.UpdatePlayerInfo, ePlayerInfoType.showRole)
				self:Close()
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestModifyPlayerInfo({
			showRole = self.curRoleId
		}, wrap_cb)
	end
end

function DlgSetRole:OnClickBtnQuit()
	self:Close()
end
