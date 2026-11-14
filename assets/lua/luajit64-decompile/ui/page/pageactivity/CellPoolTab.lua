-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivity/CellPoolTab.lua

require("UI/Item/UIItemBase")

CellPoolTab = class("CellPoolTab", UIItemBase)

function CellPoolTab:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellPoolTab:OnLeave()
	self:OnUnRegisterEvent()
	UnloadAllImageSprite(self)
end

function CellPoolTab:OnEnter(vParam)
	local g = self.UIRootObject

	self.Button = GOUtil.FindChildGameObject(g, "Button")
	self.ImgBtn = GOUtil.FindChildComponent(g, "Button", "Image")
	self.ImgSelect = GOUtil.FindChildGameObject(g, "Select")
	self.ImgType = GOUtil.FindChildComponent(g, "Type", "Image")
	self.CanOpenText = GOUtil.FindChildComponent(g, "Type/CanOpenText", "Text")
	self.CloseText = GOUtil.FindChildComponent(g, "Type/CloseText", "Text")
	self.GoLock = self:GetChildGameObject("Lock")
	self.Num = self:GetChildComponent("Num", "Text")
	self.NoLimit = self:GetChildComponent("NoLimit", "Image")
	self.Mask = self:GetChildGameObject("Mask")
	self.Name = self:GetChildComponent("Name", "Text")
	self.CanOpenText.text = _("Activate_Open")
	self.CloseText.text = _("Activate_Close")
end

function CellPoolTab:OnRegisterEvent()
	self:AddClick(self.Button, self.OnClicked)
end

function CellPoolTab:OnUnRegisterEvent()
	self:RemoveClick(self.Button, self.OnClicked)
end

function CellPoolTab:OnClicked()
	Event.Instance:Fire("ClickPoolTab", self.Index)
end

function CellPoolTab:UpdateData(info, selectIndex)
	if selectIndex == self.Index then
		self.ImgSelect.gameObject:SetActive(true)
	else
		self.ImgSelect.gameObject:SetActive(false)
	end

	self.Num.text = "No<size=57>." .. self.Index .. "</size>"
	self.Name.text = Lang(info.data.Name)

	self.NoLimit.gameObject:SetActive(info.data.NoLimit == 1)

	if info:IsDrawOut() then
		DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtn, 1))
		DealWithListRef(self, UIUtil.SetImageGray(self.ImgType, 1))
		DealWithListRef(self, UIUtil.SetImageGray(self.NoLimit, 1))
		self.ImgType.gameObject:SetActive(true)
		self.CanOpenText.gameObject:SetActive(false)
		self.CloseText.gameObject:SetActive(true)
		self.GoLock:SetActive(false)
		self.Mask:SetActive(true)
	elseif info:IsCanOpen() then
		DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtn, 0))
		DealWithListRef(self, UIUtil.SetImageGray(self.ImgType, 0))
		DealWithListRef(self, UIUtil.SetImageGray(self.NoLimit, 0))
		self.ImgType.gameObject:SetActive(true)
		self.CanOpenText.gameObject:SetActive(true)
		self.CloseText.gameObject:SetActive(false)
		self.GoLock:SetActive(false)
		self.Mask:SetActive(false)
	elseif info:IsLock() then
		DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtn, 0))
		DealWithListRef(self, UIUtil.SetImageGray(self.ImgType, 1))
		DealWithListRef(self, UIUtil.SetImageGray(self.NoLimit, 1))
		self.ImgType.gameObject:SetActive(false)
		self.CanOpenText.gameObject:SetActive(false)
		self.CloseText.gameObject:SetActive(false)
		self.GoLock:SetActive(true)
		self.Mask:SetActive(true)
	else
		DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtn, 0))
		DealWithListRef(self, UIUtil.SetImageGray(self.ImgType, 0))
		DealWithListRef(self, UIUtil.SetImageGray(self.NoLimit, 0))
		self.ImgType.gameObject:SetActive(false)
		self.GoLock:SetActive(false)
		self.Mask:SetActive(false)
	end

	if self.Index == 1 then
		if not info:IsDrawOut() then
			self.ImgType.gameObject:SetActive(false)
			self.Mask:SetActive(false)
		end

		self.GoLock:SetActive(false)
	end
end
