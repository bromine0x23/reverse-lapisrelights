-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageInteraction/PageChildGift.lua

require("UI/Page/PageInteraction/CellFavor")
require("UI/Page/PageInteraction/CellFavorUnlock")
require("UI/Page/PageInteraction/CellChildGift")

local favorPose = require("luaData/FavorPose")

PageChildGift = class("PageChildGift", UIPanel)

function PageChildGift:ctor()
	self.UIPrefabPath = "UI/PageInteraction/PanelChildGift"
end

function PageChildGift:PreLoad()
	self:LoadResAsync("UI/PageInteraction/CellChildGift", "PrefabCellChildGift")
end

function PageChildGift:OnEnter(vParam)
	self.UIRootObject.transform:SetSiblingIndex(5)

	local strList = {
		_("Char_Jewelry"),
		_("Char_Sweetmeats"),
		_("Char_Carry"),
		_("Char_Food")
	}

	for i = 1, 4 do
		self["GoTab" .. i] = self:GetChildGameObject("panel/tab/tab" .. i)
		self["tab_btn" .. i] = self:GetChildGameObject("panel/tab/tab" .. i .. "/btn")
		self["tab_sel" .. i] = self:GetChildGameObject("panel/tab/tab" .. i .. "/sel")
		self["tab_btn_tex" .. i] = self:GetChildComponent("panel/tab/tab" .. i .. "/btn/Text", "Text")
		self["tab_btn_tex" .. i].text = strList[i]
		self["tab_btn_unlike" .. i] = self:GetChildGameObject("panel/tab/tab" .. i .. "/btn/img_unlike")
		self["tab_sel_tex" .. i] = self:GetChildComponent("panel/tab/tab" .. i .. "/sel/Text", "Text")
		self["tab_sel_tex" .. i].text = strList[i]
		self["tab_sel_unlike" .. i] = self:GetChildGameObject("panel/tab/tab" .. i .. "/sel/img_unlike")
	end

	self.img_favor = self:GetChildComponent("panel/title/Image/img_favor", "Image")
	self.tex_favor_level = self:GetChildComponent("panel/title/Image/tex_favor_level", "Text")
	self.ScrollArea = self:GetChildGameObject("panel/main/ScrollArea")
	self.content = GOUtil.FindChildComponent(self.ScrollArea, "Content", "RectTransform")
	self.img_gift = self:GetChildComponent("panel/main/bg_gift/img_gift", "Image")
	self.g_cell = self:GetChildGameObject("panel/main/bg_gift/g_cell")
	self.cellGift = CellItem(self.g_cell)

	self.cellGift:InitItemByRoot(self.g_cell)

	self.cellGift.tipData = {
		showNum = true,
		initPanelIndex = 3,
		needFromBtn = true
	}
	self.bg_gift = self:GetChildGameObject("panel/main/bg_gift")
	self.Text2 = self:GetChildGameObject("panel/main/Text2")

	local _, favorTabList = ItemManager:GetRoleFavorInfoList(self.infoRole)

	for i = 1, 4 do
		if self["tab_btn_unlike" .. i] then
			SetActiveFunc(self["tab_btn_unlike" .. i], tonumber(favorTabList[i]) ~= 1)
		end

		if self["tab_sel_unlike" .. i] then
			SetActiveFunc(self["tab_sel_unlike" .. i], favorTabList[i] ~= 1)
		end
	end

	self.tex_name = self:GetChildComponent("panel/main/bg_gift/tex_name", "Text")
	self.tex_num = self:GetChildComponent("panel/main/Text2/tex_num", "Text")
	self.btn_gift = self:GetChildComponent("panel/main/btn_gift", "Image")
	self.btn_gift_award = self:GetChildGameObject("panel/btn_gift_award")

	SetActiveFunc(self.btn_gift_award, false)

	self.bg_unlike_gift = self:GetChildGameObject("panel/main/bg_unlike_gift")

	SetActiveFunc(self.bg_unlike_gift, false)
	SetActiveFunc(self.bg_gift, false)
	SetActiveFunc(self.Text2, false)
	SetActiveFunc(self.btn_gift.gameObject, false)

	self.selCellChildGiftIndex = 1
	self.selCellChildGiftCount = 0
	self.t = 0
	self.giftItemValueLists = {}
	self.cellItemList = {}
	self.DlgFavorInfo = vParam.DlgFavorInfo

	self:Localization()

	if self.infoRole then
		self:UpdateTab(self.infoRole.data.Gift)
		self:UpdateData()
		self:UpdateDot()
	end
