-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGvg/SwitchStep.lua

local mt = class("DlgGvg_SwitchStep", UIItemBase)
local _color_img_cur = "FFEF6D"
local _color_img = "585E62"
local _color_txt_cur = "585E62"
local _color_txt = "C6C8CA"

function mt:Init(obj)
	mt.base.base.ctor(self)

	self.UIRootObject = obj
	self.curStep = -1
	self.largebks = {}
	self.stepbks = {}
	self.obj_effects = {}
	self.largebks[1] = self:GetChildGameObject("largebks/bk1")
	self.largebks[2] = self:GetChildGameObject("largebks/bk2")
	self.largebks[3] = self:GetChildGameObject("largebks/bk3")
	self.stepbks[1] = self:GetChildGameObject("stepbks/bk1")
	self.stepbks[2] = self:GetChildGameObject("stepbks/bk2")
	self.stepbks[3] = self:GetChildGameObject("stepbks/bk3")
	self.obj_effects[1] = self:GetChildGameObject("stepbks/bk1/obj_effects")
	self.obj_effects[2] = self:GetChildGameObject("stepbks/bk2/obj_effects")
	self.obj_effects[3] = self:GetChildGameObject("stepbks/bk3/obj_effects")
	self.txt_step = self:GetChildComponent("safeArea/progressInfo/title/txt_step", "Text")
	self.btn_left = self:GetChildGameObject("safeArea/progressInfo/btn_left/obj_click")
	self.img_left = self:GetChildComponent("safeArea/progressInfo/btn_left", "Image")
	self.btn_right = self:GetChildGameObject("safeArea/progressInfo/btn_right/obj_click")
	self.img_right = self:GetChildComponent("safeArea/progressInfo/btn_right", "Image")
	self.imgs_dot = {}
	self.imgs_dot[1] = self:GetChildComponent("safeArea/progressInfo/dots/item1", "Image")
	self.imgs_dot[2] = self:GetChildComponent("safeArea/progressInfo/dots/item2", "Image")
	self.imgs_dot[3] = self:GetChildComponent("safeArea/progressInfo/dots/item3", "Image")
	self.txts_dot = {}
	self.txts_dot[1] = self:GetChildComponent("safeArea/progressInfo/dots/item1/Text", "Text")
	self.txts_dot[2] = self:GetChildComponent("safeArea/progressInfo/dots/item2/Text", "Text")
	self.txts_dot[3] = self:GetChildComponent("safeArea/progressInfo/dots/item3/Text", "Text")
	self.txt_condition = self:GetChildComponent("safeArea/progressInfo/txt_condition", "Text")
	self.txt_progress = self:GetChildComponent("safeArea/progressInfo/progress/txt_progress", "Text")
	self.img_fill = self:GetChildComponent("safeArea/progressInfo/progress/img_fill", "Image")
	self.obj_mask_unlock = self:GetChildGameObject("safeArea/progressInfo/obj_mask_unlock")
	self.obj_mask_pass = self:GetChildGameObject("safeArea/progressInfo/obj_mask_pass")
	self.obj_masktitle = self:GetChildGameObject("safeArea/progressInfo/obj_masktitle")
	self.obj_completed = self:GetChildGameObject("safeArea/progressInfo/obj_completed")
	self.btn_rewardview = self:GetChildGameObject("safeArea/progressInfo/btn_reward")
	self.btn_score = self:GetChildGameObject("safeArea/progressInfo/btn_score")
	self.obj_drag = self:GetChildGameObject("obj_drag")

	self:OnRegisterEvent()
end

function mt:Purge()
	self:OnUnRegisterEvent()
	EffectMgr:UnLoadEffect("Fx/UI/FX_UI_DlgGvg/FX_Cloud_Anim2")
	EffectMgr:UnLoadEffect("Fx/UI/FX_UI_DlgGvg/FX_Cloud_Anim3")

	if self.delayHandle then
		TimerMgr.RemoveTimer(self.delayHandle)
	end
end

function mt:OnRegisterEvent()
	self:AddListener(self.obj_drag, self.OnBeginDrag, EventTriggerType.BeginDrag)
	self:AddListener(self.obj_drag, self.OnDrag, EventTriggerType.Drag)
	self:AddListener(self.obj_drag, self.OnEndDrag, EventTriggerType.EndDrag)
	self:AddClick(self.btn_left, self.OnBtnLeft)
	self:AddClick(self.btn_right, self.OnBtnRight)
end

function mt:OnUnRegisterEvent()
	self:RemoveListener(self.obj_drag, self.OnBeginDrag, EventTriggerType.BeginDrag)
	self:RemoveListener(self.obj_drag, self.OnDrag, EventTriggerType.Drag)
	self:RemoveListener(self.obj_drag, self.OnEndDrag, EventTriggerType.EndDrag)
	self:RemoveClick(self.btn_left, self.OnBtnLeft)
	self:RemoveClick(self.btn_right, self.OnBtnRight)
end

function mt:OnDrag(data)
	return
end

function mt:OnBeginDrag(data)
	return
end

function mt:OnEndDrag(data)
	local dragPosX = data.pressPosition.x - data.position.x

	print(dragPosX)

	if dragPosX > 200 then
		self:OnBtnRight()
	elseif dragPosX < -200 then
		self:OnBtnLeft()
	end
