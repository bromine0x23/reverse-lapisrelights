-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFittingroom/CellAvatar.lua

require("UI/Item/UIItemBase")

CellAvatar = class("CellAvatar", UIItemBase)

function CellAvatar:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
	self.IsSeted = false
	self.listState = {}
end

function CellAvatar:Create(vParam)
	CellAvatar.base.Create(self, vParam)
end

function CellAvatar:OnEnter(vParam)
	local g = self.UIRootObject
	local txt = GOUtil.FindChildComponent(g, "Cell/GoBP/BPBind/Text", "Text")

	txt.text = _("Desc_Using")
	txt = GOUtil.FindChildComponent(g, "Cell/GoBP/BtnBind/GO/Text", "Text")
	txt.text = "<size=22>" .. _("UI_Btn_Bind") .. "</size>"
	self.TxtAvatarName = GOUtil.FindChildComponent(g, "Cell/TextName", "Text")
	self.ImgAvatarIcon = GOUtil.FindChildComponent(g, "Cell/AvatarIcon", "Image")
	self.ImageBg1 = GOUtil.FindChildComponent(g, "Cell/ImgBg1", "Image")
	self.listState.ImageBg1 = true
	self.GoImageBg2 = GOUtil.FindChildGameObject(g, "Cell/ImgBg2")
	self.GoSellingPrice1 = GOUtil.FindChildGameObject(g, "Cell/Info/Info1")
	self.CostIcon1 = GOUtil.FindChildComponent(self.GoSellingPrice1, "Image", "Image")
	self.CostText1 = GOUtil.FindChildComponent(self.GoSellingPrice1, "Text", "Text")
	self.GoSellingPrice2 = GOUtil.FindChildGameObject(g, "Cell/Info/Info2")
	self.CostIcon2 = GOUtil.FindChildComponent(self.GoSellingPrice2, "Image", "Image")
	self.CostText2 = GOUtil.FindChildComponent(self.GoSellingPrice2, "Text", "Text")
	self.GoSellingPrice3 = GOUtil.FindChildGameObject(g, "Cell/Info/Info3")
	self.CostText3 = GOUtil.FindChildComponent(self.GoSellingPrice3, "Text", "Text")
	self.GoEquip = GOUtil.FindChildGameObject(g, "Cell/EquipState")
	self.ImgRealEquip = GOUtil.FindChildComponent(g, "Cell/EquipState/1", "Image")
	self.ImgTempEquip = GOUtil.FindChildComponent(g, "Cell/EquipState/2", "Image")
	self.GoBP = GOUtil.FindChildGameObject(g, "Cell/GoBP")
	self.GoBPBind = GOUtil.FindChildGameObject(g, "Cell/GoBP/BPBind")
	self.CharacterIcon = GOUtil.FindChildComponent(self.GoBPBind, "Character", "Image")
	self.ImgBPPeriod = GOUtil.FindChildComponent(self.GoBP, "Period/Image", "Image")
	self.TxtBPPeriod = GOUtil.FindChildComponent(self.GoBP, "Period/Text", "Text")
	self.BtnBind = GOUtil.FindChildGameObject(g, "Cell/GoBP/BtnBind")
	self.GoBindCost = GOUtil.FindChildGameObject(self.BtnBind, "GO/Cost")
	self.BindCostText = GOUtil.FindChildComponent(self.BtnBind, "GO/Cost/Text", "Text")
	self.BtnGoFrom = GOUtil.FindChildGameObject(g, "Cell/BtnGo")
	self.GoSel = GOUtil.FindChildGameObject(g, "Cell/GoSel")
	self.GoNew = GOUtil.FindChildGameObject(g, "Cell/GoNew")
	self.GoLock = GOUtil.FindChildGameObject(g, "Cell/GoLock")
	self.GoCheckMark = GOUtil.FindChildGameObject(g, "Cell/GoBuySel")
	self.GoCheckedMark = GOUtil.FindChildGameObject(g, "Cell/GoBuySel/Image")
	self.ImgFromSign = GOUtil.FindChildComponent(g, "Cell/ImgFrom", "Image")

	self:AddClick(self.BtnGoFrom, self.OnClickBtnGoFrom)
	self:AddClick(self.BtnBind, self.OnClickBtnBind)
	self:AddListener(self.UIRootObject, self.OnPointerLongPress, EventTriggerType.PointerLongPress)
end

function CellAvatar:OnLeave()
	UnloadAllImageSprite(self)
	self:RemoveClick(self.BtnGoFrom, self.OnClickBtnGoFrom)
	self:RemoveClick(self.BtnBind, self.OnClickBtnBind)
	self:RemoveListener(self.UIRootObject, self.OnPointerLongPress, EventTriggerType.PointerLongPress)

	self.listState = nil
end

