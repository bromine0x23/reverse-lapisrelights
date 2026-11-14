-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellJigsaw.lua

require("UI/Item/UIItemBase")

CellJigsaw = class("CellJigsaw", UIItemBase)

function CellJigsaw:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellJigsaw:OnEnter()
	self.Main = self:GetChildGameObject("Panel/Main")
	self.FX = self:GetChildGameObject("Panel/FX")
	self.Select = self:GetChildGameObject("Panel/Select")
	self.BtnGo = self:GetChildGameObject("Panel/Select/BtnGo")
	self.ImgPanel = self:GetChildComponent("Panel", "Image")
	self.TexTitle = self:GetChildComponent("Panel/Main/TexTitle", "Text")
	self.TexConfident = self:GetChildComponent("Panel/Main/TexConfident", "Text")
	self.TexDes = self:GetChildComponent("Panel/Main/Image2/TexDes", "Text")

	self:AddClick(self.UIRootObject, self.OnClickSelcet)
	self:AddClick(self.BtnGo, self.OnClickedBtnGo)
end

function CellJigsaw:OnLeave()
	UnloadAllImageSprite(self)
	self:RemoveClick(self.UIRootObject, self.OnClickSelcet)
	self:RemoveClick(self.BtnGo, self.OnClickedBtnGo)
end

function CellJigsaw:UpdateData(info)
	self.info = info

	UIUtil.SetImageSprite(self.ImgPanel, info.img, self)

	if info.complete then
		self.Select:SetActive(false)
		self.Main:SetActive(false)

		self.ImgPanel.material = nil

		return
	end

	self.TexDes.text = info.des
	self.TexTitle.text = info.title
	self.TexConfident.text = info.condition

	self.Select:SetActive(info.select)
end

function CellJigsaw:OnClickSelcet()
	Event.Instance:Fire("CellJigaswSelect", self.info.index)
end

function CellJigsaw:OnClickedBtnGo()
	if #self.info.FromWhere > 0 then
		OperationActiveMgr.Tag = eOperationActive.Jigsaw

		DlgItemTip.GoToFrom(self.info.FromWhere[1], nil)
	end
end

function CellJigsaw:PlayFX()
	self.FX:SetActive(true)
end

function CellJigsaw:StopFX()
	self.FX:SetActive(false)
end
