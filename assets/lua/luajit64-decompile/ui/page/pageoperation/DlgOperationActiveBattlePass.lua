-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgOperationActiveBattlePass.lua

local OperationUIData = require("luaData/ActiveUiManage")

require("UI/Item/UIItemBase")
require("UI/Page/PageOperation/CellBattlePassAward")
require("UI/Page/PageOperation/CellBattlePassAwardNew")
require("Info/InfoTask")
require("UI/Page/PageTask/CellTask")

DlgOperationActiveBattlePass = class("DlgOperationActiveBattlePass", UIItemBase)

function DlgOperationActiveBattlePass:ctor()
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function DlgOperationActiveBattlePass:Purge()
	UIMgr.RemoveUpdatePanel(self)

	if self.UIScrollToolBattlePass1 then
		self.UIScrollToolBattlePass1:Purge()

		self.UIScrollToolBattlePass1 = nil
	end

	if self.UIScrollToolBattlePass2 then
		self.UIScrollToolBattlePass2:Purge()

		self.UIScrollToolBattlePass2 = nil
	end

	if self.UIScrollToolBattlePass3 then
		self.UIScrollToolBattlePass3:Purge()

		self.UIScrollToolBattlePass3 = nil
	end

	self:RemoveClick(self.active_Btn_Close, self.OnClickedBattlePassActiveClose)
	self:RemoveClick(self.active_Btn_Buy, self.OnClickedBattlePassActiveBuy)
	self:RemoveClick(self.btn_active, self.OnClickedBattlePassActive)
	Event.Instance:Remove(EventEnum.UpdateItemDataNotify, self.OnUpdataItem, self)
	Event.Instance:Remove("EventAnimBattlePassLevelStart", self.EventAnimBattlePassLevelStart, self)

	for i = 1, 2 do
		self:RemoveClick(self["BattlePassTab" .. i .. "Btn"], self.OnClickedBattlePassTab)
	end

	self:RemoveClick(self.Btn_battlePass, self.OnClickedBattlePass)
	Event.Instance:Remove("SaveBattlePass1ViewPos", self.SaveBattlePass1ViewPos, self)
	UnloadAllImageSprite(self)
	self.infoActive:ClearOperationSpine()
end

function DlgOperationActiveBattlePass:OnRegisterEvent()
	return
end

function DlgOperationActiveBattlePass:OnUnRegisterEvent()
	return
end

