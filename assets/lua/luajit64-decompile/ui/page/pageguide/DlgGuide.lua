-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGuide/DlgGuide.lua

DlgGuide = class("DlgGuide", UIPanel)

function DlgGuide:ctor()
	self.UIPrefabPath = "UI/PageGuide/DlgGuide"
	self.callbackClick = nil
	self.callbackClickFight = nil
	self.fobidenClick = false
end

function DlgGuide:PreLoad()
	return
end

function DlgGuide:Purge()
	DlgGuide.base.Purge(self)
end

function DlgGuide:OnRegisterEvent()
	local spath = "Play_SE_020_0030"

	self:AddClick(self.ButtonSkip, self.OnButtonSkip, spath)
	self:AddClick(self.GoLight, self.OnButtonClick, spath)
	self:AddClick(self.GoOpaqueMask, self.OnButtonClickBg, spath)
	self:AddClick(self.GoDialog, self.OnButtonClickDialog, spath)
	self:AddClick(self.GoDialog2, self.OnButtonClickDialog, spath)
	self:AddListener(self.GoLight, self.OnPointerLongPress, EventTriggerType.PointerLongPress)
end

function DlgGuide:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonSkip, self.OnButtonSkip)
	self:RemoveClick(self.GoLight, self.OnButtonClick)
	self:RemoveClick(self.GoOpaqueMask, self.OnButtonClickBg)
	self:RemoveClick(self.GoDialog, self.OnButtonClickDialog)
	self:RemoveClick(self.GoDialog2, self.OnButtonClickDialog)
	self:RemoveListener(self.GoLight, self.OnPointerLongPress, EventTriggerType.PointerLongPress)
end

function DlgGuide:SetClickDown(enable)
	if enable then
		self:AddListener(self.GoLight, self.OnButtonClickDown, EventTriggerType.PointerDown)
	else
		self:RemoveListener(self.GoLight, self.OnButtonClickDown, EventTriggerType.PointerDown)
	end
end

function DlgGuide:OnEnter(vParam)
	self.UIRootObject:SetActive(false)

	self.GoMask = self:GetChildGameObject("GoMask")
	self.GoMaskRect = self.GoMask
	self.GoLight = self:GetChildGameObject("GoLight")
	self.GoArrow = self:GetChildGameObject("GoLight/Image")
	self.GoPressEff = self:GetChildGameObject("GoLight/FX_UI_NewTarget_Start")
	self.GoGuideEff = self:GetChildGameObject("GoLight/FX_UI_NewTarget_Loop")
	self.GoDialog = self:GetChildGameObject("GoDialog")
	self.Dialog = self:GetChildGameObject("GoDialog/Dialog")
	self.TextDialog = self:GetChildComponent("GoDialog/Dialog/Text", "TextView")
	self.GoDialog2 = self:GetChildGameObject("GoDialog2")
	self.Dialog2 = self:GetChildGameObject("GoDialog2/Dialog")
	self.TextDialog2 = self:GetChildComponent("GoDialog2/Dialog/Text", "TextView")
	self.ButtonSkip = self:GetChildGameObject("Button")
	self.Background = self:GetChildGameObject("Background")
	self.GoOpaqueMask = self:GetChildGameObject("GoOpaqueMask")
	self.GoVideoBG = self:GetChildGameObject("VideoBG")
	self.ClickArea1 = self:GetChildGameObject("GoDialog/ClickArea")
	self.ClickArea2 = self:GetChildGameObject("GoDialog2/ClickArea")

	self.GoMask:SetActive(false)
	self.GoMaskRect:SetActive(false)
	self.GoLight:SetActive(false)
	self.GoArrow:SetActive(false)
	self.GoPressEff:SetActive(false)
	self.GoDialog:SetActive(false)
	self.GoDialog2:SetActive(false)
	self.ButtonSkip:SetActive(false)
	self.Background:SetActive(false)
	self.GoOpaqueMask:SetActive(false)
	self.GoVideoBG:SetActive(false)
end

function DlgGuide:ShowActive()
	self.UIRootObject:SetActive(true)

	if InstructionMgr.isGuideCall then
		return
	end

	local g = GameObject.Find("DlgCallIn(Clone)")

	if g then
		g:SetActive(false)
	end
end

