require("UI/Page/PageFittingroom/CellAvatar")
require("UI/Page/PageRole/DlgPreviewWeapon")
require("UI/Page/PageEquipment/DlgNewSkin")

PageEquipAvatar = class("PageEquipAvatar", UIPanel)

function PageEquipAvatar.ctor(arg_1_0)
	arg_1_0.UIPrefabPath = "UI/PanelEquipment/PanelEquipAvatar"

	arg_1_0:AddChildPanel(DlgExit(), {
		title = _("eReturn_RoleEquip"),
		callback = arg_1_0.OnBack,
		panel = arg_1_0
	})
	arg_1_0:AddChildPanel(DlgAssetsInfo(), {
		AssetInfos = {
			1051,
			502,
			501
		}
	})
end

function PageEquipAvatar.PreLoad(arg_2_0)
	arg_2_0.PrefabCellAvatar = ResourceMgr.LoadSync("UI/PageFittingroom/CellAvatar")
end

function PageEquipAvatar.OnBack(arg_3_0)
	if UIMgr.GetPrePanel().className ~= "PageEquip" then
		UIMgr.HidePreviewActor()
	else
		UIMgr.PreviewActor:ChangeLens(eActorSystemType.EQUIP)
	end

	UIMgr.PopPanel(arg_3_0.data)
end

function PageEquipAvatar.Purge(arg_4_0)
	arg_4_0.base.Purge(arg_4_0)
	arg_4_0:OnLeave()
end

function PageEquipAvatar.OnLeave(arg_5_0)
	if arg_5_0.UIScrollTool then
		arg_5_0.UIScrollTool:Purge()

		arg_5_0.UIScrollTool = nil
	end

	if arg_5_0.DlgPreviewActor then
		arg_5_0.DlgPreviewActor:Purge()

		arg_5_0.DlgPreviewActor = nil
	end

	if arg_5_0.DlgPreviewWeapon then
		arg_5_0.DlgPreviewWeapon:Purge()

		arg_5_0.DlgPreviewWeapon = nil
	end

	EffectMgr:UnLoadEffect("Fx/UI/Eff_Ui_Huanzhuang/Eff_Ui_Huanzhuang")
end

function PageEquipAvatar.OnRegisterEvent(arg_6_0)
	arg_6_0:AddClick(arg_6_0.BtnSave, arg_6_0.OnClickBtnSave)
	arg_6_0:AddClick(arg_6_0.BtnDetail, arg_6_0.OnAvatarDetail)
	arg_6_0:AddClick(arg_6_0.BtnConfirm, arg_6_0.OnAvatarConfirm)
	arg_6_0:AddClick(arg_6_0.BtnDetailQuit, arg_6_0.OnDetailQuit)
end

function PageEquipAvatar.OnUnRegisterEvent(arg_7_0)
	arg_7_0:RemoveClick(arg_7_0.BtnSave, arg_7_0.OnClickBtnSave)
	arg_7_0:RemoveClick(arg_7_0.BtnDetail, arg_7_0.OnAvatarDetail)
	arg_7_0:RemoveClick(arg_7_0.BtnConfirm, arg_7_0.OnAvatarConfirm)
	arg_7_0:RemoveClick(arg_7_0.BtnDetailQuit, arg_7_0.OnDetailQuit)
end

function PageEquipAvatar.OnEnter(arg_8_0, arg_8_1)
	if not GuideMgr:IsGuided(GuideFunctionType.EquipAvatar) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.EquipAvatar)
	end

	arg_8_0:DealWithLocalization()

	arg_8_0.BtnSave = arg_8_0:GetChildGameObject("PanelAvatar/Avatar/BtnSave")
	arg_8_0.BtnDetail = arg_8_0:GetChildGameObject("PanelAvatar/Avatar/BtnGroup/BtnDetail")
	arg_8_0.BtnConfirm = arg_8_0:GetChildGameObject("PanelAvatar/Avatar/BtnGroup/BtnConfirm")
	arg_8_0.TxtConfirm = arg_8_0:GetChildComponent("PanelAvatar/Avatar/BtnGroup/BtnConfirm/Text", "Text")
	arg_8_0.PanelDetail = arg_8_0:GetChildGameObject("PanelDetail")

	arg_8_0.PanelDetail:SetActive(false)

	arg_8_0.BtnDetailQuit = arg_8_0:GetChildGameObject("PanelDetail/Button")

	arg_8_0:InitData(arg_8_1)
end

