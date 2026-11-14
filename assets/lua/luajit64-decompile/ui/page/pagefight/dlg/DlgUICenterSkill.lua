-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUICenterSkill.lua

DlgUICenterSkill = class("DlgUICenterSkill", UIPanel_sync)

function DlgUICenterSkill:ctor()
	DlgUICenterSkill.base.ctor(self, "UI/PageFight/Dlg/DlgUICenterSkill")
end

function DlgUICenterSkill:Cache()
	DlgUICenterSkill.base.Cache(self)
end

function DlgUICenterSkill:Close()
	DlgUICenterSkill.base.Close(self)
end

function DlgUICenterSkill:Purge()
	DlgUICenterSkill.base.Purge(self)
end

function DlgUICenterSkill:OnEnter()
	self:Show(false)

	self.txt_name = self:GetChildComponent("panel/txt_name", "Text")
	self.txt_desc = self:GetChildComponent("panel/txt_desc", "Text")
	self.img_icon = self:GetChildComponent("panel/img_icon", "Image")
	self.delayHandle = nil
end

function DlgUICenterSkill:Open()
	local center = SceneMgr.GetCurrentScene().GP.Team.CenterUnit

	for _, ownSkill in ipairs(center.OwnSkills) do
		if ownSkill.BattleSkillType == EnumFight.SkillType.Center then
			ownSkill:SetIcon(self.img_icon)
			ownSkill:SetName(self.txt_name)
			ownSkill:SetDesc(self.txt_desc)
			self:Show(true)
		end
	end

	self.delayHandle = BattleConfig.Delay(1.7, function()
		GP.UI.DlgUICombinationSkill:Open()
	end)

	BattleConfig.Delay(2, function()
		self:Show(false)
	end)
end

function DlgUICenterSkill:Hide()
	self:Show(false)
	TimerMgr.RemoveTimer(self.delayHandle)
	GP.UI.DlgUICombinationSkill:Show(false)
end

function DlgUICenterSkill:OnRegisterEvent()
	return
end

function DlgUICenterSkill:OnUnRegisterEvent()
	return
end
