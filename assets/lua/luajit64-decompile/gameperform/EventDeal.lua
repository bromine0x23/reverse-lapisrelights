-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/EventDeal.lua

EventDeal = class("EventDeal")

function EventDeal:ctor(GP)
	self.GP = GP

	self:Reset()
end

function EventDeal:Reset()
	self.Impluse = nil
	self.IsShowUI = true
end

function EventDeal:Init()
	self:Register()
end

function EventDeal:Purge()
	self:UnRegister()
	self:Reset()
end

function EventDeal:Create()
	FingerGesturesUtil.SetScreenRaycasterCamera(SceneMgr.GetCurrentScene().UnityCamera)
	FingerGesturesUtil.SetScreenRaycasterLayerMask("Actor")
	FingerGesturesUtil.SetScreenRaycasterLayerMask("Nothing")
end

function EventDeal:Register()
	FingerGesturesUtil.Enable()
	EventListenerMgr.AddFingerGestureListener(self.OnTap, self, eFingerGestureType.Tap)
	Event.Instance:Add("EVENT_OPEN_DLG", self.OnOpenDlg, self)
	Event.Instance:Add("EVENT_SWITCH_SCENE", self.OnSwitchScene, self)
	Event.Instance:Add("EVENT_CAMERA_SHAKE", self.OnCameraShake, self)
end

function EventDeal:UnRegister()
	EventListenerMgr.RemoveFingerGestureListener(self.OnTap, self, eFingerGestureType.Tap)
	Event.Instance:Remove("EVENT_OPEN_DLG", self.OnOpenDlg, self)
	Event.Instance:Remove("EVENT_SWITCH_SCENE", self.OnSwitchScene, self)
	Event.Instance:Remove("EVENT_CAMERA_SHAKE", self.OnCameraShake, self)
end

function EventDeal:OnOpenDlg(...)
	self.GP.UI:OpenDlg(...)
end

function EventDeal:OnSwitchScene(val)
	if SceneMgr.GetCurrentScene().ShowScene then
		SceneMgr.GetCurrentScene():ShowScene(val)
	end
end

function EventDeal:OnCameraShake()
	if not self.Impluse then
		local sourceObj = GameObject.Find("[Predeploy]/CameraGrp/ImpluseSource")

		if sourceObj then
			self.Impluse = GOUtil.GetComponent(sourceObj.gameObject, "CinemachineImpulseSource")
		end
	end

	if self.Impluse then
		self.Impluse:GenerateImpulse()
	end
end

function EventDeal:OnTap(gesture)
	self:LiveHideUI()

	if gesture.Selection == nil then
		return
	end

	if self.GP.GameStage ~= EnumFight.GameState.OPERATOR_WAIT then
		return
	end

	for _, unit in ipairs(self.GP.Team.EnemyTeam) do
		for i, col in ipairs(unit.Collider) do
			if col == gesture.Selection then
				Event.Instance:Fire("ReqTargetChange", unit.UniqueId)

				return
			end
		end
	end
end

function EventDeal:LiveHideUI()
	if self.clickTime == nil then
		self.clickTime = 0
	end

	local now = os.clock()
	local t = now - self.clickTime

	if t < 0.3 and self.GP.UI then
		self.GP.UI.DlgUIAuto:OnBtnShowUI()
	end

	self.clickTime = now
end
