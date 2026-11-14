require("UI/Page/PageEquipment/PageEquipAvatar")

PageEquip = class("PageEquip", UIPanel)

function PageEquip.ctor(arg_1_0)
	arg_1_0.UIPrefabPath = "UI/PanelEquipment/PanelEquipment"

	arg_1_0:AddChildPanel(DlgExit(), {
		title = _("eReturn_RoleEquip"),
		callback = arg_1_0.OnBack,
		panel = arg_1_0
	})
	arg_1_0:AddChildPanel(DlgAssetsInfo(), {
		x = -600,
		y = -42
	})
end

function PageEquip.PreLoad(arg_2_0)
	return
end

function PageEquip.OnBack(arg_3_0)
	local var_3_0 = UIMgr.GetPrePanel()

	if var_3_0.className ~= "PageRole" then
		UIMgr.HidePreviewActor()
	else
		UIMgr.PreviewActor:ChangeLens(eActorSystemType.ROLE, true)
	end

	if var_3_0.className == "PageInteraction" then
		SceneMainStage.Instance:OnEnterInteractionByRoleId(arg_3_0.infoRole.id, nil, true)
	else
		UIMgr.PopPanel(arg_3_0.data)
	end
end

function PageEquip.Purge(arg_4_0)
	if arg_4_0.switchSystemType then
		UIMgr.PreviewActor:ChangeLens(arg_4_0.switchSystemType)
	end

	arg_4_0:OnLeave()
	arg_4_0.base.Purge(arg_4_0)
end

function PageEquip.OnLeave(arg_5_0)
	EffectMgr:UnLoadEffect("Fx/UI/Eff_Ui_Huanzhuang/Eff_Ui_Huanzhuang")
end

function PageEquip.OnRegisterEvent(arg_6_0)
	for iter_6_0 = 1, 6 do
		arg_6_0:AddClick(arg_6_0["Slot" .. iter_6_0], arg_6_0.OnClickedSlot)
	end

	for iter_6_1 = 1, 2 do
		arg_6_0:AddListener(arg_6_0["Suit" .. iter_6_1], arg_6_0.OnLongPressSuit, EventTriggerType.PointerLongPress)
		UIUtil.SetLongPressTime(arg_6_0["Suit" .. iter_6_1], 0.1)
	end

	arg_6_0:AddClick(arg_6_0.BtnRole, arg_6_0.OnClickedBtnChangeRole)
	arg_6_0:AddClick(arg_6_0.BtnAvatar, arg_6_0.OnClickedBtnChangeAvatar)
	arg_6_0:AddClick(arg_6_0.BtnLeft, arg_6_0.OnClickedBtnRoleL)
	arg_6_0:AddClick(arg_6_0.BtnRight, arg_6_0.OnClickedBtnCardR)
	arg_6_0:AddClick(arg_6_0.GoSwitch, arg_6_0.OnClickedGoSwitch)
	arg_6_0:AddClick(arg_6_0.BtnGuide, arg_6_0.OnClickedBtnGuide)
	Event.Instance:Add("SwitchIntensePanel", arg_6_0.SwitchIntensePanel, arg_6_0)
	Event.Instance:Add("RefreshShowRole", arg_6_0.RefreshShowRole, arg_6_0)
end

function PageEquip.OnUnRegisterEvent(arg_7_0)
	for iter_7_0 = 1, 6 do
		arg_7_0:RemoveClick(arg_7_0["Slot" .. iter_7_0], arg_7_0.OnClickedSlot)
	end

	for iter_7_1 = 1, 2 do
		arg_7_0:RemoveListener(arg_7_0["Suit" .. iter_7_1], arg_7_0.OnLongPressSuit, EventTriggerType.PointerLongPress)
	end

	arg_7_0:RemoveClick(arg_7_0.BtnRole, arg_7_0.OnClickedBtnChangeRole)
	arg_7_0:RemoveClick(arg_7_0.BtnAvatar, arg_7_0.OnClickedBtnChangeAvatar)
	arg_7_0:RemoveClick(arg_7_0.BtnLeft, arg_7_0.OnClickedBtnRoleL)
	arg_7_0:RemoveClick(arg_7_0.BtnRight, arg_7_0.OnClickedBtnCardR)
	arg_7_0:RemoveClick(arg_7_0.GoSwitch, arg_7_0.OnClickedGoSwitch)
	arg_7_0:RemoveClick(arg_7_0.BtnGuide, arg_7_0.OnClickedBtnGuide)
	Event.Instance:Remove("SwitchIntensePanel", arg_7_0.SwitchIntensePanel, arg_7_0)
	Event.Instance:Remove("RefreshShowRole", arg_7_0.RefreshShowRole, arg_7_0)
