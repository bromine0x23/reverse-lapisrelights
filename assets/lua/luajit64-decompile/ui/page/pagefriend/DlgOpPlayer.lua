-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFriend/DlgOpPlayer.lua

DlgOpPlayer = class("DlgOpPlayer", UIPanel)

function DlgOpPlayer:ctor()
	self.UIPrefabPath = "UI/PanelFriend/DlgOpPlayer"
	self.callback = nil
	self.isSyncLoad = true
end

function DlgOpPlayer:Purge()
	self.base.Purge(self)

	self.callback = nil
end

function DlgOpPlayer:OnRegisterEvent()
	self:AddClick(self.BtnInfo, self.OnClickBtnInfo)
	self:AddClick(self.BtnAdd, self.OnClickBtnAdd)
	self:AddClick(self.BtnDel, self.OnClickBtnDel)
	self:AddClick(self.BtnBlack, self.OnClickBtnBlack)
	self:AddClick(self.BtnUnblock, self.OnClickBtnUnblock)
	self:AddClick(self.BtnReport, self.OnClickBtnReport)
	self:AddClick(self.BtnQuit, self.OnClickBtnQuit, PATH_SFX_UI_CANCEL)
end

function DlgOpPlayer:OnUnRegisterEvent()
	self:RemoveClick(self.BtnInfo, self.OnClickBtnInfo)
	self:RemoveClick(self.BtnAdd, self.OnClickBtnAdd)
	self:RemoveClick(self.BtnDel, self.OnClickBtnDel)
	self:RemoveClick(self.BtnBlack, self.OnClickBtnBlack)
	self:RemoveClick(self.BtnUnblock, self.OnClickBtnUnblock)
	self:RemoveClick(self.BtnReport, self.OnClickBtnReport)
	self:RemoveClick(self.BtnQuit, self.OnClickBtnQuit)
end

function DlgOpPlayer:OnEnter(vParam)
	self:DealWithLocalization()

	self.ImgPlayerHead = self:GetChildComponent("Panel/Player/HeadIcon/Icon", "Image")
	self.ImgPlayerHeadFrame = self:GetChildComponent("Panel/Player/HeadIcon/Frame", "Image")
	self.TextPlayerName = self:GetChildComponent("Panel/Player/BgInfo/TextName", "Text")
	self.TextPlayerLevel = self:GetChildComponent("Panel/Player/BgInfo/TextLevel", "Text")
	self.TextReleUnion = self:GetChildComponent("Panel/Player/TextUnion", "Text")
	self.BtnInfo = self:GetChildGameObject("Panel/BtnInfo")
	self.BtnAdd = self:GetChildGameObject("Panel/BtnAdd")
	self.BtnDel = self:GetChildGameObject("Panel/BtnDel")
	self.BtnBlack = self:GetChildGameObject("Panel/BtnBlack")
	self.BtnUnblock = self:GetChildGameObject("Panel/BtnUnblock")
	self.BtnReport = self:GetChildGameObject("Panel/BtnReport")
	self.BtnQuit = self:GetChildGameObject("Panel/ButtonQuit")
	self.ImgBtnAdd = GOUtil.GetComponent(self.BtnAdd, "Image")

	self:UpdatePanel(vParam)
end

function DlgOpPlayer:DealWithLocalization()
	local Text = self:GetChildComponent("Panel/Title/Text", "Text")

	Text.text = _("OpFriend_Title")
	Text = self:GetChildComponent("Panel/BtnInfo/Text", "Text")
	Text.text = _("UI_View_Data")
	Text = self:GetChildComponent("Panel/BtnAdd/Text", "Text")
	Text.text = Lang(41037)
	Text = self:GetChildComponent("Panel/BtnDel/Text", "Text")
	Text.text = _("Desc_Friend_Delete")
	Text = self:GetChildComponent("Panel/BtnBlack/Text", "Text")
	Text.text = Lang(12500)
	Text = self:GetChildComponent("Panel/BtnUnblock/Text", "Text")
	Text.text = _("UI_Unblock")
	Text = self:GetChildComponent("Panel/BtnReport/Text", "Text")
	Text.text = _("UI_Report")
end

function DlgOpPlayer:UpdatePanel(data)
	self.info = data.info
	self.type = data.type
	self.callback = data.callback
	self.data = data
	self.TextPlayerName.text = self.info.pb.nickname
	self.TextPlayerLevel.text = string.format(Lang(12354), self.info.level)

	local infoItem = ItemManager:Get(self.info.pb.headId)

	SetImageSprite(self.ImgPlayerHead, infoItem:GetIcon(), self)

	infoItem = ItemManager:Get(self.info.pb.headFrame)

	SetImageSprite(self.ImgPlayerHeadFrame, infoItem:GetIcon(), self)

	if self.info.pb.clubName == "" then
		SetActiveFunc(self.TextReleUnion.gameObject, false)
	else
		self.TextReleUnion.text = Lang(2009) .. "：" .. self.info.pb.clubName
	end

	local isFriend = FriendMgr:IsGameFriend(self.info.id)

	SetActiveFunc(self.BtnAdd, not isFriend and not FriendMgr:IsGameSelf(self.info.pb.playerId))
	SetActiveFunc(self.BtnDel, isFriend)

	if FriendMgr:IsGameSelf(self.info.pb.playerId) then
		GOUtil.SetRectTransformAnchoredPosition(self.BtnInfo, 0, -118)
	end

	local isBlack = FriendMgr:IsBlackFriend(self.info.id)

	SetActiveFunc(self.BtnBlack, not isBlack)
	SetActiveFunc(self.BtnUnblock, isBlack)

	local gray = TenaryOp(isBlack, 1, 0)

	UIUtil.SetImageGray(self.ImgBtnAdd, gray)