function DlgOperationActiveBattlePass:OnEnter(vParam)
	local g = self.UIRootObject

	UIMgr.SetUpdatePanel(self)

	self.PrefabCellBattlePass1 = vParam.PrefabCell
	self.PrefabCell = vParam.PrefabTaskCell
	self.BG_active = GOUtil.FindChildGameObject(g, "Panel/BG_active")
	self.active_Btn_Close = GOUtil.FindChildGameObject(g, "Panel/BG_active/bg/btn_close")

	self:AddClick(self.active_Btn_Close, self.OnClickedBattlePassActiveClose)

	self.active_Btn_Buy = GOUtil.FindChildGameObject(g, "Panel/BG_active/bg/btn_buy")

	self:AddClick(self.active_Btn_Buy, self.OnClickedBattlePassActiveBuy)

	self.btn_active = GOUtil.FindChildGameObject(g, "Panel/TabPanel/panel1/BgAward/btn_active")

	self:AddClick(self.btn_active, self.OnClickedBattlePassActive)

	local GoodsId, State = OperationActiveMgr:GetBattlePassMonthIdState()

	SetActiveFunc(self.btn_active, not State and not NoPay)

	self.BgAward2unlock = GOUtil.FindChildGameObject(g, "Panel/TabPanel/panel1/BgAward/Image/unlock")
	self.tex_grade = GOUtil.FindChildComponent(g, "Panel/leveltitle/tex_grade", "Text")

	for i = 1, 2 do
		self["BattlePassTab" .. i .. "Btn"] = GOUtil.FindChildGameObject(g, "Panel/Tab/Tab" .. i .. "/Btn")

		self:AddClick(self["BattlePassTab" .. i .. "Btn"], self.OnClickedBattlePassTab)

		self["BattlePassTab" .. i .. "Sel"] = GOUtil.FindChildGameObject(g, "Panel/Tab/Tab" .. i .. "/Sel")
		self["BattlePassTab" .. i .. "Dot"] = GOUtil.FindChildGameObject(g, "Panel/Tab/Tab" .. i .. "/Dot")
		self["BattlePassTab" .. i .. "Text"] = GOUtil.FindChildGameObject(g, "Panel/Tab/Tab" .. i .. "/Text")
		self["BattlePassTab" .. i .. "Panel"] = GOUtil.FindChildGameObject(g, "Panel/TabPanel/panel" .. i)
	end

	self.endTimeTex = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Text", "Text")

	local textTitle2 = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Text2", "Text")

	textTitle2.text = _("Alphatext")
	self.Btn_battlePass = GOUtil.FindChildGameObject(g, "Panel/Btn_battlePass")
	self.Img_battlePass = GOUtil.FindChildComponent(g, "Panel/Btn_battlePass", "Image")
	self.Fx_UI_009_2 = GOUtil.FindChildGameObject(g, "Panel/Btn_battlePass/Fx_UI_009_2")

	self:AddClick(self.Btn_battlePass, self.OnClickedBattlePass)
	Event.Instance:Add("SaveBattlePass1ViewPos", self.SaveBattlePass1ViewPos, self)

	self.FX_UI_Activity = GOUtil.FindChildGameObject(g, "Panel/FX_UI_Activity")

	GOUtil.SetGameObjectLayer(self.FX_UI_Activity, LayerMask.NameToLayer("RT"))

	self.img_buy2 = GOUtil.FindChildComponent(g, "Panel/BG_active/bg/btn_buy/img_buy2", "Image")
	self.tex_buy2 = GOUtil.FindChildComponent(g, "Panel/BG_active/bg/btn_buy/tex_buy2", "Text")
	self.tex_buy = GOUtil.FindChildComponent(g, "Panel/BG_active/bg/btn_buy/tex_buy", "Text")
	self.tex_level = GOUtil.FindChildComponent(self.UIRootObject, "Panel/leveltitle/tex_level", "Text")
	self.tex_complete = GOUtil.FindChildComponent(self.UIRootObject, "Panel/TabPanel/panel2/Text", "Text")
	self.AnimRoot = GOUtil.GetComponent(self.tex_level.gameObject, "Animator")

	Event.Instance:Add(EventEnum.UpdateItemDataNotify, self.OnUpdataItem, self)
	EventListenerMgr.AddAnimListener(self.tex_level.gameObject, self.EventAnim, self, eAnimEventType.OnAnimationEnd)
	Event.Instance:Add("EventAnimBattlePassLevelStart", self.EventAnimBattlePassLevelStart, self)
end