function PageEquipAvatar.DealWithLocalization(arg_9_0)
	local var_9_0

	arg_9_0:GetChildComponent("PanelAvatar/Avatar/Prop/Title/Text", "Text").text = _("PageEquip_TotalProp")
	arg_9_0:GetChildComponent("PanelAvatar/Avatar/BtnGroup/BtnDetail/Text", "Text").text = Lang(12265)
	arg_9_0:GetChildComponent("PanelDetail/Title/Text", "Text").text = _("PageEquip_avatar2")
	arg_9_0:GetChildComponent("PanelDetail/PreProp/Text", "Text").text = _("PageEquip_LimitProp")

	for iter_9_0 = 1, 4 do
		arg_9_0:GetChildComponent("PanelAvatar/Avatar/Prop/" .. iter_9_0 .. "/TxtAttr", "Text").text = _("eAttType_" .. iter_9_0)
		arg_9_0:GetChildComponent("PanelDetail/PreProp/" .. iter_9_0 .. "/Text", "Text").text = _("eAttType_" .. iter_9_0)
	end
end

function PageEquipAvatar.InitData(arg_10_0, arg_10_1)
	arg_10_0.data = arg_10_1

	local var_10_0 = arg_10_1.roleId

	arg_10_0.infoRole = RoleMgr:GetRole(var_10_0)

	arg_10_0:UpateAvatarAttr()
	arg_10_0:InitAvatarData()
	arg_10_0:InitScrollView()
end

function PageEquipAvatar.UpateAvatarAttr(arg_11_0)
	for iter_11_0 = 1, 4 do
		arg_11_0:GetChildComponent("PanelAvatar/Avatar/Prop/" .. iter_11_0 .. "/TxtValue", "Text").text = arg_11_0.infoRole.avatarAtt:Get(iter_11_0)
	end
end

function PageEquipAvatar.InitAvatarData(arg_12_0)
	arg_12_0.selectIndex = 1
	arg_12_0.listAvatar = AvatarManager:GetWeaponAvatarList(arg_12_0.infoRole)

	for iter_12_0, iter_12_1 in pairs(arg_12_0.listAvatar) do
		if iter_12_1.RealEquiped then
			arg_12_0.selectIndex = iter_12_0

			break
		end
	end

	arg_12_0:UpdateBtnGroup()
end

function PageEquipAvatar.InitScrollView(arg_13_0)
	local var_13_0 = arg_13_0:GetChildGameObject("PanelAvatar/Avatar/Avatar/ScrollArea")
	local var_13_1 = arg_13_0:GetChildComponent("PanelAvatar/Avatar/Avatar/ScrollArea/Content", "Transform")
	local var_13_2 = #arg_13_0.listAvatar

	arg_13_0.UIScrollTool = UIScrollTool()

	arg_13_0.UIScrollTool:InitList(var_13_0, var_13_1, var_13_2, arg_13_0.PrefabCellAvatar, CellAvatar, arg_13_0, false)
end

function PageEquipAvatar.UpdateCell(arg_14_0, arg_14_1, arg_14_2)
	arg_14_1.Index = arg_14_2

	arg_14_1:UpdateData(arg_14_0.listAvatar[arg_14_2], arg_14_0.selectIndex)
end

function PageEquipAvatar.AddCellClick(arg_15_0, arg_15_1)
	arg_15_0:AddClick(arg_15_1.UIRootObject, arg_15_0.OnClickedCell)
end

function PageEquipAvatar.OnClickedCell(arg_16_0, arg_16_1)
	local var_16_0 = arg_16_1.pointerPress
	local var_16_1 = arg_16_0.UIScrollTool.ItemRoot2ItemDict:GetValue(var_16_0)

	if var_16_1.Item.Index == arg_16_0.selectIndex then
		return
	end

	arg_16_0.selectIndex = var_16_1.Item.Index

	arg_16_0:UpdateBtnGroup()
	arg_16_0:TempEquip()
end

function PageEquipAvatar.TempEquip(arg_17_0)
	local var_17_0 = arg_17_0.listAvatar[arg_17_0.selectIndex]

	local function var_17_1(arg_18_0)
		if arg_18_0 then
			for iter_18_0, iter_18_1 in pairs(arg_17_0.listAvatar) do
				iter_18_1.RealEquiped = false
				iter_18_1.Equiped = false
			end

			var_17_0.RealEquiped = true
			var_17_0.Equiped = true

			arg_17_0.UIScrollTool:UpdateListDataKeepPos(arg_17_0.listAvatar)
		end
	end

	if var_17_0.Geted then
		arg_17_0:RequestOperateAvatar(var_17_0.id, var_17_1)
	else
		for iter_17_0, iter_17_1 in pairs(arg_17_0.listAvatar) do
			iter_17_1.Equiped = false
		end

		var_17_0.Equiped = true

		arg_17_0.UIScrollTool:UpdateListDataKeepPos(arg_17_0.listAvatar)
	end
