-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageEquipment/PageEquipAvatar.lua

require("UI/Page/PageFittingroom/CellAvatar")
require("UI/Page/PageRole/DlgPreviewWeapon")
require("UI/Page/PageEquipment/DlgNewSkin")

PageEquipAvatar = class("PageEquipAvatar", UIPanel)

function PageEquipAvatar:ctor()
	self.UIPrefabPath = "UI/PanelEquipment/PanelEquipAvatar"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_RoleEquip"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())

	self.DlgCharacterThin = DlgCharacterThin()

	self:AddChildPanel(self.DlgCharacterThin)
end

function PageEquipAvatar:PreLoad()
	self:LoadResAsync("UI/PageFittingroom/CellAvatar", "PrefabCellAvatar", GameObject)
end

function PageEquipAvatar:OnBack()
	UIMgr.PopPanel()
end

function PageEquipAvatar:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellAvatar)
	UIMgr.SwitchPreviewActor()

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.DlgPreviewWeapon then
		self.DlgPreviewWeapon:Purge()

		self.DlgPreviewWeapon = nil
	end

	InfoSoundEventMgr:OnBack()
end

function PageEquipAvatar:OnRegisterEvent()
	self:AddClick(self.BtnDetail, self.OnClickBtnDetail)
	self:AddClick(self.BtnConfirm, self.OnClickBtnConfirm)
	self:AddClick(self.BtnAttrDetail, self.OnClickBtnAttrDetail)
	Event.Instance:Add("UpdateShowCharacter", self.UpdateRole, self)
	Event.Instance:Add("GotoFromWhere", self.GotoFromWhere, self)
end

function PageEquipAvatar:OnUnRegisterEvent()
	self:RemoveClick(self.BtnDetail, self.OnClickBtnDetail)
	self:RemoveClick(self.BtnConfirm, self.OnClickBtnConfirm)
	self:RemoveClick(self.BtnAttrDetail, self.OnClickBtnAttrDetail)

	if self.initedDetail then
		self:RemoveClick(self.BtnDetailQuit, self.OnClickBtnDetailQuit)
		self:RemoveClick(self.BtnGotoUnlock, self.OnClickBtnGotoUnlock)
	end

	Event.Instance:Remove("UpdateShowCharacter", self.UpdateRole, self)
	Event.Instance:Remove("GotoFromWhere", self.GotoFromWhere, self)
end

function PageEquipAvatar:OnEnter(vParam)
	if not GuideMgr:IsGuided(GuideFunctionType.EquipAvatar) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.EquipAvatar)
	end

	self:DealWithLocalization()

	self.PanelDetail = self:GetChildGameObject("PanelDetail")

	for k in ipairs(ATTRIBUTE_MAP[1]) do
		self["TxtValue" .. k] = self:GetChildComponent("PanelAvatar/Panel/Attr/" .. k .. "/TxtValue", "Text")
		self["GoAddSign" .. k] = self:GetChildGameObject("PanelAvatar/Panel/Attr/" .. k .. "/AddSign")
	end

	self.FromWhere = self:GetChildGameObject("PanelAvatar/Panel/BtnGroup/From")
	self.TxtFromWhere = GOUtil.FindChildComponent(self.FromWhere, "Text", "Text")
	self.BtnDetail = self:GetChildGameObject("PanelAvatar/Panel/BtnGroup/BtnDetail")
	self.BtnConfirm = self:GetChildGameObject("PanelAvatar/Panel/BtnGroup/BtnConfirm")
	self.BtnAttrDetail = self:GetChildGameObject("PanelAvatar/Panel/BtnDetail")
	self.TxtConfirm = GOUtil.FindChildComponent(self.BtnConfirm, "Text", "Text")

	self:InitData(vParam)
	UIMgr.BuildPreviewActor(eActorSystemType.AVATAR)
end

function PageEquipAvatar:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("PanelAvatar/Panel/Title/Text", "Text")
	txt.text = Lang(42292)
	txt = self:GetChildComponent("PanelAvatar/Panel/BtnGroup/BtnDetail/Text", "Text")
	txt.text = Lang(12265)

	for i = 1, #ATTRIBUTE_MAP[1] do
		txt = self:GetChildComponent("PanelAvatar/Panel/Attr/" .. i .. "/Text", "Text")
		txt.text = _("eAttType_" .. i)
	end
