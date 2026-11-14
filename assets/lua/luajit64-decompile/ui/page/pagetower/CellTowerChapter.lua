-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTower/CellTowerChapter.lua

require("UI/Item/UIItemBase")
require("UI/Item/CellItem")

CellTowerChapter = class("CellTowerChapter", UIItemBase)

local titalNormalPath = "UI/PageTower/AtlasPageTower/BG_tower_frame_03b"
local titalHardPath = "UI/PageTower/AtlasPageTower/BG_tower_frame_03c"
local bookNormalPath = "UI/PageTower/AtlasPageTower/BG_tower_frame_107"
local bookHardPath = "UI/PageTower/AtlasPageTower/BG_tower_frame_107b"
local bookNormalStarPath = "UI/PageTower/AtlasPageTower/BG_tower_frame_107"
local bookHardStarPPath = "UI/PageTower/AtlasPageTower/BG_tower_frame_107b"

function CellTowerChapter:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
	self.PrefabCellItem = ResourceMgr.LoadSync("UI/Item/CellItem")
end

function CellTowerChapter:OnLeave()
	self:OnUnRegisterEvent()

	if self.listItem then
		for i, v in ipairs(self.listItem) do
			v:OnLeave()
		end
	end

	ResourceMgr.Unload(self.PrefabCellItem)
end

function CellTowerChapter:OnEnter(vParam)
	local g = self.UIRootObject

	self.ChapterImg = GOUtil.FindChildComponent(g, "ChapterImg", "Image")
	self.TitalImage = GOUtil.FindChildComponent(g, "Tital", "Image")
	self.Tital = GOUtil.FindChildComponent(g, "Tital/Text", "Text")
	self.Book = GOUtil.FindChildComponent(g, "Book", "Image")
	self.BookStar = GOUtil.FindChildComponent(g, "Book/Star", "Image")
	self.Progress = GOUtil.FindChildComponent(g, "Progress/fill", "Image")
	self.TextProg = GOUtil.FindChildComponent(g, "Progress/TextProg", "Text")
	self.Button = GOUtil.FindChildGameObject(g, "Button")
	self.PDot = GOUtil.FindChildGameObject(g, "Button/Dot")
	self.BattleBtn = GOUtil.FindChildGameObject(g, "BattleBtn")
	self.Lock = GOUtil.FindChildGameObject(g, "Lock")
	self.Finish = GOUtil.FindChildGameObject(g, "Finish")
	self.FX_UI_003 = GOUtil.FindChildGameObject(g, "FX_UI_003")
	self.listItem = {}

	for i = 1, 3 do
		local gItem = GOUtil.FindChildGameObject(g, "CellItem" .. i)
		local item = CellItem(gItem)

		item:InitItemByRoot(gItem)
		table.insert(self.listItem, item)
	end
end

function CellTowerChapter:OnRegisterEvent()
	self:AddClick(self.Button, self.OnClickEnter)
	self:AddClick(self.BattleBtn, self.OnClickEnter)
end

function CellTowerChapter:OnUnRegisterEvent()
	self:RemoveClick(self.Button, self.OnClickEnter)
	self:RemoveClick(self.BattleBtn, self.OnClickEnter)
end

function CellTowerChapter:UpdateData(info)
	if self.info == info then
		return
	end

	self.info = info

	local num = 0
	local total = #info.listStage

	for i, v in ipairs(info.listStage) do
		if v:IsPass() then
			num = num + 1
		end
	end

	self.Progress.fillAmount = num / total
	self.TextProg.text = num .. "<size= 28>/" .. total .. "</size>"

	local isGet = info.pb.awardStatus[3] == 1

	SetActiveFunc(self.PDot, not isGet and self.info:IsPass())

	local itemList = info.data.GoldAwardList

	for i, v in ipairs(self.listItem) do
		if i <= #itemList then
			SetActiveFunc(self.listItem[i].UIRootObject, true)

			local item = ItemManager:GetValueItem(itemList[i][1], itemList[i][2])

			v:UpdateWithNumType(item)
			v:SetGetedGreen(isGet)
		else
			SetActiveFunc(self.listItem[i].UIRootObject, false)
		end
	end

	self.Tital.text = Lang(info.data.Name)

	UIUtil.SetImageSprite(self.ChapterImg, info.data.Icon, self.page)
	UIUtil.SetImageSprite(self.TitalImage, TenaryOp(info.data.Type == ChapterFromType.tower, titalNormalPath, titalHardPath), self.page)
	UIUtil.SetImageSprite(self.Book, TenaryOp(info.data.Type == ChapterFromType.tower, bookNormalPath, bookHardPath), self.page)
	UIUtil.SetImageSprite(self.BookStar, TenaryOp(info.data.Type == ChapterFromType.tower, bookNormalStarPath, bookHardStarPPath), self.page)

	if info:IsPass() then
		SetActiveFunc(self.Finish, true)
		SetActiveFunc(self.Button, true)
		SetActiveFunc(self.BattleBtn, false)
		SetActiveFunc(self.Lock, false)
	elseif info:IsOpen() then
		SetActiveFunc(self.Finish, false)
		SetActiveFunc(self.Button, false)
		SetActiveFunc(self.BattleBtn, true)
		SetActiveFunc(self.Lock, false)
	else
		SetActiveFunc(self.Finish, false)
		SetActiveFunc(self.Button, false)
		SetActiveFunc(self.BattleBtn, false)
		SetActiveFunc(self.Lock, true)
	end

	local text = self:GetChildComponent("Award/Text", "Text")

	text.text = Lang(5000108) .. "："
	text = self:GetChildComponent("Button/Text", "Text")
	text.text = _("PageRole_Detail")
	text = self:GetChildComponent("BattleBtn/Text", "Text")
	text.text = _("Desc_Raid_Choice")
	text = self:GetChildComponent("Lock/Text", "Text")
	text.text = _("Desc_TowerLockTip")

	local list = PersistentStoreUtil.GetList("UnLockTower")

	if #list ~= 0 then
		local key = self:isInArray(list, info.pb.id)

		if key ~= -1 then
			list[key] = nil

			SetActiveFunc(self.FX_UI_003, true)
			PersistentStoreUtil.SetList("UnLockTower", list)
		end
	else
		SetActiveFunc(self.FX_UI_003, false)
	end
end

function CellTowerChapter:OnClickEnter()
	require("UI/Page/PageTower/PageTowerStage")
	UIMgr.SwitchPanel(PageTowerStage, {
		infoChapter = self.info
	})
end

function CellTowerChapter:isInArray(t, val)
	for key, v in pairs(t) do
		if tonumber(v) == val then
			return key
		end
	end

	return -1
end
