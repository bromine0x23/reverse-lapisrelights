-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePlayerInfo/CellTitle.lua

CellTitle = class("CellTitle", UIItemBase)

local InfoTitle = require("Info/InfoTitle")

function CellTitle:ctor(itemPrefabCache, parent)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellTitle:Create(vParam)
	CellTitle.base.Create(self, vParam)
end

function CellTitle:OnEnter()
	self.lockGo = self:GetChildGameObject("Lock")
	self.upGo = self:GetChildGameObject("Up")
	self.img = self:GetChildComponent("Icon", "Image")
	self.name = self:GetChildComponent("Name", "Text")
	self.timeGo = self:GetChildGameObject("Time")
	self.downBtn = self:GetChildGameObject("DownBtn")

	self:OnRegisterEvent()
end

function CellTitle:UpdateData(data)
	self.data = data
	self.info = ItemManager:Get(data.cfg.ID)

	local haveTime = InfoTitle:TitleIsHaveTime(data.cfg.ID)

	if data.lockState == 1 and haveTime then
		SetActiveFunc(self.lockGo, false)
		DealWithListRef(self, UIUtil.SetImageGray(self.img, 0))
		SetActiveFunc(self.timeGo, data.cfg.Time ~= "")
	else
		SetActiveFunc(self.lockGo, true)
		DealWithListRef(self, UIUtil.SetImageGray(self.img, 1))
		SetActiveFunc(self.timeGo, false)
	end

	local isUp = data.cfg.ID == PlayerInst.InfoPlayer.medal and haveTime

	SetActiveFunc(self.upGo, isUp)
	SetActiveFunc(self.downBtn, isUp)
	UIUtil.SetImageSprite(self.img, self.info:GetIcon(), self)

	self.name.text = Lang(data.cfg.Name)
end

function CellTitle:OnRegisterEvent()
	self:AddClick(self.UIRootObject, self.OnClickedCell)
	self:AddClick(self.downBtn, self.OnClickedCell)
	self:AddListener(self.UIRootObject, self.OnPointerLongPressTitle, EventTriggerType.PointerLongPress)
end

function CellTitle:OnUnRegisterEvent()
	self:RemoveClick(self.UIRootObject, self.OnClickedCell)
	self:RemoveClick(self.downBtn, self.OnClickedCell)
	self:RemoveListener(self.UIRootObject, self.OnPointerLongPressTitle, EventTriggerType.PointerLongPress)
end

function CellTitle:OnClickedCell()
	if self.data.lockState == 1 then
		local haveTime = InfoTitle:TitleIsHaveTime(self.data.cfg.ID)

		if haveTime then
			if self.data.cfg.ID == PlayerInst.InfoPlayer.medal then
				self:SendChange(-1)
			else
				self:SendChange(self.data.cfg.ID)
			end
		else
			self:UpdateData(self.data)
		end
	end
end

function CellTitle:SendChange(id)
	local vals = {
		medal = id
	}

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestModifyPlayerInfo(vals, function(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			if id == -1 then
				PlayerInst.InfoPlayer.medal = 0
			else
				PlayerInst.InfoPlayer.medal = id
			end

			Event.Instance:Fire(EventEnum.UpdatePlayerInfo, ePlayerInfoType.medal)
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end)
end

function CellTitle:OnLeave()
	self:OnUnRegisterEvent()
	UnloadAllImageSprite(self)
end

function CellTitle:OnPointerLongPressTitle(data)
	if self.LongPressState then
		self.LongPressState = false

		return
	end

	if data.clickCount == 1 then
		self.LongPressState = true

		UIMgr.ShowItemTip(self.info)
	end
end
