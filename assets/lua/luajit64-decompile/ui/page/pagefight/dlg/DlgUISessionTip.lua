-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUISessionTip.lua

local STAY_TIME = 0.85
local TOTAL_TIME = 1.5
local DUROTION = (TOTAL_TIME - STAY_TIME) * 0.5
local State = {
	Out = "DlgUISession_item_out",
	Hold = "DlgUISession_item_hold",
	In = "DlgUISession_item_in",
	None = "None"
}
local DlgUISessionTip_item = class("DlgUISessionTip_item")

function DlgUISessionTip_item:ctor(go, parent)
	self.go = go
	self.trans = self.go.transform
	self.animator = GOUtil.GetComponent(go, "Animator")
	self.delayHandle = nil
	self.parent = parent
	self.height = -1
	self.state = State.None
	self.waitUp = false
	self.img_icon = GOUtil.FindChildComponent(go, "img_icon", "Image")
	self.txt_label = GOUtil.FindChildComponent(go, "txt_label", "Text")

	EventListenerMgr.AddAnimListenerEventID(self.go, self.OnEnd, self, "End")
	EventListenerMgr.AddAnimListenerEventID(self.go, self.OnHold, self, "InEnd")
	EventListenerMgr.AddAnimListenerEventID(self.go, self.OnOut, self, "Hold")
end

function DlgUISessionTip_item:SetHeight(height)
	self.trans:DOLocalMove(Vector3(0, height * -86, 0), 0)

	self.height = height
end

function DlgUISessionTip_item:In()
	self.state = State.In

	self.animator:Play(State.In)
end

function DlgUISessionTip_item:Up()
	if self.height == 0 or self.height == -1 then
		return
	end

	self.waitUp = false

	if self.state == State.Hold then
		self:_Up()
	elseif self.state == State.In then
		self.waitUp = true
	end
end

function DlgUISessionTip_item:_Up()
	self.animator.speed = 0

	self.trans:DOLocalMove(Vector3(0, 86, 0), 0.3):SetRelative(true):SetAutoKill(true)
	BattleConfig.FreeTimer(self.delayHandle)

	self.delayHandle = BattleConfig.Delay(0.3, function()
		self.animator.speed = 1
	end)
end

function DlgUISessionTip_item:IsState(state)
	return self.animator:GetCurrentAnimatorStateInfo(0):IsName(state)
end

function DlgUISessionTip_item:Purge()
	EventListenerMgr.RemoveAnimListenerEventID(self.go, self.OnEnd, self, "End")
	EventListenerMgr.RemoveAnimListenerEventID(self.go, self.OnHold, self, "InEnd")
	EventListenerMgr.RemoveAnimListenerEventID(self.go, self.OnOut, self, "Hold")

	self.go = nil
	self.trans = nil
	self.animator = nil

	BattleConfig.FreeTimer(self.delayHandle)

	self.delayHandle = nil
end

function DlgUISessionTip_item:OnHold()
	self.state = State.Hold

	if self.waitUp == true then
		self:_Up()
	end
end

function DlgUISessionTip_item:OnOut()
	self.state = State.Out
end

function DlgUISessionTip_item:OnEnd()
	self.state = State.None
	self.height = -1
	self.waitUp = false

	self.parent:OnItemEnd(self)
end

DlgUISessionTip = class("DlgUISessionTip", UIPanel_sync)

function DlgUISessionTip:ctor()
	DlgUISessionTip.base.ctor(self, "UI/PageFight/Dlg/DlgUISessionTip")
end

function DlgUISessionTip:Cache()
	DlgUISessionTip.base.Cache(self)
end

function DlgUISessionTip:Close(tParam)
	DlgUISessionTip.base.Close(self, tParam)
end

function DlgUISessionTip:Purge()
	DlgUISessionTip.base.Purge(self)

	for i, item in ipairs(self.items) do
		item:Purge()
	end

	UIMgr:RemoveSafeArea(self)
end

function DlgUISessionTip:OnRegisterEvent()
	DlgUISessionTip.base.OnRegisterEvent(self)
	Event.Instance:Add("UISessionTip", self.OnUISessionTip, self)
end

function DlgUISessionTip:OnUnRegisterEvent()
	DlgUISessionTip.base.OnUnRegisterEvent(self)
	Event.Instance:Remove("UISessionTip", self.OnUISessionTip, self)
end

function DlgUISessionTip:OnEnter(vParam)
	DlgUISessionTip.base.OnEnter(self, vParam)
	UIMgr:SetSafeArea(self, self.UIRootObject)

	self.btn_test = self:GetChildGameObject("panel/btn_test")
	self.items = {}
	self.playingItems = {}

	local itemTrans = self:GetChildGameObject("panel/InfoContent").transform

	for i = 1, itemTrans.childCount do
		local obj = itemTrans:GetChild(i - 1).gameObject
		local item = DlgUISessionTip_item(obj, self)

		table.insert(self.items, item)
	end

	self:Hide()
end

function DlgUISessionTip:Open()
	self:Show(true)
end

function DlgUISessionTip:Hide()
	self:Show(false)
end

function DlgUISessionTip:OnUISessionTip(skillCfg, unit)
	self:Show(true)

	local ownSkill = unit:GetOwnSkill(skillCfg.ID)
	local item = self:GetItem()

	if item then
		GP.SpriteUtil:SetSprite(item.img_icon, unit.InfoRoleCard.data.HeadIcon)
		ownSkill:SetName(item.txt_label)
	end
end

function DlgUISessionTip:OnItemEnd(item)
	local hidePanel = true

	for i, item in ipairs(self.items) do
		if item.height ~= -1 then
			hidePanel = false

			break
		end
	end

	if hidePanel == true then
		self:Hide()
	end
end

function DlgUISessionTip:GetItem()
	local maxHeight = -1
	local emptyItem

	for i, item in ipairs(self.items) do
		if emptyItem == nil and item.height == -1 then
			emptyItem = item
		end

		if maxHeight <= item.height then
			maxHeight = item.height + 1
		end
	end

	if emptyItem then
		emptyItem:SetHeight(maxHeight)
		emptyItem:In()
	end

	return emptyItem
end
