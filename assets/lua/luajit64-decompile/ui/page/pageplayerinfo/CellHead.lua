-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePlayerInfo/CellHead.lua

CellHead = class("CellHead", UIItemBase)

local InfoTitle = require("Info/InfoTitle")

function CellHead:ctor(itemPrefabCache, parent, ownUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellHead:Create(vParam)
	CellHead.base.Create(self, vParam)
end

function CellHead:OnEnter()
	self.lockGo = self:GetChildGameObject("Lock")
	self.upGo = self:GetChildGameObject("Up")
	self.img = self:GetChildComponent("Icon", "Image")
	self.name = self:GetChildComponent("Name", "Text")

	for i = 1, 2 do
		self["type" .. i] = self:GetChildGameObject("type" .. i)
		self["lockGo" .. i] = self:GetChildGameObject("type" .. i .. "/Lock")
		self["upGo" .. i] = self:GetChildGameObject("type" .. i .. "/Up")
		self["img" .. i] = self:GetChildComponent("type" .. i .. "/Icon", "Image")
		self["name" .. i] = self:GetChildComponent("type" .. i .. "/Name", "Text")
	end

	self.dot = self:GetChildGameObject("PDot")

	self:OnRegisterEvent()
end

function CellHead:UpdateData(data, index, class)
	self.data = data
	self.index = index
	self.ParentClass = class
	self.info = ItemManager:Get(data.cfg.ID)

	for i = 1, 2 do
		SetActiveFunc(self["type" .. i], index == i)

		if index == i then
			SetActiveFunc(self["lockGo" .. i], data.lockState ~= 1)

			if index == 1 then
				SetActiveFunc(self["upGo" .. i], data.cfg.ID == PlayerInst.InfoPlayer.headId)
			else
				SetActiveFunc(self["upGo" .. i], data.cfg.ID == PlayerInst.InfoPlayer.headFrame)
			end

			DealWithListRef(self, UIUtil.SetImageGray(self["img" .. i], data.lockState == 1 and 0 or 1))
			UIUtil.SetImageSprite(self["img" .. i], self.info:GetIcon(), self)

			self["name" .. i] = Lang(self.info.data.Name)
		end
	end

	SetActiveFunc(self.dot, false)
end

function CellHead:OnRegisterEvent()
	self:AddListener(self.UIRootObject, self.OnPointerLongPressHead, EventTriggerType.PointerLongPress)
	self:AddClick(self.UIRootObject, self.OnClickedCell)
end

function CellHead:OnUnRegisterEvent()
	self:RemoveListener(self.UIRootObject, self.OnPointerLongPressHead, EventTriggerType.PointerLongPress)
	self:RemoveClick(self.UIRootObject, self.OnClickedCell)
end

function CellHead:OnClickedCell()
	if self.index == 1 then
		if self.data.lockState == 1 and PlayerInst.InfoPlayer.headId ~= self.data.cfg.ID then
			self:SendHeadChange(self.data.cfg.ID)
			SetActiveFunc(self.dot, false)
		end
	elseif self.data.lockState == 1 and PlayerInst.InfoPlayer.headFrame ~= self.data.cfg.ID then
		self:SendFrameChange(self.data.cfg.ID)
		SetActiveFunc(self.dot, false)
	end
end

function CellHead:OnPointerLongPressHead(data)
	if self.LongPressState then
		self.LongPressState = false

		return
	end

	if data.clickCount == 1 then
		self.LongPressState = true

		if self.index == 1 then
			UIMgr.ShowItemTip(self.info, 1, false, true, function()
				if self.page then
					self.page:Close()
				end
			end)
		else
			UIMgr.ShowItemTip(self.info, 1, false, false, function()
				if self.page then
					self.page:Close()
				end
			end)
		end
	end
end

function CellHead:SendHeadChange(id)
	local vals = {
		headId = id
	}

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestModifyPlayerInfo(vals, function(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			PlayerInst.InfoPlayer.headId = id

			Event.Instance:Fire(EventEnum.UpdatePlayerInfo, ePlayerInfoType.head)
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end)
end

function CellHead:SendFrameChange(id)
	local vals = {
		headFrame = id
	}

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestModifyPlayerInfo(vals, function(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			PlayerInst.InfoPlayer.headFrame = id

			Event.Instance:Fire(EventEnum.UpdatePlayerInfo, ePlayerInfoType.headFrame)
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end)
end

function CellHead:OnLeave()
	self:OnUnRegisterEvent()
	UnloadAllImageSprite(self)
end
