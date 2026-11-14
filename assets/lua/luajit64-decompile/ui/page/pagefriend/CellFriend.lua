-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFriend/CellFriend.lua

require("UI/Item/UIItemBase")

CellFriend = class("CellFriend", UIItemBase)

function CellFriend:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.callback = nil
end

function CellFriend:Create(vParam)
	CellFriend.base.Create(self, vParam)
end

function CellFriend:OnEnter()
	local g = self.UIRootObject
	local Text = GOUtil.FindChildComponent(g, "BtnAdd/Text", "Text")

	Text.text = _("CellFriend_Apply")
	Text = GOUtil.FindChildComponent(g, "BtnRefuse/Text", "Text")
	Text.text = _("UI_Refuse")
	Text = GOUtil.FindChildComponent(g, "BtnAgree/Text", "Text")
	Text.text = _("UI_Agree")
	Text = GOUtil.FindChildComponent(g, "BtnUnblock/Text", "Text")
	Text.text = _("UI_Unblock")
	self.TextPlayerName = GOUtil.FindChildComponent(g, "BgInfo/TxtName", "Text")
	self.TextPlayerLevel = GOUtil.FindChildComponent(g, "BgInfo/TxtLv", "Text")
	self.ImgPlayerHead = GOUtil.FindChildComponent(g, "HeadIcon/Icon", "Image")
	self.ImgPlayerHeadFrame = GOUtil.FindChildComponent(g, "HeadIcon/Frame", "Image")
	self.TextLineState = GOUtil.FindChildComponent(g, "State/Text", "Text")
	self.GoHead = GOUtil.FindChildGameObject(g, "HeadIcon")
	self.BtnAdd = GOUtil.FindChildGameObject(g, "BtnAdd")
	self.BtnGift = GOUtil.FindChildGameObject(g, "BtnGift")
	self.BtnRecv = GOUtil.FindChildGameObject(g, "BtnRecv")
	self.BtnAgree = GOUtil.FindChildGameObject(g, "BtnAgree")
	self.BtnRefuse = GOUtil.FindChildGameObject(g, "BtnRefuse")
	self.BtnUnblock = GOUtil.FindChildGameObject(g, "BtnUnblock")
	self.ImgBtnGift = GOUtil.GetComponent(self.BtnGift, "Image")
	self.ImgBtnRecv = GOUtil.GetComponent(self.BtnRecv, "Image")

	self:OnRegisterEvent()
end

function CellFriend:OnRegisterEvent()
	self:AddClick(self.GoHead, self.OnClickHeadIcon)
	self:AddClick(self.BtnAdd, self.OnClickBtnAdd)
	self:AddClick(self.BtnGift, self.OnClickBtnGift)
	self:AddClick(self.BtnRecv, self.OnClickBtnRecv)
	self:AddClick(self.BtnAgree, self.OnClickBtnAgree)
	self:AddClick(self.BtnRefuse, self.OnClickBtnRefuse)
	self:AddClick(self.BtnUnblock, self.OnClickBtnUnblock)
end

function CellFriend:OnUnRegisterEvent()
	self:RemoveClick(self.GoHead, self.OnClickHeadIcon)
	self:RemoveClick(self.BtnAdd, self.OnClickBtnAdd)
	self:RemoveClick(self.BtnGift, self.OnClickBtnGift)
	self:RemoveClick(self.BtnRecv, self.OnClickBtnRecv)
	self:RemoveClick(self.BtnAgree, self.OnClickBtnAgree)
	self:RemoveClick(self.BtnRefuse, self.OnClickBtnRefuse)
	self:RemoveClick(self.BtnUnblock, self.OnClickBtnUnblock)
end

function CellFriend:OnLeave()
	self:OnUnRegisterEvent()
	UnloadAllImageSprite(self)

	self.callback = nil
end