end

function PageEquipAvatar:InitData(vParam)
	if vParam and vParam.avatarId then
		self.avatarId = vParam.avatarId
	end

	local infoRole

	if vParam and vParam.roleId then
		infoRole = RoleMgr:GetRole(vParam.roleId)

		CharacterThinMgr.DoResetOperate(CharacterThinMgr.ResetType.SKIP, vParam.roleId)
		self.DlgCharacterThin:Init()
	else
		local lastRoleId = CharacterThinMgr.LastData(THIN_SYSTEM_TYPE.Role).id

		infoRole = RoleMgr:GetRole(lastRoleId)
	end

	self:UpdateRole(infoRole, true)
end

function PageEquipAvatar:UpdateRole(role, updateswitch)
	if role == nil then
		return
	end

	self.infoRole = role

	if updateswitch then
		self:UpdateListRole()
	end

	self:InitAvatarData()
	RoleRDL.NewRDL.SubNewRolePlayerPrefs(role)
end

function PageEquipAvatar:UpdateListRole()
	local listRole = CharacterThinMgr.SwitchData(THIN_SYSTEM_TYPE.Role).roles

	if #listRole > 1 then
		if not self.ArrowState then
			self.ArrowState = true
		end
	elseif self.ArrowState then
		self.ArrowState = false
	end
end

function PageEquipAvatar:InitAvatarData()
	self.selectIndex = 1
	self.listAvatar = AvatarManager:GetWeaponAvatarList(self.infoRole)

	for k, v in pairs(self.listAvatar) do
		if v.RealEquiped then
			self.selectIndex = k

			break
		end
	end

	self:InitScrollView()
	self:UpdateBtnGroup()
	self:UpateAvatarAttr()
end

function PageEquipAvatar:UpateAvatarAttr()
	local avatarData = self.listAvatar[self.selectIndex]

	for k, v in ipairs(ATTRIBUTE_MAP[1]) do
		local holdSum = ExchangeAttValue(v, self.infoRole.equipBaseAtt:Get(v) * self.infoRole.equipAvatarAtt:GetExtraMul(v) + self.infoRole.equipAvatarAtt:GetExtraAdd(v))
		local add = 0

		if avatarData.Geted then
			self["TxtValue" .. k].text = holdSum
		else
			add = ExchangeAttValue(v, self.infoRole.equipBaseAtt:Get(v) * avatarData.InfoAvatar:GetMulAtt(v) + avatarData.InfoAvatar:GetAddAtt(v))

			if add > 0 then
				self["TxtValue" .. k].text = holdSum + add .. "<size=28><color=#36A536>(+" .. add .. ")</color></size>"
			else
				self["TxtValue" .. k].text = holdSum
			end
		end

		GOUtil.SetActive(self["GoAddSign" .. k], add > 0)
	end
end