function DlgGuide:PlayVideo()
	self:ShowActive()
	self.GoVideoBG:SetActive(true)

	self.VideoPlayer = self:GetChildComponent("VideoBG/1", "VideoPlayer")

	UIUtil.SetVideoPlayerClip(self.VideoPlayer, "Videos/Opening/LiveGuideVideo")

	local function fAni()
		coroutine.wait(0.1)

		local v1 = self:GetChildComponent("VideoBG/1", "VideoPlayer")
		local t1 = tonumber(v1.clip.length)

		coroutine.wait(t1)
		self.GoVideoBG:SetActive(false)

		if self.callbackClick then
			self.callbackClick()
		end
	end

	coroutine.start(fAni)
end

function DlgGuide:HideMask()
	FingerGesturesUtil.Enable()
	self.UIRootObject:SetActive(false)
	self.GoMask:SetActive(false)
	self.GoLight:SetActive(false)
	self.GoPressEff:SetActive(false)
	self.GoMaskRect:SetActive(false)
end

function DlgGuide:ShowMask(value, target, page, OffsetX, OffsetY, OffsetW, OffsetH, IsOriginSize, hideLight)
	self:ShowActive()
	self.Background:SetActive(false)
	self.GoMask:SetActive(false)
	self.GoLight:SetActive(false)
	self.GoPressEff:SetActive(false)
	self.GoMaskRect:SetActive(false)
	self.UIRootObject:SetActive(true)
	FingerGesturesUtil.Disable()

	local offx, offy, offw, offh = 0, 0, 0, 0

	if OffsetX then
		offx = OffsetX
	end

	if OffsetY then
		offy = OffsetY
	end

	if OffsetW then
		offw = OffsetW
	end

	if OffsetH then
		offh = OffsetH
	end

	local w, h = 0, 0

	self.Background:SetActive(true)
	self.GoMask:SetActive(true)
	self.GoPressEff:SetActive(true)
	self.GoLight:SetActive(true)

	if value == "Full" then
		self.GoMask:SetActive(false)
		self.GoPressEff:SetActive(false)
		self.GoLight:SetActive(false)
		self.GoArrow:SetActive(false)
	elseif value == "Target" then
		local gPage

		if page then
			if UIMgr.GetPanel(page) then
				gPage = UIMgr.GetPanel(page).UIRootObject
			else
				local p = UIMgr.GetCurPanel()

				if p == nil or p:GetChildPanel(page) == nil then
					return
				end

				gPage = p:GetChildPanel(page).UIRootObject
			end
		else
			gPage = UIMgr.GetCurPanel().UIRootObject
		end

		if gPage == nil then
			return
		end

		local g = GOUtil.FindChildGameObject(gPage, target)

		if g == nil then
			return false
		end

		self.gTarget = g
		self.GoLight.transform.position = g.transform.position
		self.GoMask.transform.position = g.transform.position

		if OffsetX or OffsetY then
			local rt = GOUtil.GetComponent(self.GoMask, "RectTransform")
			local ap = rt.anchoredPosition

			GOUtil.SetRectTransformAnchoredPosition(self.GoMask, ap.x + offx, ap.y + offy)
			GOUtil.SetRectTransformAnchoredPosition(self.GoLight, ap.x + offx, ap.y + offy)
		end

		w = GOUtil.GetRectTransformSizeDeltaWidth(g)
		h = GOUtil.GetRectTransformSizeDeltaHeight(g)
	elseif value == "Rect" then
		self.GoMask:SetActive(false)
		self.GoMaskRect:SetActive(true)
		self.GoLight:SetActive(false)

		if target then
			local g = GOUtil.FindChildGameObject(UIMgr.GetCurPanel().UIRootObject, target)

			w = GOUtil.GetRectTransformSizeDeltaWidth(g)
			h = GOUtil.GetRectTransformSizeDeltaHeight(g)

			GOUtil.SetRectTransformSizeDelta(self.GoMaskRect, w + offw, h + offh)

			self.gTarget = g
			self.GoLight.transform.position = self.gTarget.transform.position

			self.GoArrow:SetActive(false)
		end
	elseif value == "RectGlobal" then
		self.GoArrow:SetActive(false)
		self.GoMaskRect:SetActive(true)

		local g = GOUtil.FindGameObjectByName(target, UIMgr.UIRootObject)

		if g == nil then
			return false
		end

		w = GOUtil.GetRectTransformSizeDeltaWidth(g)
		h = GOUtil.GetRectTransformSizeDeltaHeight(g)

		GOUtil.SetRectTransformSizeDelta(self.GoMaskRect, w + offw, h + offh)

		self.GoMaskRect.transform.position = g.transform.position

		if OffsetX or OffsetY then
			local rt = GOUtil.GetComponent(self.GoMaskRect, "RectTransform")
			local ap = rt.anchoredPosition

			GOUtil.SetRectTransformAnchoredPosition(self.GoMaskRect, ap.x + offx, ap.y + offy)
		end

		self.GoLight.transform.position = self.GoMaskRect.transform.position
	elseif value == "TargetGlobal" then
		local list = string.split(target, "/")
		local s1 = list[1]
		local g = GOUtil.FindGameObjectByName(s1, UIMgr.UIRootObject)

		if #list > 1 then
			g = GOUtil.FindChildGameObject(g, list[2])
		end

		g = GameObject.Find(target)

		if g == nil then
			return false
		end

		self.gTarget = g
		self.GoLight.transform.position = g.transform.position
		self.GoMask.transform.position = g.transform.position

		local rt = GOUtil.GetComponent(self.GoMask, "RectTransform")
		local ap = rt.anchoredPosition

		GOUtil.SetRectTransformAnchoredPosition(self.GoLight, ap.x + offx, ap.y + offy)
		GOUtil.SetRectTransformAnchoredPosition(self.GoMask, ap.x + offx, ap.y + offy)

		w = GOUtil.GetRectTransformSizeDeltaWidth(self.GoMask)
		h = GOUtil.GetRectTransformSizeDeltaHeight(self.GoMask)
	elseif value == "TargetMonster" then
		local monsterId = tonumber(target)

		print("mid:" .. monsterId)

		local pos = GamePerform.GetUnitTransform(GP, monsterId)
		local pv = Vector3(pos.x + offx, pos.y + offy, pos.z)

		self.GoLight.transform.localPosition = pv
		self.GoMask.transform.localPosition = pv
		w = GOUtil.GetRectTransformSizeDeltaWidth(self.GoMask)
		h = GOUtil.GetRectTransformSizeDeltaHeight(self.GoMask)

		function self.callbackClickFight()
			GP:ReqSelectTarget(tonumber(monsterId))
		end
	end

	if value ~= "Rect" then
		GOUtil.SetRectTransformSizeDelta(self.GoMask, w + offw, h + offh)
		GOUtil.SetRectTransformSizeDelta(self.GoLight, w + offw, h + offh)

		local w2 = (w + offw) / 100 - 0.2
		local h2 = (h + offh) / 100 - 0.2

		GOUtil.SetTransformLocalScale(self.GoGuideEff, w2, h2, 1)
		GOUtil.SetTransformLocalScale(self.GoPressEff, w2, h2, 1)
	end

	if hideLight then
		self.GoLight:SetActive(false)
	end

	return true
