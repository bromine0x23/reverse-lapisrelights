-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageShop/DlgBuyLeftStageNum.lua

DlgBuyLeftStageNum = class("DlgBuyLeftStageNum", UIPanel)

function DlgBuyLeftStageNum:ctor()
	self.UIPrefabPath = "UI/PageShop/DlgBuyLeftStageNum"
	self.payLaw = DlgPayLaw()

	self:AddChildPanel(self.payLaw)
end

function DlgBuyLeftStageNum:PreLoad()
	self.PrefabCell = ResourceMgr.LoadSync("UI/Item/CellItem")
end

function DlgBuyLeftStageNum:Purge()
	DlgBuyLeftStageNum.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	if self.PrefabCell then
		ResourceMgr.Unload(self.PrefabCell)

		self.PrefabCell = nil
	end
end

function DlgBuyLeftStageNum:OnRegisterEvent()
	self:AddClick(self.ButtonImgMin.gameObject, self.OnClickedButtonImgMin, PATH_SFX_UI_CANCEL)
	self:AddClick(self.ButtonImgMax.gameObject, self.OnClickedButtonImgMax, PATH_SFX_UI_CANCEL)
	self:AddClick(self.ButtonImgUp.gameObject, self.OnClickedButtonImgUp, PATH_SFX_UI_CANCEL)
	self:AddClick(self.ButtonBuy.gameObject, self.OnClickedButtonBuy, PATH_SFX_UI_CANCEL)
	self:AddClick(self.ButtonExit.gameObject, self.OnClickedButtonExit, PATH_SFX_UI_CANCEL)
end

function DlgBuyLeftStageNum:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonImgMin.gameObject, self.OnClickedButtonImgMin)
	self:RemoveClick(self.ButtonImgMax.gameObject, self.OnClickedButtonImgMax)
	self:RemoveClick(self.ButtonImgUp.gameObject, self.OnClickedButtonImgUp)
	self:RemoveClick(self.ButtonBuy.gameObject, self.OnClickedButtonBuy)
	self:RemoveClick(self.ButtonExit.gameObject, self.OnClickedButtonExit, PATH_SFX_UI_CANCEL)
end

function DlgBuyLeftStageNum:OnEnter(vParam)
	self.addLeftNumType = vParam.addLeftNumType
	self.tex_tips = self:GetChildComponent("Main/tex_tips", "Text")
	self.TextNum = self:GetChildComponent("Main/Panel/Info3/InputField/Text", "Text")
	self.TextCost = self:GetChildComponent("Main/TextCost", "Text")

	local Text = self:GetChildComponent("Main/Text", "Text")

	Text.text = _("UI_Dlg_Buy")
	Text = self:GetChildComponent("Main/TextCost/Text", "Text")
	Text.text = _("Desc_Need")
	Text = self:GetChildComponent("Main/Button/Text", "Text")
	Text.text = _("UI_LeftStage_Buy")
	Text = self:GetChildComponent("Main/Panel/Info3/ButtonUp/Text", "Text")
	Text.text = _("Desc_Max")
	self.ButtonImgMin = self:GetChildComponent("Main/Panel/Info3/Button1", "Image")
	self.ButtonImgMax = self:GetChildComponent("Main/Panel/Info3/Button2", "Image")
	self.ButtonImgUp = self:GetChildComponent("Main/Panel/Info3/ButtonUp", "Image")
	self.ButtonBuy = self:GetChildComponent("Main/Button", "Button")
	self.ButtonExit = self:GetChildGameObject("Main/ButtonExit")
	self.maxNum = InfoGameInst:GetChapterTimesList()[self.addLeftNumType].buyTimes
	self.TextNumValue = 0
	self.needcostValue = 0

	self:GetMaxLeftNum()
	self:ChangeNum()
	self:SetLeftData()
	self.payLaw:Show(0, -110, self:GetChildGameObject("Main"))

	local tbg = self.TextCost.gameObject

	GOUtil.SetTransformLocalPosition(tbg, tbg.transform.localPosition.x, tbg.transform.localPosition.y + 40, 0)

	tbg = self:GetChildGameObject("Main/cost_bg")

	GOUtil.SetTransformLocalPosition(tbg, tbg.transform.localPosition.x, tbg.transform.localPosition.y + 40, 0)

	tbg = self:GetChildGameObject("Main/Panel")

	GOUtil.SetTransformLocalPosition(tbg, tbg.transform.localPosition.x, tbg.transform.localPosition.y + 40, 0)
end

function DlgBuyLeftStageNum:OnClickedButtonExit()
	self:Close()
end

