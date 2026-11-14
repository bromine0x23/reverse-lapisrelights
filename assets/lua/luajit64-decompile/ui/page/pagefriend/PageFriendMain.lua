-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFriend/PageFriendMain.lua

require("UI/UIScrollTool")
require("UI/Page/PageFriend/CellFriend")
require("UI/Page/PageFriend/DlgOpPlayer")
require("UI/Page/PageFriend/DlgFriendPanel")
require("UI/Page/PageFriend/DlgFriendAddPanel")
require("UI/Page/PageFriend/DlgBlackPanel")
require("UI/Page/PagePlayerInfo/PagePlayer")

PageFriendMain = class("PageFriendMain", UIPanel)
eFLType = {
	search = 4,
	black = 5,
	recommond = 2,
	request = 3,
	friend = 1
}

function PageFriendMain:ctor()
	self.UIPrefabPath = "UI/PanelFriend/PanelFriendMain"
	self.DlgFriend = DlgFriendPanel()

	self:AddChildPanel(self.DlgFriend)

	self.DlgAdd = DlgFriendAddPanel()

	self:AddChildPanel(self.DlgAdd)

	self.callback = nil
end

function PageFriendMain:PreLoad()
	Event.Instance:Fire("UpdateSceneDisplay", true)
end

function PageFriendMain:Purge()
	self.base.Purge(self)
	self:OnLeave()
end

function PageFriendMain:OnLeave()
	UnloadAllImageSprite(self)
	FingerGesturesUtil.Enable()

	if self.needRemoveApplyDot then
		FriendRDL.RemoveFriendApply()
	end

	self.callback = nil
end

function PageFriendMain:OnRegisterEvent()
	for i = 1, self.tagCnt do
		self:AddClick(self["BtnTag" .. i], self.OnClickBtnTag)
	end

	self:AddClick(self.btn_close, self.OnClickBtnClose)
	Event.Instance:Add("OperateAddFriend", self.OperateAddFriend, self)
	Event.Instance:Add("OperateFriendshipCoin", self.OperateFriendshipCoin, self)
	Event.Instance:Add("OperatePlayerRequest", self.OperatePlayerRequest, self)
	Event.Instance:Add("OperatePlayer", self.OperatePlayer, self)
	Event.Instance:Add("SwitchPlayerInfo", self.SwitchPlayerInfo, self)
end

function PageFriendMain:OnUnRegisterEvent()
	for i = 1, self.tagCnt do
		self:RemoveClick(self["BtnTag" .. i], self.OnClickBtnTag)
	end

	self:RemoveClick(self.btn_close, self.OnClickBtnClose)
	Event.Instance:Remove("OperateAddFriend", self.OperateAddFriend, self)
	Event.Instance:Remove("OperateFriendshipCoin", self.OperateFriendshipCoin, self)
	Event.Instance:Remove("OperatePlayerRequest", self.OperatePlayerRequest, self)
	Event.Instance:Remove("OperatePlayer", self.OperatePlayer, self)
	Event.Instance:Remove("SwitchPlayerInfo", self.SwitchPlayerInfo, self)
end

function PageFriendMain.RequestData(data)
	local function cb()
		if UIMgr.GetCurPanel().className ~= "PageMainStage" then
			UIMgr.ClearMain()
			UIMgr.SwitchPanel(PageMainStage, nil, true)
		end

		if UIMgr.GetCurPanel().className == "PageMainStage" then
			UIMgr.AddPanel(PageFriendMain(), data)
		end
	end

	if FriendMgr.Requested then
		cb()
	else
		local function wrap_cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vMsg.result.code == NetManager.Result_Sucess then
				cb()
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		end

		NetManager:RequestFriendList(wrap_cb)
		LoadingMgr.Show(eLoadingType.Repeat)
	end
end

