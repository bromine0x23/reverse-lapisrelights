-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellSignAward.lua

require("UI/Item/UIItemBase")
require("UI/Item/CellItem")
require("Info/InfoShop")

CellSignAward = class("CellSignAward", UIItemBase)

function CellSignAward:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellSignAward:OnEnter()
	local g = self.UIRootObject

	self.Cell = GOUtil.FindChildGameObject(g, "CellItem")
	self.btn_sel = self:GetChildGameObject("btn_sel")
	self.img_sel = self:GetChildGameObject("img_sel")
	self.RawImage = self:GetChildGameObject("RawImage")
	self.btn_retroactive = self:GetChildGameObject("btn_retroactive")
	self.btn_img_retroactive = self:GetChildComponent("btn_retroactive", "Image")
	self.img_retroactive = self:GetChildComponent("btn_retroactive/img_retroactive", "Image")
	self.img_retroactive2 = self:GetChildComponent("btn_retroactive/img_retroactive2", "Image")

	self:AddClick(self.btn_sel, self.OnClickedBtnSel)
	self:AddClick(self.btn_retroactive, self.OnClickedRetroactive)

	self.img_sign = self:GetChildComponent("img_sign", "Image")
	self.img_unsign = self:GetChildComponent("img_unsign", "Image")
	self.go_sign = self:GetChildGameObject("img_sign")
	self.img_double_big = self:GetChildComponent("double_big", "Image")
	self.img_double_small = self:GetChildComponent("double_small", "Image")
	self.double_big = self:GetChildGameObject("double_big")

	GOUtil.SetRectTransformAnchoredPosition(self.double_big.gameObject, 27.3, 70)

	self.double_small = self:GetChildGameObject("double_small")
	self.img_get = self:GetChildGameObject("img_sign/Image")
	self.tex_day = self:GetChildComponent("tex_day", "Text")
	self.tex_selday = self:GetChildComponent("img_sel/tex_selday", "Text")
	self.tex_selnum = self:GetChildComponent("img_sel/tex_selnum", "Text")
	self.tex_num = self:GetChildComponent("tex_num", "Text")
	self.img_day = self:GetChildGameObject("img_day")
	self.listItem = {}
end

function CellSignAward:OnLeave()
	self:RemoveClick(self.btn_sel, self.OnClickedBtnSel)
	self:RemoveClick(self.btn_retroactive, self.OnClickedRetroactive)
	UnloadAllImageSprite(self)

	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end
end

function CellSignAward:Purge()
	self:OnLeave()
end

function CellSignAward:UpdateData(data, listOpenActive, retroactiveIndex, LoginSignDay)
	self.data = data

	self:ClearCell()

	day = LoginSignDay

	local infoOperationActive = listOpenActive
	local isGeted = infoOperationActive:IsGetIndexAward(self.data.index)
	local isCanGet = infoOperationActive:IsCanGet(self.data.index)

	self.curDay = day
	self.retroactiveIndex = retroactiveIndex

	SetActiveFunc(self.btn_sel, self.data.index == day and not isGeted)
	SetActiveFunc(self.img_sel, self.data.index == day)
	SetActiveFunc(self.RawImage, self.data.index == day and not isGeted)
	SetActiveFunc(self.btn_retroactive, not isGeted and self.data.index ~= day)
	SetActiveFunc(self.go_sign, self.data.index ~= self.retroactiveIndex)
	SetActiveFunc(self.img_get, self.data.index <= day and isGeted)
	SetActiveFunc(self.tex_day.gameObject, self.data.index ~= day)
	SetActiveFunc(self.tex_num.gameObject, self.data.index ~= day)
	SetActiveFunc(self.img_day, self.data.index ~= day)

	local str = day

	self.tex_selday.text = day
	str = self.data.index

	SetActiveFunc(self.img_sign.gameObject, isGeted)

	local award = self.data.award[1]

	SetActiveFunc(self.double_big, self.data.extraReward == 40002)
	SetActiveFunc(self.double_small, self.data.extraReward == 40001)

	local gray = TenaryOp(self.data.extraReward == 40002 and ShopManager:GetMonthIdState(self.data.extraReward), 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.img_double_big, gray))

	gray = TenaryOp(self.data.extraReward == 40001 and ShopManager:GetMonthIdState(self.data.extraReward), 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.img_double_small, gray))

	if award then
		local infoItem = ItemManager:GetValueItem(award[1], award[2])
		local quality = infoItem:GetQuality()
		local gItem = self.Cell
		local item = CellItem(gItem)

		item:InitItemByRoot(gItem)

		item.name = self.data.index

		if award[2] == 0 then
			item:UpdateNoNumType(infoItem)
		else
			item:UpdateWithNumType(infoItem)
		end

		local isGray = self.data.index < day and self.data.index ~= self.retroactiveIndex or isGeted

		SetActiveFunc(self.img_retroactive.gameObject, isGray)
		SetActiveFunc(self.img_retroactive2.gameObject, self.data.index < day and self.data.index == self.retroactiveIndex or isGeted)

		if isGray then
			self.btn_img_retroactive.color = Color.New(1, 1, 1, 1)
		elseif self.data.index < day and self.data.index == self.retroactiveIndex or isGeted then
			self.btn_img_retroactive.color = Color.New(1, 1, 1, 1)
		else
			self.btn_img_retroactive.color = Color.New(1, 1, 1, 0)
		end

		self.tex_num.text = infoItem.pb.num
		self.tex_selnum.text = infoItem.pb.num

		if self.data.index < day then
			self.tex_day.text = str
			self.tex_num.text = infoItem.pb.num
		else
			self.tex_day.text = str
		end

		table.insert(self.listItem, item)
	end
end

function CellSignAward:OnClickedBtnLook()
	return
end

function CellSignAward:ClearCell()
	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end
end

function CellSignAward:OnClickedBtnSel(data)
	Event.Instance:Fire("ReceiveOperationActiveAward", self.data.index)
end

function CellSignAward:OnClickedRetroactive(data)
	if self.retroactiveIndex ~= self.data.index then
		if self.curDay < self.data.index then
			UIMgr.ShowMsg(_("Desc_NoStart"))

			return
		elseif self.curDay > self.data.index then
			UIMgr.ShowMsg(_("Desc_SignInOrder"))

			return
		end
	end

	TaskManager.signAwardDouble = self.data.extraReward == 40002 and ShopManager:GetMonthIdState(self.data.extraReward)

	Event.Instance:Fire("OperationActiveSignRetroactive", self.data.index)
end