end

function DlgGuide:ShowOpaqueMask()
	UIMgr.DlgGuide.GoOpaqueMask:SetActive(true)
	FingerGesturesUtil.Disable()
end

function DlgGuide:HideOpaqueMask()
	UIMgr.DlgGuide.GoOpaqueMask:SetActive(false)
	FingerGesturesUtil.Enable()
	self.UIRootObject:SetActive(false)
end

function DlgGuide:OnButtonClickBg(eventData)
	return
end

function DlgGuide:OnButtonSkip(eventData)
	return
end

function DlgGuide:OnButtonClick(eventData)
	if self.isKeepTalk then
		return
	end

	if self.callbackClickFight then
		self.callbackClickFight()

		self.callbackClickFight = nil

		if self.callbackClick then
			self.callbackClick()
		end

		return
	end

	if self.fobidenClick then
		return
	end

	local g = self.gTarget

	if not g then
		return
	end

	eventData.pointerPress = g

	EventListenerManager.ExecuteEvents(g, eventData, EventTriggerType.PointerClick)

	if self.callbackClick then
		self.callbackClick()
	end
end

function DlgGuide:OnButtonClickDown(eventData)
	if self.isKeepTalk then
		return
	end

	local g = self.gTarget

	if not g then
		return
	end

	eventData.pointerPress = g
	eventData.pointerPressRaycast.gameObject = g

	EventListenerManager.ExecuteEvents(g, eventData, EventTriggerType.PointerDown)

	if self.callbackClick then
		self.callbackClick()
	end
