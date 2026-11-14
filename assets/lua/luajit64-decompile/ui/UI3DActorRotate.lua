-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/UI3DActorRotate.lua

UI3DActorRotate = class("UI3DActorRotate")

function UI3DActorRotate:ctor()
	self.posStart = 0
end

function UI3DActorRotate:OnLeave()
	self:OnUnRegisterEvent()

	self.GoRawImage = nil
end

function UI3DActorRotate:Init(GoRawImage, actor)
	self.actor = actor
	self.GoRawImage = GoRawImage

	self:OnRegisterEvent()
end

function UI3DActorRotate:AddListener(go, callback, triggerType)
	EventListenerMgr.AddUIListener(go, callback, self, triggerType)
end

function UI3DActorRotate:RemoveListener(go, callback, triggerType)
	EventListenerMgr.RemoveUIListener(go, callback, self, triggerType)
end

function UI3DActorRotate:OnRegisterEvent()
	self:AddListener(self.GoRawImage, self.OnBeginDrag, EventTriggerType.BeginDrag)
	self:AddListener(self.GoRawImage, self.OnDrag, EventTriggerType.Drag)
	self:AddListener(self.GoRawImage, self.OnEndDrag, EventTriggerType.EndDrag)
end

function UI3DActorRotate:OnUnRegisterEvent()
	self:RemoveListener(self.GoRawImage, self.OnBeginDrag, EventTriggerType.BeginDrag)
	self:RemoveListener(self.GoRawImage, self.OnDrag, EventTriggerType.Drag)
	self:RemoveListener(self.GoRawImage, self.OnEndDrag, EventTriggerType.EndDrag)
end

function UI3DActorRotate:OnBeginDrag(data)
	self.posBegin = data.position
	self.rotation = self.actor.transform.rotation.eulerAngles
	self.posStart = self.rotation.y
end

function UI3DActorRotate:OnDrag(data)
	local pos = data.position - self.posBegin

	self.posBegin = data.position

	if not RoleMgr.CardFittingLongPress then
		RoleMgr.CardFittingUI3DActorRotate = true
	end

	local add = pos.x / 2

	if add > 10 then
		add = 10
	end

	if add < -10 then
		add = -10
	end

	self.posStart = self.posStart - add

	if RoleMgr.CardFittingLongPress then
		return
	end

	GOUtil.SetTransformRotation(self.actor, self.rotation.x, self.posStart, self.rotation.z)
end

function UI3DActorRotate:OnEndDrag(data)
	RoleMgr.CardFittingUI3DActorRotate = false
	RoleMgr.CardFittingLongPress = false
	self.posStart = 0
end
