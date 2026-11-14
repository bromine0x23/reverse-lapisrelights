-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageEquipment/DlgNewSkin.lua

DlgNewSkin = class("DlgNewSkin", UIPanel)

function DlgNewSkin:ctor()
	self.UIPrefabPath = "UI/PanelEquipment/DlgNewSkin"
end

function DlgNewSkin:OnRegisterEvent()
	self:AddClick(self.BtnClose, self.OnClickedBtnClose)
end

function DlgNewSkin:OnUnRegisterEvent()
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
end

function DlgNewSkin:OnEnter(vParam)
	local txt

	txt = self:GetChildComponent("Panel/Attr/Text", "Text")
	txt.text = _("PageEquip_LimitProp")
	txt = self:GetChildComponent("Panel/Text", "Text")
	txt.text = _("Desc_ClickClose")
	self.BtnClose = self:GetChildGameObject("Bg")

	InfoSoundEventMgr:LoadBank(RoleMgr:GetMaxFavorRole().data.VocalBank)
	InfoSoundEventMgr:Play("VocalCommon2", RoleMgr:GetMaxFavorRole().data.VocalCommon2)
	self:UpdatePanel(unpack(vParam))
end

function DlgNewSkin:UpdatePanel(infoRole, infoAvatar)
	local txtName = self:GetChildComponent("Panel/TxtName", "Text")

	txtName.text = infoAvatar:GetName()

	local ImgIcon = self:GetChildComponent("Panel/Icon", "Image")

	UIUtil.SetImageOverrideSprite(ImgIcon, infoAvatar.data.Icon, self)

	for k, v in ipairs(ATTRIBUTE_MAP[1]) do
		local txtAtt = self:GetChildComponent("Panel/Attr/" .. k .. "/Text", "Text")

		txtAtt.text = _("eAttType_" .. k)

		local txtNum = self:GetChildComponent("Panel/Attr/" .. k .. "/TxtV", "Text")

		txtNum.text = "+ " .. ExchangeAttValue(v, infoRole.equipBaseAtt:Get(v) * infoAvatar:GetMulAtt(v) + infoAvatar:GetAddAtt(v))
	end
end

function DlgNewSkin:OnClickedBtnClose()
	self:Close()
	InfoSoundEventMgr:OnBack()
end
