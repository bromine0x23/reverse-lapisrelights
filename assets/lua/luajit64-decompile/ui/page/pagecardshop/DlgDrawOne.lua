-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCardShop/DlgDrawOne.lua

DlgDrawOne = class("DlgDrawOne", UIPanel)

function DlgDrawOne:ctor()
	self.UIPrefabPath = "UI/PageCardShop/PanelDrawOne"
end

function DlgDrawOne:Purge()
	DlgDrawOne.base.Purge(self)

	if self.timeId ~= nil then
		TimerMgr.RemoveTimer(self.timeId)
	end

	if self.timer1 ~= nil then
		TimerMgr.RemoveTimer(self.timer1)
	end

	if self.prefabSpine then
		ResourceMgr.Unload(self.prefabSpine)

		self.prefabSpine = nil
	end

	Event.Instance:Fire("CloseDlgShare")
end

function DlgDrawOne:PreLoad()
	return
end

function DlgDrawOne:OnEnter(vParam)
	self:SetSafeArea(self:GetChildGameObject("CellCard/ImageClick/Safe"))

	self.GoNextClick = self:GetChildGameObject("CellCard/ImageClick")
	self.PanelNewRole = self:GetChildGameObject("CellCard/PanelNewRole")
	self.Animator = self:GetChildComponent("CellCard", "Animator")
	self.AnimatorAvatar = self:GetChildComponent("CellCard/ImageAvatar", "Animator")
	self.callback = vParam.callback
	self.setter = vParam.setter

	if vParam.enterback then
		vParam.enterback()

		vParam.enterback = nil
	end

	local hasNewRole = self.setter.newRole and self.setter.newRole.id > 0
	local hasChangeStar = not self.setter.newRoleCard or not (self.setter.newRoleCard.id > 0)
	local hasRankup = self.setter.extra and self.setter.extra[1] and self.setter.extra[1] > 0

	self.GoCellCard = self:GetChildGameObject("CellCard")

	self:UpdateCellOne(self.GoCellCard, self.setter)

	local TextTitle = self:GetChildComponent("CellCard/PanelNewRole/Panel/Text", "Text")

	TextTitle.text = _("Unlock_new_role")

	self.PanelNewRole:SetActive(false)
	InstructionMgr:TriggerWait("ShowGetDrawCard")

	local function f()
		coroutine.wait(1)

		if hasNewRole then
			self.infoRole = RoleMgr:GetRole(self.setter.newRole.id)

			self.PanelNewRole:SetActive(true)

			local ImageJob = self:GetChildComponent("CellCard/PanelNewRole/Panel/ImageJob", "Image")
			local ImageName = self:GetChildComponent("CellCard/PanelNewRole/Panel/ImageName1", "Image")
			local ImgHead = self:GetChildComponent("CellCard/PanelNewRole/Panel/ImgHead1", "Image")

			UIUtil.SetImageSprite(ImageJob, "UIDyAtlas/RoleJob/ICO_" .. self.infoRole.data.Job .. "_01", self)
			UIUtil.SetImageSprite(ImageName, self.infoRole.data.NameIcon, self)

			local actorData = RoleMgr:GetActorData(self.infoRole.data.ActorID)

			UIUtil.SetImageSprite(ImgHead, actorData.CharacterIcon, self)
		end

		coroutine.wait(0.2)
		self:UpdateSign(hasChangeStar)
	end

	require("UI/Dlg/Public/DlgShare")

	self.ButtonShare = self:GetChildGameObject("CellCard/ImageClick/Safe/ButtonShare")

	DlgShare.UpdateData(self.ButtonShare)

	if InstructionMgr:IsInGuide() and not isShowShare then
		self.ButtonShare:SetActive(false)
	end

	if not NEED_SHARE then
		self.ButtonShare:SetActive(false)
	end
end

function DlgDrawOne:OnRegisterEvent()
	self:AddClick(self.GoNextClick, self.OnButtonGoNextClick)
	self:AddClick(self.ButtonShare, self.OnClickButtonShare)
	EventListenerMgr.AddAnimListener(self.Animator.gameObject, self.EventAnim, self, eAnimEventType.OnAnimationEnd)
	EventListenerMgr.AddAnimListener(self.AnimatorAvatar.gameObject, self.EventAnimAvatar, self, eAnimEventType.OnAnimationEnd)
