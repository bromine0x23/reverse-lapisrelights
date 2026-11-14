-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePlayerInfo/DlgModifyNick.lua

DlgModifyNick = class("DlgModifyNick", UIPanel)

function DlgModifyNick:ctor()
	self.UIPrefabPath = "UI/PanelPlayerInfo/DlgModifyNick"
end

function DlgModifyNick:Purge()
	self.base.Purge(self)
end

function DlgModifyNick:OnRegisterEvent()
	self:AddClick(self.BtnQuit, self.OnClickedButtonQuit, PATH_SFX_UI_CANCEL)
	self:AddClick(self.BtnConfirm, self.OnClickedButtonConfirm)
	self:AddClick(self.BtnFree, self.OnClickedButtonConfirm)
	self:AddClick(self.BtnConfirm2, self.OnClickedButtonConfirm)
end

function DlgModifyNick:OnUnRegisterEvent()
	self:RemoveClick(self.BtnQuit, self.OnClickedButtonQuit)
	self:RemoveClick(self.BtnConfirm, self.OnClickedButtonConfirm)
	self:RemoveClick(self.BtnFree, self.OnClickedButtonConfirm)
	self:RemoveClick(self.BtnConfirm2, self.OnClickedButtonConfirm)
end

function DlgModifyNick:DealWithLocalization()
	local txt = self:GetChildComponent("Panel/BtnConfirm2/Text", "Text")

	txt.text = Lang(42001)
	txt = self:GetChildComponent("Panel/BtnFree/Text", "Text")
	txt.text = _("Btn_CostFree")
end

function DlgModifyNick:OnEnter(vParam)
	self:DealWithLocalization()

	self.BtnQuit = self:GetChildGameObject("Panel/BtnQuit")
	self.BtnFree = self:GetChildGameObject("Panel/BtnFree")
	self.BtnConfirm = self:GetChildGameObject("Panel/BtnConfirm")
	self.BtnConfirm2 = self:GetChildGameObject("Panel/BtnConfirm2")
	self.TxtTitle = self:GetChildComponent("Panel/Title/Text", "Text")
	self.InputField = self:GetChildComponent("Panel/InputArea/InputField", "InputField")
	self.TxtPlaceholder = self:GetChildComponent("Panel/InputArea/InputField/Placeholder", "Text")
	self.ComponentLimit = self:GetChildComponent("Panel/InputArea/InputField", "UIInputFieldCharLimit")
	self.TxtCostNum = self:GetChildComponent("Panel/BtnConfirm/TxtNum", "Text")
	self.TxtPrompt = self:GetChildComponent("Panel/TxtPrompt", "Text")
	self.TxtPrompt.text = ""

	self:Init(unpack(vParam))
end

function DlgModifyNick:Init(_modifyType, _lastInput, _callback)
	self.modifyType = _modifyType or eModifyInputType.Nick
	self.lastInput = _lastInput or ""
	self.cb = _callback

	if self.modifyType == eModifyInputType.Nick then
		self.TxtTitle.text = Lang(12131)
		self.ComponentLimit.MaxLimitChar = 6
		self.InputField.text = PlayerInst:GetNickName()
		self.TxtPlaceholder.text = Lang(12133)

		local freeNum = GetConfigArgInt("ChangeNameFreeNum")
		local canFree = freeNum > InfoGameInst:GetRenameNum()

		if not canFree then
			self.TxtPrompt.text = Lang(45007)
			self.TxtCostNum.text = GetConfigArgJson("ChangeNameFreeNum")[2]
		end

		GOUtil.SetActive(self.BtnFree, canFree)
		GOUtil.SetActive(self.BtnConfirm, not canFree)
	elseif self.modifyType == eModifyInputType.Signature then
		self.TxtTitle.text = Lang(12132)
		self.ComponentLimit.MaxLimitChar = 26
		self.InputField.text = PlayerInst:GetSignature()
		self.TxtPlaceholder.text = Lang(1)

		GOUtil.SetActive(self.BtnConfirm2, true)
		GOUtil.SetRectTransformSizeDelta(self.InputField.gameObject, 660, 60)
	elseif self.modifyType == eModifyInputType.Team then
		self.TxtTitle.text = Lang(200003)
		self.ComponentLimit.MaxLimitChar = 6
		self.InputField.text = self.lastInput
		self.TxtPlaceholder.text = Lang(200004)

		GOUtil.SetActive(self.BtnConfirm2, true)
	elseif self.modifyType == eModifyInputType.UnionNotice then
		self.TxtTitle.text = Lang(12543)
		self.ComponentLimit.MaxLimitChar = 45
		self.InputField.text = UnionMgr.releUnion.notice
		self.TxtPlaceholder.text = Lang(1)

		GOUtil.SetActive(self.BtnConfirm2, true)
		GOUtil.SetRectTransformSizeDelta(self.InputField.gameObject, 660, 60)
	elseif self.modifyType == eModifyInputType.AvatarMode then
		self.TxtTitle.text = Lang(42357)
		self.ComponentLimit.MaxLimitChar = 6
		self.InputField.text = self.lastInput
		self.TxtPlaceholder.text = Lang(42358)

		GOUtil.SetActive(self.BtnConfirm2, true)
	end

	self.preInput = self.InputField.text
