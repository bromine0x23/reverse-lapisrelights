require("UI/Page/PageRole/CellFetter")
require("UI/Page/PageRoleCard/Cell/CellCardSkill")
require("UI/Page/PageRole/DlgChooseCard")
require("UI/Page/PageRole/DlgAttrDetail")

local var_0_0 = {
	TutorialFunctionType.Equipment,
	TutorialFunctionType.Talent,
	TutorialFunctionType.Dress,
	[4] = 0
}

PageRole = class("PageRole", UIPanel)

function PageRole.ctor(arg_1_0)
	arg_1_0.UIPrefabPath = "UI/PanelRole/PanelRole"

	arg_1_0:AddChildPanel(DlgExit(), {
		title = _("eReturn_RoleInfo"),
		callback = arg_1_0.OnBack,
		panel = arg_1_0,
		preCallback = arg_1_0.PlayEndAnim
	})
	arg_1_0:AddChildPanel(DlgAssetsInfo(), {
		x = -600,
		y = -42
	})

	arg_1_0.listSpineRef = nil
end

function PageRole.PreLoad(arg_2_0)
	Event.Instance:Fire("UpdateSceneDisplay", true)

	arg_2_0.PrefabCellFetter = ResourceMgr.LoadSync("UI/PanelRole/CellFetter")
	arg_2_0.PrefabCellCardSkill = ResourceMgr.LoadSync("UI/PanelRoleCard/CellCardSkill")
end

function PageRole.OnBack(arg_3_0)
	local var_3_0 = UIMgr.GetPrePanel().vParam

	if var_3_0 == nil then
		var_3_0 = {
			infoRole = arg_3_0.infoRole
		}
	end

	UIMgr.PopPanel(var_3_0)
end

function PageRole.Purge(arg_4_0)
	arg_4_0.base.Purge(arg_4_0)

	if arg_4_0.UIScrollTool then
		arg_4_0.UIScrollTool:Purge()

		arg_4_0.UIScrollTool = nil
	end

	arg_4_0:UnloadSpineRef()
	ResourceMgr.Unload(arg_4_0.PrefabCellFetter)
	ResourceMgr.Unload(arg_4_0.PrefabCellCardSkill)
	UnloadAllImageSprite(arg_4_0)
	UIMgr:ClearDot()
	ResourceMgr.SetMaxCoroutine(4)

	if not arg_4_0.switchSystemType then
		UIMgr.HidePreviewActor()
	else
		UIMgr.PreviewActor:ChangeLens(arg_4_0.switchSystemType)
	end
end

function PageRole.UnloadSpineRef(arg_5_0)
	if arg_5_0.spineGroupHandle then
		ResourceMgr.Cancel(arg_5_0.spineGroupHandle)
	end

	if arg_5_0.listSpineRef then
		for iter_5_0, iter_5_1 in pairs(arg_5_0.listSpineRef) do
			ResourceMgr.Unload(iter_5_1)
		end

		arg_5_0.listSpineRef = nil
	end

	GOUtil.DestroyAllChildren(arg_5_0.ImgCardIcon.gameObject)
end

function PageRole.OnRegisterEvent(arg_6_0)
	arg_6_0:AddClick(arg_6_0.BtnCardL, arg_6_0.OnClickedBtnCardL)
	arg_6_0:AddClick(arg_6_0.BtnCardR, arg_6_0.OnClickedBtnCardR)
	arg_6_0:AddClick(arg_6_0.BtnAtt, arg_6_0.OnClickedBtnAtt)
	arg_6_0:AddClick(arg_6_0.GoCard, arg_6_0.OnClickedGoCard)
	arg_6_0:AddClick(arg_6_0.BtnRole, arg_6_0.OnClickedBtnRole)
	arg_6_0:AddClick(arg_6_0.BtnHeart, arg_6_0.OnClickedBtnHeart)
	arg_6_0:AddClick(arg_6_0.BtnRoleL, arg_6_0.OnClickedBtnRoleL)
	arg_6_0:AddClick(arg_6_0.BtnRoleR, arg_6_0.OnClickedBtnRoleR)

	for iter_6_0 = 1, 4 do
		if iter_6_0 <= 3 then
			arg_6_0:AddClick(arg_6_0["BtnTap" .. iter_6_0], arg_6_0.OnClickedBtnTap)
		end

		arg_6_0:AddClick(arg_6_0["BtnSwitch" .. iter_6_0], arg_6_0.OnClickedBtnSwitch)
	end

	arg_6_0:AddClick(arg_6_0.BtnInteract, arg_6_0.OnClickedGoInteract)
	Event.Instance:Add("UpdateRoleEquipedCard", arg_6_0.ShowEquipedCard, arg_6_0)
	Event.Instance:Add("DlgRoleHeartUpdatePanel", arg_6_0.UpdateRoleList, arg_6_0)
	Event.Instance:Add("UpdateDotNotify", arg_6_0.UpdateDot, arg_6_0)
