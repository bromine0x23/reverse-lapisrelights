-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/PageCharacterTest.lua

require("UI/Page/PageLogin/UIItemQuestionOption")

PageCharacterTest = class("PageCharacterTest", PageBase)

function PageCharacterTest:ctor(playerCreate)
	self.CurRoleID = 10102
	self.TempAvatars = {
		310001,
		310002
	}
	self.PlayerCreate = playerCreate
end

function PageCharacterTest:Cache()
	self:SubmitUIPrefabCacheLua("UI/PageLogin/PageCharacterTest")
	self:CacheCharacter()
end

function PageCharacterTest:Purge()
	self.CurRoleID = nil
	self.Character = nil
	self.CharCtrlChar = nil
	self.PrefabItemQuestionOption = nil

	PageCharacterTest.base.Purge(self)
end

function PageCharacterTest:TrySyncLoadOptionPrefab()
	if self.PrefabItemQuestionOption == nil then
		self.PrefabItemQuestionOption = ResourceMgr:LoadSyncLua("UI/PageLogin/ItemQuestionOption")
	end
end

function PageCharacterTest:OnPageLoaded()
	self.CurQuestionIdx = 0
	self.AnswerContainer = Container()
	self.OptionItemContainer = Container()

	self:TrySyncLoadOptionPrefab()
	self:ShowCurQuestion()
	self:ShowCharacter()
end

function PageCharacterTest:OnEnter()
	self.RawImage = GOUtil.FindChildComponent(self.UIRootObject, "RawImage", "RawImage")
	self.CharCtrl = GOUtil.AddComponent(self.RawImage.gameObject, "UI3DCharacterExControl")
	self.CharCtrl.NeedDestroyCharOnDestroy = false
	self.CharCtrl.CanPlayAnimation = false
	self.CharCtrl.CanDrag = false
	self.Img_QuestionBk = self:GetChildGameObject("Img_QuestionBk")
	self.Txt_QuestionDesc = self:GetChildComponent("Img_QuestionBk/Txt_QuestionDesc", "Text")
	self.Text_NameLeft = self:GetChildComponent("Img_QuestionBk/Image_BgNameLeft/Text_NameLeft", "Text")

	UIUtility.SetText(self.Text_NameLeft, Localization.Get("DESC_WANG_ASSISTANT"))

	local btn_Skip = self:GetChildComponent("Btn_Skip", "Button")

	self:AutoRegistClick(btn_Skip.gameObject, self.OnClickedSkipBtn)
end

function PageCharacterTest:OnLeave()
	self.RawImage = nil
	self.Txt_QuestionDesc = nil
	self.Img_QuestionBk = nil
	self.CharCtrl.Character = nil
	self.CharCtrl = nil
	self.infoChar = nil

	if not IsNil(self.CharCtrlChar) then
		UIUtility.SetComponentVisible(self.CharCtrlChar, false)
	end

	self.CurQuestionIdx = 0
	self.AnswerContainer = nil
	self.OptionItemContainer = nil
	self.clickItemDisable = false
	self.TempAvatars = nil
end

function PageCharacterTest:OnRegisterEvent()
	return
end

function PageCharacterTest:OnUnRegisterEvent()
	return
end

function PageCharacterTest:CacheCharacter()
	local characterGO = GOUtil.NewGameObject("Character", nil)

	self.Character = GOUtil.AddComponent(characterGO, "Character")

	CharacterMgr:Cache(self.CurRoleID, self.Character, true, "PlayerCreateMotions")
	self.Character:CacheAvatars(self.TempAvatars, true)
end

function PageCharacterTest:CacheCharacterMotion(motionIdx)
	if motionIdx == nil or self.Character == nil then
		return
	end

	local infoChar = CharacterMgr:GetCharacter(self.CurRoleID)

	if infoChar == nil then
		return
	end

	local actorData = infoChar.actorData

	if actorData == nil then
		return
	end

	local motionList = actorData.PlayerCreateMotions

	if motionList == 0 or motionList.Count == 0 or motionIdx >= motionList.Count then
		return
	end

	self.Character:CacheMotionsByArray({
		motionList:get_Item(motionIdx - 1)
	})
end

function PageCharacterTest:ShowCharacter()
	if self.CharCtrl == nil then
		return
	end

	local light = GOUtil.FindChildComponent(self.CharCtrl.CameraEx.gameObject, "DirectionalLight", "Light")

	if light ~= nil then
		light.intensity = 1
	end

	if self.CharCtrlChar == nil then
		self.CharCtrlChar = self.Character
		self.CharCtrl.Character = self.Character

		self.CharCtrl:CreateCharacter(true)
	else
		if self.CharCtrlChar ~= nil then
			self.CharCtrl.Character = self.Character

			UIUtility.SetComponentVisible(self.CharCtrlChar, true)
			self.Character.motionSystem:PlayMotionForce("StandIdle")
		end

		self.CharCtrl:SetTextureSize(self.RawImage.rectTransform.rect.width, self.RawImage.rectTransform.rect.height)
	end

	local defaultLayer = LayerMask.NameToLayer(LayerType.Actor)
	local mask = math.pow(2, defaultLayer)

	self.CharCtrl.CameraEx.cullingMask = mask

	MxUtil.SetChildrenLayer(self.CharCtrl.Character.gameObject, defaultLayer)

	local light = GOUtil.FindChildComponent(self.CharCtrl.CameraEx.gameObject, "DirectionalLight", "Light")

	light.cullingMask = mask

	MxCoroutineHelper.ExecuteNextFrameWithFrameTimes(1, self.Mono, function()
		self.CharCtrl.CameraEx.transform.localEulerAngles = Vector3.New(10, 0, 0)
	end)
	self.CharCtrl:SetCameraPos(Vector3.New(0, 1.49, -1.8))
