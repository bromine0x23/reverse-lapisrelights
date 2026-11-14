-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageShop/DlgProductRate.lua

require("Info/InfoCardPool")
require("UI/Page/PageShop/CellProductDropRate")
require("UI/Page/PageShop/CellProdRateDetail")

DlgProductRate = class("DlgProductRate", UIPanel)

function DlgProductRate:ctor()
	self.UIPrefabPath = "UI/PageShop/DlgProductRate"
end

function DlgProductRate:Purge()
	DlgProductRate.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	ResourceMgr.Unload(self.PrefabCellProdGroupDetail)
	ResourceMgr.Unload(self.PrefabCellProdDropRate)
end

function DlgProductRate:PreLoad()
	self:LoadResAsync("UI/PageShop/CellProdGroupDetail", "PrefabCellProdGroupDetail")
	self:LoadResAsync("UI/PageShop/CellProdDropRate", "PrefabCellProdDropRate")
end

function DlgProductRate:OnEnter(vParam)
	self.info = vParam.info
	self.ButtonExit = self:GetChildGameObject("Main/ButtonExit")
	self.Content = self:GetChildGameObject("Main/ScrollView/Viewport/Content")

	local Text = self:GetChildComponent("Main/bg_title/Text", "Text")

	Text.text = "割合詳細"

	local tmpInfo = vParam.probDetail

	self.cellDic = {}

	for i = 1, #tmpInfo do
		local v = tmpInfo[i]

		if not self.cellDic[tostring(v.parentItemId)] then
			self.cellDic[tostring(v.parentItemId)] = {}
		end

		table.insert(self.cellDic[tostring(v.parentItemId)], v)
	end

	for k, v in pairs(self.cellDic) do
		print("id " .. k)
		table.sort(v, function(a, b)
			return a.probability > b.probability
		end)
	end

	self:UpdateScroll()
end

function DlgProductRate:OnRegisterEvent()
	self:AddClick(self.ButtonExit, self.OnButtonExit, PATH_SFX_UI_CANCEL)
end

function DlgProductRate:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonExit, self.OnButtonExit)
end

function DlgProductRate:AddText(message, height, top, fontSize)
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

function DlgProductRate:UpdateScroll()
	local addH = 0
	local sizeH = 0
	local goodsList = self.info.data.GoodsItemList
	local heightCount = 0

	for i = 1, #goodsList do
		local id = goodsList[i][1]
		local num = goodsList[i][2]
		local list = self.cellDic[tostring(id)]
		local rateTotal = 0

		for j = 1, #list do
			rateTotal = rateTotal + list[j].probability
		end

		rateTotal = math.ceil(rateTotal)

		local cell = CellProdRateDetail(self.PrefabCellProdGroupDetail, self.Content, self)

		cell:Create()
		cell:UpdateData(id, num, string.format("提供割合：%d", rateTotal) .. "%")

		for n = 1, #list do
			local cellRate = CellProductDropRate(self.PrefabCellProdDropRate, cell.GroupPanel, self)

			cellRate:Create()
			cellRate:UpdateData(list[n], n)
		end

		local newHeight = 80 * (#list - 1)

		GOUtil.SetRectTransformSizeDelta(cell.UIRootObject, 1118, 225 + newHeight)
		GOUtil.SetRectTransformAnchoredPosition(cell.UIRootObject, 0, addH)

		addH = addH - (newHeight + 225)
		sizeH = sizeH + newHeight + 225
	end

	GOUtil.SetRectTransformSizeDelta(self.Content, 1122, sizeH)
end

function DlgProductRate:OnButtonExit()
	self:Close()
end