end

function DlgGuide:OnPointerLongPress(eventData)
	if not self.isKeepTalk then
		return
	end

	local g = self.gTarget

	if not g then
		return
	end

	if eventData.clickCount ~= 1 then
		return
	end

	eventData.clickCount = 1
	eventData.pointerPress = g

	EventListenerManager.ExecuteEvents(g, eventData, EventTriggerType.PointerLongPress)
end

function DlgGuide:SetTalkKeep(isKeep)
	self.isKeepTalk = isKeep

	if isKeep then
		-- block empty
	else
		self.GoDialog:SetActive(false)
		self.GoDialog2:SetActive(false)
	end

	self.ClickArea1:SetActive(not isKeep)
	self.ClickArea2:SetActive(not isKeep)
end

function DlgGuide:ShowTalk(Value, Target, OffsetX, OffsetY)
	self:ShowActive()
	self.GoDialog:SetActive(true)
	self.GoDialog2:SetActive(false)

	if Target then
		local g = GOUtil.FindChildGameObject(UIMgr.GetCurPanel().UIRootObject, Target)

		self.Dialog.transform.position = g.transform.position

		local rt = GOUtil.GetComponent(self.Dialog, "RectTransform")
		local ap = rt.anchoredPosition

		GOUtil.SetRectTransformOffsetType(self.Dialog, 0, ap.x + OffsetX, ap.y + OffsetY)
	else
		GOUtil.SetRectTransformOffsetType(self.Dialog, 0, 0, 0)
	end

	local str = Lang(tonumber(Value))

	self.strDialog = str

	local listStr = StringToTable(str)
	local maxNum = #listStr

	self.dialogShowed = false

	TimerMgr.RemoveTimer(self.timerDialog)

	self.TextDialog.Text = ModifyRichTextForTextView(str)
	self.TextDialog.VisibleLength = 0

	local i = 1

	self.timerDialog = TimerMgr.AddTimer(eTimerType.RealTime, 0.1, function()
		if i > maxNum then
			self.dialogShowed = true

			TimerMgr.RemoveTimer(self.timerDialog)

			return
		end

		self.TextDialog.VisibleLength = i

		self.TextDialog:UpdateText()

		i = i + 1
	end, {}, -1)
end

function DlgGuide:OnButtonClickDialog()
	if self.isKeepTalk then
		return
	end

	if not self.dialogShowed then
		TimerMgr.RemoveTimer(self.timerDialog)

		self.dialogShowed = true
		self.TextDialog.VisibleLength = -1
		self.TextDialog2.VisibleLength = -1

		if self.strDialog then
			self.TextDialog:UpdateText()
		end

		if self.strDialog2 then
			self.TextDialog2:UpdateText()
		end
	else
		self.GoDialog:SetActive(false)
		self.GoDialog2:SetActive(false)

		if self.callbackClick then
			self.callbackClick()
		end
	end
end

function DlgGuide:ShowFullTalk(Value)
	self:ShowActive()
	self.GoDialog2:SetActive(true)
	self.GoDialog:SetActive(false)

	local str = Lang(tonumber(Value))

	self.strDialog2 = str

	local listStr = StringToTable(str)
	local maxNum = #listStr

	self.dialogShowed = false

	TimerMgr.RemoveTimer(self.timerDialog)

	self.TextDialog2.Text = ModifyRichTextForTextView(str)
	self.TextDialog2.VisibleLength = 0

	local i = 1

	self.timerDialog = TimerMgr.AddTimer(eTimerType.RealTime, 0.1, function()
		if i > maxNum then
			self.dialogShowed = true

			TimerMgr.RemoveTimer(self.timerDialog)

			return
		end

		self.TextDialog2.VisibleLength = i

		self.TextDialog2:UpdateText()

		i = i + 1
	end, {}, -1)
end

function DlgGuide:OnBackAndroid()
	if GOUtil.IsActiveSelf(self.GoDialog) or GOUtil.IsActiveSelf(self.GoDialog2) then
		self:OnButtonClickDialog()

		return
	end
end
