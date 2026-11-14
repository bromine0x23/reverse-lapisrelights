-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGvg/Skills.lua

local mt = class("DlgGvg_Skills")

require("UI/Item/UIItemBase")

local cell = class("CellGvgSkill", UIItemBase)

function mt:ctor()
	return
end

function mt:Init(root, itemPrefabCache)
	self.root = root
	self.itemPrefabCache = itemPrefabCache
	self.items = {}

	self:AddEvent()
	self:Refresh()
	UIMgr.SetUpdatePanel(self)
end

function mt:Purge()
	UIMgr.RemoveUpdatePanel(self)
	self:RemoveEvent()

	for i = #self.items, 1, -1 do
		local item = table.remove(self.items, i)

		item:Purge()
	end
end

function mt:AddEvent()
	Event.Instance:Add("EVENT_GVG_REFRESH", self.OnEventGvgRefresh, self)
end

function mt:RemoveEvent()
	Event.Instance:Remove("EVENT_GVG_REFRESH", self.OnEventGvgRefresh, self)
end

function mt:OnEventGvgRefresh()
	self:Refresh()
end

function mt:Refresh()
	for i = #self.items, 1, -1 do
		local item = table.remove(self.items, i)

		item:Purge()
	end

	for i, skill in ipairs(Infogvg.stage.skills) do
		local obj = cell(self.itemPrefabCache, self.root)

		obj:Create(skill)
		table.insert(self.items, obj)
	end
end

function mt:OnUpdateSecond()
	for i, item in ipairs(self.items) do
		item:TimeText()
	end
end

function cell:ctor(itemPrefabCache, parent)
	cell.base.ctor(self, itemPrefabCache, parent)
end

function cell:Purge()
	self:OnUnRegisterEvent()
	UnloadAllImageSprite(self)
	Object.Destroy(self.UIRootObject)
end

function cell:OnRegisterEvent()
	self:AddListener(self.obj_click, self.OnPointerDown, EventTriggerType.PointerDown)
end

function cell:OnUnRegisterEvent()
	self:RemoveListener(self.obj_click, self.OnPointerDown, EventTriggerType.PointerDown)
end

function cell:OnPointerDown(data)
	if data.clickCount == 1 then
		Infogvg:Log("self.id:" .. self.id)

		local tipData = SkillTip.GetMonsterData(data.position, self.id)

		UIMgr.ShowSkillTip(tipData)
	else
		UIMgr.HideSkillTip()
	end
end

function cell:OnEnter(skill)
	self.id = skill.id
	self.level = skill.level
	self.endTime = skill.endTime
	self.img_icon = self:GetChildComponent("img_icon", "Image")
	self.obj_click = self:GetChildGameObject("obj_click")
	self.txt_time = self:GetChildComponent("txt_time", "Text")

	local talent = TalentManager:Get(self.id)

	if talent then
		UIUtil.SetImageSprite(self.img_icon, talent:GetIconPath(), self)
	else
		Infogvg:Error(" TalentManager can not found:" .. self.id)
	end

	self:TimeText()
	self:OnRegisterEvent()
end

function cell:TimeText()
	local endTime = tonumber(self.endTime)
	local serverTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local leftSec = Mathf.Floor(Mathf.Max(0, endTime - serverTime))

	UIUtil.SetTextString(self.txt_time, self:_FormatTime(leftSec))

	if leftSec == 0 then
		Infogvg.net:RequestGvg()
	end
end

function cell:_FormatTime(second)
	local d, h, m, s = GetTimeFormatBySec(second)
	local strTime = ""

	if d > 0 then
		strTime = string.format("%02d:%02d:%02d", d, h, m)
	elseif h > 0 then
		strTime = string.format("%02d:%02d", h, m)
	elseif m > 0 then
		strTime = string.format("%02d:%02d", h, m)
	elseif s > 0 then
		strTime = "00:01"
	else
		return "00:01"
	end

	return strTime
end

return mt