end

function PageChildGift:Localization()
	local TextAuto

	TextAuto = self:GetChildComponent("panel/title/Image/Text1", "Text")
	TextAuto.text = _("Desc_Relationship")
	TextAuto = self:GetChildComponent("panel/title/Image/Text2", "Text")
	TextAuto.text = _("Desc_FavorLevelShow")
	TextAuto = self:GetChildComponent("panel/main/Text", "Text")
	TextAuto.text = _("Desc_LongClickToChoice")
	TextAuto = self:GetChildComponent("panel/main/btn_gift/Text", "Text")
	TextAuto.text = _("Desc_SendGift")
	TextAuto = self:GetChildComponent("panel/main/Text2", "Text")
	TextAuto.text = _("Desc_Number")
end

function PageChildGift:Init(show, data)
	if self.UIRootObject and not IsNil(self.UIRootObject) then
		if not show then
			self.DlgFavorInfo.aimList = {}
		else
			self.DlgFavorInfo:NotifyUpdate()
		end

		SetActiveFunc(self.UIRootObject.gameObject, show)
	end

	if data then
		self.data = data
		self.infoRole = data.infoRole
		self.actor = data.actor

		local _, favorTabList = ItemManager:GetRoleFavorInfoList(self.infoRole)

		for i = 1, 4 do
			if self["tab_btn_unlike" .. i] then
				SetActiveFunc(self["tab_btn_unlike" .. i], tonumber(favorTabList[i]) ~= 1)
			end

			if self["tab_sel_unlike" .. i] then
				SetActiveFunc(self["tab_sel_unlike" .. i], favorTabList[i] ~= 1)
			end
		end

		self:UpdateDot()
	end

	if show then
		if self.data then
			Event.Instance:Fire("SetVcScreenX", {
				isLeft = true,
				index = self.data.index
			})
		end

		self.selCellChildGiftIndex = 1
		self.selCellChildGiftCount = 0
		self.t = 0

		if self.cellItemList then
			for _, v in ipairs(self.cellItemList) do
				SetActiveFunc(v.btn_sub, false)
				SetActiveFunc(v.go_sel, false)
			end
		end

		self.cellItemList = {}
		self.giftItemValueLists = {}

		if self.UIRootObject and not IsNil(self.UIRootObject) then
			SetActiveFunc(self.bg_gift, false)
			SetActiveFunc(self.Text2, false)
			SetActiveFunc(self.btn_gift.gameObject, false)
			self:UpdateTab(self.infoRole.data.Gift)
			self:UpdateData()
		end

		if not show and self.uiTabIndex then
			self:CancelDot()
		end
	else
		local addLevelList = {}

		self.addLevelList = addLevelList

		for i = 1, 4 do
			addLevelList[i] = 0
		end

		self.DlgFavorInfo:AddExpLevel(addLevelList)

		if self.data then
			Event.Instance:Fire("SetVcScreenX", {
				isLeft = false,
				index = self.data.index
			})
		end
	end
end

function PageChildGift:UpdateData()
	self.infoRole = RoleMgr:GetRole(self.infoRole.id)
	self.tex_favor_level.text = self.infoRole.curFavorLevel

	local favorIndex = RoleMgr:GetFavorSectionIndex(self.infoRole.curFavorLevel)

	UIUtil.SetImageSprite(self.img_favor, "UI/PageInteraction/AtlasPageInteraction/AtlasDlgFavor/BG_word_likelv_0" .. favorIndex, self)
end

function PageChildGift:Purge()
	PageChildGift.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	self.cellGift:OnLeave()
	UnloadAllImageSprite(self)
	ResourceMgr.Unload(self.PrefabCellChildGift)
	self:CancelDot()
end

function PageChildGift:OnRegisterEvent()
	for i = 1, 4 do
		self:AddClick(self["GoTab" .. i], self.OnClickTabBtn)
	end

	self:AddClick(self.btn_gift.gameObject, self.OnClickBtnGift)
	self:AddClick(self.btn_gift_award, self.OnClickGetGift)
	Event.Instance:Add("UpdateMainGift", self.UpdateMainGift, self)
	Event.Instance:Add("UpdateAddLevelGift", self.UpdateAddLevelGift, self)
	Event.Instance:Add("ResetMaxGif", self.ResetMaxGif, self)
end

