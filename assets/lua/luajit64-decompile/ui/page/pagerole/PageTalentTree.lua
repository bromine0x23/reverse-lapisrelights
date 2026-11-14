-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRole/PageTalentTree.lua

require("UI/Page/PageRole/CellTalent")
require("UI/Page/PageRole/CellTalentIndex")
require("UI/Page/PageRole/DlgTalentActive")

PageTalentTree = class("PageTalentTree", UIPanel)

function PageTalentTree:ctor()
	self.UIPrefabPath = "UI/PanelTalent/PanelTalentTree"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_RoleTalent"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo(), {
		x = -700,
		y = -42
	})

	self.DlgTalentActive = DlgTalentActive()

	self:AddChildPanel(self.DlgTalentActive)
end

function PageTalentTree:PreLoad()
	self:LoadResAsync("UI/PanelTalent/CellTalent1", "PrefabCellTalent1", GameObject)
	self:LoadResAsync("UI/PanelTalent/CellTalent2", "PrefabCellTalent2", GameObject)
	self:LoadResAsync("UI/PanelTalent/CellTalent3", "PrefabCellTalent3", GameObject)
	self:LoadResAsync("UI/PanelTalent/Path1", "PrefabPath1", GameObject)
	self:LoadResAsync("UI/PanelTalent/Path2", "PrefabPath2", GameObject)
	self:LoadResAsync("UI/PanelTalent/CellIndex", "PrefabCellIndex", GameObject)
end

function PageTalentTree:OnBack()
	UIMgr.PopPanel()
end

function PageTalentTree:Purge()
	self.base.Purge(self)
	TimerMgr.RemoveTimer(self.timer)
	UITweenUtil.RemoveTween(self.rtContent)
	self:OnLeave()
end

function PageTalentTree:OnLeave()
	ResourceMgr.Unload(self.PrefabCellTalent1)
	ResourceMgr.Unload(self.PrefabCellTalent2)
	ResourceMgr.Unload(self.PrefabCellTalent3)
	ResourceMgr.Unload(self.PrefabPath1)
	ResourceMgr.Unload(self.PrefabPath2)
	ResourceMgr.Unload(self.PrefabCellIndex)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.dictCellTalent then
		for _, v in pairs(self.dictCellTalent) do
			self:RemoveClick(v.UIRootObject, self.OnCellClick)
			v:OnLeave()
		end

		self.dictCellTalent = nil
	end
end

function PageTalentTree:OnRegisterEvent()
	self:AddClick(self.BtnLeft, self.OnClickedBtnRoleL)
	self:AddClick(self.BtnRight, self.OnClickedBtnCardR)
	Event.Instance:Add("UpdateTreeAfterDevelop", self.UpdateTreeAfterDevelop, self)
	Event.Instance:Add(EventEnum.UpdateItemDataNotify, self.UpdateDot, self)
	Event.Instance:Add("UpdateShowCharacter", self.UpdateRole, self)
	Event.Instance:Add("TalentTreeCellNeedAnimation", self.ShowEnableAnim, self)
	Event.Instance:Add("TalentTreeCellCloseAnimation", self.CloseEnableAnim, self)
	Event.Instance:Add("SignContentPos", self.SignContentPos, self)
end

function PageTalentTree:OnUnRegisterEvent()
	self:RemoveClick(self.BtnLeft, self.OnClickedBtnRoleL)
	self:RemoveClick(self.BtnRight, self.OnClickedBtnCardR)
	Event.Instance:Remove("UpdateTreeAfterDevelop", self.UpdateTreeAfterDevelop, self)
	Event.Instance:Remove(EventEnum.UpdateItemDataNotify, self.UpdateDot, self)
	Event.Instance:Remove("UpdateShowCharacter", self.UpdateRole, self)
	Event.Instance:Remove("TalentTreeCellNeedAnimation", self.ShowEnableAnim, self)
	Event.Instance:Remove("TalentTreeCellCloseAnimation", self.CloseEnableAnim, self)
	Event.Instance:Remove("SignContentPos", self.SignContentPos, self)
