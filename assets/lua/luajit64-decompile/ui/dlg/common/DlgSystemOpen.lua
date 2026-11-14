-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgSystemOpen.lua

DlgSystemOpen = class("DlgSystemOpen", UIPanel)

function DlgSystemOpen:ctor()
	self.UIPrefabPath = "UI/Common/DlgSystemOpen/DlgSystemOpen"
	self.callback = nil
	self.page = nil
end

function DlgSystemOpen:PreLoad()
	self:LoadResAsync("Fx/UI/Eff_UI_DlgSystemOpen/FX_UI_DlgSystemOpen_Fly", "PrefabFlyEff")
end

function DlgSystemOpen:Purge()
	self.base.Purge(self)
	UnloadAllImageSprite(self)
	ResourceMgr.Unload(self.PrefabFlyEff)

	if self.Timer1 then
		TimerMgr.RemoveTimer(self.Timer1)

		self.Timer1 = nil
	end

	if self.Timer2 then
		TimerMgr.RemoveTimer(self.Timer2)

		self.Timer2 = nil
	end

	if self.timerMask then
		TimerMgr.RemoveTimer(self.timerMask)

		self.timerMask = nil
	end

	self.page = nil

	EffectMgr:UnLoadEffect("Fx/UI/Eff_UI_DlgSystemOpen/FX_UI_DlgSystemOpen_Start")
	EffectMgr:UnLoadEffect("Fx/UI/Eff_UI_DlgSystemOpen/FX_UI_DlgSystemOpen_End")
	FingerGesturesUtil.Enable()
end

function DlgSystemOpen:OnRegisterEvent()
	self:AddClick(self.Bg, self.OnClickedClose)
end

function DlgSystemOpen:OnUnRegisterEvent()
	self:RemoveClick(self.Bg, self.OnClickedClose)
end

function DlgSystemOpen:OnEnter(vParam)
	FingerGesturesUtil.Disable()

	self.Bg = self:GetChildGameObject("Bg")
	self.BgImage = GOUtil.GetComponent(self.Bg, "Image")
	self.BgImage.raycastTarget = false
	self.timerMask = TimerMgr.AddTimer(eTimerType.RealTime, 1, function()
		self.BgImage.raycastTarget = true

		TimerMgr.RemoveTimer(self.timerMask)

		self.timerMask = nil
	end, nil)
	self.GoPanel = self:GetChildGameObject("Panel")
	self.GoAntiTouch = self:GetChildGameObject("AntiTouch")

	self.GoAntiTouch:SetActive(false)

	self.GoEffPoint = self:GetChildGameObject("EffPoint")
	self.Icon = self:GetChildComponent("Panel/System/Icon", "Image")
	self.TxtName = self:GetChildComponent("Panel/System/Name", "Text")
	self.TxtDesc = self:GetChildComponent("Panel/Prompt/Text", "Text")

	if not vParam then
		return
	end

	if vParam.list then
		self.list = vParam.list
	end

	if vParam.panel then
		self.page = vParam.panel
	end

	if self.list ~= nil then
		local infoSystem = self.list[1]

		self.id = infoSystem.data.Function

		UIUtil.SetImageSprite(self.Icon, infoSystem.data.Icon, self, true)

		self.TxtName.text = Lang(infoSystem.data.Name)
		self.TxtDesc.text = Lang(infoSystem.data.Info)
		self.UnlockFunction = infoSystem.data.Function

		local isHave = false

		for k, v in pairs(systemType1) do
			if v == infoSystem.data.Function then
				self.GoSystem = self.page["BtnFirstSystem" .. k]
				isHave = true

				break
			end
		end

		if not isHave then
			for k, v in pairs(systemType2) do
				if v == infoSystem.data.Function then
					self.GoSystem = self.page["BtnSecondSystem" .. k]

					break
				end
			end
		end

		if not self.GoSystem then
			local funId = infoSystem.data.Function

			if funId == 5 or funId == 8 or funId == 11 then
				if funId == 5 then
					PersistentStoreUtil.SetBool("DressDot", true)
				end

				if funId == 8 then
					PersistentStoreUtil.SetBool("TalentDot", true)
				end

				if funId == 11 then
					PersistentStoreUtil.SetBool("EquipDot", true)
				end

				self.GoSystem = self.page.BtnFirstSystem2
			elseif funId == 13 or funId == 24 or funId == 34 or funId == 36 or funId == 37 then
				if funId == 13 then
					PersistentStoreUtil.SetBool("AssetDot", true)
				end

				if funId == 24 then
					PersistentStoreUtil.SetBool("BossDot", true)
				end

				if funId == 34 then
					PersistentStoreUtil.SetBool("TowerDot", true)
				end

				if funId == 36 then
					PersistentStoreUtil.SetBool("DeffDot", true)
				end

				if funId == 37 then
					PersistentStoreUtil.SetBool("BossLiveDot", true)
				end

				self.GoSystem = self.page.BtnFirstSystem7
			end
		end

		table.remove(self.list, 1)
	end

	if self.list and #self.list > 0 then
		function self.callback()
			local data = {
				list = self.list,
				panel = self.page
			}

			UIMgr.AddPanel(DlgSystemOpen(), data)
		end
	end

	if InstructionMgr.isGuideCall then
		return
	end

	local g = GameObject.Find("DlgCallIn(Clone)")

	if g then
		g:SetActive(false)
	end
end

function DlgSystemOpen:DealWithClose()
	if self.callback then
		self.callback()

		self.callback = nil
	end

	self:Close()
	Event.Instance:Fire("UpdateAboutDot")

	local sId = "0"

	if self.id then
		sId = self.id
	end

	InstructionMgr:TriggerWait("SystemOpen" .. sId)
end

function DlgSystemOpen:OnClickedClose()
	if not self.GoSystem then
		self:DealWithClose()

		return
	end

	self.Bg:SetActive(false)
	self.GoPanel:SetActive(false)
	self.GoAntiTouch:SetActive(true)
	EffectMgr:Alloc("Fx/UI/Eff_UI_DlgSystemOpen/FX_UI_DlgSystemOpen_Start", self.UIRootObject, true, 1)

	self.Timer1 = TimerMgr.AddTimer(eTimerType.ScaleTime, 0.5, function()
		if IsNil(self.UIRootObject) then
			return
		end

		if IsNil(self.PrefabFlyEff) then
			return
		end

		local eff = GOUtil.InstantiatePrefab(self.PrefabFlyEff, self.UIRootObject)

		if IsNil(self.GoSystem) then
			return
		end

		local x, y, z = GOUtil.GetTransformPosition(self.GoSystem, x, y, z)

		if IsNil(self.GoEffPoint) then
			return
		end

		GOUtil.SetTransformPosition(self.GoEffPoint, x, y, z)

		self.tweener = eff.transform:DOMove(Vector3(x, y, z), 0.3)

		GOUtil.SetTweenerCallback(self.tweener, function()
			self.Timer2 = TimerMgr.AddTimer(eTimerType.ScaleTime, 0.15, function()
				Object.Destroy(eff)
				EffectMgr:Alloc("Fx/UI/Eff_UI_DlgSystemOpen/FX_UI_DlgSystemOpen_End", self.GoEffPoint, true, 1)
				self:DealWithClose()
				self.tweener:Kill()

				if self.id then
					SystemOpenMgr.DealSystemOpen(self.id)
				end
			end, nil)
		end)
	end, nil)
end
