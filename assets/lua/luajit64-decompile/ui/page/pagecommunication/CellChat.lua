-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCommunication/CellChat.lua

require("UI/Item/UIItemBase")

local ActorData = require("luaData/ActorData")

CellChat = class("CellChat", UIItemBase)

function CellChat:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.Page = page
end

function CellChat:OnEnter(vParam)
	local g = self.UIRootObject
	local text1 = GOUtil.FindChildComponent(g, "2/Bg2/Text1", "Text")

	text1.text = _("Desc_UnRead")

	local text2 = GOUtil.FindChildComponent(g, "2/Bg2/Text2", "Text")

	text2.text = _("Desc_Read")
	self.Text1 = GOUtil.FindChildComponent(g, "1/Bg/Text", "TextView")
	self.Text2 = GOUtil.FindChildComponent(g, "2/Bg2/Text", "TextView")
	self.Image1 = GOUtil.FindChildComponent(g, "1/Head1/Icon", "Image")
	self.Image1Color = GOUtil.FindChildComponent(g, "1/Head1/Image", "Image")
	self.Image2 = GOUtil.FindChildComponent(g, "2/Head2/Icon", "Image")
	self.Bg2 = self:GetChildComponent("2/Bg2", "Image")
	self.Go1 = GOUtil.FindChildGameObject(g, "1")
	self.Go2 = GOUtil.FindChildGameObject(g, "2")
	self.GoWait = GOUtil.FindChildGameObject(g, "TextWait")
	self.GoUnRead = GOUtil.FindChildGameObject(g, "2/Bg2/Text1")
	self.GoReaded = GOUtil.FindChildGameObject(g, "2/Bg2/Text2")
end

function CellChat:OnLeave()
	return
end

function CellChat:OnClickedMsg()
	return
end

function CellChat:UpdateData(chatData)
	local actorId = chatData.actorId
	local content = chatData.content
	local flag = chatData.flag
	local isReaded = chatData.isReaded
	local isEnd = chatData.isEnd

	if flag == 1 then
		self.GoWait:SetActive(true)
		self.Go1:SetActive(false)
		self.Go2:SetActive(false)
		self.Text1.gameObject:SetActive(false)
		self.Text2.gameObject:SetActive(false)
	else
		self.GoWait:SetActive(false)
		self.Text1.gameObject:SetActive(true)
		self.Text2.gameObject:SetActive(true)

		self.Text1.Text = content
		self.Text2.Text = content

		UIUtil.ForceRebuildLayoutImmediate(self.Image1.gameObject)
		UIUtil.ForceRebuildLayoutImmediate(self.Image2.gameObject)

		if actorId > 0 then
			self.Go1:SetActive(true)
			self.Go2:SetActive(false)

			local actorData = ActorData[actorId]

			UIUtil.SetImageSprite(self.Image1, actorData.CharacterIcon, self.Page)
			SoundMgr.PostEvent(PATH_SFX_UI_TOPIC_GETNEWMSG, UIMgr.UICamera.gameObject)
		elseif actorId == 0 then
			self.Go1:SetActive(false)
			self.Go2:SetActive(true)

			if isReaded then
				self.GoUnRead:SetActive(false)
				self.GoReaded:SetActive(true)
			else
				self.GoUnRead:SetActive(true)
				self.GoReaded:SetActive(false)
			end
		else
			SoundMgr.PostEvent(PATH_SFX_UI_TOPIC_SENDMSG, UIMgr.UICamera.gameObject)
			self.Go1:SetActive(false)
			self.Go2:SetActive(true)

			if PlayerInst then
				UIUtil.SetImageSprite(self.Image2, ItemManager:Get(PlayerInst.InfoPlayer.headId):GetIcon(), self.Page)
			end

			self.GoUnRead:SetActive(false)
			self.GoReaded:SetActive(true)
		end
	end

	if flag == 2 then
		isEnd = true
	end
end
