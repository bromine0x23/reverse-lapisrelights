-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePass/CellTeamPass.lua

require("UI/Item/UIItemBase")

CellTeamPass = class("CellTeamPass", UIItemBase)

function CellTeamPass:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellTeamPass:Create(vParam)
	CellTeamPass.base.Create(self, vParam)
end

function CellTeamPass:OnEnter()
	local g = self.UIRootObject

	self.CombIcon = GOUtil.FindChildComponent(g, "Team", "RawImage")
	self.GoLock = GOUtil.FindChildGameObject(g, "GoLock")
	self.LockIcon = GOUtil.FindChildComponent(g, "GoLock", "RawImage")
	self.GoRate = GOUtil.FindChildGameObject(g, "BgRate")
	self.TxtRate = GOUtil.FindChildComponent(g, "BgRate/Image/Text", "Text")
	self.TxtPlayNum = GOUtil.FindChildComponent(g, "Text", "Text")
	self.NoOpen = GOUtil.FindChildGameObject(g, "NoOpen")

	for i = 1, 3 do
		local item = GOUtil.FindChildGameObject(g, "CellGroup/CellItem" .. i)

		self["CellItem" .. i] = CellItem(item)

		self["CellItem" .. i]:InitItemByRoot(item)
	end
end

function CellTeamPass:OnLeave()
	for i = 1, 3 do
		self["CellItem" .. i]:OnLeave()
	end

	UnloadAllImageSprite(self)
end

function CellTeamPass:UpdateData(infoComb)
	self.NoOpen:SetActive(false)

	if infoComb == nil then
		self.NoOpen:SetActive(true)

		return
	end

	local combId = infoComb.id

	self.listChapter = CombChapterMgr.GetCombChapters(combId)
	self.listOpenChapter = {}

	for i = 1, #self.listChapter do
		local isOpen = self.listChapter[i]:IsOpen()

		if isOpen then
			table.insert(self.listOpenChapter, self.listChapter[i])
		end
	end

	if #self.listOpenChapter == 0 then
		return
	end

	self.chapterIdx = #self.listOpenChapter
	self.chapterId = self.listOpenChapter[self.chapterIdx].data.ID
	self.listStage = ChapterMgr:GetChapter(self.chapterId).listStage

	local ItemInfoList = {}

	for _, value in pairs(self.listStage) do
		for _, item in pairs(value.data.ItemList) do
			local infoItem = ItemManager:GetValueItem(item[1], item[2])

			if infoItem:GetType() == eItemType.I_SCROLL and infoItem:GetQuality() >= 3 then
				local flag = false

				for _, data in ipairs(ItemInfoList) do
					if infoItem.id == data.id then
						flag = true
					end
				end

				if not flag and #ItemInfoList < 3 then
					table.insert(ItemInfoList, infoItem)

					if #ItemInfoList >= 3 then
						break
					end
				end
			end
		end
	end

	for i = 1, 3 do
		local data = ItemInfoList[i]

		if data ~= nil then
			self["CellItem" .. i]:UpdateNoNumType(data)
			self["CellItem" .. i].UIRootObject:SetActive(true)
		else
			self["CellItem" .. i].UIRootObject:SetActive(false)
		end
	end

	self.TxtPlayNum.text = _("Desc_Times") .. CombChapterMgr.GetCombRemainingChallengeNum(combId) .. "/" .. CombChapterMgr.GetSingleLimitChallengeNum(combId)

	UIUtil.SetRawImageTexture(self.CombIcon, "Texture/Team/BG_team_logo_0" .. combId .. "b", self)
	UIUtil.SetRawImageTexture(self.LockIcon, "Texture/Team/BG_team_logo_0" .. combId .. "b", self)

	local isUnlock = CombChapterMgr.CombChapterIsUnLock(combId)

	SetActiveFunc(self.GoLock, not isUnlock)
	SetActiveFunc(self.GoRate, isUnlock)

	local rate, sum = CombChapterMgr.GetCombChapterStarCollect(combId)

	self.TxtRate.text = rate .. "/" .. sum

	RedDotSystemMgr.SetUIRedDot(self.UIRootObject, "Chapter/Comb/" .. combId)
end
