-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgGetAward.lua

require("UI/Item/CellItem")
require("UI/Page/PageCardShop/DlgDrawOne")
require("UI/Dlg/Common/DlgItemOverRemind")

DlgGetAward = class("DlgGetAward", UIPanel)

function DlgGetAward:ctor()
	self.callback = nil
	self.fromMail = false
	self.UIPrefabPath = "UI/Common/DlgGetAward/DlgGetAward"
end

function DlgGetAward:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
end

function DlgGetAward:Purge()
	DlgGetAward.base.Purge(self)

	if self.PrefabCellItem then
		ResourceMgr.Unload(self.PrefabCellItem)

		self.PrefabCellItem = nil
	end

	self:OnLeave()
end

function DlgGetAward:OnLeave()
	if self.Timer then
		TimerMgr.RemoveTimer(self.Timer)

		self.Timer = nil
	end

	if self.Timer2 then
		TimerMgr.RemoveTimer(self.Timer2)

		self.Timer2 = nil
	end

	if self.listItem and #self.listItem > 0 then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end

	self.fromMail = nil
	TaskManager.integralList = {}
	TaskManager.signAwardDouble = false
end

function DlgGetAward:OnRegisterEvent()
	self:AddClick(self.Button, self.OnClickedButton)
end

function DlgGetAward:OnUnRegisterEvent()
	self:RemoveClick(self.Button, self.OnClickedButton)
end