function DlgOperationActiveBattlePass:DealWithLocalization(ActiveID)
	self.infoActive:SetOperationUIModel(ActiveID, self.BGRaw, self.UIRootObject)

	if self.infoActive.data.UIType == eOperationActive.BattlePass2 then
		local ui

		for k, v in pairsByKeys(OperationUIData) do
			if v.ActiveID == ActiveID then
				ui = v

				break
			end
		end

		self.infoActive:SetOperationBg(ActiveID, self.BGRaw, self.UIRootObject)

		local ImageTitle = self:GetChildComponent("Panel/ImgTitle", "Image")
		local Icon0 = self:GetChildComponent("Panel/TabPanel/panel1/BgAward/Image0", "Image")
		local Icon1 = self:GetChildComponent("Panel/TabPanel/panel1/BgAward/Image", "Image")
		local Popup = self:GetChildComponent("Panel/BG_active/bg", "RawImage")
		local ButtonBuy = self:GetChildComponent("Panel/BG_active/bg/btn_buy", "Image")

		UIUtil.SetRawImageTexture(Popup, ui.SpineStatic[2][1], self)

		if ui.SpineStatic[2][3] and ui.SpineStatic[2][4] then
			GOUtil.SetRectTransformAnchoredPosition(Popup.gameObject, ui.SpineStatic[2][3], ui.SpineStatic[2][4])
		end

		UIUtil.SetImageSprite(ImageTitle, ui.SpineStatic[1][1], self)

		if ui.SpineStatic[1][3] and ui.SpineStatic[1][4] then
			GOUtil.SetRectTransformAnchoredPosition(ImageTitle.gameObject, ui.SpineStatic[1][3], ui.SpineStatic[1][4])
		end

		UIUtil.SetImageSprite(Icon0, ui.Pic[1][1], self)

		if ui.Pic[1][3] and ui.Pic[1][4] then
			GOUtil.SetRectTransformAnchoredPosition(Icon0.gameObject, ui.Pic[1][3], ui.Pic[1][4])
		end

		UIUtil.SetImageSprite(Icon1, ui.Pic[2][1], self)

		if ui.Pic[2][3] and ui.Pic[2][4] then
			GOUtil.SetRectTransformAnchoredPosition(Icon1.gameObject, ui.Pic[2][3], ui.Pic[2][4])
		end

		if ui.Pic[3] and ui.Pic[3][1] ~= "" then
			UIUtil.SetImageSprite(ButtonBuy, ui.Pic[3][1], self)
		end

		if ui.Pic[3] and ui.Pic[3][3] and ui.Pic[3][4] then
			GOUtil.SetRectTransformAnchoredPosition(ButtonBuy.gameObject, ui.Pic[3][3], ui.Pic[3][4])
		end

		ImageTitle:SetNativeSize()
		Icon0:SetNativeSize()
		Icon1:SetNativeSize()

		if #ui.Text > 0 then
			if ui.Text[1] and #ui.Text[1] > 0 then
				self.oriText = Lang(ui.Text[1][1])

				if ui.Text[1][3] and ui.Text[1][4] then
					GOUtil.SetRectTransformAnchoredPosition(self.endTimeTex.gameObject, ui.Text[1][3], ui.Text[1][4])
				end

				if ui.Text[1][5] then
					local distance = 1

					if ui.Text[1][6] then
						distance = ui.Text[1][6]
					end

					GOUtil.SetOutLineColor(self.endTimeTex.gameObject, ui.Text[1][5], distance)
				end
			end

			if ui.Text[2] and #ui.Text[2] > 0 then
				self.oriLv = Lang(ui.Text[2][1])

				if ui.Text[2][3] and ui.Text[2][4] then
					GOUtil.SetRectTransformAnchoredPosition(self.tex_level.gameObject, ui.Text[2][3], ui.Text[2][4])
				end

				if ui.Text[2][5] then
					local distance = 1

					if ui.Text[2][6] then
						distance = ui.Text[2][6]
					end

					GOUtil.SetOutLineColor(self.tex_level.gameObject, ui.Text[2][5], distance)
				end
			end
		end

		if self.oriLv then
			self.tex_level.text = string.format(self.oriLv, BattlePassTaskMgr:GetBattlePassLevel())
		else
			self.tex_level.text = _("eSortType_2") .. BattlePassTaskMgr:GetBattlePassLevel()
		end
	else
		InfoOperationActive:SetOperationUIModel(ActiveID, self.BGRaw, self.UIRootObject)
	end
end