function PageChildGift:OnUnRegisterEvent()
	if IsNil(self.btn_gift) then
		return
	end

	for i = 1, 4 do
		self:RemoveClick(self["GoTab" .. i], self.OnClickTabBtn)
	end

	self:RemoveClick(self.btn_gift.gameObject, self.OnClickBtnGift)
	self:RemoveClick(self.btn_gift_award, self.OnClickGetGift)
	Event.Instance:Remove("UpdateMainGift", self.UpdateMainGift, self)
	Event.Instance:Remove("UpdateAddLevelGift", self.UpdateAddLevelGift, self)
	Event.Instance:Remove("ResetMaxGif", self.ResetMaxGif, self)
end

function PageChildGift:OnClickTabBtn(data)
	local go = data.pointerPress.gameObject
	local index = string.sub(go.name, 4, 4)

	if self.uiTabIndex == index then
		return
	end

	self:CancelDot()

	self.selCellChildGiftIndex = 1
	self.selCellChildGiftCount = 0
	self.t = 0

	self:UpdateTab(tonumber(index))
end

function PageChildGift:OnClickBtnGift()
	if not self.isGetGift then
		self.isGetGift = true
	else
		return
	end

	if self.bgCellGiftID and TenaryOp(self:GetRoleFavorHoldInfoState(self.bgCellGiftID, self.infoRole), 0, 1) == 1 then
		self.isGetGift = false

		UIMgr.ShowMsg(_("Msg_GiftCannotsend"))

		return
	end

	local item = {}

	item[1] = {}
	item[1].id = self.info.data.data.ID
	item[1].num = self.selCellChildGiftCount
	item[1].info = self.info

	if self.info then
		local function wrap_cb(vPBMessage, setter)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vPBMessage.result.code == NetManager.Result_Sucess then
				self.DlgFavorInfo:PlayFavorHeartAnimation(self.addLevelList[4])

				self.addLevelList = {}

				self:OnHandleSendGift(vPBMessage, setter, item)

				self.selCellChildGiftCount = 0
				self.isGetGift = false
				self.t = 0

				for _, v in ipairs(self.cellItemList) do
					SetActiveFunc(v.btn_sub, false)
					SetActiveFunc(v.go_sel, false)
				end

				self.cellItemList = {}

				local giftItemValue = {}

				giftItemValue.id = self.info.data.data.ID
				giftItemValue.count = 0
				giftItemValue.expOne = 0

				self:AddGiftItemValueLists(giftItemValue)

				local addLevelList = LevelManager:GetPreviewProgress(self.infoRole, {})

				self.DlgFavorInfo:AddExpLevel(addLevelList)
				self.UIScrollTool:UpdateListData(self.favorInfoList["Type" .. self.uiTabIndex])
				Event.Instance:Fire("UpdateDotNotify")
				self:UpdateData()

				if self.uiTabIndex then
					self:CancelDot()
				end
			else
				self.isGetGift = false

				UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
				SetActiveFunc(self.btn_gift_award, false)
			end
		end

		local addLevelList = LevelManager:GetPreviewProgress(self.infoRole, self.giftItemValueLists)
		local isMax = self.isMax
		local count, Max

		if addLevelList and addLevelList[5] then
			count, Max, isMax = LevelManager:GetFavorAddCount(self.infoRole, self.giftItemValueLists, item.ID, addLevelList[5])
		end

		if isMax then
			local function call(type)
				self.isGetGift = false

				if type == DlgCommon.ButtonType.OK then
					NetManager:RequestSendGift(self.infoRole.id, item, wrap_cb)
					LoadingMgr.Show(eLoadingType.Repeat)
				else
					print("cancel")
				end
			end

			local strAlert = _("FacorInfo_Max")
			local args = {
				DlgCommonEvent.Type.Confirm,
				_("Desc_Alert"),
				strAlert,
				call,
				_("Button_OK"),
				_("Button_Cancel"),
				nil,
				32767
			}

			UIMgr.AddPanel(DlgCommonEvent(), args, self.UIRootObject)
		else
			NetManager:RequestSendGift(self.infoRole.id, item, wrap_cb)
			LoadingMgr.Show(eLoadingType.Repeat)
		end
	end
end

function PageChildGift:OnClickGetGift()
	SetActiveFunc(self.btn_gift_award, false)
	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestGetRoleGift(self.infoRole.id, function(msg)
		LoadingMgr.Hide(eLoadingType.Repeat)
		self.infoRole:UpdateFavorAward(msg.favorLevelRecord)
		PlayAnim(eInterctAnimType.idle, self.actor, self.infoRole)
	end, function()
		return
	end)
end

