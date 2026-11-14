-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRole/CellTalent.lua

require("UI/Item/UIItemBase")

CellTalent = class("CellTalent", UIItemBase)

function CellTalent:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellTalent:Create(vParam)
	CellTalent.base.Create(self, vParam)
end

function CellTalent:OnEnter()
	local g = self.UIRootObject

	self.Icon = GOUtil.FindChildComponent(g, "Panel/Icon", "Image")
	self.Lock = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/Lock")
	self.Dot = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/Dot")
	self.Animator = self:GetChildComponent("", "Animator")
	self.EnableEffect = self:GetChildGameObject("Panel/EnableEffect")
	self.Effect = self:GetChildGameObject("Panel/Effect")

	if self.Animator ~= nil then
		EventListenerMgr.AddAnimListener(self.UIRootObject, self.CloseEffect, self, eAnimEventType.OnAnimationEnd)
	end
end

function CellTalent:OnLeave()
	if self.Animator ~= nil then
		EventListenerMgr.RemoveAnimListener(self.UIRootObject, self.CloseEffect, self, eAnimEventType.OnAnimationEnd)
	end

	UnloadAllImageSprite(self)
end

function CellTalent:UpdateData(node)
	if not node then
		return
	end

	if node.data.RewardType == eSkillNodeType.attri then
		SetImageSprite(self.Icon, "UI/PanelTalent/AtlasTalentTree/BG_icon_tree_0" .. node.data.AttributeType, self)
	elseif node.data.RewardType == eSkillNodeType.item or node.data.RewardType == eSkillNodeType.avatar then
		local rank1 = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Rank1", "Image")
		local rank2 = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Rank2", "Image")

		if node.data.RewardType == eSkillNodeType.item then
			local info = ItemManager:GetValueItem(node.data.Item[1], node.data.Item[2])

			ItemManager:SetItemInfo(info, self.Icon, rank1, rank2, self)
		else
			local infoAvatar = AvatarManager:GetAvatar(node.data.Avatar)

			SetImageSprite(self.Icon, infoAvatar.data.Icon, self)
			UIUtil.SetImageSprite(rank1, "UIDyAtlas/ItemRarity/BG_frame_item_04_b", self)
			UIUtil.SetImageSprite(rank2, "UIDyAtlas/ItemRarity/BG_frame_item_04_a", self)
		end
	elseif node.data.RewardType == eSkillNodeType.skill then
		local infoTalent = TalentManager:Get(node.data.Skill)

		UIUtil.SetImageSprite(self.Icon, "UIDyAtlas/Skill/" .. infoTalent.data.Icon, self)

		local txtLevel = GOUtil.FindChildComponent(self.UIRootObject, "Panel/TxtLevel", "Text")

		txtLevel.gameObject:SetActive(false)
	end

	self:UpdateDynamicData(node)
end

function CellTalent:UpdateDynamicData(node)
	local unlock = node.unlock
	local canAct = node.canAct
	local level = node.level

	self.Lock:SetActive(not unlock or not canAct)
	self.Dot:SetActive(SkillManager:GetPageTalentTreeAttriDot(node))

	if self.Effect ~= nil then
		self.Effect:SetActive(unlock and canAct)
	end

	local gray = TenaryOp(unlock and canAct, 0, 1)

	if node.data.RewardType == eSkillNodeType.attri then
		DealWithListRef(self, UIUtil.SetImageGray(self.Icon, gray))

		local goStar_ = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/Star_")

		goStar_:SetActive(false)

		local goStar = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/Star")

		goStar:SetActive(unlock and canAct)

		local txtAttr = GOUtil.FindChildComponent(self.UIRootObject, "Panel/UpAttr/Text", "Text")

		if unlock and canAct then
			for i = 0, node.maxLevel do
				local star = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/Star/Star" .. i)

				star:SetActive(level == i)
			end

			local addAttr = level ~= 0 and Mathf.Round(node:GetAttr()) or 0

			txtAttr.text = _("eAttType_" .. node.data.AttributeType) .. " <color=#01b34c>+" .. addAttr .. "</color>"
		else
			txtAttr.text = _("eAttType_" .. node.data.AttributeType) .. " +0"
		end
	elseif node.data.RewardType == eSkillNodeType.item or node.data.RewardType == eSkillNodeType.avatar then
		local txtGeted = GOUtil.FindChildComponent(self.UIRootObject, "Panel/TxtGeted", "Text")

		txtGeted.text = _("Desc_Has_Get")

		txtGeted.gameObject:SetActive(node.geted)

		if gray == 0 then
			gray = node.geted and 1 or 0
		end

		local rank1 = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Rank1", "Image")
		local rank2 = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Rank2", "Image")

		DealWithListRef(self, UIUtil.SetImageGray(self.Icon, gray))
		DealWithListRef(self, UIUtil.SetImageGray(rank1, gray))
		DealWithListRef(self, UIUtil.SetImageGray(rank2, gray))
	elseif node.data.RewardType == eSkillNodeType.skill then
		DealWithListRef(self, UIUtil.SetImageGray(self.Icon, gray))

		local imgFrame = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Frame", "Image")

		DealWithListRef(self, UIUtil.SetImageGray(imgFrame, gray))
	end
end

function CellTalent:ShowAnimation()
	if self.Animator ~= nil then
		self.Animator:Play("CellTalent1_enable", 0, 0)
	end
end

function CellTalent:CloseEffect()
	Event.Instance:Fire("TalentTreeCellCloseAnimation")
	self.EnableEffect:SetActive(false)
end

function CellTalent:SetEffectActive()
	if self.EnableEffect ~= nil then
		self.EnableEffect:SetActive(false)
	end
end
