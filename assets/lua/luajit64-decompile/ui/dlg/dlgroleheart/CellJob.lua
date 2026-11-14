require("UI/Item/UIItemBase")

CellJob = class("CellJob", UIItemBase)

local var_0_0 = {
	"Strength",
	"Artifice",
	"Speed",
	"Intelligence",
	"Assistance"
}

function CellJob.ctor(arg_1_0, arg_1_1, arg_1_2)
	arg_1_0.ItemPrefabCache = arg_1_1
	arg_1_0.Parent = arg_1_2
end

function CellJob.Create(arg_2_0, arg_2_1)
	CellJob.base.Create(arg_2_0, arg_2_1)
end

function CellJob.OnEnter(arg_3_0)
	local var_3_0 = arg_3_0.UIRootObject

	arg_3_0.Image = GOUtil.FindChildComponent(var_3_0, "Image", "Image")
	arg_3_0.Sel = GOUtil.GetComponent(var_3_0, "Image")
	arg_3_0.Text = arg_3_0:GetChildComponent("Text", "Text")

	arg_3_0:OnRegisterEvent()
end

function CellJob.UpdateData(arg_4_0, arg_4_1, arg_4_2)
	UIUtil.SetImageSprite(arg_4_0.Image, "UIDyAtlas/RoleJob/ICO_" .. var_0_0[arg_4_1] .. "_01", arg_4_0)

	arg_4_0.Text.text = _("eJobWord_" .. var_0_0[arg_4_1])

	if arg_4_1 == arg_4_2 then
		UIUtil.SetImageSprite(arg_4_0.Sel, "UI/Common/DlgRoleHeart/AtlasDlgRoleHeart/BTN_togglebar_03", arg_4_0)
	else
		UIUtil.SetImageSprite(arg_4_0.Sel, "UI/Common/DlgRoleHeart/AtlasDlgRoleHeart/BTN_togglebar_02", arg_4_0)
	end
end

function CellJob.OnRegisterEvent(arg_5_0)
	return
end

function CellJob.OnUnRegisterEvent(arg_6_0)
	return
end

function CellJob.OnClickedCell(arg_7_0)
	return
end

function CellJob.OnLeave(arg_8_0)
	arg_8_0:OnUnRegisterEvent()
	UnloadAllImageSprite(arg_8_0)
end