function PageChildGift:OnHandleSendGift(vPBMessage, setter, item)
	if vPBMessage.result.code == NetManager.Result_Sucess then
		self:NotifyPlayFavorUpAni(setter, item)
	else
		UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
	end
end

function PageChildGift:NotifyPlayFavorUpAni(setter, item)
	local actor = SceneMainStage.Instance.curActor
	local actorMotion = actor.MotionSystem

	if globalInterAniState == "idleState" and not actorMotion:IsInTransition() then
		-- block empty
	else
		return
	end

	if item == nil then
		return
	end

	local info = item[1].info
	local isCake = string.split(info.data.data.SubType, ".")[1] == "cake"

	if isCake then
		PlayAnim(eInterctAnimType.birthdayPlayerSend, actor, self.infoRole)

		return
	end

	local holdInfo = self:GetRoleFavorHoldInfoState(info.data.data.ID, self.infoRole)

	if holdInfo and holdInfo[2] == 1 then
		PlayAnim(eInterctAnimType.favorGift, actor, self.infoRole)

		return
	end

	local preFavorLv = setter.preFavorLevel
	local curFavorLv = setter.curFavorLevel

	if preFavorLv < curFavorLv then
		local preFavorIndex = RoleMgr:GetFavorSectionIndex(preFavorLv)
		local curFavorIndex = RoleMgr:GetFavorSectionIndex(curFavorLv)

		if preFavorIndex < curFavorIndex then
			PlayAnim(eInterctAnimType.rankup, actor, self.infoRole)
		else
			PlayAnim(eInterctAnimType.levelup, actor, self.infoRole)
		end
	else
		PlayAnim(eInterctAnimType.sendGift, actor, self.infoRole)
	end
end

function PageChildGift:GetRoleFavorHoldInfoState(favorID, infoRole)
	local listId = infoRole.data.FavorItemList

	for _, v in pairs(listId) do
		if v[1] == favorID then
			return v
		end
	end

	return nil
end

function PageChildGift:UpdateTab(index)
	for i = 1, 4 do
		SetActiveFunc(self["tab_btn" .. i], index ~= i)
		SetActiveFunc(self["tab_sel" .. i], index == i)
	end

	self.uiTabIndex = index
	self.favorInfoList = ItemManager:GetRoleFavorInfoList(self.infoRole)

	local count = #self.favorInfoList["Type" .. self.uiTabIndex]

	if self.UIScrollTool then
		for _, v in ipairs(self.cellItemList) do
			SetActiveFunc(v.btn_sub, false)
			SetActiveFunc(v.go_sel, false)
		end

		self.cellItemList = {}

		self.UIScrollTool:UpdateListData(self.favorInfoList["Type" .. self.uiTabIndex])

		return
	else
		self.cellItemList = {}
	end

	local function addCallback(item)
		self:AddClick(item.UIRootObject, nil)
	end

	local function updateCallback(item, index2)
		local data = self.favorInfoList["Type" .. self.uiTabIndex][index2]

		if data then
			local infoItem = ItemManager:Get(data.ID)
			local holdInfo = self:GetRoleFavorHoldInfoState(data.ID, self.infoRole)

			item:UpdateData(infoItem, self.selCellChildGiftIndex, index2, holdInfo)
		end

		table.insert(self.cellItemList, index2, item)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.ScrollArea, self.content, count, self.PrefabCellChildGift, CellChildGift, self, false, addCallback, updateCallback)

	function self.UIScrollTool.ScrollView.beginDragCB()
		FingerGesturesUtil.Disable()
	end

	function self.UIScrollTool.ScrollView.onSlippingComplete()
		FingerGesturesUtil.Enable()
	end
end

