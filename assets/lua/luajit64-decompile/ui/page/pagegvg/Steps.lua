-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGvg/Steps.lua

local _LIGHT = 0.35
local tempcfg = require("UI/Page/PageGvg/Monster3dRenderCfg")
local renderCfg = tempcfg.Steps
local mt = class("DlgGvg_Steps", UIItemBase)

function mt:Init(obj)
	mt.base.base.ctor(self)

	self.UIRootObject = obj

	self:OnEnter()
	self:OnRegisterEvent()
end

function mt:Purge()
	self:OnUnRegisterEvent()
	self:ResetPortals()
	self.render3d:Purge()

	for i, handle in ipairs(self.reliveHandles) do
		TimerMgr.RemoveTimer(handle)
	end

	self.reliveHandles = {}
end

function mt:OnRegisterEvent()
	Event.Instance:Add("OnLoaded_Monster3dRender", self.OnModelLoad, self)
	Event.Instance:Add("UI_DlgGvgCombatReadiness", self.OnUICompatReadinessOpen, self)
	Event.Instance:Add("EVENT_GVG_REWARD_STEP", self.OnPortalReborn, self)
	Event.Instance:Add("EVENT_GVG_SELECT_PORTAL", self.OnSelectPortal, self)
end

function mt:OnUnRegisterEvent()
	Event.Instance:Remove("OnLoaded_Monster3dRender", self.OnModelLoad, self)
	Event.Instance:Remove("UI_DlgGvgCombatReadiness", self.OnUICompatReadinessOpen, self)
	Event.Instance:Remove("EVENT_GVG_REWARD_STEP", self.OnPortalReborn, self)
	Event.Instance:Remove("EVENT_GVG_SELECT_PORTAL", self.OnSelectPortal, self)
end

function mt:OnEnter()
	self.list = {}
	self.rawimg_UI3dRender = self:GetChildComponent("UI3dRender", "RawImage")
	self.rawimg_UI3dRender.enabled = false
	self.render3d = require("UI/Page/PageGvg/Monster3dRender")

	self.render3d:Init(self.rawimg_UI3dRender.gameObject)

	local v = renderCfg.cameraPos

	self.render3d:SetCameraPosition(v[1], v[2], v[3])

	v = renderCfg.cameraRot

	self.render3d:SetCameraRotation(v[1], v[2], v[3])

	self.monsterIds = {}

	local o1 = self:GetChildGameObject("steps/panel")
	local o2 = self:GetChildGameObject("steps/panel_2")
	local o3 = self:GetChildGameObject("steps/panel_3")

	self.panels = {
		o1,
		o2,
		o3
	}
	self.reliveHandles = {}
end

function mt:Refresh(step)
	self.step = step

	if step == 1 then
		self.rawimg_UI3dRender.enabled = false
	end

	for i, obj in ipairs(self.panels) do
		GOUtil.SetActive(obj, step == i)
	end

	self:CreatePortals()
end

function mt:ResetPortals()
	for i = #self.list, 1, -1 do
		local item = table.remove(self.list, i)

		item:Purge()

		item = nil
	end
end

function mt:CreatePortals()
	self:ResetPortals()

	local step = self.step
	local monsterIds = {}
	local tempPortal = {}
	local root = GOUtil.FindChildGameObject(self.panels[1], "stages").transform

	self.monsterIds = {}

	for i, stage in Infogvg.stage:Filter():IsStep(step):Ipairs() do
		if not tempPortal[stage.portalIdx] then
			tempPortal[stage.portalIdx] = true

			local item

			if step == 1 then
				local portal = require("UI/Page/PageGvg/Portal")

				item = portal()

				local t = root:GetChild(i - 1):GetChild(0).gameObject

				item:Init(t)
			else
				local portal = require("UI/Page/PageGvg/Portal3D")

				item = portal()

				local root = GOUtil.FindChildGameObject(self.panels[step], "stages").transform
				local t = root:GetChild(i - 1):GetChild(0).gameObject

				item:Init(t)
			end

			item:Refresh(step, stage.portalIdx)
			table.insert(self.list, item)

			local monster = stage.monsters[1]

			table.insert(self.monsterIds, monster.monsterId)
		end
	end

	Infogvg:Table(self.monsterIds)

	if self.step == 1 then
		self.render3d:PurgeModel()
	else
		self.render3d:LoadMonsters(self.monsterIds)
	end
end

function mt:OnPortalReborn()
	local step, portalIdxs = Infogvg.persistent.animPortalStep, Infogvg.persistent.animPortalIdxs

	if #portalIdxs == 0 then
		return
	end

	if step ~= self.step then
		return
	end

	local temp = {}

	for i, idx in ipairs(portalIdxs) do
		temp[idx] = true
	end

	for i, portal in Infogvg.portal:Filter():IsStep(self.step):Ipairs() do
		if temp[portal.portalIdx] then
			local model = self.render3d:GetModel(portal.portalIdx)
			local model_ui = self.list[portal.portalIdx]

			if model and model_ui and portal:Stage() then
				local delay = 1
				local handle = TimerMgr.AddTimer(eTimerType.ScaleTime, delay, function()
					local reliveTime = model_ui:Relive()
					local handle2 = TimerMgr.AddTimer(eTimerType.ScaleTime, reliveTime, function()
						model:SetLightRadiance(1)
						model:Resume()
						EffectMgr:Alloc("Fx/UI/FX_UI_DlgGvg/FX_FillRestore02", model_ui.UIRootObject, true, reliveTime)
					end, {})

					table.insert(self.reliveHandles, handle2)
				end, {})

				table.insert(self.reliveHandles, handle)
			end
		end
	end
