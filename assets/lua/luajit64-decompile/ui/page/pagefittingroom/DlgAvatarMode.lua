-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFittingroom/DlgAvatarMode.lua

DlgAvatarMode = class("DlgAvatarMode", UIPanel)

function DlgAvatarMode:ctor()
	DlgAvatarMode.base.ctor(self, "UI/PageFittingroom/DlgAvatarMode")

	self.parentPage = nil
end

function DlgAvatarMode:PreLoad()
	return
end

function DlgAvatarMode:Purge()
	self.base.Purge(self)

	self.parentPage = nil

	self.infoRole:SetCurModeId()
	self:OnLeave()
end

function DlgAvatarMode:OnLeave()
	if self.listCellMode then
		for _, v in ipairs(self.listCellMode) do
			self:RemoveClick(v, self.OnClickCellMode)
		end

		self.listCellMode = nil
	end
end

function DlgAvatarMode:OnRegisterEvent()
	self:AddClick(self.BtnMode, self.OnClickBtnMode)
	self:AddClick(self.BtnRename, self.OnClickBtnRename)
	self:AddClick(self.BtnDefault, self.OnClickBtnDefault)
	self:AddClick(self.GoEmptyRaycast, self.OnClickBtnMode)
end

function DlgAvatarMode:OnUnRegisterEvent()
	self:RemoveClick(self.BtnMode, self.OnClickBtnMode)
	self:RemoveClick(self.BtnRename, self.OnClickBtnRename)
	self:RemoveClick(self.BtnDefault, self.OnClickBtnDefault)
	self:RemoveClick(self.GoEmptyRaycast, self.OnClickBtnMode)

	for i = 1, self.modeCnt do
		self:RemoveClick(self["BtnMode" .. i], self.OnClickCellMode)
	end
end

function DlgAvatarMode:OnEnter(vParam)
	self.GoEmptyRaycast = self:GetChildGameObject("EmptyRaycast")

	GOUtil.SetActive(self.GoEmptyRaycast, 0)

	self.GoModeList = self:GetChildGameObject("Panel/Panel/Mode/List")

	GOUtil.SetActive(self.GoModeList, 0)

	self.BtnMode = self:GetChildGameObject("Panel/Panel/Mode/BtnMode")
	self.BtnDefault = self:GetChildGameObject("Panel/Panel/BtnDefault")
	self.BtnRename = self:GetChildGameObject("Panel/Panel/Mode/List/Content/BtnRename")
	self.TxtModeName = GOUtil.FindChildComponent(self.BtnMode, "Text", "Text")
	self.GoDefault = GOUtil.FindChildGameObject(self.BtnDefault, "Img2")
	self.parentPage = vParam.page

	self:InitModeList()
end

function DlgAvatarMode:InitModeList()
	self.modeCnt = 4

	for i = 1, self.modeCnt do
		self["GoMode" .. i] = self:GetChildGameObject("Panel/Panel/Mode/List/Content/" .. i)
		self["BtnMode" .. i] = GOUtil.FindChildGameObject(self["GoMode" .. i], "Button")

		self:AddClick(self["BtnMode" .. i], self.OnClickCellMode)

		self["GoDefault" .. i] = GOUtil.FindChildGameObject(self["GoMode" .. i], "Image")
		self["TxtModeName" .. i] = GOUtil.FindChildComponent(self["GoMode" .. i], "Text", "Text")
	end
end

function DlgAvatarMode:UpdateRoleMode(role)
	if self.infoRole and role.id == self.infoRole.id then
		return
	end

	self.infoRole = role

	self.infoRole:SetCurModeId(AvatarManager.LastEquipAvatar.modeId)

	self.curModeIdx = 1

	local defIdx = 1

	for i = 1, #role.pb.avatarModes do
		if role.pb.avatarModes[i].id == self.infoRole.curModeId then
			self.curMode = role.pb.avatarModes[i]
			self.preMode = role.pb.avatarModes[i]
			self.curModeIdx = i
			defIdx = i

			break
		end
	end

	self:UpdateModeList()
	self:RefreshModeShow()
	self:RefreshRenamePos()
