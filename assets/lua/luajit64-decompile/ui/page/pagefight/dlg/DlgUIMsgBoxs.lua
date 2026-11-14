-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUIMsgBoxs.lua

DlgUIMsgBoxs = class("DlgUIMsgBoxs", UIPanel_sync)

local Label = {}
local bInitlabel = false

Label.sessionDic = {}

function Label.Init()
	if bInitlabel == true then
		return
	end

	local sessionWord = require("luaData/SessionWord")

	for _, ele in ipairs(sessionWord) do
		Label.sessionDic[ele.CharacterID] = {}
		Label.sessionDic[ele.CharacterID] = ele
	end
end

function DlgUIMsgBoxs:ctor()
	DlgUIMsgBoxs.base.ctor(self, "UI/PageFight/Dlg/DlgUIMsgBox")
end

function DlgUIMsgBoxs:Cache()
	DlgUIMsgBoxs.base.Cache(self)
end

function DlgUIMsgBoxs:Close(tParam)
	if self.timeId ~= nil then
		TimerMgr.RemoveTimer(self.timeId)
	end

	DlgUIMsgBoxs.base.Close(self, tParam)
end

function DlgUIMsgBoxs:OnRegisterEvent()
	EventListenerMgr.AddAnimListener(self.UIRootObject, self.OnBack, self, eAnimEventType.OnAnimationEnd)
end

function DlgUIMsgBoxs:OnUnRegisterEvent()
	EventListenerMgr.RemoveAnimListener(self.UIRootObject, self.OnBack, self, eAnimEventType.OnAnimationEnd)
end

function DlgUIMsgBoxs:Purge()
	DlgUIMsgBoxs.base.Purge(self)
	UIMgr:RemoveSafeArea(self)
end

function DlgUIMsgBoxs:OnEnter(vParam)
	UIMgr:SetSafeArea(self, self.UIRootObject)
	Label.Init()

	self.anim = GOUtil.GetComponent(self.UIRootObject, "Animator")
	self.img_headIcon = self:GetChildComponent("panel/img_headIcon", "Image")
	self.txt_dialogLabel = self:GetChildComponent("panel/bubble/bg/txt_dialogLabel", "Text")

	self:Show(false)
end

function DlgUIMsgBoxs:Open(field, unit)
	if GP.FightMode ~= EnumFight.BattleType.BOSS then
		return
	end

	local cfg = Label.sessionDic[unit.UnitId]

	if not cfg then
		return
	end

	if not cfg[field] then
		return
	end

	local label = Lang(cfg[field])

	self:Show(true)
	self:SetBubble(label, unit)
end

function DlgUIMsgBoxs:OnBack()
	self:Show(false)
end

function DlgUIMsgBoxs:SetBubble(label, unit)
	self.anim:Play("DlgBattleMsgBox_open")

	local targetUnit = unit

	self:SetRoleImg(targetUnit)

	self.txt_dialogLabel.text = label

	if self.timeId ~= nil then
		TimerMgr.RemoveTimer(self.timeId)
	end

	self.timeId = BattleConfig.Delay(2, function()
		self:Show(false)
	end)
end

function DlgUIMsgBoxs:SetRoleImg(unit)
	local path = unit.InfoRoleCard.data.HitIcon

	GP.SpriteUtil:SetSprite(self.img_headIcon, path)
end
