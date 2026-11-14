-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/PageUserNameInput.lua

require("Info/NickConfig")

PageUserNameInput = class("PageUserNameInput", PageBase)

function PageUserNameInput:ctor(playerCreate)
	self.PlayerCreate = playerCreate
end

function PageUserNameInput:Cache()
	self:SubmitUIPrefabCacheLua("UI/PageLogin/PageUserNameInput")
end

function PageUserNameInput:OnPageLoaded()
	return
end

function PageUserNameInput:OnEnter()
	self.lastName = ""
	self.Panel = self:GetChildGameObject("Panel")

	local txt_AName = self:GetChildComponent("Panel/Txt_AName", "Text")

	UIUtility.SetText(txt_AName, Localization.Get("DESC_COLLEGE"))

	self.Input_Name = self:GetChildComponent("Panel/Input_Name", "InputField")

	local function wrap_cb(str)
		self:OnInputFieldChange(str)
	end

	self.Input_Name.onEndEdit:AddListener(wrap_cb)

	self.Btn_Random = self:GetChildComponent("Panel/Input_Name/Btn_Random", "Button")
	self.PromptDlgShown = false

	local txt_ContractContent = self:GetChildComponent("Panel/Txt_ContractContent", "Text")

	UIUtility.SetText(txt_ContractContent, Localization.Get("Prompt_ContractContent"))

	self.Img_Bk = self:GetChildGameObject("Img_Bk")

	UIUtility.SetVisible(self.Img_Bk, false)

	local img_Icon = self:GetChildComponent("Img_Bk/Img_Icon", "Image")

	UIUtility.SetSprite(img_Icon, PATH_CHAR_PHOTO .. "ui_charphoto_wangzijie01", false)

	self.Text_NameLeft = self:GetChildComponent("Img_Bk/Img_QuestionBk/Image_BgNameLeft/Text_NameLeft", "Text")
	self.Txt_QuestionDesc = self:GetChildComponent("Img_Bk/Img_QuestionBk/Txt_QuestionDesc", "Text")

	UIUtility.SetText(self.Text_NameLeft, Localization.Get("DESC_WANG_ASSISTANT"))
	UIUtility.SetText(self.Txt_QuestionDesc, Localization.Get("Prompt_SignContract"))

	self.Btn_Think = self:GetChildComponent("Panel/Btn_Think", "Button")
	self.Txt_Think = self:GetChildComponent("Panel/Btn_Think/Txt_Think", "Text")
	self.Btn_Sign = self:GetChildComponent("Panel/Btn_Sign", "Button")
	self.Txt_Sign = self:GetChildComponent("Panel/Btn_Sign/Txt_Sign", "Text")

	UIUtility.SetText(self.Txt_Think, Localization.Get("DESC_THINK"))
	UIUtility.SetText(self.Txt_Sign, Localization.Get("DESC_SIGN"))

	self.Img_SealTrans = self:GetChildComponent("Panel/Img_Seal", "Transform")

	UIUtility.SetTransScale(self.Img_SealTrans, Vector3.New(2, 2, 2))
	UIUtility.SetComponentVisible(self.Img_SealTrans, false)
end

function PageUserNameInput:OnLeave()
	self.Input_Name = nil
	self.PromptDlgShown = false
	self.Btn_Random = nil
	self.Img_Bk = nil
	self.Text_NameLeft = nil
	self.Txt_QuestionDesc = nil
	self.Btn_Think = nil
	self.Txt_Think = nil
	self.Btn_Sign = nil
	self.Txt_Sign = nil
	self.Img_SealTrans = nil
	self.Panel = nil
end

function PageUserNameInput:OnRegisterEvent()
	self:AutoRegistClick(self.Btn_Think.gameObject, self.OnClickedThinkBtn)
	self:AutoRegistClick(self.Btn_Sign.gameObject, self.OnClickedSignBtn)
	self:AutoRegistClick(self.Btn_Random.gameObject, self.OnClickedRandomBtn)
