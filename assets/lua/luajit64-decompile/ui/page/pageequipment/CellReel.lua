-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageEquipment/CellReel.lua

require("UI/Item/UIItemBase")

CellReel = class("CellReel", UIItemBase)

function CellReel:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellReel:OnEnter(vParam)
	local g = self.UIRootObject

	self.Icon = GOUtil.FindChildComponent(g, "Icon", "Image")
	self.ImgRank1 = GOUtil.FindChildComponent(g, "Rank1", "Image")
	self.ImgRank2 = GOUtil.FindChildComponent(g, "Rank2", "Image")
	self.TxtHold = GOUtil.FindChildComponent(g, "Text", "Text")
	self.GoRecom = GOUtil.FindChildGameObject(g, "GoRecom")
	self.GoSel = GOUtil.FindChildGameObject(g, "GoSel")
	self.GoDot = GOUtil.FindChildGameObject(g, "Dot")
	self.gImgGray = GOUtil.FindChildGameObject(g, "ImgGray")
end

function CellReel:OnLeave()
	UnloadAllImageSprite(self)
end

function CellReel:UpdateData(itemId, index, isGray)
	local isSelected

	if type(index) == "number" then
		isSelected = self.Index == index
	else
		isSelected = index == true
	end

	self.info = ItemManager:Get(itemId)

	if self.info == nil then
		return
	end

	UIUtil.SetImageSprite(self.Icon, self.info.data.Icon, self)

	local quality = self.info.data.Quality

	UIUtil.SetImageSprite(self.ImgRank1, "UIDyAtlas/ItemRarity/BG_frame_item_0" .. quality .. "_b", self)
	UIUtil.SetImageSprite(self.ImgRank2, "UIDyAtlas/ItemRarity/BG_frame_item_0" .. quality .. "_a", self)
	self:UpdateHoldNum()

	if isGray ~= nil then
		self:SetGray(isGray)
	end

	self:UpdateSelectState(isSelected)
	self:UpdateDot()
end

function CellReel:UpdateHoldNum()
	if self.info then
		self.TxtHold.text = self.info:GetCurResNum()

		if self.TxtHold.text == "0" then
			self:SetGray(true)
			self:UpdateSelectState(false)
		else
			self:SetGray(false)
		end
	end
end

function CellReel:SetGray(b)
	if not b and self.TxtHold.text == "0" then
		b = true
	end

	GOUtil.SetActive(self.gImgGray, b)
end

function CellReel:IsActive()
	return not GOUtil.IsActiveSelf(self.gImgGray) or GOUtil.IsActiveSelf(self.GoSel)
end

function CellReel:UpdateSelectState(vBool)
	if vBool and self.TxtHold.text == "0" then
		vBool = false
	end

	GOUtil.SetActive(self.GoSel, vBool)
end

function CellReel:UpdateDot()
	local isNew = RoleRDL.EquipRDL.IsNewEnchantReel(self.info.id)

	GOUtil.SetActive(self.GoDot, isNew)
end

function CellReel:GetRank(qua)
	if qua == 1 then
		return "R"
	elseif qua == 2 then
		return "SR"
	elseif qua == 3 then
		return "SSR"
	elseif qua == 4 then
		return "UR"
	end

	return "R"
end
