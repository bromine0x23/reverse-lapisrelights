-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRole/DlgTalentActive.lua

DlgTalentActive = class("DlgTalentActive", UIPanel)

local ePanelType = {
	skill = 3,
	item = 2,
	attr = 1
}

local function GetPrefabType(node)
	if node.data.RewardType == eSkillNodeType.attri then
		return ePanelType.attr
	elseif node.data.RewardType == eSkillNodeType.item or node.data.RewardType == eSkillNodeType.avatar then
		return ePanelType.item
	elseif node.data.RewardType == eSkillNodeType.skill then
		return ePanelType.skill
	end

	return ePanelType.attr
end

function DlgTalentActive:ctor()
	self.UIPrefabPath = "UI/PanelTalent/DlgTalentActive"
end

function DlgTalentActive:Purge()
	self.base.Purge(self)
	EffectMgr:UnLoadEffect("Fx/UI/FX_UI_007/FX_UI_007")
	InfoSoundEventMgr:OnBack()
end

function DlgTalentActive:OnRegisterEvent()
	self:AddClick(self.BtnActive, self.OnClickedBtnActive)
	self:AddClick(self.BtnClose, self.OnClickedBtnClose)
	self:AddClick(self.BtnAddGem, self.OnClickedBtnAddGem)
	self:AddClick(self.BtnL, self.OnClickedBtnL)
	self:AddClick(self.BtnR, self.OnClickedBtnR)
	Event.Instance:Add(EventEnum.UpdateItemDataNotify, self.UpdateItemDataNotify, self)
	Event.Instance:Add("UpdateNetData", self.UpdateNetData, self)
end

function DlgTalentActive:OnUnRegisterEvent()
	self:RemoveClick(self.BtnActive, self.OnClickedBtnActive)
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
	self:RemoveClick(self.BtnAddGem, self.OnClickedBtnAddGem)
	self:RemoveClick(self.BtnL, self.OnClickedBtnL)
	self:RemoveClick(self.BtnR, self.OnClickedBtnR)
	Event.Instance:Remove(EventEnum.UpdateItemDataNotify, self.UpdateItemDataNotify, self)
	Event.Instance:Remove("UpdateNetData", self.UpdateNetData, self)
end

function DlgTalentActive:OnEnter(vParam)
	self:DealWithLocalization()

	for i = 1, table.getCount(ePanelType) do
		self["GoTalent" .. i] = self:GetChildGameObject("Panel/BgNode/" .. i)
	end

	self.GoCost = self:GetChildGameObject("Panel/BgInfo/Cost")

	for i = 1, 2 do
		self["CostItem" .. i] = self:GetChildGameObject("Panel/BgInfo/Cost/Item/" .. i)
		self["ItemIcon" .. i] = self:GetChildComponent("Panel/BgInfo/Cost/Item/" .. i .. "/Icon", "Image")
		self["CostValue" .. i] = self:GetChildComponent("Panel/BgInfo/Cost/Item/" .. i .. "/Text", "Text")
	end

	self.BtnAddGem = self:GetChildGameObject("Panel/BgInfo/Cost/Item/2/Image")
	self.TxtTalentName = self:GetChildComponent("Panel/BgInfo/Title/Text", "Text")
	self.TxtTalentInfo = self:GetChildComponent("Panel/BgInfo/Info/Text", "Text")
	self.GoAttr = self:GetChildGameObject("Panel/BgInfo/Info/Attr")
	self.TxtPre = self:GetChildComponent("Panel/BgInfo/Info/Attr/TxtPre", "Text")
	self.TxtCur = self:GetChildComponent("Panel/BgInfo/Info/Attr/TxtCur", "Text")
	self.TxtFinalAttr = self:GetChildComponent("Panel/BgInfo/Info/TxtFinalAtt", "Text")
	self.TxtFull = self:GetChildComponent("Panel/BgInfo/TxtFull", "Text")
	self.TxtPrompt = self:GetChildComponent("Panel/BgInfo/TxtPrompt", "Text")
	self.GoTip = self:GetChildGameObject("Panel/BgInfo/Info/Tip")
	self.TxtTip = GOUtil.FindChildComponent(self.GoTip, "Text", "Text")
	self.AnimatorTip = self:GetChildComponent("Panel/BgInfo/Info/Tip", "Animator")
	self.GoActive = self:GetChildGameObject("Active")
	self.ActiveAnim = GOUtil.GetComponent(self.GoActive, "Animator")
	self.BtnL = self:GetChildGameObject("Panel/BtnL")
	self.BtnR = self:GetChildGameObject("Panel/BtnR")
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")
	self.BtnActive = self:GetChildGameObject("Panel/BgInfo/Button")
	self.TxtBtn = GOUtil.FindChildComponent(self.BtnActive, "Text", "Text")
	self.TxtTitle = self:GetChildComponent("Panel/Title/Text", "Text")