end

function PageCharacterTest:ShowCurQuestion()
	local questionData = self.PlayerCreate.QuestionDataArray
	local idx = self.CurQuestionIdx

	if idx >= questionData.Length then
		return
	end

	local data = questionData[idx]

	UIUtility.SetText(self.Txt_QuestionDesc, data.QuestionDesc:ToLanguage())

	local curItemCount = self.OptionItemContainer:GetCount()
	local realCount = data.CaseDesc.Count

	if curItemCount < realCount then
		math.randomseed(os.time())

		for i = curItemCount + 1, realCount do
			local itemOption = UIItemQuestionOption(self.PrefabItemQuestionOption, self.UIRootObject, self)

			itemOption:Create()
			self.OptionItemContainer:Push(itemOption)
		end
	elseif realCount < curItemCount then
		for i = realCount + 1, curItemCount do
			local itemOption = self.OptionItemContainer:GetValueByIndex(i)

			UIUtility.SetVisible(itemOption.UIRootObject, false)
		end
	end

	local function clickItem_CB(optionID)
		self:HandleClickOptionItem(optionID)
	end

	for i = 1, realCount do
		local itemOption = self.OptionItemContainer:GetValueByIndex(i)

		itemOption.Index = i

		local strText = DataManager.Instance:GetLanguage(data.CaseDesc:get_Item(i - 1))

		itemOption:SetItem(strText)
		itemOption:SetPos(self:GetOptionPos(i))

		itemOption.OnClick = clickItem_CB
	end
end

function PageCharacterTest:HandleClickOptionItem(optionID)
	if self.clickItemDisable then
		return
	end

	self.AnswerContainer:Push(optionID)

	self.clickItemDisable = true

	local optionCount = self.OptionItemContainer:GetCount()

	for i = 1, optionCount do
		if i ~= optionID then
			local item = self.OptionItemContainer:GetValueByIndex(i)

			item:PlayCloudAnim(nil)
		end
	end

	local questionData = self.PlayerCreate.QuestionDataArray

	local function itemInFinishCB()
		self.clickItemDisable = false
	end

	local waitItem = self.OptionItemContainer:GetValueByIndex(optionID)

	local function waitItemFadeOutFinishCB()
		self.CurQuestionIdx = self.CurQuestionIdx + 1

		if self.CurQuestionIdx >= questionData.Length then
			self:HandleAnswerQuestionFinish()
		else
			self:ShowCurQuestion()
		end

		for i = 1, optionCount do
			local item = self.OptionItemContainer:GetValueByIndex(i)

			item:SetItemIn(0.5, nil)
		end

		MxCoroutineHelper.StartCoroutine(0.5, self.Mono, itemInFinishCB)
	end

	local function waitItemWatingFinishCB()
		return
	end

	DG.Tweening.ShortcutExtensions.DOScale(waitItem.Text.transform, 1.5, 0.2)
	MxCoroutineHelper.StartCoroutine(waitItem.CloudAnimLength, self.Mono, waitItemWatingFinishCB)

	if self.Character ~= nil then
		if self.CurQuestionIdx == questionData.Length - 1 then
			self:HandleAnswerQuestionFinish()
		else
			self.Character.motionSystem:PlayMotionForce_CB("Record", function(motionSystem)
				self.Character.motionSystem:PlayMotionForce("StandIdle")
				UIUtility.SetTransScale(waitItem.Text.transform, Vector3.New(1, 1, 1))
				waitItem:FadeOut(0.2, waitItemFadeOutFinishCB)
			end)
		end
	end
end

function PageCharacterTest:GetOptionPos(optionID)
	if optionID == 1 then
		return Vector3.New(-282, 189, 0)
	elseif optionID == 2 then
		return Vector3.New(309, 165, 0)
	elseif optionID == 3 then
		return Vector3.New(-355, -48, 0)
	elseif optionID == 4 then
		return Vector3.New(387, -61, 0)
	else
		return Vector3.New(0, 0, 0)
	end
end

function PageCharacterTest:HandleAnswerQuestionFinish()
	self.Character.motionSystem:PlayMotionForce_CB("Think", function(motionSystem)
		self.PlayerCreate:CalcGetCharacter(self.AnswerContainer)
		SwitchToPage(self.PlayerCreate.PageTestResultAnimation)
	end)
end

function PageCharacterTest:OnClickedSkipBtn()
	for i = 1, self.PlayerCreate.QuestionDataArray.Length do
		self.AnswerContainer:SetValueByIndex(i, 1)
	end

	self.PlayerCreate:CalcGetCharacter(self.AnswerContainer)
	SwitchToPage(self.PlayerCreate.PageTestResultAnimation)
end