end

function PageTalentTree:OnEnter(vParam)
	PersistentStoreUtil.SetBool("TalentDot", false)

	if not GuideMgr:IsGuided(GuideFunctionType.TalentTree) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.TalentTree)
	end

	self:DealWithLocalization()
	self.DlgTalentActive.UIRootObject:SetActive(false)

	self.ImgRoleIcon = self:GetChildComponent("Panel/Tree/Attr/Role/Icon", "Image")
	self.TxtRoleName = self:GetChildComponent("Panel/Tree/Attr/Role/Text", "Text")

	for i = 1, 4 do
		self["TxtAttr" .. i] = self:GetChildComponent("Panel/Tree/Attr/" .. i .. "/Text", "Text")
	end

	self.GoStarRate = self:GetChildGameObject("Panel/Tree/StarRate")
	self.TxtStarRate = self:GetChildComponent("Panel/Tree/StarRate/Text", "Text")
	self.Content = self:GetChildGameObject("Panel/Tree/Scroll/ScrollArea/Content")
	self.rtContent = self:GetChildComponent("Panel/Tree/Scroll/ScrollArea/Content", "RectTransform")
	self.scrollRect = self:GetChildComponent("Panel/Tree/Scroll/ScrollArea", "ScrollRect")
	self.BtnLeft = self:GetChildGameObject("Panel/Tree/Arrow/Btnleft")
	self.BtnRight = self:GetChildGameObject("Panel/Tree/Arrow/Btnright")
	self.EnableEffect = self:GetChildGameObject("EnableRTCamera/effect_enable")

	self:InitData(vParam)
	UITweenUtil.SetGroupAlpha(self.rtContent, 0)

	self.timer = TimerMgr.AddTimer(eTimerType.RealTime, 0.2, function()
		UITweenUtil.GroupAlphaAnim(self.rtContent, 0.2)
	end, nil)
end

function PageTalentTree:DealWithLocalization()
	local Text = self:GetChildComponent("Panel/Tree/Attr/Image1/Text", "Text")

	Text.text = _("Desc_TotalAttrAdd")
end

