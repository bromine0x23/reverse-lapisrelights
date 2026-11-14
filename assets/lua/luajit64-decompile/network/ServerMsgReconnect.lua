-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Network/ServerMsgReconnect.lua

ServerMsgReconnect = class("ServerMsgReconnect")

function ServerMsgReconnect:Init()
	ServerMsgReconnect:_RegisterEvent()
end

function ServerMsgReconnect:OnConnected(vIsSuccess)
	print("<color=green>ServerMsgReconnect:OnConnected</color>")
end

function ServerMsgReconnect:OnDisConnected(vIsSuccess)
	print("<color=red>ServerMsgReconnect:OnDisConnected</color>")
end

function ServerMsgReconnect:_RegisterEvent()
	Event.Instance:Add(EventId.Network.Connected, self.OnConnected, self)
	Event.Instance:Add(EventId.Network.DisConnected, self.OnDisConnected, self)
end

function ServerMsgReconnect:_UnRegisterEvent()
	Event.Instance:Remove(EventId.Network.Connected, self.OnConnected)
	Event.Instance:Remove(EventId.Network.DisConnected, self.OnDisConnected, self)
end

ServerMsgReconnect.Instance = ServerMsgReconnect.Instance or ServerMsgReconnect()
