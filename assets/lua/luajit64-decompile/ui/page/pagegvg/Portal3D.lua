-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGvg/Portal3D.lua

local RELIVE_TIME = 5
local portal = class("DlgGvg_Steps_Portal3D", UIItemBase)

function portal:Init(obj, root)
	portal.base.base.ctor(self)

	self.UIRootObject = obj

	self:OnEnter()
	self:OnRegisterEvent()
end

function portal:Purge()
	self:OnUnRegisterEvent()
end

function portal:OnRegisterEvent()
	Event.Instance:Add("OnTap_Monster3dRender", self.OnTap, self)
	self:AddClick(self.obj_clickArea, self.OnClick)
end

function portal:OnUnRegisterEvent()
	Event.Instance:Remove("OnTap_Monster3dRender", self.OnTap, self)
	self:RemoveClick(self.obj_clickArea, self.OnClick)
end

function portal:OnEnter()
	self.step = 0
	self.portalIdx = 0
	self.txt_progress = self:GetChildComponent("txt_progress", "Text")
	self.img_fill = self:GetChildComponent("img_fill", "Image")
	self.img_fill_bk = self:GetChildComponent("img_fill_bk", "Image")
	self.img_completed = self:GetChildComponent("img_completed", "Image")
	self.obj_clickArea = self:GetChildGameObject("obj_clickarea")
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
		Infogvg:Error("portal找見つかりませんmonster！step：" .. self.step .. " portalIdx:" .. self.portalIdx)

		return
	end

	local hp, maxhp = stage:GetMonsterHp()
	local progress = hp / maxhp

	if stage:IsComplete() == true then
		progress = 0
	end

	UIUtil.SetTextString(self.txt_progress, math.ceil(progress * 100) .. "%")

	if self.relive then
		UITweenUtil.FillAmountAnim(self.img_fill, 0, progress, RELIVE_TIME)
		EffectMgr:Alloc("Fx/UI/FX_UI_DlgGvg/FX_FillRestore", self.UIRootObject, true, RELIVE_TIME)
	else
		self.img_fill.fillAmount = progress
	end

	if stage:IsPass() then
		local infoStage = InfoStage(stage.stageId)

		self.img_completed.enabled = stage.refreshTimes + 1 == infoStage.data.PlayNum and stage:GetMonsterHp() <= 0

		local cfg = Infogvg.cfg:MaxPortal()
		local maxPortal = cfg[self.step]

		if self.portalIdx == maxPortal then
			local img = self:GetChildComponent("img_bossflag", "Image")

			UIUtil.SetImageGray(img, 1)
		end
	else
		self.img_completed.enabled = stage:IsComplete()
	end

	self.monsterId = monster.monsterId

	if stage:IsPass() or stage:IsLock() then
		self.img_fill.enabled = false
		self.img_fill_bk.enabled = false
	else
		self.img_fill.enabled = true
		self.img_fill_bk.enabled = true
	end
end

function portal:Relive()
	self.relive = true

	self:Refresh(self.step, self.portalIdx)

	self.relive = false

	return RELIVE_TIME
end

function portal:Dead()
	self.img_fill.fillAmount = 0
end

function portal:OnClick()
	Event.Instance:Fire("EVENT_GVG_SELECT_PORTAL", self.step, self.portalIdx)
end

function portal:OnTap(model)
	return
end

return portal
