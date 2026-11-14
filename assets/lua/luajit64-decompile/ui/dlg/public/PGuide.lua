-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Public/PGuide.lua

PGuide = class("PGuide", UIPanel)

function PGuide:ctor()
	self.UIPrefabPath = "UI/CommonTip/PGuide/PGuide"
end

function PGuide:Purge()
	self.base.Purge(self)
end

function PGuide:OnRegisterEvent()
	self:AddClick(self.BtnNext, self.OnClickedBtnNext)
	self:AddClick(self.BtnBefore, self.OnClickedBtnBefore)
	self:AddClick(self.BtnClose, self.OnClickedBtnClose)
	self:AddListener(self.DragArea, self.OnBeginDrag, EventTriggerType.BeginDrag)
	self:AddListener(self.DragArea, self.OnDrag, EventTriggerType.Drag)
	self:AddListener(self.DragArea, self.OnEndDrag, EventTriggerType.EndDrag)
end

function PGuide:OnUnRegisterEvent()
	self:RemoveClick(self.BtnNext, self.OnClickedBtnNext)
	self:RemoveClick(self.BtnBefore, self.OnClickedBtnBefore)
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
	self:RemoveListener(self.DragArea, self.OnBeginDrag, EventTriggerType.BeginDrag)
	self:RemoveListener(self.DragArea, self.OnDrag, EventTriggerType.Drag)
	self:RemoveListener(self.DragArea, self.OnEndDrag, EventTriggerType.EndDrag)
end

function PGuide:OnEnter(vParam)
	self.RawImage = self:GetChildComponent("RawImage", "RawImage")
	self.BtnNext = self:GetChildGameObject("BtnNext")
	self.BtnBefore = self:GetChildGameObject("BtnBefore")
	self.DragArea = self:GetChildGameObject("DragArea")
	self.BtnClose = self:GetChildGameObject("BtnClose")
	self.PageIndex = self:GetChildComponent("Text", "Text")

	local text = self:GetChildComponent("BtnClose/Text", "Text")

	self:Init(vParam)
end

function PGuide:Init(vParam)
	self.panelId = vParam
	self.listShow, self.list = GuideMgr:GetGuidTextures(self.panelId)
	self.showCount = #self.listShow

	local _, index = GuideMgr:IsGuided(self.panelId)

	self.curTextureIdx = 1

	if index and index ~= 0 then
		self.openIdx = index

		if self.listShow[index] == self.list[index] then
			self.curTextureIdx = index
		else
			local showIdx = table.getIndex(self.listShow, self.list[index])

			self.curTextureIdx = showIdx == -1 and 1 or showIdx
		end
	end

	self:UpdatePanel()
end

function PGuide:UpdatePanel()
	local strId = self.listShow[self.curTextureIdx]

	if strId == nil then
		self:Close()
		InstructionMgr:TriggerWait("CloseGuidePic")

		return
	end

	if strId < 10 then
		strId = "00" .. strId
	elseif strId >= 10 and strId < 100 then
		strId = "0" .. strId
	end

	UIUtil.SetRawImageTexture(self.RawImage, "Texture/Guide/guid_" .. strId, self)

	self.PageIndex.text = "<color=#FF3C78>" .. self.curTextureIdx .. "</color><color=#3197A1>/" .. self.showCount .. "</color>"

	self.BtnNext:SetActive(self.curTextureIdx ~= self.showCount)
	self.BtnBefore:SetActive(self.curTextureIdx ~= 1)
	self.BtnClose:SetActive(self.curTextureIdx == self.showCount)
end

function PGuide:OnClickedBtnNext()
	self.curTextureIdx = self.curTextureIdx + 1

	if self.curTextureIdx > self.showCount then
		self.curTextureIdx = self.showCount
	end

	self:UpdatePanel()
end

function PGuide:OnClickedBtnBefore()
	self.curTextureIdx = self.curTextureIdx - 1

	if self.curTextureIdx < 1 then
		self.curTextureIdx = 1
	end

	self:UpdatePanel()
end

function PGuide:OnDrag(data)
	return
end

function PGuide:OnBeginDrag(data)
	self.isDrag = true
end

function PGuide:OnEndDrag(data)
	local dragPosX = data.pressPosition.x - data.position.x

	if dragPosX > 500 then
		self.curTextureIdx = self.curTextureIdx + 1

		if self.curTextureIdx > self.showCount then
			self.curTextureIdx = self.showCount
		end

		self:UpdatePanel()
	elseif dragPosX < -500 then
		self.curTextureIdx = self.curTextureIdx - 1

		if self.curTextureIdx < 1 then
			self.curTextureIdx = 1
		end

		self:UpdatePanel()
	end

	self.isDrag = false
end

function PGuide:OnClickedBtnClose()
	if self.curTextureIdx == self.showCount and not self.isDrag then
		GuideMgr:Record(self.panelId, self.openIdx)
		self:Close()
		InstructionMgr:TriggerWait("CloseGuidePic")
	end
end

function PGuide:OnBackAndroid()
	GuideMgr:Record(self.panelId, self.openIdx)
	self:Close()
	InstructionMgr:TriggerWait("CloseGuidePic")
end