end

function PageRole.OnUnRegisterEvent(arg_7_0)
	arg_7_0:RemoveClick(arg_7_0.BtnCardL, arg_7_0.OnClickedBtnCardL)
	arg_7_0:RemoveClick(arg_7_0.BtnCardR, arg_7_0.OnClickedBtnCardR)
	arg_7_0:RemoveClick(arg_7_0.BtnAtt, arg_7_0.OnClickedBtnAtt)
	arg_7_0:RemoveClick(arg_7_0.GoCard, arg_7_0.OnClickedGoCard)
	arg_7_0:RemoveClick(arg_7_0.BtnRole, arg_7_0.OnClickedBtnRole)
	arg_7_0:RemoveClick(arg_7_0.BtnHeart, arg_7_0.OnClickedBtnHeart)
	arg_7_0:RemoveClick(arg_7_0.BtnRoleL, arg_7_0.OnClickedBtnRoleL)
	arg_7_0:RemoveClick(arg_7_0.BtnRoleR, arg_7_0.OnClickedBtnRoleR)

	for iter_7_0 = 1, 4 do
		if iter_7_0 <= 3 then
			arg_7_0:RemoveClick(arg_7_0["BtnTap" .. iter_7_0], arg_7_0.OnClickedBtnTap)
		end

		arg_7_0:RemoveClick(arg_7_0["BtnSwitch" .. iter_7_0], arg_7_0.OnClickedBtnSwitch)
	end

	arg_7_0:RemoveClick(arg_7_0.BtnInteract, arg_7_0.OnClickedGoInteract)
	Event.Instance:Remove("UpdateRoleEquipedCard", arg_7_0.ShowEquipedCard, arg_7_0)
	Event.Instance:Remove("DlgRoleHeartUpdatePanel", arg_7_0.UpdateRoleList, arg_7_0)
	Event.Instance:Remove("UpdateDotNotify", arg_7_0.UpdateDot, arg_7_0)

	if arg_7_0.listCellSkill then
		for iter_7_1 = 1, #arg_7_0.listCellSkill do
			arg_7_0.listCellSkill[iter_7_1]:OnLeave()
		end

		GOUtil.DestroyAllChildren(arg_7_0.GoSkillGroup)
	end

	if arg_7_0.listGoSpe then
		for iter_7_2, iter_7_3 in pairs(arg_7_0.listGoSpe) do
			arg_7_0:RemoveListener(iter_7_3, arg_7_0.OnLongPressSpe, EventTriggerType.PointerLongPress)
		end

		GOUtil.DestroyAllChildren(arg_7_0.GoSpeGroup)
	end
end

function PageRole.OnEnter(arg_8_0, arg_8_1)
	ResourceMgr.SetMaxCoroutine(1)
	arg_8_0:DealWithLocalization()

	arg_8_0.Panel1 = arg_8_0:GetChildGameObject("Panel/Panel1")
	arg_8_0.Panel2 = arg_8_0:GetChildGameObject("Panel/Panel2")
	arg_8_0.Panel3 = arg_8_0:GetChildGameObject("Panel/Panel3")
	arg_8_0.BtnCardL = GOUtil.FindChildGameObject(arg_8_0.Panel1, "BtnL")
	arg_8_0.BtnCardR = GOUtil.FindChildGameObject(arg_8_0.Panel1, "BtnR")
	arg_8_0.BtnAtt = GOUtil.FindChildGameObject(arg_8_0.Panel1, "RoleAttr/Button")
	arg_8_0.GoCard = GOUtil.FindChildGameObject(arg_8_0.Panel1, "RoleCard/GoCard")
	arg_8_0.ImgCardBg = GOUtil.FindChildComponent(arg_8_0.GoCard, "CardMask/CardBg", "RawImage")
	arg_8_0.ImgCardIcon = GOUtil.FindChildComponent(arg_8_0.GoCard, "CardMask/CardIcon", "RawImage")
	arg_8_0.GoSpeGroup = GOUtil.FindChildGameObject(arg_8_0.Panel1, "RoleCard/Info/Specialty/Group")
	arg_8_0.GoSkillGroup = GOUtil.FindChildGameObject(arg_8_0.Panel1, "RoleCard/Skill")

	for iter_8_0 = 1, 4 do
		arg_8_0["BtnSwitch" .. iter_8_0] = arg_8_0:GetChildGameObject("BtnGroup/Btn" .. iter_8_0)
		arg_8_0["BtnSwitch" .. iter_8_0].name = iter_8_0

		local var_8_0 = GOUtil.GetComponent(arg_8_0["BtnSwitch" .. iter_8_0], "Image")
		local var_8_1 = true

		if var_0_0[iter_8_0] ~= 0 then
			var_8_1 = TutorialMgr:IsOpenNoMsg(var_0_0[iter_8_0])
		end

		local var_8_2 = TenaryOp(var_8_1, 0, 1)

		UIUtil.SetImageGray(var_8_0, var_8_2)
	end

	arg_8_0.BtnRole = arg_8_0:GetChildGameObject("BtnRole")
	arg_8_0.BtnHeart = arg_8_0:GetChildGameObject("BtnHeart")
	arg_8_0.BtnRoleL = arg_8_0:GetChildGameObject("RoleGrade/BtnLeft")
	arg_8_0.BtnRoleR = arg_8_0:GetChildGameObject("RoleGrade/BtnRight")
	arg_8_0.BtnInteract = arg_8_0:GetChildGameObject("BtnInteract")
	arg_8_0.GoHeartEnable = arg_8_0:GetChildGameObject("BtnHeart/ImgEnable")
	arg_8_0.GoHeartDisable = arg_8_0:GetChildGameObject("BtnHeart/ImgDisable")

	for iter_8_1 = 1, 3 do
		arg_8_0["BtnTap" .. iter_8_1] = arg_8_0:GetChildGameObject("Panel/BtnGroup/Btn" .. iter_8_1)
		arg_8_0["SelTap" .. iter_8_1] = arg_8_0:GetChildGameObject("Panel/BtnGroup/Sel" .. iter_8_1)
		arg_8_0["BtnTap" .. iter_8_1].name = iter_8_1
	end

	arg_8_0.Animator = GOUtil.GetComponent(arg_8_0.UIRootObject, "Animator")

	arg_8_0:InitData(arg_8_1)