end

function mt:OnBtnLeft()
	local step = self.curStep - 1

	if step >= 1 and step <= 3 then
		EffectMgr:Alloc("Fx/UI/FX_UI_DlgGvg/FX_Cloud_Anim2", self.UIRootObject, true, 2)

		self.curStep = step

		self:_OnBtnClick(step)
	end
end

function mt:OnBtnRight()
	local step = self.curStep + 1

	if step >= 1 and step <= 3 then
		EffectMgr:Alloc("Fx/UI/FX_UI_DlgGvg/FX_Cloud_Anim3", self.UIRootObject, true, 2)

		self.curStep = step

		self:_OnBtnClick(step)
	end
end

function mt:_OnBtnClick()
	if self.delayHandle then
		TimerMgr.RemoveTimer(self.delayHandle)
	end

	self.delayHandle = TimerMgr.AddTimer(eTimerType.ScaleTime, 0.5, function()
		Event.Instance:Fire("EVENT_GVG_UI_SWITCHSTEP", self.curStep)
	end, nil)
end

function mt:SwitchTo(step)
	self.curStep = step

	if self.curStep == 1 then
		local max = ActiveMgr:GetActive(Infogvg.stage.activeId).data.ArgJson[1]
		local cur = Infogvg.stage.phaseTimes

		self.img_fill.fillAmount = cur / max

		local str = cur .. "/" .. max

		UIUtil.SetTextString(self.txt_progress, str)
	elseif self.curStep == 2 then
		self:Step2()
	elseif self.curStep == 3 then
		self:Step3()
	end

	self:RefreshUI()
end

function mt:Step2()
	local stage

	for i, s in Infogvg.stage:Filter():IsStep(2):IsPortal(4):Ipairs() do
		stage = s

		if stage:IsComplete() == false then
			break
		end
	end

	if not stage then
		Infogvg:Error("portal見つかりませんstage！step：" .. self.step .. " portalIdx:" .. self.portalIdx)

		return
	end

	local monster = stage.monsters[1]

	if not monster then
		Infogvg:Error("portal見つかりませんmonster！step：" .. self.step .. " portalIdx:" .. self.portalIdx)

		return
	end

	local hp, maxhp = stage:GetMonsterHp()
	local progress = 1 - hp / maxhp

	UIUtil.SetTextString(self.txt_progress, math.ceil(progress * 100) .. "%")

	self.img_fill.fillAmount = progress
end

function mt:Step3()
	local maxPortal = 4
	local notcompletedPortal = maxPortal
	local curPortalIdx = 0
	local stage

	for i, s in Infogvg.stage:Filter():IsStep(3):Ipairs() do
		if s:IsComplete() == false and curPortalIdx ~= s.portalIdx then
			curPortalIdx = s.portalIdx
			notcompletedPortal = notcompletedPortal - 1
		end
	end

	local cur = notcompletedPortal
	local max = maxPortal

	UIUtil.SetTextString(self.txt_progress, cur .. "/" .. max)

	self.img_fill.fillAmount = cur / max
end

function mt:RefreshUI()
	local step = self.curStep
	local isLocked = step > Infogvg.stage.curStep
	local isCompleted = step < Infogvg.stage.curStep

	GOUtil.SetActive(self.obj_mask_unlock, isLocked)
	GOUtil.SetActive(self.obj_mask_pass, isCompleted)

	if isLocked or isCompleted then
		GOUtil.SetActive(self.obj_masktitle, true)
	else
		GOUtil.SetActive(self.obj_masktitle, false)
	end

	GOUtil.SetActive(self.obj_completed, isCompleted)
	GOUtil.SetActive(self.btn_rewardview, not isLocked)
	GOUtil.SetActive(self.btn_score, not isLocked)

	self.img_left.enabled = self.curStep ~= 1
	self.img_right.enabled = self.curStep ~= 3

	for i = 1, 3 do
		if i == step then
			self.imgs_dot[i].color = getColorFromString(_color_img_cur)
			self.txts_dot[i].color = getColorFromString(_color_txt_cur)

			if isLocked or isCompleted then
				GOUtil.SetActive(self.obj_effects[i], false)
			else
				GOUtil.SetActive(self.obj_effects[i], true)
			end
		else
			self.imgs_dot[i].color = getColorFromString(_color_img)
			self.txts_dot[i].color = getColorFromString(_color_txt)
		end

		GOUtil.SetActive(self.largebks[i], i == step)
		GOUtil.SetActive(self.stepbks[i], i == step)
	end

	local cfg = {
		"Desc_GVG_tips_phase1",
		"Desc_GVG_tips_phase2",
		"Desc_GVG_tips_phase3"
	}
	local lan = cfg[step]

	lan = lan or "Desc_GVG_tips_phase" .. step

	UIUtil.SetTextString(self.txt_condition, _(lan))

	local title = string.format(_("Desc_GVG_tips_phase_title"), step)
	local name = ""

	for i, stage in Infogvg.stage:Filter():IsStep(step):Ipairs() do
		local infochapter = ChapterMgr:GetChapter(stage.chapterId)

		name = Lang(infochapter.data.Name)

		break
	end

	UIUtil.SetTextString(self.txt_step, title .. name)
end

return mt