end

function DlgTalentActive:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/BgInfo/Cost/Text", "Text")
	txt.text = Lang(12044)
end

function DlgTalentActive:Show(node, infoRole, treeIdx)
	self.UIRootObject:SetActive(true)

	if not infoRole then
		return
	end

	self.infoRole = infoRole
	self.trees = SkillManager:GetTreesByRoleId(infoRole.id)

	if not self.trees[treeIdx] then
		return
	end

	self.treeIdx = treeIdx
	self.tree = self.trees[treeIdx]
	self.node = node
	self.canSwitch = false

	if self.node and (self.node.data.RewardType == eSkillNodeType.attri or self.node.data.RewardType == eSkillNodeType.skill) then
		self.canSwitch = true
	end

	self.nodeIdx = 1

	if self.tree.tlistMain then
		for k, v in ipairs(self.tree.tlistMain) do
			if node.id == v.id then
				self.nodeIdx = k

				break
			end
		end
	end

	self:UpdatePanel()

	self.isNextLock = self:CheckNext()
	self.needAnim = false
end

function DlgTalentActive:Hide()
	self.UIRootObject:SetActive(false)
end

function DlgTalentActive:OnClickedBtnL()
	self:OnNext(false)
end

function DlgTalentActive:OnClickedBtnR()
	self:OnNext(true)
end

function DlgTalentActive:OnNext(isR)
	local nodeIdx = self.nodeIdx

	if isR then
		nodeIdx = nodeIdx + 1 > #self.tree.tlistMain and nodeIdx or nodeIdx + 1
	else
		nodeIdx = nodeIdx - 1 < 1 and nodeIdx or nodeIdx - 1
	end

	local node = self.tree.tlistMain[nodeIdx]

	if not node.unlock then
		UIMgr.ShowMsg(SkillManager.GetUnlockInfo(node))

		return
	end

	if not node.canAct then
		UIMgr.ShowMsg(_("Desc_BeforeNodeNotOpen"))

		return
	end

	self.nodeIdx = nodeIdx
	self.node = self.tree.tlistMain[nodeIdx]
	self.needSwitch = true

	self:UpdatePanel()

	self.isNextLock = self:CheckNext()
end

function DlgTalentActive:CheckNext()
	local nodeIdx = self.nodeIdx

	nodeIdx = nodeIdx + 1 > #self.tree.tlistMain and nodeIdx or nodeIdx + 1

	local node = self.tree.tlistMain[nodeIdx]

	if not node.unlock then
		return false
	end

	if not node.canAct then
		return false
	end

	return true
end

