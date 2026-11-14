-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCommunication/CellLine.lua

require("UI/Item/UIItemBase")

local actorData = require("luaData/ActorData")

CellLine = class("CellLine", UIItemBase)

function CellLine:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellLine:OnEnter(vParam)
	local g = self.UIRootObject

	self.Name = GOUtil.FindChildComponent(g, "Name", "Text")
	self.AvatarImage = GOUtil.FindChildComponent(g, "Mask/AvatarImage", "Image")
	self.Txt = GOUtil.FindChildComponent(g, "Txt", "TextView")
	self.Avator = GOUtil.FindChildGameObject(g, "Avator")
	self.AvatorBox = GOUtil.FindChildComponent(g, "AvatorBox", "Image")
	self.Vol = GOUtil.FindChildGameObject(g, "Vol")
	self.backImage = GOUtil.FindChildComponent(g, "Back", "Image")

	self:AddClick(self.Vol, self.PlayVoice)
end

function CellLine:OnLeave()
	self:RemoveClick(self.Vol, self.PlayVoice)
end

function CellLine:UpdateData(data)
	self.data = data

	local actor = actorData[data.actorId]

	self.AvatorBox.gameObject:SetActive(false)
	self.Avator.gameObject:SetActive(true)

	if actor ~= nil then
		self.Avator.gameObject:SetActive(true)
		self.AvatarImage.gameObject:SetActive(true)

		self.backImage.color = Color(1, 1, 1, 1)

		UIUtil.SetImageSprite(self.AvatarImage, actor.CharacterIcon, nil, true)

		self.Name.text = ScenarioKit.Instance.Language:Get(data.actorName)
	elseif data.actorName == "" or data.actorName == nil then
		self.AvatorBox.gameObject:SetActive(true)
		self.Avator.gameObject:SetActive(false)

		self.Name.text = PlayerInst:GetNickName()

		UIUtil.SetImageSprite(self.AvatarImage, ItemManager:Get(PlayerInst.InfoPlayer.headId):GetIcon(), nil, true)
		UIUtil.SetImageSprite(self.AvatorBox, ItemManager:Get(PlayerInst.InfoPlayer.headFrame):GetIcon(), nil)
	else
		self.Name.text = ScenarioKit.Instance.Language:Get(data.actorName)
	end

	if not string.isNullOrEmpty(data.strIcon) then
		UIUtil.SetImageSprite(self.AvatarImage, data.strIcon, nil, true)
	end

	if not data.vol then
		self.Vol:SetActive(false)
	else
		self.Vol:SetActive(true)
	end

	self.Txt.Text = ScenarioKit.Instance.Language:Get(data.Txt)
end

function CellLine:PlayVoice()
	Event.Instance:Fire("DlgHistoryPlayVoice", self.data.vol)
end