end

function DlgDrawOne:OnUnRegisterEvent()
	self:RemoveClick(self.GoNextClick, self.OnButtonGoNextClick)
	self:RemoveClick(self.ButtonShare, self.OnClickButtonShare)
	EventListenerMgr.RemoveAnimListener(self.Animator.gameObject, self.EventAnim, self, eAnimEventType.OnAnimationEnd)
	EventListenerMgr.RemoveAnimListener(self.AnimatorAvatar.gameObject, self.EventAnimAvatar, self, eAnimEventType.OnAnimationEnd)
end

function DlgDrawOne:OnClickButtonShare()
	local go = GameObject.Find("ClickEffectMountNode")

	if not IsNil(go) then
		go:SetActive(false)
	end

	self.ButtonShare:SetActive(false)
	require("UI/Dlg/Public/DlgShare")

	local function cb()
		UIMgr:HideBlock()
		self.ButtonShare:SetActive(true)
	end

	Event.Instance:Fire("CloseDlgShare")
	MiscUtil.CaptureRenderTexture(function(t2d)
		UIMgr.AddPanel(DlgShare(), {
			texture = t2d,
			callback = cb,
			GoBtnShare = self.ButtonShare
		})
	end)
end

function DlgDrawOne:PlayVoice(str, actor)
	local listPath = self.infoRole.data.Vocals
	local strPath, strVocal

	for i = 1, #listPath do
		local list = listPath[i]
		local key = list[1]

		if key == str then
			strPath = list[2]
			strVocal = tonumber(list[3])
		end
	end

	if strPath then
		SoundMgr.Play(strPath)

		local ActorLipSync = GOUtil.AddMissingComponent(self.UIRootObject, "ActorLipSync")

		ActorLipSync:Init(self.infoRole.data.Lips)
		self:ShowSubTitle(Lang(strVocal))

		if actor then
			ActorLipSync:Play(actor, strPath)
		end
	end
end

function DlgDrawOne:ShowSubTitle(str)
	if IsNil(self.PanelDlg) then
		return
	end

	self.PanelDlg:SetActive(true)

	self.TextDlg.text = str

	local function cb()
		if not IsNil(self.PanelDlg) then
			self.PanelDlg:SetActive(false)
		end
	end

	if self.timeId ~= nil then
		TimerMgr.RemoveTimer(self.timeId)
	end

	self.timeId = TimerMgr.AddTimer(eTimerType.RealTime, 4, cb, self)
end

function DlgDrawOne:OnButtonGoRoleClick()
	self.PanelNewRole:SetActive(false)
end

function DlgDrawOne:OnButtonGoNextClick()
	if not self.isFinish or not self.isFinishAvatar then
		self.isFinish = true
		self.isFinishAvatar = true

		self.Animator:Update(10)

		if self.infoRoleCard.data.AvatarUnlock[1] and self.infoRoleCard.data.AvatarUnlock[1][2] > 0 then
			self.ImageAvatar:SetActive(true)
			self.AnimatorAvatar:Update(10)
		end
	else
		if self.callback then
			self.callback()

			self.callback = nil
		end

		self:Close()
	end
end

