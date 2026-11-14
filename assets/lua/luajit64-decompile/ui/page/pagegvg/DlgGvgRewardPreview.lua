-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGvg/DlgGvgRewardPreview.lua

local ITEM_CONFIG = {
	{
		"PersonalBasicReward",
		"PersonalMaxDamageReward"
	},
	{
		"PersonalStagePassReward",
		"GroupStagePassReward"
	},
	{
		"GVGPhaseReward"
	}
}
local CFG_SOURCE = {
	GroupStagePassReward = "STAGE_DATA",
	GVGPhaseReward = "CHAPTER_DATA",
	PersonalStagePassReward = "STAGE_DATA",
	PersonalBasicReward = "STAGE_DATA",
	PersonalMaxDamageReward = "STAGE_DATA"
}
local ITEM_SHOW_NUM = {
	GroupStagePassReward = false,
	GVGPhaseReward = true,
	PersonalStagePassReward = false,
	PersonalBasicReward = false,
	PersonalMaxDamageReward = false
}
local ITEM_NAME_CONFIG = {
	"Desc_GVG_leveldrop",
	"Desc_GVG_killdrop",
	"Desc_GVG_phasedrop"
}
local mt = class("DlgGvgRewardPreview_Item", UIItemBase)

DlgGvgRewardPreview = class("DlgGvgRewardPreview", UIPanel)

require("UI/Item/UIItemBase")

function DlgGvgRewardPreview:ctor()
	DlgGvgRewardPreview.base.ctor(self, "UI/PageGvg/DlgGvgRewardPreview")
end

function DlgGvgRewardPreview:Purge()
	DlgGvgRewardPreview.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellItem)
	UnloadAllImageSprite(self)

	for i = #self.items, 1, -1 do
		local item = table.remove(self.items, i)

		item:Purge()
	end
end

function DlgGvgRewardPreview:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
end

function DlgGvgRewardPreview:OnRegisterEvent()
	self:AddClick(self.btn_close, self.OnBtnClose)
end

function DlgGvgRewardPreview:OnUnRegisterEvent()
	self:RemoveClick(self.btn_close, self.OnBtnClose)
end

function DlgGvgRewardPreview:OnBtnClose()
	self:Close()
end

function DlgGvgRewardPreview:OnEnter(step)
	self.step = step
	self.btn_close = self:GetChildGameObject("panel/close/obj_click")
	self.itemT = self:GetChildGameObject("panel/items/itemT")
	self.items = {}
	self.itemMap = {}

	GOUtil.SetActive(self.itemT, false)
	self:CreateItems()
	self:Refresh()
end

function DlgGvgRewardPreview:CreateItems()
	for i, itemKeys in ipairs(ITEM_CONFIG) do
		local item = mt()

		item:Init(self.itemT)

		for _, key in ipairs(itemKeys) do
			self.itemMap[key] = i
		end

		local key = ITEM_NAME_CONFIG[i]

		item.title = _(key)
		item.PrefabCellItem = self.PrefabCellItem

		table.insert(self.items, item)
	end
end

function DlgGvgRewardPreview:GetItem(key)
	local idx = self.itemMap[key]

	if idx then
		local item = self.items[idx]

		if item then
			return item
		end
	end

	return nil
end

function DlgGvgRewardPreview:Refresh()
	local allkeys = {}

	for i, itemKeys in ipairs(ITEM_CONFIG) do
		for _, key in ipairs(itemKeys) do
			table.insert(allkeys, key)
		end
	end

	for i, stage in Infogvg.stage:Filter():IsStep(self.step):Ipairs() do
		for keyIdx, key in ipairs(allkeys) do
			local rewards = {}

			if CFG_SOURCE[key] == "STAGE_DATA" then
				local infoStage = InfoStage(stage.stageId)

				rewards = infoStage.data[key]
			elseif CFG_SOURCE[key] == "CHAPTER_DATA" and stage.portalIdx == 1 then
				local infochapter = ChapterMgr:GetChapter(stage.chapterId)

				rewards = infochapter.data[key]
			end

			for j, reward in ipairs(rewards) do
				local id = reward[1]
				local count = reward[2]
				local item = self:GetItem(key)

				item:AddReward(id, count, ITEM_SHOW_NUM[key])
			end
		end
	end

	for i, item in ipairs(self.items) do
		item:Refresh()
	end
end

function mt:Init(obj)
	local go = GOUtil.Instantiate(obj, obj.transform.parent.gameObject)

	mt.base.base.ctor(self)

	self.UIRootObject = go

	GOUtil.SetActive(self.UIRootObject, true)

	self.rewards = {}
	self.title = "none"

	self:OnEnter()
	self:OnRegisterEvent()
end

function mt:Purge()
	self:OnUnRegisterEvent()

	self.PrefabCellItem = nil

	self.UIScrollTool:Purge()
	Object.Destroy(self.UIRootObject)
end

function mt:OnRegisterEvent()
	return
end

function mt:OnUnRegisterEvent()
	return
end

function mt:OnEnter()
	self.txt_title = self:GetChildComponent("txt_title", "Text")
	self.UIScrollTool = UIScrollTool()
end

function mt:AddReward(id, count, showNum)
	for i, reward in ipairs(self.rewards) do
		if reward.id == id then
			reward.count = reward.count + count

			return
		end
	end

	table.insert(self.rewards, {
		id = id,
		count = count,
		showNum = showNum
	})
end

function mt:Refresh()
	self.txt_title.text = self.title

	local scrollArea = self:GetChildGameObject("scroll")
	local content = self:GetChildComponent("scroll/content", "RectTransform")
	local count = #self.rewards

	local function onAdd(item)
		return
	end

	local function onUpdate(item, index)
		local v = self.rewards[index]
		local infoItem = ItemManager:GetValueItem(v.id, v.count)

		if v.showNum then
			item:UpdateWithNumType(infoItem)
		else
			item:UpdateNoNumType(infoItem)
		end
	end

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellItem, CellItem, self, true, onAdd, onUpdate)
end
