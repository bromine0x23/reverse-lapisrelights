-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageInteraction/CellStoryChapter.lua

require("UI/Item/UIItemBase")

CellStoryChapter = class("CellStoryChapter", UIItemBase)

function CellStoryChapter:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellStoryChapter:OnLeave()
	self.GoItem = nil

	if self.cellItem then
		self.cellItem:OnLeave()

		self.cellItem = nil
	end

	UnloadAllImageSprite(self)
	TimerMgr.RemoveTimer(self.timer)
end

function CellStoryChapter:SetCellItem(cellItem)
	self.cellItem = cellItem
end

function CellStoryChapter:OnEnter()
	local g = self.UIRootObject

	self.ImageIcon = GOUtil.FindChildComponent(g, "ImageIcon", "Image")
	self.GoItem = GOUtil.FindChildGameObject(g, "GoItem")
	self.GLock = GOUtil.FindChildGameObject(g, "ImageLock")
	self.GLockText = GOUtil.FindChildComponent(g, "ImageLock/Image/Text", "Text")
	self.GLockOpen = GOUtil.FindChildGameObject(g, "ImageLock/FX_UI_004")
	self.GLocked = GOUtil.FindChildGameObject(g, "ImageLock/Image")
	self.GNew = GOUtil.FindChildGameObject(g, "ImageNew")
	self.TextChapterName = GOUtil.FindChildComponent(g, "TextChapterName", "Text")
	self.Dot = GOUtil.FindChildGameObject(g, "PDot")
	self.Attr = GOUtil.FindChildGameObject(g, "Attr")

	for i = 1, 4 do
		self["TxtValue" .. i] = self:GetChildComponent("Attr/" .. i .. "/Line/Text", "Text")
		self["GOValue" .. i] = self:GetChildGameObject("Attr/" .. i)
		self["GOFirst" .. i] = self:GetChildGameObject("Attr/" .. i .. "/FirstAward")
		self["GOIsGet" .. i] = self:GetChildGameObject("Attr/" .. i .. "/IsGet")
	end
end

function CellStoryChapter:UpdateData(info, infoRole)
	SetActiveFunc(self.GLock, false)
	SetActiveFunc(self.GLockOpen, false)
	SetActiveFunc(self.GLocked, false)
	SetActiveFunc(self.GNew, false)
	UIUtil.SetImageOverrideSprite(self.ImageIcon, info.data.Icon, self)

	self.TextChapterName.text = info:GetName()

	if info.data.FavorStorySkill ~= 0 then
		SetActiveFunc(self.cellItem.UIRootObject, false)
		SetActiveFunc(self.Attr, true)

		local infoTalent = TalentManager:Get(info.data.FavorStorySkill)
		local skillAttr = infoTalent.data.Argus1[1]

		for i = 1, 4 do
			if skillAttr[i] > 0 then
				self["TxtValue" .. i].text = "+" .. skillAttr[i]
			end

			SetActiveFunc(self["GOValue" .. i], skillAttr[i] > 0)
			SetActiveFunc(self["GOFirst" .. i], not info.pb.isPass)
			SetActiveFunc(self["GOIsGet" .. i], info.pb.isPass)
		end
	else
		SetActiveFunc(self.cellItem.UIRootObject, true)
		SetActiveFunc(self.Attr, false)

		local id = info.data.FirstAward[1][1]
		local infoItem = ItemManager:Get(id)

		self.cellItem:UpdateNoNumType(infoItem)
		self.cellItem:SetGeted(info.pb.isPass)
	end

	local favorLevel = info.data.FavorLevel

	SetActiveFunc(self.Dot, false)

	if favorLevel > infoRole.curFavorLevel then
		SetActiveFunc(self.GLock, true)
		SetActiveFunc(self.GLockOpen, false)
		SetActiveFunc(self.GLocked, true)
		SetActiveFunc(self.GNew, false)

		self.GLockText.text = string.format(_("PageTalentTree_Unlock_favor"), favorLevel)
	else
		local isEnter = PersistentStoreUtil.GetBool(PersistentStoreUtil.KEY_FAVOR_STORY_ENTER .. info.id, true)

		SetActiveFunc(self.GLock, false)

		if not isEnter then
			SetActiveFunc(self.GNew, true)
		else
			SetActiveFunc(self.GNew, false)

			if not info.pb.isPass then
				SetActiveFunc(self.Dot, true)
			end
		end
	end
end
