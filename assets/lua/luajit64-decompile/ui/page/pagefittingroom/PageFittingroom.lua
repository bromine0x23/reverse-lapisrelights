-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFittingroom/PageFittingroom.lua

require("UI/Dlg/Public/DlgExit")
require("UI/Page/PageFittingroom/CellAvatar")
require("Info/InfoAvatar")
require("UI/Dlg/Common/DlgCardFilter")
require("UI/Page/PageRole/DlgPreviewActor")
require("UI/Page/PageFittingroom/DlgAvatarSelBuy")
require("UI/Page/PageFittingroom/DlgNeedGet")
require("UI/Page/PageFittingroom/DlgAvatarMode")

PageFittingroom = class("PageFittingroom", UIPanel, true)

function PageFittingroom:ctor()
	self.UIPrefabPath = "UI/PageFittingroom/PanelFittingroom"
	self.DlgAvatarMode = DlgAvatarMode()

	self:AddChildPanel(self.DlgAvatarMode, {
		page = self
	})
	self:AddChildPanel(DlgExit(), {
		panel = self,
		title = _("eReturn_Avatar"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn
	})
	self:AddChildPanel(DlgAssetsInfo())

	self.DlgCharacterThin = DlgCharacterThin(THIN_SYSTEM_TYPE.Role, THIN_PAGE_TYPE.Fitting)

	self:AddChildPanel(self.DlgCharacterThin)
end

function PageFittingroom:PreLoad()
	self:LoadResAsync("UI/PageFittingroom/CellAvatar", "PrefabCell", GameObject)
end

function PageFittingroom:OnBack()
	if self.data then
		if self.data.from == 3 then
			SceneMgr.LoadScene("AR", {
				infoRole = self.infoRole,
				index = PageInteraction.jumpARIndex
			})

			return
		elseif self.data.teamSystemAgent then
			UIMgr.PopPanel(self.data.teamSystemAgent)

			return
		end
	end

	UIMgr.PopPanel()
end

function PageFittingroom:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCell)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.DlgPreviewActor then
		self.DlgPreviewActor:Purge()

		self.DlgPreviewActor = nil
	end

	self:ClearAvatarFactory()
	InfoSoundEventMgr:OnBack()
	EffectMgr:UnLoadEffect("Fx/UI/Eff_Ui_Huanzhuang/Eff_Ui_Huanzhuang")

	if not self.notResetRecord then
		AvatarManager.LastEquipAvatar = {}
	end
end

function PageFittingroom:ClearSlotAvatarFactory(slot)
	if self.listAvatarFactory and self.listAvatarFactory[slot] then
		self.listAvatarFactory[slot]:Purge()

		self.listAvatarFactory[slot] = nil
	end
end

function PageFittingroom:ClearAvatarFactory()
	if self.listAvatarFactory then
		for _, v in pairs(self.listAvatarFactory) do
			if v ~= nil then
				v:Purge()
			end
		end

		self.listAvatarFactory = nil
	end
end

function PageFittingroom:OnRegisterEvent()
	for i = 1, self.TabCnt do
		self:AddClick(self["BtnTab" .. i], self.OnClickTab)
	end

	self:AddClick(self.BtnRoleL, self.OnClickBtnRoleL)
	self:AddClick(self.BtnRoleR, self.OnClickBtnRoleR)
	self:AddClick(self.BtnAttr, self.OnClickBtnAttr)
	self:AddClick(self.BtnShop, self.OnClickBtnShop)
	self:AddClick(self.BtnSave, self.OnClickBtnSave)
	self:AddClick(self.BtnRestore, self.RestoreRoleMode)
	Event.Instance:Add("SyncServerModeData", self.RequestOperateAvatar, self)
	Event.Instance:Add("UpdateShowCharacter", self.UpdateRole, self)
	Event.Instance:Add("GotoFromWhere", self.GotoFromWhere, self)
	Event.Instance:Add("UpdateAfterGetAvatar", self.UpdateAfterGetAvatar, self)
	Event.Instance:Add("DoAfterBuyAvatar", self.DoAfterBuyAvatar, self)
	Event.Instance:Add("AvatarShelfRefresh", self.AvatarShelfRefresh, self)
end

function PageFittingroom:OnUnRegisterEvent()
	for i = 1, self.TabCnt do
		self:RemoveClick(self["BtnTab" .. i], self.OnClickTab)
	end

	self:RemoveClick(self.BtnRoleL, self.OnClickBtnRoleL)
	self:RemoveClick(self.BtnRoleR, self.OnClickBtnRoleR)
	self:RemoveClick(self.BtnAttr, self.OnClickBtnAttr)
	self:RemoveClick(self.BtnShop, self.OnClickBtnShop)
	self:RemoveClick(self.BtnSave, self.OnClickBtnSave)
	self:RemoveClick(self.BtnRestore, self.RestoreRoleMode)
	Event.Instance:Remove("SyncServerModeData", self.RequestOperateAvatar, self)
	Event.Instance:Remove("UpdateShowCharacter", self.UpdateRole, self)
	Event.Instance:Remove("GotoFromWhere", self.GotoFromWhere, self)
	Event.Instance:Remove("UpdateAfterGetAvatar", self.UpdateAfterGetAvatar, self)
	Event.Instance:Remove("DoAfterBuyAvatar", self.DoAfterBuyAvatar, self)
	Event.Instance:Remove("AvatarShelfRefresh", self.AvatarShelfRefresh, self)
