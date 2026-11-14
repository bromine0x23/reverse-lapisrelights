-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellCardAward.lua

require("UI/Item/UIItemBase")

CellCardAward = class("CellCardAward", UIItemBase)

function CellCardAward:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellCardAward:OnEnter()
	local g = self.UIRootObject
	local text = GOUtil.FindChildComponent(g, "BtnRecv/Text", "Text")

	text.text = _("Desc_Get")
	self.GoCard = GOUtil.FindChildGameObject(g, "Card")
	self.GoLimit = GOUtil.FindChildGameObject(g, "img_limit")
	self.CardBg = GOUtil.FindChildComponent(g, "Card/CardMask/Bg", "RawImage")
	self.CardIcon = GOUtil.FindChildComponent(g, "Card/CardMask/CardIcon", "RawImage")
	self.CardJob = GOUtil.FindChildComponent(g, "Card/Job", "Image")
	self.CardRank = GOUtil.FindChildComponent(g, "Card/CardRank", "Image")
	self.CardName = GOUtil.FindChildComponent(g, "Card/CardName", "Text")
	self.BtnLook = GOUtil.FindChildGameObject(g, "BtnLook")

	self:AddClick(self.BtnLook, self.OnClickedBtnLook)

	self.ImgBtnLook = GOUtil.GetComponent(self.BtnLook, "Image")
	self.BtnRecv = GOUtil.FindChildGameObject(g, "BtnRecv")

	self:AddClick(self.BtnRecv, self.OnClickedBtnRecv)

	self.ImgBtnRecv = GOUtil.GetComponent(self.BtnRecv, "Image")
	self.GoRecved = GOUtil.FindChildGameObject(g, "Recved")
end

function CellCardAward:OnLeave()
	self:RemoveClick(self.BtnLook, self.OnClickedBtnLook)
	self:RemoveClick(self.BtnRecv, self.OnClickedBtnRecv)

	if self.groupHandle then
		ResourceMgr.Cancel(self.groupHandle)
	end
end

function CellCardAward:UpdateData(data)
	self.data = data

	local cardId = data.award[1][2]
	local infoRoleCard = InfoRoleCard(cardId)
	local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)

	GOUtil.DestroyAllChildren(self.CardIcon.gameObject)

	if infoRoleCard.data.SpineData ~= "" then
		SetActiveFunc(self.CardBg.gameObject, false)

		self.CardIcon.enabled = false
		self.groupHandle = ResourceMgr.BeginSubmit(function(spineGo)
			if self.UIRootObject ~= nil then
				local cardSpine = self.spineObj

				if cardSpine then
					local spine = GOUtil.InstantiateUIPrefab(cardSpine, spineGo)

					if GOUtil.GetComponent(spine, "SpineAspectRatioFitter") then
						GOUtil.GetComponent(spine, "SpineAspectRatioFitter").enabled = false
					end
				end
			end
		end, self.CardIcon.gameObject)

		ResourceMgr.SubmitCache(infoRoleCard.data.SpineData .. "_Anim", self, "spineObj", GameObject)
		ResourceMgr.EndSubmit()
	else
		SetActiveFunc(self.CardBg.gameObject, true)

		self.CardIcon.enabled = true

		RoleCardMgr:SetInfoPanel(infoRoleCard, self.CardIcon, self.CardBg)
	end

	RoleCardMgr:SetCardLocation(infoRoleCard, self.CardIcon.gameObject, 3)

	if infoRoleCard.data.ID == 103202 then
		GOUtil.SetTransformLocalScale(self.CardIcon.gameObject, 0.34)
	end

	self.CardName.text = infoRoleCard:GetName()

	UIUtil.SetImageSprite(self.CardJob, "UIDyAtlas/RoleJob/ICO_" .. infoRole.data.Job .. "_01_S", self)
	UIUtil.SetImageSprite(self.CardRank, "UIDyAtlas/RoleCardRank/BG_card_back_" .. infoRoleCard.rank .. "_10")
	self:UpdateDynamicData(self.data.index)
end

function CellCardAward:UpdateDynamicData(index)
	local infoOperationActive = OperationActiveMgr:Get(eOperationActive.Card)
	local isGeted = infoOperationActive:IsGetIndexAward(index)
	local isCanGet = infoOperationActive:IsCanGet(index)

	SetActiveFunc(self.BtnRecv, not isGeted)
	SetActiveFunc(self.GoRecved, isGeted)
	SetActiveFunc(self.BtnLook, not isGeted)

	local cy, ry = 50, -7

	if isGeted then
		cy, ry = 0, -57
	else
		local gray = TenaryOp(isCanGet, 0, 1)

		UIUtil.SetImageGray(self.ImgBtnRecv, gray)
	end

	SetActiveFunc(self.GoLimit, index == 7)
end

function CellCardAward:OnClickedBtnLook()
	local popData = {
		tag = 4
	}
	local data = {
		onlyShow = true,
		cardId = self.data.award[1][2],
		popData = popData
	}

	UIMgr.SwitchPanel(PageRoleCard, data)
end

function CellCardAward:OnClickedBtnRecv(data)
	local infoOperationActive = OperationActiveMgr:Get(eOperationActive.Card)
	local isCanGet = infoOperationActive:IsCanGet(self.data.index)

	if not isGeted and not isCanGet then
		UIMgr.ShowMsg(_("Desc_Waiting"))

		return
	end

	Event.Instance:Fire("ReceiveOperationActiveAward", self.data.index)
end