function CellFriend:UpdateData(info, _type, callback)
	self.info = info
	self.type = _type
	self.callback = callback

	local isFriend = FriendMgr:IsGameFriend(info.id)

	self.isFriend = isFriend

	local isBlack = FriendMgr:IsBlackFriend(info.id)

	self.TextPlayerName.text = info.pb.nickname
	self.TextPlayerLevel.text = string.format(Lang(12354), info.level)

	local infoItem = ItemManager:Get(info.pb.headId)

	UIUtil.SetImageSprite(self.ImgPlayerHead, infoItem:GetIcon(), self)

	infoItem = ItemManager:Get(info.pb.headFrame)

	UIUtil.SetImageSprite(self.ImgPlayerHeadFrame, infoItem:GetIcon(), self)

	if info.pb.isOnline then
		self.TextLineState.text = Lang(12501)
	else
		self.TextLineState.text = info:GetStrLogoutTime()
	end

	SetActiveFunc(self.BtnAdd, false)
	SetActiveFunc(self.BtnAgree, false)
	SetActiveFunc(self.BtnRefuse, false)
	SetActiveFunc(self.BtnUnblock, false)
	SetActiveFunc(self.BtnGift, false)
	SetActiveFunc(self.BtnRecv, false)

	if _type == eFLType.friend then
		SetActiveFunc(self.BtnRecv, info:IsGiftToMe())
		SetActiveFunc(self.BtnGift, not info:IsGiftToMe())

		local gray = TenaryOp(info:IsGiftToday(), 1, 0)

		UIUtil.SetImageGray(self.ImgBtnGift, gray)

		gray = TenaryOp(InfoGameInst:IsOverRecvFriendCoinNumToday(), 1, 0)

		UIUtil.SetImageGray(self.ImgBtnRecv, gray)
	elseif _type == eFLType.recommond then
		SetActiveFunc(self.BtnAdd, true)
	elseif _type == eFLType.request then
		SetActiveFunc(self.BtnAgree, true)
		SetActiveFunc(self.BtnRefuse, true)
	elseif _type == eFLType.search then
		SetActiveFunc(self.BtnAdd, not isFriend and not isBlack)
		SetActiveFunc(self.BtnUnblock, isBlack)
		SetActiveFunc(self.BtnRecv, isFriend and FriendMgr:GetInfoFriend(info.id):IsGiftToMe())
		SetActiveFunc(self.BtnGift, isFriend and not FriendMgr:GetInfoFriend(info.id):IsGiftToMe())

		local gray = TenaryOp(isFriend and FriendMgr:GetInfoFriend(info.id):IsGiftToday(), 1, 0)

		UIUtil.SetImageGray(self.ImgBtnGift, gray)
	elseif _type == eFLType.black then
		SetActiveFunc(self.BtnUnblock, true)
	end
end

function CellFriend:OnClickHeadIcon()
	local data = {
		type = self.type,
		info = self.info,
		callback = self.callback
	}

	UIMgr.AddPanel(DlgOpPlayer(), data)
end

function CellFriend:OnClickBtnAdd()
	if not FriendMgr:IsCanRequestAgain(self.info.id) then
		return
	end

	local data = {
		listId = {
			self.info.id
		},
		callback = self.callback
	}

	Event.Instance:Fire("OperateAddFriend", data)
end

local function CommonFunc1(_type, info, callback)
	local data = {
		type = _type,
		playerId = info.id,
		callback = callback
	}

	Event.Instance:Fire("OperateFriendshipCoin", data)
end

function CellFriend:OnClickBtnGift()
	if not self.isFriend then
		return
	end

	local isGift = false

	if self.type == eFLType.friend then
		isGift = self.info:IsGiftToday()
	else
		isGift = FriendMgr:GetInfoFriend(self.info.id):IsGiftToday()
	end

	if isGift then
		UIMgr.ShowMsg(_("Msg_Onec_Day_Same_Friend"))

		return
	end

	CommonFunc1(1, self.info, self.callback)
end

function CellFriend:OnClickBtnRecv()
	if InfoGameInst:IsOverRecvFriendCoinNumToday() then
		UIMgr.ShowMsg(Lang(12508))

		return
	end

	CommonFunc1(2, self.info, self.callback)
end

local function CommonFunc2(_type, info, callback)
	local data = {
		type = _type,
		listInfo = {
			info
		},
		callback = callback
	}

	Event.Instance:Fire("OperatePlayerRequest", data)
end

function CellFriend:OnClickBtnAgree()
	CommonFunc2(1, self.info, self.callback)
end

function CellFriend:OnClickBtnRefuse()
	CommonFunc2(2, self.info, self.callback)
end

local function CommonFunc(msg, callback)
	local function wrap_cb(index)
		if index == 1 then
			callback()
		end
	end

	local strTitle = _("Desc_Alert")
	local strOkText = _("UI_OK")
	local strCancelText = _("Quite_Cancel")

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, strTitle, msg, wrap_cb, strOkText, strCancelText)
end

function CellFriend:OnClickBtnUnblock()
	local data = {
		type = 3,
		info = self.info,
		callback = self.callback
	}
	local msg = _("Msg_Friend_Remove")

	local function cb()
		Event.Instance:Fire("OperatePlayer", data)
	end

	CommonFunc(msg, cb)
end
