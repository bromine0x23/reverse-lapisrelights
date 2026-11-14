-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageEquipment/PageEquip.lua

require("UI/Page/PageEquipment/PageEquipAvatar")

PageEquip = class("PageEquip", UIPanel)

function PageEquip:ctor()
	self.UIPrefabPath = "UI/PanelEquipment/PanelEquipment"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_RoleEquip"),
		callback = self.OnBack,
		helpCallback = self.OnClickedBtnGuide,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())

	self.DlgCharacterThin = DlgCharacterThin(THIN_SYSTEM_TYPE.Role, THIN_PAGE_TYPE.Equip)

	self:AddChildPanel(self.DlgCharacterThin)
end

function PageEquip:PreLoad()
	return
end

function PageEquip:OnBack(vParam)
	UIMgr.PopPanel(vParam)
end

function PageEquip:Purge()
	self.base.Purge(self)
	InfoSoundEventMgr:OnBack()
	UIMgr.SwitchPreviewActor()
	EffectMgr:UnLoadEffect("UI/PanelRole/Partical_Avatar")
end

function PageEquip:OnRegisterEvent()
	self:AddClick(self.BtnAvatar, self.OnClickedBtnAvatar)
	self:AddClick(self.BtnOneKey, self.OnClickedBtnOneKey)
	self:AddClick(self.BtnRoleL, self.OnClickedBtnRoleL)
	self:AddClick(self.BtnRoleR, self.OnClickedBtnRoleR)

	for i = 1, self.slotCnt do
		self:AddClick(self["BtnSlot" .. i], self.OnClickedBtnSlot)
	end

	Event.Instance:Add("UpdateEquipAfterDevelop", self.UpdateEquipAfterDevelop, self)
	Event.Instance:Add("UpdateShowCharacter", self.UpdateRole, self)
	Event.Instance:Add(EventEnum.UpdateItemDataNotify, self.UpdateItemDataNotify, self)
	Event.Instance:Add("UpdateNetData", self.UpdateNetData, self)
end

function PageEquip:OnUnRegisterEvent()
	self:RemoveClick(self.BtnAvatar, self.OnClickedBtnAvatar)
	self:RemoveClick(self.BtnOneKey, self.OnClickedBtnOneKey)
	self:RemoveClick(self.BtnRoleL, self.OnClickedBtnRoleL)
	self:RemoveClick(self.BtnRoleR, self.OnClickedBtnRoleR)

	for i = 1, self.slotCnt do
		self:RemoveClick(self["BtnSlot" .. i], self.OnClickedBtnSlot)
	end

	Event.Instance:Remove("UpdateEquipAfterDevelop", self.UpdateEquipAfterDevelop, self)
	Event.Instance:Remove("UpdateShowCharacter", self.UpdateRole, self)
	Event.Instance:Remove(EventEnum.UpdateItemDataNotify, self.UpdateItemDataNotify, self)
	Event.Instance:Remove("UpdateNetData", self.UpdateNetData, self)
end

function PageEquip:OnEnter(vParam)
	PersistentStoreUtil.SetBool("EquipDot", false)
	self:DealWithLocalization()

	if not GuideMgr:IsGuided(GuideFunctionType.Equip) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.Equip)
	end

	self.slotCnt = EquipmentManager.EquipSlotCnt

	for i = 1, self.slotCnt do
		self["BtnSlot" .. i] = self:GetChildGameObject("Panel/EquipSlot/" .. i)
		self["ImgSlot" .. i] = GOUtil.GetComponent(self["BtnSlot" .. i], "Image")
		self["ImgIcon" .. i] = GOUtil.FindChildComponent(self["BtnSlot" .. i], "ImgIcon", "Image")
		self["GoSlotUnlock" .. i] = GOUtil.FindChildGameObject(self["BtnSlot" .. i], "Unlock")
		self["GoSlotLock" .. i] = GOUtil.FindChildGameObject(self["BtnSlot" .. i], "Lock")
		self["ImgSuit" .. i] = GOUtil.FindChildComponent(self["BtnSlot" .. i], "Unlock/ImgSuit", "Image")
		self["ImgLevel" .. i] = GOUtil.FindChildComponent(self["BtnSlot" .. i], "Unlock/ImgLevel", "Image")
		self["TxtLevel" .. i] = GOUtil.FindChildComponent(self["BtnSlot" .. i], "Unlock/ImgLevel/TxtLevel", "Text")
		self["GoDot" .. i] = GOUtil.FindChildGameObject(self["BtnSlot" .. i], "Unlock/Dot")
		self["TxtUnlockCon" .. i] = GOUtil.FindChildComponent(self["BtnSlot" .. i], "Lock/Text", "Text")
	end

	self.BtnAvatar = self:GetChildGameObject("Panel/EquipSlot/BtnAvatar")

	EffectMgr:Alloc("UI/PanelRole/Partical_Avatar", self.BtnAvatar, true)

	self.BtnOneKey = self:GetChildGameObject("Panel/EquipSlot/BtnOneKey")
	self.ImgOneKey = self:GetChildComponent("Panel/EquipSlot/BtnOneKey", "Image")
	self.GoArrow = self:GetChildGameObject("Panel/EquipSlot/GoArrow")
	self.ArrowState = true
	self.BtnRoleL = self:GetChildGameObject("Panel/EquipSlot/GoArrow/BtnL")
	self.BtnRoleR = self:GetChildGameObject("Panel/EquipSlot/GoArrow/BtnR")

	self:Init(vParam)
	UIMgr.BuildPreviewActor(eActorSystemType.EQUIP, self)
