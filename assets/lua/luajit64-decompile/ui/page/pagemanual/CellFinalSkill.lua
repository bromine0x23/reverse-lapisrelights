-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageManual/CellFinalSkill.lua

require("UI/Item/UIItemBase")

CellFinalSkill = class("CellFinalSkill", UIItemBase)

function CellFinalSkill:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellFinalSkill:OnLeave()
	self:OnUnRegisterEvent()
	UnloadAllImageSprite(self)

	self.page = nil
end

function CellFinalSkill:OnEnter(vParam)
	local g = self.UIRootObject

	self.ImageIcon = GOUtil.FindChildComponent(g, "Info/ImageIcon", "Image")
	self.Image = GOUtil.FindChildComponent(g, "Info/Image", "Image")
	self.TextName = GOUtil.FindChildComponent(g, "Info/Text", "Text")
	self.Lock = GOUtil.FindChildGameObject(g, "Info/Lock")
	self.Play = GOUtil.FindChildGameObject(g, "Info/Play")
	self.Animator = GOUtil.FindChildComponent(g, "Info/AwardBtn", "Animator")
	self.AwardBtn = GOUtil.FindChildGameObject(g, "Info/AwardBtn")
	self.AwardIcon = GOUtil.FindChildComponent(g, "Info/AwardBtn/Icon", "Image")
	self.AwardCount = GOUtil.FindChildComponent(g, "Info/AwardBtn/Text", "Text")
	self.AwardImg1 = GOUtil.FindChildComponent(self.AwardBtn, "bg", "Image")
	self.AwardImg2 = GOUtil.FindChildComponent(self.AwardBtn, "Image", "Image")
	self.Info = self:GetChildGameObject("Info")
	self.Empty = self:GetChildGameObject("Empty")

	local text = GOUtil.FindChildComponent(g, "Empty/Text", "Text")

	text.text = _("Desc_NoMoreSkill")
end

function CellFinalSkill:OnRegisterEvent()
	self:AddClick(self.UIRootObject, self.OnClicked)
	self:AddClick(self.AwardBtn, self.OnClickedAwardBtn)
end

function CellFinalSkill:OnUnRegisterEvent()
	self:RemoveClick(self.UIRootObject, self.OnClicked)
	self:RemoveClick(self.AwardBtn, self.OnClickedAwardBtn)
end

function CellFinalSkill:OnClicked()
	if self.infoRoleCard.isEmpty then
		return
	end

	if self.isHold then
		UIMgr.HideMsg()

		local infoRole = RoleCardMgr:GetRole(self.infoRoleCard.id)

		Event.Instance:Fire("PlayCardTimeLine", {
			infoRole = infoRole,
			skillId = self.skillInfo.data.ID
		})
	else
		UIMgr.ShowMsg(_("TipsNoCard"))
	end
end

function CellFinalSkill:OnClickedAwardBtn()
	if not self.canGet then
		UIMgr.ShowMsg(_("Msg_Award_Can_Receive_None"))

		return
	end

	NetManager:RequestGetCollectionAward(eCollectionAwardType.FINALSKILL, {
		self.infoRoleCard.id
	}, function(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			table.insert(CollectionManager.skillAwardList, self.infoRoleCard.id)
			Event.Instance:Fire("UpdateRedDot")
			self:SetAwardBtn(false)
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end, {
		self.infoRoleCard.data.CharacterID
	})
	LoadingMgr.Show(eLoadingType.Repeat)
end

function CellFinalSkill:UpdateData(infoRoleCard, hasDot)
	self.infoRoleCard = infoRoleCard

	if self.infoRoleCard.isEmpty then
		self.Empty:SetActive(true)
		self.Info:SetActive(false)

		return
	else
		self.Empty:SetActive(false)
		self.Info:SetActive(true)
	end

	local listSkill = RoleCardMgr:GetCardSkill(infoRoleCard)

	for i, v in ipairs(listSkill) do
		if v.data.Type == eTalentType.Battle and v.data.BattleSkillType == eBattleTalentType.Active then
			self.skillInfo = v
		end
	end

	if not self.skillInfo then
		return
	end

	self.isHold = self.infoRoleCard:IsHold()
	self.isGetAward = table.contains(CollectionManager.skillAwardList, self.infoRoleCard.id)

	self.Lock:SetActive(not self.isHold)
	self.Play:SetActive(self.isHold)

	local canGet = self.isHold and not self.isGetAward

	self:SetAwardBtn(canGet)
	UIUtil.SetImageSprite(self.AwardIcon, ItemManager:GetIcon(self.infoRoleCard.data.Award[1][1]), self.page)

	self.AwardCount.text = "x" .. self.infoRoleCard.data.Award[1][2]

	UIUtil.SetImageSprite(self.ImageIcon, infoRoleCard.data.SkillIconlook, self.page, false)

	self.TextName.text = Lang(self.skillInfo.data.Name)
end

function CellFinalSkill:SetAwardBtn(canGet)
	if table.contains(CollectionManager.skillAwardList, self.infoRoleCard.id) then
		self.AwardBtn:SetActive(false)

		return
	end

	self.AwardBtn:SetActive(true)

	self.canGet = canGet

	local gray = TenaryOp(canGet, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.AwardImg1, gray))
	DealWithListRef(self, UIUtil.SetImageGray(self.AwardImg2, gray))
	DealWithListRef(self, UIUtil.SetImageGray(self.AwardIcon, gray))

	if canGet then
		self.Animator:Play("Award_Get", 0, 0)
		GOUtil.SetTextColor(self.AwardCount.gameObject, 193, 115, 158)
	else
		self.Animator:Play("Empty", 0, 0)
		GOUtil.SetTextColor(self.AwardCount.gameObject, 88, 94, 109)
	end
end