end

function PageFittingroom:DealWithLocalization()
	self.TextBPTip = self:GetChildComponent("Panel/AvatarList/BgScroll/TextBp", "Text")
	self.TextBPTip.text = _("Desc_BpPromptMessage")
	self.TextTempTip = self:GetChildComponent("Panel/AvatarList/Deal/TxtPrompt", "Text")
	self.TextTempTip.text = Lang(42287)

	local txt

	txt = self:GetChildComponent("Panel/AvatarList/Deal/BtnSave/Text", "Text")
	txt.text = _("UI_FittingRoomSave")
	txt = self:GetChildComponent("Panel/BtnAtt/Text", "Text")
	txt.text = Lang(12021)
	txt = self:GetChildComponent("Panel/AvatarList/Deal/BtnReset/Text", "Text")
	txt.text = Lang(5000020)
end

function PageFittingroom:OnEnter(vParam)
	InstructionMgr:TriggerWait("ShowFitting")

	if not GuideMgr:IsGuided(GuideFunctionType.Avatar) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.Avatar)
	end

	self:DealWithLocalization()

	local config = GetConfigArgJson("AvatarTabType")

	self.TabCnt = table.getCount(config)
	self.TabConfig = {}

	for _, v in ipairs(config) do
		table.insert(self.TabConfig, v[1])
	end

	local tabGroup = self:GetChildGameObject("Panel/AvatarList/TabGroup")
	local tab = self:GetChildGameObject("Panel/AvatarList/TabGroup/Tab")
	local imgIcon1, imgIcon2, path

	for i = 1, self.TabCnt do
		if i == 1 then
			self["GoTab" .. i] = tab
		else
			self["GoTab" .. i] = GOUtil.InstantiateUI(tab, tabGroup)
		end

		self["BtnTab" .. i] = GOUtil.FindChildGameObject(self["GoTab" .. i], "Btn")
		self["SelTab" .. i] = GOUtil.FindChildGameObject(self["GoTab" .. i], "Sel")
		self["RealEquip" .. i] = GOUtil.FindChildGameObject(self["GoTab" .. i], "RealEquip")
		self["TempEquip" .. i] = GOUtil.FindChildGameObject(self["GoTab" .. i], "TempEquip")
		imgIcon1 = GOUtil.FindChildComponent(self["BtnTab" .. i], "Icon", "Image")
		path = table.concat({
			"UI/PageFittingroom/Atlas/",
			config[i][2]
		})

		SetImageSprite(imgIcon1, path, self)

		imgIcon2 = GOUtil.FindChildComponent(self["SelTab" .. i], "Icon", "Image")
		path = table.concat({
			path,
			"a"
		})

		SetImageSprite(imgIcon2, path, self)

		self["GoTab" .. i].name = self.TabConfig[i]
	end

	self.BtnShop = self:GetChildGameObject("Panel/AvatarList/Deal/BtnShop/Click")
	self.BtnSave = self:GetChildGameObject("Panel/AvatarList/Deal/BtnSave")
	self.BtnRestore = self:GetChildGameObject("Panel/AvatarList/Deal/BtnReset")
	self.ImgShopCar = self:GetChildComponent("Panel/AvatarList/Deal/BtnShop", "Image")
	self.GoShopNum = self:GetChildGameObject("Panel/AvatarList/Deal/BtnShop/BgCnt")
	self.TxtShopCnt = self:GetChildComponent("Panel/AvatarList/Deal/BtnShop/BgCnt/TxtCnt", "Text")
	self.GoNoneTip = self:GetChildGameObject("Panel/AvatarList/BgScroll/Tip")
	self.GoArrow = self:GetChildGameObject("Panel/Arrow")
	self.ArrowState = true
	self.BtnRoleL = self:GetChildGameObject("Panel/Arrow/BtnL")
	self.BtnRoleR = self:GetChildGameObject("Panel/Arrow/BtnR")
	self.BtnAttr = self:GetChildGameObject("Panel/BtnAtt")
	self.GoAttr1 = self:GetChildGameObject("Panel/BtnAtt/Image1")
	self.GoAttr2 = self:GetChildGameObject("Panel/BtnAtt/Image2")
	self.AnimBindPrompt = self:GetChildComponent("Panel/Prompt", "Animator")
	self.BPBindPrompt1 = self:GetChildGameObject("Panel/Prompt/Image1")
	self.TxtBindName1 = self:GetChildComponent("Panel/Prompt/Image1/Text", "Text")
	self.TxtBPAtt1 = self:GetChildComponent("Panel/Prompt/Image1/Text1", "Text")
	self.BPBindPrompt2 = self:GetChildGameObject("Panel/Prompt/Image2")
	self.TxtBindName2 = self:GetChildComponent("Panel/Prompt/Image2/Text", "Text")
	self.TxtBPAtt2 = self:GetChildComponent("Panel/Prompt/Image2/Text1", "Text")
	self.data = vParam
	self.obj = self:GetChildGameObject("Panel/Character")

	local control = GOUtil.AddMissingComponent(self.obj, "UI3DRenderControl")

	self.DlgPreviewActor = DlgPreviewActor()
	self.DlgPreviewActor.IsLeft = true

	self.DlgPreviewActor:Init(control)

	self.preAvatarSlot = {}

	self:InitData()