function DlgOperationActiveBattlePass:Init(infoActive, BGRaw)
	self.infoActiveID = infoActive.id
	self.infoActive = infoActive
	self.BGRaw = BGRaw
	self.listBattlePassAward = OperationActiveMgr:GetActiveRewardItems(infoActive.id)
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder

	self:DealWithLocalization(self.ActiveID)

	if not self.spineGroupHandle then
		self.spineGroupHandle = {}
	end

	self.spineGroupHandle = ResourceMgr.BeginSubmit(function()
		if self.BG then
			if not self.listRef then
				self.listRef = {}
			end

			table.insert(self.listRef, self.BG)

			if not IsNil(self.BGRaw) then
				UIUtil.SetImageSprite(self.BGRaw, self.BG, self)
			end
		end
	end)

	ResourceMgr.SubmitCache("UI/PanelOperation/New/Spine/BattlePass/BG_battlepass_main_01", self, "BG", Sprite)
	ResourceMgr.EndSubmit()

	local GoodsId, State = OperationActiveMgr:GetBattlePassMonthIdState()
	local itemInfo = ShopManager:GetProduct(GoodsId)
	local originValue = itemInfo.data.CostValue
	local costValue = itemInfo.data.GoodsPrice

	if itemInfo.data.CostType == 1 then
		SetActiveFunc(self.tex_buy.gameObject, true)

		self.tex_buy.text = "¥" .. costValue[1]
	else
		SetActiveFunc(self.img_buy2.gameObject, true)
		SetActiveFunc(self.tex_buy2.gameObject, true)

		local infoItem = ItemManager:Get(costValue[1])
		local pathIcon = GetItemIcon(infoItem:GetType(), infoItem.id)

		pathIcon = pathIcon .. "_S"

		UIUtil.SetImageOverrideSprite(self.img_buy2, pathIcon)

		self.tex_buy2.text = costValue[2]
	end

	local isgray = State == true
	local gray = TenaryOp(isgray, 0, 1)

	SetActiveFunc(self.BgAward2unlock, gray == 1)

	self.Fill = GOUtil.FindChildComponent(self.UIRootObject, "Panel/leveltitle/Bar/Fill", "Image")
	self.Fill.fillAmount = BattlePassTaskMgr:GetBattlePassScore()
	self.tex_grade.text = BattlePassTaskMgr:GetBattlePassGrade()

	self:UpdateBattlePassTab(OperationActiveMgr.BattlePassTag)
	self:SetMaxValue()

	if self.oriText then
		self.endTimeTex.text = string.format(self.oriText, OperationActiveMgr:GetOpenTime(infoActive.data.ShowEndTime))
	else
		self.endTimeTex.text = OperationActiveMgr:GetOpenTime(infoActive.data.ShowEndTime)
	end
end

function DlgOperationActiveBattlePass:SignBattlePassnAward(tabName)
	if tabName == "Tab1" then
		local isHave, index, index2 = OperationActiveMgr:Get(self.infoActiveID):IsHaveCanRec()
		local count = #self.listBattlePassAward.ScoreSectionReward
		local width = GOUtil.GetRectTransformSizeDeltaWidth(self.content.gameObject)

		width = width - count * 195

		if index == 0 or index == count then
			index = 1
		end

		self.BattlePass1ViewPos = Vector2((1 - index2) * 195 + 3, 0)

		if self.BattlePass1ViewPos then
			self.UIScrollToolBattlePass1:SetContentPosImmediate(self.BattlePass1ViewPos, self.listBattlePassAward.ScoreSectionReward)
		end
	end
end

function DlgOperationActiveBattlePass:SaveBattlePass1ViewPos()
	if self.UIScrollToolBattlePass1 then
		local x, y = self.UIScrollToolBattlePass1.ScrollView.content.anchoredPosition.x or 0, 0

		self.BattlePass1ViewPos = Vector2.New(x, y)
	end
end

function DlgOperationActiveBattlePass:UpdateData(infoActive)
	self.infoActiveID = infoActive.id
	self.infoActive = infoActive
	self.listBattlePassAward = OperationActiveMgr:GetActiveRewardItems(infoActive.id)

	self:UpdateBattlePassTab(OperationActiveMgr.BattlePassTag)

	self.Fill.fillAmount = BattlePassTaskMgr:GetBattlePassScore()
	self.tex_grade.text = BattlePassTaskMgr:GetBattlePassGrade()

	self:SetMaxValue()
	self:DealWithLocalization(self.ActiveID)

	local GoodsId, State = OperationActiveMgr:GetBattlePassMonthIdState()

	SetActiveFunc(self.btn_active, not State)

	local isgray = State == true

	SetActiveFunc(self.BG_active, false)

	local gray = TenaryOp(isgray, 0, 1)

	SetActiveFunc(self.BgAward2unlock, gray == 1)
