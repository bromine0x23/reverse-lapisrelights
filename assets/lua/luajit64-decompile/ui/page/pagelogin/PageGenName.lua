-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/PageGenName.lua

require("Info/NickConfig")
require("Guide/GuideFlow")

PageGenName = class("PageGenName", UIPanel)
PageGenName.UserNameLimit = 6

function PageGenName:ctor()
	PageLogin.base.ctor(self, "UI/PanelCreatePlayer/PanelGenName")
end

function PageGenName:PreLoad()
	self.PrefabAnim = ResourceMgr.LoadSync("UI/PanelCreatePlayer/PanelGenName_Anim")
end

function PageGenName:OnEnter(cb)
	if type(cb) == "function" then
		self.cb = cb
	else
		self.callback = cb.callback
	end

	self.ButtonSign = self:GetChildComponent("Panel/ButtonSign", "Button")
	self.InputFieldName = self:GetChildComponent("Panel/InputFieldName", "InputField")
	self.ButtonRandom = self:GetChildComponent("Panel/InputFieldName/ButtonRandom", "Button")
	self.Txt_AName2 = self:GetChildComponent("Panel/Txt_AName2", "Text")
	self.Txt_AName2.text = _("Desc_GuideName")
	self.InputFieldName.characterLimit = PageGenName.UserNameLimit

	self:OnClickedButtonRandom()
end

function PageGenName:OnLeave()
	if self.PrefabAnim then
		ResourceMgr.Unload(self.PrefabAnim)

		self.PrefabAnim = nil
	end

	self.ButtonSign = nil
	self.InputFieldName = nil
	self.ButtonRandom = nil
end

function PageGenName:OnRegisterEvent()
	self:AddClick(self.ButtonSign.gameObject, self.OnClickedButtonSign)
	self:AddClick(self.ButtonRandom.gameObject, self.OnClickedButtonRandom)
end

function PageGenName:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonSign.gameObject, self.OnClickedButtonSign)
	self:RemoveClick(self.ButtonRandom.gameObject, self.OnClickedButtonRandom)
end

function PageGenName:OnClickedButtonRandom()
	local nick = GetRandomPlayerNick()

	self.InputFieldName.text = ""

	if nick ~= nil and nick ~= "" then
		if utf8len(nick) > PageGenName.UserNameLimit then
			nick = utf8sub(nick, 1, PageGenName.UserNameLimit)
		end

		self.InputFieldName.text = nick
	end
end

function PageGenName:OnInputFieldChange(strP)
	local str = MxUtil.CutStringSpace(strP)
	local nameLength = utf8len(str)

	if nameLength > PageGenName.UserNameLimit then
		str = utf8sub(str, 1, PageGenName.UserNameLimit)
		self.Input_Name.text = str
	else
		self.Input_Name.text = str
	end
end

function PageGenName:OnClickedThinkBtn()
	SwitchToPage(self.PlayerCreate.PageTestResult)
end

function PageGenName:OnClickedButtonSign()
	local nickName = self.InputFieldName.text

	if nickName == nil or string.len(nickName) == 0 then
		UIMgr.ShowMsg(_("Msg_InputWordBefore"))

		return
	end

	local vals = {
		nickname = self.InputFieldName.text
	}

	NetManager:RequestModifyPlayerInfo(vals, function(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			GOUtil.InstantiateUIPrefab(self.PrefabAnim, self.UIRootObject)

			if self.callback then
				self:RequestGetPlayer()
			else
				SoundMgr.PostEvent("Play_SE_020_0042", self.UIRootObject)
				TimerMgr.AddTimer(eTimerType.RealTime, 2, function()
					ScenarioKit.Instance.UI.DialogPanel.gameObject:SetActive(true)
					ScenarioKit.Instance.UI.DialogPanel:OnClickDialog()
					self:Close()

					if self.cb then
						self.cb()
					end
				end, {
					1
				})
			end
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageGenName:RequestGetPlayer()
	local function wrap_cb(...)
		self:OnGetPlayerInfo(...)
	end

	NetManager:RequestGetPlayerInfo(wrap_cb)
end

function PageGenName:OnGetPlayerInfo(vPBMessage)
	local code = vPBMessage.result.code

	if code == NetManager.Result_Sucess or code == 2 then
		self.callback()
	else
		print("OnGetPlayerInfo err: " .. vPBMessage.result.desc)
	end
end

function PageGenName:OnBackAndroid()
	self:OnClickedButtonSign()

	return true
end