function PageTalentTree:InitData(data)
	local listRole = {}
	local infoRole

	if data and data.roleId then
		infoRole = RoleMgr:GetRole(data.roleId)

		CharacterThinMgr.DoResetOperate(CharacterThinMgr.ResetType.SKIP, data.roleId)
	else
		local lastRoleId = CharacterThinMgr.LastData(THIN_SYSTEM_TYPE.Role).id

		infoRole = RoleMgr:GetRole(lastRoleId)
	end

	listRole = CharacterThinMgr.SwitchData(THIN_SYSTEM_TYPE.Role).roles

	self:UpdateRole(infoRole)
	self.BtnLeft:SetActive(#listRole > 1)
	self.BtnRight:SetActive(#listRole > 1)
end

function PageTalentTree:UpdateRole(infoRole)
	if not infoRole and not infoRole.hold then
		return
	end

	self.infoRole = infoRole
	self.listAllSkill = SkillManager:GetTreesByRoleId(self.infoRole.id)
	self.talentRate = self:GetRoleTalentRate()
	self.curTreeIdx = self.talentRate.treeIdx

	self:UpdateTreeTag()
	self:UpdateSkillTree()
	self:SetContentPos()

	self.TxtRoleName.text = self.infoRole:GetName()

	UIUtil.SetImageSprite(self.ImgRoleIcon, self.infoRole.actorData.ThemeIcon, self)
end

function PageTalentTree:GetRoleTalentRate()
	local listNode = {}

	if self.infoRole.pb.skillNodes then
		for _, v in ipairs(self.infoRole.pb.skillNodes) do
			local node = SkillManager:GetNode(v.id)

			if node.data.RewardType == eSkillNodeType.attri or node.data.RewardType == eSkillNodeType.skill then
				table.insert(listNode, node)
			end
		end
	end

	local finalNodeId = 0

	if next(listNode) then
		table.sort(listNode, function(a, b)
			return a.id < b.id
		end)

		finalNodeId = listNode[#listNode].id
	end

	local function func(nodeId)
		local temp = {}

		for k, v in ipairs(self.listAllSkill) do
			for i, j in ipairs(v.data.Trunk) do
				if nodeId == j then
					temp.treeIdx = k
					temp.nodeIdx = i
					temp.isFinalTree = k == table.getn(self.listAllSkill)
					temp.isFinalNode = i == table.getn(v.data.Trunk)

					break
				end
			end
		end

		return temp
	end

	local temp = {
		nodeIdx = 1,
		treeIdx = 1
	}

	if finalNodeId ~= 0 then
		local nodePos = func(finalNodeId)

		if next(nodePos) then
			if nodePos.isFinalTree or not nodePos.isFinalNode then
				temp.treeIdx = nodePos.treeIdx
				temp.nodeIdx = nodePos.nodeIdx

				if not nodePos.isFinalNode then
					temp.nodeIdx = nodePos.nodeIdx + 1
				end
			else
				local t = SkillManager.NextTreeIsUnlock(nodePos.treeIdx, self.infoRole.id)

				if t.starFull then
					temp.treeIdx = nodePos.treeIdx + 1
					temp.nodeIdx = 1
				else
					temp.treeIdx = nodePos.treeIdx
					temp.nodeIdx = nodePos.nodeIdx
				end
			end
		end
	end

	return temp
end

function PageTalentTree:UpdateTreeTag()
	if self.UIScrollTool then
		self.UIScrollTool:UpdateListData(self.listAllSkill)

		return
	end

	local scrollArea = self:GetChildGameObject("Panel/Tag/ScrollArea")
	local content = self:GetChildComponent("Panel/Tag/ScrollArea/Content", "RectTransform")
	local count = #self.listAllSkill

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCellIndex)
	end

	local function updateCallback(item, index)
		item:UpdateData(self.curTreeIdx, self.infoRole)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellIndex, CellTalentIndex, self, false, addCallback, updateCallback)

	self.UIScrollTool.ScrollView.vertical = false
end

function PageTalentTree:OnClickedCellIndex(data)
	UITweenUtil.SetGroupAlpha(self.rtContent, 1)

	local go = data.pointerPressRaycast.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index

	if self.curTreeIdx == index then
		return
	end

	if index > 1 then
		local data = SkillManager.NextTreeIsUnlock(index - 1, self.infoRole.id)

		if not data.starFull then
			UIMgr.ShowMsg(_("Msg_Star_Less_Order_Last"))

			return
		end

		if not data.actFull then
			UIMgr.ShowMsg(_("Msg_Node_Inactivated_Order_Last"))

			return
		end
	end

	local preIdx = self.curTreeIdx

	self.curTreeIdx = index

	self.UIScrollTool:UpdateCellSelect(preIdx, index)
	self:UpdateSkillTree()
	self:SetContentPos()
end

function PageTalentTree:UpdateSkillTree()
	GOUtil.DestroyAllChildren(self.Content)

	if self.dictCellTalent then
		for _, v in pairs(self.dictCellTalent) do
			self:RemoveClick(v.UIRootObject, self.OnCellClick)
			v:OnLeave()
		end
	end

	self.listNode = {}
	self.dictCellTalent = {}
	self.branchPath2Gray = {}

	local sw = 320
	local sx = 60

	self.sw = sw
	self.sx = sx

	local skillTree = self.listAllSkill[self.curTreeIdx]

	if not skillTree then
		return
	end

	local n = #skillTree.tlistMain

	GOUtil.SetRectTransformSizeDelta(self.Content, sx + sw * (n - 1) + 250 + 60, self.rtContent.sizeDelta.y)

	for i = 1, n - 1 do
		local g = GOUtil.InstantiateUIPrefab(self.PrefabPath1, self.Content)

		GOUtil.SetRectTransformAnchoredPosition(g, sx + sw * (i - 1) + 165, 0)
	end

	for i = 1, #skillTree.tlistBranch do
		local td = skillTree.tlistBranch[i]
		local pos = table.getIndex(skillTree.tlistMainIds, td.parentId) - 1
		local g = GOUtil.InstantiateUIPrefab(self.PrefabPath2, self.Content)
		local gOne = GOUtil.FindChildGameObject(g, "One")
		local gTwo = GOUtil.FindChildGameObject(g, "Two")
		local sx = sx + sw * pos + 105 + 160
		local psy = td.dir == eDirType.Up and 1 or -1

		g.transform.localScale = Vector3.New(1, psy, 1)

		GOUtil.SetRectTransformAnchoredPosition(g, sx, 0)
		gOne:SetActive(#td.list == 1)
		gTwo:SetActive(#td.list == 2)

		local imgGray = GOUtil.FindChildComponent(g, "Image2", "Image")

		table.insert(self.branchPath2Gray, imgGray)
	end

	for i = 1, n do
		local node = skillTree.tlistMain[i]

		self:CreateCellSkill(self.Content, node, sx + sw * (i - 1), 0, i)
	end

	for i = 1, #skillTree.tlistBranch do
		local td = skillTree.tlistBranch[i]
		local pos = table.getIndex(skillTree.tlistMainIds, td.parentId) - 1
		local sx = sx + sw * pos + 105 + 160
		local py

		py = td.dir == eDirType.Up and 232 or -232

		for j = 1, #td.list do
			local node = td.list[j]

			if #td.list == 1 then
				self:CreateCellSkill(self.Content, node, sx - 72, py, i)
			else
				local val = TenaryOp(j % 2 == 0, 1, -1)

				self:CreateCellSkill(self.Content, node, sx + 89 * val - 72, py, i)
			end
		end
	end

	self:UpdateAttrAndStar()
end

function PageTalentTree:UpdateAttrAndStar()
	for i = 1, 4 do
		self["TxtAttr" .. i].text = "+" .. Mathf.Round(self:GetAtt(self.curTreeIdx)[i])
	end

	self.GoStarRate:SetActive(self.curTreeIdx < #self.listAllSkill)

	if self.curTreeIdx < #self.listAllSkill then
		local data = SkillManager.NextTreeIsUnlock(self.curTreeIdx, self.infoRole.id)

		self.TxtStarRate.text = Localization("Desc_Unlock_Order_Next") .. "<color=#F166F5>" .. data.curStars .. "</color>/" .. data.maxStars
	end
end

function PageTalentTree:GetPos(idx)
	local cw = GOUtil.GetRectTransformSizeDeltaWidth(self.Content)
	local scroll = self:GetChildGameObject("Panel/Tree/Scroll")
	local sw = GOUtil.GetRectTransformSizeDeltaWidth(scroll) - 44
	local cx = 0
	local nx = self.sx + self.sw * (idx - 1)

	if nx > sw / 2 and cw - nx > sw / 2 then
		cx = 0 - (nx - sw / 2)
	elseif cw - nx <= sw / 2 then
		cx = 0 - (cw - sw)
	end

	return cx
end

function PageTalentTree:SetContentPos()
	self.scrollRect.enabled = false

	if next(self.talentRate) and self.curTreeIdx == self.talentRate.treeIdx then
		local nodeIdx = self.talentRate.nodeIdx

		GOUtil.SetRectTransformAnchoredPosition(self.Content, self:GetPos(nodeIdx), 0)
	end

	self.scrollRect.enabled = true
	self.talentRate = {}
end

function PageTalentTree:CreateCellSkill(gbp, node, x, y, index)
	node:UpdateData(self.infoRole)

	self.listNode[node.id] = node

	local prefab

	if node.data.RewardType == eSkillNodeType.attri then
		prefab = self.PrefabCellTalent1
	elseif node.data.RewardType == eSkillNodeType.item or node.data.RewardType == eSkillNodeType.avatar then
		prefab = self.PrefabCellTalent2
	elseif node.data.RewardType == eSkillNodeType.skill then
		prefab = self.PrefabCellTalent3
	end

	local item = CellTalent(prefab, gbp)

	item:Create()

	item.UIRootObject.name = node.id

	item:SetEffectActive()
	GOUtil.SetRectTransformAnchoredPosition(item.UIRootObject, x, y)
	self:AddClick(item.UIRootObject, self.OnCellClick)

	if (node.data.RewardType == eSkillNodeType.item or node.data.RewardType == eSkillNodeType.avatar) and self.branchPath2Gray[index] then
		local gray = TenaryOp(not node.unlock or not node.canAct, 1, 0)

		DealWithListRef(self, UIUtil.SetImageGray(self.branchPath2Gray[index], gray))

		if gray == 1 then
			SetImageSprite(self.branchPath2Gray[index], "UI/PanelTalent/AtlasTalentTree/BG_tree_line01b", self)
		else
			SetImageSprite(self.branchPath2Gray[index], "UI/PanelTalent/AtlasTalentTree/BG_skilltree_up_02", self)
		end
	end

	item:UpdateData(node)

	self.dictCellTalent[node.id] = item
end

function PageTalentTree:GetAtt(tagIdx)
	local listPbNode = self.infoRole.pb.skillNodes
	local listNode = self.listAllSkill[self.curTreeIdx].data.Trunk
	local temp = {}

	if listPbNode then
		for i = 1, #listPbNode do
			local node = SkillManager:GetNode(listPbNode[i].id)

			for _, n in pairs(listNode) do
				if node.id == n and not table.contains(temp, node.id) then
					table.insert(temp, node)
				end
			end
		end
	end

	local attr = {
		0,
		0,
		0,
		0
	}

	for _, node in pairs(temp) do
		if node.data.RewardType == eSkillNodeType.attri then
			local value = node.data.Attribute[node.level]
			local etype = node.data.AttributeType

			attr[etype] = attr[etype] + value
		end
	end

	return attr
end

function PageTalentTree:OnClickedBtnRoleL()
	self:OnNext(false)
end

function PageTalentTree:OnClickedBtnCardR()
	self:OnNext(true)
end

function PageTalentTree:OnNext(isR)
	CharacterThinMgr.SwitchRole(nil, isR)
end

function PageTalentTree:OnCellClick(data)
	local id = tonumber(data.pointerPress.name)
	local node = self.listNode[id]

	if not node.unlock then
		UIMgr.ShowMsg(SkillManager.GetUnlockInfo(node))

		return
	end

	if not node.canAct then
		UIMgr.ShowMsg(_("Desc_BeforeNodeNotOpen"))

		return
	end

	self.DlgTalentActive:Show(node, self.infoRole, self.curTreeIdx)
end

function PageTalentTree:OnClickedGuideBtn()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.TalentTree)
end

function PageTalentTree:UpdateTreeAfterDevelop()
	self:UpdateAttrAndStar()
	self:UpdateDot()
end

function PageTalentTree:UpdateDot()
	if self.dictCellTalent then
		for nodeId, cellTalent in pairs(self.dictCellTalent) do
			local node = self.listNode[nodeId]

			cellTalent:UpdateDynamicData(node)
		end
	end

	if self.UIScrollTool and self.UIScrollTool.ItemRoot2ItemDict then
		for _, v in self.UIScrollTool.ItemRoot2ItemDict:Enumerator() do
			if v.Item.UpdateDot ~= nil then
				v.Item:UpdateDot()
			end
		end
	end
end

function PageTalentTree:ShowEnableAnim(id)
	local cell = self.dictCellTalent[id]

	if cell ~= nil then
		cell:ShowAnimation()
		cell.EnableEffect:SetActive(true)
		self.EnableEffect:SetActive(true)
	end
end

function PageTalentTree:CloseEnableAnim()
	self.EnableEffect:SetActive(false)
end

function PageTalentTree:SignContentPos(idx)
	GOUtil.SetRectTransformAnchoredPosition(self.Content, self:GetPos(idx), 0)
end