function DlgDrawOne:UpdateCellOne(g, setterData)
	local infoRoleCard = RoleCardMgr:GetRoleCard(setterData.id)

	self.infoRoleCard = infoRoleCard

	local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)
	local CardBg = GOUtil.FindChildComponent(g, "Main/CardMask/Bg", "RawImage")
	local CardIcon = GOUtil.FindChildComponent(g, "Main/CardMask/CardIcon", "RawImage")

	GOUtil.DestroyAllChildren(CardIcon.gameObject)

	if infoRoleCard.data.SpineData ~= "" then
		CardBg.gameObject:SetActive(false)

		CardIcon.enabled = false

		local cardSpine = ResourceMgr.LoadSync(infoRoleCard.data.SpineData .. "_Anim_All")

		if cardSpine then
			local g = GOUtil.InstantiateUIPrefab(cardSpine, CardIcon.gameObject)

			self.prefabSpine = cardSpine
		end
	else
		CardBg.gameObject:SetActive(true)

		CardIcon.enabled = true

		RoleCardMgr:SetInfoPanel(infoRoleCard, CardIcon, CardBg)
	end

	local ImageRank = GOUtil.FindChildComponent(g, "Main/Image1/ImageRank", "Image")

	if infoRoleCard.data.Rank ~= "UR" then
		InfoSoundEventMgr:Play("VocalDrawCard", RoleCardMgr:GetRoleCard(infoRoleCard.id).data.VocalGet)
	end

	UIUtil.SetImageSprite(ImageRank, "UIDyAtlas/RoleCardRank/BG_cardpool_" .. infoRoleCard.data.Rank, self)

	CardName = GOUtil.FindChildComponent(g, "Main/Image1/CardName", "Text")
	CardName.text = infoRoleCard:GetName()

	local ImgHead = GOUtil.FindChildComponent(g, "Main/Image2/ImgHead1", "Image")
	local actorData = RoleMgr:GetActorData(infoRole.data.ActorID)

	UIUtil.SetImageSprite(ImgHead, actorData.CharacterIcon, self)

	local CardJob = GOUtil.FindChildComponent(g, "Main/Image2/Job", "Image")

	UIUtil.SetImageSprite(CardJob, "UIDyAtlas/RoleJob/ICO_" .. infoRole.data.Job .. "_01_S", self)

	local CardJob = GOUtil.FindChildComponent(g, "Main/Image2/Job", "Image")

	UIUtil.SetImageSprite(CardJob, "UIDyAtlas/RoleJob/ICO_" .. infoRole.data.Job .. "_01_S", self)

	local Text1 = GOUtil.FindChildComponent(g, "Main/Image2/Text1", "Text")
	local Text2 = GOUtil.FindChildComponent(g, "Main/Image2/Text2", "Text")

	Text1.text = infoRole:GetName()
	Text2.text = Lang(infoRole.data.CvName)
	self.GoMain = GOUtil.FindChildGameObject(g, "Main")
	self.GoCardStar = GOUtil.FindChildGameObject(g, "ImageStar")

	self.GoMain:SetActive(true)
	self.GoCardStar:SetActive(false)

	self.GoCardNew = GOUtil.FindChildGameObject(g, "ImageNew")

	self.GoCardNew:SetActive(false)

	self.ImageStar = GOUtil.FindChildComponent(g, "ImageStar", "Image")

	self.ImageStar.gameObject:SetActive(false)
	UIUtil.SetImageSprite(self.ImageStar, infoRoleCard.data.RoleStar, self)

	self.ImageAvatar = GOUtil.FindChildGameObject(g, "ImageAvatar")

	self.ImageAvatar:SetActive(false)

	if infoRoleCard.data.AvatarUnlock[1] and infoRoleCard.data.AvatarUnlock[1][2] > 0 then
		self.Icon = GOUtil.FindChildComponent(g, "ImageAvatar/Icon", "Image")

		local infoAvatar = AvatarManager:GetAvatar(infoRoleCard.data.AvatarUnlock[1][2])

		UIUtil.SetImageSprite(self.Icon, infoAvatar.data.Icon, self)

		self.timer1 = TimerMgr.AddTimer(eTimerType.RealTime, 0.5, function()
			self.ImageAvatar:SetActive(true)
		end, self)
	else
		self.isFinishAvatar = true
	end
end

function DlgDrawOne:UpdateSign(hasChangeStar)
	if IsNil(self.ImageStar) then
		return
	end

	if hasChangeStar then
		self.ImageStar.gameObject:SetActive(true)
	else
		self.GoCardNew:SetActive(false)
	end
end

function DlgDrawOne:EventAnim()
	self.isFinish = true
end

function DlgDrawOne:EventAnimAvatar()
	self.isFinishAvatar = true
end

function DlgDrawOne:OnBackAndroid()
	self:OnButtonGoNextClick()

	return true
end
