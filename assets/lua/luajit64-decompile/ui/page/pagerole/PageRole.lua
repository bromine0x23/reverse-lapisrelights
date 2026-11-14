-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRole/PageRole.lua

PageRole = class("PageRole", UIPanel)

local enumSystem = {
	TutorialFunctionType.Equipment,
	TutorialFunctionType.Talent,
	TutorialFunctionType.Dress
}

local function CheckSystemUnlock(system, noMsg)
	local isOpen = true

	if system ~= 0 then
		if not noMsg then
			isOpen = TutorialMgr:IsOpenTut(system)
		else
			isOpen = TutorialMgr:IsOpenNoMsg(system)
		end
	end

	return isOpen
end

function PageRole:ctor()
	self.UIPrefabPath = "UI/PanelRole/PanelRole"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_RoleInfo"),
		callback = self.OnBack,
		panel = self,
		preCallback = self.PlayEndAnim
	})
	self:AddChildPanel(DlgAssetsInfo(), {
		x = -600,
		y = -42
	})

	self.DlgCharacterThin = DlgCharacterThin(THIN_SYSTEM_TYPE.Role, THIN_PAGE_TYPE.Role)

	self:AddChildPanel(self.DlgCharacterThin)
end

function PageRole:OnBack(vParam)
	UIMgr.PopPanel(vParam)
end

function PageRole:Purge()
	self.base.Purge(self)

	globalInterSoundEvent = nil
	globalInterSoundBank = nil

	UIMgr.SwitchPreviewActor()
end

function PageRole:OnRegisterEvent()
	self:AddClick(self.BtnEquip, self.OnClickedBtnEquip)
	self:AddClick(self.BtnDress, self.OnClickedBtnDress)
	self:AddClick(self.BtnRoleL, self.OnClickedBtnRoleL)
	self:AddClick(self.BtnRoleR, self.OnClickedBtnRoleR)
	Event.Instance:Add("UpdateShowCharacter", self.UpdateRole, self)
end

function PageRole:OnUnRegisterEvent()
	self:RemoveClick(self.BtnEquip, self.OnClickedBtnEquip)
	self:RemoveClick(self.BtnDress, self.OnClickedBtnDress)
	self:RemoveClick(self.BtnRoleL, self.OnClickedBtnRoleL)
	self:RemoveClick(self.BtnRoleR, self.OnClickedBtnRoleR)
	Event.Instance:Remove("UpdateShowCharacter", self.UpdateRole, self)
end

function PageRole:OnEnter(vParam)
	self:DealWithLocalization()

	self.BtnEquip = self:GetChildGameObject("Panel/BtnEquip")
	self.BtnDress = self:GetChildGameObject("Panel/BtnDress")
	self.GoArrow = self:GetChildGameObject("Panel/GoArrow")
	self.ArrowState = true
	self.BtnRoleL = self:GetChildGameObject("Panel/GoArrow/BtnL")
	self.BtnRoleR = self:GetChildGameObject("Panel/GoArrow/BtnR")

	local GoLock = self:GetChildGameObject("Panel/BtnEquip/Lock")

	if not CheckSystemUnlock(enumSystem[1], true) then
		GOUtil.SetActive(GoLock, true)
	end

	GoLock = self:GetChildGameObject("Panel/BtnDress/Lock")

	if not CheckSystemUnlock(enumSystem[3], true) then
		GOUtil.SetActive(GoLock, true)
	end

	self:Init(vParam)
	UIMgr.BuildPreviewActor(eActorSystemType.ROLE, self)
end

function PageRole:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/BtnEquip/Image/Text", "Text")
	txt.text = Lang(9123)
	txt = self:GetChildComponent("Panel/BtnDress/Image/Text", "Text")
	txt.text = Lang(12452)
end

function PageRole:Init(data)
	local infoRole

	if data and data.roleId then
		infoRole = RoleMgr:GetRole(data.roleId)

		CharacterThinMgr.DoResetOperate(CharacterThinMgr.ResetType.SKIP, data.roleId)
		self.DlgCharacterThin:Init()
		UIMgr.ClearClassStackData(self.className)
	else
		local lastRoleId = CharacterThinMgr.LastData(THIN_SYSTEM_TYPE.Role).id

		infoRole = RoleMgr:GetRole(lastRoleId)
	end

	self:UpdateRole(infoRole, true)
end

function PageRole:UpdateRole(infoRole, updateswitch)
	if not infoRole or not infoRole.hold then
		return
	end

	self.infoRole = infoRole

	if updateswitch then
		self:UpdateListRole()
	end

	self:UpdateDot()
end

function PageRole:UpdateListRole()
	local listRole = CharacterThinMgr.SwitchData(THIN_SYSTEM_TYPE.Role).roles

	if #listRole > 1 then
		if not self.ArrowState then
			self.GoArrow:SetActive(true)

			self.ArrowState = true
		end
	elseif self.ArrowState then
		self.GoArrow:SetActive(false)

		self.ArrowState = false
	end
end

function PageRole:OnClickedBtnEquip()
	if not CheckSystemUnlock(enumSystem[1]) then
		return
	end

	require("UI/Page/PageEquipment/PageEquip")
	UIMgr.SwitchPanel(PageEquip)
end

function PageRole:OnClickedBtnTalent()
	if not CheckSystemUnlock(enumSystem[2]) then
		return
	end

	require("UI/Page/PageRole/PageTalentTree")
	UIMgr.SwitchPanel(PageTalentTree)
end

function PageRole:OnClickedBtnDress()
	if not CheckSystemUnlock(enumSystem[3]) then
		return
	end

	require("UI/Page/PageFittingroom/PageFittingroom")
	UIMgr.SwitchPanel(PageFittingroom)
end

function PageRole:OnClickedBtnRoleL()
	self:OnNext(false)
end

function PageRole:OnClickedBtnRoleR()
	self:OnNext(true)
end

function PageRole:OnNext(isR)
	local _type = isR and eDirectionType.R or eDirectionType.L

	CharacterThinMgr.DOSwitch(THIN_SYSTEM_TYPE.Role, _type)
end

function PageRole:UpdateDot()
	RedDotSystemMgr.SetUIRedDot(self.BtnEquip, "Role/" .. self.infoRole.id .. "/Equip")
	RedDotSystemMgr.SetUIRedDot(self.BtnDress, "Role/" .. self.infoRole.id .. "/Fitting")
end

function PageRole:OnBackAndroid()
	if self.DlgCharacterThin and not IsNil(self.DlgCharacterThin.GoClick) and GOUtil.IsActiveSelf(self.DlgCharacterThin.GoClick) then
		self.DlgCharacterThin:OnClickBack()

		return true
	end

	return false
end
