-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCardShop/DlgCardShopInfo.lua

require("UI/Page/PageCardShop/DlgGetCardRecord")
require("Info/InfoCardPool")
require("UI/Page/PageCardShop/CellCardDropRate")
require("UI/Page/PageCardShop/CellCardPoolDetail")

DlgCardShopInfo = class("DlgCardShopInfo", UIPanel)

function DlgCardShopInfo:ctor()
	self.UIPrefabPath = "UI/PageCardShop/DlgCardShopInfo"
end

function DlgCardShopInfo:Purge()
	DlgCardShopInfo.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	ResourceMgr.Unload(self.PrefabCellCardPoolDetail)
	ResourceMgr.Unload(self.PrefabCellCardDropRate)
end

function DlgCardShopInfo:PreLoad()
	self:LoadResAsync("UI/PageCardShop/CellCardPoolDetail", "PrefabCellCardPoolDetail")
	self:LoadResAsync("UI/PageCardShop/CellCardDropRate", "PrefabCellCardDropRate")
end

function DlgCardShopInfo:OnEnter(vParam)
	self.info = vParam.info
	self.probDetail = vParam.probDetail
	self.tenProbDetail = vParam.tenProbDetail
	self.ButtonExit = self:GetChildGameObject("Main/ButtonExit")
	self.ButtonRecord = self:GetChildGameObject("Main/ButtonRecord")
	self.ButtonMv = self:GetChildGameObject("Main/ButtonMv")

	local Text = self:GetChildComponent("Main/bg_title/Text", "Text")

	Text.text = _("DlgCardShopInfo_title")
	Text = self:GetChildComponent("Main/ButtonRecord/Text", "Text")
	Text.text = _("DlgCardShopInfo_btn")
	Text = self:GetChildComponent("Main/Info/Text1", "Text")
	Text.text = _("DlgCardShopInfo_info")
	Text = self:GetChildComponent("Main/TextTime1", "Text")
	Text.text = _("DlgCardShopInfo_openTime")
	Text = self:GetChildComponent("Main/ButtonMv/Text", "Text")
	Text.text = _("DlgCardShopInfo_btnMv")

	local TextInfo = self:GetChildComponent("Main/Info/Scroll View/Viewport/Text", "Text")

	TextInfo.text = Lang(self.info.data.PoolDesc)

	local TextTime = self:GetChildComponent("Main/TextTime", "Text")
	local TextTime1 = self:GetChildGameObject("Main/TextTime1")
	local curTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	if self.info.data.TimeShow == 1 and self.info.data.CreateAccountPoolTime == 0 then
		if self.info.data.ActiveType == eCardPoolActiveType.ChooseCardPool and (curTime > GetTimeTampByString(self.info.data.EndTime) or curTime < GetTimeTampByString(self.info.data.OpenTime)) then
			TextTime.text = ""

			SetActiveFunc(TextTime1, false)
		else
			TextTime.text = self.info.data.OpenTime .. "    " .. self.info.data.EndTime

			SetActiveFunc(TextTime1, true)
		end
	else
		TextTime.text = ""

		SetActiveFunc(TextTime1, false)
	end

	self.Content = self:GetChildGameObject("Main/ScrollView/Viewport/Content")

	self:UpdateScrollJP()
end

function DlgCardShopInfo:OnRegisterEvent()
	self:AddClick(self.ButtonExit, self.OnButtonExit, PATH_SFX_UI_CANCEL)
	self:AddClick(self.ButtonRecord, self.OnButtonRecord)
	self:AddClick(self.ButtonMv, self.OnButtonMv)
end

function DlgCardShopInfo:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonExit, self.OnButtonExit)
	self:RemoveClick(self.ButtonRecord, self.OnButtonRecord)
	self:RemoveClick(self.ButtonMv, self.OnButtonMv)
end

