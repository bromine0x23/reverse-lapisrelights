-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Dlg/DlgUnlockSkill.lua

DlgUnlockSkill = class("DlgUnlockSkill", UIPanel)

function DlgUnlockSkill:ctor()
	self.UIPrefabPath = "UI/PanelRoleCard/DlgUnlockSkill"
	self.callback = nil
end

function DlgUnlockSkill:PreLoad()
	self:LoadResAsync("UI/PanelRoleCard/CellCardSkill", "PrefabCellCardSkill", GameObject)
end

function DlgUnlockSkill:Purge()
	self.base.Purge(self)
	self:OnLeave()
end

function DlgUnlockSkill:OnLeave()
	if self.CellSkill and self.CellSkill.OnLeave ~= nil then
		self.CellSkill:OnLeave()
	end

	ResourceMgr.Unload(self.PrefabCellCardSkill)
end

function DlgUnlockSkill:OnRegisterEvent()
	self:AddClick(self.GoClose, self.OnClickedClose, PATH_SFX_UI_CANCEL)
end

function DlgUnlockSkill:OnUnRegisterEvent()
	self:RemoveClick(self.GoClose, self.OnClickedClose)
end

function DlgUnlockSkill:OnEnter(vParam)
	local txt = self:GetChildComponent("Text", "Text")

	txt.text = _("Desc_ClickClose_1")
	self.GoClose = self:GetChildGameObject("Bg")
	self.SkillPoint = self:GetChildGameObject("Panel/Skill/CellSkill/Con")

	local infoRoleCard = vParam.infoRoleCard
	local infoTalent

	if vParam.skillId then
		infoTalent = TalentManager:Get(vParam.skillId)
	else
		infoTalent = vParam.info
	end

	local showType = vParam.infoType

	if infoTalent and infoTalent.data.BattleSkillType == eBattleTalentType.SpecialBall then
		showType = CELL_CARD_SKILL_TYPE.Ball
	end

	self.CellSkill = CellCardSkill(self.PrefabCellCardSkill, self.SkillPoint, self)

	self.CellSkill:Create()
	GOUtil.SetTransformLocalScale(self.CellSkill.UIRootObject, 0.75)
	self.CellSkill:UpdateData({
		infoRoleCard = infoRoleCard,
		info = infoTalent,
		infoType = showType
	})

	self.callback = vParam.callback
end

function DlgUnlockSkill:OnClickedClose()
	self:Close()

	if self.callback then
		self.callback()

		self.callback = nil
	end
end