end

function PageEquipAvatar.EquipAvatar(arg_19_0, arg_19_1, arg_19_2, arg_19_3)
	LoadingMgr.Show(eLoadingType.Repeat)

	local var_19_0 = arg_19_0.DlgPreviewActor.actor
	local var_19_1 = ActorUtil.BuildAvatarFactory(arg_19_1)

	ResourceMgr.BeginSubmit(function()
		LoadingMgr.Hide(eLoadingType.Repeat)

		if var_19_0 then
			var_19_0.SkeletonSystem:SetSrpingBoneEnabled(false)
			var_19_0.AvatarSystem:PutOn(var_19_1:Build())

			local var_20_0 = var_19_0.Root

			GOUtil.SetGameObjectLayer(var_20_0, LayerMask.NameToLayer("RT"))

			var_19_1 = nil

			if arg_19_3 then
				-- block empty
			else
				var_19_0.MotionSystem:Play("Buy")
				EffectMgr:Alloc("Fx/UI/Eff_Ui_Huanzhuang/Eff_Ui_Huanzhuang", arg_19_0.UIRootObject, true, 2)
			end
		end
	end)
	var_19_1:Cache()
	ResourceMgr.EndSubmit()
end

function PageEquipAvatar.UpdateBtnGroup(arg_21_0)
	local var_21_0 = arg_21_0.listAvatar[arg_21_0.selectIndex]

	if var_21_0 == nil then
		return
	end

	local var_21_1 = not var_21_0.IsUnlocked
	local var_21_2 = var_21_0.Geted

	arg_21_0.BtnDetail:SetActive(true)
	arg_21_0.BtnConfirm:SetActive(true)

	if var_21_2 then
		arg_21_0.TxtConfirm.text = _("UI_OK")
		arg_21_0.avatarBtnState = 1

		arg_21_0.BtnConfirm:SetActive(false)
	elseif var_21_1 then
		arg_21_0.TxtConfirm.text = _("Desc_goUnlock")
		arg_21_0.avatarBtnState = 2

		arg_21_0.BtnDetail:SetActive(false)
	else
		arg_21_0.TxtConfirm.text = _("UI_Buy")
		arg_21_0.avatarBtnState = 3

		arg_21_0.BtnDetail:SetActive(false)
	end
end

function PageEquipAvatar.OnClickBtnSave(arg_22_0)
	local var_22_0 = arg_22_0.listAvatar[arg_22_0.selectIndex]

	if var_22_0 == nil then
		return
	end

	local var_22_1 = not var_22_0.IsUnlocked
	local var_22_2 = var_22_0.Geted
end

function PageEquipAvatar.OnAvatarConfirm(arg_23_0)
	if arg_23_0.avatarBtnState == 1 then
		local var_23_0 = arg_23_0.listAvatar[arg_23_0.selectIndex]

		local function var_23_1(arg_24_0)
			if arg_24_0 then
				for iter_24_0, iter_24_1 in pairs(arg_23_0.listAvatar) do
					iter_24_1.RealEquiped = false
					iter_24_1.Equiped = false
				end

				var_23_0.RealEquiped = true

				arg_23_0.UIScrollTool:UpdateListDataKeepPos(arg_23_0.listAvatar)
			end
		end

		arg_23_0:RequestOperateAvatar(var_23_0.id, var_23_1)
	elseif arg_23_0.avatarBtnState == 2 then
		arg_23_0:OnGoFrom()
	elseif arg_23_0.avatarBtnState == 3 then
		arg_23_0:OnBtnBuy()
	end
end

function PageEquipAvatar.OnGoFrom(arg_25_0)
	local var_25_0 = arg_25_0.listAvatar[arg_25_0.selectIndex]
	local var_25_1 = AvatarManager:GetAvatar(var_25_0.id)

	local function var_25_2(arg_26_0)
		if arg_26_0 == 1 then
			if var_25_1.data.FromWhere == 1 then
				local var_26_0 = {}
			elseif var_25_1.data.FromWhere == 2 then
				local var_26_1 = {
					infoRole = arg_25_0.infoRole,
					roleId = arg_25_0.infoRole.id
				}

				UIMgr.SwitchPanel(PageTalentTree, var_26_1)
			end
		end
	end

	local var_25_3 = _("Avatar_From_" .. var_25_1.data.FromWhere)

	if var_25_1.data.FromWhere == 1 then
		local var_25_4 = RoleCardMgr:GetRoleCard(var_25_1.data.FromRoleCardID)
		local var_25_5 = 1

		for iter_25_0 = 1, #var_25_4.data.StarUnlockAvatar do
			local var_25_6 = var_25_4.data.StarUnlockAvatar[iter_25_0]

			for iter_25_1, iter_25_2 in pairs(var_25_6) do
				if iter_25_2 == var_25_1.id then
					var_25_5 = iter_25_0
				end
			end
		end

		local var_25_7 = string.format(_("UpToStarLevel"), var_25_5)

		var_25_3 = var_25_4.data.Rank .. "·" .. var_25_4:GetName() .. " " .. var_25_7
	end

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Go_Get"), var_25_3, var_25_2, _("UI_Go"))
end

