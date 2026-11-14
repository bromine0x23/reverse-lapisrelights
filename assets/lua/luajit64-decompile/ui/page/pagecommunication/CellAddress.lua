-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCommunication/CellAddress.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageCommunication/PagePhoneMsgList")

CellAddress = class("CellAddress", UIItemBase)

function CellAddress:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellAddress:OnEnter(vParam)
	local g = self.UIRootObject

	self.ImageIcon = GOUtil.FindChildComponent(g, "Head/Icon", "Image")
	self.TextCount = GOUtil.FindChildComponent(g, "Image/Count/Text", "Text")
	self.GoCount = GOUtil.FindChildGameObject(g, "Image/Count")
	self.GoImgGeted = self:GetChildGameObject("Image/Image1")
	self.ImageColor = GOUtil.FindChildComponent(g, "Head/Image", "Image")
	self.InputField = GOUtil.FindChildComponent(g, "InputField", "InputField")
	self.TextName = GOUtil.FindChildComponent(g, "Image/Text", "Text")

	local function wrap_cb(str)
		self:OnInputFieldChange(str)
	end

	self.InputField.onEndEdit:AddListener(wrap_cb)
end

function CellAddress:OnLeave()
	return
end

function CellAddress:OnInputFieldChange(str)
	if self.infoRole:GetCommuName() == str then
		self.InputField.text = self.infoRole:GetCommuName()
		self.TextName.text = self.InputField.text

		return
	end

	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			self.infoRole.pb.nickName = self.InputField.text
			self.TextName.text = self.infoRole.pb.nickName
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)

			self.InputField.text = self.infoRole:GetCommuName()
			self.TextName.text = self.InputField.text
		end
	end

	NetManager:RequestModifyTopicName(self.roleId, self.InputField.text, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function CellAddress:UpdateData(roleId, tabIndex, showModify)
	self.roleId = roleId

	local infoRole = RoleMgr:GetRole(roleId)

	self.infoRole = infoRole

	UIUtil.SetImageSprite(self.ImageIcon, infoRole.actorData.CharacterIcon)

	self.ImageColor.color = getColorFromString(infoRole.data.Color)
	self.InputField.text = self.infoRole:GetCommuName()
	self.TextName.text = self.InputField.text

	self.GoImgGeted:SetActive(true)

	if tabIndex == 1 then
		local listTopic = TopicManager:GetListTopic(roleId, 0)
		local listTopicGeted = TopicManager:GetListTopic(roleId, 1)

		self.topicNum = #listTopic
		self.topicGetNum = #listTopicGeted
	else
		local listCall = PhoneCallManager:GetListTopic(roleId, 0)
		local listCallGeted = PhoneCallManager:GetListTopic(roleId, 1)

		self.topicNum = #listCall
		self.topicGetNum = #listCallGeted
	end

	if self.topicNum == 0 then
		self.GoCount:SetActive(false)

		if self.topicGetNum == 0 then
			self.GoImgGeted:SetActive(false)
		end
	else
		self.GoCount:SetActive(true)

		self.TextCount.text = self.topicNum
	end

	if showModify then
		self.TextName.gameObject:SetActive(false)
		self.InputField.gameObject:SetActive(true)
	else
		self.TextName.gameObject:SetActive(true)
		self.InputField.gameObject:SetActive(false)
	end
end