function DlgGetAward:OnEnter(vParam)
	SoundMgr.PostEvent(PATH_SFX_UI_RECEIVE_AWARD, self.UIRootObject)

	local list = {}

	if vParam and vParam.list then
		list = vParam.list
	end

	if vParam and vParam.callback then
		self.callback = vParam.callback
	end

	if vParam and vParam.fromMail then
		self.fromMail = vParam.fromMail
	end

	if vParam.flag == "GVGSTEP" or vParam.flag == "GVGSTAGE" or vParam.flag == "GVGHELP" then
		local imgTitle = self:GetChildComponent("Panel/BgTitle/Image1 (4)", "Image")
		local path = Infogvg.cfg:GetRewardTitleIcon(vParam.flag)

		if path then
			SetImageSprite(imgTitle, path, self, true)
		end
	end

	if vParam.tip then
		local go = self:GetChildGameObject("Panel/Image (4)")

		SetActiveFunc(go, true)

		local label = self:GetChildComponent("Panel/Image (4)/Text", "Text")

		label.text = vParam.tip
	end

	local count = 0

	for i = 1, #list do
		local s = list[i]
		local infoItem = SetterData.GetItemFromAsset(s)

		if infoItem ~= nil and s.num > 0 then
			count = count + 1
		end
	end

	local path = ""
	local isVertical = false

	if count > 9 then
		path = "2"
		isVertical = true

		self:GetChildGameObject("Panel"):SetActive(false)
		self:GetChildGameObject("Panel2"):SetActive(true)
	else
		self:GetChildGameObject("Panel"):SetActive(true)
		self:GetChildGameObject("Panel2"):SetActive(false)
	end

	local textBtn = self:GetChildComponent("Panel" .. path .. "/Text", "Text")

	textBtn.text = _("Desc_Continue")
	self.Button = self:GetChildGameObject("Panel" .. path .. "/Button")

	local ScrollArea = self:GetChildGameObject("Panel" .. path .. "/ScrollArea")
	local ScrollView = GOUtil.AddMissingComponent(ScrollArea, "UIScrollView")

	ScrollView.vertical = isVertical
	ScrollView.content = self:GetChildComponent("Panel" .. path .. "/ScrollArea/Content", "Transform")
	self.listRoleCard = {}
	self.listItem = {}

	if vParam.battlePassPayList then
		TaskManager.battlePassPayList = vParam.battlePassPayList
		isVertical = count > 7

		self:BattlePassPayList(isVertical)

		ScrollArea = self:GetChildGameObject("battlePass/BattlePassScrollArea1")
		ScrollView = GOUtil.AddMissingComponent(ScrollArea, "UIScrollView")
		ScrollView.vertical = isVertical
		ScrollView.content = self:GetChildComponent("battlePass/BattlePassScrollArea1/Content", "Transform")

		local BgRect = self:GetChildComponent("Panel/Bg", "Transform")
		local BgTitleRect = self:GetChildComponent("Panel/BgTitle", "Transform")
		local ImgBattlePass = self:GetChildGameObject("battlePass/ImgBattlePass")

		SetActiveFunc(ImgBattlePass, true)
		SetActiveFunc(ScrollArea, true)

		local TexBattlePass = self:GetChildComponent("battlePass/ImgBattlePass/Text", "Text")

		TexBattlePass.text = Lang(812)

		GOUtil.SetRectTransformSizeDelta(BgRect.gameObject, BgRect.sizeDelta.x, 855)
		GOUtil.SetRectTransformAnchoredPosition(BgRect.gameObject, BgRect.anchoredPosition.x, 462)
		GOUtil.SetRectTransformAnchoredPosition(BgTitleRect.gameObject, 0, 429)

		if count > 7 then
			local ScrollAreaRect = GOUtil.GetComponent(ScrollArea, "Transform")

			GOUtil.SetRectTransformSizeDelta(ScrollAreaRect.gameObject, ScrollAreaRect.sizeDelta.x, 340)
		end

		SetActiveFunc(self:GetChildGameObject("battlePass"), true)
		self:GetChildGameObject("Panel"):SetActive(true)
		self:GetChildGameObject("Panel2"):SetActive(false)

		self.Button = self:GetChildGameObject("Panel/Button")
	end

	if #TaskManager.commonAwardTomorrowList ~= 0 then
		ScrollArea = self:GetChildGameObject("common/CommonScrollArea1")
		ScrollView = GOUtil.AddMissingComponent(ScrollArea, "UIScrollView")
		ScrollView.content = self:GetChildComponent("common/CommonScrollArea1/Content", "Transform")

		local ScrollArea2 = self:GetChildGameObject("common/CommonScrollArea2")

		ScrollView2 = GOUtil.AddMissingComponent(ScrollArea2, "UIScrollView")
		ScrollView2.content = self:GetChildComponent("common/CommonScrollArea2/Content", "Transform")

		local BgRect = self:GetChildComponent("Panel/Bg", "Transform")
		local BgTitleRect = self:GetChildComponent("Panel/BgTitle", "Transform")

		SetActiveFunc(ScrollArea, true)

		local TexBattlePass = self:GetChildComponent("battlePass/ImgBattlePass/Text", "Text")

		TexBattlePass.text = Lang(812)

		GOUtil.SetRectTransformSizeDelta(BgRect.gameObject, BgRect.sizeDelta.x, 855)
		GOUtil.SetRectTransformAnchoredPosition(BgRect.gameObject, BgRect.anchoredPosition.x, 462)
		GOUtil.SetRectTransformAnchoredPosition(BgTitleRect.gameObject, 0, 429)

		local count = #TaskManager.commonAwardTomorrowList

		for i = 1, count do
			local award = TaskManager.commonAwardTomorrowList[i]
			local infoItem = ItemManager:GetValueItem(award[1], award[2])

			if infoItem ~= nil then
				local item = CellItem(self.PrefabCellItem, ScrollView2.content.gameObject, self)

				item:Create()

				if award[2] == 0 then
					item:UpdateNoNumType(infoItem)
				else
					item:UpdateWithNumType(infoItem)
				end

				local scrollviewContent = GOUtil.AddMissingComponent(item.UIRootObject, "UIScrollViewContent")

				scrollviewContent.scrollView = ScrollView2

				table.insert(self.listItem, item)
			end
		end

		self:GetChildGameObject("Panel"):SetActive(true)
		self:GetChildGameObject("Panel2"):SetActive(false)
		SetActiveFunc(self:GetChildGameObject("common"), true)

		self.Button = self:GetChildGameObject("Panel/Button")
		TaskManager.commonAwardTomorrowList = {}
	end

	table.sort(list, function(a, b)
		if a == nil or b == nil then
			return false
		end

		if a == b then
			return false
		end

		return a.from == protocol_pb.AF_STAGE_WHIP and b.from ~= protocol_pb.AF_STAGE_WHIP
	end)

	local startValue = 0
	local listTask = {}

	for i = 1, #TaskManager.integralList do
		if TaskManager.integralList[i] then
			if listTask[TaskManager.integralList[i][1]] then
				listTask[TaskManager.integralList[i][1]] = listTask[TaskManager.integralList[i][1]] + TaskManager.integralList[i][2]
			else
				listTask[TaskManager.integralList[i][1]] = TaskManager.integralList[i][2]
			end
		end
	end

	for k, v in pairs(listTask) do
		startValue = startValue + 1
		infoItem = ItemManager:GetValueItem(k, v)

		local item = CellItem(self.PrefabCellItem, ScrollView.content.gameObject, self)

		item:Create()
		item:UpdateData(startValue, infoItem, true)
		table.insert(self.listItem, item)
	end

	local count = #list
	local itemList = {}

	for i = 1, count do
		local s = list[i]

		if s.asset == protocol_pb.RC_RECEIVE or s.asset == protocol_pb.I_SOUL then
			table.insert(self.listRoleCard, s)
		end

		local infoItem = SetterData.GetItemFromAsset(s)

		if infoItem ~= nil and s.num > 0 and s.from ~= protocol_pb.AF_TEAM_LV_UP then
			local info = {}

			info.infoItem = infoItem
			info.from = s.from

			table.insert(itemList, info)
		end
	end

	if vParam.goodsItemList then
		local weightMap = {}

		table.sort(itemList, function(a, b)
			local weightA = weightMap[a.infoItem.id]

			if not weightA then
				weightA = table.getIndex(vParam.goodsItemList, a.infoItem.id)

				if weightA == -1 then
					weightA = 100
				end
			end

			local weightB = weightMap[b.infoItem.id]

			if not weightB then
				weightB = table.getIndex(vParam.goodsItemList, b.infoItem.id)

				if weightB == -1 then
					weightB = 100
				end
			end

			if weightA == weightB then
				return a.infoItem.id < b.infoItem.id
			else
				return weightA < weightB
			end
		end)

		NetEncapManager.goodsItemList = {}
	else
		table.sort(itemList, function(a, b)
			return a.infoItem.id < b.infoItem.id
		end)
	end

	for key, value in pairs(itemList) do
		local item = CellItem(self.PrefabCellItem, ScrollView.content.gameObject, self)

		item:Create()

		if value.from == protocol_pb.AF_STAGE_WHIP then
			item:UpdateDataByWhipAward(key, value.infoItem)
			item:SetWhip(true)
		else
			item:UpdateData(key + startValue, value.infoItem, true)
		end

		if value.from == protocol_pb.AF_STAGE_HIGH_AWARD then
			item:SetHigh(true)
		elseif value.from == protocol_pb.AF_STAGE_FIRST then
			item:SetFirstPass(true)
		elseif value.from == protocol_pb.AF_EXTRA_AWARD then
			item:SetExtra(true)
		end

		if TaskManager.signAwardDouble then
			item:SetSignDouble(true)
		end

		local scrollviewContent = GOUtil.AddMissingComponent(item.UIRootObject, "UIScrollViewContent")

		scrollviewContent.scrollView = ScrollView

		table.insert(self.listItem, item)
	end

	self.Timer = TimerMgr.AddTimer(eTimerType.RealTime, 0.1, function(...)
		ScrollView:SetContentPosImmediate(Vector2.New(30 * count, 0))
	end, {
		1
	})
	self.isPlayAnimation = true
	self.Timer2 = TimerMgr.AddTimer(eTimerType.RealTime, 0.1 * #self.listItem + 1, function(...)
		self.isPlayAnimation = false
	end, {
		1
	})
	self.index = 1

	self:AddDraw()