function DlgTalentActive:UpdatePanel()
	self.BtnL:SetActive(self.canSwitch and next(self.tree.tlistMain) ~= nil and self.nodeIdx > 1)
	self.BtnR:SetActive(self.canSwitch and next(self.tree.tlistMain) ~= nil and self.nodeIdx < #self.tree.tlistMain)

	if not self.node then
		return
	end

	self:UpdateTalent()
	self:RefreshTalentInfo()
end

function DlgTalentActive:UpdateTalent()
	local node = self.node
	local _type = GetPrefabType(node)
	local level = node.level or 0

	for i = 1, table.getCount(ePanelType) do
		self["GoTalent" .. i]:SetActive(i == _type)
	end

	local go = self["GoTalent" .. _type]
	local icon = GOUtil.FindChildComponent(go, "Icon", "Image")

	self.GoAttr:SetActive(_type == ePanelType.attr and level < node.maxLevel)
	self.GoTip:SetActive(_type == ePanelType.attr and level < node.maxLevel)
	self.TxtFinalAttr.gameObject:SetActive(_type == ePanelType.attr and level == node.maxLevel)
	self.TxtTalentInfo.gameObject:SetActive(_type ~= ePanelType.attr)

	if _type == ePanelType.attr then
		self.TxtTitle.text = _("TalentActive_Title")

		UIUtil.SetImageSprite(icon, "UI/PanelTalent/AtlasTalentTree/BG_icon_tree_0" .. node.data.AttributeType, self)

		for i = 1, node.maxLevel do
			GOUtil.FindChildGameObject(go, "Star/Star" .. i):SetActive(i <= level)
		end

		if node.geted then
			if level < node.maxLevel then
				local value1 = node.data.UpgradeChance[node.level][1]
				local value2 = node.data.UpgradeChance[node.level][2]

				self.TxtTip.text = string.gsub(_("Desc_SuccessProbability"), "{str}", value1 + value2 * node.failTimes)
				self.TxtPre.text = _("Desc_CurrentAdd") .. Mathf.Round(node:GetAttr())
				self.TxtCur.text = string.gsub(_("Desc_NextAdd"), "{count}", Mathf.Round(node.data.Attribute[level + 1]) or 0)
			else
				self.GoAttr:SetActive(false)
				self.GoTip:SetActive(false)
				self.TxtFinalAttr.gameObject:SetActive(true)

				self.TxtFinalAttr.text = _("Desc_CurrentAdd") .. Mathf.Round(node:GetAttr())
			end
		else
			self.TxtTip.text = string.gsub(_("Desc_SuccessProbability"), "{str}", 100)
			self.TxtPre.text = _("Desc_CurrentAdd") .. Mathf.Round(node:GetAttr())
			self.TxtCur.text = string.gsub(_("Desc_NextAdd"), "{count}", Mathf.Round(node.data.Attribute[level + 1]) or 0)
		end
	elseif _type == ePanelType.item then
		self.TxtTitle.text = _("Desc_Award_Unlock")

		local rank1 = GOUtil.FindChildComponent(go, "Rank1", "Image")
		local rank2 = GOUtil.FindChildComponent(go, "Rank2", "Image")
		local txtValue = GOUtil.FindChildComponent(go, "Text", "Text")

		if node.data.RewardType == eSkillNodeType.item then
			local item = node.data.Item
			local info = ItemManager:GetValueItem(item[1], item[2])

			ItemManager:SetItemInfo(info, icon, rank1, rank2)

			txtValue.text = item[2]
		else
			local infoAvatar = AvatarManager:GetAvatar(node.data.Avatar)

			UIUtil.SetImageSprite(icon, infoAvatar.data.Icon, self)
			UIUtil.SetImageSprite(rank1, "UIDyAtlas/ItemRarity/BG_frame_item_04_b", self)
			UIUtil.SetImageSprite(rank2, "UIDyAtlas/ItemRarity/BG_frame_item_04_a", self)

			txtValue.text = 1
		end
	elseif _type == ePanelType.skill then
		self.TxtTitle.text = _("Desc_TalentActive")

		local infoTalent = TalentManager:Get(node.data.Skill)

		UIUtil.SetImageSprite(icon, "UIDyAtlas/Skill/" .. infoTalent.data.Icon, self)

		local txtLevel = GOUtil.FindChildComponent(go, "TxtLevel", "Text")

		txtLevel.text = "Lv." .. node.level
	end
end

function DlgTalentActive:RefreshTalentInfo()
	local node = self.node

	self.GoCost:SetActive(true)
	self.BtnActive:SetActive(true)
	self.TxtFull.gameObject:SetActive(false)
	self.TxtPrompt.gameObject:SetActive(false)

	if node.geted then
		if node.data.RewardType == eSkillNodeType.attri then
			if node.perfect then
				self.GoCost:SetActive(false)
				self.BtnActive:SetActive(false)
				self.TxtFull.gameObject:SetActive(true)

				self.TxtFull.text = _("PageTalentTree_Perfect")
			end
		else
			self.GoCost:SetActive(false)
			self.BtnActive:SetActive(false)
			self.TxtFull.gameObject:SetActive(true)

			self.TxtFull.text = Lang(18223)
		end
	end

	self.TxtTalentName.text = node:GetName()
	self.TxtTalentInfo.text = node:GetDesc()

	if node.data.RewardType == eSkillNodeType.attri then
		self.TxtPrompt.gameObject:SetActive(node.level ~= 0 and node.level < node.maxLevel)

		if node.level == 0 then
			self.TxtBtn.text = _("PageTalentTree_Active")
			self.TxtPrompt.text = "※" .. _("PageTalentTree_NotActive")
		elseif node.level == 1 or node.level == 2 then
			self.TxtBtn.text = _("PageTalentTree_Surmount")
			self.TxtPrompt.text = "※" .. _("PageTalentTree_SurPrompt")
		elseif node.level == 3 then
			self.TxtBtn.text = _("PageTalentTree_Ultimate")
			self.TxtPrompt.text = "※" .. _("PageTalentTree_UltPrompt")
		end
	elseif node.data.RewardType == eSkillNodeType.item or node.data.RewardType == eSkillNodeType.avatar or node.data.RewardType == eSkillNodeType.skill then
		self.TxtBtn.text = _("Btn_Unlock")

		if node.data.RewardType == eSkillNodeType.skill then
			local skillTip = require("UI/Dlg/Common/SkillTipDesc")
			local level = SkillManager:GetTalentLevelByTreeIdx(self.infoRole.id, self.treeIdx, node.data.Skill)

			self.TxtTalentInfo.text = skillTip.GetDesc(node.data.Skill, level, 0)
		end
	end

	local listInfoItem = node.data.CostGem

	if not listInfoItem or #listInfoItem == 0 then
		self.GoCost:SetActive(false)

		return
	end

	for i = 1, 2 do
		self["CostItem" .. i]:SetActive(i <= #listInfoItem)

		if i <= #listInfoItem then
			local itemId = listInfoItem[i][1]
			local itemCost = listInfoItem[i][2]
			local infoItemNeed = ItemManager:Get(itemId)

			UIUtil.SetImageSprite(self["ItemIcon" .. i], infoItemNeed:GetIcon(), self)

			self["CostValue" .. i].text = infoItemNeed:GetCurResNum() .. "/<color=#ECCD21>" .. itemCost .. "</color>"

			if itemCost > infoItemNeed:GetCurResNum() then
				self.BtnAddGem:SetActive(true)
			end
		end
	end
end

function DlgTalentActive:OnClickedBtnActive()
	if not self.node.canAct then
		UIMgr.ShowMsg(_("Desc_BeforeNodeNotOpen"))

		return
	end

	local listCost = self.node.data.CostGem

	for i = 1, #listCost do
		local id = listCost[i][1]
		local needNum = listCost[i][2]
		local infoItem = ItemManager:Get(id)
		local holdNum = infoItem:GetCurResNum()

		if holdNum < needNum then
			UIMgr.ShowItemTip(ItemManager:Get(id), 2, true, true)

			return
		end
	end

	local function wrap_cb(vMsg)
		self:ResponseTalentNode(vMsg)
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestTalentNode(self.infoRole.id, self.node.id, wrap_cb)
end

function DlgTalentActive:ResponseTalentNode(msg)
	local preLevel = self.node.level

	LoadingMgr.Hide(eLoadingType.Repeat)

	if msg.result.code == NetManager.Result_Sucess then
		SkillManager:UpdateTreeNodeData(self.tree.id, self.infoRole.id)

		if msg.node.id == self.tree.tlistMain[#self.tree.tlistMain].id then
			local curTeerData = SkillManager.NextTreeIsUnlock(self.treeIdx, self.infoRole.id)

			if curTeerData.starFull and curTeerData.actFull then
				SkillManager:UpdateTreeNodeData(self.trees[self.treeIdx + 1].id, self.infoRole.id)
			end
		end

		if self.node.data.RewardType == eSkillNodeType.attri then
			self.AnimatorTip:Play("Tip_Anim")
			self:PlayAnim(msg.node.level, preLevel)
		end

		if self.node.data.RewardType == eSkillNodeType.skill then
			UIMgr.ShowMsg(_("DlgGetItem_UnLockSkill"))
		elseif self.node.data.RewardType == eSkillNodeType.avatar then
			UIMgr.ShowMsg(_("DlgGetItem_UnLockAvatar"))
		end

		InfoSoundEventMgr:LoadBank(self.infoRole.data.VocalBank)

		if msg.node.failTimes == 0 then
			InfoSoundEventMgr:Play("VocalCommon2", self.infoRole.data.VocalCommon2)
			EffectMgr:Alloc("Fx/UI/FX_UI_007/FX_UI_007", self:GetChildGameObject("Panel/BgNode/1/Star/Image" .. msg.node.level), true, 1)
		else
			InfoSoundEventMgr:Play("VocalCommon1", self.infoRole.data.VocalCommon1)
		end

		self:UpdatePanel()
		Event.Instance:Fire("UpdateTreeAfterDevelop")

		if self.isNextLock ~= self:CheckNext() then
			self.needAnim = true
		else
			self.needAnim = false
		end
	else
		UIMgr.ShowMsg(msg.result.desc, msg)
	end
end

function DlgTalentActive:PlayAnim(curLevel, preLevel)
	local node = self.node
	local text = GOUtil.FindChildComponent(self.GoActive, "Text", "Text")

	text.text = _("Filter_Talent")

	local text1 = GOUtil.FindChildComponent(self.GoActive, "Text1", "Text")

	if node.data.RewardType == eSkillNodeType.attri then
		if curLevel ~= preLevel then
			if curLevel == 1 then
				text1.text = node:GetName() .. "<color=green>" .. _("PageTalentTree_Active") .. _("Desc_Success") .. "</color>"
			else
				text1.text = node:GetName() .. "<color=green>" .. _("PageTalentTree_Surmount") .. _("Desc_Success") .. "</color>"
			end
		elseif curLevel == 0 then
			text1.text = node:GetName() .. "<color=green>" .. _("PageTalentTree_Active") .. _("Desc_Failure") .. "</color>"
		else
			text1.text = node:GetName() .. "<color=red>" .. _("PageTalentTree_Surmount") .. _("Desc_Failure") .. "</color>"
		end
	elseif node.data.RewardType == eSkillNodeType.item or node.data.RewardType == eSkillNodeType.avatar then
		return
	elseif node.data.RewardType == eSkillNodeType.skill then
		text1.text = node:GetName() .. "<color=green>" .. _("PageTalentTree_Ultimate") .. "</color>" .. _("Desc_Success")
	end

	self.ActiveAnim:Play("ActiveResultOpen")
end

function DlgTalentActive:OnClickedBtnAddGem()
	local listCost = self.node.data.CostGem
	local id = listCost[2][1]
	local needNum = listCost[2][2]
	local infoItem = ItemManager:Get(id)
	local holdNum = infoItem:GetCurResNum()

	if holdNum < needNum then
		UIMgr.ShowItemTip(ItemManager:Get(id), 2, true, true)

		return
	end
end

function DlgTalentActive:OnClickedBtnClose()
	for i = 1, 4 do
		GOUtil.DestroyAllChildren(self:GetChildGameObject("Panel/BgNode/1/Star/Image" .. i))
	end

	self.UIRootObject:SetActive(false)

	if self.needAnim == true then
		local nodeIdx = self.nodeIdx

		nodeIdx = nodeIdx + 1 > #self.tree.tlistMain and nodeIdx or nodeIdx + 1

		if nodeIdx == self.nodeIdx then
			return
		end

		local node = self.tree.tlistMain[nodeIdx]

		Event.Instance:Fire("TalentTreeCellNeedAnimation", node.id)
	end

	if self.canSwitch and self.needSwitch then
		Event.Instance:Fire("SignContentPos", self.nodeIdx)
	end
end

function DlgTalentActive:UpdateItemDataNotify()
	if self.UIRootObject.activeSelf then
		self:UpdatePanel()
	end
end

function DlgTalentActive:UpdateDot()
	local hasDot = true

	for _, v in ipairs(self.node.data.CostGem) do
		local holdNum = ItemManager:GetItemCount(v[1] or 501)
		local costNum = v[2] or 0

		if holdNum < costNum then
			hasDot = false
		end
	end

	self.GoDot:SetActive(hasDot)
end

function DlgTalentActive:UpdateNetData()
	if self.UIRootObject.activeSelf then
		self:UpdatePanel()
		Event.Instance:Fire("UpdateTreeAfterDevelop")
	end
end