end

function PageFittingroom:OnActorLoaded()
	if self.DlgPreviewActor and self.DlgPreviewActor.actor then
		local actor = self.DlgPreviewActor.actor

		actor.SkeletonSystem:SetSpringPreventRefresh(true)
	end
end

function PageFittingroom:GetTabIndex(avatarTabType)
	local idx = table.getIndex(self.TabConfig, avatarTabType)

	return idx == -1 and 1 or idx
end

function PageFittingroom:InitData()
	local infoRole

	if self.data and self.data.infoRole then
		infoRole = self.data.infoRole

		CharacterThinMgr.DoResetOperate(CharacterThinMgr.ResetType.SKIP, infoRole.id)
		self.DlgCharacterThin:Init()
		UIMgr.ClearClassStackData(self.className)
	else
		infoRole = RoleMgr:GetRole(CharacterThinMgr.LastData(THIN_SYSTEM_TYPE.Role).id)
	end

	self.curtabIdx = self:GetTabIndex(eAvatarTabType.Event)

	if self.data and self.data.avatarId then
		local infoAvatar = AvatarManager:GetAvatar(self.data.avatarId)

		self.curtabIdx = self:GetTabIndex(infoAvatar.data.AvatarTabType)
	elseif AvatarManager.needPresave and AvatarManager.curTabIndex > 0 then
		self.curtabIdx = AvatarManager.curTabIndex
		AvatarManager.curTabIndex = 0
	end

	self.pretabIdx = self.curtabIdx
	self.listAvatarFactory = {}

	self:SelectTab()
	self:UpdateRole(infoRole)
end

function PageFittingroom:UpdateRole(infoRole)
	if not infoRole or not infoRole.hold then
		return
	end

	self.infoRole = infoRole

	self.DlgAvatarMode:UpdateRoleMode(self.infoRole)

	self.needResetEquip = false

	if table.getCount(AvatarManager.LastEquipAvatar) ~= 0 then
		if AvatarManager.LastEquipAvatar.roleId == self.infoRole.id and AvatarManager.needPresave then
			self.infoRole:SetTempEquipAvatarIds(AvatarManager.LastEquipAvatar.avatarIds)

			self.needResetEquip = true
		else
			local role = self.infoRole

			if role ~= AvatarManager.LastEquipAvatar.roleId then
				role = RoleMgr:GetRole(AvatarManager.LastEquipAvatar.roleId)
			end

			role:SetTempEquipAvatarIds()

			AvatarManager.LastEquipAvatar = {}
		end
	end

	self:UpdateOneTime()
	self:UpdateListData(true)
	self:LoadActor()
end

function PageFittingroom:UpdateOneTime()
	self.listDefault = {}

	for i = 1, #self.infoRole.actorData.DefaultAvatars do
		local id = self.infoRole.actorData.DefaultAvatars[i]

		table.insert(self.listDefault, id)
	end

	local cur = #CharacterThinMgr.SwitchData(THIN_SYSTEM_TYPE.Role).roles > 1

	if cur ~= self.pre then
		SetActiveWithState(self, "GoArrow", cur)

		self.pre = cur
	end

	for i = 1, self.TabCnt do
		RedDotSystemMgr.SetUIRedDot(self["GoTab" .. i], "Role/" .. self.infoRole.id .. "/Fitting/" .. self.TabConfig[i])
	end

	RoleRDL.NewRDL.SubNewRolePlayerPrefs(self.infoRole)
end

function PageFittingroom:LoadActor()
	self:ClearAvatarFactory()

	if self.DlgPreviewActor then
		self.DlgPreviewActor.isRTCameraFar = false

		if self.TabConfig[self.curtabIdx] == eAvatarTabType.Body then
			self.DlgPreviewActor.isRTCameraFar = true
		end

		self.DlgPreviewActor.cb = wrapedCb(self.OnActorLoaded, self)

		self.DlgPreviewActor:LoadActor(self.infoRole, true, nil, nil)
	end

	if self.needResetEquip then
		self.infoRole:SetTempEquipAvatarIds()

		AvatarManager.LastEquipAvatar = {}
		self.needResetEquip = false
	end
end

function PageFittingroom:UpdateListData(resetData, keepPos, resetPos)
	if resetData then
		self:UpdateDictAndEquipAvatar()
	end

	self:UpdateScrollView(keepPos, resetPos)
	self:UpdateExecutableState()
end

