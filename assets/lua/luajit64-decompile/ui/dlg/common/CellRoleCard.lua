-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/CellRoleCard.lua

require("UI/Item/UIItemBase")

CellRoleCard = class("CellRoleCard", UIItemBase)

function CellRoleCard:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellRoleCard:Create(vParam)
	CellRoleCard.base.Create(self, vParam)
end

function CellRoleCard:OnEnter()
	local g = self.UIRootObject
	local txt = GOUtil.FindChildComponent(g, "Hold/Equiped/Image/Text", "Text")

	txt.text = _("Desc_Shown")
	txt = GOUtil.FindChildComponent(g, "NotHold/Text", "Text")
	txt.text = _("Desc_More_Not")
	self.RICardBg = GOUtil.FindChildComponent(g, "Hold/Card/Bg", "RawImage")
	self.RICardIcon = GOUtil.FindChildComponent(g, "Hold/Card/Icon", "RawImage")
	self.ImgCardRank = GOUtil.FindChildComponent(g, "Hold/CardRank", "Image")
	self.ImgCardJob = GOUtil.FindChildComponent(g, "Hold/RoleJob", "Image")
	self.TxtCardName = GOUtil.FindChildComponent(g, "Hold/Other/TxtCard", "Text")
	self.TxtCardLevel = GOUtil.FindChildComponent(g, "Hold/Other/TxtValue", "Text")
	self.TxtCardLevel.fontSize = 24
	self.GoFrame = GOUtil.FindChildGameObject(g, "Hold/Other/CardStar/Frame")
	self.GoStar1 = GOUtil.FindChildGameObject(g, "Hold/Other/CardStar/Star1")
	self.GoStar2 = GOUtil.FindChildGameObject(g, "Hold/Other/CardStar/Star2")

	for i = 1, table.getCount(eRankType) do
		self["GoPetal" .. i] = GOUtil.FindChildGameObject(g, "Hold/Petal/State" .. i)
	end

	self.GoHold = GOUtil.FindChildGameObject(g, "Hold")
	self.GoNotHold = GOUtil.FindChildGameObject(g, "NotHold")
	self.GoEquiped = GOUtil.FindChildGameObject(g, "Hold/Equiped")
	self.DlgLongTip = ResourceMgr.LoadSync("UI/Common/DlgCommon/DlgLongTip")
	self.longPress = false
	self.CardEffect = GOUtil.FindChildGameObject(g, "Hold/CardEffect")

	self:AddListener(g, self.OnPointerDownRoot, EventTriggerType.PointerDown)
	self:AddListener(g, self.OnPointerUpRoot, EventTriggerType.PointerUp)
	self:AddListener(g, self.OnLongPressRoot, EventTriggerType.PointerLongPress)

	self.IsNeedDealUnload = false
end

function CellRoleCard:OnLeave()
	self:RemoveClick(self.UIRootObject, self.OnPointerDownRoot, EventTriggerType.PointerDown)
	self:RemoveClick(self.UIRootObject, self.OnPointerUpRoot, EventTriggerType.PointerUp)
	self:RemoveClick(self.UIRootObject, self.OnLongPressRoot, EventTriggerType.PointerLongPress)

	if self.groupHandle then
		ResourceMgr.Cancel(self.groupHandle)

		self.groupHandle = nil
	end

	UnloadAllImageSprite(self)

	if self.DlgLongTip then
		ResourceMgr.Unload(self.DlgLongTip)

		self.DlgLongTip = nil
	end

	if self.IsNeedDealUnload then
		RoleCardMgr:UnloadEffect()
	end
end

function CellRoleCard:UpdateData(infoRoleCard)
	if not self.page.updated then
		return
	end

	if not infoRoleCard then
		if self.infoRoleCard then
			PrintWithColor(self.infoRoleCard.id .. "------------", "red")
		end

		return
	end

	self.infoRoleCard = infoRoleCard
	self.infoRole = RoleCardMgr:GetRole(infoRoleCard.id)

	if self.infoRoleCard:IsHold() then
		self:SetCardInfo()
	else
		GOUtil.SetActive(self.GoHold, false)
		GOUtil.SetActive(self.GoNotHold, true)
	end

	local isShow = RoleCardMgr.ShowCardEffect(self.infoRoleCard)

	if not self.IsNeedDealUnload and isShow then
		RoleCardMgr:CreateEffect()

		self.IsNeedDealUnload = true
	end

	GOUtil.SetActive(self.CardEffect, isShow)