function CellAvatar:UpdateData(avatarData, index, infoRole, showBtn, showFrom)
	if not avatarData or not avatarData.InfoAvatar then
		return
	end

	UnloadAllImageSprite(self)

	self.avatarData = avatarData
	self.infoRole = infoRole
	self.showBtn = Tenary(showBtn, false)
	self.showFrom = Tenary(showFrom, false)
	self.IsGeted = avatarData.Geted
	self.IsUnlock = avatarData.IsUnlocked
	self.IsCanGet = avatarData.IsCanGotoGet
	self.IsBP = avatarData.InfoAvatar:IsBPAvatar()
	self.IsActive = avatarData.InfoAvatar.data.Active ~= 0
	self.TxtAvatarName.text = avatarData.InfoAvatar:GetName()

	UIUtil.SetImageOverrideSprite(self.ImgAvatarIcon, avatarData.InfoAvatar.data.Icon, self)

	if not self.IsSeted then
		if self.avatarData.InfoAvatar:IsWeaponAvatar() then
			UIUtil.SetImageSprite(self.ImgRealEquip, "UI/PageFittingroom/AtlasCellAvatar/BG_equip_equiped", self)
			UIUtil.SetImageSprite(self.ImgTempEquip, "UI/PageFittingroom/AtlasCellAvatar/BG_equip_test", self)
		else
			UIUtil.SetImageSprite(self.ImgRealEquip, "UI/PageFittingroom/AtlasCellAvatar/BG_equip_equiped_02", self)
			UIUtil.SetImageSprite(self.ImgTempEquip, "UI/PageFittingroom/AtlasCellAvatar/BG_equip_test_02", self)
		end

		self.IsSeted = true
	end

	self:UpdateInfo()
	self:UpdateState()

	local state = self.avatarData.Equiped

	self:UpdateSlectState(state)
	self:UpdateNew()
end

function CellAvatar:UpdateInfo()
	if self.IsUnlock and not self.IsGeted then
		local strIcon = ItemManager:GetIcon(self.avatarData.InfoAvatar.data.Cost[1] or 501)

		if self.IsActive then
			UIUtil.SetImageSprite(self.CostIcon1, strIcon, self)

			self.CostText1.text = self.avatarData.InfoAvatar.data.Cost[2] or 0
		else
			UIUtil.SetImageSprite(self.CostIcon2, strIcon, self)

			self.CostText2.text = self.avatarData.InfoAvatar.data.Cost[2] or 0
		end
	elseif self.IsBP then
		local k, v = self.avatarData.InfoAvatar:GetBPAddAtt()

		if not self.showFrom then
			if k > 0 and v > 0 then
				if GetAttValueType(GetAttENKey(k)) == eValueType.Abs then
					self.CostText3.text = _("eAttType_Fit_" .. k) .. " <color=#009D1E>+" .. v .. "</color>"
				else
					self.CostText3.text = _("eAttType_Fit_" .. k) .. " <color=#009D1E>+" .. v * 100 .. "%</color>"
				end
			else
				self.CostText3.text = ""
			end
		elseif self.avatarData.Geted then
			self.CostText3.text = _("Desc_Geted")
		else
			self.CostText3.text = _("Avatar_From_" .. self.avatarData.InfoAvatar.data.FromWhere)
		end
	elseif self.IsGeted then
		self.CostText3.text = _("Desc_Geted")
	else
		local fromWhere = self.avatarData.InfoAvatar.data.FromWhere

		if fromWhere ~= 0 then
			local str = ""

			if fromWhere == eAvatarFrom.card or fromWhere == eAvatarFrom.petal or fromWhere == eAvatarFrom.limit_card_pool then
				local infoRoleCard = RoleCardMgr:GetRoleCard(self.avatarData.InfoAvatar.data.FromRoleCardID)

				str = string.format(_("Avatar_From_" .. fromWhere), "")
			else
				str = _("Avatar_From_" .. fromWhere)
			end

			self.CostText3.text = str
		else
			self.CostText3.text = ""
		end
	end

	local gray = 0

	if self.IsBP and not self.IsGeted and not self.IsCanGet then
		gray = 1
	end

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgAvatarIcon, gray))
	DealWithListRef(self, UIUtil.SetImageGray(self.ImageBg1, gray))
end

function CellAvatar:UpdateState()
	SetActiveWithState(self, "ImageBg1", not self.IsGeted, true)
	SetActiveWithState(self, "GoImageBg2", self.IsGeted)
	SetActiveWithState(self, "GoBP", self.IsBP)

	if self.showBtn then
		SetActiveWithState(self, "BtnGoFrom", not self.IsUnlock and self.IsCanGet)
	end

	local fromId = self.avatarData.InfoAvatar.data.FromWhere

	if fromId ~= 0 then
		SetActiveWithState(self, "ImgFromSign", true, true)
		SetImageSprite(self.ImgFromSign, "UI/PageFittingroom/AtlasCellAvatar/IC_COM_006_" .. fromId, self)
	else
		SetActiveWithState(self, "ImgFromSign", false, true)
	end

	for i = 1, 3 do
		local vbool = false

		if i == 1 then
			vbool = self.IsUnlock and not self.IsGeted and self.IsActive
		elseif i == 2 then
			vbool = self.IsUnlock and not self.IsGeted and not self.IsActive
		else
			vbool = self.IsGeted or self.IsBP or not self.IsUnlock
		end

		SetActiveWithState(self, "GoSellingPrice" .. i, vbool)
	end

	SetActiveWithState(self, "GoLock", not self.IsUnlock)
	self:UpdateNameState()
	self:UpdateEquipState()

	if self.IsBP then
		self:UpdateBpBindState()
	end
