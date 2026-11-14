-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Network/GateServer.lua

require("Info/Player")
require("Network/ServerMsgSend")
require("Network/ServerMsgRecv")

GateServer = {}
GateServer.ReconnectAccCount = 0
GateServer.MaxReconnectCount = 3
GateServer.Reconnecting = false
GateServer.IsServerError = false
GateServer.CanReConnect = true
GateServer.IsShowUpdate = false

function GateServer:OnConnect(is_succ, brief, cnt)
	if not is_succ then
		return
	end

	GateServer.IsConnect = is_succ

	Event.Instance:Fire(EventId.Network.Connected, is_succ)

	if is_succ then
		ServerMsgSend.Instance:SendByName("P9000_Request")

		self.Reconnecting = false
	end
end

function GateServer:OnDisconnect(vIsSuccess, vBrief, vChl)
	if Time.realtimeSinceStartup - self.TimeSince < 2 then
		return
	end

	print("Disconnect " .. tostring(vIsSuccess) .. " " .. vBrief)

	self.Reconnecting = true
	GateServer.IsConnect = false

	if GateServer.IsServerError then
		return
	end

	self.TimeSince = Time.realtimeSinceStartup

	Event.Instance:Fire(EventId.Network.DisConnected, vIsSuccess)
	TimerMgr.AddTimer(eTimerType.RealTime, 3, function()
		print("TryReConnect")
		self:Connect()
	end, {})
end

function GateServer:OnServerError(reason)
	print("on server error >>>>>>>>>>>>>>>>>>>>>>>")

	if GateServer.IsServerError then
		return
	end

	if reason == NetworkManager.ERROR_RES_VER then
		local guidePassed = PlayerPrefs.GetInt("GuidePassed", 0)

		if guidePassed == 0 or BackKeyMgr:IsInGameScene() then
			return
		end
	end

	ClearWebTimeout()

	if reason == NetworkManager.ERROR_SIGN or reason == NetworkManager.ERROR_KICKOFF or reason == NetworkManager.ERROR_SERVER_ERROR or reason == NetworkManager.ERROR_HTTP1_ERROR then
		UIMgr.ShowDialog(_("PagePlatform_error_description"), function()
			Launcher.Instance:Restart()
		end)

		GateServer.IsServerError = true
	elseif reason == NetworkManager.ERROR_CAUTION then
		UIMgr.ShowDialog("警告")
	elseif reason == NetworkManager.ERROR_RES_VER then
		local function wrap_cb()
			Launcher.Instance:Restart()
		end

		if not GateServer.IsShowUpdate then
			UIMgr.ShowDialog("更新の必要なデータを確認しました\nダウンロード後、タイトル画面に戻ります", wrap_cb)

			GateServer.IsShowUpdate = true
		end
	elseif reason == NetworkManager.ERROR_MAINTAIN then
		GateServer.IsServerError = true
	end
end

local m_dgt_on_connect, m_dgt_on_disconnect, m_dgt_on_server_error
local m_obs_list = {}

function GateServer:Init()
	self.ReconnectAccCount = 0
	self.TimeSince = Time.realtimeSinceStartup
	m_dgt_on_connect = Event.Instance:AddDelegate(Dispatcher.Instance, "OnConnect", self.OnConnect, self)
	m_dgt_on_disconnect = Event.Instance:AddDelegate(Dispatcher.Instance, "OnDisconnect", self.OnDisconnect, self)
	m_dgt_on_server_error = Event.Instance:AddDelegate(Dispatcher.Instance, "OnServerError", self.OnServerError, self)
	GateServer.IsServerError = false
end

function GateServer:Shutdown()
	Event.Instance:RemoveDelegate(m_dgt_on_connect)
	Event.Instance:RemoveDelegate(m_dgt_on_disconnect)
	Event.Instance:RemoveDelegate(m_dgt_on_server_error)

	m_dgt_on_connect = nil
	m_dgt_on_disconnect = nil
	m_dgt_on_server_error = nil
	NetStateLogin = false
end

function GateServer:Connect(vIP, vPort)
	self.CacheIP = vIP or self.CacheIP
	self.CachePort = vPort or self.CachePort

	if self.CacheIP == nil or self.CachePort == nil then
		return
	end

	NetworkManager.ConnectorGate:Connect(self.CacheIP, tonumber(self.CachePort))
end

function GateServer:Disconnect()
	NetStateLogin = false

	NetworkManager.ConnectorGate:Disconnect()
end

function GateServer:DisconnectKC()
	NetworkManager.ConnectorGate:Disconnect("timeout mupile times")
end

return GateServer
