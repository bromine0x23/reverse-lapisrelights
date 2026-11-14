-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUIPVPCardSkill.lua

local _BattleSkillData = require("Info.InfoBattleSkillData")

DlgUIPVPCardSkill = class("DlgUIPVPCardSkill", UIPanel_sync)

function DlgUIPVPCardSkill:ctor()
	DlgUIPVPCardSkill.base.ctor(self, "UI/PageFight/Dlg/DlgUIPVPCardSkill")
end

function DlgUIPVPCardSkill:Cache()
	DlgUIPVPCardSkill.base.Cache(self)
end

function DlgUIPVPCardSkill:Purge()
	DlgUIPVPCardSkill.base.Purge(self)
end

function DlgUIPVPCardSkill:Close()
	DlgUIPVPCardSkill.base.Close(self)
end

function DlgUIPVPCardSkill:OnEnter()
	self:Hide()

	self.txt_name = self:GetChildComponent("CardName/Text", "Text")
	self.img_cardIcon = self:GetChildComponent("CardIcon/mask/img_cardIcon", "Image")
	self.txt_mp = self:GetChildComponent("CardIcon/txt_sp", "Text")
	self.img_descIcon = self:GetChildComponent("CardIcon/img_descIcon", "Image")
end

function DlgUIPVPCardSkill:Hide()
	self.UIRootObject:SetActive(false)
end

function DlgUIPVPCardSkill:Refresh(ownSkill, onComplete)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator", false)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", false)
	self.UIRootObject:SetActive(true)

	local unitBase = UnitOwnSkill.Get(ownSkill.Id).Owner
	local smallIcon = ""

	if unitBase.UnitData.data.PlayType == 2 then
		local cardid = unitBase.UnitData.data.CardID
		local cfg = ConfigTable.CharacterCard[cardid]

		if cfg then
			smallIcon = cfg.SmallIcon
		end
	else
		smallIcon = unitBase.InfoRoleCard.data.SmallIcon
	end

	GP.SpriteUtil:SetSprite(self.img_cardIcon, smallIcon)

	local config = _BattleSkillData:GetData(ownSkill.Id)

	self.txt_mp.text = tostring(config.Cost)

	ownSkill:SetDescIcon(self.img_descIcon)
	ownSkill:SetName(self.txt_name)
	BattleConfig.Delay(1, function()
		if onComplete then
			onComplete()
		end

		self:Hide()
	end)
end
