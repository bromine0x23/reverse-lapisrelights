-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageInteraction/CellChildGift.lua

require("UI/Item/UIItemBase")

CellChildGift = class("CellChildGift", UIItemBase)

function CellChildGift:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellChildGift:OnEnter()
	local g = self.UIRootObject

	self.img_gift = self:GetChildComponent("img_gift", "Image")
	self.go_sel = self:GetChildGameObject("img_sel")
	self.go_like = self:GetChildGameObject("go_like")
	self.btn_add = self:GetChildGameObject("btn_add")
	self.btn_sub = self:GetChildGameObject("btn_sub")
	self.tex_num = self:GetChildComponent("tex_num", "Text")

	local gItem = self:GetChildGameObject("CellItem")

	self.CellItem = CellItem(gItem)

	self.CellItem:InitItemByRoot(gItem)
	self:OnRegisterEvent()
end

function CellChildGift:UpdateData(infoData, selectIndex, index, holdInfo)
	UIUtil.SetImageSprite(self.img_gift, infoData.data.Icon, self)
	self.CellItem:UpdateNoNumType(infoData)

	local gray = TenaryOp(holdInfo, 0, 1)

	self.CellItem:SetGray(gray == 1)
	DealWithListRef(self, UIUtil.SetImageGray(self.img_gift, gray))
	SetActiveFunc(self.go_sel, selectIndex == index and gray == 0)
	SetActiveFunc(self.go_like, gray == 0 and holdInfo[2] == 1)

	local colorStr = TenaryOp(infoData:GetNum() == 0, string.format("<color=#e22a2a>%s</color>", "×" .. infoData:GetNum()), string.format("<color=#505a61>%s</color>", "×" .. infoData:GetNum()))

	self.tex_num.fontSize = 20
	self.tex_num.text = colorStr
	self.index = index
	self.infoData = infoData
	self.holdInfo = holdInfo

	if selectIndex == index then
		local info = {}

		info.type = 1
		info.cell = self
		info.index = self.index
		info.data = self.infoData
		info.holdInfo = self.holdInfo

		Event.Instance:Fire("UpdateMainGift", info)
	end
end

function CellChildGift:Purge()
	self:OnLeave()
end

function CellChildGift:OnLeave()
	self:OnUnRegisterEvent()
	UnloadAllImageSprite(self)
	self.CellItem:OnLeave()
end

function CellChildGift:OnRegisterEvent()
	self:AddListener(self.btn_add, self.OnPointerItemAddRepeat, EventTriggerType.PointerRepeat)
	self:AddListener(self.btn_sub, self.OnPointerItemSubRepeat, EventTriggerType.PointerRepeat)
	self:AddListener(self.btn_add, self.OnClickedAdd, EventTriggerType.PointerUp)
	self:AddListener(self.btn_sub, self.OnClickedSub, EventTriggerType.PointerUp)
end

function CellChildGift:OnUnRegisterEvent()
	self:RemoveClick(self.btn_add, self.OnPointerItemAddRepeat, EventTriggerType.PointerRepeat)
	self:RemoveClick(self.btn_sub, self.OnPointerItemSubRepeat, EventTriggerType.PointerRepeat)
	self:RemoveClick(self.btn_add, self.OnClickedAdd, EventTriggerType.PointerUp)
	self:RemoveClick(self.btn_sub, self.OnClickedSub, EventTriggerType.PointerUp)
end

function CellChildGift:OnClickedAdd()
	Event.Instance:Fire("ResetMaxGif")

	if self.Repeat then
		self.Repeat = false

		return
	end

	local info = {}

	info.type = 1
	info.cell = self
	info.index = self.index
	info.data = self.infoData
	info.holdInfo = self.holdInfo

	Event.Instance:Fire("UpdateMainGift", info)
end

function CellChildGift:OnPointerItemAddRepeat()
	self.Repeat = true

	local info = {}

	info.type = 3
	info.cell = self
	info.index = self.index
	info.data = self.infoData
	info.holdInfo = self.holdInfo

	Event.Instance:Fire("UpdateMainGift", info)
end

function CellChildGift:OnClickedSub()
	Event.Instance:Fire("ResetMaxGif")

	if self.Repeat then
		self.Repeat = false

		return
	end

	local info = {}

	info.type = 2
	info.cell = self
	info.index = self.index
	info.data = self.infoData
	info.holdInfo = self.holdInfo

	Event.Instance:Fire("UpdateMainGift", info)
end

function CellChildGift:OnPointerItemSubRepeat()
	self.Repeat = true

	local info = {}

	info.type = 4
	info.cell = self
	info.index = self.index
	info.data = self.infoData
	info.holdInfo = self.holdInfo

	Event.Instance:Fire("UpdateMainGift", info)
end