function DlgBuyLeftStageNum:OnClickedButtonImgMin()
	self.TextNumValue = self.TextNumValue - 1

	if self.TextNumValue < 0 then
		self.TextNumValue = 0
	end

	self.TextNum.text = self.TextNumValue .. ""

	self:ChangeNum()
	self:SetLeftData()
end

function DlgBuyLeftStageNum:OnClickedButtonImgMax()
	self:GetMaxLeftNum()

	self.TextNumValue = self.TextNumValue + 1

	if self.TextNumValue > self.maxNum then
		self.TextNumValue = self.maxNum
	end

	if self.TextNumValue < 0 then
		self.TextNumValue = 0
	end

	self.TextNum.text = self.TextNumValue .. ""

	self:ChangeNum()
	self:SetLeftData()
end

function DlgBuyLeftStageNum:OnClickedButtonImgUp()
	self:GetMaxLeftNum()

	self.TextNumValue = self.maxNum

	if self.TextNumValue < 0 then
		self.TextNumValue = 0
	end

	self.TextNum.text = self.TextNumValue .. ""

	self:ChangeNum()
	self:SetLeftData()
end

function DlgBuyLeftStageNum:SetLeftData()
	local sumCount = self:GetMaxNum()

	self.tex_tips.text = _("Desc_BuyTimes") .. self.maxNum - self.TextNumValue .. "/" .. sumCount
	self.TextNum.text = self.TextNumValue
	self.TextCost.text = self.needcostValue

	if self.TextNumValue ~= self.maxNum then
		self.tex_tips.color = Color.New(0.34509803921568627, 0.3686274509803922, 0.3843137254901961, 1)
	else
		self.tex_tips.color = Color.New(1, 0, 0, 1)
	end

	if PlayerInst:GetDiamondAll() < self.needcostValue then
		self.TextCost.color = Color.red
	else
		self.TextCost.color = Color.white
	end

	local gray = TenaryOp(self.TextNumValue == 0, 1, 0)

	DealWithListRef(self, UIUtil.SetImageGray(self.ButtonImgMin, gray))

	gray = TenaryOp(self.TextNumValue == self.maxNum, 1, 0)

	DealWithListRef(self, UIUtil.SetImageGray(self.ButtonImgMax, gray))
	DealWithListRef(self, UIUtil.SetImageGray(self.ButtonImgUp, gray))
end

function DlgBuyLeftStageNum:GetMaxLeftNum()
	local sumCount, count = self:GetMaxNum()

	self.maxNum = sumCount - count
end

function DlgBuyLeftStageNum:GetMaxNum()
	return ChapterMgr.GetTimes(self.addLeftNumType, ShopManager.MonthPrivilegeFunc.Func20)
end

function DlgBuyLeftStageNum:ChangeNum()
	local sumCount, count = self:GetMaxNum()
	local costList = {}

	if self.addLeftNumType == ePassChallengeBuyType.Gold then
		costList = GetConfigArgJson("GoldStageDailyNumBuyCost")
	else
		costList = GetConfigArgJson("ResourceDailyNumBuyCost")
	end

	if sumCount <= count then
		return
	end

	self.needcostValue = 0

	for n = 1, self.TextNumValue do
		for i = 1, #costList do
			if costList[i][1] <= count + n and costList[i + 1] and costList[i + 1][1] > count + n then
				needcost = costList[i][3]
				self.needcostValue = self.needcostValue + costList[i][3]

				break
			elseif not costList[i + 1] then
				self.needcostValue = self.needcostValue + costList[i][3]

				break
			end
		end
	end

	self.TextCost.text = self.needcostValue
end

function DlgBuyLeftStageNum:OnClickedButtonBuy()
	if self.maxNum == 0 then
		UIMgr.ShowMsg(_("Desc_NoBuyTimes"))

		return
	end

	if PlayerInst:GetDiamondAll() < self.needcostValue then
		UIMgr.ShowMsg(_("Desc_DrawCardNotEnoughRes"))

		return
	end

	if self.TextNumValue == 0 then
		UIMgr.ShowMsg(_("Buy_Battle_Count_ResourceStage"))

		return
	end

	local function wrap_cb(pb)
		LoadingMgr.Hide(eLoadingType.Repeat, 42)

		if pb.result.code == NetManager.Result_Sucess then
			InfoGameInst:SetChapterTimesList(self.addLeftNumType, self.TextNumValue)
			Event.Instance:Fire(EventEnum.UpdateStage, true)

			self.TextNumValue = 0

			self:GetMaxLeftNum()
			self:ChangeNum()
			self:SetLeftData()
			self:Close()
			UIMgr.ShowMsg(_("BuyStageNum_success"))
		else
			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestAddStageTypeNum(self.addLeftNumType, self.TextNumValue, wrap_cb)
end
