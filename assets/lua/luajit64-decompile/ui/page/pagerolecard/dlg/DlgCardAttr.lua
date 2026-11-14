-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Dlg/DlgCardAttr.lua

DlgCardAttr = class("DlgCardAttr", UIPanel)

function DlgCardAttr:ctor()
	self.UIPrefabPath = "UI/PanelRoleCard/DlgCardAttr"
	self.cb = nil
end

function DlgCardAttr:Purge()
	self.base.Purge(self)

	self.cb = nil
end

function DlgCardAttr:OnRegisterEvent()
	self:AddClick(self.UIRootObject, self.OnClickedContinue)
end

function DlgCardAttr:OnUnRegisterEvent()
	self:RemoveClick(self.UIRootObject, self.OnClickedContinue)
end

function DlgCardAttr:OnEnter(vParam)
	local Text = self:GetChildComponent("Panel/Title/Text", "Text")

	Text.text = Lang(12345)
	Text = self:GetChildComponent("Panel/SumScore/Text", "Text")
	Text.text = _("Desc_Score_Total")
	Text = self:GetChildComponent("Panel/SumScore/TxtType", "Text")
	Text.text = _("Desc_Contain_Role")
	Text = self:GetChildComponent("Panel/Score/Text", "Text")
	Text.text = _("Desc_Score_Card")
	Text = self:GetChildComponent("Panel/Attr/Text", "Text")
	Text.text = Lang(42178)

	local infoRoleCard = vParam.infoRoleCard
	local onlyShow = vParam.onlyShow

	self.cb = vParam.cb

	local infoRole

	if onlyShow then
		infoRoleCard.attrs = infoRoleCard:UpdateAtt(infoRoleCard.maxLevel, infoRoleCard.maxStarLevel, infoRoleCard.maxPetal)
		infoRole = RoleMgr:ForgeRole(infoRoleCard.data.CharacterID)
	else
		infoRole = RoleCardMgr:GetRole(infoRoleCard.id)
	end

	local txtSumScore = self:GetChildComponent("Panel/SumScore/Text/Text", "Text")

	txtSumScore.text = RoleCardMgr:GetFightValue(infoRole, infoRoleCard)

	local txtCardScore = self:GetChildComponent("Panel/Score/Text/Text", "Text")

	txtCardScore.text = RoleCardMgr:GetCardFightValue(infoRoleCard)

	for k, v in pairs(ATTRIBUTE_NAME) do
		local txtAttr = self:GetChildComponent("Panel/Attr/" .. k .. "/Image/TxtAttr", "Text")

		txtAttr.text = _("eAttType_" .. k)

		local txtValue = self:GetChildComponent("Panel/Attr/" .. k .. "/TxtValue", "Text")

		txtValue.text = math.floor(infoRoleCard.attrs:Get(v) + 0.5)
	end
end

function DlgCardAttr:OnClickedContinue()
	if self.cb then
		self.cb()

		self.cb = nil
	end

	self:Close()
end