function PageFriendMain:OnEnter(vParam)
	FingerGesturesUtil.Disable()
	Event.Instance:Fire("DealWithUIAnim", true)

	self.tagCnt = 3

	self:DealWithLocalization()

	self.panel_close = self:GetChildGameObject("panel_close")
	self.btn_close = self:GetChildGameObject("panel_close/btn_close")

	self.panel_close.transform:SetAsLastSibling()

	for i = 1, self.tagCnt do
		self["GoTag" .. i] = self:GetChildGameObject("TagPanel/" .. i)
		self["BtnTag" .. i] = self:GetChildGameObject("TagPanel/" .. i .. "/Button")
		self["SelTag" .. i] = self:GetChildGameObject("TagPanel/" .. i .. "/Select")
	end

	self.tagIdx = FriendMgr.tag

	if vParam and vParam.tag then
		self.tagIdx = vParam.tag
	end

	if #FriendMgr:GetApplyList() ~= 0 then
		self.tagIdx = 2
	else
		self.tagIdx = 1

		if FriendMgr.tag ~= 1 then
			self.tagIdx = FriendMgr.tag
		end
	end

	self.needRemoveApplyDot = nil

	self:UpdatePanel()
end

function PageFriendMain:DealWithLocalization()
	for i = 1, self.tagCnt do
		local str = ""

		if i == 1 then
			str = _("Title_Friend")
		elseif i == 2 then
			str = _("Page_AddFriend")
		elseif i == 3 then
			str = _("Title_BlackList")
		end

		local Text = self:GetChildComponent("TagPanel/" .. i .. "/Button/Text", "Text")

		Text.text = str
		Text = self:GetChildComponent("TagPanel/" .. i .. "/Select/Text", "Text")
		Text.text = str
	end
end

function PageFriendMain:OnClickBtnTag(data)
	local go = data.pointerPress.transform.parent.gameObject
	local index = tonumber(go.name)

	if self.tagIdx == index then
		return
	end

	self.tagIdx = index
	FriendMgr.tag = index

	self:UpdatePanel()
end

function PageFriendMain:OnClickBtnClose()
	Event.Instance:Fire("DealWithUIAnim", false)

	OperationActiveMgr.DlgLimitTaskJumpFlag = false

	FriendMgr:ClearKeyWord()

	FriendMgr.tag = 1

	self:Close()
end

function PageFriendMain:UpdatePanel()
	if self.needRemoveApplyDot then
		FriendRDL.RemoveFriendApply()

		self.needRemoveApplyDot = false
	end

	if self.needRemoveApplyDot == nil and self.tagIdx == 2 then
		self.needRemoveApplyDot = true
	end

	for i = 1, self.tagCnt do
		SetActiveFunc(self["BtnTag" .. i], i ~= self.tagIdx)
		SetActiveFunc(self["SelTag" .. i], i == self.tagIdx)
	end

	if self.tagIdx == 1 then
		self.DlgFriend:Show()
		self.DlgAdd:Hide()
	elseif self.tagIdx == 2 then
		self.DlgAdd:Show()
		self.DlgFriend:Hide()
	end

	if FriendMgr.PlayerInfoData then
		UIMgr.AddPanel(DlgOpPlayer(), FriendMgr.PlayerInfoData)

		FriendMgr.PlayerInfoData = nil
	end
end