end

function PageRole.DealWithLocalization(arg_9_0)
	arg_9_0:GetChildComponent("Panel/Panel1/RoleAttr/Title/Text", "Text").text = _("PageRole_TagAttr")
	arg_9_0:GetChildComponent("Panel/Panel1/RoleCard/Title/Text", "Text").text = _("PageRole_TagCard")
	arg_9_0:GetChildComponent("Panel/Panel1/RoleCard/Info/Sign/Text", "Text").text = _("Desc_Role_Location")
	arg_9_0:GetChildComponent("Panel/Panel1/RoleCard/Info/Specialty/Text", "Text").text = _("Desc_Role_Speciality")
	arg_9_0:GetChildComponent("Panel/Panel1/RoleAttr/Button/Text", "Text").text = _("UI_detail")
	arg_9_0:GetChildComponent("BtnGroup/Btn1/Text", "Text").text = _("Desc_From_11_1")
	arg_9_0:GetChildComponent("BtnGroup/Btn2/Text", "Text").text = _("Desc_WorldMap_12")
	arg_9_0:GetChildComponent("BtnGroup/Btn3/Text", "Text").text = _("Desc_WorldMap_3")
	arg_9_0:GetChildComponent("Panel/BtnGroup/Btn1/Text", "Text").text = _("eReturn_PlayerInfo")
	arg_9_0:GetChildComponent("Panel/BtnGroup/Sel1/Text", "Text").text = _("eReturn_PlayerInfo")
	arg_9_0:GetChildComponent("Panel/BtnGroup/Btn2/Text", "Text").text = _("PageRole_Fetter")
	arg_9_0:GetChildComponent("Panel/BtnGroup/Sel2/Text", "Text").text = _("PageRole_Fetter")
	arg_9_0:GetChildComponent("Panel/BtnGroup/Btn3/Text", "Text").text = _("PageRole_Detail")
	arg_9_0:GetChildComponent("Panel/BtnGroup/Sel3/Text", "Text").text = _("PageRole_Detail")

	for iter_9_0 = 1, 4 do
		arg_9_0:GetChildComponent("Panel/Panel1/RoleAttr/Attr/" .. iter_9_0 .. "/TxtAttr", "Text").text = _("eAttType_" .. iter_9_0)
	end
end

function PageRole.InitData(arg_10_0, arg_10_1)
	arg_10_0.curTabIdx = 1

	if arg_10_1 then
		arg_10_0.initRoleId = arg_10_1.roleId
	end

	arg_10_0:UpdateRoleList()
	arg_10_0:UpdateGroupTab()
end

function PageRole.UpdateRoleList(arg_11_0)
	arg_11_0.listRole = RoleMgr:GetSelectHoldRole()
	arg_11_0.roleIdx = RoleMgr:GetSelectHoldRoleIndex()

	if arg_11_0.initRoleId then
		for iter_11_0 = 1, #arg_11_0.listRole do
			if arg_11_0.listRole[iter_11_0].id == arg_11_0.initRoleId then
				arg_11_0.roleIdx = iter_11_0
				arg_11_0.initRoleId = nil

				break
			end
		end
	end

	arg_11_0:UpdateRole()
	arg_11_0:UpdateFavoriteState()