end

function PageUserNameInput:OnUnRegisterEvent()
	return
end

function PageUserNameInput:OnInputFieldChange(strP)
	local str = MxUtil.CutStringSpace(strP)
	local nameLength = utf8len(str)

	if nameLength > 6 then
		str = utf8sub(str, 1, 6)
		self.Input_Name.text = str
	else
		self.Input_Name.text = str
	end
end

function PageUserNameInput:OnClickedRandomBtn()
	local nick = GetRandomPlayerNick()

	self.Input_Name.text = ""

	if nick ~= nil and nick ~= "" then
		if utf8len(nick) > 6 then
			nick = utf8sub(nick, 1, 6)
		end

		self.Input_Name.text = nick
	end
end

function PageUserNameInput:OnClickedThinkBtn()
	SwitchToPage(self.PlayerCreate.PageTestResult)
end

function PageUserNameInput:OnClickedSignBtn()
	local nickName = self.Input_Name.text

	if nickName == nil or string.len(nickName) == 0 then
		UIMgr.ShowMsg(Localization.Get("Prompt_PleaseSignNameFirst"))

		return
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestSubmitPlayerInfo(1, nickName, self.PlayerCreate.GetCharTbl, self.PlayerCreate.PlayerSex, function(p12_Response)
		self:OnSubmitPlayerInfo(p12_Response)
	end, self.PlayerCreate.initSkin)
end

function PageUserNameInput:OnSubmitPlayerInfo(p12_Response)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if p12_Response.result.code ~= NetManager.Result_Sucess then
		UIMgr.ShowMsg(p12_Response.result.desc, p12_Response)

		return
	end

	PlayerInst.InfoPlayer.name = p12_Response.nickname
	PlayerInst.InfoPlayer.regTime = NetData:GetCurServerTime()
	PlayerInst.InfoPlayer.gender = self.PlayerCreate.PlayerSex

	if SDKMgr.Instance ~= nil then
		SDKMgr.Instance:OnCreatRole()
	end

	InstructionMgr:UploadAnalysis(-1)
	UIUtility.SetComponentVisible(self.Btn_Sign, false)
	UIUtility.SetComponentVisible(self.Btn_Think, false)
	UIUtility.SetComponentVisible(self.Img_SealTrans, true)

	local function wrap_cb()
		self:RequestGetBasePlayer()
	end

	local duration = 0.3

	DG.Tweening.ShortcutExtensions.DOLocalMoveY(self.Img_SealTrans, -70, duration, false)

	local tweener = DG.Tweening.ShortcutExtensions.DOScale(self.Img_SealTrans, 1, duration)

	UIUtility.SetTweenerCallback(tweener, wrap_cb)
end

function PageUserNameInput:RequestGetPlayer()
	local function wrap_cb(...)
		self:OnGetPlayerInfo(...)
	end

	NetManager:RequestGetPlayerInfo(wrap_cb)
end

function PageUserNameInput:OnGetPlayerInfo(vPBMessage)
	local code = vPBMessage.result.code

	CharacterMgr:GetAllMemberList()

	if code == NetManager.Result_Sucess or code == 2 then
		self.PlayerCreate:GotoSupport()
	else
		print("OnGetPlayerInfo err: " .. vPBMessage.result.desc)
	end
end

function PageUserNameInput:HideButBk()
	self.Panel:SetActive(false)
end

function PageUserNameInput:RequestGetBasePlayer()
	local function wrap_cb(...)
		self:OnGetBasePlayerInfo(...)
	end

	NetManager:RequestGetBasePlayerInfo(wrap_cb)
end

function PageUserNameInput:OnGetBasePlayerInfo(vPBMessage)
	local code = vPBMessage.result.code

	if code == NetManager.Result_Sucess then
		self:RequestGetPlayer()
	else
		self:OnGetBasePlayerInfo()
	end
end
