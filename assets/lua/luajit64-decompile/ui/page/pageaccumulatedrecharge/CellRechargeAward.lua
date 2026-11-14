-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageAccumulatedRecharge/CellRechargeAward.lua

local ActiveManage = require("luaData/ActiveManage")
local ActiveBuffInfo = require("luaData/ActiveBuffInfo")
local GoodsMonthPrivilege = require("luaData/GoodsMonthPrivilege")

require("UI/Item/UIItemBase")

CellRechargeAward = class("CellRechargeAward", UIItemBase)

function CellRechargeAward:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellRechargeAward:OnLeave()
	for i = 1, #self.CellList do
		local item = self.CellList[i]

		item:OnLeave()
	end

	self:RemoveClick(self.BtnGet, self.OnClickGet)
end

function CellRechargeAward:OnEnter()
	self.CellList = {}

	local cell = self:GetChildGameObject("CellItem1")
	local item = CellItem(cell)

	item:InitItemByRoot(cell)
	table.insert(self.CellList, item)

	for i = 2, 4 do
		local cell = self:GetChildGameObject("CellGroup/CellItem" .. i)
		local item = CellItem(cell)

		item:InitItemByRoot(cell)
		table.insert(self.CellList, item)
	end

	self.BtnGet = self:GetChildGameObject("Button")
	self.ImgBtn = self:GetChildComponent("Button", "Image")
	self.TexButton = self:GetChildComponent("Button/Text", "Text")
	self.TexTitle = self:GetChildComponent("title/TexTitle", "Text")
	self.TexDes = self:GetChildComponent("TexDes", "Text")
	self.TexAim = self:GetChildComponent("TexAim", "Text")
	self.ObjAim = self:GetChildGameObject("TexAim")

	self:AddClick(self.BtnGet, self.OnClickGet)
end

function CellRechargeAward:OnClickGet()
	Event.Instance:Fire("GetRechargeAward", self.info.index)
end

function CellRechargeAward:UpdateData(info)
	self.info = info
	self.TexTitle.text = string.format(_("Desc_TopUpTarget"), tostring(info.Aim))

	for i = 1, #self.CellList do
		local item = self.CellList[i]

		if info.ItemList[i] ~= nil then
			item.UIRootObject:SetActive(true)

			local infoItem = ItemManager:GetValueItem(info.ItemList[i][1], info.ItemList[i][2])

			item:UpdateWithNumType(infoItem)
		else
			item.UIRootObject:SetActive(false)
		end
	end

	if info.NowRecharge >= info.Aim then
		if info.isGet then
			self.TexButton.text = _("Desc_Has_Get")
		else
			self.TexButton.text = _("Desc_Get")
		end

		local gray = TenaryOp(info.isGet, 1, 0)

		DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtn, gray))
		self.BtnGet:SetActive(true)
		self.ObjAim:SetActive(false)
	else
		self.BtnGet:SetActive(false)
		self.ObjAim:SetActive(true)

		self.TexAim.text = string.format(_("Desc_TopUpAlready"), tostring(info.NowRecharge), tostring(info.Aim))
	end
end