end

function PageRole.UpdateRole(arg_12_0)
	arg_12_0:UnloadSpineRef()

	arg_12_0.infoRole = arg_12_0.listRole[arg_12_0.roleIdx]

	if RoleCardMgr:IsNewRole(arg_12_0.infoRole.id) then
		RoleCardMgr:RemovePlayerPrefsViewdRole(arg_12_0.infoRole.id)
	end

	if not arg_12_0.infoRole then
		return
	end

	arg_12_0:UpdateRoleCard()
	UIMgr.ShowPreviewActor(arg_12_0.infoRole)

	arg_12_0.update1 = false
	arg_12_0.update2 = false
	arg_12_0.update3 = false

	if arg_12_0.curTabIdx == 1 then
		arg_12_0:UpdatePanel1()
	elseif arg_12_0.curTabIdx == 2 then
		arg_12_0:UpdatePanel2()
	elseif arg_12_0.curTabIdx == 3 then
		arg_12_0:UpdatePanel3()
	end

	arg_12_0:UpdateCombat()
	arg_12_0:UpdateDot()
end

function PageRole.UpdateCombat(arg_13_0)
	local var_13_0 = arg_13_0.infoRole
	local var_13_1 = arg_13_0:GetChildComponent("RoleGrade/Tex_name", "Text")
	local var_13_2 = arg_13_0:GetChildComponent("RoleGrade/Job", "Image")

	var_13_1.text = var_13_0:GetName()

	if var_13_0.data.Leader == 0 then
		arg_13_0:GetChildGameObject("RoleGrade/Img_Leader"):SetActive(false)
	else
		arg_13_0:GetChildGameObject("RoleGrade/Img_Leader"):SetActive(true)
	end

	SetImageSprite(var_13_2, "UIDyAtlas/RoleJob/ICO_" .. var_13_0.data.Job .. "_01_S", arg_13_0)

	arg_13_0:GetChildComponent("RoleGrade/Tex_grade", "Text").text = Mathf.Floor(RoleMgr:GetRoleScore(arg_13_0.infoRole))
end

function PageRole.UpdateRoleCard(arg_14_0)
	arg_14_0.listRoleCard = RoleCardMgr:GetRoleHoldCard(arg_14_0.infoRole.id)

	table.sort(arg_14_0.listRoleCard, function(arg_15_0, arg_15_1)
		return RoleCardMgr:GetCompareRankAndLevel(arg_15_0, arg_15_1, 1)
	end)

	local var_14_0 = arg_14_0.infoRole:GetRoleCardId()
	local var_14_1 = TenaryOp(var_14_0 == 0, arg_14_0.listRoleCard[1].id, var_14_0)

	for iter_14_0, iter_14_1 in pairs(arg_14_0.listRoleCard) do
		if iter_14_1.id == var_14_1 then
			arg_14_0.cardIdx = iter_14_0

			break
		end
	end
end

function PageRole.UpdatePanel1(arg_16_0)
	arg_16_0.update1 = true

	arg_16_0:UpdateRoleCardInfo()
	arg_16_0:UpdateDynamicVal()
end