function PageFittingroom:UpdateDictAndEquipAvatar()
	self.curMode = self.DlgAvatarMode.curMode
	self.dictAvatar = {}

	for i = 1, self.TabCnt do
		local t = AvatarManager:GetListAvatar(self.infoRole, self.TabConfig[i])

		table.insert(self.dictAvatar, t)
	end

	for i = 1, #self.dictAvatar do
		self:UpdateSort(i)
		self:UpdateEquipTag(i)
	end

	self.listEquip = {}

	local t = self.infoRole:GetEquipAvatarIds()

	for i = 1, #t do
		table.insert(self.listEquip, t[i])

		if self.needResetEquip then
			self:SubNewAvatarDot(t[i])
		end
	end
end

function PageFittingroom:UpdateSort(curtabIdx)
	table.sort(self.dictAvatar[curtabIdx], function(a, b)
		local priority = -1000
		local k1 = 10000
		local k2 = 10000
		local d = 1

		if self.TabConfig[curtabIdx] == eAvatarTabType.BP then
			d = 10

			if a.Geted then
				k1 = k1 + priority * d
			end

			if b.Geted then
				k2 = k2 + priority * d
			end

			d = 11

			if a.InfoAvatar:IsBPAvatar() then
				k1 = k1 + priority * d
			end

			if b.InfoAvatar:IsBPAvatar() then
				k2 = k2 + priority * d
			end

			d = 12

			if not a.Geted and not a.IsCanGotoGet then
				k1 = k1 + priority * d
			end

			if not b.Geted and not b.IsCanGotoGet then
				k2 = k2 + priority * d
			end
		else
			d = 10

			if not a.Geted then
				k1 = k1 + priority * d
			end

			if not b.Geted then
				k2 = k2 + priority * d
			end

			d = 11

			if not a.RealEquiped then
				k1 = k1 + priority * d
			end

			if not b.RealEquiped then
				k2 = k2 + priority * d
			end
		end

		d = 2

		if a.InfoAvatar.data.FromWhere > 0 then
			k1 = k1 + priority * d
		end

		if b.InfoAvatar.data.FromWhere > 0 then
			k2 = k2 + priority * d
		end

		if k1 == k2 then
			if (a.Order or 0) == (b.Order or 0) then
				return a.id < b.id
			else
				return (a.Order or 0) < (b.Order or 0)
			end
		end

		return k2 < k1
	end)
end

