-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/PageConnect.lua

require("Network/NetManager")
require("UI/Page/PageLogin/PageComfirm")

PageConnect = class("PageConnect", UIPanel, true)

function PageConnect:ctor()
	PageConnect.base.ctor(self, "UI/PanelLogin/PanelConnect")
end

function PageConnect:Purge()
	PageConnect.base.Purge(self)
end

function PageConnect:OnPageLoaded()
	return
end

function PageConnect:OnEnter()
	local fxComp = GOUtil.FindChildGameObject(self.UIRootObject, "Eff_UI_Loading_Temp")
end

function PageConnect:OnLeave()
	PageConnect.base.OnLeave(self)
end

function PageConnect:StartConnect()
	GateServer:Connect(NetManager.Host, NetManager.Port)
end

function PageConnect:OnHandleNetworkConnected(vIsSuccess)
	if vIsSuccess then
		local function wrap_cb(...)
			self:OnHandleHandShake(...)
		end

		NetManager:RequestHandShake(wrap_cb)
	end
end

function PageConnect:OnHandleHandShake(vPBMessage)
	if vPBMessage.result.code == NetManager.Result_Sucess then
		UIMgr.SwitchPanel(PageComfirm)
	elseif vPBMessage.result.code == 1 then
		local function wrap_cb(...)
			Launcher.Instance:Quit()
		end
	else
		self:OnHandleNetworkConnected(true)
	end
end

function PageConnect:OnRegisterEvent()
	Event.Instance:AddExclude(EventId.Network.Connected, self.OnHandleNetworkConnected, self)
	self:StartConnect()
end

function PageConnect:OnUnRegisterEvent()
	Event.Instance:RemoveExclude(EventId.Network.Connected, self.OnHandleNetworkConnected)
end
