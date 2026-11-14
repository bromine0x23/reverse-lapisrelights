require("UI/Item/UIItemBase")

CellDefaultTeam = class("CellDefaultTeam", UIItemBase)

function CellDefaultTeam.ctor(arg_1_0, arg_1_1, arg_1_2)
	arg_1_0.ItemPrefabCache = arg_1_1
	arg_1_0.Parent = arg_1_2
end

function CellDefaultTeam.Create(arg_2_0, arg_2_1)
	CellDefaultTeam.base.Create(arg_2_0, arg_2_1)
end

function CellDefaultTeam.OnEnter(arg_3_0)
	local var_3_0 = arg_3_0.UIRootObject

	arg_3_0.Text = GOUtil.FindChildComponent(var_3_0, "Text", "Text")
	arg_3_0.Sel = GOUtil.GetComponent(var_3_0, "Image")

	arg_3_0:OnRegisterEvent()
end

function CellDefaultTeam.UpdateData(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4)
	if arg_4_3 == 0 then
		arg_4_0.UIRootObject:SetActive(false)
	else
		arg_4_0.UIRootObject:SetActive(true)
	end

	if arg_4_1.name ~= "" then
		arg_4_0.Text.text = arg_4_1.name
	else
		arg_4_0.Text.text = _("PageBattleTeam_TeamNum") .. arg_4_1.id
	end

	if arg_4_2 == arg_4_4 then
		UIUtil.SetImageSprite(arg_4_0.Sel, "UI/Common/DlgRoleHeart/AtlasDlgRoleHeart/BTN_togglebar_03", arg_4_0)
	else
		UIUtil.SetImageSprite(arg_4_0.Sel, "UI/Common/DlgRoleHeart/AtlasDlgRoleHeart/BTN_togglebar_02", arg_4_0)
	end
end

function CellDefaultTeam.OnRegisterEvent(arg_5_0)
	return
end

function CellDefaultTeam.OnUnRegisterEvent(arg_6_0)
	return
end

function CellDefaultTeam.OnClickedCell(arg_7_0)
	return
end

function CellDefaultTeam.OnLeave(arg_8_0)
	arg_8_0:OnUnRegisterEvent()
end
