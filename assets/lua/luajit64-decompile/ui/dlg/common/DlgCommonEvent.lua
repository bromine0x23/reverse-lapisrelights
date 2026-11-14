-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgCommonEvent.lua

require("UI/UIPanel")
require("UI/Dlg/Public/DlgPayLaw")

DlgCommonEvent = class("DlgCommonEvent", UIPanel)
DlgCommonEvent.ButtonType = {
	Ok = 1,
	Close = 3,
	Mask = 0,
	Cancel = 2,
	OkNoMoreTips = 4
}
DlgCommonEvent.Type = {
	TipsAndItem = 12,
	Del = 4,
	Large = 99,
	MsgStory = 9,
	Confirm = 2,
	GameOver = 35,
	Msg2 = 3,
	Expla = 6,
	DiamondBuyTips = 100,
	TodayNoMoreTipsCardShop = 10,
	MsgWithAlert = 8,
	Buy2 = 11,
	TodayNoMoreTips = 7,
	NotPromptToday = 15,
	Loading = 5,
	Msg = 0,
	NotPromptNextTime = 13,
	Buy = 1,
	MsgFuncForbid = 14
}
DlgCommonEvent.CallBack = nil
DlgCommonEvent.Label_Title = nil
DlgCommonEvent.Button_OK = nil
DlgCommonEvent.Button_Cancel = nil

function DlgCommonEvent:ctor()
	self.UIPrefabPath = "UI/Common/DlgCommon/DlgCommon"
	self.isSyncLoad = true
	self.payLaw = DlgPayLaw()

	self:AddChildPanel(self.payLaw)
end

function DlgCommonEvent:Purge()
	self.base.Purge(self)
end

