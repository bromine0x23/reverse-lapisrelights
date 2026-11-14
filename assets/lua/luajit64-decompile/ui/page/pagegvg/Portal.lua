-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGvg/Portal.lua

local portal = class("DlgGvg_Steps_Portal", UIItemBase)
local RELIVE_TIME = 5

function portal:Init(obj, root)
	portal.base.base.ctor(self)

	self.UIRootObject = obj

	self:OnEnter()
	self:OnRegisterEvent()
end

function portal:Purge()
	self:OnUnRegisterEvent()

	if self.reliveHandle then
		TimerMgr.RemoveTimer(self.reliveHandle)
	end
end

function portal:OnRegisterEvent()
	self:AddClick(self.obj_clickArea, self.OnClick)
end

function portal:OnUnRegisterEvent()
	self:RemoveClick(self.obj_clickArea, self.OnClick)
end

function portal:OnEnter()
	self.step = 0
	self.portalIdx = 0
	self.img_fill = self:GetChildComponent("img_fill", "Image")
	self.img_fill_bk = self:GetChildComponent("img_fill_bk", "Image")
	self.img_icon = self:GetChildComponent("img_icon", "Image")
	self.obj_clickArea = self:GetChildGameObject("obj_clickarea")
	self.img_iconMask = self:GetChildComponent("img_iconMask", "Image")
	self.img_iconMask.enabled = false
	self.img_selected = self:GetChildComponent("img_selected", "Image")
	self.txt_stageName = self:GetChildComponent("title/txt_name", "Text")
	self.obj_effects = self:GetChildGameObject("effects")
	self.reliveHandle = nil
end

function portal:Refresh(step, portalIdx)
	self.step = step
	self.portalIdx = portalIdx

	local stage

	for i, s in Infogvg.stage:Filter():IsStep(step):IsPortal(portalIdx):Ipairs() do
		stage = s

		if stage:IsComplete() == false then
			break
		end
	end

	if not stage then
		Infogvg:Error("portal見つかりませんstage！step：" .. self.step .. " portalIdx:" .. self.portalIdx)

		return
	end

	self.stageId = stage.stageId

	local monster = stage.monsters[1]

	if not monster then
		Infogvg:Error("portal見つかりませんmonster！step：" .. self.step .. " portalIdx:" .. self.portalIdx)

		return
	end

	local progress = self:_GetProgres()

	if stage.previousWin == true and progress > 0 then
		stage.previousWin = false

		UITweenUtil.FillAmountAnim(self.img_fill, 0, progress, RELIVE_TIME)
		EffectMgr:Alloc("Fx/UI/FX_UI_DlgGvg/FX_FillRestore", self.UIRootObject, true, RELIVE_TIME)
	else
		self.img_fill.fillAmount = progress
	end

	self.monsterId = monster.monsterId

	SetImageSprite(self.img_icon, Infogvg.cfg:StageImagePortal(stage.portalIdx), self, true)

	self.img_selected.enabled = stage:IsComplete()

	GOUtil.SetActive(self.obj_effects, not stage:IsComplete())

	if stage:IsLock() == true or stage:IsComplete() == true then
		self.img_icon.color = Color.New(0.4745, 0.4745, 0.4745)
	end

	local infoStage = InfoStage(self.stageId)

	if string.isNullOrEmpty(Lang(infoStage.data.Name)) then
		self.txt_stageName.text = "クエスト名未設定"
	else
		self.txt_stageName.text = Lang(infoStage.data.Name)
	end

	if stage:IsPass() then
		self.img_fill.enabled = false
		self.img_fill_bk.enabled = false
	else
		self.img_fill.enabled = true
		self.img_fill_bk.enabled = true
	end
end

function portal:_GetProgres()
	local progress = 0
	local stage = Infogvg.stage:Get(self.stageId)

	if stage then
		local hp, maxhp = stage:GetMonsterHp()

		progress = hp / maxhp

		if stage:IsComplete() == true then
			progress = 0
		end
	end

	return progress
end

function portal:OnClick()
	Event.Instance:Fire("EVENT_GVG_SELECT_PORTAL", self.step, self.portalIdx)
end

return portal
