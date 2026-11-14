-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/CommunicationRDL.lua

local CallData = require("luaData/CallData")
local NewsData = require("luaData/TopicData")

CommunicationRDL = {}

local Communication_Type = {
	Call = "Call",
	News = "News"
}
local RD_Communication_Branch_Path = {
	Call = "Communication/Call/%d/%d",
	News = "Communication/News/%d/%d"
}

local function GetElement(_config)
	if _config == nil then
		return
	end

	local role = RoleMgr:GetRole(_config.RoleId)

	if role == nil or not role.hold then
		return
	end

	return role.data.Team, role.id
end

local function CommFunc(_tab, _type)
	_tab = _tab or {}

	local configTab = _type == Communication_Type.Call and CallData or NewsData

	for _, id in pairs(_tab) do
		local combId, roleId = GetElement(configTab[id])

		if combId ~= nil and roleId ~= nil then
			RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Communication_Branch_Path[_type], 1, combId, roleId)
		end
	end
end

function CommunicationRDL.InitRD()
	CommFunc(PhoneCallManager.getPhoneList, Communication_Type.Call)
	CommFunc(TopicManager.getTopicList, Communication_Type.News)
end

local function DealFunc(_type1, _type2, _id)
	local configTab = _type1 == Communication_Type.Call and CallData or NewsData
	local num = _type2 == RED_DOT_CHANGE_TYPE.Add and 1 or -1
	local combId, roleId = GetElement(configTab[_id])

	if combId ~= nil and roleId ~= nil then
		RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Communication_Branch_Path[_type1], num, combId, roleId)
	end
end

function CommunicationRDL.AddCall(_id)
	DealFunc(Communication_Type.Call, RED_DOT_CHANGE_TYPE.Add, _id)
end

function CommunicationRDL.RemoevCall(_id)
	DealFunc(Communication_Type.Call, RED_DOT_CHANGE_TYPE.Sub, _id)
end

function CommunicationRDL.AddNews(_id)
	DealFunc(Communication_Type.News, RED_DOT_CHANGE_TYPE.Add, _id)
end

function CommunicationRDL.RemoveNews(_id)
	DealFunc(Communication_Type.News, RED_DOT_CHANGE_TYPE.Sub, _id)
end

return CommunicationRDL
