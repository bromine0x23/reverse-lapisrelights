-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/PageTestResultAnimation.lua

PageTestResultAnimation = class("PageTestResultAnimation", PageBase)

function PageTestResultAnimation:ctor(playerCreate)
	self.AnimInfo = {
		{
			Dir = "Right",
			InitPos = 380,
			FinalPos = 370,
			Duration = 0.15
		},
		{
			Dir = "Left",
			InitPos = -380,
			FinalPos = -370,
			Duration = 0.15
		},
		{
			Dir = "Center",
			InitPos = -10,
			FinalPos = 0,
			Duration = 0.15
		},
		{
			Dir = "Right",
			InitPos = 370,
			FinalPos = 360,
			Duration = 0.15
		},
		{
			Dir = "Left",
			InitPos = -370,
			FinalPos = -360,
			Duration = 0.15
		},
		{
			Dir = "Center",
			InitPos = -10,
			FinalPos = 0,
			Duration = 0.15
		}
	}
	self.CharImgInitCol = Color.New(0, 0, 0, 1)
	self.CharImgFinalCol = Color.New(1, 1, 1, 1)
	self.ConfirmInitLeftPos = -360
	self.ConfirmInitRightPos = 360
	self.ConfirmFinalLeftPos = -350
	self.ConfirmFinalRightPos = 350
	self.BlackShadowFadeTime = 0.15
	self.ConfirmAnimCharFadeTime = 0.2
	self.ConfirmAnimConfrimImgFadeTime = 0.2
	self.ConfirmAnimConfrimImgInitScale = Vector3.New(1.2, 1.2, 1.2)
	self.PlayerCreate = playerCreate
end

function PageTestResultAnimation:Cache()
	self:SubmitUIPrefabCacheLua("UI/PageLogin/PageTestResultAnimation")
end

function PageTestResultAnimation:OnPageLoaded()
	self:PlayAnimation()
end

function PageTestResultAnimation:OnEnter()
	self.Img_Bk = self:GetChildComponent("Img_Bk", "Image")
	self.Img_CharLeftImg = self:GetChildComponent("Img_CharLeft", "Image")
	self.Img_CharCenterImg = self:GetChildComponent("Img_CharCenter", "Image")
	self.Img_CharRightImg = self:GetChildComponent("Img_CharRight", "Image")
	self.Img_Confirm = self:GetChildComponent("Img_Confirm", "Image")

	UIUtility.SetComponentVisible(self.Img_CharLeftImg, false)
	UIUtility.SetComponentVisible(self.Img_CharCenterImg, false)
	UIUtility.SetComponentVisible(self.Img_CharRightImg, false)

	self.CurAnimInfoIdx = 1
	self.CurPlayAnimImg = nil
	self.AnimPlayFinished = false
end

function PageTestResultAnimation:OnLeave()
	self.Img_Bk = nil
	self.Img_CharLeftImg = nil
	self.Img_CharRightImg = nil
	self.Img_CharCenterImg = nil
	self.Img_Confirm = nil
	self.CurAnimInfoIdx = 1
	self.CurPlayAnimImg = nil
end

function PageTestResultAnimation:OnRegisterEvent()
	self:AutoRegistClick(self.UIRootObject, self.OnClickBk)
end

function PageTestResultAnimation:OnUnRegisterEvent()
	return
end

function PageTestResultAnimation:ResetCurPlayAnimImg(dirType)
	if dirType == "Right" then
		self.CurPlayAnimImg = self.Img_CharRightImg
	elseif dirType == "Left" then
		self.CurPlayAnimImg = self.Img_CharLeftImg
	elseif dirType == "Center" then
		self.CurPlayAnimImg = self.Img_CharCenterImg
	end
end

function PageTestResultAnimation:GetImgByCharIdx(charIdx)
	if charIdx == 1 then
		return self.Img_CharLeftImg
	elseif charIdx == 2 then
		return self.Img_CharCenterImg
	elseif charIdx == 3 then
		return self.Img_CharRightImg
	end
end

function PageTestResultAnimation:GetConfirmInitPosByImgIdx(imgIdx)
	if imgIdx == 1 then
		return self.ConfirmInitLeftPos
	elseif imgIdx == 2 then
		return 0
	elseif imgIdx == 3 then
		return self.ConfirmInitRightPos
	end
end

function PageTestResultAnimation:GetConfirmFinalPosByImgIdx(imgIdx)
	if imgIdx == 1 then
		return self.ConfirmFinalLeftPos
	elseif imgIdx == 2 then
		return 0
	elseif imgIdx == 3 then
		return self.ConfirmFinalRightPos
	end