end

function DlgOpPlayer:OnClickBtnInfo()
	local data = {
		info = self.info,
		callback = function()
			self:Close()
		end,
		sourceData = self.data
	}

	if self.type == 100 then
		Event.Instance:Fire("SetRankViewPosYEvent")
		self:SwitchPlayerInfo(data)
	else
		Event.Instance:Fire("SwitchPlayerInfo", data)
	end

	if self.callback then
		self.callback()
	end
end

function DlgOpPlayer:GetCallback()
	local function callback()
		if self.callback then
			self.callback()
		end

		self:Close()
	end

	return callback
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

function DlgOpPlayer:OnClickBtnAdd()
	if FriendMgr:IsBlackFriend(self.info.id) then
		if self.type == eFLType.black then
			UIMgr.ShowMsg(_("Msg_Player_In_Black"))

			return
		else
			local msg = _("Msg_Friend_Remove_Black_OrNot")

			local function cb()
				self:OnClickBtnUnblock()
			end

			CommonFunc(msg, cb)
		end

		return
	end

	if not FriendMgr:IsCanRequestAgain(self.info.id) then
		return
	end

	local data = {
		listId = {
			self.info.id
		},
		callback = self:GetCallback()
	}

	Event.Instance:Fire("OperateAddFriend", data)

	if self.type == 100 then
		self:OperateAddFriend(data)
	end
end

function DlgOpPlayer:OnClickBtnDel()
	local data = {
		type = 1,
		info = self.info,
		callback = self:GetCallback()
	}
	local msg = _("Msg_Friend_Dele_OrNot")

	local function cb()
		Event.Instance:Fire("OperatePlayer", data)

		if self.type == 100 then
			self:OperatePlayer(data)
		end
	end

	CommonFunc(msg, cb)
end

function DlgOpPlayer:OnClickBtnBlack()
	local data = {
		type = 2,
		info = self.info,
		callback = self:GetCallback()
	}
	local msg = _("Msg_Friend_PullBlack_OrNot")

	local function cb()
		Event.Instance:Fire("OperatePlayer", data)

		if self.type == 100 then
			self:OperatePlayer(data)
		end
	end

	CommonFunc(msg, cb)
end

function DlgOpPlayer:OnClickBtnUnblock()
	local data = {
		type = 3,
		info = self.info,
		callback = self:GetCallback()
	}

	Event.Instance:Fire("OperatePlayer", data)

	if self.type == 100 then
		self:OperatePlayer(data)
	end
end

function DlgOpPlayer:OnClickBtnReport()
	UIMgr.ShowMsg(Lang(12172))
end

function DlgOpPlayer:OnClickBtnQuit()
	self:Close()
end

function DlgOpPlayer:OperateAddFriend(data)
	if FriendMgr:IsOverMaxFriend() then
		UIMgr.ShowMsg(Lang(12509))

		return
	end

	if InfoGameInst:IsOverRequestFriendNumToday() then
		UIMgr.ShowMsg(_("Msg_Request_Full_Today"))

		return
	end

	local listPlayerId = {}

	if data.listId then
		listPlayerId = data.listId
	end

	local function wrap_cb(vMsg)
		self:ResponseAddFriend(vMsg, listPlayerId)
	end

	NetManager:RequestAddFriend(listPlayerId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgOpPlayer:ResponseAddFriend(vMsg, list)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if vMsg.result.code == 0 then
		UIMgr.ShowMsg(Lang(26000042))

		local listId = vMsg.playerId

		FriendMgr:DeleteFromListRecommend(listId)
		InfoGameInst:ChangeTodayRequestFriendNum(#listId)

		for i = 1, #list do
			FriendMgr:AddToListRequest(list[i])
		end

		self:Close()
	else
		UIMgr.ShowMsg(vMsg.result.desc, vMsg)
	end
end

function DlgOpPlayer:SwitchPlayerInfo(data)
	if not data or not data.info then
		return
	end

	local playerId = data.info.id

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == 0 then
			if data.callback then
				data.callback()
			end

			local data = {}

			data.player = vMsg.player
			data.roleCards = vMsg.roleCards
			data.mainStageId = tonumber(vMsg.mainStageId)
			data.cardCount = vMsg.cardCount

			UIMgr.SwitchPanel(PagePlayer, data)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestPlayerInfo(playerId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgOpPlayer:OperatePlayer(data)
	local _type = data.type

	if _type == 2 and FriendMgr:IsOverMaxBlack() then
		UIMgr.ShowMsg(Lang(12511))

		return
	end

	local playerId = data.info.id

	local function wrap_cb(vMsg)
		self:ResponseOperatePlayer(vMsg, _type, data.info)
	end

	NetManager:RequestDealWithFriendRelation(_type, playerId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgOpPlayer:ResponseOperatePlayer(vMsg, _type, info)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if vMsg.result.code == 0 then
		if _type == 1 then
			FriendMgr:DeleteFromListFriend(info.id)
		elseif _type == 2 then
			FriendMgr:AddToListBlack(info)
		elseif _type == 3 then
			FriendMgr:DeleteFromListBlack(info)
		end

		self:Close()
	else
		UIMgr.ShowMsg(vMsg.result.desc, vMsg)
	end
end
