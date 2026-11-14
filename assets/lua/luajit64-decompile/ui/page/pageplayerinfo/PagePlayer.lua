-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePlayerInfo/PagePlayer.lua

require("UI/Page/PagePlayerInfo/DlgModifyNick")
require("UI/Page/PagePlayerInfo/PageHead")
require("UI/Page/PagePlayerInfo/PageTitle")

PagePlayer = class("PagePlayer", UIPanel, true)

function PagePlayer:ctor()
	self.UIPrefabPath = "UI/PanelPlayerInfo/PanelPlayerInfo"

	self:AddChildPanel(DlgExit(), {
		hideHome = true,
		panel = self,
		title = _("eReturn_PlayerInfo_2"),
		callback = self.OnBack
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PagePlayer:OnBack()
	UIMgr.PopPanel()
end

function PagePlayer:Purge()
	self.base.Purge(self)
	self:OnLeave()

	if self.IsNeedDealUnload then
		RoleCardMgr:UnloadEffect()
	end
end

function PagePlayer:OnLeave()
	if self.DlgPreviewActor then
		self.DlgPreviewActor:Purge()

		self.DlgPreviewActor = nil
	end

	for i = 1, #self.listCard do
		if self.listCard[i] then
			local isShow = RoleCardMgr.ShowCardEffect(self.listCard[i])

			if isShow then
				RoleCardMgr:UnloadEffect()
			end
		end
	end
end

function PagePlayer:OnRegisterEvent()
	self:AddClick(self.BtnModName, self.OnClickBtnModName)
	self:AddClick(self.BtnCopyId, self.OnClickBtnCopyId)
	self:AddClick(self.BtnBorn, self.OnClickBtnBorn)
	self:AddClick(self.BtnSign, self.OnClickBtnSign)
	self:AddClick(self.BtnChangeHead, self.OnClickBtnChangeHead)
	self:AddClick(self.BtnChangeRole, self.OnClickBtnChangeRole)
	self:AddClick(self.BtnFittingRoom, self.OnClickBtnFittingRoom)
	self:AddClick(self.BtnPrompt, self.OnClickBtnPrompt)
	Event.Instance:Add(EventEnum.UpdatePlayerInfo, self.UpdatePlayerInfo, self)
end

function PagePlayer:OnUnRegisterEvent()
	self:RemoveClick(self.BtnModName, self.OnClickBtnModName)
	self:RemoveClick(self.BtnCopyId, self.OnClickBtnCopyId)
	self:RemoveClick(self.BtnBorn, self.OnClickBtnBorn)
	self:RemoveClick(self.BtnSign, self.OnClickBtnSign)
	self:RemoveClick(self.BtnChangeHead, self.OnClickBtnChangeHead)
	self:RemoveClick(self.BtnChangeRole, self.OnClickBtnChangeRole)
	self:RemoveClick(self.BtnFittingRoom, self.OnClickBtnFittingRoom)
	self:RemoveClick(self.BtnPrompt, self.OnClickBtnPrompt)

	if self.IsMine then
		self:RemoveClick(self.BtnChangeMedal, self.OnClickModifyMedal)

		for i = 1, 4 do
			self:RemoveClick(self["SlotCard" .. i], self.OnClickSlot)
		end
	end

	Event.Instance:Remove(EventEnum.UpdatePlayerInfo, self.UpdatePlayerInfo, self)
end

function PagePlayer:OnEnter(vParam)
	if not GuideMgr:IsGuided(GuideFunctionType.PlayerInfo) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.PlayerInfo)
	end

	self:DealWithLocalization()

	self.BtnChangeRole = self:GetChildGameObject("Panel/BtnChangeRole")
	self.BtnFittingRoom = self:GetChildGameObject("Panel/BtnFittingRoom")
	self.BtnModName = self:GetChildGameObject("Panel/Info/Player/Bg1/Name/BtnModName")
	self.BtnCopyId = self:GetChildGameObject("Panel/Info/Player/Bg1/UID/BtnCopyId")
	self.BtnBorn = self:GetChildGameObject("Panel/Info/Player/Bg1/Birthday/BtnBorn")
	self.BtnSign = self:GetChildGameObject("Panel/Info/Player/Bg2/BtnSign")
	self.BtnChangeHead = self:GetChildGameObject("Panel/Info/Player/Head")
	self.BtnPrompt = self:GetChildGameObject("Panel/Info/Show/BtnPrompt")
	self.BtnAddMedal = self:GetChildGameObject("Panel/Info/AddMedal")
	self.BtnChangeMedal = self:GetChildGameObject("Panel/Info/ChangeMedal")
	self.GoMedalIcon = self:GetChildGameObject("Panel/Info/MedalIcon")
	self.GoChangeTip = self:GetChildGameObject("Panel/Info/Player/ChangeHead")
	self.PlayerID = self:GetChildComponent("Panel/Info/Player/Bg1/UID/TxtId", "Text")
	self.Control = self:GetChildComponent("Panel/Role", "UI3DRenderControl")
	self.DlgPreviewActor = DlgPreviewActor()
	self.DlgPreviewActor.IsLeft = true

	self.DlgPreviewActor:Init(self.Control, false, true)
	self:InitData(vParam)

	self.IsNeedDealUnload = false
end

function PagePlayer:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/BtnFittingRoom/Text", "Text")
	txt.text = Lang(12452)
	txt = self:GetChildComponent("Panel/Info/Player/Bg1/Name/Text", "Text")
	txt.text = Lang(42099)
	txt = self:GetChildComponent("Panel/Info/Player/Bg1/Level/Text", "Text")
	txt.text = Lang(12004)
	txt = self:GetChildComponent("Panel/Info/Player/Bg1/UID/Text", "Text")
	txt.text = Lang(42155)
	txt = self:GetChildComponent("Panel/Info/Player/Bg1/Birthday/Text", "Text")
	txt.text = Lang(42156)
	txt = self:GetChildComponent("Panel/Info/Player/Bg2/Text", "Text")
	txt.text = Lang(42157)
	txt = self:GetChildComponent("Panel/Info/Player/Achive/Chapter/Text", "Text")
	txt.text = Lang(42161)
	txt = self:GetChildComponent("Panel/Info/Player/Achive/CardNum/Text", "Text")
	txt.text = Lang(42162)
	txt = self:GetChildComponent("Panel/Info/Show/Title/Text", "Text")
	txt.text = Lang(42160)
	txt = self:GetChildComponent("Panel/Info/Player/Bg1/UID/BtnCopyId/Txt", "Text")
	txt.text = Lang(12377)
	txt = self:GetChildComponent("Panel/Info/Show/TxtTip", "Text")
	txt.text = Lang(12977)
end

function PagePlayer:InitData(vParam)
	self.IsMine = true

	if not vParam or not vParam.player then
		self.infoPlayer = PlayerInst.InfoPlayer
	else
		self.IsMine = false
		self.infoPlayer = InfoPlayer()

		self.infoPlayer:SetData(vParam.player)

		self.infoPlayer.roleCards = vParam.roleCards or {}
		self.infoPlayer.stageId = vParam.mainStageId
		self.infoPlayer.cardCount = vParam.cardCount or 0
	end

	self:UpdatePanel()
	self:InitCard()

	if vParam and vParam.SwitchHead then
		PlayerInst.tabIndex = 1

		UIMgr.AddPanel(PageHead(), {
			headId = vParam.SwitchHead
		})

		vParam.SwitchHead = nil
		vParam.SwitchHead = nil
	end

	if vParam and vParam.SwitchHeadFrame then
		PlayerInst.tabIndex = 2

		UIMgr.AddPanel(PageHead(), {
			headId = vParam.SwitchHeadFrame
		})

		vParam.SwitchHeadFrame = nil
		vParam.SwitchHeadFrame = nil
	end
end

function PagePlayer:UpdatePanel()
	GOUtil.SetActive(self.BtnChangeRole, self.IsMine)
	GOUtil.SetActive(self.BtnFittingRoom, self.IsMine)
	GOUtil.SetActive(self.BtnModName, self.IsMine)
	GOUtil.SetActive(self.BtnSign, self.IsMine)
	GOUtil.SetActive(self.GoChangeTip, self.IsMine)
	GOUtil.SetActive(self.BtnPrompt, self.IsMine)

	local txtId = self:GetChildComponent("Panel/Info/Player/Bg1/UID/TxtId", "Text")

	txtId.text = self.infoPlayer.pid

	local txtLevel = self:GetChildComponent("Panel/Info/Player/Bg1/Level/TxtLevel", "Text")

	txtLevel.text = self.infoPlayer.curLevel

	local txtMain = self:GetChildComponent("Panel/Info/Player/Achive/Chapter/TxtMain", "Text")
	local txtCard = self:GetChildComponent("Panel/Info/Player/Achive/CardNum/TxtCard", "Text")
	local cIdx, sIdx, cardCnt = 1, 1, 0

	if self.IsMine then
		cIdx, sIdx = ChapterMgr:GetMainCompleteRate()
		cardCnt = table.getn(RoleCardMgr:GetAllHoldCard())
	else
		cIdx, sIdx = ChapterMgr:GetMainCompleteRate(self.infoPlayer.stageId)
		cardCnt = self.infoPlayer.cardCount
	end

	txtMain.text = string.format("%s-%s", tostring(cIdx), tostring(sIdx))

	local maxCardCnt = table.getn(RoleCardMgr:GetAllCard())

	txtCard.text = GetPreciseDecimal(cardCnt / maxCardCnt * 100, 1) .. "%"

	self:UpdateNick()
	self:UpdateBirthday()
	self:UpdateSignature()
	self:UpdateShowRole()
	self:UpdateHead()
	self:UpdateFrame()
	self:UpdateMedal()
end

function PagePlayer:UpdateNick()
	if not self.TxtPlayerName then
		self.TxtPlayerName = self:GetChildComponent("Panel/Info/Player/Bg1/Name/TxtName", "Text")
	end

	self.TxtPlayerName.text = self.infoPlayer:GetNickName()
end

function PagePlayer:UpdateBirthday()
	if not self.TxtBirthday then
		self.TxtBirthday = self:GetChildComponent("Panel/Info/Player/Bg1/Birthday/TxtBorn", "Text")
	end

	local bornTime = self.infoPlayer:GetBirthday()

	GOUtil.SetActive(self.BtnBorn, self.IsMine and tonumber(bornTime) == 0)

	if tonumber(bornTime) <= 0 then
		self.TxtBirthday.text = _("Desc_Not_Setting")

		return
	end

	local month = math.modf(tonumber(bornTime) / 100)
	local day = tonumber(bornTime) - month * 100

	self.TxtBirthday.text = string.format(_("Desc_TimeShow"), month, day)
end

function PagePlayer:UpdateSignature()
	if not self.TxtSign then
		self.TxtSign = self:GetChildComponent("Panel/Info/Player/Bg2/TxtSign", "Text")
	end

	local str = self.infoPlayer.signature

	if string.isNullOrEmpty(str) then
		UIUtil.SetGraphicAlpha(self.TxtSign, 0.6274509803921569)
	else
		UIUtil.SetGraphicAlpha(self.TxtSign, 1)
	end

	self.TxtSign.text = self.infoPlayer:GetSignature()
end

function PagePlayer:UpdateShowRole()
	local infoRole = RoleMgr:GetRole(self.infoPlayer:GetShowRole())

	if not self.IsMine then
		infoRole = InfoRole(self.infoPlayer:GetShowRole())

		if self.infoPlayer.leader.id > 0 then
			infoRole:SetData(self.infoPlayer.leader)
		end

		infoRole:SetPBPlayer(self.infoPlayer.pb)
	end

	if infoRole == nil then
		GOUtil.SetActive(self.Control, false)

		return
	end

	if self.DlgPreviewActor then
		self.DlgPreviewActor:LoadActor(infoRole, true)
	end
end

function PagePlayer:UpdateHead()
	if not self.ImgHead then
		self.ImgHead = self:GetChildComponent("Panel/Info/Player/Head", "Image")
	end

	local infoItem = ItemManager:Get(self.infoPlayer.headId)

	SetImageSprite(self.ImgHead, infoItem:GetIcon(), self)
end

function PagePlayer:UpdateFrame()
	if not self.ImgHeadFrame then
		self.ImgHeadFrame = self:GetChildComponent("Panel/Info/Player/Head/HeadFrame", "Image")
	end

	local infoItem = ItemManager:Get(self.infoPlayer.headFrame)

	SetImageSprite(self.ImgHeadFrame, infoItem:GetIcon(), self)
end

function PagePlayer:UpdateMedal()
	if self.IsMine then
		self:AddClick(self.BtnChangeMedal, self.OnClickModifyMedal)
	end

	SetActiveFunc(self.BtnAddMedal, self.infoPlayer.medal == 0)
	SetActiveFunc(self.BtnChangeMedal, self.IsMine)
	SetActiveFunc(self.GoMedalIcon, self.infoPlayer.medal ~= 0)

	if self.infoPlayer.medal == 0 then
		local txtMedal = self:GetChildComponent("Panel/Info/AddMedal/Text", "Text")

		txtMedal.text = Lang(42158)

		local txtMedalPrompt = self:GetChildComponent("Panel/Info/AddMedal/Text2", "Text")

		if self.IsMine then
			txtMedalPrompt.text = Lang(42163)
			txtMedalPrompt.enabled = false
		else
			txtMedalPrompt.text = Lang(42164)
		end
	else
		if IsNil(self.MedalIcon) then
			self.MedalIcon = self:GetChildComponent("Panel/Info/MedalIcon/Icon", "Image")
		end

		infoItem = ItemManager:Get(self.infoPlayer.medal)

		SetImageSprite(self.MedalIcon, infoItem:GetIcon(), self)

		if self.IsMine then
			local txtMedalPrompt = self:GetChildComponent("Panel/Info/ChangeMedal/Text", "Text")

			txtMedalPrompt.text = _("UI_Change_Point")
		end
	end
end

function PagePlayer:UpdatePlayerInfo(_type)
	if _type == ePlayerInfoType.nickName then
		self:UpdateNick()
	elseif _type == ePlayerInfoType.birthday then
		self:UpdateBirthday()
	elseif _type == ePlayerInfoType.signature then
		self:UpdateSignature()
	elseif _type == ePlayerInfoType.showRole then
		self:UpdateShowRole()
	elseif _type == ePlayerInfoType.showCards then
		-- block empty
	elseif _type == ePlayerInfoType.head then
		self:UpdateHead()
	elseif _type == ePlayerInfoType.headFrame then
		self:UpdateFrame()
	elseif _type == ePlayerInfoType.medal then
		self:UpdateMedal()
	end
end

function PagePlayer:OnClickBtnModName()
	if not self.IsMine then
		return
	end

	UIMgr.AddPanel(DlgModifyNick(), {
		eModifyInputType.Nick
	})
end

function PagePlayer:OnClickBtnBorn()
	if not self.IsMine then
		return
	end

	require("UI/Page/PagePlayerInfo/DlgSetBirthday")
	UIMgr.AddPanel(DlgSetBirthday())
end

function PagePlayer:OnClickBtnSign()
	if not self.IsMine then
		return
	end

	UIMgr.AddPanel(DlgModifyNick(), {
		eModifyInputType.Signature
	})
end

function PagePlayer:OnClickBtnCopyId()
	GOUtil.CopyToClipBoard(self.infoPlayer.pid)
	UIMgr.ShowMsg(_("Msg_Copy_Success"))
end

function PagePlayer:OnClickBtnChangeHead()
	if not self.IsMine then
		return
	end

	UIMgr.AddPanel(PageHead(), nil)
end

function PagePlayer:OnClickBtnFittingRoom()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Dress)

	if not isOpen then
		return
	end

	if not self.IsMine then
		return
	end

	local infoRole = RoleMgr:GetRole(self.infoPlayer:GetShowRole())

	require("UI/Page/PageFittingroom/PageFittingroom")
	UIMgr.SwitchPanel(PageFittingroom, {
		infoRole = infoRole
	})