function PageFriendMain:OperateAddFriend(data)
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

	if data.callback then
		self.callback = data.callback
	end

	local function wrap_cb(vMsg)
		self:ResponseAddFriend(vMsg, listPlayerId)
	end

	NetManager:RequestAddFriend(listPlayerId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageFriendMain:ResponseAddFriend(vMsg, list)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if vMsg.result.code == 0 then
		UIMgr.ShowMsg(Lang(26000042))

		local listId = vMsg.playerId

		FriendMgr:DeleteFromListRecommend(listId)
		InfoGameInst:ChangeTodayRequestFriendNum(#listId)

		for i = 1, #list do
			FriendMgr:AddToListRequest(list[i])
		end

		if self.callback then
			self.callback()
		end
	else
		UIMgr.ShowMsg(vMsg.result.desc, vMsg)
	end
end

function PageFriendMain:OperateFriendshipCoin(data)
	local _type = data.type

	if _type == 2 and InfoGameInst:IsOverRecvFriendCoinNumToday() then
		UIMgr.ShowMsg(Lang(12508))

		return
	end

	local playerId = data.playerId or 0

	if data.callback then
		self.callback = data.callback
	end

	local function wrap_cb(vMsg)
		self:ResponseOperateFriendshipCoin(vMsg, _type)
	end

	NetManager:RequestDealWithFriendCoin(_type, playerId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageFriendMain:ResponseOperateFriendshipCoin(vMsg, _type)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if vMsg.result.code == 0 then
		FriendMgr:SetGiftOrRecvCoinState(_type, vMsg.playerId)

		if _type == 1 then
			UIMgr.ShowMsg(Lang(12521))
		else
			InfoGameInst:ChangeTodayRecvFriendCoinNum(#vMsg.playerId)
			FriendRDL.RemoveFriendGift(#vMsg.playerId)
		end

		if self.callback then
			self.callback()
		end
	else
		UIMgr.ShowMsg(vMsg.result.desc, vMsg)
	end
end

function PageFriendMain:OperatePlayerRequest(data)
	local _type = data.type
	local listInfo = data.listInfo

	if #listInfo == 0 then
		UIMgr.ShowMsg(Lang(12516))

		return
	end

	if _type == 1 and FriendMgr:IsOverMaxFriend() then
		UIMgr.ShowMsg(Lang(12509))

		return
	end

	local listPlayerId = {}

	for i = 1, #listInfo do
		table.insert(listPlayerId, listInfo[i].id)
	end

	if data.callback then
		self.callback = data.callback
	end

	local function wrap_cb(vMsg)
		self:ResponseOperateRequest(vMsg, _type, listInfo)
	end

	NetManager:RequestDealWithFriendRequest(_type, listPlayerId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageFriendMain:ResponseOperateRequest(vMsg, _type, listInfo)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if vMsg.result.code == 0 then
		local listSucessId = vMsg.playerId

		if _type == 1 then
			local function wrap_cb(vMsg)
				LoadingMgr.Hide(eLoadingType.Repeat)
			end

			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:RequestFriendList(wrap_cb)
			UIMgr.ShowMsg(_("AddFriend_Successful"))
		elseif _type == 2 then
			UIMgr.ShowMsg(_("Reject_Successful"))
		end

		FriendMgr:DeleteFromListApply(listSucessId)

		if self.callback then
			self.callback()
		end
	else
		UIMgr.ShowMsg(vMsg.result.desc, vMsg)
	end
end

function PageFriendMain:OperatePlayer(data)
	local _type = data.type

	if _type == 2 and FriendMgr:IsOverMaxBlack() then
		UIMgr.ShowMsg(Lang(12511))

		return
	end

	local playerId = data.info.id

	if data.callback then
		self.callback = data.callback
	end

	local function wrap_cb(vMsg)
		self:ResponseOperatePlayer(vMsg, _type, data.info)
	end

	NetManager:RequestDealWithFriendRelation(_type, playerId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageFriendMain:ResponseOperatePlayer(vMsg, _type, info)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if vMsg.result.code == 0 then
		if _type == 1 then
			FriendMgr:DeleteFromListFriend(info.id)
		elseif _type == 2 then
			FriendMgr:AddToListBlack(info)
		elseif _type == 3 then
			FriendMgr:DeleteFromListBlack(info)
		end

		if self.callback then
			self.callback()
		end
	else
		UIMgr.ShowMsg(vMsg.result.desc, vMsg)
	end
end

function PageFriendMain:SwitchPlayerInfo(data)
	if not data or not data.info then
		return
	end

	local playerId = data.info.id

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == 0 then
			local vParam = {}

			vParam.player = vMsg.player
			vParam.roleCards = vMsg.roleCards
			vParam.mainStageId = tonumber(vMsg.mainStageId)
			vParam.cardCount = vMsg.cardCount

			UIMgr.SwitchPanel(PagePlayer, vParam)

			if data.callback then
				data.callback()
			end

			FriendMgr.IsExitOnPageFriend = true
			FriendMgr.PlayerInfoData = data.sourceData
			FriendMgr.tag = self.tagIdx

			self:Close()
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestPlayerInfo(playerId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageFriendMain:UpdateDotNotify()
	self:UpdateDot()
end

function PageFriendMain:UpdateDot()
	return
end

function PageFriendMain:OnBackAndroid()
	self:OnClickBtnClose()
end
