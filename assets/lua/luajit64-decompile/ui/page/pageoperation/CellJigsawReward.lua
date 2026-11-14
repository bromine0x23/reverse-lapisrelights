-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellJigsawReward.lua

require("UI/Item/UIItemBase")

eRewardState = {
	CanGet = 2,
	NoGet = 1,
	IsGeted = 3
}
CellJigsawReward = class("CellJigsawReward", UIItemBase)

function CellJigsawReward:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellJigsawReward:OnEnter()
	self.TexProgress = self:GetChildComponent("TexProgress", "Text")
	self.ObjCanGet = self:GetChildGameObject("ImgCanGet")
	self.BtnGet = self:GetChildGameObject("BtnGet")
	self.FX = self:GetChildGameObject("FX")

	local gItem = self:GetChildGameObject("CellItem")

	self.CellItem = CellItem(gItem)

	self.CellItem:InitItemByRoot(gItem)
	self:AddClick(self.BtnGet, self.OnClickedBtnRecv)
end

function CellJigsawReward:OnLeave()
	UnloadAllImageSprite(self)
	self:RemoveClick(self.BtnGet, self.OnClickedBtnRecv)
	self.CellItem:OnLeave()
end

function CellJigsawReward:UpdateData(info)
	self.info = info

	if info.state == eRewardState.NoGet then
		self.CellItem:SetGray(1)
		self.ObjCanGet:SetActive(false)
		self.CellItem:SetGetedGreen(false)
		self.BtnGet:SetActive(false)
		self.FX:SetActive(false)
	elseif info.state == eRewardState.CanGet then
		self.CellItem:SetGray(0)
		self.ObjCanGet:SetActive(true)
		self.CellItem:SetGetedGreen(false)
		self.BtnGet:SetActive(true)
		self.FX:SetActive(true)
	elseif info.state == eRewardState.IsGeted then
		self.CellItem:SetGray(0)
		self.ObjCanGet:SetActive(false)
		self.CellItem:SetGetedGreen(true)
		self.BtnGet:SetActive(false)
		self.FX:SetActive(false)
	end

	self.TexProgress.text = info.progress

	local infoItem = ItemManager:GetValueItem(self.info.itemList[1][1], self.info.itemList[1][2])

	self.CellItem:UpdateWithNumType(infoItem)
end

function CellJigsawReward:OnClickedBtnRecv(data)
	if self.info.state == eRewardState.CanGet then
		Event.Instance:Fire("GetJigsawReward", self.info.index)
	end
end
