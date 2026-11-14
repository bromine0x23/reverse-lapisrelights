-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageClassroom/DlgMainStageCardPanel.lua

DlgMainStageCardPanel = class("DlgMainStageCardPanel", UIPanel)

function DlgMainStageCardPanel:ctor()
	self.base.ctor(self, "UI/PanelMainStage/DlgMainStageCardPanel")
end

function DlgMainStageCardPanel:Purge()
	self.base.Purge(self)

	if self.groupHandle then
		ResourceMgr.Cancel(self.groupHandle)

		self.groupHandle = nil
	end

	if self.CardIcon then
		GOUtil.DestroyAllChildren(self.CardIcon.gameObject)
	end

	UnloadAllImageSprite(self)
end

function DlgMainStageCardPanel:OnRegisterEvent()
	self:AddClick(self.GoCard, self.OnClickedPanelCard)
	self:AddListener(self.GoCard, self.OnBeginDrag, EventTriggerType.BeginDrag)
	self:AddListener(self.GoCard, self.OnDrag, EventTriggerType.Drag)
	self:AddListener(self.GoCard, self.OnEndDrag, EventTriggerType.EndDrag)
end

function DlgMainStageCardPanel:OnUnRegisterEvent()
	self:RemoveClick(self.GoCard, self.OnClickedPanelCard)
	self:RemoveListener(self.GoCard, self.OnBeginDrag, EventTriggerType.BeginDrag)
	self:RemoveListener(self.GoCard, self.OnDrag, EventTriggerType.Drag)
	self:RemoveListener(self.GoCard, self.OnEndDrag, EventTriggerType.EndDrag)
end

function DlgMainStageCardPanel:OnEnter(vParam)
	self.page = vParam

	self.UIRootObject.transform:SetAsFirstSibling()

	self.GoCard = self:GetChildGameObject("CardMode")
	self.CardIcon = self:GetChildComponent("CardMode/CardIcon", "RawImage")
	self.CardBg = self:GetChildComponent("CardMode/CardBg", "RawImage")
	self.GoL = self:GetChildGameObject("CardMode/ImgLeft")
	self.GoR = self:GetChildGameObject("CardMode/ImgRight")

	self.GoL:SetActive(false)
	self.GoR:SetActive(false)
	self:InitData()
end

function DlgMainStageCardPanel:InitData()
	self.curSeat = PersistentStoreUtil.Get2DMainShowSeat()
	self.preSeat = self.curSeat

	self:GetCardList()
end

function DlgMainStageCardPanel:Show()
	local function cb()
		self.UIRootObject:SetActive(true)
		Event.Instance:Fire("UpdateSceneDisplay", false)
	end

	self:UpdateCardPanel(cb)
end

function DlgMainStageCardPanel:Hide()
	Event.Instance:Fire("UpdateSceneDisplay", true)
	self.UIRootObject:SetActive(false)
	UnloadAllImageSprite(self)
end

function DlgMainStageCardPanel:GetCardList()
	self.listRoleCard = {}

	local roleCardIds = PlayerInst.InfoPlayer.roleCards

	for i = 1, #roleCardIds do
		local infoRoleCard = RoleCardMgr:GetRoleCard(roleCardIds[i])

		table.insert(self.listRoleCard, infoRoleCard)
	end

	self.cardCnt = table.getn(self.listRoleCard)
end

function DlgMainStageCardPanel:OnClickedPanelCard()
	if self.isDraging then
		return
	end

	self.page.hideUI = not self.page.hideUI

	Event.Instance:Fire("DealWithUIAnim", self.page.hideUI)
end

function DlgMainStageCardPanel:UpdateCardPanel(cb)
	local infoRoleCard = self.listRoleCard[self.curSeat]

	if not infoRoleCard then
		return
	end

	if self.groupHandle then
		ResourceMgr.Cancel(self.groupHandle)

		self.groupHandle = nil
	end

	self.preGoSpine = self.GoSpine

	if infoRoleCard.data.SpineData ~= "" then
		self.CardIcon.enabled = false

		self.CardBg.gameObject:SetActive(false)

		local spineRef = ResourceMgr.LoadSync(infoRoleCard.data.SpineData .. "_Anim_All", GameObject)

		if spineRef then
			DealWithListSpineRef(self, spineRef)

			self.GoSpine = GOUtil.InstantiateUIPrefab(spineRef, self.CardIcon.gameObject)

			GOUtil.UpdateSpineSkeleton(self.GoSpine)
		else
			self.CardIcon.enabled = true

			self.CardBg.gameObject:SetActive(true)
			RoleCardMgr:SetInfoPanel(infoRoleCard, self.CardIcon, self.CardBg, self)
			GOUtil.SetTransformLocalScale(self.CardIcon.gameObject, 1)
		end

		if self.preGoSpine then
			Object.Destroy(self.preGoSpine)
		end
	else
		self.CardIcon.enabled = true

		self.CardBg.gameObject:SetActive(true)
		RoleCardMgr:SetInfoPanel(infoRoleCard, self.CardIcon, self.CardBg, self)
		GOUtil.SetTransformLocalScale(self.CardIcon.gameObject, 1)

		if self.preGoSpine then
			Object.Destroy(self.preGoSpine)
		end
	end

	if cb then
		cb()
	end
end

function DlgMainStageCardPanel:OnBeginDrag(data)
	self.posBegin = data.position
	self.prePos = self.posBegin
end

function DlgMainStageCardPanel:OnDrag(data)
	self.isDraging = true

	local pos = data.position - self.posBegin

	self.posBegin = data.position
end

function DlgMainStageCardPanel:OnEndDrag(data)
	self.isDraging = false

	local curPos = data.position
	local disPos = curPos - self.prePos
	local x = disPos.x
	local sw = Screen.width

	if x > 0 and math.abs(x) > sw / 5 then
		self.curSeat = self.curSeat - 1

		if self.curSeat < 1 then
			self.curSeat = 1
		end
	elseif x < 0 and math.abs(x) > sw / 5 then
		self.curSeat = self.curSeat + 1

		if self.curSeat > self.cardCnt then
			self.curSeat = self.cardCnt
		end
	end

	if self.curSeat ~= self.preSeat then
		PersistentStoreUtil.Set2DMainShowSeat(self.curSeat)
		self:UpdateCardPanel()

		self.preSeat = self.curSeat
	end
end