end

function PageEquip.OnEnter(arg_8_0, arg_8_1)
	PersistentStoreUtil.SetBool("EquipDot", false)
	arg_8_0:DealWithLocalization()

	for iter_8_0 = 1, 6 do
		arg_8_0["Slot" .. iter_8_0] = arg_8_0:GetChildGameObject("Panel/EquipSlot/" .. iter_8_0)

		if iter_8_0 <= 2 then
			arg_8_0["Suit" .. iter_8_0] = arg_8_0:GetChildGameObject("Panel/EquipAttr/View/Suit/Group/" .. iter_8_0)
			arg_8_0["SuitIcon" .. iter_8_0] = arg_8_0:GetChildComponent("Panel/EquipAttr/View/Suit/Group/" .. iter_8_0 .. "/Icon", "Image")
		end
	end

	arg_8_0.GoSwitch = arg_8_0:GetChildGameObject("Panel/EquipAttr/GoAct")
	arg_8_0.AnimEquipAttr = arg_8_0:GetChildComponent("Panel/EquipAttr", "Animator")
	arg_8_0.GoTip = arg_8_0:GetChildGameObject("Tip")

	arg_8_0.GoTip:SetActive(false)

	arg_8_0.GoNoSuit = arg_8_0:GetChildGameObject("Panel/EquipAttr/View/Suit/TxtNoSuit")
	arg_8_0.BtnRole = arg_8_0:GetChildGameObject("Panel/BtnRole")
	arg_8_0.BtnAvatar = arg_8_0:GetChildGameObject("Panel/BtnAvatar")
	arg_8_0.BtnLeft = arg_8_0:GetChildGameObject("Panel/BtnLeft")
	arg_8_0.BtnRight = arg_8_0:GetChildGameObject("Panel/BtnRight")
	arg_8_0.BtnGuide = arg_8_0:GetChildGameObject("Panel/BtnGuide")

	arg_8_0:InitData(arg_8_1)
end

function PageEquip.DealWithLocalization(arg_9_0)
	local var_9_0

	arg_9_0:GetChildComponent("Panel/EquipAttr/View/Attr/Text", "Text").text = _("Desc_AttrOverview")
	arg_9_0:GetChildComponent("Panel/EquipAttr/View/Suit/Text", "Text").text = _("Desc_EquipEnchantEffect")
	arg_9_0:GetChildComponent("Panel/EquipAttr/View/Suit/TxtNoSuit", "Text").text = _("Desc_NoEquipEnchantEffect")
	arg_9_0:GetChildComponent("Panel/BtnAvatar/TxtName", "Text").text = _("Desc_EquipAvatar")

	for iter_9_0 = 1, 6 do
		arg_9_0:GetChildComponent("Panel/EquipSlot/" .. iter_9_0 .. "/BgLevel/Text", "Text").text = string.format(_("Desc_Level"), "")

		if iter_9_0 <= 4 then
			arg_9_0:GetChildComponent("Panel/EquipAttr/View/Attr/" .. iter_9_0 .. "/TxtAttr", "Text").text = _("eAttType_" .. iter_9_0)
		end
	end
end

function PageEquip.InitData(arg_10_0, arg_10_1)
	if not GuideMgr:IsGuided(GuideFunctionType.Equip) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.Equip)
	end

	arg_10_0.listRole = RoleMgr:GetSelectHoldRole()
	arg_10_0.roleIdx = RoleMgr:GetSelectHoldRoleIndex()

	if arg_10_1 and arg_10_1.roleId then
		arg_10_0.data = arg_10_1
		arg_10_0.roleId = arg_10_1.roleId
	else
		arg_10_0.roleId = arg_10_0.listRole[arg_10_0.roleIdx].id
	end

	if not arg_10_0.roleId then
		arg_10_0.roleId = 101
	end

	if not arg_10_0.data then
		arg_10_0.data = {}
	end

	arg_10_0.data.infoRole = RoleMgr:GetRole(arg_10_0.roleId)

	arg_10_0:UpdatePanel()