function DlgCommonEvent:OnEnter(vParam)
	self.Panel_Main = self:GetChildGameObject("TweenRoot/Main")
	self.Panel_Second = self:GetChildGameObject("TweenRoot/SecondBig")
	self.PanelTitle = self:GetChildGameObject("TweenRoot/Main/bg_title")
	self.Label_Title = self:GetChildComponent("TweenRoot/Main/bg_title/Text", "Text")
	self.PanelTitle2 = self:GetChildGameObject("TweenRoot/Main/bg_title2")
	self.Label_Title2 = self:GetChildComponent("TweenRoot/Main/bg_title2/Text", "Text")
	self.PanelMsg = self:GetChildGameObject("TweenRoot/Main/PanelMsg")
	self.Label_Message = self:GetChildComponent("TweenRoot/Main/PanelMsg/Text1", "Text")

	local textCost = self:GetChildComponent("TweenRoot/Main/PanelBuy/GoNeed/Text1", "Text")

	textCost.text = _("Desc_CostOrNot")
	self.PanelBuy = self:GetChildGameObject("TweenRoot/Main/PanelBuy")
	self.PanelBuyCardShop = self:GetChildGameObject("TweenRoot/Main/PanelBuyCardShop")
	self.ImageIcon = self:GetChildComponent("TweenRoot/Main/PanelBuy/GoNeed/Image1", "Image")
	self.TextNum = self:GetChildComponent("TweenRoot/Main/PanelBuy/GoNeed/TextNum", "Text")
	self.TextProductName = self:GetChildComponent("TweenRoot/Main/PanelBuy/GoNeed/Text2", "Text")
	self.ImageResIcon = self:GetChildComponent("TweenRoot/Main/PanelBuy/GoHave/Image1", "Image")
	self.TextResNum = self:GetChildComponent("TweenRoot/Main/PanelBuy/GoHave/TextNum", "Text")
	self.GoHave = self:GetChildGameObject("TweenRoot/Main/PanelBuy/GoHave")
	self.PanelBuy2 = self:GetChildGameObject("TweenRoot/Main/PanelBuy2")
	self.TextBuy = self:GetChildComponent("TweenRoot/Main/PanelBuy2/Text", "Text")
	self.TextBuyTip = self:GetChildComponent("TweenRoot/Main/PanelBuy2/TextTip", "Text")
	self.PanelMsg2 = self:GetChildGameObject("TweenRoot/Main/PanelMsg2")
	self.Label_Message2 = self:GetChildComponent("TweenRoot/Main/PanelMsg2/Text1", "TextView")
	self.PanelMsg3 = self:GetChildGameObject("TweenRoot/Main/PanelMsg3")
	self.Label_Message3 = self:GetChildComponent("TweenRoot/Main/PanelMsg3/Text1", "Text")
	self.PanelMsg4 = self:GetChildGameObject("TweenRoot/Main/PanelMsg4")
	self.Label_Message4m = self:GetChildComponent("TweenRoot/Main/PanelMsg4/Text1", "Text")
	self.Label_Message4r = self:GetChildComponent("TweenRoot/Main/PanelMsg4/Text2", "Text")
	self.PanelMsg5 = self:GetChildGameObject("TweenRoot/Main/PanelMsg5")
	self.Label_Message5 = self:GetChildComponent("TweenRoot/Main/PanelMsg5/Text1", "Text")
	self.PanelMsgStory = self:GetChildGameObject("TweenRoot/Main/PanelMsgStory")
	self.Label_MessageStory = self:GetChildComponent("TweenRoot/Main/PanelMsgStory/Text1", "TextView")
	self.StoryAward = self:GetChildGameObject("TweenRoot/Main/PanelMsgStory/StoryAward")
	self.StoryText1 = self:GetChildComponent("TweenRoot/Main/PanelMsgStory/StoryAward/Text1", "Text")
	self.StoryText2 = self:GetChildComponent("TweenRoot/Main/PanelMsgStory/StoryAward/Text2", "Text")
	self.StoryText1.text = _("Msg_StoryText1")
	self.StoryText2.text = _("Msg_StoryText2")
	self.Button_Cancel = self:GetChildGameObject("TweenRoot/Main/Grid/Button_Cancel")
	self.Button_OK = self:GetChildGameObject("TweenRoot/Main/Grid/Button_OK")
	self.Label_Cancel = self:GetChildComponent("TweenRoot/Main/Grid/Button_Cancel/Label_Cancel", "Text")
	self.Label_OK = self:GetChildComponent("TweenRoot/Main/Grid/Button_OK/Label_OK", "Text")
	self.ButtonQuit = self:GetChildGameObject("TweenRoot/Main/Button")
	self.Button_OK.name = 1
	self.Button_Cancel.name = 2
	self.ButtonQuit.name = 3
	self.Button_Out = self:GetChildGameObject("TweenRoot/Main/Grid/Button_Out")
	self.Button_Main = self:GetChildGameObject("TweenRoot/Main/Grid/Button_Main")
	self.Label_Out = self:GetChildComponent("TweenRoot/Main/Grid/Button_Out/Label", "Text")
	self.Label_Main = self:GetChildComponent("TweenRoot/Main/Grid/Button_Main/Label", "Text")
	self.Button_Out.name = 4
	self.Button_Main.name = 5
	self.PanelTip = self:GetChildGameObject("TweenRoot/Main/PanelTip")
	self.Toggle = self:GetChildComponent("TweenRoot/Main/PanelTip/Toggle", "Toggle")
	self.ToggleText = self:GetChildComponent("TweenRoot/Main/PanelTip/Text", "Text")
	self.ToggleText.text = _("Desc_NoMoreTips")
	self.Button_OK_Large = self:GetChildGameObject("TweenRoot/SecondBig/Grid/Button_OK")
	self.Button_Cancel_Large = self:GetChildGameObject("TweenRoot/SecondBig/Grid/Button_Cancel")
	self.Large_PanelMsg2 = self:GetChildGameObject("TweenRoot/SecondBig/PanelMsg2")
	self.Label_OK_Large = self:GetChildComponent("TweenRoot/SecondBig/Grid/Button_OK/Label_OK", "Text")
	self.Label_Cancel_Large = self:GetChildComponent("TweenRoot/SecondBig/Grid/Button_Cancel/Label_Cancel", "Text")
	self.Large_Label_Message2 = self:GetChildComponent("TweenRoot/SecondBig/PanelMsg2/Text1", "TextView")
	self.Large_Label_Message2_Left = self:GetChildComponent("TweenRoot/SecondBig/PanelMsg2/Text2", "TextView")
	self.Large_Title = self:GetChildComponent("TweenRoot/SecondBig/bg_title/Text", "Text")
	self.ButtonQuitLarge = self:GetChildGameObject("TweenRoot/SecondBig/Button")
	self.Button_OK_Large.name = 1
	self.Button_Cancel_Large.name = 2
	self.ButtonQuitLarge.name = 3

	self:Show(unpack(vParam))

	if self.preClose then
		self:Close()
	end
