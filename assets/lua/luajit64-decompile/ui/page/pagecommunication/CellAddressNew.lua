-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCommunication/CellAddressNew.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageCommunication/PagePhoneMsgList")

CellAddressNew = class("CellAddressNew", UIItemBase)

function CellAddressNew:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellAddressNew:OnEnter(vParam)
	local g = self.UIRootObject

	self.ImageIcon = GOUtil.FindChildComponent(g, "Head/HeadIcon", "Image")
	self.ImageTeamIcon = GOUtil.FindChildComponent(g, "TeamIcon", "Image")
	self.TextName = GOUtil.FindChildComponent(g, "Name", "Text")
	self.TopicCountCount = GOUtil.FindChildComponent(g, "TopicCount", "Text")
	self.PhoneCountCount = GOUtil.FindChildComponent(g, "PhoneCount", "Text")
	self.SelectBg = GOUtil.FindChildGameObject(g, "SelectBg")
	self.UnSelectBg = GOUtil.FindChildGameObject(g, "UnSelectBg")
end

function CellAddressNew:OnLeave()
	return
end

function CellAddressNew:UpdateData(infoRole, isSelect, typeIdx)
	self.infoRole = infoRole

	UIUtil.SetImageSprite(self.ImageTeamIcon, "UIDyAtlas/Team/BG_mark_" .. self.infoRole.data.Team .. "00", self.page)
	UIUtil.SetImageSprite(self.ImageIcon, self.infoRole.actorData.CharacterIcon, self.page)

	self.TextName.text = self.infoRole:GetCommuName()

	local listTopicGetedReward = TopicManager:GetListTopic(self.infoRole.id, 0)
	local listTopicGeted = TopicManager:GetListTopic(self.infoRole.id)

	self.topicGetNum = #listTopicGeted
	self.topicGetRewardNum = #listTopicGetedReward

	local listCallGetedReward = PhoneCallManager:GetListTopic(self.infoRole.id, 0)
	local listCallGeted = PhoneCallManager:GetListTopic(self.infoRole.id)

	self.phoneGetNum = #listCallGeted
	self.phoneGetRewardNum = #listCallGetedReward

	if self.topicGetRewardNum == 0 then
		self.TopicCountCount.text = self.topicGetRewardNum .. "/" .. self.topicGetNum
	else
		self.TopicCountCount.text = "<color=red>" .. self.topicGetRewardNum .. "</color>" .. "/" .. self.topicGetNum
	end

	if self.phoneGetRewardNum == 0 then
		self.PhoneCountCount.text = self.phoneGetRewardNum .. "/" .. self.phoneGetNum
	else
		self.PhoneCountCount.text = "<color=red>" .. self.phoneGetRewardNum .. "</color>" .. "/" .. self.phoneGetNum
	end

	self.typeIdx = typeIdx

	self:SetDot()
	self:SetSelectImage(isSelect)
end

function CellAddressNew:SetSelectImage(isSelect)
	self.SelectBg:SetActive(isSelect)
	self.UnSelectBg:SetActive(not isSelect)
end

function CellAddressNew:SetDot()
	if self.typeIdx then
		local path

		if self.typeIdx == 1 then
			path = string.format("Communication/News/%d/%d", self.infoRole.data.Team, self.infoRole.id)
		else
			path = string.format("Communication/Call/%d/%d", self.infoRole.data.Team, self.infoRole.id)
		end

		RedDotSystemMgr.SetUIRedDot(self.UIRootObject, path)
	end
end
