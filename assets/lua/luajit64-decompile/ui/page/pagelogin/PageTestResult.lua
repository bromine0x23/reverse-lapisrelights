-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/PageTestResult.lua

require("UI/Page/PageLogin/UIItemGetCharInfo")

PageTestResult = class("PageTestResult", PageBase)

function PageTestResult:ctor(playerCreate)
	self.WaitCoroutine = nil
	self.PlayerCreate = playerCreate
end

function PageTestResult:Cache()
	self:SubmitUIPrefabCacheLua("UI/PageLogin/PageTestResult")
end

function PageTestResult:Purge()
	self.PrefabItemGetCharInfo = nil

	PageCharacterTest.base.Purge(self)
end

function PageTestResult:TrySyncLoadCharInfoPrefab()
	if self.PrefabItemGetCharInfo == nil then
		self.PrefabItemGetCharInfo = ResourceMgr:LoadSyncLua("UI/PageLogin/ItemGetCharInfo")
	end
end

function PageTestResult:OnPageLoaded()
	self:ShowCharInfo()
end

function PageTestResult:OnEnter()
	self.RawImage = GOUtil.FindChildComponent(self.UIRootObject, "RawImage", "RawImage")
	self.CharCtrl = GOUtil.AddComponent(self.RawImage.gameObject, "UI3DCharacterExControl")
	self.CharCtrl.CanPlayAnimation = false
	self.CharCtrl.CanDrag = false

	self:SetRTCamera()

	self.Btn_Reselect = self:GetChildComponent("Btn_Reselect", "Button")
	self.Btn_Confirm = self:GetChildComponent("Btn_Confirm", "Button")
	self.Img_ReasonBk = self:GetChildGameObject("Img_Bk")
	self.Text_NameLeft = self:GetChildComponent("Img_Bk/Img_QuestionBk/Image_BgNameLeft/Text_NameLeft", "Text")
	self.Txt_QuestionDesc = self:GetChildComponent("Img_Bk/Img_QuestionBk/Txt_QuestionDesc", "Text")

	UIUtility.SetText(self.Text_NameLeft, Localization.Get("DESC_WANG_ASSISTANT"))
	UIUtility.SetVisible(self.Img_ReasonBk, false)

	self.Img_SelectorRoot = self:GetChildGameObject("Img_SelectorRoot")
	self.Img_RightArrowBtn = self:GetChildComponent("Img_RightArrow", "Button")
	self.Img_LeftArrowBtn = self:GetChildComponent("Img_LeftArrow", "Button")
	self.CharDict = Record()
	self.CacheCharIDTbl = {}
	self.ItemContainer = Container()
	self.CurShowCharID = 0
	self.CurPlayAS = nil
	self.IsPlayingForceAnim = false
end

function PageTestResult:OnLeave()
	self.RawImage = nil
	self.Btn_Reselect = nil
	self.Btn_Confirm = nil
	self.Img_ReasonBk = nil
	self.Text_NameLeft = nil
	self.Txt_QuestionDesc = nil
	self.Img_SelectorRoot = nil
	self.Img_RightArrowBtn = nil
	self.Img_LeftArrowBtn = nil
	self.ItemContainer = nil
	self.UISelector = nil

	local Values = self.CharDict:GetValues()

	for i = 1, #Values do
		if not IsNil(Values[i]) then
			GameObject.Destroy(Values[i].gameObject)
		end
	end

	self.CharDict = nil
	self.CacheCharIDTbl = nil
	self.CurPlayAS = nil
	self.CharCtrl.Character = nil
	self.CharCtrl = nil

	self:StopCoroutine()
end

function PageTestResult:OnRegisterEvent()
	self:AutoRegistClick(self.Btn_Reselect.gameObject, self.OnClickedReSelectBtn)
	self:AutoRegistClick(self.Btn_Confirm.gameObject, self.OnClickedConfirmBtn)
	self:AutoRegistClick(self.Img_LeftArrowBtn.gameObject, self.OnClickedLeftArrowBtn)
	self:AutoRegistClick(self.Img_RightArrowBtn.gameObject, self.OnClickedRightArrowBtn)
	self:AutoRegistClick(self.Img_ReasonBk, self.OnClickedReasonBk)
	self:AutoRegistClick(self.RawImage.gameObject, self.OnClickChar)