function PageFittingroom:UpdateExecutableState()
	local listAll = {}
	local listNeedBuy = {}
	local existNotBind = false

	for _, id in ipairs(self.listEquip) do
		local avatarData = AvatarManager:GetAvatarData(self.infoRole, id, self.curMode.id)

		if self.IntoShopCar(avatarData, self.infoRole) then
			table.insert(listAll, avatarData)

			if avatarData.IsUnlocked and not avatarData.Geted then
				table.insert(listNeedBuy, avatarData)
			end
		end

		local bpAvatar = PlayerInst:GetBPAvatar(id)

		if bpAvatar and bpAvatar.roleId ~= self.infoRole.id then
			existNotBind = true
		end
	end

	SetActiveWithState(self, "TextBPTip", existNotBind, true)
	SetActiveWithState(self, "GoShopNum", #listAll > 0)

	self.TxtShopCnt.text = #listAll

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgShopCar, TenaryOp(#listAll > 0, 0, 1)))

	local isModify = self:CheckEquipedModeModify()

	SetActiveWithState(self, "TextTempTip", not isModify, true)
	SetActiveWithState(self, "BtnRestore", isModify)
	SetActiveWithState(self, "BtnSave", isModify)
	SetActiveWithState(self, "BtnAttr", #self.infoRole.bpAvatars > 0)
end

function PageFittingroom:SelectTab(index)
	if index ~= nil then
		self.pretabIdx = self.curtabIdx
		self.curtabIdx = index or self:GetTabIndex(eAvatarTabType.Event)
	end

	if self.DlgPreviewActor then
		self.DlgPreviewActor.isRTCameraFar = true

		if self.TabConfig[self.curtabIdx] ~= eAvatarTabType.Body then
			self.DlgPreviewActor.isRTCameraFar = false
		end

		self.DlgPreviewActor:ChangeView()
	end

	for i = 1, self.TabCnt do
		if i == self.pretabIdx and self.curtabIdx ~= self.pretabIdx then
			self["BtnTab" .. i]:SetActive(true)
			self["SelTab" .. i]:SetActive(false)
		end

		if i == self.curtabIdx then
			self["BtnTab" .. i]:SetActive(false)
			self["SelTab" .. i]:SetActive(true)
		end
	end
end

function PageFittingroom:UpdateEquipTag(tabIdx)
	local function funRefresh(idx)
		local hasRealEquiped = false
		local hasTempEquiped = false

		if self.dictAvatar[idx] then
			for _, avatarData in ipairs(self.dictAvatar[idx]) do
				if avatarData.RealEquiped then
					hasRealEquiped = true
				elseif avatarData.Equiped then
					hasTempEquiped = true
				end
			end
		end

		SetActiveWithState(self, "RealEquip" .. idx, hasRealEquiped)
		SetActiveWithState(self, "TempEquip" .. idx, hasTempEquiped)
	end

	if tabIdx then
		funRefresh(tabIdx)
	else
		for i = 1, self.TabCnt do
			funRefresh(i)
		end
	end
end

function PageFittingroom:OnClickTab(data)
	local index = self:GetTabIndex(data.pointerPress.transform.parent.name)

	if type(index) ~= "number" or self.curtabIdx == index then
		return
	end

	self:SelectTab(index)
	self:UpdateScrollView(false, true)
end

function PageFittingroom:UpdateScrollView(keepPos, resetPos)
	local cur = #self.dictAvatar[self.curtabIdx] <= 0

	if self.preNoneState ~= cur then
		SetActiveWithState(self, "GoNoneTip", cur)

		self.preNoneState = cur
	end

	if self.UIScrollTool then
		if keepPos then
			self.UIScrollTool:UpdateListDataKeepPos(self.dictAvatar[self.curtabIdx])
		else
			if resetPos then
				-- block empty
			end

			self.UIScrollTool:UpdateListData(self.dictAvatar[self.curtabIdx])
		end

		return
	end

	local ScrollArea = self:GetChildGameObject("Panel/AvatarList/ScrollArea")
	local content = self:GetChildComponent("Panel/AvatarList/ScrollArea/Content", "Transform")
	local count = #self.dictAvatar[self.curtabIdx]

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCell)
	end

	local function updateCallback(item, index)
		local curList = self.dictAvatar[self.curtabIdx]

		item.Index = index

		item:UpdateData(curList[index], nil, self.infoRole)

		item.UIRootObject.name = "cell"
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.PrefabCell, CellAvatar, self, false, addCallback, updateCallback)

	if self.data and self.data.avatarId then
		local initPos

		for i, v in ipairs(self.dictAvatar[self.curtabIdx]) do
			if v.id == self.data.avatarId then
				local pos = GetContentPos(self.UIScrollTool.ScrollView, math.ceil(#self.dictAvatar[self.curtabIdx] / 3), math.ceil(i / 3), true)

				initPos = Vector3(0, pos, 0)

				break
			end
		end

		self.UIScrollTool:SetInitPos(initPos)
	end
end

function PageFittingroom:OnClickedCell(data)
	local go = data.pointerPress
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index
	local avatarData = self.dictAvatar[self.curtabIdx][index]

	self:SubNewAvatarDot(avatarData.id)
	self:TempEquip(avatarData)
	self:UpdateExecutableState()
end

function PageFittingroom:CheckEquipedModeModify()
	local isModify = false

	if #self.curMode.avatars ~= #self.listEquip then
		isModify = true
	else
		for _, v in ipairs(self.listEquip) do
			if not table.contains(self.curMode.avatars, v) then
				isModify = true
			end
		end
	end

	return isModify
end

function PageFittingroom:OnClickBtnRoleL()
	self:OnNext(false)
end

function PageFittingroom:OnClickBtnRoleR()
	self:OnNext(true)
end

function PageFittingroom:OnNext(isR)
	UIMgr.HideMsg2()

	local _type = isR and eDirectionType.R or eDirectionType.L

	CharacterThinMgr.DOSwitch(THIN_SYSTEM_TYPE.Role, _type)
end

function PageFittingroom:UpdateAvatarSelect(avatarId)
	local needHide = false
	local list = {}

	if table.contains(self.listEquip, avatarId) then
		needHide = true
	end

	local slots = AvatarManager:GetAvatar(avatarId).data.Slot
	local listUnEquipId = self:CheckSlot(self.listEquip, slots)

	for i = 1, #listUnEquipId do
		table.insert(list, listUnEquipId[i])
	end

	if self.UIScrollTool.ItemRoot2ItemDict then
		for _, v in self.UIScrollTool.ItemRoot2ItemDict:Enumerator() do
			if v.Item and v.Item.avatarData then
				if table.contains(list, v.Item.avatarData.id) then
					v.Item:UpdateSlectState(false)
				elseif not needHide and v.Item.avatarData.id == avatarId then
					v.Item:UpdateSlectState(true)
				end
			end
		end
	end
end

function PageFittingroom:UpdateEquipState()
	if self.UIScrollTool.ItemRoot2ItemDict then
		for _, v in self.UIScrollTool.ItemRoot2ItemDict:Enumerator() do
			if v.Item and v.Item.avatarData then
				v.Item:UpdateEquipState()
				v.Item:UpdateNew()
			end
		end
	end
end

function PageFittingroom:TempEquip(avatarData)
	if avatarData == nil then
		return
	end

	local curSlot = avatarData.InfoAvatar.data.Slot

	if self.TabConfig[self.curtabIdx] ~= eAvatarTabType.Body and self.DlgPreviewActor then
		self.DlgPreviewActor.isRTCameraFar = true

		if eAvatarSlot[curSlot[1]] ~= eAvatarSlot.Body then
			self.DlgPreviewActor.isRTCameraFar = false
		end

		self.DlgPreviewActor:ChangeView()
	end

	self:UpdateAvatarSelect(avatarData.id)

	local isTempEquip = avatarData.Equiped

	self:RemoveAvatarFromList(self.listEquip, avatarData.id)

	if isTempEquip then
		self:UnEquipAvatar(curSlot)
	else
		self:EquipAvatar(avatarData.id)
	end

	for _, id in pairs(self.listDefault) do
		if id then
			local infoAvatar = AvatarManager:GetAvatar(id)

			if infoAvatar then
				local hasTake = AvatarManager:FindAvatarBySlot(self.listEquip, infoAvatar.data.Slot)

				if not hasTake then
					self:EquipAvatar(id)
				end
			end
		end
	end

	self:UpdateEquipState()
	self:UpdateEquipTag()
end

function PageFittingroom:EquipAvatar(id, isNewBuy)
	self:UpdateAvatarDataTempEquiped(id, true)
	table.insert(self.listEquip, id)

	self.listAvatarFactory = self.listAvatarFactory or {}

	local infoAvatar = AvatarManager:GetAvatar(id)
	local slot = GetAvatarSlot(infoAvatar.data.Slot)
	local actor = self.DlgPreviewActor.actor

	LoadingMgr.Show(eLoadingType.Repeat)

	local avatarFactory

	ResourceMgr.BeginSubmit(function()
		LoadingMgr.Hide(eLoadingType.Repeat)

		if actor then
			actor.SkeletonSystem:SetSrpingBoneEnabled(false)

			local part = avatarFactory:Build()

			actor.AvatarSystem:PutOn(part)
			GOUtil.SetGameObjectLayer(actor.Root, LayerMask.NameToLayer("RT"))
			self:ClearSlotAvatarFactory(slot)

			self.listAvatarFactory[slot] = avatarFactory

			if table.contains(self.listDefault, id) then
				return
			end

			if isNewBuy then
				-- block empty
			else
				self.preAvatarSlot[self.infoRole.id] = self.preAvatarSlot[self.infoRole.id] or {}

				if self.preAvatarSlot[self.infoRole.id][1] == slot then
					return
				end

				table.insert(self.preAvatarSlot[self.infoRole.id], slot)

				local callback

				do
					local id = self.infoRole.id

					function callback()
						table.remove(self.preAvatarSlot[id], 1)
						actor:ResetBehaviour()
					end
				end

				if slot == eAvatarSlot.FaceUp or slot == eAvatarSlot.FaceDown or slot == eAvatarSlot.Ornament then
					PlayAnim(eInterctAnimType.changeHead, actor, self.infoRole, callback)
				elseif slot == eAvatarSlot.Back or slot == eAvatarSlot.Waist then
					PlayAnim(eInterctAnimType.changeBack, actor, self.infoRole, callback)
				else
					PlayAnim(eInterctAnimType.changeSuit, actor, self.infoRole, callback)
				end

				EffectMgr:Alloc("Fx/UI/Eff_Ui_Huanzhuang/Eff_Ui_Huanzhuang", self.obj, true, 2)
			end
		end
	end)

	avatarFactory = ActorUtil.BuildAvatarFactory(id, self.infoRole.id)

	avatarFactory:Cache()
	ResourceMgr.EndSubmit()
end

function PageFittingroom:UnEquipAvatar(slotList)
	local slot = GetAvatarSlot(slotList)
	local actor = self.DlgPreviewActor.actor

	actor.SkeletonSystem:SetSrpingBoneEnabled(false)
	actor.AvatarSystem:TakeOff(slot)
	self:ClearSlotAvatarFactory(slot)
end

function PageFittingroom:UpdateAvatarDataRealEquiped(id, isRealEquiped)
	for _, v in pairs(self.dictAvatar) do
		for k, avatarData in pairs(v) do
			avatarData.Equiped = false

			if avatarData.id == id then
				avatarData.Equiped = true
				avatarData.RealEquiped = isRealEquiped
			end
		end
	end
end

function PageFittingroom:UpdateAvatarDataTempEquiped(id, isEquiped)
	for _, v in pairs(self.dictAvatar) do
		for k, avatarData in pairs(v) do
			if avatarData.id == id then
				avatarData.Equiped = isEquiped
			end
		end
	end
end

function PageFittingroom:UpdateAvatarDataGeted(id, isGeted)
	for _, v in pairs(self.dictAvatar) do
		for k, avatarData in pairs(v) do
			if avatarData.id == id then
				avatarData.Geted = isGeted
			end
		end
	end
end

function PageFittingroom:CheckSlot(listAvatar, listSlot)
	local listSlotResult = {}

	for k, id in ipairs(listAvatar) do
		local infoAvatar = AvatarManager:GetAvatar(id)

		for k1, v1 in pairs(infoAvatar.data.Slot) do
			if table.contains(listSlot, v1) and not table.contains(listSlotResult, id) then
				table.insert(listSlotResult, id)
			end
		end
	end

	return listSlotResult
end

function PageFittingroom:RemoveAvatarFromList(list, avatarId)
	local curInfoAvatar = AvatarManager:GetAvatar(avatarId)

	if curInfoAvatar == nil then
		return
	end

	local listSlotResult = self:CheckSlot(list, curInfoAvatar.data.Slot)

	for i = #listSlotResult, 1, -1 do
		local id = listSlotResult[i]

		if table.contains(list, id) then
			self:UpdateAvatarDataTempEquiped(id, false)
			table.removeByValue(list, id)
		end
	end
end

function PageFittingroom:SwitchRoleMode(data)
	if data == nil then
		return
	end

	local function funSwitch()
		if data.callback then
			data.callback()
		end

		self:SelectTab(self:GetTabIndex(eAvatarTabType.Event))
		self:LoadActor()
		self:UpdateListData(true, false, true)
	end

	local haveModify = self:CheckEquipedModeModify()

	if haveModify then
		local function OnCallback(index)
			if index == 1 then
				self.needResetEquip = false

				funSwitch()
			end
		end

		UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), _("Msg_Avatar_Mode_Unsaved"), OnCallback, _("UI_Yes"), _("UI_No"))

		return
	end

	funSwitch()
end

function PageFittingroom:RestoreRoleMode()
	if not CheckTime(self.clickTime1) then
		self.clickTime1 = Time.realtimeSinceStartup

		return
	end

	self.clickTime1 = Time.realtimeSinceStartup

	if not self:CheckEquipedModeModify() then
		UIMgr.ShowMsg(_("Msg_Avatar_Mode_Unchanged"))

		return
	end

	if self.needResetEquip then
		self.infoRole:SetTempEquipAvatarIds()

		self.needResetEquip = false
	end

	self:LoadActor()
	self:UpdateListData(true, true)
end

function PageFittingroom:RequestOperateAvatar(tempVar, callback, hideSaveSucess)
	local vars = {
		roleId = self.infoRole.id,
		modeId = self.DlgAvatarMode.curMode.id,
		name = tempVar.modeName,
		avatarIds = tempVar.avatarIds,
		defaultId = tempVar.defaultId
	}
	local panelCb = tempVar.panelCb

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			if tempVar.avatarIds then
				for _, v in pairs(self.dictAvatar) do
					for k, avatarData in pairs(v) do
						avatarData.Equiped = false
						avatarData.RealEquiped = false

						if table.contains(tempVar.avatarIds, avatarData.id) then
							avatarData.RealEquiped = true
						end

						if table.contains(self.listEquip, avatarData.id) then
							avatarData.Equiped = true
						end
					end
				end

				self:DoSortAfterChange(tempVar.avatarIds)
				self:UpdateEquipTag()

				if not hideSaveSucess then
					UIMgr.ShowMsg(_("Save_Success"))
				end
			end

			if tempVar.modeName then
				UIMgr.ShowMsg(_("Msg_Avatar_Mode_Name_Modify_Sucess"))
			elseif tempVar.defaultId then
				UIMgr.ShowMsg(_("Msg_Sucess_Set"))
			end

			if panelCb then
				panelCb()
			end
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end

		if callback then
			callback(vMsg.result.code)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestEquipAvatar(vars, wrap_cb)
end

function PageFittingroom:OnClickBtnShop()
	local listAvatarData = {}

	for _, avatarId in ipairs(self.listEquip) do
		local avatarData = AvatarManager:GetAvatarData(self.infoRole, avatarId, self.curMode.id)
		local isBP = avatarData.InfoAvatar:IsBPAvatar()

		if not avatarData.Geted or isBP and not PlayerInst:IsBind(avatarData.id, self.infoRole.id) then
			table.insert(listAvatarData, avatarData)
		end
	end

	if #listAvatarData > 0 then
		UIMgr.AddPanel(DlgAvatarSelBuy(self), {
			infoRole = self.infoRole,
			listAvatar = listAvatarData
		})
	else
		UIMgr.ShowMsg(_("Msg_ShopCard_Null_Temp"))
	end
end

function PageFittingroom:OnClickBtnSave()
	if not CheckTime(self.clickTime) then
		self.clickTime = Time.realtimeSinceStartup

		return
	end

	self.clickTime = Time.realtimeSinceStartup

	local listAvatarData = {}

	for _, avatarId in ipairs(self.listEquip) do
		local avatarData = AvatarManager:GetAvatarData(self.infoRole, avatarId, self.curMode.id)
		local isBP = avatarData.InfoAvatar:IsBPAvatar()

		if not avatarData.Geted or isBP and not PlayerInst:IsBind(avatarData.id, self.infoRole.id) then
			table.insert(listAvatarData, avatarData)
		end
	end

	local function cb()
		if #listAvatarData > 0 then
			local data = {
				isSave = true,
				infoRole = self.infoRole,
				listAvatar = listAvatarData
			}

			UIMgr.AddPanel(DlgAvatarSelBuy(self), data)
		end
	end

	self:RequestSave(cb)
end

function PageFittingroom:RequestSave(callback)
	local listIds = {}

	for _, avatarId in ipairs(self.listEquip) do
		local avatardata = AvatarManager:GetAvatarData(self.infoRole, avatarId, self.curMode.id)

		if avatardata.Geted and (not avatardata.InfoAvatar:IsBPAvatar() or PlayerInst:IsBind(avatardata.id, self.infoRole.id)) then
			table.insert(listIds, avatarId)
		else
			for i, j in ipairs(self.curMode.avatars) do
				local avatar = AvatarManager:GetAvatar(j)

				if GetAvatarSlot(avatardata.InfoAvatar.data.Slot) == GetAvatarSlot(avatar.data.Slot) then
					table.insert(listIds, j)

					break
				end
			end
		end
	end

	listIds = table.deduplication(listIds)

	local exist = false

	if #listIds ~= #self.curMode.avatars then
		exist = true
	else
		for _, v in ipairs(listIds) do
			if not table.contains(self.curMode.avatars, v) then
				exist = true
			end
		end
	end

	if exist then
		self:RequestOperateAvatar({
			avatarIds = listIds
		}, callback)
	else
		callback()
	end
end

function PageFittingroom:DoAfterBuyAvatar(isSave, listBuyId)
	listBuyId = listBuyId or {}

	for k, avatarId in ipairs(listBuyId) do
		self:UpdateAvatarDataGeted(avatarId, true)
	end

	if isSave then
		self:RequestSave()
	else
		self:DoSortAfterChange(listBuyId)
	end
end

function PageFittingroom:DoSortAfterChange(listChangeId)
	if listChangeId == nil or #listChangeId == 0 then
		return
	end

	local t = {}

	for _, v in ipairs(listChangeId) do
		local avatar = AvatarManager:GetAvatar(v)

		if avatar then
			local tabIdx = self:GetTabIndex(avatar.data.AvatarTabType)

			if not table.contains(t, tabIdx) then
				table.insert(t, tabIdx)
			end
		end
	end

	for _, tabIdx in pairs(t) do
		self:UpdateSort(tabIdx)
	end

	self:UpdateListData(false, false, true)
end

function PageFittingroom:OnClickBtnAttr()
	self.GoAttr1:SetActive(false)
	self.GoAttr2:SetActive(true)
	require("UI/Page/PageFittingroom/DlgAvatarAttr")
	UIMgr.AddPanel(DlgAvatarAttr(), {
		infoRole = self.infoRole,
		page = self
	})
end

function PageFittingroom:PlayBPBindInfo(infoAvatar, oldBindInfo)
	if oldBindInfo and oldBindInfo.roleId ~= 0 then
		self.BPBindPrompt2:SetActive(true)

		self.TxtBindName2.text = RoleMgr:GetRole(oldBindInfo.roleId):GetName()
		self.TxtBPAtt2.text = AvatarManager.GetStrAtt(infoAvatar, false)[1]
	else
		self.BPBindPrompt2:SetActive(false)
	end

	local pbAvatar = PlayerInst:GetBPAvatar(infoAvatar.id)

	self.TxtBindName1.text = RoleMgr:GetRole(pbAvatar.roleId):GetName()
	self.TxtBPAtt1.text = AvatarManager.GetStrAtt(infoAvatar, true)[1]

	self.AnimBindPrompt:Play("Anim_Bp_Prompt")
end

function PageFittingroom:GotoFromWhere(infoAvatar, cb)
	AvatarManager.curTabIndex = self.curtabIdx
	self.notResetRecord = true
	AvatarManager.needPresave = true
	AvatarManager.LastEquipAvatar = {
		roleId = self.infoRole.id,
		avatarIds = self.listEquip,
		modeId = self.curMode.id
	}

	AvatarManager.GotoFromWhere(self.infoRole, infoAvatar, cb)
end

function PageFittingroom:UpdateAfterGetAvatar()
	AvatarManager.curTabIndex = 0
	self.notResetRecord = false
	AvatarManager.needPresave = false
	AvatarManager.LastEquipAvatar = {}

	local listEquip = self.listEquip

	self:UpdateDictAndEquipAvatar()

	self.listEquip = listEquip

	for _, avatarId in ipairs(listEquip) do
		self:UpdateAvatarDataTempEquiped(avatarId, true)
		self:SubNewAvatarDot(avatarId)
	end

	self:UpdateEquipTag()
	self:UpdateScrollView(false, true)
	self:UpdateExecutableState()
end

function PageFittingroom:SubNewAvatarDot(avatarId)
	if RoleRDL.FittingRDL.IsNewAvatar(self.infoRole, avatarId) then
		RoleRDL.FittingRDL.SubNewAvatarId(self.infoRole, avatarId)
		Event.Instance:Fire("UpdateThinNotify")
	end
end

function PageFittingroom:OnClickedGuideBtn()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.Avatar)
end

function PageFittingroom.IntoShopCar(avatarData, infoRole)
	if not avatarData then
		return false
	end

	if not avatarData.Geted then
		return true
	end

	local bpAvatar = PlayerInst:GetBPAvatar(avatarData.id)

	if bpAvatar and bpAvatar.roleId ~= infoRole.id then
		return true
	end

	return false
end

function PageFittingroom:AvatarShelfRefresh()
	if self.infoRole then
		self:UpdateListData(true, true)
	end
end

function PageFittingroom:OnBackAndroid()
	if self.DlgCharacterThin and GOUtil.IsActiveSelf(self.DlgCharacterThin.GoClick) then
		self.DlgCharacterThin:OnClickBack()

		return true
	end

	return false
end