end

function DlgOperationActiveBattlePass:SetMaxValue()
	if #self.listBattlePassAward.ScoreSectionReward == BattlePassTaskMgr:GetBattlePassLevel() then
		self.Fill.fillAmount = 1
		self.tex_grade.text = "Max"

		RedDotSystemMgr.RemoveNode("Operation/BattlePass/Task")
		RedDotSystemMgr.SetNodeLockState("Operation/BattlePass/Task", true)
		SetActiveFunc(self.BattlePassTab2Dot, false)

		local scrollArea = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/TabPanel/panel2/BgAward/ScrollArea")

		SetActiveFunc(scrollArea, false)

		self.tex_complete.text = _("BattlePass_Complete")

		SetActiveFunc(self.tex_complete.gameObject, true)
	else
		SetActiveFunc(self.tex_complete.gameObject, false)
	end
end

function DlgOperationActiveBattlePass:OnUpdateSecond()
	if self.infoActive then
		if self.oriText then
			self.endTimeTex.text = string.format(self.oriText, OperationActiveMgr:GetOpenTime(self.infoActive.data.ShowEndTime))
		else
			self.endTimeTex.text = OperationActiveMgr:GetOpenTime(self.infoActive.data.ShowEndTime)
		end
	end
end

function DlgOperationActiveBattlePass:OnClickedBattlePassActive()
	SetActiveFunc(self.BG_active, true)
end

function DlgOperationActiveBattlePass:OnClickedBattlePassActiveClose()
	SetActiveFunc(self.BG_active, false)
end

function DlgOperationActiveBattlePass:OnUpdataItem()
	SetActiveFunc(self.BG_active, false)
end

function DlgOperationActiveBattlePass:OnClickedBattlePassActiveBuy()
	local function vCallBack(idx)
		if idx ~= DlgCommonEvent.ButtonType.Ok then
			return
		end

		local function callback(vPBMessage)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vPBMessage.result.code == NetManager.Result_Sucess then
				SoundMgr.Play(PATH_SFX_UI_SHOP_BUYSUCCESS)
			else
				UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
			end
		end

		local GoodsId, State = OperationActiveMgr:GetBattlePassMonthIdState()

		NetEncapManager:RequestPurchasePruduct(GoodsId, 1, "", {}, callback)
		LoadingMgr.Show(eLoadingType.Repeat)
	end

	local productId, stateT = OperationActiveMgr:GetBattlePassMonthIdState()
	local itemInfo = ShopManager:GetProduct(productId)
	local originValue = itemInfo.data.CostValue
	local costValue = itemInfo.data.GoodsPrice

	UIMgr.ShowCommon(DlgCommonEvent.Type.DiamondBuyTips, _("Desc_Alert"), {
		item1 = 502,
		isDiamond = false,
		num1 = costValue[2],
		item2 = Lang(155)
	}, vCallBack)
end

function DlgOperationActiveBattlePass:OnClickedBattlePassTab(data)
	local tabName = data.pointerPress.transform.parent.name

	OperationActiveMgr.BattlePassTag = tabName

	if self.UIScrollToolBattlePass1 then
		local x, y = self.UIScrollToolBattlePass1.ScrollView.content.anchoredPosition.x or 0, 0

		self.BattlePass1ViewPos = Vector2.New(x, y)
	end

	if self.UIScrollToolBattlePass2 then
		local x, y = self.UIScrollToolBattlePass2.ScrollView.content.anchoredPosition.x or 0, 0

		self.BattlePass2ViewPos = Vector2.New(x, y)
	end

	if self.UIScrollToolBattlePass3 then
		local x, y = 0, self.UIScrollToolBattlePass3.ScrollView.content.anchoredPosition.y or 0

		self.BattlePass3ViewPos = Vector2.New(x, y)
	end

	self:UpdateBattlePassTab(tabName)
end