end

function mt:OnModelLoad(model, portalIdx)
	if self.uiCompatReadinessOpen then
		return
	end

	if self.step == 1 then
		return
	end

	local model_ui = self.list[portalIdx]

	if not model_ui then
		return
	end

	self.rawimg_UI3dRender.enabled = true

	local pos = renderCfg:ModelPos(self.monsterIds[portalIdx], portalIdx)

	model:SetLocalPos(pos[1], pos[2], pos[3])

	local rot = renderCfg:ModelRot(self.monsterIds[portalIdx], portalIdx)

	model:SetLocalRot(rot[1], rot[2], rot[3])

	local scale = renderCfg:ModelScale(self.monsterIds[portalIdx], portalIdx)

	model:SetLocalScale(scale)

	local stages = Infogvg.portal:Stages(self.step, portalIdx)
	local stage = stages[1]

	for i, s in ipairs(stages) do
		if s:IsComplete() == false and s:IsLock() == false then
			stage = s

			break
		end
	end

	if stage:IsLock() then
		model:SetLightRadiance(_LIGHT)
	elseif stage:IsComplete() or stage:IsPass() then
		model:SetLightRadiance(_LIGHT)
		model:Pause()
	else
		local setDead = false

		if self.step == Infogvg.persistent.animPortalStep then
			for _, deadIdx in ipairs(Infogvg.persistent.animPortalIdxs) do
				if deadIdx == portalIdx then
					setDead = true

					break
				end
			end
		end

		if setDead then
			model:SetLightRadiance(_LIGHT)
			model:Pause()
			model_ui:Dead()
		else
			local cfg = Infogvg.cfg:MaxPortal()
			local maxPortal = cfg[self.step]

			if portalIdx == maxPortal then
				model:AllocFx("Fx/UI/FX_UI_DlgGvg/FX_DlgGvg_Boss", -1)
			end
		end
	end
end

function mt:RenderMonster()
	self.render3d:Init(self.rawimg_UI3dRender.gameObject)

	local v = renderCfg.cameraPos

	self.render3d:SetCameraPosition(v[1], v[2], v[3])

	v = renderCfg.cameraRot

	self.render3d:SetCameraRotation(v[1], v[2], v[3])

	if self.step ~= 1 and #self.monsterIds > 1 then
		self.render3d:LoadMonsters(self.monsterIds)
	end
end

function mt:OnUICompatReadinessOpen(val)
	if val == true then
		for i, handle in ipairs(self.reliveHandles) do
			TimerMgr.RemoveTimer(handle)
		end

		self.reliveHandles = {}
		self.uiCompatReadinessOpen = true
		self.rawimg_UI3dRender.enabled = false
	else
		self.uiCompatReadinessOpen = nil
		self.rawimg_UI3dRender.enabled = true

		self:RenderMonster()
	end
end

function mt:OnSelectPortal(stepIdx, portalIdx)
	if not Infogvg:IsPlayOpen() then
		UIMgr.ShowMsg(_("Msg_Active_Over"))

		return
	end

	Infogvg:Log("click portal " .. stepIdx .. "-" .. portalIdx)

	for i, stage in Infogvg.stage:Filter():IsStep(stepIdx):IsPortal(portalIdx):Ipairs() do
		local function _logFun()
			local str = "クエスト情報-->>> ："

			str = str .. " stage:" .. tostring(stage.stageId)
			str = str .. " progress:" .. tostring(stage.progress)

			local hp, maxhp = stage:GetMonsterHp()

			str = str .. " hp:" .. hp .. " / " .. maxhp
			str = str .. " bloodCost:" .. Infogvg:JsonStr(stage.bloodCost)
			str = str .. " maxbloodCost:" .. Infogvg:JsonStr(stage.maxbloodCost)

			Infogvg:Log(str)
		end

		_logFun()
	end

	if not Infogvg:CheckPortal(stepIdx, portalIdx) then
		Infogvg:Error("portal:OnClick() , " .. stepIdx .. "-" .. portalIdx)

		return
	end

	local targetStage
	local stages = Infogvg.portal:Stages(stepIdx, portalIdx)

	for i, stage in ipairs(stages) do
		targetStage = stage

		if stage:IsComplete() == false and stage:IsLock() == false then
			Infogvg.stage:SelectStage(stage.uid)
			UIMgr.AddPanel(DlgGvgCombatReadiness())

			break
		end
	end

	if targetStage:IsPass() == true then
		UIMgr.ShowMsg(_("Desc_GVG_pass"))

		return
	end

	if targetStage:IsLock() == true then
		UIMgr.ShowMsg(_("Desc_GVG_lock"))

		return
	end

	if targetStage:IsComplete() == true then
		UIMgr.ShowMsg(_("Desc_GVG_complete"))

		return
	end
end

return mt
