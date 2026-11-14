-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageBondage/CellCombinationSkill.lua

require("UI/Item/UIItemBase")

CellCombinationSkill = class("CellCombinationSkill", UIItemBase)

function CellCombinationSkill:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellCombinationSkill:Create(vParam)
	CellCombinationSkill.base.Create(self, vParam)
end

function CellCombinationSkill:OnEnter()
	local g = self.UIRootObject
	local txt = self:GetChildComponent("Skill/Lock/Text", "Text")

	txt.text = Lang(12040)
	self.ImgCombinationBg = GOUtil.GetComponent(g, "Image")

	local group = GOUtil.FindChildGameObject(g, "Group")

	self.ScrollView = GOUtil.AddMissingComponent(group, "UIScrollView")
	self.GoContent = GOUtil.FindChildGameObject(g, "Group/Content")
	self.GoSkill = GOUtil.FindChildGameObject(g, "Skill")
	self.GoSelect = GOUtil.FindChildGameObject(g, "Select")
end

function CellCombinationSkill:OnLeave()
	if self.ScrollView and self.listCell then
		for i = 1, #self.listCell do
			self:RemoveClick(self.listCell[i], self.OnClickedGoSkill)
		end
	end

	UnloadAllImageSprite(self)
end

function CellCombinationSkill:UpdateData(data)
	self.info = data.info

	local infoCombination = data.info
	local fightNum = data.battleNum

	UIUtil.SetImageSprite(self.ImgCombinationBg, "UI/PanelBondage/Team/AtlasTeam" .. infoCombination.id .. "/BG_fetter_team_0" .. infoCombination.id, self)

	self.listSkill = infoCombination.listSkill

	if #self.listSkill > 3 then
		self.ScrollView.horizontal = true
	end

	self.listCell = {}

	for i = 1, #self.listSkill do
		local go = GOUtil.Instantiate(self.GoSkill, self.GoContent)

		go.name = i

		local info = self.listSkill[i]

		if info ~= nil then
			local SkillIcon = GOUtil.FindChildComponent(go, "Icon", "Image")

			UIUtil.SetImageSprite(SkillIcon, "UIDyAtlas/Skill/" .. info.data.Icon, self)

			local SkillLevel = GOUtil.FindChildComponent(go, "Level/Text", "Text")

			SkillLevel.text = Lang(12078) .. "：" .. tostring(info.pb.level or 1)

			local GoMask = GOUtil.FindChildGameObject(go, "Image")
			local GoImgLock = GOUtil.FindChildGameObject(go, "Image/ImgUnlock")
			local GoTxtEnable = GOUtil.FindChildGameObject(go, "Image/TxtEnable")
			local GoLevel = GOUtil.FindChildGameObject(go, "Level")
			local GoLock = GOUtil.FindChildGameObject(go, "Lock")
			local isUnlock = CombBondageMgr:BondageSkillIsUnlock(infoCombination, info.id)
			local needNum = infoCombination.data.ActivatedRole[i]
			local isEnable = needNum <= fightNum
			local txtEnable = GOUtil.GetComponent(GoTxtEnable, "Text")

			txtEnable.text = string.format(_("Desc_SkillCondition"), fightNum .. "/" .. needNum)

			GOUtil.SetActive(GoMask, not isUnlock or not isEnable)
			GOUtil.SetActive(GoImgLock, not isUnlock)
			GOUtil.SetActive(GoTxtEnable, isUnlock and not isEnable)
			GOUtil.SetActive(GoLevel, isUnlock)
			GOUtil.SetActive(GoLock, not isUnlock)
			self:AddClick(go, self.OnClickedGoSkill)
			table.insert(self.listCell, go)
		end
	end

	GOUtil.SetActive(self.GoSkill, false)
	RedDotSystemMgr.SetUIRedDot(self.UIRootObject, "Arrow/Bondage/Unlock/" .. infoCombination.id)
end

function CellCombinationSkill:UpdateSelectState(state)
	if state == nil then
		state = false
	end

	GOUtil.SetActive(self.GoSelect, state)
end

function CellCombinationSkill:OnClickedGoSkill(data)
	local go = data.pointerPress.gameObject
	local index = tonumber(go.name)
	local infoSkill = self.listSkill[index]
	local data = {
		infoSkill = infoSkill,
		infoComb = self.info
	}

	Event.Instance:Fire("ShowSkillTip", data)
end