end

function PageEquip:DealWithLocalization()
	local txt = self:GetChildComponent("Panel/EquipSlot/BtnOneKey/TxtName", "Text")

	txt.text = Lang(7001025)
end

function PageEquip:Init(data)
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

function PageEquip:UpdateRole(infoRole, updateswitch)
	if not infoRole or not infoRole.hold then
		return
	end

	if self.infoRole and self.infoRole.id ~= infoRole.id then
		UnloadAllImageSprite(self)
	end

	self.infoRole = infoRole
	self.roleId = self.infoRole.id

	if updateswitch then
		self:UpdateListRole()
	end

	self:UpdatePanel()

	self.listAvatar = AvatarManager:GetWeaponAvatarList(self.infoRole)

	self:UpdateDot()
end

function PageEquip:UpdateListRole()
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

function PageEquip:UpdatePanel()
	self:UpdateSlot()
	self:UpdateEquipBtnState()
end

function PageEquip:UpdateEquipBtnState()
	local isCanDevelop = self.IsCanDevelopAll(self.infoRole)
	local gray = TenaryOp(isCanDevelop, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgOneKey, gray))
end

function PageEquip:UpdateSlot()
	self:UpdateSlotStatic()
	self:UpdateSlotDynamic()
end

function PageEquip:UpdateSlotStatic()
	for i = 1, self.slotCnt do
		local infoEquip = EquipmentManager:GetEquip(self.infoRole:GetEquipId(i))
		local infoSlot = self.infoRole:GetEquipSlot(i)
		local icon = EquipmentManager:GetEquipSlotIconAndName(self.infoRole, infoEquip, infoSlot.quality, infoSlot.grade)

		SetImageSprite(self["ImgIcon" .. i], icon, self)

		local isUnlock = self.infoRole:IsEquipSlotUnlocked(i)

		GOUtil.SetActive(self["GoSlotLock" .. i], not isUnlock)
		GOUtil.SetActive(self["GoSlotUnlock" .. i], isUnlock)
		GOUtil.SetActive(self["ImgSuit" .. i], isUnlock and infoSlot.scroll ~= 0)

		if not isUnlock then
			self["TxtUnlockCon" .. i].text = string.format(Lang(12054), GetConfigArgJson("EquipmentUnlock")[i] .. "\n")

			UIUtil.SetGraphicColorRGBA(self["ImgIcon" .. i], 0.6980392156862745, 0.6980392156862745, 0.6980392156862745, 0.9254901960784314)
			UIUtil.SetGraphicColorRGBA(self["ImgSlot" .. i], 0.7843137254901961, 0.7843137254901961, 0.7843137254901961, 0.9254901960784314)
		else
			if infoSlot.scroll ~= 0 then
				local infoReel = ItemManager:Get(infoSlot.scroll)

				SetImageSprite(self["ImgSuit" .. i], EquipmentManager.GetSuitIconByScrollType(tonumber(infoReel.data.SubType)) .. "_s", self)

				local cnt = self.infoRole:GetActiveSameSuitSubTypeNum(infoSlot.scroll, i, true)
				local listSuit = EquipmentManager.GetSuitByScrollType(tonumber(infoReel.data.SubType))
				local index = 0

				for j = 1, #listSuit do
					if cnt >= listSuit[j].Number then
						index = j
					end
				end

				if index ~= 0 then
					if self["handle" .. i] == nil or self["preEffNum" .. i] ~= index then
						if self["handle" .. i] ~= nil then
							EffectMgr:Free(self["handle" .. i])
						end

						self["handle" .. i] = EffectMgr:Alloc("Fx/UI/Eff_Ui_FuMo/Eff_Ui_FuMo_Trail0" .. index, self["ImgSuit" .. i].gameObject, true)
						self["preEffNum" .. i] = index
					end
				else
					if self["handle" .. i] ~= nil then
						EffectMgr:Free(self["handle" .. i])

						self["handle" .. i] = nil
					end

					self["preEffNum" .. i] = 0
				end
			end

			UIUtil.SetGraphicColorRGB(self["ImgIcon" .. i], 1, 1, 1)
			UIUtil.SetGraphicColorRGB(self["ImgSlot" .. i], 1, 1, 1)
		end
	end
end