function DlgOperationActiveBattlePass:OnClickedBattlePass()
	local panel = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/TabPanel/panel1")

	if OperationActiveMgr.BattlePassTag == "Tab2" then
		local listBattlePassAward = OperationActiveMgr:GetActiveRewardItems(self.infoActiveID)

		if #listBattlePassAward.ScoreSectionReward == BattlePassTaskMgr:GetBattlePassLevel() then
			return
		end

		self.BattlePassTaskList = TaskManager:SortTaskList(TaskManager:GetList(eTaskListType.battlePass))

		local listComp = {}

		for _, v in pairs(self.BattlePassTaskList) do
			if v:IsComplete() and not v:IsGetAward() then
				table.insert(listComp, v)
			end
		end

		if #listComp == 0 then
			UIMgr.ShowMsg(_("Msg_Award_Can_Receive_None"))
		else
			Event.Instance:Fire("DealWithCompleteTask", listComp)
		end

		return
	end

	local isflag = InfoOperationActive:IsBattlePassAwardDot()

	if isflag then
		local GoodsId, State = OperationActiveMgr:GetBattlePassMonthIdState()
		local type = TenaryOp(State == true, true, false)

		self:SaveBattlePass1ViewPos()
		Event.Instance:Fire("ReceiveOperationActiveAward", 0, true, type)
	else
		UIMgr.ShowMsg(_("Msg_Award_Can_Receive_None"))
	end
end