function PageChildGift:UpdateMainGift(info)
	local isDragging = self.UIScrollTool.ScrollView:IsDragging()

	if isDragging then
		return
	end

	if not info.holdInfo then
		local addLevelList = LevelManager:GetPreviewProgress(self.infoRole, {})

		self.DlgFavorInfo:AddExpLevel(addLevelList)

		self.tex_num.text = _("Desc_Number") .. 0
		self.tex_name.text = info.data:GetNameAndDesc()

		local gray = TenaryOp(info.holdInfo, 0, 1)

		SetActiveFunc(self.btn_gift.gameObject, false)
		SetActiveFunc(self.bg_unlike_gift, true)
		SetActiveFunc(self.bg_gift, true)
		SetActiveFunc(self.Text2, true)
		DealWithListRef(self, UIUtil.SetImageGray(self.btn_gift, gray))
		UIUtil.SetImageSprite(self.img_gift, info.data.data.Icon, self)

		self.bgCellGiftID = info.data.id

		self.cellGift:UpdateNoNumType(info.data)

		return
	end

	if self.selCellChildGiftIndex ~= info.index then
		self.selCellChildGiftIndex = info.index
		self.selCellChildGiftCount = 0
		self.t = 0

		for _, v in ipairs(self.cellItemList) do
			SetActiveFunc(v.btn_sub, false)
			SetActiveFunc(v.go_sel, false)
		end

		self.giftItemValueLists = {}

		SetActiveFunc(info.cell.go_sel, true)

		if self.info then
			local colorStr = TenaryOp(self.info.data:GetNum() == 0 and self.infoRole.curFavorLevel ~= GetConfigArgInt("FavorMaxLevel"), string.format("<color=#e22a2a>%s</color>", "×" .. self.info.data:GetNum()), string.format("<color=#505a61>%s</color>", "×" .. self.info.data:GetNum()))

			self.info.cell.tex_num.text = colorStr
		end
	end

	if self.info and self.info.type ~= info.type then
		self:ResetMaxGif()
	end

	self.info = info

	SetActiveFunc(self.bg_gift, true)
	SetActiveFunc(self.Text2, true)
	SetActiveFunc(self.btn_gift.gameObject, true)
	SetActiveFunc(self.bg_unlike_gift, false)

	local maxNum = info.data:GetNum()

	if info.type == 1 then
		self.selCellChildGiftCount = self.selCellChildGiftCount + 1

		local count = math.min(self.selCellChildGiftCount, maxNum)
		local tempCount = self.selCellChildGiftCount

		self.selCellChildGiftCount = count

		SetActiveFunc(info.cell.btn_sub, count > 0)
		UIUtil.SetImageSprite(self.img_gift, info.data.data.Icon, self)

		self.bgCellGiftID = info.data.id

		self.cellGift:UpdateNoNumType(info.data)

		self.tex_name.text = info.data:GetNameAndDesc()
		self.tex_num.text = _("Desc_Number") .. count

		local gray = TenaryOp(info.holdInfo and count > 0, 0, 1)

		DealWithListRef(self, UIUtil.SetImageGray(self.btn_gift, gray))

		if maxNum < tempCount and self.selCellChildGiftCount ~= 0 then
			UIMgr.ShowMsg(Lang(590003))
		end
	elseif info.type == 2 then
		self.selCellChildGiftCount = self.selCellChildGiftCount - 1

		local count = math.max(0, self.selCellChildGiftCount)

		self.selCellChildGiftCount = count

		SetActiveFunc(info.cell.btn_sub, count > 0)
		UIUtil.SetImageSprite(self.img_gift, info.data.data.Icon, self)

		self.bgCellGiftID = info.data.id

		self.cellGift:UpdateNoNumType(info.data)

		self.tex_name.text = info.data:GetNameAndDesc()
		self.tex_num.text = _("Desc_Number") .. count

		local gray = TenaryOp(info.holdInfo and count > 0, 0, 1)

		DealWithListRef(self, UIUtil.SetImageGray(self.btn_gift, gray))
	elseif info.type == 3 then
		if self.isMax then
			return
		end

		self.t = self.t + 1

		local step = math.pow(10, math.floor(self.t * 0.1))

		self.selCellChildGiftCount = self.selCellChildGiftCount + step

		local count = math.min(self.selCellChildGiftCount, maxNum)
		local tempCount = self.selCellChildGiftCount

		self.selCellChildGiftCount = count

		SetActiveFunc(info.cell.btn_sub, count > 0)
		UIUtil.SetImageSprite(self.img_gift, info.data.data.Icon, self)

		self.bgCellGiftID = info.data.id

		self.cellGift:UpdateNoNumType(info.data)

		self.tex_name.text = info.data:GetNameAndDesc()
		self.tex_num.text = _("Desc_Number") .. count

		local gray = TenaryOp(info.holdInfo and count > 0, 0, 1)

		DealWithListRef(self, UIUtil.SetImageGray(self.btn_gift, gray))

		if maxNum < tempCount and self.selCellChildGiftCount ~= 0 and not self.isMax then
			self.isMax = maxNum < tempCount

			UIMgr.ShowMsg(_("Msg_SetGiftMax"))
		end
	elseif info.type == 4 then
		self.t = self.t + 1

		local step = math.pow(10, math.floor(self.t * 0.1))

		self.selCellChildGiftCount = self.selCellChildGiftCount - step

		local count = math.max(0, self.selCellChildGiftCount)

		self.selCellChildGiftCount = count

		SetActiveFunc(info.cell.btn_sub, count > 0)
		UIUtil.SetImageSprite(self.img_gift, info.data.data.Icon, self)

		self.bgCellGiftID = info.data.id

		self.cellGift:UpdateNoNumType(info.data)

		self.tex_name.text = info.data:GetNameAndDesc()
		self.tex_num.text = _("Desc_Number") .. count

		local gray = TenaryOp(info.holdInfo and count > 0, 0, 1)

		DealWithListRef(self, UIUtil.SetImageGray(self.btn_gift, gray))
	end

	local expOne = tonumber(info.data.data.Value)

	if info.holdInfo then
		if tonumber(info.holdInfo[2]) == 0 then
			expOne = tonumber(info.data.data.Value)
		else
			expOne = tonumber(GetConfigArgInt("FavorExtraNum")) + tonumber(info.data.data.Value)
		end
	end

	local giftItemValue = {}

	giftItemValue.id = info.data.data.ID
	giftItemValue.count = self.selCellChildGiftCount
	giftItemValue.expOne = expOne

	self:AddGiftItemValueLists(giftItemValue)

	local addLevelList = LevelManager:GetPreviewProgress(self.infoRole, self.giftItemValueLists)

	self.addLevelList = addLevelList

	local count, isMax = 0, false

	if addLevelList and addLevelList[5] then
		count, isMax = LevelManager:GetFavorAddCount(self.infoRole, self.giftItemValueLists, info.data.data.ID, addLevelList[5])
	end

	if not self.isMax and isMax then
		if info.type == 3 then
			self.selCellChildGiftCount = math.min(self.selCellChildGiftCount, count)
			giftItemValue.id = info.data.data.ID
			giftItemValue.count = self.selCellChildGiftCount
			giftItemValue.expOne = expOne

			self:AddGiftItemValueLists(giftItemValue)

			addLevelList = LevelManager:GetPreviewProgress(self.infoRole, self.giftItemValueLists)
			self.addLevelList = addLevelList
			self.bgCellGiftID = info.data.id

			self.cellGift:UpdateNoNumType(info.data)

			self.tex_name.text = info.data:GetNameAndDesc()
			self.tex_num.text = _("Desc_Number") .. self.selCellChildGiftCount
		end

		self.isMax = isMax

		self.DlgFavorInfo:PlayFxMax()
	end

	self.DlgFavorInfo:AddExpLevel(addLevelList)

	self.tex_num.text = "<size=30>" .. self.tex_num.text .. "</size>"

	local colorStr = TenaryOp(self.selCellChildGiftCount == 0 and self.infoRole.curFavorLevel ~= GetConfigArgInt("FavorMaxLevel") and maxNum == 0, string.format("<color=#e22a2a>%s</color>", "×" .. self.selCellChildGiftCount), string.format("<color=#505a61>%s</color>", self.selCellChildGiftCount .. "/" .. maxNum))

	info.cell.tex_num.text = colorStr
