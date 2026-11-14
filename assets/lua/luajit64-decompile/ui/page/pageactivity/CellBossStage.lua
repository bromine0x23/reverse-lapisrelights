-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivity/CellBossStage.lua

require("UI/Item/UIItemBase")

CellBossStage = class("CellBossStage", UIItemBase)

function CellBossStage:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellBossStage:Create(vParam)
	CellBossStage.base.Create(self, vParam)
end

function CellBossStage:OnEnter(vParam)
	local g = self.UIRootObject
	local text = GOUtil.FindChildComponent(g, "CostItem/Text", "Text")

	text.text = Lang(5000009)
	self.BGIcon = GOUtil.FindChildComponent(g, "", "Image")
	self.BossIcon = GOUtil.FindChildComponent(g, "EnemyIcon", "Image")
	self.TextLevel = GOUtil.FindChildComponent(g, "TextLevel", "Text")
	self.ImageLevel = GOUtil.FindChildComponent(g, "ImageLevel", "Image")
	self.TextDiff = GOUtil.FindChildComponent(g, "Name/TextDiff", "Text")
	self.TextNum = GOUtil.FindChildComponent(g, "NeedItem/TextNum", "Text")
	self.ImageNeed = GOUtil.FindChildComponent(g, "NeedItem/Image", "Image")
	self.GoLock = GOUtil.FindChildGameObject(g, "GoLock")
	self.GoDot = GOUtil.FindChildGameObject(g, "Dot")

	self.GoDot:SetActive(false)

	self.Animator = GOUtil.FindChildComponent(g, "", "Animator")
	self.Finish = self:GetChildGameObject("Finish")
	self.listItem = {}

	for i = 1, 2 do
		local gItem = GOUtil.FindChildGameObject(g, "Award/" .. i)
		local item = CellItem(gItem)

		item:InitItemByRoot(gItem)
		table.insert(self.listItem, item)
	end
end

function CellBossStage:OnLeave()
	UnloadAllImageSprite(self)

	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end

		self.listItem = nil
	end
end

function CellBossStage:UpdateData(infoStage)
	self.info = infoStage

	if infoStage.showEffect ~= nil then
		self.Animator:Play("CellBossStage_Open", 0, 0)
	end

	if infoStage.data.ActType == 20 then
		UIUtil.SetImageSprite(self.BGIcon, "UI/PanelActivity/AtlasActivityStage/BTN_bossex_05", self)
	else
		UIUtil.SetImageSprite(self.BGIcon, "UI/PanelActivity/AtlasActivityStage/BTN_bossex_01", self)
	end

	local isOpen = infoStage.isUnLock

	if not isOpen then
		local infoChapter = ChapterMgr:GetChapterByStage(self.info.data.ID)

		if table.contains(infoChapter.data.InitStage, self.info.data.ID) then
			isOpen = true
		end
	end

	self.GoLock:SetActive(not isOpen)

	local infoMonster = EnemyManager:Get(infoStage.listMonster[1])

	UIUtil.SetImageOverrideSprite(self.BossIcon, infoMonster.data.NameIcon, self)
	UIUtil.SetImageSprite(self.ImageLevel, infoStage.data.Icon, self)

	local costItem = self.info.data.CostItem

	UIUtil.SetImageOverrideSprite(self.ImageNeed, ItemManager:GetIcon(costItem[1]), self)

	self.TextNum.text = costItem[2] .. _("Desc_count")

	SetActiveFunc(self.Finish, infoStage:GetLeftPlayNum() == 0 and infoStage.data.ActType == 20)

	local clickTime = PersistentStoreUtil.GetString("KEY_RDL_CHAPTER_PARTY_BOSS")

	SetActiveFunc(self.GoDot, infoStage:IsOpen() and infoStage.data.ActType == 20 and (clickTime == "" or clickTime ~= "" and not TimeIsToday(clickTime)))

	local listAward = {}

	if infoStage:IsPass() then
		for i, v in ipairs(infoStage.data.ItemList) do
			table.insert(listAward, {
				isFirst = false,
				data = v
			})
		end
	else
		for i, v in ipairs(infoStage.data.FirstAward) do
			table.insert(listAward, {
				isFirst = true,
				data = v
			})
		end

		for i, v in ipairs(infoStage.data.ItemList) do
			table.insert(listAward, {
				isFirst = false,
				data = v
			})
		end
	end

	for i = 1, #self.listItem do
		local item = self.listItem[i]

		item.UIRootObject:SetActive(i <= #listAward)

		if i <= #listAward then
			local id = listAward[i].data[1]
			local num = listAward[i].data[2]
			local award = ItemManager:GetValueItem(id, num, listAward[i].data[3])

			if award.randomNum then
				item:UpdateWithNumType(award, nil, award.randomNum)
			else
				item:UpdateWithNumType(award)
			end

			item:SetFirstPass(listAward[i].isFirst)
		end
	end
end
