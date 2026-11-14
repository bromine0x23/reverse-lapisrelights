require("UI/Item/UIItemBase")

CellRoleHead = class("CellRoleHead", UIItemBase)

function CellRoleHead.ctor(arg_1_0, arg_1_1, arg_1_2)
	arg_1_0.ItemPrefabCache = arg_1_1
	arg_1_0.Parent = arg_1_2
end

function CellRoleHead.Create(arg_2_0, arg_2_1)
	CellRoleHead.base.Create(arg_2_0, arg_2_1)
end

function CellRoleHead.OnEnter(arg_3_0)
	local var_3_0 = arg_3_0.UIRootObject

	arg_3_0.isSel = true
	arg_3_0.isGray = false
	arg_3_0.data = nil
	arg_3_0.Role = GOUtil.FindChildComponent(var_3_0, "Role", "Image")
	arg_3_0.Team = arg_3_0:GetChildComponent("Team", "Image")
	arg_3_0.ImgSel = GOUtil.FindChildComponent(var_3_0, "ImgSel", "Image")
	arg_3_0.ImgOut = GOUtil.FindChildComponent(var_3_0, "ImgOut", "Image")
	arg_3_0.ImgHeart = GOUtil.FindChildComponent(var_3_0, "ImgHeart", "Image")
	arg_3_0.ImgBattle = GOUtil.FindChildComponent(var_3_0, "ImgBattle", "Image")
	arg_3_0.GoSel = GOUtil.FindChildGameObject(var_3_0, "ImgSel")
	arg_3_0.GoOut = GOUtil.FindChildGameObject(var_3_0, "ImgOut")
	arg_3_0.GoHeart = GOUtil.FindChildGameObject(var_3_0, "ImgHeart")
	arg_3_0.GoBattle = GOUtil.FindChildGameObject(var_3_0, "ImgBattle")
	arg_3_0.GoDot = GOUtil.FindChildGameObject(var_3_0, "dot")
	arg_3_0.GoNew = GOUtil.FindChildGameObject(var_3_0, "new")
	arg_3_0:GetChildComponent("ImgBattle/Text", "Text").text = Lang(5000013)

	arg_3_0:OnRegisterEvent()
end

function CellRoleHead.UpdateData(arg_4_0, arg_4_1, arg_4_2)
	local var_4_0 = arg_4_1.cellHeadData.actorData

	arg_4_0.allCellHeadData = arg_4_1.allCellHeadData
	arg_4_0.data = arg_4_1

	UIUtil.SetImageSprite(arg_4_0.Role, var_4_0.CharacterIcon, arg_4_0)
	arg_4_0.GoHeart:SetActive(arg_4_1.favoriteRoleId == 1)

	local var_4_1 = TenaryOp(arg_4_1.cellHeadData.hold, 0, 1)

	if var_4_1 == 0 then
		arg_4_0.isGray = false
	else
		arg_4_0.isGray = true
	end

	arg_4_0.GoSel:SetActive(arg_4_1.roleId == 1)
	arg_4_0.GoOut:SetActive(arg_4_1.roleId == 1)
	arg_4_0.GoBattle:SetActive(arg_4_1.jobValue == 1)

	if arg_4_1.roleId == 1 then
		RoleCardMgr:SetRoleHeartState(RoleMgr:GetRole(arg_4_1.cellHeadData.id))
	end

	local var_4_2 = RoleMgr:IsNewRole(arg_4_1.cellHeadData.id)

	arg_4_0.GoNew:SetActive(var_4_2)
	arg_4_0.GoDot:SetActive(RoleMgr:CellRoleHeadDot(RoleMgr:GetRole(arg_4_1.cellHeadData.id)) and not arg_4_0.isGray)
	UIUtil.SetImageGray(arg_4_0.Role, var_4_1)
	UIUtil.SetImageGray(arg_4_0.Team, var_4_1)
end

function CellRoleHead.OnRegisterEvent(arg_5_0)
	arg_5_0:AddClick(arg_5_0.UIRootObject, arg_5_0.OnClickedCell)
end

function CellRoleHead.OnUnRegisterEvent(arg_6_0)
	arg_6_0:RemoveClick(arg_6_0.UIRootObject, arg_6_0.OnClickedCell)
end

function CellRoleHead.OnClickedCell(arg_7_0, arg_7_1)
	return
end

function CellRoleHead.OnLeave(arg_8_0)
	arg_8_0:OnUnRegisterEvent()
end