end

function PagePlayer:OnClickBtnChangeRole()
	if not self.IsMine then
		return
	end

	require("UI/Page/PagePlayerInfo/DlgSetRole")
	UIMgr.AddPanel(DlgSetRole())
end

function PagePlayer:OnClickModifyMedal()
	if not self.IsMine then
		return
	end

	UIMgr.SwitchPanel(PageTitle)
	TitleRDL.RemovePlayerPrefs(PLAYER_TITLE_TYPE.Medal)
end

function PagePlayer:OnClickBtnPrompt()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.PlayerInfo)
end

function PagePlayer:InitCard()
	local raycast = self:GetChildComponent("Panel/Info/Show/Slot", "GraphicRaycaster")

	raycast.enabled = self.IsMine
	self.listCard = {}
	self.listCardId = {}

	for _, v in ipairs(self.infoPlayer.roleCards) do
		local infoCard

		if self.IsMine then
			if v ~= 0 then
				infoCard = RoleCardMgr:GetRoleCard(v)
			end
		else
			infoCard = InfoRoleCard(v.id)
			v.playerId = self.infoPlayer.pid

			infoCard:SetPBPlayer(self.infoPlayer.pb)
			infoCard:SetData(v)
		end

		if infoCard then
			table.insert(self.listCard, infoCard)
			table.insert(self.listCardId, infoCard.id)
		end
	end

	for i = 1, 4 do
		local card = self:GetChildGameObject("Panel/Info/Show/Slot/Card/" .. i)

		self["SlotCard" .. i] = card
		self["UIDragExchangeObj" .. i] = GOUtil.GetComponent(card, "UIDragExchangeObject")

		if self.IsMine then
			self:AddClick(self["SlotCard" .. i], self.OnClickSlot)
		end

		if i > #self.listCard then
			GOUtil.SetActive(card, false)
		end

		if i <= #self.listCard then
			local infoCard = self.listCard[i]
			local imgIcon = GOUtil.FindChildComponent(card, "Mask/Icon", "Image")
			local imgRank = GOUtil.FindChildComponent(card, "Rank", "Image")
			local imgJob = GOUtil.FindChildComponent(card, "RoleJob", "Image")
			local cardEff = GOUtil.FindChildGameObject(card, "CardEffect")

			SetImageSprite(imgIcon, infoCard.data.MidIcon, self)
			SetImageSprite(imgRank, "UIDyAtlas/RoleCardRank/BG_card_back_" .. infoCard.rank .. "_14", self)
			SetImageSprite(imgJob, "UI/PanelPlayerInfo/AtlasPlayerInfo/ICO_" .. infoCard.JobStr .. "_01_S", self)

			local txtName = GOUtil.FindChildComponent(card, "Text", "Text")
			local txtLevel = GOUtil.FindChildComponent(card, "TxtLevel", "Text")

			txtName.text = infoCard:GetName()
			txtLevel.text = infoCard.curLevel

			local isShow = RoleCardMgr.ShowCardEffect(infoCard)

			if not self.IsNeedDealUnload and isShow then
				RoleCardMgr:CreateEffect()

				self.IsNeedDealUnload = true
			end

			SetActiveFunc(cardEff, isShow)

			local temp = {}

			temp.GoFrame = GOUtil.FindChildGameObject(card, "Star/Frame")
			temp.GoStar1 = GOUtil.FindChildGameObject(card, "Star/Star1")
			temp.GoStar2 = GOUtil.FindChildGameObject(card, "Star/Star2")

			RoleCardMgr:SetStar(infoCard, temp)

			for j = 1, 4 do
				local cardPetal = GOUtil.FindChildGameObject(card, "Flower/State" .. j)

				GOUtil.SetActive(cardPetal, j == infoCard.cardRank)

				if j == infoCard.cardRank then
					for k = 1, infoCard.maxPetal do
						local imgF = GOUtil.FindChildComponent(cardPetal, "" .. k, "Image")
						local gray = TenaryOp(k <= infoCard.curPetal, 0, 1)

						DealWithListRef(self, UIUtil.SetImageGray(imgF, gray))
					end
				end
			end
		end
	end

	self.UIDragExchange = self:GetChildComponent("Panel/Info/Show/Slot/Card", "UIDragExchange")

	function self.UIDragExchange.BeginDragEvent(index)
		self:BeginDragEvent(index)
	end

	function self.UIDragExchange.EndDragEvent(preIdx, curIdx)
		self:EndDragEvent(preIdx, curIdx)
	end