function PageEquipAvatar:InitScrollView()
	if self.UIScrollTool then
		self.UIScrollTool:UpdateListData(self.listAvatar)

		return
	end

	local scrollArea = self:GetChildGameObject("PanelAvatar/Panel/Scroll")
	local content = self:GetChildComponent("PanelAvatar/Panel/Scroll/Content", "RectTransform")
	local count = #self.listAvatar

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCell)
	end

	local function updateCallback(item, index)
		item:UpdateData(self.listAvatar[index], self.selectIndex, self.infoRole)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellAvatar, CellAvatar, self, false, addCallback, updateCallback)

	if self.avatarId ~= nil then
		for i, v in ipairs(self.listAvatar) do
			if v.id == self.avatarId then
				local pos = GetContentPos(self.UIScrollTool.ScrollView, math.ceil(#self.listAvatar / 3), math.ceil(i / 3), true)

				self.UIScrollTool:SetInitPos(Vector3(0, pos, 0))

				break
			end
		end
	end
end

function PageEquipAvatar:OnClickedCell(data)
	local go = data.pointerPress
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)

	if info.Item.Index == self.selectIndex then
		return
	end

	self.selectIndex = info.Item.Index

	InfoSoundEventMgr:LoadBank(self.infoRole.data.VocalBank)
	InfoSoundEventMgr:Play("VocalCommon2", self.infoRole.data.VocalCommon2)
	self:TempEquip()
	self:UpdateBtnGroup()
	self:UpateAvatarAttr()
end

function PageEquipAvatar:TempEquip()
	for _, avatarData in pairs(self.listAvatar) do
		avatarData.Equiped = false
	end

	local avatarData = self.listAvatar[self.selectIndex]

	if avatarData == nil then
		return
	end

	avatarData.Equiped = true

	UIMgr.PreviewActor:EquipAvatar(avatarData.InfoAvatar.id)

	if RoleRDL.FittingRDL.IsNewAvatar(self.infoRole, avatarData.id) then
		RoleRDL.FittingRDL.SubNewAvatarId(self.infoRole, avatarData.id)
	end

	self.UIScrollTool:UpdateListDataKeepPos(self.listAvatar)
end

function PageEquipAvatar:UpdateBtnGroup()
	local avatarData = self.listAvatar[self.selectIndex]

	if avatarData == nil then
		return
	end

	local isLock = not avatarData.IsUnlocked
	local isGet = avatarData.Geted

	if isGet then
		self.avatarState = 1

		if avatarData.Equiped and not avatarData.RealEquiped then
			self.TxtConfirm.text = Lang(9123)
		end
	elseif isLock then
		self.avatarState = 2
	else
		self.avatarState = 3
		self.TxtConfirm.text = Lang(12246)
	end

	GOUtil.SetActive(self.BtnConfirm, self.avatarState == 1 and avatarData.Equiped and not avatarData.RealEquiped or self.avatarState == 3)
	GOUtil.SetActive(self.BtnDetail, true)
end

function PageEquipAvatar:OnClickBtnConfirm()
	if self.avatarState == 1 then
		self:OnEquip()
	elseif self.avatarState == 2 then
		-- block empty
	elseif self.avatarState == 3 then
		self:OnBtnBuy()
	end
end

function PageEquipAvatar:OnEquip()
	local avatarData = self.listAvatar[self.selectIndex]

	local function wrap_cb()
		for _, avatarData in pairs(self.listAvatar) do
			avatarData.RealEquiped = false
			avatarData.Equiped = false
		end

		avatarData.RealEquiped = true

		self:UpdateBtnGroup()
		self.UIScrollTool:UpdateListDataKeepPos(self.listAvatar)
		UIMgr.PreviewActor:EquipAvatar(avatarData.id)

		if UIMgr.PreviewActor.DlgRoleInfo then
			UIMgr.PreviewActor.DlgRoleInfo:UpdateEquipWeaponIcon()
		end
	end

	self:RequestOperateAvatar(avatarData.id, wrap_cb)
end

function PageEquipAvatar:RequestOperateAvatar(id, callback)
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self.infoRole.pb.weaponAvatar = id

			if callback then
				callback()
			end
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestEquipWeaponAvatar(self.infoRole.id, id, wrap_cb)
end

function PageEquipAvatar:OnBtnBuy()
	local function wrap_cb(type)
		if type == DlgCommonEvent.ButtonType.Ok then
			self:RequestBuyAvatar()
		end
	end

	local infoAvatar = self.listAvatar[self.selectIndex].InfoAvatar
	local msg = string.format(_("Desc_Buy_Emoji_Format"), GetEmojiId(infoAvatar.data.Cost[1]), infoAvatar.data.Cost[2], infoAvatar:GetName())

	UIMgr.ShowCommon(DlgCommonEvent.Type.Confirm, _("Tittle_Affirm"), msg, callback, _("Button_Yes"), nil, true)
end

function PageEquipAvatar:RequestBuyAvatar()
	local avatarData = self.listAvatar[self.selectIndex]

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			avatarData.Geted = true

			table.insert(self.infoRole.pb.avatars, avatarData.id)
			self.infoRole:UpdateEquipAvatarAttr(true)
			self.UIScrollTool:UpdateListDataKeepPos(self.listAvatar)
			self:UpdateBtnGroup()
			self:UpateAvatarAttr()
			UIMgr.AddPanel(DlgNewSkin(), {
				self.infoRole,
				avatarData.InfoAvatar
			})
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestBuyAvatar(self.infoRole.id, {
		avatarData.id
	}, wrap_cb)
end

function PageEquipAvatar:OnClickBtnDetail()
	self.PanelDetail:SetActive(true)
	self:InitAvatarDetail()
end

function PageEquipAvatar:InitAvatarDetail()
	if not self.initedDetail then
		local txt = self:GetChildComponent("PanelAvatar/Panel/BtnDetail/Text", "Text")

		txt.text = _("UI_Active_View")
		txt = self:GetChildComponent("PanelDetail/Panel/BtnGoto/Text", "Text")
		txt.text = _("Desc_goUnlock")
		self.TxtAvatarName = self:GetChildComponent("PanelDetail/Panel/Title/Text", "Text")
		self.BtnDetailQuit = self:GetChildGameObject("PanelDetail/Panel/Button")
		self.BtnGotoUnlock = self:GetChildGameObject("PanelDetail/Panel/BtnGoto")
		self.GoUnlockPrompt = self:GetChildGameObject("PanelDetail/Panel/Prompt")
		self.TxtPrompt = GOUtil.FindChildComponent(self.GoUnlockPrompt, "Text", "Text")

		self:AddClick(self.BtnGotoUnlock, self.OnClickBtnGotoUnlock)
		self:AddClick(self.BtnDetailQuit, self.OnClickBtnDetailQuit)

		local control2 = self:GetChildComponent("PanelDetail/Panel/RawImage", "UI3DRenderControl")

		self.DlgPreviewWeapon = DlgPreviewWeapon()

		self.DlgPreviewWeapon:Init(control2)

		self.initedDetail = true
	end

	self:UpdateAvatarDetail()
end

function PageEquipAvatar:UpdateAvatarDetail()
	if self.listAvatar == nil or #self.listAvatar == 0 then
		return
	end

	local avatarData = self.listAvatar[self.selectIndex]

	if avatarData == nil then
		return
	end

	if self.preSelectIdx ~= self.selectIndex then
		self.preSelectIdx = self.selectIndex
		self.TxtAvatarName.text = avatarData.InfoAvatar:GetName()

		GOUtil.SetActive(self.BtnGotoUnlock, not avatarData.IsUnlocked)
		GOUtil.SetActive(self.GoUnlockPrompt, not avatarData.IsUnlocked)

		if not avatarData.IsUnlocked then
			self.TxtPrompt.text = string.format(_("Desc_Avatar_Unlock_Way"), _("Avatar_From_" .. avatarData.InfoAvatar.data.FromWhere))
		end
	end

	self.DlgPreviewWeapon:EquipAvatar(avatarData.id)
end

function PageEquipAvatar:OnClickBtnDetailQuit()
	self.PanelDetail:SetActive(false)
	self.DlgPreviewWeapon:Exit()
end

function PageEquipAvatar:OnClickBtnAttrDetail()
	require("UI/Page/PageEquipment/DlgWeaponAvatarAttr")
	UIMgr.AddPanel(DlgWeaponAvatarAttr(), self.infoRole)
end

function PageEquipAvatar:OnClickBtnGotoUnlock()
	local infoAvatar = self.listAvatar[self.selectIndex].InfoAvatar

	AvatarManager.GotoFromWhere(self.infoRole, infoAvatar)
end

function PageEquipAvatar:GotoFromWhere(infoAvatar, cb)
	AvatarManager.GotoFromWhere(self.infoRole, infoAvatar, cb)
end

function PageEquipAvatar:OnClickedGuideBtn()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.EquipAvatar)
end

function PageEquipAvatar:OnBackAndroid()
	if self.DlgCharacterThin and GOUtil.IsActiveSelf(self.DlgCharacterThin.GoClick) then
		self.DlgCharacterThin:OnClickBack()

		return true
	end

	if self.PanelDetail and GOUtil.IsActiveSelf(self.PanelDetail) then
		self:OnClickBtnDetailQuit()

		return true
	end

	return false
end