end

function PageEquip.UpdatePanel(arg_11_0)
	arg_11_0.infoRole = RoleMgr:GetRole(arg_11_0.roleId)

	if not arg_11_0.infoRole then
		return
	end

	UIMgr.ShowPreviewActor(arg_11_0.infoRole)

	arg_11_0.listAvatar = AvatarManager:GetWeaponAvatarList(arg_11_0.infoRole)
	arg_11_0.listAvatar = AvatarManager:GetWeaponAvatarList(arg_11_0.infoRole)

	for iter_11_0, iter_11_1 in pairs(arg_11_0.listAvatar) do
		if iter_11_1.RealEquiped then
			UIMgr.PreviewActor:EquipAvatar(iter_11_1.id, false, true)

			break
		end
	end

	TimerMgr.AddTimer(eTimerType.RealTime, 2, function()
		return
	end, nil)
	arg_11_0:UpdateSlot()
	arg_11_0:UpdateAllProp()
end

function PageEquip.Set3DRole(arg_13_0)
	arg_13_0.listAvatar = AvatarManager:GetWeaponAvatarList(arg_13_0.infoRole)

	UIMgr.PreviewActor:UpdateRole(arg_13_0.infoRole)
end

function PageEquip.EquipAvatar(arg_14_0, arg_14_1, arg_14_2, arg_14_3)
	LoadingMgr.Show(eLoadingType.Repeat)

	local var_14_0 = UIMgr.PreviewActor.actor
	local var_14_1 = ActorUtil.BuildAvatarFactory(arg_14_1)

	ResourceMgr.BeginSubmit(function()
		LoadingMgr.Hide(eLoadingType.Repeat)

		if var_14_0 then
			var_14_0.SkeletonSystem:SetSrpingBoneEnabled(false)
			var_14_0.AvatarSystem:PutOn(var_14_1:Build())

			local var_15_0 = var_14_0.Root

			GOUtil.SetGameObjectLayer(var_15_0, LayerMask.NameToLayer("RT"))

			var_14_1 = nil

			if arg_14_3 then
				-- block empty
			else
				if arg_14_2 then
					var_14_0.MotionSystem:Play("Buy")
				else
					var_14_0.MotionSystem:Play("PutOn")
				end

				EffectMgr:Alloc("Fx/UI/Eff_Ui_Huanzhuang/Eff_Ui_Huanzhuang", arg_14_0.UIRootObject, true, 2)
			end
		end
	end)
	var_14_1:Cache()
	ResourceMgr.EndSubmit()
end