end

function PageChildGift:ResetMaxGif()
	self.t = 0
	self.isMax = false
end

function PageChildGift:UpdateAddLevelGift(isChange, roleId)
	if isChange and not self.UIRootObject.activeSelf then
		self.giftItemValueLists = {}
	end

	if roleId then
		self.infoRole = RoleMgr:GetRole(roleId)
	end

	if self.giftItemValueLists then
		local addLevelList = LevelManager:GetPreviewProgress(self.infoRole, self.giftItemValueLists)

		self.DlgFavorInfo:AddExpLevel(addLevelList, true)
	end
end

function PageChildGift:AddGiftItemValueLists(giftItemValue)
	for i, v in ipairs(self.giftItemValueLists) do
		if self.giftItemValueLists[i].id == giftItemValue.id then
			table.remove(self.giftItemValueLists, i)
		elseif self.giftItemValueLists[i].count == 0 then
			table.remove(self.giftItemValueLists, i)
		end
	end

	if giftItemValue.count ~= 0 then
		table.insert(self.giftItemValueLists, giftItemValue)
	end
end

function PageChildGift:UpdateDot()
	for i = 1, 4 do
		RedDotSystemMgr.SetUIRedDot(self["GoTab" .. i], "Role/" .. self.infoRole.id .. "/Interact/Gift/" .. i)
	end
end

function PageChildGift:CancelDot()
	return
end
