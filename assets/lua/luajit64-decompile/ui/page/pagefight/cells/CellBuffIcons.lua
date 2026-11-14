-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Cells/CellBuffIcons.lua

local CellBuffIcons_item = class("CellBuffIcons_item")

function CellBuffIcons_item:ctor(obj)
	self.gameObject = obj
	self.img_icon = GOUtil.FindChildComponent(self.gameObject, "img_icon", "Image")
	self.txt_stack = GOUtil.FindChildComponent(self.gameObject, "txt_stack", "Text")
	self.lastStack = 0
end

function CellBuffIcons_item:Purge()
	self.gameObject = nil
	self.img_icon = nil
	self.txt_stack = nil
	self.lastStack = 0
end

function CellBuffIcons_item:Show(val)
	if IsNil(self.gameObject) then
		return
	end

	GOUtil.SetActive(self.gameObject, val)
end

local SPEED = 0.15

function CellBuffIcons_item:SetBuff(buff, buffUid)
	if IsNil(self.gameObject) then
		return
	end

	if IsNil(self.txt_stack) then
		return
	end

	GP.SpriteUtil:SetSprite(self.img_icon, buff.IconPath)

	if buff.MaxStack == 0 then
		self.txt_stack.text = ""
	elseif buff.Stack > 0 then
		self.txt_stack.text = tostring(buff.Stack)

		if buffUid == buff.UID then
			local tween = GOUtil.DOScaleAll(self.txt_stack.transform, 1.5, SPEED)

			GOUtil.SetTweenerCallback(tween, function()
				if IsNil(self.txt_stack) then
					return
				end

				GOUtil.DOScaleAll(self.txt_stack.transform, 1, SPEED)
			end)
		end
	else
		self.txt_stack.text = ""
	end
end

CellBuffIcons = class("CellBuffIcons", UIPanel_sync)

function CellBuffIcons:ctor(str)
	if str == "boss" then
		CellBuffIcons.base.ctor(self, "UI/PageFight/Cells/CellBuffIcons_boss")
	else
		CellBuffIcons.base.ctor(self, "UI/PageFight/Cells/CellBuffIcons")
	end
end

function CellBuffIcons:Cache()
	CellBuffIcons.base.Cache(self)
end

function CellBuffIcons:Close()
	CellBuffIcons.base.Close(self)
end

function CellBuffIcons:Purge()
	CellBuffIcons.base.Purge(self)

	self.owner = nil

	for i, item in ipairs(self.items) do
		item:Purge()
	end
end

function CellBuffIcons:OnEnter()
	self.obj_clickArea = self:GetChildGameObject("obj_clickArea")
	self.items = {}

	local itemTrans = self:GetChildGameObject("buffs").transform

	for i = 1, itemTrans.childCount do
		local obj = itemTrans:GetChild(i - 1).gameObject
		local item = CellBuffIcons_item(obj)

		item:Show(false)
		table.insert(self.items, item)
	end
end

function CellBuffIcons:Bind(uniqueId, root, showIcon)
	self.owner = UnitActor.FindUnitById(uniqueId)
	self.showIcon = showIcon

	GOUtil.AttachGameObject(self.UIRootObject, root, true)
end

function CellBuffIcons:OnRegisterEvent()
	Event.Instance:Add("AddBuff", self.OnBuffChange, self)
	Event.Instance:Add("RemoveBuff", self.OnBuffChange, self)
	Event.Instance:Add("BuffStack", self.OnBuffChange, self)
	self:AddListener(self.obj_clickArea, self.OnPointerDown_Buff, EventTriggerType.PointerLongPress)
end

function CellBuffIcons:OnUnRegisterEvent()
	Event.Instance:Remove("AddBuff", self.OnBuffChange, self)
	Event.Instance:Remove("RemoveBuff", self.OnBuffChange, self)
	Event.Instance:Remove("BuffStack", self.OnBuffChange, self)
	self:RemoveListener(self.obj_clickArea, self.OnPointerDown_Buff, EventTriggerType.PointerLongPress)
end

local function FixScreenPos(screenClickPoint)
	local offset = UIMgr.RootCanvas.pixelRect.width * 0.2

	if screenClickPoint.x > UIMgr.RootCanvas.pixelRect.width / 2 then
		screenClickPoint.x = screenClickPoint.x - offset
	else
		screenClickPoint.x = screenClickPoint.x + offset
	end

	return Vector2.New(screenClickPoint.x, screenClickPoint.y)
end

local function yOffset(buffCount, screenClickPoint)
	local offset = 200 + (buffCount - 1) * 102.94 / 2

	if buffCount > 8 then
		offset = offset - 200
	elseif buffCount > 5 then
		offset = offset - 200
	end

	if screenClickPoint.y > UIMgr.RootCanvas.pixelRect.height / 2 then
		offset = offset * -1
	end

	return offset
end

function CellBuffIcons:OnPointerDown_Buff(data)
	if self.owner == nil then
		return
	end

	if data.clickCount == 1 then
		local unit = self.owner
		local _buffs = {}

		for i, buff in ipairs(unit.Buffs) do
			if buff.ShowIcon == self.showIcon or buff.ShowIcon == EnumFight.ShowIcon.All then
				table.insert(_buffs, buff)
			end
		end

		if #_buffs > 0 then
			local offset = yOffset(#_buffs, data.position)
			local fixPos = FixScreenPos(data.position)

			print(offset)
			UIMgr.ShowBuffTip(_buffs, fixPos, offset)
		end
	else
		UIMgr.HideBuffTip()
	end
end

function CellBuffIcons:OnBuffChange(uniqueId, buffId, buffUid)
	if self.owner == nil then
		return
	end

	if self.owner.UniqueId ~= uniqueId then
		return
	end

	local unit = self.owner
	local itemCount = 0

	for i, buff in ipairs(unit.Buffs) do
		if buff.ShowIcon == self.showIcon or buff.ShowIcon == EnumFight.ShowIcon.All then
			itemCount = itemCount + 1

			local item = self.items[itemCount]

			if item then
				item:Show(true)
				item:SetBuff(buff, buffUid)
			else
				break
			end
		end
	end

	for i = itemCount + 1, #self.items do
		self.items[i]:Show(false)
	end
end