end

function DlgAvatarMode:UpdateModeList()
	for i = 1, self.modeCnt do
		self:UpdateModeName(i)
	end

	self:UpdateDefaultMode()
end

function DlgAvatarMode:UpdateModeName(idx)
	local mode = self.infoRole.pb.avatarModes[idx]

	if mode ~= nil then
		if mode.name and mode.name ~= "" then
			self["TxtModeName" .. idx].text = mode.name
		else
			self["TxtModeName" .. idx].text = string.format(_("Msg_Custom_Dress_Mode"), _("ecNum_" .. idx))
		end
	end
end

function DlgAvatarMode:UpdateDefaultMode()
	for i = 1, self.modeCnt do
		GOUtil.SetActive(self["GoDefault" .. i], TenaryOp(i == self.infoRole.pb.curreModeId, 1, 0))
	end
end

function DlgAvatarMode:RefreshModeShow()
	if self.curMode.name and self.curMode.name ~= "" then
		self.TxtModeName.text = self.curMode.name
	else
		self.TxtModeName.text = string.format(_("Msg_Custom_Dress_Mode"), _("ecNum_" .. self.curMode.id))
	end

	GOUtil.SetActive(self.GoDefault, TenaryOp(self.curMode.id == self.infoRole.pb.curreModeId, 1, 0))
end

function DlgAvatarMode:RefreshRenamePos()
	GOUtil.AttachGameObject(self.BtnRename, self["GoMode" .. self.curModeIdx])
	GOUtil.SetTransformLocalPosition(self.BtnRename, 180, 0, 0)
end

function DlgAvatarMode:OnClickBtnMode()
	if not self.ModeListState then
		GOUtil.SetActive(self.GoModeList, 1)
		GOUtil.SetActive(self.GoEmptyRaycast, 1)

		self.ModeListState = true
	else
		GOUtil.SetActive(self.GoModeList, 0)
		GOUtil.SetActive(self.GoEmptyRaycast, 0)

		self.ModeListState = false
	end
end

function DlgAvatarMode:OnClickCellMode(data)
	local idx = tonumber(data.pointerPress.transform.parent.name)
	local mode = self.infoRole.pb.avatarModes[idx]

	if mode.id == self.curMode.id then
		return
	end

	local temp = {
		callback = function()
			self.infoRole:SetCurModeId(idx)
			self.infoRole:SetTempEquipAvatarIds()

			AvatarManager.LastEquipAvatar = {}
			self.curModeIdx = idx
			self.preMode = self.curMode
			self.curMode = mode

			self:RefreshModeShow()
			self:RefreshRenamePos()
		end
	}

	if self.parentPage and self.parentPage.SwitchRoleMode then
		self.parentPage:SwitchRoleMode(temp)
	end
end

function DlgAvatarMode:OnClickBtnRename()
	local function cb(input, cb)
		self:ModeNameChangeCall(input, cb)
	end

	require("UI/Page/PagePlayerInfo/DlgModifyNick")
	UIMgr.AddPanel(DlgModifyNick(), {
		eModifyInputType.AvatarMode,
		self.TxtModeName.text,
		cb
	})
end

function DlgAvatarMode:ModeNameChangeCall(input, panelCb)
	local function cb()
		panelCb()
		self:UpdateModeName(self.curModeIdx)
		self:RefreshModeShow()
	end

	Event.Instance:Fire("SyncServerModeData", {
		modeName = input,
		panelCb = cb
	})
end

function DlgAvatarMode:OnClickBtnDefault()
	if self.curMode.id == self.infoRole.pb.curreModeId then
		UIMgr.ShowMsg(_("Msg_Avatar_Mode_As_Default"))

		return
	end

	local function cb()
		self:UpdateDefaultMode()
		self:RefreshModeShow()
	end

	Event.Instance:Fire("SyncServerModeData", {
		defaultId = self.curMode.id,
		panelCb = cb
	})
end