end

function PageTestResultAnimation:SetImgInitState(img, initPos, charID)
	if img == nil then
		return
	end

	UIUtility.SetRTPos(img.transform, Vector3.New(initPos, 0, 0))
	UIUtility.SetComponentVisible(img, true)

	local infoChar = CharacterMgr:GetCharacter(charID)

	UIUtility.SetSprite(img, PATH_CHAR_PHOTO .. infoChar:GetCharacterBodyIcon(), false)
	UIUtility.SetGraphicColor(img, self.CharImgInitCol)
end

function PageTestResultAnimation:PlayAnimation()
	if self.CurAnimInfoIdx > #self.AnimInfo then
		return
	end

	if self.CurPlayAnimImg ~= nil then
		UIUtility.SetComponentVisible(self.CurPlayAnimImg, false)
	end

	local animInfo = self.AnimInfo[self.CurAnimInfoIdx]

	if self.CurAnimInfoIdx == 1 then
		local bkFadeDuration = animInfo.Duration / 3 + 1

		DG.Tweening.ShortcutExtensions46.DOFade(self.Img_Bk, 1, bkFadeDuration)
	elseif self.CurAnimInfoIdx == #self.AnimInfo then
		local bkFadeDuration = animInfo.Duration / 3 * 5

		DG.Tweening.ShortcutExtensions46.DOFade(self.Img_Bk, 0, bkFadeDuration)
	end

	self:ResetCurPlayAnimImg(animInfo.Dir)

	local charID = self.PlayerCreate.CreateCharIDContainer:GetValueByIndex(self.CurAnimInfoIdx)

	self:SetImgInitState(self.CurPlayAnimImg, animInfo.InitPos, charID)
	MxCoroutineHelper.StartCoroutine(self.BlackShadowFadeTime, self.Mono, function()
		DG.Tweening.ShortcutExtensions46.DOColor(self.CurPlayAnimImg, self.CharImgFinalCol, animInfo.Duration)

		local tweener = DG.Tweening.ShortcutExtensions.DOLocalMoveX(self.CurPlayAnimImg.transform, animInfo.FinalPos, animInfo.Duration, false)

		UIUtility.SetTweenerCallback(tweener, function()
			self.CurAnimInfoIdx = self.CurAnimInfoIdx + 1

			if self.CurAnimInfoIdx <= #self.AnimInfo then
				self:PlayAnimation()
			else
				UIUtility.SetComponentVisible(self.CurPlayAnimImg, false)
				self:PlayConfirmAnimation()
			end
		end)
	end)
end

function PageTestResultAnimation:PlayConfirmAnimation()
	local charCount = self.PlayerCreate.CreateCharIDContainer:GetCount()
	local getCharTbl = self.PlayerCreate.GetCharTbl

	for i = 1, #getCharTbl do
		local charID = getCharTbl[i]
		local charIdx = self.PlayerCreate.CreateCharIDContainer:GetIndexByValue(charID)
		local animInfo = self.AnimInfo[charIdx]
		local img = self:GetImgByCharIdx(i)

		self:SetImgInitState(img, self:GetConfirmInitPosByImgIdx(i), charID)
		MxCoroutineHelper.StartCoroutine(self.BlackShadowFadeTime, self.Mono, function()
			DG.Tweening.ShortcutExtensions.DOLocalMoveX(img.transform, self:GetConfirmFinalPosByImgIdx(i), self.ConfirmAnimCharFadeTime, false)
			DG.Tweening.ShortcutExtensions46.DOColor(img, self.CharImgFinalCol, self.ConfirmAnimCharFadeTime)
		end)
	end

	MxCoroutineHelper.StartCoroutine(self.ConfirmAnimCharFadeTime + self.BlackShadowFadeTime, self.Mono, function()
		UIUtility.SetTransScale(self.Img_Confirm.transform, self.ConfirmAnimConfrimImgInitScale)
		UIUtility.SetComponentVisible(self.Img_Confirm, true)
		DG.Tweening.ShortcutExtensions.DOScale(self.Img_Confirm.transform, 1, self.ConfirmAnimConfrimImgFadeTime)
		DG.Tweening.ShortcutExtensions46.DOFade(self.Img_Confirm, 1, self.ConfirmAnimConfrimImgFadeTime)

		self.AnimPlayFinished = true
	end)
end

function PageTestResultAnimation:OnClickBk()
	if not self.AnimPlayFinished then
		return
	end

	SwitchToPage(self.PlayerCreate.PageTestResult)
end