function PageEquip.UpdateSlot(arg_16_0)
	for iter_16_0 = 1, 6 do
		local var_16_0 = arg_16_0:GetChildGameObject("Panel/EquipSlot/" .. iter_16_0)
		local var_16_1 = GOUtil.FindChildComponent(var_16_0, "Icon", "Image")
		local var_16_2 = GOUtil.FindChildComponent(var_16_0, "BgName/TxtName", "Text")
		local var_16_3 = GOUtil.FindChildComponent(var_16_0, "BgLevel/TxtLevel", "Text")
		local var_16_4 = GOUtil.FindChildComponent(var_16_0, "ImgSuit", "Image")
		local var_16_5 = GOUtil.FindChildComponent(var_16_0, "Lock/TxtLock", "Text")
		local var_16_6 = GOUtil.FindChildGameObject(var_16_0, "Lock")
		local var_16_7 = GOUtil.FindChildGameObject(var_16_0, "BgLevel")
		local var_16_8 = arg_16_0.infoRole:IsEquipSlotUnlocked(iter_16_0)

		var_16_6:SetActive(not var_16_8)
		var_16_7:SetActive(var_16_8)

		local var_16_9 = arg_16_0.infoRole:GetEquipId(iter_16_0)
		local var_16_10 = EquipmentManager:GetEquip(var_16_9)
		local var_16_11 = arg_16_0.infoRole:GetEquipSlot(iter_16_0)

		if var_16_8 then
			var_16_3.text = var_16_11.level
		end

		local var_16_12, var_16_13 = EquipmentManager:GetEquipSlotIconAndName(arg_16_0.infoRole, var_16_10, var_16_11.quality, var_16_11.grade)

		var_16_2.text = var_16_13

		SetImageSprite(var_16_1, var_16_12, arg_16_0)

		local var_16_14 = GOUtil.GetComponent(var_16_7, "Image")
		local var_16_15 = EquipmentManager:GetQualityIndex(var_16_11.quality, var_16_11.grade)
		local var_16_16 = GetConfigArgJson("EquipQualityColor")[var_16_15].Icon

		SetImageSprite(var_16_14, "UI/PanelEquipment/AtlasEquipment/" .. var_16_16, arg_16_0)

		local var_16_17 = TenaryOp(var_16_8, 0, 1)

		DealWithListRef(arg_16_0, UIUtil.SetImageGray(var_16_1, var_16_17))

		var_16_5.text = string.format(_("PageTalentTree_Unlock_favor"), GetConfigArgJson("EquipmentUnlock")[iter_16_0])

		var_16_4.gameObject:SetActive(var_16_11.scroll ~= 0)

		if var_16_11.scroll ~= 0 then
			local var_16_18 = ItemManager:Get(var_16_11.scroll)
			local var_16_19 = RoleMgr:GetSuitIcon(tonumber(var_16_18.data.SubType))

			UIUtil.SetImageSprite(var_16_4, var_16_19 .. "_s", arg_16_0)

			local var_16_20 = arg_16_0.infoRole:GetActiveSameSuitSubTypeNum(var_16_11.scroll, iter_16_0, true)
			local var_16_21 = RoleMgr:GetSuitOfScrollType(tonumber(var_16_18.data.SubType))
			local var_16_22 = 0

			for iter_16_1 = 1, #var_16_21 do
				if var_16_20 >= var_16_21[iter_16_1].Number then
					var_16_22 = iter_16_1
				end
			end

			if var_16_22 ~= 0 then
				arg_16_0["handle" .. iter_16_0] = EffectMgr:Alloc("Fx/UI/Eff_Ui_FuMo/Eff_Ui_FuMo_Trail0" .. var_16_22, var_16_4.gameObject, true)
			elseif arg_16_0["handle" .. iter_16_0] then
				EffectMgr:Free(arg_16_0["handle" .. iter_16_0])

				arg_16_0["handle" .. iter_16_0] = nil
			end
		end
	end

	for iter_16_2 = 1, 6 do
		arg_16_0:GetChildGameObject("Panel/EquipSlot/" .. iter_16_2 .. "/dot"):SetActive(EquipmentManager:GetPageEquipDevelopDot(arg_16_0.infoRole, iter_16_2))
	end
end