end

function PageTestResult:OnUnRegisterEvent()
	return
end

function PageTestResult:CacheCharacter(charID)
	local characterGO = GOUtil.NewGameObject("Character_" .. charID, nil)
	local character = GOUtil.AddComponent(characterGO, "Character")

	CharacterMgr:Cache(charID, character, true, "Motions")

	return character
end

function PageTestResult:SetRTCamera()
	if self.CharCtrl == nil then
		return
	end

	local light = GOUtil.FindChildComponent(self.CharCtrl.CameraEx.gameObject, "DirectionalLight", "Light")

	if light ~= nil then
		light.intensity = 1
	end

	self.CharCtrl:SetCameraPos(Vector3.New(0, 1.13, -2.2))
end

function PageTestResult:HideCharacter()
	local chars = self.CharDict:GetValues()
	local charsCount = #chars

	for i = 1, charsCount do
		UIUtility.SetComponentVisible(chars[i], false)
	end
end

function PageTestResult:ShowCharacter(charID)
	if self.CurShowCharID == charID then
		return
	end

	self.CurShowCharID = charID

	self:HideCharacter()

	local char = self.CharDict:GetValue(charID)

	if char == nil then
		if self.CharCtrl ~= nil then
			LoadingMgr.Show(eLoadingType.Repeat)
			MxResMgr.Instance:BeginSubmitCB(nil, function()
				self:OnPlayerLoadCompleted()
			end)

			char = self:CacheCharacter(charID)

			MxResMgr.Instance:EndSubmit()
			self.CharDict:Set(charID, char)
			table.insert(self.CacheCharIDTbl, charID)
		end
	else
		UIUtility.SetComponentVisible(char, true)
		self:PlayCharAnimAndSound(charID)
	end
end

function PageTestResult:OnPlayerLoadCompleted(handle, loaded, count, idx)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if #self.CacheCharIDTbl == 0 then
		return
	end

	for i = 1, #self.CacheCharIDTbl do
		local charID = self.CacheCharIDTbl[i]
		local char = self.CharDict:GetValue(charID)

		if char ~= nil then
			self.CharCtrl.Character = char

			local activeChar = char.gameObject.activeInHierarchy

			UIUtility.SetComponentVisible(char, true)
			self.CharCtrl:CreateCharacter(true)
			UIUtility.SetComponentVisible(char, activeChar)

			if activeChar then
				self:PlayCharAnimAndSound(charID)
			end
		end
	end

	self.CacheCharIDTbl = nil
	self.CacheCharIDTbl = {}
end

function PageTestResult:OnClickedReSelectBtn()
	SwitchToPage(self.PlayerCreate.PageCharacterTest)
end

function PageTestResult:OnClickedConfirmBtn()
	UIUtility.SetComponentVisible(self.RawImage, false)
	UIUtility.SetComponentVisible(self.Btn_Reselect, false)
	UIUtility.SetComponentVisible(self.Btn_Confirm, false)
	UIUtility.SetVisible(self.Img_SelectorRoot, false)
	UIUtility.SetComponentVisible(self.Img_LeftArrowBtn, false)
	UIUtility.SetComponentVisible(self.Img_RightArrowBtn, false)
	self:HideCharacter()
	self:CreateAsChild(self.PlayerCreate.DlgExploreConversation, 1003)

	function self.PlayerCreate.DlgExploreConversation.OnFinish()
		SwitchToPage(self.PlayerCreate.PageUserNameInput)
	end
end

function PageTestResult:ShowCharInfo()
	local getCharTbl = self.PlayerCreate.GetCharTbl
	local getCharCount = #getCharTbl

	self.UISelector = GOUtil.AddComponent(self.Img_SelectorRoot, "UISelector")

	local function wrap_cb(go)
		self:OnSelectorChanged(go)
	end

	self.UISelector.onChanged = wrap_cb

	self:TrySyncLoadCharInfoPrefab()

	local uisos = {}

	for i = 1, getCharCount do
		local item = UIItemGetCharInfo(self.PrefabItemGetCharInfo, self.Img_SelectorRoot, self)

		item:Create()

		item.Index = i

		item:SetItem(getCharTbl[i], self:GetReasonTipTbl(i))
		item:SetPos(self:GetCharInfoItemPos(i))
		item.UIRootObject.transform:SetAsFirstSibling()

		item.UIRootObject.name = "UIItemGetCharInfo" .. i

		self.ItemContainer:Push(item)

		local uiSelectorObj = GOUtil.AddComponent(item.UIRootObject, "UISelectorObject")

		uiSelectorObj.Alpha = 1
		uiSelectorObj.Scale = 1

		table.insert(uisos, uiSelectorObj)

		if i == 1 then
			uiSelectorObj:SetAlpha(1)
			uiSelectorObj:SetScale(1)
		end
	end

	self.UISelector:SetObjects(uisos)
	self:ShowCharIntro(getCharTbl[1])
	self:ShowCharacter(getCharTbl[1])