function DlgCardShopInfo:AddText(message, height, top, fontSize)
	local head1

	head1 = GOUtil.Instantiate(self:GetChildGameObject("Main/TextTitle"), self.Content)

	local rect = GOUtil.GetComponent(head1, "RectTransform")

	rect.anchoredPosition = Vector2.New(0, 0)
	rect.pivot = Vector2.New(0, 1)
	rect.anchorMin = Vector2.New(0, 1)
	rect.anchorMax = Vector2.New(0, 1)

	local text = GOUtil.GetComponent(head1, "Text")

	UIUtil.SetTextAlignment(text, 3)

	text.text = message

	if fontSize then
		text.fontSize = fontSize
	end

	GOUtil.SetRectTransformSizeDelta(head1, 1118, height)
	GOUtil.SetRectTransformAnchoredPosition(head1, 0, top)
end

function DlgCardShopInfo:UpdateScrollJP()
	local list = {
		{},
		{},
		{},
		{}
	}
	local dicTen = {
		{},
		{},
		{},
		{}
	}
	local listTen = {}

	if self.tenProbDetail then
		print("gen ten prob detail")

		for i, v in ipairs(self.tenProbDetail) do
			if dicTen[v.quality] then
				table.insert(dicTen[v.quality], v)
			else
				dicTen[v.quality] = {}

				table.insert(dicTen[v.quality], v)
			end
		end

		for k, v in pairs(dicTen) do
			table.sort(v, function(a, b)
				return a.probability > b.probability
			end)
		end

		for i = 1, #dicTen do
			local v = dicTen[i]

			if #v > 0 then
				table.insert(listTen, v)
			end
		end

		print("#list ten is " .. #listTen)
	end

	for i, v in ipairs(self.probDetail) do
		if list[v.quality] then
			table.insert(list[v.quality], v)
		else
			list[v.quality] = {}

			table.insert(list[v.quality], v)
		end
	end

	for k, v in pairs(list) do
		table.sort(v, function(a, b)
			return a.probability > b.probability
		end)
	end

	local count = #list
	local count2 = #listTen
	local addH = 0
	local sizeH = 0
	local heightCount = count + count2

	if count2 > 0 then
		self:AddText("■「10回召喚」（1回目～9回目）", 60, addH)

		addH = addH - 60

		if #self.info.data.OneCost > 0 then
			self:AddText("※1回ごとに、その提供割合にもとづいて召喚を行っております。\n※「1回召喚」と「10回召喚」（１回目～9回目まで）は、同じ提供割合です。", 100, addH, 30)

			addH = addH - 100
		else
			self:AddText("※1回ごとに、その提供割合にもとづいて召喚を行っております。", 50, addH, 30)

			addH = addH - 50
		end
	end

	for i = count, 1, -1 do
		if list[i][1] == nil then
			heightCount = heightCount - 1
		else
			local rateGroupData = 0

			for i, v in ipairs(list[i]) do
				rateGroupData = rateGroupData + v.probability
			end

			local cell

			cell = CellCardPoolDetail(self.PrefabCellCardPoolDetail, self.Content, self)

			cell:Create()
			cell:UpdateData(string.format("%.3f", rateGroupData) .. "%", list[i][1].quality)

			for n = 1, #list[i] do
				local cellRate = CellCardDropRate(self.PrefabCellCardDropRate, cell.GroupPanel, self)

				cellRate:Create()

				local data = {}

				data[1] = list[i][n].cardId
				data[2] = string.format("%.3f", list[i][n].probability) .. "%"

				if list[i][n].probability > list[i][#list[i]].probability then
					data[3] = 1
				else
					data[3] = 0
				end

				cellRate:UpdateData(data, n)
			end

			local newHeight = 80 * (#list[i] - 1)

			if cell then
				GOUtil.SetRectTransformSizeDelta(cell.UIRootObject, 1118, 225 + newHeight)
				GOUtil.SetRectTransformAnchoredPosition(cell.UIRootObject, 0, addH)
			else
				newHeight = -225
			end

			addH = addH - (newHeight + 225)
			sizeH = sizeH + newHeight
		end
	end

	if count2 > 0 then
		self:AddText("■「10回召喚」（10回目）", 65, addH)

		addH = addH - 65

		local isUrAffim = false

		for i = count2, 1, -1 do
			if listTen[i][1] == nil then
				-- block empty
			else
				local rateGroupData = 0

				for i, v in ipairs(listTen[i]) do
					rateGroupData = rateGroupData + v.probability
				end

				if list[i][1] and list[i][1].quality == 1 and rateGroupData == 100 then
					isUrAffim = true
				end
			end
		end

		if isUrAffim then
			self:AddText("※「10回召喚」10回目はURが確定で出現します。", 60, addH, 30)
		else
			self:AddText("※「10回召喚」10回目はSSR以上が確定で出現します。", 60, addH, 30)
		end

		addH = addH - 60
	end

	for i = count2, 1, -1 do
		if listTen[i][1] == nil then
			heightCount = heightCount - 1
		else
			local rateGroupData = 0

			for i, v in ipairs(listTen[i]) do
				rateGroupData = rateGroupData + v.probability
			end

			local cell

			cell = CellCardPoolDetail(self.PrefabCellCardPoolDetail, self.Content, self)

			cell:Create()
			cell:UpdateData(string.format("%.3f", rateGroupData) .. "%", listTen[i][1].quality)

			if list[i][1] and list[i][1].quality == 1 and rateGroupData == 100 then
				isUrAffim = true
			end

			for n = 1, #listTen[i] do
				local cellRate = CellCardDropRate(self.PrefabCellCardDropRate, cell.GroupPanel, self)

				cellRate:Create()

				local data = {}

				data[1] = listTen[i][n].cardId
				data[2] = string.format("%.3f", listTen[i][n].probability) .. "%"

				if listTen[i][n].probability > listTen[i][#listTen[i]].probability then
					data[3] = 1
				else
					data[3] = 0
				end

				cellRate:UpdateData(data, n)
			end

			local newHeight = 80 * (#listTen[i] - 1)

			if cell then
				GOUtil.SetRectTransformSizeDelta(cell.UIRootObject, 1118, 225 + newHeight)
				GOUtil.SetRectTransformAnchoredPosition(cell.UIRootObject, 0, addH)
			else
				newHeight = -225
			end

			addH = addH - (newHeight + 225)
			sizeH = sizeH + newHeight
		end
	end

	if count2 > 0 then
		GOUtil.SetRectTransformSizeDelta(self.Content, 1122, 225 * heightCount + sizeH + 310)
	else
		GOUtil.SetRectTransformSizeDelta(self.Content, 1122, 225 * heightCount + sizeH)
	end
end

function DlgCardShopInfo:OnButtonExit()
	self:Close()
end

function DlgCardShopInfo:OnButtonRecord()
	local function callback(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			if #vPBMessage.records == 0 and self.info.data.ActiveType == eCardPoolActiveType.StepUpPool and self.info.data.StepUpOrder ~= 1 then
				local function callback2(vPBMessage)
					LoadingMgr.Hide(eLoadingType.Repeat)

					if vPBMessage.result.code == NetManager.Result_Sucess then
						UIMgr.AddPanel(DlgGetCardRecord(), {
							records = vPBMessage.records,
							info = self.info
						})
					else
						UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
					end
				end

				local list = CardPoolManager:GetActivePoolList(self.info.data.ActiveID)

				for i, v in ipairs(list) do
					if v.data.StepUpOrder == self.info.data.StepUpOrder - 1 then
						NetManager:RequestDrawCardRecord(v.data.ID, callback2)
						LoadingMgr.Show(eLoadingType.Repeat)

						return
					end
				end
			end

			UIMgr.AddPanel(DlgGetCardRecord(), {
				records = vPBMessage.records,
				info = self.info
			})
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetManager:RequestDrawCardRecord(self.info.id, callback)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgCardShopInfo:OnButtonMv()
	Event.Instance:Fire("OnPlayFirstVideo")
	self:Close()
end