end

function CellAvatar:UpdateNameState()
	local bpAvatar = PlayerInst:GetBPAvatar(self.avatarData.id)
	local isShow = self.avatarData.IsUnlocked and not self.avatarData.Geted or self.IsBP and PlayerInst:IsBind(self.avatarData.id, self.infoRole.id) or not self.showBtn

	SetActiveWithState(self, "TxtAvatarName", isShow, true)
end

function CellAvatar:UpdateEquipState()
	SetActiveWithState(self, "ImgRealEquip", self.avatarData.RealEquiped, true)
	SetActiveWithState(self, "ImgTempEquip", not self.avatarData.RealEquiped and self.avatarData.Equiped, true)
	self:UpdateNameState()

	if not self.showBtn then
		return
	end

	if self.IsBP then
		local isBind = false
		local isThis = false
		local bpAvatar = PlayerInst:GetBPAvatar(self.avatarData.InfoAvatar.id)

		if bpAvatar then
			isBind = bpAvatar.roleId ~= 0
			isThis = bpAvatar.roleId == self.infoRole.id
		end

		SetActiveWithState(self, "BtnBind", self.showBtn and self.IsGeted and (not isBind or not isThis))
	end
end

function CellAvatar:UpdateBpBindState()
	local isBind = false
	local isThis = false
	local bpAvatar = PlayerInst:GetBPAvatar(self.avatarData.InfoAvatar.id)

	if bpAvatar then
		isBind = bpAvatar.roleId ~= 0
		isThis = bpAvatar.roleId == self.infoRole.id
	end

	SetActiveWithState(self, "GoBPBind", isBind)

	if isBind then
		local role = RoleMgr:GetRole(bpAvatar.roleId)

		SetImageSprite(self.CharacterIcon, "UIDyAtlas/Enemy/Icon/IC_ENH_" .. role.data.Enname .. "_03", self)
	end

	SetActiveWithState(self, "BtnBind", self.showBtn and self.IsGeted and (not isBind or not isThis))
	SetActiveWithState(self, "GoBindCost", isBind and not isThis)

	if isBind and not isThis then
		local bindCost = GetConfigArgJson("AvatarBindCost")

		self.BindCostText.text = string.format("[%d] %d", GetEmojiId(bindCost[1]), bindCost[2])
	end

	local active = OperationActiveMgr:Get(self.avatarData.InfoAvatar.data.AvatarFrom)

	if active then
		local num = active.data.BuffSkillID[1]

		self.TxtBPPeriod.text = num

		local path

		path = num == 1 and "UI/PageFittingroom/AtlasCellAvatar/fontNumTy1b_st" or num == 2 and "UI/PageFittingroom/AtlasCellAvatar/fontNumTy1b_nd" or num == 3 and "UI/PageFittingroom/AtlasCellAvatar/fontNumTy1b_rd" or "UI/PageFittingroom/AtlasCellAvatar/fontNumTy1b_th"

		if not string.isNullOrEmpty(path) then
			SetImageSprite(self.ImgBPPeriod, path, self)
		end
	end
end

function CellAvatar:UpdateSlectState(state)
	SetActiveWithState(self, "GoSel", state)
end

function CellAvatar:UpdateNew()
	local isNew = RoleRDL.FittingRDL.IsNewAvatar(self.infoRole, self.avatarData.id)

	SetActiveWithState(self, "GoNew", isNew)
end

function CellAvatar:ShowCheckMark(avatarData)
	local isShow = not avatarData.InfoAvatar:IsBPAvatar() and avatarData.IsUnlocked

	self.GoCheckMark:SetActive(isShow)
	self.GoCheckedMark:SetActive(isShow and avatarData.checkmark)
end

function CellAvatar:OnPointerLongPress(data)
	if self.showBtn then
		return
	end

	local itemInfo = ItemManager:GetValueItem(571, self.avatarData.InfoAvatar.id)

	if self.IsBP then
		itemInfo = ItemManager:GetValueItem(573, self.avatarData.InfoAvatar.id)
	end

	if data.clickCount == 1 then
		itemInfo.tempRoleId = self.infoRole.id

		UIMgr.ShowItemTip(itemInfo)
	end
end

function CellAvatar:OnClickBtnBind()
	if self.page and self.page.RequestBind then
		self.page:RequestBind(self.avatarData)
	end
end

function CellAvatar:OnClickBtnGoFrom()
	if self.page and self.page.GotoFromWhere then
		self.page:GotoFromWhere(self.avatarData.InfoAvatar)
	end
end
