-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellGrowthFund.lua

require("UI/Item/UIItemBase")

CellGrowthFund = class("CellGrowthFund", UIItemBase)

function CellGrowthFund:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellGrowthFund:OnEnter()
	self.NoGet = self:GetChildGameObject("NoGet")
	self.IsGet = self:GetChildGameObject("IsGet")
	self.ButtonGet = self:GetChildGameObject("ButtonGet")
	self.ButtonGo = self:GetChildGameObject("ButtonGo")
	self.TexNoGet = self:GetChildComponent("NoGet", "Text")
	self.TexNoGet.text = _("Desc_Not_Get")
	self.TexLv = self:GetChildComponent("TexLv", "Text")

	for i = 1, 3 do
		local gItem = self:GetChildGameObject("ItemGroup/" .. i)

		self["cellItem" .. i] = CellItem(gItem)

		self["cellItem" .. i]:InitItemByRoot(gItem)
	end

	self:AddClick(self.ButtonGet, self.OnClickGet)
	self:AddClick(self.ButtonGo, self.OnClickedBtnGo)
end

function CellGrowthFund:OnLeave()
	return
end

function CellGrowthFund:UpdateData(info)
	self.info = info

	for i = 1, 3 do
		local infoItem = ItemManager:GetValueItem(self.info.reward[i][1], self.info.reward[i][2])

		self["cellItem" .. i]:UpdateWithNumType(infoItem)
		self["cellItem" .. i]:SetGeted(false)
	end

	self.ButtonGo:SetActive(false)
	self.ButtonGet:SetActive(false)
	self.IsGet:SetActive(false)
	self.NoGet:SetActive(false)

	if self.info.isComplete then
		if self.info.status == 3 then
			for i = 1, 3 do
				self["cellItem" .. i]:SetGeted(true)
			end

			self.IsGet:SetActive(true)
		elseif self.info.status == 2 then
			for i = 1, 2 do
				self["cellItem" .. i]:SetGeted(true)
			end

			if ShopManager:GetGrowthFund() then
				self.ButtonGet:SetActive(true)
			else
				self.ButtonGo:SetActive(true)
			end
		else
			self.ButtonGet:SetActive(true)
		end
	else
		self.NoGet:SetActive(true)
	end

	self.TexLv.text = self.info.condition
end

function CellGrowthFund:OnClickGet()
	Event.Instance:Fire("GrowthTaskGet", self.info.id)
end

function CellGrowthFund:OnClickedBtnGo()
	local fromwhere = {}

	fromwhere[1] = 1
	fromwhere[2] = tabMainType.month
	fromwhere[3] = 4

	DlgItemTip.GoToFrom(fromwhere)
end