function PageEquipAvatar.OnBtnBuy(arg_27_0)
	local function var_27_0(arg_28_0)
		if arg_28_0 == 1 then
			arg_27_0:RequestBuyAvatar()
		end
	end

	local var_27_1 = arg_27_0.listAvatar[arg_27_0.selectIndex]
	local var_27_2 = AvatarManager:GetAvatar(var_27_1.id)
	local var_27_3 = ItemManager:GetIcon(var_27_2.data.Cost[1])
	local var_27_4 = var_27_2.data.Cost[2]

	UIMgr.ShowCommon(DlgCommonEvent.Type.Buy, "", {
		icon = var_27_3,
		need = var_27_4,
		name = var_27_2:GetName()
	}, var_27_0)
end

function PageEquipAvatar.RequestBuyAvatar(arg_29_0)
	local function var_29_0(...)
		arg_29_0:OnHandleBuyAvatar(...)
	end

	local var_29_1 = arg_29_0.listAvatar[arg_29_0.selectIndex]

	NetManager:RequestBuyAvatar(arg_29_0.infoRole.id, {
		var_29_1.id
	}, var_29_0)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageEquipAvatar.OnHandleBuyAvatar(arg_31_0, arg_31_1)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if arg_31_1.result.code == NetManager.Result_Sucess then
		local var_31_0 = arg_31_0.listAvatar[arg_31_0.selectIndex]

		var_31_0.Geted = true

		table.insert(arg_31_0.infoRole.pb.avatars, var_31_0.id)
		arg_31_0.infoRole:UpdateEquipAttr()
		arg_31_0.infoRole:UpdateAttr()
		arg_31_0:EquipAvatar(var_31_0.id, true)

		for iter_31_0, iter_31_1 in pairs(arg_31_0.listAvatar) do
			iter_31_1.RealEquiped = false
		end

		var_31_0.RealEquiped = true

		arg_31_0.UIScrollTool:UpdateListDataKeepPos(arg_31_0.listAvatar)
		arg_31_0:UpdateBtnGroup()
		arg_31_0:UpateAvatarAttr()
		arg_31_0:RequestOperateAvatar(var_31_0.id)
		UIMgr.AddPanel(DlgNewSkin(), var_31_0.id)
	else
		UIMgr.ShowMsg(arg_31_1.result.desc)
	end
end

function PageEquipAvatar.RequestOperateAvatar(arg_32_0, arg_32_1, arg_32_2)
	local function var_32_0(arg_33_0)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if arg_33_0.result.code == NetManager.Result_Sucess then
			arg_32_0.infoRole.pb.weaponAvatar = arg_32_1

			if arg_32_2 then
				arg_32_2(true)
			end
		else
			UIMgr.ShowMsg(arg_33_0.result.desc)

			if arg_32_2 then
				arg_32_2(false)
			end
		end
	end

	NetManager:RequestEquipWeaponAvatar(arg_32_0.infoRole.id, arg_32_1, var_32_0)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageEquipAvatar.OnAvatarDetail(arg_34_0)
	local var_34_0 = arg_34_0.listAvatar[arg_34_0.selectIndex]
	local var_34_1 = AvatarManager:GetAvatar(var_34_0.id)

	arg_34_0.DlgPreviewWeapon:EquipAvatar(var_34_0.id)
	arg_34_0.PanelDetail:SetActive(true)

	arg_34_0:GetChildComponent("PanelDetail/Title/Text", "Text").text = var_34_1:GetName()

	for iter_34_0 = 1, 4 do
		arg_34_0:GetChildComponent("PanelDetail/PreProp/" .. iter_34_0 .. "/TextNum", "Text").text = var_34_1.data.SkinAttList[iter_34_0]
	end
end

function PageEquipAvatar.OnDetailQuit(arg_35_0)
	arg_35_0.PanelDetail:SetActive(false)
	arg_35_0.DlgPreviewWeapon:Exit()
end