end

function CellRoleCard:SetCardInfo()
	GOUtil.DestroyAllChildren(self.RICardIcon.gameObject)

	local function fun()
		self.TxtCardName.text = self.infoRoleCard:GetName()
		self.TxtCardLevel.text = self.infoRoleCard.curLevel

		SetImageSprite(self.ImgCardRank, "UIDyAtlas/RoleCardRank/BG_card_back_" .. self.infoRoleCard.rank .. "_12", self)
		SetImageSprite(self.ImgCardJob, "UIDyAtlas/RoleJob/ICO_" .. self.infoRoleCard.JobStr .. "_01_S", self)
		RoleCardMgr:SetStar(self.infoRoleCard, self)
		RoleCardMgr:SetPetal(self.infoRoleCard, self)
		GOUtil.SetActive(self.GoHold, true)
		GOUtil.SetActive(self.GoNotHold, false)
		self:UpdateSelectState(self.infoRoleCard ~= nil and self.infoRole.pb.roleCardId == self.infoRoleCard.id)
	end

	if self.infoRoleCard.data.SpineData ~= "" then
		self.RICardIcon.enabled = false

		GOUtil.SetActive(self.RICardBg, false)

		local function wrap_cb()
			if self.UIRootObject ~= nil and self.spineRef then
				local spine = GOUtil.InstantiateUIPrefab(self.spineRef, self.RICardIcon.gameObject)

				GOUtil.UpdateSpineSkeleton(self.RICardIcon.gameObject)

				if GOUtil.GetComponent(spine, "SpineAspectRatioFitter") then
					GOUtil.GetComponent(spine, "SpineAspectRatioFitter").enabled = false
				end

				DealWithListSpineRef(self, self.spineRef, 5)
				fun()
			end
		end

		self.groupHandle = ResourceMgr.BeginSubmit(wrap_cb)

		ResourceMgr.SubmitCache(self.infoRoleCard.data.SpineData .. "_Anim", self, "spineRef", GameObject)
		ResourceMgr.EndSubmit()
	else
		self.RICardIcon.enabled = true

		GOUtil.SetActive(self.RICardBg, true)
		RoleCardMgr:SetInfoPanel(self.infoRoleCard, self.RICardIcon, self.RICardBg, self)
		fun()
	end

	RoleCardMgr:SetCardLocation(self.infoRoleCard, self.RICardIcon.gameObject, 1)
end

function CellRoleCard:UpdateSelectState(state)
	GOUtil.SetActive(self.GoEquiped, state)
end

function CellRoleCard:OnPointerDownRoot()
	self.longPress = false
end

function CellRoleCard:OnPointerUpRoot()
	if not self.longPress then
		self.page:SetEquipCard(self.Index)
	end
end

function CellRoleCard:OnLongPressRoot(data)
	if data.clickCount == 1 then
		self.longPress = true

		if not self.GoDlgLongTip then
			self.GoDlgLongTip = GOUtil.InstantiatePrefab(self.DlgLongTip, self.UIRootObject)
		end

		GOUtil.FindChildComponent(self.GoDlgLongTip, "BG/Bar", "UIDlgLongTip").onEndTween = function()
			local panel = UIMgr.GetPrePanel()

			if panel.className == "PageRoleCard" and self.page then
				if UIMgr.PreviewActor then
					local data

					if self.page.parentPanel and self.page.parentPanel.IsChangeRole then
						CardSwitchMgr:ResetCardIdsByRole(self.infoRole.id)

						data = {
							cardId = self.infoRoleCard.id
						}
						self.page.parentPanel.IsChangeRole = false
					end

					UIMgr.PreviewActor.parentPanel:OnBack(data)
				elseif self.page and self.page.parentPanel then
					self.page.parentPanel:OnBack()
				end
			else
				CardSwitchMgr:ResetCardIdsByRole(self.infoRoleCard.data.CharacterID)
				require("UI/Page/PageRoleCard/Page/PageRoleCard")
				UIMgr.SwitchPanel(PageRoleCard, {
					cardId = self.infoRoleCard.id
				})
			end
		end
	end
end
