-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePlayerInfo/PagePlayerBirthday.lua

PagePlayerBirthday = class("PagePlayerBirthday", UIPanel)

function PagePlayerBirthday:ctor()
	self.UIPrefabPath = "UI/PanelPlayerInfo/PanelPlayerBirthday"
end

function PagePlayerBirthday:PreLoad()
	return
end

function PagePlayerBirthday:Purge()
	self.base.Purge(self)

	if self.avatarFactory then
		self.avatarFactory:Purge()

		self.avatarFactory = nil
	end

	if self.avatarPart then
		self.avatarPart:Destroy()

		self.avatarPart = nil
	end

	if self.Timer then
		TimerMgr.RemoveTimer(self.Timer)

		self.Timer = nil
	end
end

function PagePlayerBirthday:OnRegisterEvent()
	self:AddClick(self.GoClick, self.OnClickedBtnReceive)
end

function PagePlayerBirthday:OnUnRegisterEvent()
	self:RemoveClick(self.GoClick, self.OnClickedBtnReceive)
end

function PagePlayerBirthday:OnEnter(vParam)
	self.combIdx = vParam.combIdx or 1
	self.GoClick = self:GetChildGameObject("Click")

	self:InitData()
end

function PagePlayerBirthday:InitData()
	self.CurScene = SceneMgr:GetCurrentScene()
	self.ListRole = self.CurScene.ListRole
	self.GiftRoleIdx = 1

	for k, role in ipairs(self.ListRole) do
		if role.data.Leader == 1 then
			self.GiftRoleIdx = k
		end
	end

	self.Timer = TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
		self:PlayWithCallback()

		self.Timer = nil
	end, {})
end

function PagePlayerBirthday:PlayBirthdaySendAnim()
	local role = self.ListRole[self.GiftRoleIdx]

	if role ~= nil then
		self:EquipAvatar(role.data.GiftBox, role)
		PlayAnim(eInterctAnimType.birthdaySend, self.CurScene.Actors[self.GiftRoleIdx], role)
	end
end

function PagePlayerBirthday:PlayWithCallback()
	local idx = 0

	local function Play()
		idx = idx + 1

		if idx <= #self.ListRole then
			if not self.CurScene or not self.CurScene.Actors then
				return
			end

			local actor = self.CurScene.Actors[idx]

			globalInterAniState = "idleState"

			PlayAnim(eInterctAnimType.birthdayGift, actor, self.ListRole[idx], Play)
		else
			self:PlayBirthdaySendAnim()
		end
	end

	Play()
end

function PagePlayerBirthday:EquipAvatar(tempId, role, isTemp)
	if not self.CurScene or not self.CurScene.Actors then
		return
	end

	local actor = self.CurScene.Actors[self.GiftRoleIdx]

	local function RequestCb()
		if actor ~= nil and self.avatarFactory ~= nil then
			actor.SkeletonSystem:SetSrpingBoneEnabled(false)

			self.avatarPart = self.avatarFactory:Build()

			actor.AvatarSystem:PutOn(self.avatarPart)
			GOUtil.SetGameObjectLayer(actor.Root, LayerMask.NameToLayer("Actor"))
		end

		LoadingMgr.Hide(eLoadingType.Repeat)
	end

	ResourceMgr.BeginSubmit(RequestCb)

	self.avatarFactory = ActorUtil.BuildAvatarFactory(tempId, role.id)

	self.avatarFactory:Cache()
	ResourceMgr.EndSubmit()
end

function PagePlayerBirthday:OnClickedBtnReceive()
	local function panelCb()
		SceneMgr.LoadScene("MainStage", nil)
	end

	if globalInterAniState ~= "sendGiftToPlayer" then
		return
	end

	local activeId = OperationActiveMgr.GetPlayerBirthdayActiveID()
	local activeIdx = self.combIdx

	if not activeId or activeId == 0 then
		error("ActiveId is not exist. Please Check ...")

		return
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			local infoOperationActive = OperationActiveMgr:Get(activeId)

			if infoOperationActive ~= nil then
				infoOperationActive:ChangeAwardRecords(activeIdx)
			end
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			panelCb()
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestOperationActiveAward(activeId, activeIdx, wrap_cb, panelCb)
end