end

function DlgGetAward:BattlePassPayList(isVertical)
	local ScrollArea = self:GetChildGameObject("battlePass/BattlePassScrollArea2")
	local ScrollView = GOUtil.AddMissingComponent(ScrollArea, "UIScrollView")
	local count = #TaskManager.battlePassPayList

	ScrollView.vertical = count > 7
	ScrollView.content = self:GetChildComponent("battlePass/BattlePassScrollArea2/Content", "Transform")

	SetActiveFunc(ScrollArea, true)

	if not isVertical and count > 7 then
		local ScrollAreaRect = GOUtil.GetComponent(ScrollArea, "Transform")

		GOUtil.SetRectTransformSizeDelta(ScrollAreaRect.gameObject, ScrollAreaRect.sizeDelta.x, 340)
	elseif not isVertical and count > 7 then
		local ScrollAreaRect = GOUtil.GetComponent(ScrollArea, "Transform")

		GOUtil.SetRectTransformSizeDelta(ScrollAreaRect.gameObject, ScrollAreaRect.sizeDelta.x, 210)
	end

	for i = 1, count do
		local award = TaskManager.battlePassPayList[i]
		local infoItem = ItemManager:GetValueItem(award[1], award[2])

		if infoItem ~= nil then
			local item = CellItem(self.PrefabCellItem, ScrollView.content.gameObject, self)

			item:Create()

			if award[2] == 0 then
				item:UpdateNoNumType(infoItem)
			else
				item:UpdateWithNumType(infoItem)
			end

			local scrollviewContent = GOUtil.AddMissingComponent(item.UIRootObject, "UIScrollViewContent")

			scrollviewContent.scrollView = ScrollView

			table.insert(self.listItem, item)
		end
	end

	TaskManager.battlePassPayList = {}
