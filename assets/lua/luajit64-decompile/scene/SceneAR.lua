-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Scene/SceneAR.lua

require("Scene/SceneBase")

SceneAR = class("SceneAR", SceneBase, true)

local ARMode = {}

function SceneAR.CreateInstance()
	if not SceneAR.Instance then
		SceneAR.Instance = SceneAR()
	end

	return SceneAR.Instance
end

function SceneAR.DestroyInstance()
	SceneAR.Instance = nil
end

function SceneAR:OnInit(vParam)
	if vParam.index == 1 then
		ARMode = require("AR/ARMode_Free")
	elseif vParam.index == 2 then
		ARMode = require("AR/ARMode_Foundation")
	else
		ARMode = require("AR/ARMode_Foundation")
	end

	ARMode:OnInit(vParam)
end

function SceneAR:OnCache()
	SceneMgr.autoHideLoading = true

	ResourceMgr.SubmitCache(ARMode.prefab, self, "SceneARRoot")
end

function SceneAR:OnCreate()
	InfoBGMEventMgr:LoadBank("PageMainStage")

	Input.multiTouchEnabled = true
	self.ARRootInstance = GOUtil.InstantiatePrefab(self.SceneARRoot, nil)

	ARMode:OnCreate(self.ARRootInstance)
	FingerGesturesUtil.SetScreenRaycasterLayerMask("ARDistance")
end

function SceneAR:OnRegisterEvent()
	ARMode:OnRegisterEvent()
end

function SceneAR:OnUnRegisterEvent()
	ARMode:OnUnRegisterEvent()
end

function SceneAR:OnDestroy()
	return
end

function SceneAR:OnPurge()
	Input.multiTouchEnabled = false

	ARMode:ChangeAppOrientation(true)
	ARMode:OnPurge()

	ARMode = nil
end

function SceneAR:OnEnd()
	return
end

function SceneAR:ChangeCameraFacing(frontfacing)
	ARMode:ChangeCameraFacing(frontfacing)
end

function SceneAR:ChangeAppOrientation(horizontal)
	ARMode:ChangeAppOrientation(horizontal)
end

function SceneAR:Exit()
	Event.Instance:Fire("ARChangeAppOrientation", true)
	UIMgr.ShowCommon(DlgCommonEvent.Type.Confirm, _("Tittle_Affirm"), _("Desc_ARSignOut"), function(index)
		if index == 1 then
			self:OnExit()
		end
	end, _("UI_OK"), _("Button_Cancel"))
end

function SceneAR:OnExit()
	self.NotSupport = false

	InfoBGMEventMgr:Clear()
	SoundMgr.SetSwitch(PATH_SCENETYPE_GROUP, PATH_SCENETYPE_HOME, UIMgr.UICamera.gameObject)
	SceneMgr.LoadScene("MainStage", {
		from = 9,
		infoRole = ARMode.infoRole
	})
end

function SceneAR:ToChangeCloth()
	print(ARMode.infoRole)
	InfoBGMEventMgr:Clear()
	SceneMgr.LoadScene("MainStage", {
		from = 3,
		infoRole = ARMode.infoRole
	})
end

function SceneAR:Charator_ShadowOn()
	ARMode:Charator_ShadowOn()
end

function SceneAR:Charator_ShadowOff()
	ARMode:Charator_ShadowOff()
end

function SceneAR:ToggleEyeFollow(isOn)
	ARMode:ToggleEyeFollow(isOn)
end

function SceneAR:OnError(errorStr)
	if Application.isEditor == false then
		UIMgr.ShowCommon(DlgCommonEvent.Type.Loading, _("Tittle_Affirm"), _(errorStr), function(index)
			print(index)

			if index == 1 then
				-- block empty
			else
				self:OnExit()
			end
		end)
	end
end

function SceneAR:OnStateChanged(state)
	if state == -1 then
		self.NotSupport = true

		UIMgr.ShowArPremission(DlgCommonEvent.Type.Loading, _("ARMode_Checking"), function(index)
			self:OnExit()
		end)
	elseif state == 3 then
		self.NotSupport = true

		UIMgr.ShowCommon(DlgCommonEvent.Type.Loading, _("ARMode_Checking"), _("AR_Install"), function(index)
			self:OnExit()
		end)
	elseif state == 4 then
		self.NotSupport = true

		UIMgr.ShowCommon(DlgCommonEvent.Type.Loading, _("ARMode_Checking"), _("AR_Install"), function(index)
			self:OnExit()
		end)
	elseif state >= 5 then
		-- block empty
	else
		self.NotSupport = true

		UIMgr.ShowCommon(DlgCommonEvent.Type.Confirm, _("ARMode_Checking"), _("AR_Unsupported"), function(index)
			self:OnExit()
		end)
	end
end

function SceneAR:OnARStepChanged(step)
	if ARMode ~= nil then
		ARMode:OnARStepChanged(step)
	end
end

function SceneAR:OnBackAndroid()
	if ARMode and ARMode:OnBackAndroid() then
		-- block empty
	else
		self:Exit()
	end
end

return SceneAR