function PageEquip:UpdateSlotDynamic()
	for i = 1, self.slotCnt do
		local isUnlock = self.infoRole:IsEquipSlotUnlocked(i)

		if isUnlock then
			local infoSlot = self.infoRole:GetEquipSlot(i)
			local quaIdx = EquipmentManager:GetQualityIndex(infoSlot.quality, infoSlot.grade)
			local col = sixNumToRGB(GetConfigArgJson("EquipQualityColor")[quaIdx].Color)

			UIUtil.SetGraphicColorRGB(self["ImgLevel" .. i], col.r / 255, col.g / 255, col.b / 255)

			self["TxtLevel" .. i].text = infoSlot.level
		end
	end
end

function PageEquip:OnClickedBtnRoleL()
	self:OnNext(false)
end

function PageEquip:OnClickedBtnRoleR()
	self:OnNext(true)
end

function PageEquip:OnNext(isR)
	local _type = isR and eDirectionType.R or eDirectionType.L

	CharacterThinMgr.DOSwitch(THIN_SYSTEM_TYPE.Role, _type)
end

function PageEquip:OnClickedBtnSlot(data)
	local index = tonumber(data.pointerPress.gameObject.name)

	if not self.IsSlotUnlocked(self.roleId, index) then
		return
	end

	RoleRDL.EquipRDL.SubUnlockEquipSlot(self.infoRole, index)
	require("UI/Page/PageEquipment/PageEquipDevelop")
	UIMgr.SwitchPanel(PageEquipDevelop, {
		roleId = self.roleId,
		slotIdx = index
	})
end

function PageEquip:OnClickedBtnAvatar()
	UIMgr.SwitchPanel(PageEquipAvatar)
end

function PageEquip:OnClickedBtnOneKey()
	local canDevelop = self.IsCanDevelopAll(self.infoRole)

	if canDevelop then
		require("UI/Page/PageEquipment/DlgDevelopAllEquip")
		UIMgr.AddPanel(DlgDevelopAllEquip(), {
			roleId = self.roleId
		})
	else
		local notMaxEquip = EquipmentManager:GetEquipNotMaxResult(self.infoRole)

		if notMaxEquip then
			UIMgr.ShowMsg(_("Desc_NoItemOrMoney"))
		else
			UIMgr.ShowMsg(_("No_Event"))
		end
	end
end

function PageEquip:UpdateEquipAfterDevelop()
	self:UpdateSlotDynamic()

	if UIMgr.PreviewActor and UIMgr.PreviewActor.DlgRoleInfo then
		UIMgr.PreviewActor.DlgRoleInfo:UpdateCombatPowerAndAtt()
	end

	InfoSoundEventMgr:LoadBank(UIMgr.PreviewActor.DlgRoleInfo.parentPanel.infoRole.data.VocalBank)
	InfoSoundEventMgr:Play("VocalCommon6", UIMgr.PreviewActor.DlgRoleInfo.parentPanel.infoRole.data.VocalCommon6)
	Event.Instance:Fire("UpdateThinAfterDevelop")
	self:UpdateEquipBtnState()
end

function PageEquip:UpdateDot()
	for i = 1, 6 do
		RedDotSystemMgr.SetUIRedDot(self["BtnSlot" .. i], "Role/" .. self.infoRole.id .. "/Equip/" .. i .. "/Unlock")
	end

	RedDotSystemMgr.SetUIRedDot(self.BtnOneKey, "Role/" .. self.infoRole.id .. "/Equip/Fast_Intense")
	RedDotSystemMgr.SetUIRedDot(self.BtnAvatar, "Role/" .. self.infoRole.id .. "/Equip/Weapon")
end

function PageEquip:UpdateItemDataNotify()
	self:UpdateEquipBtnState()
end

function PageEquip.IsSlotUnlocked(roleId, slotIdx)
	local infoRole = RoleMgr:GetRole(roleId)

	if infoRole then
		local isUnlock = infoRole:IsEquipSlotUnlocked(slotIdx)

		if isUnlock then
			return true
		else
			local needLevel = GetConfigArgJson("EquipmentUnlock")[slotIdx]

			UIMgr.ShowMsg(string.format(_("PageTalentTree_Unlock_favor_1"), needLevel))
		end
	end

	return false
end

function PageEquip.IsCanDevelopAll(infoRole)
	local canDevelop = false
	local costList = EquipmentManager:GetAllEquipDevelopNeedItem(infoRole, {})

	if costList ~= nil and table.getItemCount(costList) > 0 then
		canDevelop = true
	end

	local costList = EquipmentManager:GetAllEquipBreakNeedItem(infoRole, {})

	if costList ~= nil and table.getItemCount(costList) > 0 then
		canDevelop = true
	end

	return canDevelop
end

function PageEquip:OnClickedBtnGuide()
	require("UI/Dlg/Public/GuideChooseTip")
	UIMgr.AddPanel(GuideChooseTip(), {
		guideType = "EquipGuide"
	})
end

function PageEquip:UpdateNetData()
	self:UpdatePanel()
end

function PageEquip:OnBackAndroid()
	if self.DlgCharacterThin and not IsNil(self.DlgCharacterThin.GoClick) and GOUtil.IsActiveSelf(self.DlgCharacterThin.GoClick) then
		self.DlgCharacterThin:OnClickBack()

		return true
	end

	return false
end