end

function DlgGetAward:AddDraw()
	GOUtil.SetActive(self.UIRootObject, true)

	if self.index > #self.listRoleCard then
		return
	end

	self.showAddDraw = true

	local sd = self.listRoleCard[self.index]
	local hasChangeStar = not sd.newRoleCard or not (sd.newRoleCard.id > 0)

	self.index = self.index + 1

	if hasChangeStar then
		self.showAddDraw = false

		self:AddDraw()
	else
		GOUtil.SetActive(self.UIRootObject, false)

		local hasNewRole = sd.newRole and sd.newRole.id > 0
		local infoRoleCard = RoleCardMgr:GetRoleCard(sd.id)
		local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)

		local function showDlgDrawOne()
			require("UI/Page/PageCardShop/DlgDrawOne")
			UIMgr.AddPanel(DlgDrawOne(), {
				callback = function()
					self.showAddDraw = false

					self:AddDraw()
				end,
				setter = sd
			})
		end

		local function showURcardShow()
			if infoRoleCard.rank == "ur" then
				require("UI/Page/PageCardShop/DlgURCardShow")
				UIMgr.AddPanel(DlgURCardShow(), {
					callback = function()
						showDlgDrawOne()
					end,
					infoRole = infoRole,
					infoRoleCard = infoRoleCard
				})
			else
				showDlgDrawOne()
			end
		end

		local function showNewRoleUnlock()
			if hasNewRole then
				require("UI/Page/PageCardShop/DlgNewRoleUnlock")
				UIMgr.AddPanel(DlgNewRoleUnlock(), {
					callback = function()
						showURcardShow()
					end,
					infoRole = infoRole
				})
			else
				showURcardShow()
			end
		end

		showNewRoleUnlock()
	end
end

function DlgGetAward:OnClickedButton(...)
	if self.showAddDraw then
		return
	end

	if self.isPlayAnimation then
		self.isPlayAnimation = false

		for i, v in ipairs(self.listItem) do
			v:SkipAnimator()
		end

		return
	end

	local function wrap_cb()
		if self.callback then
			self.callback()

			self.callback = nil
		end
	end

	if SetterData.haveOverItem then
		SetterData.haveOverItem = false

		if self.fromMail then
			UIMgr.ShowMsg(_("Msg_OverItem_Mail"))
		else
			UIMgr.ShowMsg(_("Msg_OverItem_Common"))
		end

		wrap_cb()
	else
		wrap_cb()
	end

	self:Close()
end

function DlgGetAward.GetInstance()
	DlgGetAward.Instance = DlgGetAward()

	return DlgGetAward.Instance
end

function DlgGetAward:OnBackAndroid()
	self:OnClickedButton()
end
