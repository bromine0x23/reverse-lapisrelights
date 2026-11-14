-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFittingroom/DlgAvatarAttr.lua

DlgAvatarAttr = class("DlgAvatarAttr", UIPanel)

function DlgAvatarAttr:ctor()
	self.UIPrefabPath = "UI/PageFittingroom/DlgAvatarAttr"
end

function DlgAvatarAttr:PreLoad()
	return
end

function DlgAvatarAttr:Purge()
	self.base.Purge(self)
end

function DlgAvatarAttr:OnRegisterEvent()
	self:AddClick(self.UIRootObject, self.OnClickClose)
end

function DlgAvatarAttr:OnUnRegisterEvent()
	self:RemoveClick(self.UIRootObject, self.OnClickClose)
end

function DlgAvatarAttr:OnEnter(vParam)
	local txt = self:GetChildComponent("Panel/Panel/Title/Text", "Text")

	txt.text = _("Desc_Title_Attribute_Add")
	self.TxtPrompt = self:GetChildComponent("Panel/Panel/Text", "Text")
	self.TxtPrompt.text = _("Desc_Attribute_Add_None")

	for i = 1, #ATTRIBUTE_NAME do
		self["GoAtt" .. i] = self:GetChildGameObject("Panel/Panel/Content/" .. i)
		self["TextAtt" .. i] = self:GetChildComponent("Panel/Panel/Content/" .. i .. "/Image/Text", "Text")
		self["TextValue" .. i] = self:GetChildComponent("Panel/Panel/Content/" .. i .. "/Text", "Text")
	end

	self:UpdatePanel(vParam)
end

function DlgAvatarAttr:UpdatePanel(vParam)
	self.page = vParam.page

	local infoRole = vParam.infoRole
	local list = {}

	if infoRole then
		for k, v in ipairs(ATTRIBUTE_NAME) do
			local att = infoRole.bpAvatarAtt:GetExtraAdd(v)

			if att > 0 then
				list[k] = att
			end
		end
	end

	local cnt = table.getCount(list)

	GOUtil.SetActive(self.TxtPrompt, cnt <= 0)

	local i = 1

	for k, v in pairsByKeys(list) do
		self["GoAtt" .. i]:SetActive(true)

		self["TextAtt" .. i].text = _("eAttType_" .. k)

		if GetAttValueType(GetAttENKey(k)) == eValueType.Abs then
			self["TextValue" .. i].text = "+" .. v
		else
			self["TextValue" .. i].text = "+" .. v * 100 .. "%"
		end

		i = i + 1
	end
end

function DlgAvatarAttr:OnClickClose()
	self.page.GoAttr1:SetActive(true)
	self.page.GoAttr2:SetActive(false)
	self:Close()
end
