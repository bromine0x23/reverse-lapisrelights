-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/PageComfirm.lua

require("Network/NetManager")
require("Info/InfoLevel")

PageComfirm = class("PageComfirm", UIPanel, true)

function PageComfirm:ctor()
	PageComfirm.base.ctor(self, "UI/PanelLogin/PanelConfirm")
end

function PageComfirm:Purge()
	PageComfirm.base.Purge(self)
end

function PageComfirm:OnPageLoaded()
	return
end

function PageComfirm:OnEnter()
	local fxComp = GOUtil.FindChildGameObject(self.UIRootObject, "Eff_UI_Loading_Temp")

	self.PanelTip = self:GetChildGameObject("PanelTip")

	ChapterMgr:InitChapterList()
	self:RequestLogin()
end

function PageComfirm:OnLeave()
	PageComfirm.base.OnLeave(self)
end

function PageComfirm:OnRegisterEvent()
	return
end

function PageComfirm:OnUnRegisterEvent()
	return
end

function PageComfirm:OnCheckVersion(vPBMessage)
	if vPBMessage.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	self:RequestLogin()
end

function PageComfirm:RequestLogin()
	local function wrap_cb(...)
		self:OnLogin(...)
	end

	NetManager:RequestLogin(wrap_cb)
end

function PageComfirm:OnLogin(vPBMessage)
	if self.timerLogin ~= nil then
		TimerMgr.RemoveTimer(self.timerLogin)
	end

	if vPBMessage.result.code == NetManager.Result_Sucess then
		self:RequestGetPlayer()
	elseif vPBMessage.result.code == NetManager.Result_Timeout then
		TimerMgr.AddTimer(eTimerType.RealTime, 10, function()
			self:RequestLogin()
		end, {
			1
		})
	end
end

function PageComfirm:RequestGetPlayer()
	local function wrap_cb(...)
		self:OnGetPlayerInfo(...)
	end

	NetManager:RequestGetPlayerInfo(wrap_cb)
end

function PageComfirm:OnGetPlayerInfo(vPBMessage)
	local code = vPBMessage.result.code
	local sceneName = "MainStage"

	if code == NetManager.Result_Sucess then
		InstructionMgr:End()
		self:DealWithSpot()
		SDKMgr.GetInstance():NotifyZone(PlayerInst.InfoPlayer.pid, PlayerInst.InfoPlayer.name)
	elseif code == 2 then
		self:DealWithSpot()
		SDKMgr.GetInstance():NotifyZone(PlayerInst.InfoPlayer.pid, PlayerInst.InfoPlayer.name)
	else
		print("OnGetPlayerInfo err: " .. vPBMessage.result.desc)
		self:RequestGetPlayer()
	end
end

function PageComfirm:DealWithSpot()
	if not InstructionMgr.isOpen or PlayerInst.InfoPlayer.newbieProgress == 1 then
		SceneMgr.LoadScene("MainStage", nil)
	else
		InstructionMgr:Start()
		GuideFlow.Start()
	end
end

function PageComfirm:DealWithSpotIOS()
	local guidePassed = PlayerPrefs.GetInt("GuidePassed", 0)

	print("guidePassed:" .. tostring(guidePassed))

	if not InstructionMgr.isOpen or PlayerInst.InfoPlayer.newbieProgress == 1 then
		if AppConst.AssetBundleMode and guidePassed == 0 then
			InstructionMgr.UpdateAfterGuide()

			return
		end

		SceneMgr.LoadScene("MainStage", nil)

		return
	end

	InstructionMgr:Start()
	print("DealWithSpot~~~~~~~~~~~~~~~~~")
	print(InstructionMgr.getSpot)

	if InstructionMgr.getSpot then
		print("AppConst.AssetBundleMode" .. tostring(AppConst.AssetBundleMode))

		if AppConst.AssetBundleMode and guidePassed == 0 then
			InstructionMgr.UpdateAfterGuide()

			return
		end
	end

	GuideFlow.Start()
end
