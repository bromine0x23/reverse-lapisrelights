-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Network/ServerMsgSend.lua

ServerMsgSend = class("ServerMsgSend")

if not ServerMsgSend.Instance then
	ServerMsgSend.Instance = ServerMsgSend()
end

ServerMsgSend.GroupIdMax = 65536
ServerMsgSend.GroupId = 0

function ServerMsgSend:LogSend(vPBMessage, vGroupId)
	local msgName = type(vPBMessage) == "string" and vPBMessage or tostring(vPBMessage._message_name)
	local msgContent = type(vPBMessage) == "string" and "" or string.sub(tostring(vPBMessage), 1, 200)

	print("<color=gray>Server Send groupId(" .. vGroupId .. ")</color>: " .. msgName .. "\n" .. msgContent, true)
end

function ServerMsgSend:GenerateGroupId()
	self.GroupId = (self.GroupId + 1) % self.GroupIdMax

	return self.GroupId
end

ServerMsgSend.GroupIdToPBMessage = {}

function ServerMsgSend:CachePBMessage(vPBMessage, vGroupId)
	self.GroupIdToPBMessage[vGroupId] = vPBMessage
end

function ServerMsgSend:GetCachedPBMessage(vGroup)
	return self.GroupIdToPBMessage[vGroup]
end

function ServerMsgSend:DeletePBMessage(vGroup)
	self.GroupIdToPBMessage[vGroup] = nil
end

function ServerMsgSend:Close()
	NetworkManager.ConnectorGate.Channel:Close()
end

function ServerMsgSend:SendUseHttpOne(vPBMessage, vGroup, vMsgName, noAuth)
	vGroup = vGroup or self:GenerateGroupId()

	self:LogSend(vPBMessage, vGroup)
	self:CachePBMessage(vPBMessage, vGroup)

	vMsgName = vMsgName or vPBMessage._message_name

	local needAuth = true

	if noAuth then
		needAuth = false
	end

	NetworkManager.RequestHttpOne(vMsgName, vGroup, vPBMessage:SerializeToString(), needAuth)

	local data = {
		group = vGroup,
		msgName = vMsgName,
		noNeedAuth = noAuth
	}

	return data
end

function ServerMsgSend:Send(vPBMessage, vGroup, vMsgName, setTop, noAuth, isRetry)
	vGroup = vGroup or self:GenerateGroupId()

	self:LogSend(vPBMessage, vGroup)
	self:CachePBMessage(vPBMessage, vGroup)

	vMsgName = vMsgName or vPBMessage._message_name

	local needAuth = true

	if noAuth then
		needAuth = false
	end

	NetworkManager.ConnectorGate:Send(vMsgName, vGroup, vPBMessage:SerializeToString(), setTop and true or false, needAuth, isRetry)

	local data = {
		group = vGroup,
		msgName = vMsgName,
		noNeedAuth = noAuth
	}

	return data
end

function ServerMsgSend:SendByName(vMsgName, vGroup, noAuth, isRetry)
	vGroup = vGroup or self:GenerateGroupId()

	self:LogSend(vMsgName, vGroup)
	self:CachePBMessage(vMsgName, vGroup)

	if noAuth then
		-- block empty
	end

	local needAuth = true

	NetworkManager.ConnectorGate:Send(vMsgName, vGroup, nil, false, needAuth, isRetry)

	local data = {
		group = vGroup,
		msgName = vMsgName,
		noNeedAuth = noAuth
	}

	return data
end

function ServerMsgSend:SimulateServerMsg(vMsgName, vPBMessage, vGroupId)
	if self.SimulateServerEvent or self:IsSimulateServerByMessageName(vMsgName) then
		local simulateFunc = self[vMsgName]

		if not simulateFunc then
			error("can not find " .. vMsgName .. " simulate func")

			return true
		end

		local pb = simulateFunc(self, vPBMessage)

		ServerMsgRecv.Instance:HandlePBMessage(pb, vGroupId)

		return true
	end

	return false
end