end

function PagePlayer:BeginDragEvent(index)
	local idx

	for i = 1, 4 do
		if self["UIDragExchangeObj" .. i].ObjIndex == index then
			idx = i

			break
		end
	end

	if idx ~= nil and not IsNil(self["SlotCard" .. idx]) then
		self["SlotCard" .. idx].transform:SetAsLastSibling()

		self.raycast = GOUtil.GetComponent(self["SlotCard" .. idx], "UIEmpty4Raycast")
		self.raycast.raycastTarget = false
	end
end

function PagePlayer:EndDragEvent(preIdx, curIdx)
	if self.raycast then
		self.raycast.raycastTarget = true
	end

	if preIdx ~= curIdx then
		local cardId = self.listCardId[curIdx]

		self.listCardId[curIdx] = self.listCardId[preIdx]
		self.listCardId[preIdx] = cardId

		self:RequestModify(self.listCardId)
	end
end

function PagePlayer:OnClickSlot(data)
	if self.UIDragExchange and self.UIDragExchange.IsDragging then
		return
	end

	local go = data.pointerPress.gameObject
	local uiDragExchangeObj = GOUtil.GetComponent(go, "UIDragExchangeObject")

	if uiDragExchangeObj ~= nil then
		local index = tonumber(uiDragExchangeObj.ObjIndex)

		require("UI/Page/PageRoleCard/Page/PageRoleCardList")
		UIMgr.SwitchPanel(PageRoleCardList, {
			showIdx = index,
			entType = eEnterType.cardShow
		})
	end
end

function PagePlayer:RequestModify(listShowCard)
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			PlayerInst.InfoPlayer.roleCards = listShowCard

			UIMgr.ShowMsg(_("Msg_ChangeCardTips"))
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestModifyPlayerInfo({
		roleCards = listShowCard
	}, wrap_cb)
end