function PageEquip.UpdateAllProp(arg_17_0)
	arg_17_0.infoRole:UpdateEquipAttr()

	for iter_17_0 = 1, 4 do
		arg_17_0:GetChildComponent("Panel/EquipAttr/View/Attr/" .. iter_17_0 .. "/TxtValue", "Text").text = math.floor(arg_17_0.infoRole.equipAtt:Get(iter_17_0) + 0.5)
	end

	arg_17_0.listReson = RoleMgr:GetRoleActiveResonance(arg_17_0.infoRole)

	arg_17_0.GoNoSuit:SetActive(#arg_17_0.listReson == 0)

	for iter_17_1 = 1, 2 do
		arg_17_0["Suit" .. iter_17_1]:SetActive(iter_17_1 <= #arg_17_0.listReson)

		if iter_17_1 <= #arg_17_0.listReson then
			local var_17_0 = arg_17_0.listReson[iter_17_1]

			UIUtil.SetImageSprite(arg_17_0["SuitIcon" .. iter_17_1], var_17_0.Img, arg_17_0)
		end
	end
end

function PageEquip.OnClickedBtnRoleL(arg_18_0)
	arg_18_0.roleIdx = TenaryOp(arg_18_0.roleIdx - 1 < 1, #arg_18_0.listRole, arg_18_0.roleIdx - 1)

	arg_18_0:RefreshShowRole(arg_18_0.listRole[arg_18_0.roleIdx].id)
end

function PageEquip.OnClickedBtnCardR(arg_19_0)
	arg_19_0.roleIdx = TenaryOp(arg_19_0.roleIdx + 1 > #arg_19_0.listRole, 1, arg_19_0.roleIdx + 1)

	arg_19_0:RefreshShowRole(arg_19_0.listRole[arg_19_0.roleIdx].id)
end

function PageEquip.OnClickedBtnGuide(arg_20_0)
	require("UI/Dlg/Public/GuideChooseTip")
	UIMgr.AddPanel(GuideChooseTip(), {
		guideType = "EquipGuide"
	})
end

function PageEquip.RefreshShowRole(arg_21_0, arg_21_1)
	if arg_21_0.data then
		arg_21_0.data.roleId = arg_21_1
		arg_21_0.data.infoRole = RoleMgr:GetRole(arg_21_1)
	end

	arg_21_0.roleId = arg_21_1

	arg_21_0:UpdatePanel()
end

function PageEquip.OnClickedGoSwitch(arg_22_0)
	if arg_22_0.show then
		arg_22_0.AnimEquipAttr:Play("AnimEquipAttr_Hide")
	else
		arg_22_0.AnimEquipAttr:Play("AnimEquipAttr_Show")
	end

	arg_22_0.show = not arg_22_0.show
end

function PageEquip.OnLongPressSuit(arg_23_0, arg_23_1)
	local var_23_0 = arg_23_1.pointerPressRaycast.gameObject
	local var_23_1 = tonumber(var_23_0.name)

	if arg_23_1.clickCount == 1 then
		arg_23_0.GoTip:SetActive(true)

		arg_23_0.GoTip.transform.localPosition = UIUtil.GetTipsPos(arg_23_0.UIRootObject, arg_23_1.position, arg_23_0.GoTip, 150)

		arg_23_0:SetTip(var_23_1)
	else
		arg_23_0.GoTip:SetActive(false)
	end
end

function PageEquip.SetTip(arg_24_0, arg_24_1)
	local var_24_0 = arg_24_0.listReson[arg_24_1]
	local var_24_1 = arg_24_0:GetChildComponent("Tip/ImgSuit", "Image")

	UIUtil.SetImageSprite(suitIVcon, var_24_0.Img .. "_s", arg_24_0)

	arg_24_0:GetChildComponent("Tip/TxtSuit", "Text").text = Lang(var_24_0.Name)

	local var_24_2 = RoleMgr:GetSuitOfScrollType(var_24_0.ScrollType)

	for iter_24_0 = 1, 2 do
		local var_24_3 = var_24_2[iter_24_0]

		arg_24_0:GetChildComponent("Tip/" .. iter_24_0 .. "/Bg/Text", "Text").text = var_24_3.Number .. "件"

		local var_24_4 = arg_24_0:GetChildComponent("Tip/" .. iter_24_0 .. "/TxtInfo", "Text")

		var_24_4.text = Lang(var_24_3.Info)

		local var_24_5 = TenaryOp(var_24_0.Number > var_24_3.Number, 1, 0.6)

		var_24_4.color = Color.New(1, 1, 1, var_24_5)
	end
end

function PageEquip.IsSlotUnlocked(arg_25_0, arg_25_1)
	local var_25_0 = RoleMgr:GetRole(arg_25_0)

	if var_25_0 then
		if var_25_0:IsEquipSlotUnlocked(arg_25_1) then
			return true
		else
			local var_25_1 = GetConfigArgJson("EquipmentUnlock")[arg_25_1]

			UIMgr.ShowMsg(string.format(_("PageTalentTree_Unlock_favor"), var_25_1))
		end
	end

	return false
end

function PageEquip.OnClickedSlot(arg_26_0, arg_26_1)
	local var_26_0 = arg_26_1.pointerPress.gameObject
	local var_26_1 = tonumber(var_26_0.name)

	if not PageEquip.IsSlotUnlocked(arg_26_0.roleId, var_26_1) then
		return
	end

	require("UI/Page/PageEquipment/PageEquipDevelop")
	UIMgr.SwitchPanel(PageEquipDevelop, {
		roleId = arg_26_0.roleId,
		slotIdx = var_26_1
	})
end

function PageEquip.OnClickedBtnChangeAvatar(arg_27_0)
	arg_27_0.switchSystemType = eActorSystemType.AVATAR

	UIMgr.SwitchPanel(PageEquipAvatar, {
		roleId = arg_27_0.roleId
	})
end

function PageEquip.OnClickedBtnChangeRole(arg_28_0)
	require("UI/Dlg/DlgRoleHeart/DlgRoleHeart")
	UIMgr.AddPanel(DlgRoleHeart(), {
		typeId = 2,
		roleId = arg_28_0.roleId
	}, arg_28_0.UIRootObject)
end