end

function DlgCommonEvent:OnRegisterEvent()
	self:AddClick(self.ButtonQuit, self.OnButtonQuit)
	self:AddClick(self.Button_OK, self.OnButtonClick)
	self:AddClick(self.Button_Cancel, self.OnButtonClick)
	self:AddClick(self.Button_Out, self.OnButtonClick)
	self:AddClick(self.Button_Main, self.OnButtonClick)
	self:AddClick(self.Button_OK_Large, self.OnButtonClick)
	self:AddClick(self.Button_Cancel_Large, self.OnButtonClick)
	self:AddClick(self.ButtonQuitLarge, self.OnButtonQuit)
end

function DlgCommonEvent:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonQuit, self.OnButtonQuit)
	self:RemoveClick(self.Button_OK, self.OnButtonClick)
	self:RemoveClick(self.Button_Cancel, self.OnButtonClick)
	self:RemoveClick(self.Button_Out, self.OnButtonClick)
	self:RemoveClick(self.Button_Main, self.OnButtonClick)
	self:RemoveClick(self.Button_OK_Large, self.OnButtonClick)
	self:RemoveClick(self.Button_Cancel_Large, self.OnButtonClick)
	self:RemoveClick(self.ButtonQuitLarge, self.OnButtonQuit)

	if self.dlgType == DlgCommonEvent.Type.GameOver then
		Event.Instance:Remove("EVENT_CLOSE_DLG_COOMN", self.OnGameOver, self)
	end
end

function DlgCommonEvent:OnGameOver()
	if self.dlgType == DlgCommonEvent.Type.GameOver then
		self:Close()
	end
end

function DlgCommonEvent:OnButtonQuit()
	SoundMgr.Play(PATH_SFX_UI_CANCEL)

	if self.CallBack ~= nil then
		self.CallBack(DlgCommonEvent.ButtonType.Close)

		self.CallBack = nil
	end

	self:Close()
end

function DlgCommonEvent:OnButtonClick(data)
	SoundMgr.Play(PATH_SFX_UI_CLICK)

	local go = data.pointerPress
	local index = tonumber(go.name)

	if self.CallBack ~= nil then
		if self.dlgType == DlgCommonEvent.Type.TodayNoMoreTips or self.dlgType == DlgCommonEvent.Type.TodayNoMoreTipsCardShop then
			if self.Toggle.isOn then
				index = DlgCommonEvent.ButtonType.OkNoMoreTips
			end
		elseif self.dlgType == DlgCommonEvent.Type.NotPromptNextTime then
			if index == DlgCommonEvent.ButtonType.Ok and self.Toggle.isOn then
				index = DlgCommonEvent.ButtonType.OkNoMoreTips
			end
		elseif self.dlgType == DlgCommonEvent.Type.NotPromptToday and index == DlgCommonEvent.ButtonType.Ok and self.Toggle.isOn then
			index = DlgCommonEvent.ButtonType.OkNoMoreTips
		end

		self:Close()
		self.CallBack(index)

		self.CallBack = nil
	else
		self:Close()
	end
end

function DlgCommonEvent:OnBackAndroid()
	local showBtnOk = GOUtil.IsActiveSelf(self.Button_OK) or GOUtil.IsActiveSelf(self.Button_OK_Large)
	local showBtnCancel = GOUtil.IsActiveSelf(self.Button_Cancel) or GOUtil.IsActiveSelf(self.Button_Cancel_Large)

	if showBtnOk and showBtnCancel or self.forceBack then
		if self.CallBack ~= nil then
			self.CallBack(DlgCommonEvent.ButtonType.Cancel)

			self.CallBack = nil
		end

		self:Close()
	else
		if self.CallBack ~= nil then
			self.CallBack(DlgCommonEvent.ButtonType.Ok)

			self.CallBack = nil
		end

		self:Close()
	end
end

