-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Network/ServerMsgRecv.lua

ServerMsgRecv = class("ServerMsgRecv")

if not ServerMsgRecv.Instance then
	ServerMsgRecv.Instance = ServerMsgRecv()
end

function ServerMsgRecv:LogRecv(vPBMessage, vGroupId)
	print("<color=yellow>Server Recv groupId(" .. vGroupId .. ")</color>: " .. vPBMessage._message_name .. "\n" .. tostring(vPBMessage), true)
end

function ServerMsgRecv:HandlePBMessage(vPBMessage, vGroupId)
	self:LogRecv(vPBMessage, vGroupId)

	local sendPBMessage = ServerMsgSend.Instance:GetCachedPBMessage(vGroupId)

	if not sendPBMessage then
		return
	end

	ServerMsgSend.Instance:DeletePBMessage(vGroupId)
end
