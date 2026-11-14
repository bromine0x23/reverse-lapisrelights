require("UI/Item/UIItemBase")

CellHeartTab = class("CellHeartTab", UIItemBase)

local var_0_0 = require("Info/InfoTeam")

function CellHeartTab.ctor(arg_1_0, arg_1_1, arg_1_2)
	arg_1_0.ItemPrefabCache = arg_1_1
	arg_1_0.Parent = arg_1_2
end

function CellHeartTab.Create(arg_2_0, arg_2_1)
	CellHeartTab.base.Create(arg_2_0, arg_2_1)
end

function CellHeartTab.OnEnter(arg_3_0)
	local var_3_0 = arg_3_0.UIRootObject

	arg_3_0.Btn = arg_3_0:GetChildGameObject("Btn")
	arg_3_0.Sel = arg_3_0:GetChildGameObject("Sel")
	arg_3_0.Img_on = arg_3_0:GetChildGameObject("Img_on")
	arg_3_0.Img_off = arg_3_0:GetChildGameObject("Img_off")
	arg_3_0.Content = arg_3_0:GetChildGameObject("ScrollArea/Content")
	arg_3_0.Text = arg_3_0:GetChildComponent("Text", "Text")
	arg_3_0.TextGo = arg_3_0:GetChildGameObject("Text")

	arg_3_0.Btn:SetActive(true)
	arg_3_0.Sel:SetActive(false)
	arg_3_0.Img_off:SetActive(true)
	arg_3_0.Img_on:SetActive(false)
	arg_3_0:OnRegisterEvent()
end

function CellHeartTab.UpdateData(arg_4_0, arg_4_1, arg_4_2)
	if arg_4_1 then
		arg_4_0.Btn:SetActive(false)
		arg_4_0.Sel:SetActive(true)

		if arg_4_2 == 0 then
			arg_4_0.Img_off:SetActive(true)
			arg_4_0.Img_on:SetActive(false)
		else
			arg_4_0.Img_off:SetActive(false)
			arg_4_0.Img_on:SetActive(true)
		end
	else
		arg_4_0.Btn:SetActive(true)
		arg_4_0.Sel:SetActive(false)
		arg_4_0.Img_off:SetActive(true)
		arg_4_0.Img_on:SetActive(false)
	end

	if arg_4_0.UIRootObject.name == "2" then
		GOUtil.SetRectTransformSizeDelta(arg_4_0.Content, 292, 660)
	elseif arg_4_0.UIRootObject.name == "3" then
		GOUtil.SetRectTransformSizeDelta(arg_4_0.Content, 292, 550)
	elseif arg_4_0.UIRootObject.name == "4" then
		local var_4_0 = var_0_0.stageTeams
		local var_4_1 = 0

		for iter_4_0 = 1, 5 do
			local var_4_2 = var_4_0[iter_4_0]
			local var_4_3 = 0

			for iter_4_1 = 1, 10 do
				if var_4_2.roleCardTeams[iter_4_1] ~= 0 then
					var_4_3 = 1
				end
			end

			if var_4_3 == 1 then
				var_4_1 = var_4_1 + 1
			end
		end

		GOUtil.SetRectTransformSizeDelta(arg_4_0.Content, 292, 110 * (var_4_1 + 2))
	end

	if arg_4_0.UIRootObject.name == "1" then
		arg_4_0.Img_off:SetActive(false)
		arg_4_0.Img_on:SetActive(false)
		GOUtil.SetRectTransformAnchoredPosition(arg_4_0.TextGo, 0, 0)

		arg_4_0.Text.text = _("PageChooseCard_All")
	elseif arg_4_0.UIRootObject.name == "2" then
		arg_4_0.Text.text = Lang(12076)
	elseif arg_4_0.UIRootObject.name == "3" then
		arg_4_0.Text.text = Lang(12020)
	elseif arg_4_0.UIRootObject.name == "4" then
		arg_4_0.Text.text = Lang(12079)
	end
end

function CellHeartTab.OnRegisterEvent(arg_5_0)
	return
end

function CellHeartTab.OnUnRegisterEvent(arg_6_0)
	return
end

function CellHeartTab.OnClickedCell(arg_7_0)
	return
end

function CellHeartTab.OnLeave(arg_8_0)
	arg_8_0:OnUnRegisterEvent()
end
