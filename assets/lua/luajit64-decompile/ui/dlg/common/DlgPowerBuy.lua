-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgPowerBuy.lua

DlgPowerBuy = class("DlgPowerBuy", UIPanel)

function DlgPowerBuy:ctor()
	self.UIPrefabPath = "UI/Common/DlgPowerBuy/DlgPowerBuy"
	self.cb = nil
	self.payLaw = DlgPayLaw()

	self:AddChildPanel(self.payLaw)
end

function DlgPowerBuy:Purge()
	self.base.Purge(self)

	self.cb = nil
end

function DlgPowerBuy:OnRegisterEvent()
	self:AddClick(self.BtnBuy, self.OnClickedBtnBuy)
	self:AddClick(self.BtnQuit, self.OnClickedBtnQuit)
	Event.Instance:Add("UpdatePowerBuyTimes", self.UpdatePanel, self)
end

function DlgPowerBuy:OnUnRegisterEvent()
	self:RemoveClick(self.BtnBuy, self.OnClickedBtnBuy)
	self:RemoveClick(self.BtnQuit, self.OnClickedBtnQuit)
	Event.Instance:Remove("UpdatePowerBuyTimes", self.UpdatePanel, self)
end

function DlgPowerBuy:OnEnter(vParam)
	self:DealWithLocalization()

	self.TxtChange = self:GetChildComponent("Panel/GoEnough/Text", "Text")
	self.TxtChange.text = _("Desc_Power_Change_After_Buy")
	self.TxtRefreshTime = self:GetChildComponent("Panel/TxtRefresh", "Text")
	self.TxtRefreshTime.text = "※" .. string.format(_("Desc_Refresh_Time_Which_Day"), tostring(InfoGameInst.RefreshTime))
	self.TxtCost = self:GetChildComponent("Panel/TxtCost", "Text")
	self.TxtBuyNum = self:GetChildComponent("Panel/TxtNum", "Text")
	self.GoEnough = self:GetChildGameObject("Panel/GoEnough")
	self.GoLess = self:GetChildGameObject("Panel/GoLess")
	self.BtnBuy = self:GetChildGameObject("Panel/BtnBuy")
	self.BtnQuit = self:GetChildGameObject("Panel/BtnQuit")

	self:Init(vParam)
end

function DlgPowerBuy:DealWithLocalization()
	local txt = self:GetChildComponent("Panel/Title/Text", "Text")

	txt.text = _("Desc_Power_Buy")
	txt = self:GetChildComponent("Panel/BtnBuy/Text", "Text")
	txt.text = _("UI_Buy")
end

function DlgPowerBuy:Init(vParam)
	if vParam then
		self.cb = vParam.cb
	end

	self:UpdatePanel()
	GOUtil.SetTransformLocalPosition(self.TxtBuyNum.gameObject, 310, -210, 0)
	self.payLaw:Show(0, -110)
end

function DlgPowerBuy:UpdatePanel()
	local times = InfoGameInst:GetPowerBoughtTimes()
	local leftTimes = InfoGameInst.maxPowerBuyTimesDay - times

	self.TxtBuyNum.text = string.format(_("Desc_Buy_Times_Today"), leftTimes .. "/" .. InfoGameInst.maxPowerBuyTimesDay)

	local isCanBuy = leftTimes > 0

	self.data = nil

	if isCanBuy then
		local list = GetConfigArgJson("PowerBuyCost")
		local num = 0

		for _, v in ipairs(list) do
			num = num + v[3]

			if num <= InfoGameInst.maxPowerBuyTimesDay and times < num then
				self.data = v

				break
			end
		end
	end

	GOUtil.SetActive(self.GoEnough, isCanBuy)
	GOUtil.SetActive(self.GoLess, not isCanBuy)
	GOUtil.SetActive(self.BtnBuy, isCanBuy)
	GOUtil.SetActive(self.TxtCost, isCanBuy)
	GOUtil.SetActive(self.TxtRefreshTime, not isCanBuy)

	local color

	if isCanBuy then
		color = getColorFromString("585E62", 1)

		if self.data then
			self.TxtCost.text = string.format(_("Desc_Prompt_Buy_Power"), GetEmojiIdByType("P_DIAMOND"), self.data[1], self.data[2])
		end

		self:InitEnough()
	else
		color = getColorFromString("FF0000", 1)

		self:InitLess()
	end

	UIUtil.SetGraphicColorRGBA(self.TxtBuyNum, color.r, color.g, color.b, color.a)
end

function DlgPowerBuy:InitEnough()
	local hold = PlayerInst:GetPower()
	local txt1 = self:GetChildComponent("Panel/GoEnough/1/Text", "Text")

	txt1.text = hold

	local txt2 = self:GetChildComponent("Panel/GoEnough/2/Text", "Text")

	txt2.text = hold + (self.data[2] or 0)
end

function DlgPowerBuy:InitLess()
	local txt = self:GetChildComponent("Panel/GoLess/Text", "Text")

	txt.text = PlayerInst:GetPower()
end

function DlgPowerBuy:OnClickedBtnBuy()
	local function callback(index)
		if index == DlgCommonEvent.ButtonType.Ok then
			local function wrap_cb(vMsg)
				LoadingMgr.Hide(eLoadingType.Repeat)

				if vMsg.result.code == NetManager.Result_Sucess then
					SoundMgr.Play(PATH_SFX_UI_SHOP_BUYSUCCESS)

					if SetterData.haveOverItem then
						SetterData.haveOverItem = false

						UIMgr.ShowMsg(_("Msg_OverItem_Common"))
					else
						Event.Instance:Fire(EventEnum.UpdatePlayerInfo)
						UIMgr.ShowMsg(_("BuyPower_success"))
					end

					if self.cb then
						self.cb()

						self.cb = nil
					end

					self:Close()
				else
					UIMgr.ShowMsg(vMsg.result.desc, vMsg)
				end
			end

			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:RequestBuyPower(1, wrap_cb)
		end
	end

	if PlayerInst:GetDiamondAll() >= self.data[1] then
		callback(DlgCommonEvent.ButtonType.Ok)
	else
		ReplaceDiamond(self.data[1], callback)
	end
end

function DlgPowerBuy:OnClickedBtnQuit()
	self:Close()
end