end

function PageTestResult:OnSelectorChanged(go)
	if go == nil then
		return
	end

	local charIdx = 1
	local charCount = self.ItemContainer:GetCount()

	for i = 1, charCount do
		local item = self.ItemContainer:GetValueByIndex(i)

		if item.UIRootObject == go then
			charIdx = i

			break
		end
	end

	local charID = self.PlayerCreate.GetCharTbl[charIdx]

	self:ShowCharIntro(charID)
	self:ShowCharacter(charID)
end

function PageTestResult:GetCharInfoItemPos(idx)
	local startXPos = 22
	local startYPos = 0
	local xPosOffset = 38
	local yPosOffset = -26
	local pos = Vector3.New(startXPos + (idx - 1) * xPosOffset, startYPos + (idx - 1) * yPosOffset, 0)

	return pos
end

function PageTestResult:GetReasonTipTbl(groupID)
	local tbl = {}
	local playerCreate = self.PlayerCreate
	local questionData = playerCreate.QuestionDataTbl
	local selectCharIdx = 1
	local selectOptionIdx = 0
	local selectCharID = playerCreate.GetCharTbl[groupID]
	local strDesc = ""
	local questionCount = #questionData

	for i = 1, questionCount do
		local data = questionData[i].data

		if groupID == data.GroupId then
			selectCharIdx = selectCharID == data.Character1 and 1 or 2
			selectOptionIdx = questionData[i].AnswerOption - 1

			if data.MapList:get_Item(selectOptionIdx) == selectCharIdx then
				strDesc = DataManager.Instance:GetLanguage(data.MapDesc:get_Item(selectOptionIdx))

				if strDesc ~= "0" then
					table.insert(tbl, strDesc)
				end
			end
		end
	end

	return tbl
end

function PageTestResult:ShowCharIntro(charID)
	local infoChar = CharacterMgr:GetCharacter(charID)
	local tips = infoChar.infoData.Tips
	local tipCount = tips.Count
	local strIntro = ""

	for i = 1, tipCount do
		strIntro = strIntro .. DataManager.Instance:GetLanguage(tips:get_Item(i - 1))
	end

	UIUtility.SetVisible(self.Img_ReasonBk, true)
	UIUtility.SetText(self.Txt_QuestionDesc, strIntro)
end

function PageTestResult:OnClickedReasonBk()
	self:StopCoroutine()
	UIUtility.SetVisible(self.Img_ReasonBk, false)
end

function PageTestResult:StopCoroutine()
	if self.WaitCoroutine ~= nil then
		MxCoroutineHelper.StopCoroutine(self.WaitCoroutine)

		self.WaitCoroutine = nil
	end
end

function PageTestResult:PlayCharAnimAndSound(charID)
	local infoChar = CharacterMgr:GetCharacter(charID)
	local char = self.CharDict:GetValue(charID)

	if char.motionSystem.bodyAnim == nil then
		return
	end

	char.motionSystem:PlayMotionForce_G_CB("Welcome", -1, function()
		char.motionSystem:PlayMotion("StandIdle")

		self.IsPlayingForceAnim = false
	end)
end

function PageTestResult:OnClickChar(data)
	if self.IsPlayingForceAnim then
		return
	end

	self.IsPlayingForceAnim = true

	self:PlayCharAnimAndSound(self.CurShowCharID)
end

function PageTestResult:OnClickedLeftArrowBtn()
	if self.UISelector ~= nil then
		self.UISelector:Next()
	end
end

function PageTestResult:OnClickedRightArrowBtn()
	if self.UISelector ~= nil then
		self.UISelector:Previous()
	end
end