function DlgOperationActiveBattlePass:UpdateBattlePassTab(tabName)
	if tabName == "Tab1" then
		GOUtil.SetTextColor(self.BattlePassTab1Text, 88, 94, 98)
		GOUtil.SetTextColor(self.BattlePassTab2Text, 255, 255, 255)

		if not self.UIScrollToolBattlePass1 then
			local scrollArea = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/TabPanel/panel1/BgAward/ScrollArea")
			local content = GOUtil.FindChildComponent(scrollArea, "Content", "RectTransform")

			self.content = content
			self.count = #self.listBattlePassAward.ScoreSectionReward
			self.day = BattlePassTaskMgr:GetBattlePassLevel()
			self.TaskID = BattlePassTaskMgr:GetBattlePassTaskID()

			local function addCallback(item)
				self:AddClick(item.BtnGet, nil)
			end

			local function updateCallback(item, index)
				local data1 = self.listBattlePassAward.ScoreSectionReward[index]
				local data2 = self.listBattlePassAward.PayScoreSectionReward[index]

				item:UpdateData(data1, data2, self.infoActive, self.count, self.day, self.TaskID)
			end

			self.UIScrollToolBattlePass1 = UIScrollTool()

			self.UIScrollToolBattlePass1:InitList(scrollArea, content, self.count, self.PrefabCellBattlePass1, CellBattlePassAwardNew, self, true, addCallback, updateCallback)

			self.UIScrollToolBattlePass1.ScrollView.decelerationRate = 0.01

			self:SignBattlePassnAward("Tab1")
		else
			self:SignBattlePassnAward("Tab1")
			self.UIScrollToolBattlePass1:SetContentPosImmediate(self.BattlePass1ViewPos or Vector2.New(0, 0), self.listBattlePassAward.ScoreSectionReward)
		end

		SetActiveFunc(self["BattlePassTab" .. 1 .. "Btn"], false)
		SetActiveFunc(self["BattlePassTab" .. 2 .. "Btn"], true)
		SetActiveFunc(self["BattlePassTab" .. 1 .. "Sel"], true)
		SetActiveFunc(self["BattlePassTab" .. 2 .. "Sel"], false)
		SetActiveFunc(self["BattlePassTab" .. 1 .. "Panel"], true)
		SetActiveFunc(self["BattlePassTab" .. 2 .. "Panel"], false)

		TaskManager.battlePassPayList = {}

		local DayIndex = BattlePassTaskMgr:GetBattlePassLevel()

		for n = 1, #self.listBattlePassAward.PayScoreSectionReward do
			local award = self.listBattlePassAward.PayScoreSectionReward[n].award
			local canRecv = n <= DayIndex
			local isRecv = TaskManager:IsRecvedPayScoreAward(BattlePassTaskMgr:GetBattlePassTaskID(), n - 1)
			local GoodsId, State = OperationActiveMgr:GetBattlePassMonthIdState()
			local isActive = State

			if State and (not canRecv or isRecv) then
				isActive = false
			end
		end

		if InfoOperationActive:IsBattlePassAwardDot() then
			self.Fx_UI_009_2:SetActive(true)
			UIUtil.SetImageSprite(self.Img_battlePass, "UI/PanelOperation/New/AtlasCommon/BTN_square_pink_01", self)
		else
			self.Fx_UI_009_2:SetActive(false)
			UIUtil.SetImageSprite(self.Img_battlePass, "UI/PanelOperation/New/AtlasCommon/BTN_square_pink_02", self)
		end
	else
		GOUtil.SetTextColor(self.BattlePassTab2Text, 88, 94, 98)
		GOUtil.SetTextColor(self.BattlePassTab1Text, 255, 255, 255)

		TaskManager.battlePassPayList = {}

		if not self.UIScrollToolBattlePass3 then
			local scrollArea = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/TabPanel/panel2/BgAward/ScrollArea")
			local content = GOUtil.FindChildComponent(scrollArea, "Content", "RectTransform")

			self.BattlePassTaskList = TaskManager:SortTaskList(TaskManager:GetList(eTaskListType.battlePass))

			local count = #self.BattlePassTaskList

			local function addCallback(item)
				self:AddClick(item.BtnGet, nil)
			end

			local function updateCallback(item, index)
				local curList = self.BattlePassTaskList
				local infoTask = curList[index]

				item:UpdateData(infoTask, nil, 301)
			end

			self.UIScrollToolBattlePass3 = UIScrollTool()

			self.UIScrollToolBattlePass3:InitList(scrollArea, content, count, self.PrefabCell, CellTask, self, false, addCallback, updateCallback)
		end

		SetActiveFunc(self["BattlePassTab" .. 1 .. "Btn"], true)
		SetActiveFunc(self["BattlePassTab" .. 2 .. "Btn"], false)
		SetActiveFunc(self["BattlePassTab" .. 1 .. "Sel"], false)
		SetActiveFunc(self["BattlePassTab" .. 2 .. "Sel"], true)
		SetActiveFunc(self["BattlePassTab" .. 1 .. "Panel"], false)
		SetActiveFunc(self["BattlePassTab" .. 2 .. "Panel"], true)

		self.BattlePassTaskList = TaskManager:SortTaskList(TaskManager:GetList(eTaskListType.battlePass))

		self.UIScrollToolBattlePass3:SetContentPosImmediate(Vector2.New(0, 0), self.BattlePassTaskList)

		local listBattlePassAward = OperationActiveMgr:GetActiveRewardItems(self.infoActiveID)

		if #listBattlePassAward.ScoreSectionReward > BattlePassTaskMgr:GetBattlePassLevel() and TaskManager:IsBattlePassTaskDot() then
			self.Fx_UI_009_2:SetActive(true)
			UIUtil.SetImageSprite(self.Img_battlePass, "UI/PanelOperation/New/AtlasCommon/BTN_square_pink_01", self)
		else
			self.Fx_UI_009_2:SetActive(false)
			UIUtil.SetImageSprite(self.Img_battlePass, "UI/PanelOperation/New/AtlasCommon/BTN_square_pink_02", self)
		end
	end
end

function DlgOperationActiveBattlePass:EventAnimBattlePassLevelStart()
	self.AnimRoot:Play("battle_pass_add_level")
end

function DlgOperationActiveBattlePass:EventAnim()
	self.AnimRoot:Play("EmptyState")
end

function DlgOperationActiveBattlePass:OnBackAndroid()
	if self.BG_active and GOUtil.IsActiveSelf(self.BG_active) then
		self:OnClickedBattlePassActiveClose()

		return true
	else
		return false
	end
end