function PageRole.UpdateRoleCardInfo(arg_17_0)
	arg_17_0.infoRoleCard = arg_17_0.listRoleCard[arg_17_0.cardIdx]

	local var_17_0 = arg_17_0.infoRoleCard

	arg_17_0.BtnCardL:SetActive(arg_17_0.cardIdx ~= 1)
	arg_17_0.BtnCardR:SetActive(arg_17_0.cardIdx ~= #arg_17_0.listRoleCard)

	local var_17_1 = GOUtil.FindChildComponent(arg_17_0.Panel1, "RoleCard/Info/Name/Txt", "Text")
	local var_17_2 = GOUtil.FindChildComponent(arg_17_0.Panel1, "RoleCard/Info/Sign/Txt/Text", "Text")

	var_17_1.text = Lang(var_17_0.data.Name)
	var_17_2.text = Lang(var_17_0.data.Location[2])
	arg_17_0.listSkill = RoleCardMgr:GetCardAllSkill(var_17_0)

	table.sort(arg_17_0.listSkill, function(arg_18_0, arg_18_1)
		return arg_18_0.data.Type < arg_18_1.data.Type
	end)

	arg_17_0.listSpe = var_17_0.listAbility

	if arg_17_0.listGoSpe then
		for iter_17_0, iter_17_1 in pairs(arg_17_0.listGoSpe) do
			arg_17_0:RemoveListener(iter_17_1, arg_17_0.OnLongPressSpe, EventTriggerType.PointerLongPress)
		end
	end

	GOUtil.DestroyAllChildren(arg_17_0.GoSpeGroup)

	local var_17_3 = GOUtil.FindChildGameObject(arg_17_0.Panel1, "RoleCard/Info/Specialty/CellSpe")

	var_17_3:SetActive(true)

	arg_17_0.listGoSpe = {}

	for iter_17_2 = 1, #arg_17_0.listSpe do
		local var_17_4 = GOUtil.InstantiateUI(var_17_3, arg_17_0.GoSpeGroup)
		local var_17_5 = GOUtil.GetComponent(var_17_4, "Image")

		SetImageSprite(var_17_5, arg_17_0.listSpe[iter_17_2].Icon, arg_17_0)

		var_17_4.name = iter_17_2

		arg_17_0:AddListener(var_17_4, arg_17_0.OnLongPressSpe, EventTriggerType.PointerLongPress)
		table.insert(arg_17_0.listGoSpe, var_17_4)
	end

	var_17_3:SetActive(false)

	if arg_17_0.listCellSkill then
		for iter_17_3 = 1, #arg_17_0.listCellSkill do
			arg_17_0.listCellSkill[iter_17_3]:OnLeave()
		end
	end

	GOUtil.DestroyAllChildren(arg_17_0.GoSkillGroup)

	arg_17_0.listCellSkill = {}

	for iter_17_4 = 1, #arg_17_0.listSkill do
		local var_17_6 = CellCardSkill(arg_17_0.PrefabCellCardSkill, arg_17_0.GoSkillGroup)

		var_17_6:Create()

		local var_17_7 = arg_17_0.listSkill[iter_17_4]

		var_17_6:UpdateData({
			infoRoleCard = var_17_0,
			info = var_17_7
		})

		var_17_6.UIRootObject.name = iter_17_4

		GOUtil.SetTransformLocalScale(var_17_6.UIRootObject, 0.8)
		table.insert(arg_17_0.listCellSkill, var_17_6)
	end

	arg_17_0:UpdateCard()
end

function PageRole.UpdateCard(arg_19_0)
	local var_19_0 = arg_19_0.infoRoleCard
	local var_19_1 = GOUtil.FindChildComponent(arg_19_0.GoCard, "Rank", "Image")
	local var_19_2 = GOUtil.FindChildComponent(arg_19_0.GoCard, "Job", "Image")

	GOUtil.FindChildComponent(arg_19_0.GoCard, "TxtLv", "Text").text = var_19_0.curLevel

	SetImageSprite(var_19_1, "UIDyAtlas/RoleCardRank/BG_card_back_" .. var_19_0.rank .. "_13", arg_19_0)
	SetImageSprite(var_19_2, "UIDyAtlas/RoleJob/ICO_" .. arg_19_0.infoRole.data.Job .. "_01_S", arg_19_0)

	local var_19_3 = {
		GoFrame = GOUtil.FindChildGameObject(arg_19_0.GoCard, "Star/Frame"),
		GoStar1 = GOUtil.FindChildGameObject(arg_19_0.GoCard, "Star/Star1"),
		GoStar2 = GOUtil.FindChildGameObject(arg_19_0.GoCard, "Star/Star2")
	}

	RoleCardMgr:SetStar(var_19_0, var_19_3)

	for iter_19_0 = 1, 4 do
		local var_19_4 = GOUtil.FindChildGameObject(arg_19_0.GoCard, "Petal/State" .. iter_19_0)

		var_19_4:SetActive(iter_19_0 == var_19_0.cardRank)

		if iter_19_0 == var_19_0.cardRank then
			local var_19_5 = var_19_0.maxPetal
			local var_19_6 = var_19_0.curPetal

			for iter_19_1 = 1, var_19_5 do
				local var_19_7 = GOUtil.FindChildComponent(var_19_4, "" .. iter_19_1, "Image")
				local var_19_8 = TenaryOp(iter_19_1 <= var_19_6, 0, 1)

				UIUtil.SetImageGray(var_19_7, var_19_8)
			end
		end
	end

	arg_19_0.ImgCardIcon.enabled = var_19_0.data.SpineData == ""

	arg_19_0.ImgCardBg.gameObject:SetActive(var_19_0.data.SpineData == "")

	if arg_19_0.spineGroupHandle then
		ResourceMgr.Cancel(arg_19_0.spineGroupHandle)
	end

	if var_19_0.data.SpineData ~= "" then
		GOUtil.DestroyAllChildren(arg_19_0.ImgCardIcon.gameObject)

		local function var_19_9(arg_20_0)
			if arg_20_0 ~= var_19_0.id then
				return
			end

			if arg_19_0.spineRef then
				if not arg_19_0.listSpineRef then
					arg_19_0.listSpineRef = {}
				end

				table.insert(arg_19_0.listSpineRef, arg_19_0.spineRef)

				local var_20_0 = GOUtil.InstantiatePrefab(arg_19_0.spineRef, arg_19_0.ImgCardIcon.gameObject)

				if GOUtil.GetComponent(var_20_0, "SpineAspectRatioFitter") then
					GOUtil.GetComponent(var_20_0, "SpineAspectRatioFitter").enabled = false
				end

				arg_19_0.spineRef = nil
			end
		end

		arg_19_0.spineGroupHandle = ResourceMgr.BeginSubmit(var_19_9, var_19_0.id)

		ResourceMgr.SubmitCache(var_19_0.data.SpineData .. "_Anim", arg_19_0, "spineRef", GameObject)
		ResourceMgr.EndSubmit()
	else
		RoleCardMgr:SetInfoPanel(var_19_0, arg_19_0.ImgCardIcon, arg_19_0.ImgCardBg, arg_19_0)
	end

	RoleCardMgr:SetCardLocation(var_19_0, arg_19_0.ImgCardIcon.gameObject, 3)
end

function PageRole.UpdateDynamicVal(arg_21_0)
	for iter_21_0 = 1, 4 do
		local var_21_0 = arg_21_0:GetChildComponent("Panel/Panel1/RoleAttr/Attr/" .. iter_21_0 .. "/TxtValue", "Text")
		local var_21_1 = RoleMgr:IndexToAttrType(iter_21_0)
		local var_21_2 = 0

		if arg_21_0.infoRole.hold then
			var_21_2 = arg_21_0.infoRole:GetNewAtt(var_21_1, arg_21_0.infoRoleCard)
		end

		var_21_0.text = Mathf.Floor(var_21_2 + 0.5)
	end
end

function PageRole.UpdatePanel2(arg_22_0)
	arg_22_0.update2 = true
	arg_22_0.listJoin = arg_22_0.infoRole.listRoleJoin

	local function var_22_0()
		local var_23_0 = arg_22_0:GetChildGameObject("Panel/Panel2/ScrollArea")
		local var_23_1 = arg_22_0:GetChildComponent("Panel/Panel2/ScrollArea/Content", "Transform")
		local var_23_2 = #arg_22_0.listJoin

		local function var_23_3(arg_24_0)
			arg_22_0:AddClick(arg_24_0.UIRootObject, nil)
		end

		local function var_23_4(arg_25_0, arg_25_1)
			local var_25_0 = arg_22_0.listJoin[arg_25_1]

			arg_25_0:UpdateData(var_25_0)
		end

		arg_22_0.UIScrollTool = UIScrollTool()

		arg_22_0.UIScrollTool:InitList(var_23_0, var_23_1, var_23_2, arg_22_0.PrefabCellFetter, CellFetter, arg_22_0, false, var_23_3, var_23_4)
	end

	if not arg_22_0.inited then
		var_22_0()

		arg_22_0.inited = true
	else
		arg_22_0.UIScrollTool:UpdateListData(arg_22_0.listJoin)
	end
end

function PageRole.UpdatePanel3(arg_26_0)
	arg_26_0.update3 = true

	local var_26_0 = arg_26_0:GetChildComponent("Panel/Panel3/Image", "Image")

	UIUtil.SetImageSprite(var_26_0, arg_26_0.infoRole.data.InfoIcon)
end

function PageRole.UpdateFavoriteState(arg_27_0)
	local var_27_0 = false

	for iter_27_0 = 1, #PlayerInst.InfoPlayer.favoriteRoles do
		if PlayerInst.InfoPlayer.favoriteRoles[iter_27_0] == arg_27_0.infoRole.id then
			var_27_0 = true

			break
		end
	end

	arg_27_0.GoHeartEnable:SetActive(var_27_0)
	arg_27_0.GoHeartDisable:SetActive(not var_27_0)
end

function PageRole.OnLongPressSpe(arg_28_0, arg_28_1)
	if arg_28_1.clickCount == 1 then
		local var_28_0 = tonumber(arg_28_1.pointerPressRaycast.gameObject.name)
		local var_28_1 = arg_28_0.listSpe[var_28_0]
		local var_28_2 = SkillTip.GetWorkCondData(arg_28_1.position, var_28_1)

		UIMgr.ShowSkillTip(var_28_2)
	else
		UIMgr.HideSkillTip()
	end
end

function PageRole.ShowEquipedCard(arg_29_0)
	arg_29_0:UpdateRoleCard()
	arg_29_0:UpdateRoleCardInfo()
	arg_29_0:UpdateDynamicVal()
end

function PageRole.OnClickedBtnTap(arg_30_0, arg_30_1)
	local var_30_0 = tonumber(arg_30_1.pointerPress.name)

	if arg_30_0.curTabIdx == var_30_0 then
		return
	end

	arg_30_0.curTabIdx = var_30_0

	arg_30_0:UpdateGroupTab()
end

function PageRole.UpdateGroupTab(arg_31_0)
	for iter_31_0 = 1, 3 do
		arg_31_0["BtnTap" .. iter_31_0]:SetActive(iter_31_0 ~= arg_31_0.curTabIdx)
		arg_31_0["SelTap" .. iter_31_0]:SetActive(iter_31_0 == arg_31_0.curTabIdx)
	end

	arg_31_0.Panel1:SetActive(arg_31_0.curTabIdx == 1)
	arg_31_0.Panel2:SetActive(arg_31_0.curTabIdx == 2)
	arg_31_0.Panel3:SetActive(arg_31_0.curTabIdx == 3)

	if arg_31_0.curTabIdx == 1 then
		if not arg_31_0.update1 then
			arg_31_0:UpdatePanel1()
		end
	elseif arg_31_0.curTabIdx == 2 then
		if not arg_31_0.update2 then
			arg_31_0:UpdatePanel2()
		else
			arg_31_0.UIScrollTool:SetContentPos(arg_31_0.pos or Vector2.zero, 0)
		end
	elseif arg_31_0.curTabIdx == 3 and not arg_31_0.update3 then
		arg_31_0:UpdatePanel3()
	end

	if arg_31_0.UIScrollTool then
		local var_31_0 = 0
		local var_31_1 = arg_31_0.UIScrollTool.ScrollView.content.anchoredPosition.y or 0

		arg_31_0.pos = Vector2.New(var_31_0, var_31_1)
	end
end

function PageRole.OnClickedBtnCardL(arg_32_0)
	arg_32_0.cardIdx = TenaryOp(arg_32_0.cardIdx - 1 < 1, 1, arg_32_0.cardIdx - 1)

	arg_32_0:UpdateRoleCardInfo()
	arg_32_0:UpdateDynamicVal()
end

function PageRole.OnClickedBtnCardR(arg_33_0)
	arg_33_0.cardIdx = TenaryOp(arg_33_0.cardIdx + 1 > #arg_33_0.listRoleCard, #arg_33_0.listRoleCard, arg_33_0.cardIdx + 1)

	arg_33_0:UpdateRoleCardInfo()
	arg_33_0:UpdateDynamicVal()
end

function PageRole.OnClickedBtnRoleL(arg_34_0)
	arg_34_0.roleIdx = TenaryOp(arg_34_0.roleIdx - 1 < 1, #arg_34_0.listRole, arg_34_0.roleIdx - 1)

	arg_34_0:UpdateRole()
	arg_34_0:SaveRole()
	arg_34_0:UpdateFavoriteState()
end

function PageRole.OnClickedBtnRoleR(arg_35_0)
	arg_35_0.roleIdx = TenaryOp(arg_35_0.roleIdx + 1 > #arg_35_0.listRole, 1, arg_35_0.roleIdx + 1)

	arg_35_0:UpdateRole()
	arg_35_0:SaveRole()
	arg_35_0:UpdateFavoriteState()
end

function PageRole.SaveRole(arg_36_0)
	local var_36_0 = string.split(RoleCardMgr:GetRoleCardSelect(), "_")
	local var_36_1 = var_36_0[1] .. "_" .. var_36_0[2] .. "_" .. arg_36_0.roleIdx

	RoleCardMgr:SetRoleCardSelect(var_36_1)
end

function PageRole.OnClickedBtnRole(arg_37_0)
	if RoleCardMgr:GetRoleIconFirstState() == "1" then
		RoleCardMgr:SetRoleIconFirstState("0")
	end

	RoleCardMgr:SetRoleHeartState()
	require("UI/Dlg/DlgRoleHeart/DlgRoleHeart")
	UIMgr.AddPanel(DlgRoleHeart(), {
		typeId = 1,
		roleId = arg_37_0.infoRole.id
	}, arg_37_0.UIRootObject)
end

function PageRole.OnClickedBtnHeart(arg_38_0)
	local var_38_0 = 1
	local var_38_1 = {}

	for iter_38_0 = 1, #PlayerInst.InfoPlayer.favoriteRoles do
		if tonumber(PlayerInst.InfoPlayer.favoriteRoles[iter_38_0]) == tonumber(arg_38_0.infoRole.id) then
			var_38_0 = 0
		end
	end

	local var_38_2 = {
		favoriteRoles = {
			arg_38_0.infoRole.id,
			var_38_0
		}
	}

	local function var_38_3(arg_39_0)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if arg_39_0.result.code == NetManager.Result_Sucess then
			if var_38_0 == 1 then
				PlayerInst.InfoPlayer:AddFavoriteRoles(arg_38_0.infoRole.id)
				UIMgr.ShowMsg(_("Msg_CollectionSuccess"))
			else
				PlayerInst.InfoPlayer:RemoveFavoriteRoles(arg_38_0.infoRole.id)
				UIMgr.ShowMsg(_("Msg_CollectionCancel"))
			end

			arg_38_0:UpdateFavoriteState()
		else
			UIMgr.ShowMsg(arg_39_0.result.desc)
		end
	end

	NetManager:RequestModifyPlayerInfo(var_38_2, var_38_3)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageRole.OnClickedBtnAtt(arg_40_0)
	local var_40_0 = {
		infoRole = arg_40_0.infoRole,
		infoRoleCard = arg_40_0.infoRoleCard
	}

	UIMgr.AddPanel(DlgAttrDetail(), var_40_0)
end

function PageRole.OnClickedGoCard(arg_41_0)
	UIMgr.AddPanel(DlgChooseCard(), {
		infoRole = arg_41_0.infoRole
	})
end

function PageRole.OnClickedBtnSwitch(arg_42_0, arg_42_1)
	local var_42_0 = tonumber(arg_42_1.pointerPress.name)
	local var_42_1 = true

	if var_0_0[var_42_0] ~= 0 then
		var_42_1 = TutorialMgr:IsOpenTut(var_0_0[var_42_0])
	end

	if not var_42_1 then
		return
	end

	if var_42_0 == 1 then
		arg_42_0.switchSystemType = eActorSystemType.Equip

		require("UI/Page/PageEquipment/PageEquip")
		UIMgr.SwitchPanel(PageEquip, {
			roleId = arg_42_0.infoRole.id
		})
		Event.Instance:Fire("UpdateSceneDisplay", false)
	elseif var_42_0 == 2 then
		require("UI/Page/PageRole/PageTalentTree")
		UIMgr.SwitchPanel(PageTalentTree, {
			roleId = arg_42_0.infoRole.id
		})
	elseif var_42_0 == 3 then
		arg_42_0.switchSystemType = eActorSystemType.Fitting

		require("UI/Page/PageFittingroom/PageFittingroom")
		UIMgr.SwitchPanel(PageFittingroom, {
			infoRole = arg_42_0.infoRole
		})
	end
end

function PageRole.OnClickedGoInteract(arg_43_0)
	if UIMgr.GetPrePanel().className == "PageInteraction" then
		arg_43_0:OnBack()
	else
		SceneMainStage.Instance:OnEnterInteractionByRoleId(arg_43_0.infoRole.id)
	end
end

function PageRole.PlayEndAnim(arg_44_0, arg_44_1)
	arg_44_0.Animator:Play("eff_ui_Pagerole_out")
	arg_44_1(1)
end

function PageRole.UpdateDot(arg_45_0)
	for iter_45_0 = 1, 3 do
		if IsNil(arg_45_0["GoDot" .. iter_45_0]) then
			arg_45_0["GoDot" .. iter_45_0] = UIMgr:AddDot(arg_45_0["BtnSwitch" .. iter_45_0], iter_45_0, 1, Vector2(-36, -26))
		end

		local var_45_0 = false

		if iter_45_0 == 1 then
			var_45_0 = PersistentStoreUtil.GetBool("EquipDot") or RoleMgr:GetRoleTypeLevelDot(2, 3, arg_45_0.infoRole) and TutorialMgr:IsOpenNoMsg(var_0_0[1])
		elseif iter_45_0 == 2 then
			var_45_0 = PersistentStoreUtil.GetBool("TalentDot") or RoleMgr:GetRoleTypeLevelDot(2, 2, arg_45_0.infoRole) and TutorialMgr:IsOpenNoMsg(var_0_0[2])
		elseif iter_45_0 == 3 then
			for iter_45_1 = 1, 7 do
				if PersistentStoreUtil.GetBool("AvatarDot_" .. arg_45_0.infoRole.id .. "_" .. iter_45_1, false) then
					var_45_0 = true

					break
				end
			end

			var_45_0 = var_45_0 or PersistentStoreUtil.GetBool("DressDot")
		end

		if var_45_0 then
			UIMgr:ShowDot(iter_45_0)
		else
			UIMgr:HideDot(iter_45_0)
		end
	end

	local var_45_1 = RoleMgr:GetAllHoldRole()
	local var_45_2 = false

	for iter_45_2 = 1, #var_45_1 do
		local var_45_3 = var_45_1[iter_45_2].id
		local var_45_4 = false

		for iter_45_3 = 1, 7 do
			if PersistentStoreUtil.GetBool("AvatarDot_" .. var_45_3 .. "_" .. iter_45_3, false) then
				var_45_4 = true

				break
			end
		end

		if var_45_4 then
			local var_45_5 = true

			break
		end
	end

	if IsNil(arg_45_0.GoRoleDot) then
		arg_45_0.GoRoleDot = UIMgr:AddDot(arg_45_0.BtnRole, 4, 1, Vector2(-18, -18))
	end

	if RoleMgr:GetRoleTypeLevelDot(2, 1, arg_45_0.infoRole) then
		UIMgr:ShowDot(4)
	else
		UIMgr:HideDot(4)
	end
end
