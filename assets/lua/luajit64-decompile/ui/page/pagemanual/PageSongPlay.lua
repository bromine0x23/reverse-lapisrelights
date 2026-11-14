-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageManual/PageSongPlay.lua

local videoData = require("luaData/VideoData")

PageSongPlay = class("PageSongPlay", UIPanel)

function PageSongPlay:ctor()
	self.UIPrefabPath = "UI/PageManual/PageSongPlay"

	self:AddChildPanel(DlgExit(), {
		title = _("Desc_Story"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo(), {
		x = -600,
		y = -42
	})
end

function PageSongPlay:PreLoad()
	return
end

function PageSongPlay:OnBack()
	UIMgr.PopPanel(self.data)
end

function PageSongPlay:Purge()
	self.base.Purge(self)
	InfoBGMEventMgr:ReplayBGM()
	SoundMgr.UnloadBank(self.data.Bank)

	if self.Sequence then
		DG.Tweening.DOTween.Kill("Sequence", false)

		self.Sequence = nil
	end
end

function PageSongPlay:OnRegisterEvent()
	self:AddClick(self.Stop, self.OnClickPause)
	self:AddClick(self.Next, self.OnClickNext)
	self:AddClick(self.Last, self.OnClickLast)
	self:AddClick(self.Play, self.OnClickPlay)
	self:AddListener(self.DrawImage, self.OnDrag, EventTriggerType.Drag)
	self:AddListener(self.DrawImage, self.OnPointerDown, EventTriggerType.PointerDown)
	self:AddListener(self.DrawImage, self.OnPointerUp, EventTriggerType.PointerUp)
end

function PageSongPlay:OnUnRegisterEvent()
	self:RemoveClick(self.Stop, self.OnClickPause)
	self:RemoveClick(self.Next, self.OnClickNext)
	self:RemoveClick(self.Last, self.OnClickLast)
	self:RemoveClick(self.Play, self.OnClickPlay)
	self:RemoveListener(self.DrawImage, self.OnDrag, EventTriggerType.Drag)
	self:RemoveListener(self.DrawImage, self.OnPointerDown, EventTriggerType.PointerDown)
	self:RemoveListener(self.DrawImage, self.OnPointerUp, EventTriggerType.PointerUp)
end

function PageSongPlay:OnEnter(vParam)
	InfoBGMEventMgr:StopBGM()

	self.data = vParam.data

	self:DealWithLocalization()

	self.Stop = self:GetChildGameObject("Panel/Stop")
	self.Next = self:GetChildGameObject("Panel/Next")
	self.Last = self:GetChildGameObject("Panel/Last")
	self.Play = self:GetChildGameObject("Panel/Play")
	self.DiscImage = self:GetChildComponent("Panel/Disc/DiscImage", "Image")
	self.Name = self:GetChildComponent("Panel/Name", "Text")
	self.Slider = self:GetChildComponent("Panel/ShowSlider", "Slider")
	self.Time = self:GetChildComponent("Panel/Time", "Text")
	self.Content = self:GetChildGameObject("Panel/Words/Content")
	self.Text = self:GetChildGameObject("Panel/Words/Text")
	self.DrawImage = self:GetChildGameObject("Panel/DrawImage")
	self.DragSlider = self:GetChildComponent("Panel/DrawImage/DragSlider", "Slider")
	self.Disc = self:GetChildGameObject("Panel/Disc")
	self.listWordItems = {}

	self:UpdateWords()
	self:UpdatePanel()
	self:OnClickPlay()
end

function PageSongPlay:DealWithLocalization()
	return
end

function PageSongPlay:UpdatePanel()
	if not self.DiscTween then
		self.DiscTween = self.Disc.transform:DORotate(Vector3(0, 0, -360), 10, DG.Tweening.RotateMode.FastBeyond360):SetLoops(-1):SetEase(DG.Tweening.Ease.Linear)

		self.DiscTween:SetAutoKill(false)
		self.DiscTween:Pause()
	end

	UIUtil.SetImageSprite(self.DiscImage, self.data.DiscPath, self, false)
end

function PageSongPlay:UpdateWords()
	SoundMgr.LoadBank(self.data.Bank, false, false)

	local count = #self.data.Subtitle

	if count > #self.listWordItems then
		for i = 1, count - #self.listWordItems do
			local item = GOUtil.Instantiate(self.Text, self.Content)

			table.insert(self.listWordItems, item)
		end
	end

	for i = 1, #self.listWordItems do
		if i <= count then
			self.listWordItems[i]:SetActive(true)

			GOUtil.GetComponent(self.listWordItems[i], "Text").text = Lang(self.data.Subtitle[i][2])
		else
			self.listWordItems[i]:SetActive(false)
		end
	end

	if self.Sequence then
		DG.Tweening.DOTween.Kill("Sequence", false)

		self.Sequence = nil
	end

	self.Sequence = DG.Tweening.DOTween.Sequence()

	for i = 1, count do
		self.Sequence:Insert(self.data.Subtitle[i][1], self.Content.transform:DOLocalMoveY(70 * i, 0.5))
	end

	self.Sequence:SetId("Sequence")
	self.Sequence:SetAutoKill(false)
	self.Sequence:Pause()
	GOUtil.SetTransformLocalPosition(self.Content, 0, 0, 0)

	self.Slider.value = 0
	self.playTimes = 0
	self.Time.text = "00:00/" .. self:GetTimeStr(self.data.Length)
	self.Name.text = Lang(self.data.Name)
	self.isPlaying = false
end

function PageSongPlay:GetTimeStr(second)
	local d, h, m, s = GetTimeFormatBySec(second)

	if s < 10 then
		s = "0" .. s
	end

	if m < 10 then
		m = "0" .. m
	end

	return m .. ":" .. s
end

function PageSongPlay:OnClickPlay()
	self.isPlaying = true

	self.Play:SetActive(false)
	self.Stop:SetActive(true)

	if self.Slider.value ~= 0 then
		SoundMgr.ExecuteActionOnEvent(self.data.VoiceEvent, AkActionOnEventType.AkActionOnEventType_Resume)
	else
		SoundMgr.PlayWithCallback(self.data.VoiceEvent, AkCallbackType.AK_EndOfEvent, AkCallbackManager.EventCallback(function(in_cookie, in_type, in_info)
			self.isPlaying = false
			self.Slider.value = 0

			if self.Sequence then
				self.Sequence.fullPosition = 0

				self.Sequence:Pause()
			end

			if self.DiscTween then
				self.DiscTween:Pause()
			end

			self.playTimes = 0

			if not IsNil(self.Stop) then
				self.Stop:SetActive(false)
			end

			if not IsNil(self.Play) then
				self.Play:SetActive(true)
			end

			if not IsNil(self.Time) then
				self.Time.text = "00:00/" .. self:GetTimeStr(self.data.Length)

				self:OnClickPlay()
			end
		end))
	end

	self.Sequence:Play()
	self.DiscTween:Play()
end

function PageSongPlay:OnClickPause()
	self.isPlaying = false

	self.Play:SetActive(true)
	self.Stop:SetActive(false)

	if self.Slider.value ~= 0 then
		SoundMgr.ExecuteActionOnEvent(self.data.VoiceEvent, AkActionOnEventType.AkActionOnEventType_Pause)
	end

	self.Sequence:Pause()
	self.DiscTween:Pause()
end

function PageSongPlay:OnClickNext()
	self:OnClickChange(true)
end

function PageSongPlay:OnClickLast()
	self:OnClickChange(false)
end

function PageSongPlay:OnClickChange(isNext)
	if self.lastPointTime and os.time() - self.lastPointTime < 0.5 then
		return
	end

	self.lastPointTime = os.time()

	local isPlay = self.isPlaying

	SoundMgr.Stop(self.data.VoiceEvent)
	SoundMgr.UnloadBank(self.data.Bank)

	self.data = CollectionManager:GetSongNext(self.data.ID, isNext)

	self.Play:SetActive(true)
	self.Stop:SetActive(false)
	self:UpdateWords()
	self:UpdatePanel()

	if isPlay then
		TimerMgr.AddTimer(eTimerType.FrameCount, 3, function()
			self:OnClickPlay()
		end, self)
	end
end

function PageSongPlay:OnValueChange(value)
	if not self.isPlaying then
		self:OnClickPlay()
	end

	SoundMgr.SeekOnEvent(self.data.VoiceEvent, value, UIMgr.UICamera.gameObject)

	self.Slider.value = value
	self.Sequence.fullPosition = value * self.data.Length
end

function PageSongPlay:OnUpdate()
	if self.isPlaying then
		self.playTimes = self.playTimes + Time.deltaTime

		if self.data.Length <= self.playTimes then
			SoundMgr.Stop(self.data.VoiceEvent)
		else
			self.Slider.value = self.playTimes / self.data.Length
			self.Time.text = self:GetTimeStr(self.playTimes) .. "/" .. self:GetTimeStr(self.data.Length)
		end
	end
end

function PageSongPlay:OnDrag(data)
	self.DragSlider.gameObject:SetActive(true)
	self.Slider.gameObject:SetActive(false)
	self.DragSlider:OnDrag(data)
end

function PageSongPlay:OnPointerDown(data)
	self.DragSlider.gameObject:SetActive(true)
	self.Slider.gameObject:SetActive(false)
	self.DragSlider:OnPointerDown(data)
end

function PageSongPlay:OnPointerUp(data)
	self.DragSlider.gameObject:SetActive(false)
	self.Slider.gameObject:SetActive(true)

	self.playTimes = self.data.Length * self.DragSlider.value

	self:OnValueChange(self.DragSlider.value)
end
