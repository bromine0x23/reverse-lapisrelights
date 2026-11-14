-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageClassroom/CellMail.lua

require("UI/Item/UIItemBase")

CellMail = class("CellMail", UIItemBase)

function CellMail:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellMail:Create(vParam)
	CellMail.base.Create(self, vParam)
end

function CellMail:OnEnter()
	local g = self.UIRootObject
	local textGet = GOUtil.FindChildComponent(g, "Panel/GetTime/Text", "Text")

	textGet.text = _("Mail_GetTime")

	local textLimit = GOUtil.FindChildComponent(g, "Panel/LimitTime/Text", "Text")

	textLimit.text = _("Mail_Rec_Limit")

	local textFrom = GOUtil.FindChildComponent(g, "Panel/TxtFrom", "Text")

	textFrom.text = _("Mial_Source") .. "："
	self.TxtName = GOUtil.FindChildComponent(g, "Panel/BgName/Text", "Text")
	self.TxtSource = GOUtil.FindChildComponent(g, "Panel/TxtSource", "Text")
	self.TxtGetTime = GOUtil.FindChildComponent(g, "Panel/GetTime/TxtTime", "Text")
	self.TxtLimitTime = GOUtil.FindChildComponent(g, "Panel/LimitTime/TxtTime", "Text")
	self.GetTime = GOUtil.FindChildGameObject(g, "Panel/GetTime")
	self.TxtGetTime.fontSize = 26

	GOUtil.SetRectTransformAnchoredPosition(self.TxtGetTime.gameObject, 134, 0)

	self.TxtLimitTime.fontSize = 26

	GOUtil.SetRectTransformAnchoredPosition(self.TxtLimitTime.gameObject, 134, 0)

	self.GoItem = GOUtil.FindChildGameObject(g, "Panel/Tag/Item")
	self.GoOther = GOUtil.FindChildGameObject(g, "Panel/Tag/Other")
	self.ItemIcon = GOUtil.FindChildComponent(g, "Panel/Tag/Item/Icon", "Image")
	self.ItemRank1 = GOUtil.FindChildComponent(g, "Panel/Tag/Item/Rank1", "Image")
	self.ItemRank2 = GOUtil.FindChildComponent(g, "Panel/Tag/Item/Rank2", "Image")
	self.TxtValue = GOUtil.FindChildComponent(g, "Panel/Tag/Item/Text", "Text")
	self.GoRead = GOUtil.FindChildGameObject(g, "Panel/Read")
	self.GoUnread = GOUtil.FindChildGameObject(g, "Panel/Unread")
	self.GoLock = GOUtil.FindChildGameObject(g, "Panel/Lock")
end

function CellMail:OnLeave()
	UnloadAllImageSprite(self)
end

function CellMail:UpdateData(infoMail)
	self.TxtName.text = infoMail.pb.title
	self.TxtSource.text = infoMail.pb.sender

	local sendTime = infoMail.pb.sendTime

	self.TxtGetTime.text = os.date("  %Y.%m.%d %H:%M", sendTime / DateUtil.MillsPerSecond)

	local endTime = infoMail.pb.endTime

	if endTime == 0 then
		self.TxtLimitTime.text = "  " .. _("Mail_NoLimit")

		self.GetTime.gameObject:SetActive(false)
	else
		self.TxtLimitTime.text = os.date("  %Y.%m.%d %H:%M", endTime / DateUtil.MillsPerSecond)

		self.GetTime.gameObject:SetActive(true)
	end

	local list = infoMail.assets

	if #list > 0 then
		local infoItem = list[1].infoItem

		self.TxtValue.gameObject:SetActive(false)
		ItemManager:SetItemInfo(infoItem, self.ItemIcon, self.ItemRank1, self.ItemRank2, self)
	end

	self:RefreshPanel(infoMail)
end

function CellMail:RefreshPanel(infoMail)
	local haveReaded = infoMail:IsReaded()

	self.GoRead:SetActive(haveReaded)
	self.GoUnread:SetActive(not haveReaded)

	local haveAnnex = infoMail:HaveAnnex()
	local haveReced = infoMail:IsReceived()

	self.GoItem:SetActive(haveAnnex and not haveReced)
	self.GoOther:SetActive(not haveAnnex or haveReced)

	local haveLock = infoMail:IsLocked()

	self.GoLock:SetActive(haveLock)
end