function DlgCommonEvent:Show(_type, strTitle, _data, vCallBack, strOkText, strCancelText, needQuit, order, forceBack)
	self.forceBack = forceBack == true

	if order ~= nil then
		local canvas = self:GetChildComponent("", "Canvas")

		canvas.sortingOrder = order
	end

	self.dlgType = _type
	self.Label_Title.text = strTitle

	self.Panel_Second:SetActive(false)
	self.Panel_Main:SetActive(true)
	self.PanelTitle:SetActive(false)
	self.PanelTitle2:SetActive(false)
	self.PanelMsg:SetActive(false)
	self.PanelMsg2:SetActive(false)
	self.PanelMsg3:SetActive(false)
	self.PanelMsg4:SetActive(false)
	self.PanelMsg5:SetActive(false)
	self.PanelBuy:SetActive(false)
	self.PanelBuy2:SetActive(false)
	self.Button_Cancel:SetActive(false)
	self.PanelTip:SetActive(false)
	self.PanelBuyCardShop:SetActive(false)
	self.Button_Out:SetActive(false)
	self.Button_Main:SetActive(false)

	if _type == DlgCommonEvent.Type.Buy then
		self.PanelTitle:SetActive(true)
		self.PanelBuy:SetActive(true)
		self.GoHave:SetActive(false)

		if _data.icon then
			UIUtil.SetImageSprite(self.ImageIcon, _data.icon, self)
			UIUtil.SetImageSprite(self.ImageResIcon, _data.icon, self)
		end

		if _data.have then
			self.GoHave:SetActive(true)

			self.TextResNum.text = _data.have
		end

		self.TextNum.text = _data.need
		self.TextProductName.text = _("UI_Buy") .. " " .. _data.name
		self.Label_Title.text = _("UI_Buy")

		self.Button_OK:SetActive(true)
		self.Button_Cancel:SetActive(false)

		needQuit = true
	elseif _type == DlgCommonEvent.Type.Buy2 then
		self.PanelTitle:SetActive(true)
		self.PanelBuy2:SetActive(true)

		local item1Str = ""
		local item2Str = ""

		if _data.icon1Id then
			item1Str = GetItemEmojiStr(_data.icon1Id)
		end

		if _data.icon2Id then
			item2Str = GetItemEmojiStr(_data.icon2Id)
		end

		if _data.strAlert then
			self.TextBuyTip.gameObject:SetActive(true)

			self.TextBuyTip.text = _data.strAlert
		else
			self.TextBuyTip.gameObject:SetActive(false)
		end

		local desc = _data.txt

		desc = string.gsub(desc, "{num1}", _data.num1)
		desc = string.gsub(desc, "{num2}", _data.num2)
		desc = string.gsub(desc, "{item1}", item1Str)
		self.TextBuy.text = string.gsub(desc, "{item2}", item2Str)
		needQuit = true
	elseif _type == DlgCommonEvent.Type.Confirm then
		self.PanelMsg:SetActive(true)
		self.PanelTitle:SetActive(true)

		self.Label_Message.text = _data

		self.Button_OK:SetActive(true)
		self.Button_Cancel:SetActive(false)
	elseif _type == DlgCommonEvent.Type.Msg2 then
		self.PanelTitle2:SetActive(true)

		self.Label_Title2.text = strTitle
		self.Label_Message2.Text = _data

		self.PanelMsg2:SetActive(true)
		self.Button_OK:SetActive(true)

		needQuit = true
	elseif _type == DlgCommonEvent.Type.Del then
		self.PanelTitle:SetActive(true)
		self.PanelMsg:SetActive(true)

		self.Label_Title.text = strTitle
		self.Label_Message.text = _data

		self.Button_OK:SetActive(true)
	elseif _type == DlgCommonEvent.Type.Loading then
		self.PanelTitle:SetActive(true)
		self.PanelMsg:SetActive(true)

		self.Label_Title.text = strTitle
		self.Label_Message.text = _data

		self.Button_OK:SetActive(false)

		needQuit = true
	elseif _type == DlgCommonEvent.Type.Expla then
		self.PanelTitle:SetActive(true)
		self.PanelMsg3:SetActive(true)

		self.Label_Title.text = strTitle
		self.Label_Message3.text = _data

		self.Button_OK:SetActive(false)

		needQuit = true
	elseif _type == DlgCommonEvent.Type.Large then
		self.Panel_Main:SetActive(false)
		self.Panel_Second:SetActive(true)
		self.Large_PanelMsg2:SetActive(true)

		self.Large_Title.text = strTitle

		if type(_data) == "string" then
			self.Large_Label_Message2.Text = _data
		else
			GOUtil.SetActive(self.Large_Label_Message2.gameObject, false)
			GOUtil.SetActive(self.Large_Label_Message2_Left.gameObject, true)

			self.Large_Label_Message2_Left.Text = _data.text
		end
	elseif _type == DlgCommonEvent.Type.TodayNoMoreTips then
		self.PanelTitle:SetActive(true)
		self.PanelBuy2:SetActive(true)
		self.PanelTip:SetActive(true)

		needQuit = true

		if _data[2] then
			self.TextBuyTip.gameObject:SetActive(true)

			self.TextBuyTip.text = _data[2]

			GOUtil.SetRectTransformAnchoredPosition(self.PanelTip, 0, -40)
			GOUtil.SetRectTransformAnchoredPosition(self.TextBuyTip.gameObject, 0, 0)
			GOUtil.SetRectTransformAnchoredPosition(self.TextBuy.gameObject, -403, 60)
		else
			self.TextBuyTip.gameObject:SetActive(false)
			GOUtil.SetRectTransformAnchoredPosition(self.PanelTip, 0, -20)
			GOUtil.SetRectTransformAnchoredPosition(self.TextBuy.gameObject, -403, 40)
		end

		self.TextBuy.text = _data[1]

		self.Button_OK:SetActive(true)

		if _data[3] then
			self.payLaw:Show(0, 10)
			GOUtil.SetTransformLocalPosition(self.TextBuy.gameObject, self.TextBuy.gameObject.transform.localPosition.x, 70, 0)
			GOUtil.SetTransformLocalPosition(self.PanelTip, 0, -60, 0)
		end
	elseif _type == DlgCommonEvent.Type.TipsAndItem then
		self.PanelTitle:SetActive(true)
		self.PanelMsg:SetActive(true)
		self.PanelTip:SetActive(false)

		needQuit = true
		self.Label_Title.text = strTitle
		self.Label_Message.text = _data

		self.Button_OK:SetActive(true)
	elseif _type == DlgCommonEvent.Type.TodayNoMoreTipsCardShop then
		self.PanelTitle:SetActive(true)
		self.PanelBuyCardShop:SetActive(true)
		self.PanelTip:SetActive(false)

		local g = self.PanelBuyCardShop
		local Text1 = GOUtil.FindChildComponent(g, "Text1", "Text")

		if _data.txt then
			desc = _data.txt
		else
			local item1Str = ""

			desc = _("Desc_DrawCardDiamond")

			if _data.item1 then
				item1Str = GetItemEmojiStr(_data.item1)

				if _data.item1 and _data.item1 == 502 then
					if PlayerInst:GetDiamond() >= _data.num1 and PlayerInst:GetDiamondPay() > 0 then
						desc = _("Desc_DrawCardNoPayFirst")
					end

					self.payLaw:Show(0, 0)
					GOUtil.SetTransformLocalPosition(Text1.gameObject, Text1.transform.localPosition.x, 70, 0)
				end
			end

			desc = string.gsub(desc, "{num1}", _data.num1)
			desc = string.gsub(desc, "{num2}", _data.num2)
			desc = string.gsub(desc, "{item1}", item1Str)

			if _data.item2 then
				local item2Str = GetItemEmojiStr(_data.item2)

				desc = string.gsub(desc, "{item2}", item2Str)
			end
		end

		Text1.text = desc
		self.Label_Title.text = strTitle

		self.Button_OK:SetActive(true)
		self.Button_Cancel:SetActive(false)

		needQuit = true
	elseif _type == DlgCommonEvent.Type.DiamondBuyTips then
		self.PanelTitle:SetActive(true)
		self.PanelBuyCardShop:SetActive(true)

		local g = self.PanelBuyCardShop
		local Text1 = GOUtil.FindChildComponent(g, "Text1", "Text")
		local item1Str = ""

		desc = _("Desc_BuyItemsTipsKc")

		if _data.item1 then
			item1Str = GetItemEmojiStr(_data.item1)
		end

		desc = string.gsub(desc, "{num1}", _data.num1)
		desc = string.gsub(desc, "{item1}", item1Str)

		if _data.item2 then
			desc = string.gsub(desc, "{item2}", _data.item2)
		end

		Text1.text = desc
		self.Label_Title.text = strTitle

		self.Button_OK:SetActive(true)
		self.Button_Cancel:SetActive(true)

		if _data.isDiamond then
			self.payLaw:Show(0, -60)
			GOUtil.SetTransformLocalPosition(Text1.gameObject, Text1.gameObject.transform.localPosition.x, 35, 0)
		end

		needQuit = true
	elseif _type == DlgCommonEvent.Type.MsgWithAlert then
		needQuit = true

		self.PanelTitle:SetActive(true)
		self.PanelMsg4:SetActive(true)

		self.Label_Title.text = strTitle
		self.Label_Message4m.text = _data.content
		self.Label_Message4r.text = _data.alert

		self.Button_OK:SetActive(true)
	elseif _type == DlgCommonEvent.Type.MsgStory then
		self.PanelTitle2:SetActive(true)

		self.Label_Title2.text = strTitle
		self.Label_MessageStory.Text = _data.msg

		self.PanelMsgStory:SetActive(true)
		self.Button_OK:SetActive(true)
		SetActiveFunc(self.StoryAward, _data.needTip)
		UIUtil.ForceRebuildLayoutImmediate(self.StoryAward)
	elseif _type == DlgCommonEvent.Type.NotPromptNextTime then
		self.PanelTitle:SetActive(true)

		self.Label_Title.text = strTitle

		self.PanelMsg2:SetActive(true)
		self.Button_OK:SetActive(true)

		self.Label_Message2.Text = _data

		self.PanelTip:SetActive(true)

		self.Toggle.isOn = false
		self.ToggleText.text = _("Desc_Not_Prompt_Next_Time")
	elseif _type == DlgCommonEvent.Type.NotPromptToday then
		self.PanelTitle:SetActive(true)

		self.Label_Title.text = strTitle

		self.PanelMsg2:SetActive(true)
		self.Button_OK:SetActive(true)

		self.Label_Message2.Text = _data

		self.PanelTip:SetActive(true)

		self.Toggle.isOn = false
		self.ToggleText.text = _("Desc_ToDay_No_Tips")
	elseif _type == DlgCommonEvent.Type.MsgFuncForbid then
		self.PanelTitle:SetActive(true)

		self.Label_Title.text = strTitle

		self.PanelMsg5:SetActive(true)
		self.Button_OK:SetActive(false)
		self.Button_Out:SetActive(true)
		self.Button_Main:SetActive(true)

		self.Label_Message5.text = _data
		self.Label_Out.text = _("Label_Out")
		self.Label_Main.text = _("Label_Main")
	else
		if _type == DlgCommonEvent.Type.GameOver then
			Event.Instance:Add("EVENT_CLOSE_DLG_COOMN", self.OnGameOver, self)
		end

		self.PanelTitle:SetActive(true)

		self.Label_Title.text = strTitle

		self.PanelMsg:SetActive(true)
		self.Button_OK:SetActive(true)

		if type(_data) == "table" then
			if _data.isDiamond then
				self.payLaw:Show(0, -60)
				GOUtil.SetTransformLocalPosition(self.Label_Message.gameObject, 0, 35, 0)
			end

			self.Label_Message.text = _data.text
		else
			self.Label_Message.text = _data
		end
	end

	needQuit = needQuit == nil and true or needQuit

	if strOkText then
		self.Label_OK.text = strOkText
		self.Label_OK_Large.text = strOkText
	else
		self.Label_OK.text = _("UI_confirm")
		self.Label_OK_Large.text = _("UI_confirm")
	end

	if strCancelText then
		self.Label_Cancel.text = strCancelText

		self.Button_Cancel:SetActive(true)

		self.Label_Cancel_Large.text = strCancelText

		self.Button_Cancel_Large:SetActive(true)
	else
		self.Label_Cancel.text = _("Quite_Cancel")
		self.Label_Cancel_Large.text = _("Quite_Cancel")
	end

	self.ButtonQuit:SetActive(needQuit)

	self.CallBack = vCallBack
end