end

function DlgModifyNick:GetWordLimit()
	return GetConfigArgJson("WordLimit")[self.modifyType][2]
end

function DlgModifyNick:OnClickedButtonConfirm()
	if utf8len(self.InputField.text) > self:GetWordLimit() then
		UIMgr.ShowMsg(_("Over_MaxNickName"))

		return
	end

	if self.InputField.text == "" then
		if self.modifyType == eModifyInputType.Nick then
			UIMgr.ShowMsg(_("Msg_Input_Nick_Name"))
		elseif self.modifyType == eModifyInputType.Signature then
			UIMgr.ShowMsg(_("Msg_Input_Signature"))
		elseif self.modifyType == eModifyInputType.Team then
			UIMgr.ShowMsg(_("Msg_Input_Team_Name"))
		elseif self.modifyType == eModifyInputType.UnionNotice then
			UIMgr.ShowMsg(_("Msg_Input_Union_Notice"))
		elseif self.modifyType == eModifyInputType.AvatarMode then
			UIMgr.ShowMsg(_("Msg_Input_Avatar_Mode_Name"))
		end

		return
	end

	if self.preInput == self.InputField.text then
		UIMgr.ShowMsg(_("Msg_Input_Not_Modify"))

		return
	end

	if self.modifyType == eModifyInputType.Team or self.modifyType == eModifyInputType.AvatarMode then
		if self.cb then
			self.cb(self.InputField.text, function()
				self:Close()
			end)
		end
	elseif self.modifyType == eModifyInputType.UnionNotice then
		self:RequestModifyUnionNotice()
	else
		self:RequestModifyPlayerInfo()
	end
end

function DlgModifyNick:RequestModifyPlayerInfo()
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			if self.modifyType == eModifyInputType.Nick then
				UIMgr.ShowMsg(_("Msg_Nick_Name_Modify_Sucess"))
				Event.Instance:Fire(EventEnum.UpdatePlayerInfo, ePlayerInfoType.nickName)
			elseif self.modifyType == eModifyInputType.Signature then
				UIMgr.ShowMsg(_("Msg_Signature_Modify_Sucess"))
				Event.Instance:Fire(EventEnum.UpdatePlayerInfo, ePlayerInfoType.signature)
			end

			self:Close()
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	if self.modifyType == eModifyInputType.Nick then
		local function changeName(_type)
			if _type == DlgCommonEvent.ButtonType.Ok then
				LoadingMgr.Show(eLoadingType.Repeat)
				NetManager:RequestModifyPlayerInfo({
					nickname = self.InputField.text
				}, wrap_cb)
			end
		end

		local function default()
			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:RequestModifyPlayerInfo({
				nickname = self.InputField.text
			}, wrap_cb)
		end

		local freeNum = GetConfigArgInt("ChangeNameFreeNum")
		local canFree = freeNum > InfoGameInst:GetRenameNum()

		if canFree then
			default()
		else
			local price = tonumber(GetConfigArgJson("ChangeNameFreeNum")[2])

			UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Tittle_Affirm"), {
				isDiamond = true,
				text = string.format(_("Desc_ChangeNameConfirm"), price)
			}, function(idx)
				if idx == 1 then
					default()
				end
			end, _("Button_Yes"), _("Button_No"), true)
		end
	elseif self.modifyType == eModifyInputType.Signature then
		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestModifyPlayerInfo({
			signature = self.InputField.text
		}, wrap_cb)
	end
end

function DlgModifyNick:RequestModifyUnionNotice()
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self:Close()
			UIMgr.ShowMsg(_("Msg_Union_Notice_Modify_Sucess"))
		elseif vMsg.result.code == 2 then
			self:Close()
			PageUnion.GoBackMainPage(vMsg)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestUnionSetting(self.InputField.text, nil, nil, wrap_cb)
end

function DlgModifyNick:OnClickedButtonQuit()
	self:Close()
end

function DlgModifyNick:OnClickedBtnRandom()
	local nick = GetRandomPlayerNick()

	self.InputField.text = ""

	if nick ~= nil and nick ~= "" then
		if utf8len(nick) > 6 then
			nick = utf8sub(nick, 1, 6)
		end

		self.InputField.text = nick
	end
end
