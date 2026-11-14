-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Network/NetManager.lua

require("protobuf/protobuf")
require("PB/Protos/protocol_pb")
require("Network/ServerMsgReconnect")
require("Network/NetData")
require("Info/SetterData")
require("Info/InstructionMgr")
require("Info/InfoGameExtra")
require("Info/AttributeAgent")
require("Info/InfoCombination")
require("Info/InfoRole")
require("Info/InfoRoleCard")
require("Info/InfoItem")
require("Info/InfoWork")
require("Info/InfoMail")
require("Info/InfoTheme")
require("Info/InfoActive")
require("Info/InfoFriend")
require("Info/InfoRank")
require("Info/PassMgr")
require("Info/InfoOperationActive")
require("Info/InfoShop")
require("Manager/SDKMgr")
require("Util/Util")
require("UI/Dlg/Common/DlgGetAward")
require("UI/Dlg/Public/DlgProducerLevelUp")
require("Network/SimulateData")

local InfoTeam = require("Info/InfoTeam")

require("RedDot/RedDotSystemMgr")
require("Info/SystemMaintainMgr")

NetManager = {}
NetManager.buildId = 26993
NetManager.RES_VER_NUM = "0"
NetManager.DebugSysTime = 0
OpenAllActive = true
OpenAllLock = true
NoPay = false
NetManager.strDominOuter = PlayerPrefs.GetString("endpoint_host", "http://10.203.6.44:10085")
NetManager.IsUseSDK = false
TEST_VER = not AppConst.SDKMode
strDominOuter = "http://t1srv.lapis.ozgame.cn:20098"
strDominOuter = "http://109.244.4.100:8080"
NetManager.desKey = "FWvYxycnu2mEb3b8VMZvVhv6"
OpenAllActive = true
OpenActive = OpenAllActive
OpenLimitActive = OpenAllActive
OpenAD = OpenAllActive
OpenSmallShop = OpenAllActive
OpenCodeChange = OpenAllActive
NetManager.simulate = false
NetManager.authorizeId = 0
NetManager.channel = 10
NetManager.clientGroup = "DREAM"
NetManager.version = UnityEngine.Application.version .. "." .. NetManager.buildId
NetManager.Host = PlayerPrefs.GetString("endpoint_host", Kc.Config.KcAppSetting.ApiEndPoint)
NetManager.Port = PlayerPrefs.GetInt("endpoint_port", Kc.Config.KcAppSetting.ApiPort)
NetManager.TListCallback = {}
NetManager.TListTimeIds = {}
NetManager.Result_Timeout = -999
NetManager.Result_Sucess = 0
NetManager.SurveyUrl = nil
NetManager.NoticeTxt = "test-notice"
NetManager.IsUseInterServer = false
NetStateFobidReconnect = false
NetManager.SkillNodeDefaultIndex = 9998
NetManager.Result_Maintain = 1002

local TIME_OUT_SECOND = 10

NetManager.strDominInter = PlayerPrefs.GetString("endpoint_inner", "http://devsrv.lapis.ozgame.cn:10085")

local reconnectVerify = ""
local pushToken = ""

NetManager.SIndex = 3
NetManager.NIndex = 3

function NetManager:GetServerListDomin()
	local strList = "/platform/ServerList.do"
	local strDomin = self.strDominInter

	if self.IsUseInterServer then
		strDomin = self.strDominInter
	else
		strDomin = self.strDominOuter
	end

	if NetManager.IsUseSDK then
		return ""
	end

	return strDomin .. strList
end

function NetManager:GetDominOuter()
	return self.strDominOuter
end

function NetManager:GetServerList(callback, selfObject)
	local cid = ""
	local subid = ""
	local pToken = NetManager.SDKToken
	local channel = 1

	if NetManager.IsUseSDK then
		cid = OzSDKManager.Instance:GetSuperChannelId()
		subid = OzSDKManager.Instance:GetAppId()
		channel = 3
	end

	print("OnGetLoginInfo6666666~~~~~~~~~~~")

	local OnGetServerList = wrapedCb(callback, selfObject)

	NetworkManager.GetServerList(self:GetServerListDomin(), channel, NetManager.authorizeId, NetData:GetCurTimeMillis(), cid, subid, pToken, OnGetServerList)

	NetManager.SIndex = NetManager.SIndex - 1

	if NetManager.SIndex < 1 then
		NetManager.SIndex = 3
	end
end

function NetManager:GetServerNotice(callback, selfObject)
	local strPath = ""
	local OnGetServerList = wrapedCb(callback, selfObject)

	NetworkManager.GetServerNotice(strPath, OnGetServerList)

	NetManager.NIndex = NetManager.NIndex - 1

	if NetManager.NIndex < 1 then
		NetManager.NIndex = 3
	end
end

function NetManager:Init()
	if not Kc.Config.KcAppSetting.EnabledDebugMenu then
		OpenAllLock = false
		InstructionMgr.isOpen = true
	end

	NetManager:RegisterEvent()
	ServerMsgReconnect.Instance:Init()
end

function NetManager:UnRegisterEvent()
	return
end

function Restart()
	local obj = ResourceMgr.LoadSync("UI/Common/ClearCamera", GameObject)

	GOUtil.InstantiatePrefab(obj, nil)

	NetStateFobidReconnect = true

	Launcher.Instance:Restart()
end

function DealWithGetAward(pbSetter, fromMail, panelCb)
	local setter = SetterData.GetSetterData(pbSetter)

	setter:Parse()

	local wrap_cb

	if SetterData.showLevelup then
		function wrap_cb()
			UIMgr.AddPanel(DlgProducerLevelUp(), {
				callback = panelCb
			})
		end
	else
		wrap_cb = panelCb
	end

	local listNormal = setter:Getlist(protocol_pb.AF_NORMAL)
	local listExtra = setter:Getlist(protocol_pb.AF_EXTRA_AWARD)

	if #listNormal > 0 or #listExtra > 0 then
		local data = {
			list = setter.list,
			callback = wrap_cb,
			fromMail = fromMail
		}

		if OperationActiveMgr.IsActiveCommon then
			OperationActiveMgr.IsActiveCommon = TimerMgr.AddTimer(eTimerType.RealTime, 0.5, function()
				TimerMgr.RemoveTimer(OperationActiveMgr.IsActiveCommon)

				OperationActiveMgr.IsActiveCommon = nil

				Event.Instance:Fire("DlgOperationActiveCommonOneCloseEvent")
				UIMgr.AddPanel(DlgGetAward.GetInstance(), data)
			end, nil)
		else
			if #NetEncapManager.goodsItemList > 0 then
				data.goodsItemList = {}

				for _, value in ipairs(NetEncapManager.goodsItemList) do
					table.insert(data.goodsItemList, value)
				end
			end

			if #TaskManager.battlePassPayList > 0 then
				data.battlePassPayList = {}

				for _, value in ipairs(TaskManager.battlePassPayList) do
					table.insert(data.battlePassPayList, value)
				end
			end

			UIMgr.AddPanel(DlgGetAward.GetInstance(), data)
		end
	end
end

function ShowFuncForbidDialog()
	local function OnCallback(index)
		if index == 4 then
			Restart()
		elseif index ~= 5 or UIMgr.GetCurPanel().className == "PageMainStage" then
			-- block empty
		else
			SceneMgr.LoadScene("MainStage")
		end
	end

	UIMgr.ShowCommon(DlgCommonEvent.Type.MsgFuncForbid, _("Desc_Alert"), _("Desc_FuncFobid"), OnCallback)
end

function DealWithGetAwardKc(pbSetter)
	local setter = SetterData.GetSetterData(pbSetter)

	setter:Parse()

	local wrap_cb

	if SetterData.showLevelup then
		function wrap_cb()
			UIMgr.AddPanel(DlgProducerLevelUp(), {
				callback = panelCb
			})
		end
	else
		wrap_cb = nil
	end

	local listNormal = setter:Getlist(protocol_pb.AF_NORMAL)
	local listExtra = setter:Getlist(protocol_pb.AF_EXTRA_AWARD)

	if #listNormal > 0 or #listExtra > 0 then
		local data = {
			fromMail = false,
			list = setter.list,
			callback = wrap_cb
		}

		if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
			PlayerPrefs.SetString("BuyCachedData", EncodeData(setter.list))
		else
			UIMgr.AddPanel(DlgGetAward.GetInstance(), data)
		end
	end
end

function EncodeData(list)
	local result = {}

	for i = 1, #list do
		local v = list[i]
		local tmp = {}

		tmp.from = v.from
		tmp.num = v.num
		tmp.asset = v.asset

		table.insert(result, tmp)
	end

	return jsonParser.encode(result)
end

function NetManager.CheckCachedBuyItemPop()
	local cachedBuyData = PlayerPrefs.GetString("BuyCachedData", nil)

	if cachedBuyData ~= nil and cachedBuyData ~= "" then
		UIMgr.AddPanel(DlgGetAward.GetInstance(), {
			list = jsonParser.decode(cachedBuyData)
		})
		PlayerPrefs.DeleteKey("BuyCachedData")
	end
end

function NetManager:RequestHeartDump()
	ServerMsgSend.Instance:SendByName("P10000_Request")
end

function OnReceiveHeartShake(vMsg)
	local pb = protocol_pb.P10000_Response()

	pb:ParseFromString(vMsg.BodyString)
	SystemMaintainMgr:Init(pb.protocols)
end

function NetManager:RequestHandShake(callback)
	local vPBMessage = protocol_pb.P0_Request()

	printTable(vPBMessage)

	vPBMessage.deviceOs = SystemInfoUtil.operatingSystem
	vPBMessage.deviceName = SystemInfoUtil.deviceModel
	vPBMessage.deviceId = SystemInfoUtil.deviceUniqueIdentifier
	vPBMessage.netType = tostring(Application.internetReachability)
	vPBMessage.appVersion = Launcher.Instance:GetAppVer()
	vPBMessage.resVersion = Launcher.Instance:GetResVer()
	vPBMessage.debugSysTime = NetManager.DebugSysTime

	NetworkManager.ConnectorGate:SetEncryptType(0)

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

NEED_TIMEOUT_LOADING_CLEAR = {
	"P1000_Request",
	"P1001_Request",
	"P1006_Request"
}
NEED_DOUBLE_TIMEOUT = {
	"P1006_Request"
}
TimerOutDic = {
	call_time = 0,
	count = 0
}
TimerOutCBList = {}

function TimerOutDeal(params)
	local pb = {}

	pb.result = {}
	pb.result.code = NetManager.Result_Timeout
	pb.result.desc = _("Desc_NetTimerOut")

	local vGroup = params[1]
	local vMsg = params[2]
	local callback = NetManager.TListCallback[vGroup].cb
	local noAuth = NetManager.TListCallback[vGroup].noAuth
	local vExtra = NetManager.TListCallback[vGroup].extra

	NetManager.TListCallback[vGroup] = nil

	LoadingMgr.Hide(eLoadingType.Repeat)

	if vMsg ~= nil then
		if not GateServer.IsServerError then
			local function resend_cb()
				local group

				LoadingMgr.Show(eLoadingType.Repeat)

				if type(vMsg) == "string" then
					group = ServerMsgSend.Instance:SendByName(vMsg, vGroup, noAuth, true)
				else
					group = ServerMsgSend.Instance:Send(vMsg, vGroup, nil, false, noAuth, true)

					if vExtra then
						group.extra = vExtra
					end
				end

				SetCallback(group, callback, vMsg)
			end

			local function wrap_cb(index)
				if index == 1 then
					for i = 1, #TimerOutCBList do
						TimerOutCBList[i]()
					end

					table.clear(TimerOutCBList)
				elseif index == 2 then
					Launcher.Instance:Restart()
				end
			end

			local msgName = type(vMsg) == "string" and vMsg or tostring(vMsg._message_name)

			if table.contains(NEED_TIMEOUT_LOADING_CLEAR, msgName) then
				print("[HIDE NOW]TIMEOUT")
				LoadingMgr.Hide(eLoadingType.Repeat)
			end

			local curr_time = NetData:GetCurServerTime() / 1000

			if curr_time - TimerOutDic.call_time < TIME_OUT_SECOND * 2 then
				if curr_time - TimerOutDic.call_time >= TIME_OUT_SECOND then
					TimerOutDic.count = TimerOutDic.count + 1

					if TimerOutDic.count > 2 then
						GateServer:DisconnectKC()
					end
				end
			else
				TimerOutDic.count = 1
			end

			if TimerOutDic.count >= 4 then
				if not TimerOutDic.IsTimeOutBlock then
					UIMgr.ShowCommonKc(DlgCommonEvent.Type.Msg, _("Desc_Alert"), "接続がタイムアウトしました、\nリトライしてください", function()
						Restart()
					end, nil, nil, false)

					TimerOutDic.IsTimeOutBlock = true
				end
			else
				table.insert(TimerOutCBList, resend_cb)

				if #TimerOutCBList <= 1 then
					TimerOutDic.call_time = NetData:GetCurServerTime() / 1000

					wrap_cb(1)
				end
			end
		end
	else
		print("接続タイムアウト")

		if callback ~= nil and not GateServer.IsServerError then
			callback(pb)
		end
	end
end

function SetCallback(data, callback, vMsg)
	local vGroup = data.group
	local vMsgName = data.msgName

	if NetManager.simulate then
		SimulateResponse(callback, vMsgName)

		return
	end

	NetManager.TListCallback[vGroup] = {
		cb = callback,
		extra = data.extra,
		noAuth = data.noNeedAuth
	}

	local timeOut = table.contains(NEED_DOUBLE_TIMEOUT, vMsgName) and TIME_OUT_SECOND * 2 or TIME_OUT_SECOND

	NetManager.TListTimeIds[vGroup] = TimerMgr.AddTimer(eTimerType.RealTime, timeOut, TimerOutDeal, {
		vGroup,
		vMsg
	})
end

function GetCallback(pb, vMsg)
	pb:ParseFromString(vMsg.BodyString)
	ServerMsgRecv.Instance:HandlePBMessage(pb, vMsg.Group)

	local cb = NetManager.TListCallback[vMsg.Group].cb
	local extraData = NetManager.TListCallback[vMsg.Group].extra

	NetManager.TListCallback[vMsg.Group] = nil

	return cb, extraData
end

function ClearWebTimeout()
	for k, v in pairs(NetManager.TListCallback) do
		local timeID = NetManager.TListTimeIds[k]

		if timeID then
			TimerMgr.RemoveTimer(timeID)
			LoadingMgr.Hide(eLoadingType.Repeat)
		end

		NetManager.TListTimeIds[k] = nil
	end

	NetManager.TListCallback = {}
end

function DealWithTimeout(vMsg)
	if NetManager.TListTimeIds[vMsg.Group] ~= nil then
		local timeId = NetManager.TListTimeIds[vMsg.Group]

		TimerMgr.RemoveTimer(timeId)
	end

	local result = false

	if NetManager.TListCallback[vMsg.Group] == nil then
		result = true
	end

	return result
end

function OnRecvHandShackRes(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P0_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		if pb.isEncrypt then
			NetworkManager.ConnectorGate:SetEncryptType(1)
		end

		NetworkManager.ConnectorGate.EncryptKey = pb.encryptKey
	end

	if pb.result.code == 2 then
		ServerMsgSend:Close()
		print("11host:" .. NetManager.Host .. " port:" .. NetManager.Port)

		NetManager.Host = pb.redirectHost
		NetManager.Port = pb.redirectPort

		print("22host:" .. NetManager.Host .. " port:" .. NetManager.Port)

		GateServer.CacheIP = NetManager.Host
		GateServer.CachePort = NetManager.Port

		return
	end

	DateUtil.ServerTimeZone = pb.logicZoneOffset
	NetManager.showZoneOffset = pb.showZoneOffset

	print("pb.logicZoneOffset:" .. pb.logicZoneOffset)
	print("pb.showZoneOffset:" .. pb.showZoneOffset)
	NetData:SetServerTime(pb.sysTime, pb.sysTimeOffset)
	fun(pb)
end

function NetManager:RequestCheckVersion(callback)
	local vPBMessage = protocol_pb.P1_Request()

	vPBMessage.group = NetManager.clientGroup
	vPBMessage.version = NetManager.version
	vPBMessage.txtSign = CryptographyUtil.GetMd5(vPBMessage.version, 0)

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvCheckVersionRes(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:RequestSubmitPlayerInfo(nType, strNickname, isDebug, callback)
	local vPBMessage = protocol_pb.P12_Request()

	vPBMessage.type = nType
	vPBMessage.nickname = strNickname
	vPBMessage.advanced = isDebug

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSubmitPlayerInfo(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P12_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:RequestLogin(callback)
	local vPBMessage = protocol_pb.P2_Request()

	vPBMessage.pushId = "1"
	vPBMessage.resSign = NetManager.RES_VER_NUM

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvLogin(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P2_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)

	PlayerInst.InfoPlayer.pid = pb.playerId

	if pb.result.code == 5 then
		local function wrap_cb(index)
			PlayerPrefs.SetInt("GuidePassed", 1)
			Restart()
		end

		UIMgr.ShowDialog(pb.result.desc, wrap_cb, pb)
	elseif pb.result.code ~= 0 then
		local function wrap_cb(...)
			Restart()
		end

		UIMgr.ShowDialog(pb.result.desc, wrap_cb, pb)
	end

	if pb.result.code == 0 then
		NetStateLogin = true

		local listOpenActive = OperationActiveMgr:Get(OperationActiveMgr:GetTotalOnlineInfo().ID)

		local function wrap_cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vMsg.result.code == NetManager.Result_Sucess then
				listOpenActive:SetData(vMsg.activeOperates[1])
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestActiveOperates({
			listOpenActive.data.ID
		}, wrap_cb)
	end
end

function NetManager:RequestLogout(type, callback)
	local vPBMessage = protocol_pb.P3_Request()

	vPBMessage.type = type

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvLogout(vMsg)
	local pb = protocol_pb.P3_Response()

	pb:ParseFromString(vMsg.BodyString)
	ServerMsgRecv.Instance:HandlePBMessage(pb, vMsg.Group)
	Event.Instance:Fire("DisconnectEvent")

	if pb.type == 2 then
		NetStateFobidReconnect = true

		local function wrap_cb(...)
			if SDKMgr.Instance ~= nil and NetManager.IsUseSDK then
				SDKMgr.Instance:Logout(wrap)
				Restart()
			else
				Restart()
			end

			NetStateFobidReconnect = false
		end

		UIMgr.ShowDialog(_("P3_Response_2"), wrap_cb)
	end
end

function OnRecvCommand(vMsg)
	local pb = protocol_pb.P4_Response()

	pb:ParseFromString(vMsg.BodyString)
	ServerMsgRecv.Instance:HandlePBMessage(pb, vMsg.Group)
	Event.Instance:Fire("DisconnectEvent")

	if pb.result.code == 1 then
		local function wrap_cb(...)
			NetStateFobidReconnect = true

			Restart()
		end

		PlayerPrefs.SetInt("GuidePassed", 1)
		UIMgr.ShowDialog(_("P4_Response_1"), wrap_cb, pb)

		NetStateFobidReconnect = false
	elseif pb.result.code == 2 then
		local function wrap_cb(...)
			return
		end

		UIMgr.ShowDialog(pb.result.desc, wrap_cb, pb)
	elseif pb.result.code == 3 then
		local function wrap_cb(...)
			NetStateFobidReconnect = true

			Restart()
		end

		UIMgr.ShowDialog(_("P4_Response_3"), wrap_cb, pb)

		NetStateFobidReconnect = false
	end
end

function NetManager:RequestGetBasePlayerInfo(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P9_Request")

	SetCallback(vGroup, callback, "P9_Request")
end

function OnRecvGetBasePlayerInfo(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P9_Response()
	local fun = GetCallback(pb, vMsg)

	ChapterMgr:SetData(pb.chapters)
	InfoGameInst:SetData(pb.gameInfo)
	PlayerInst:SetFriendHelpInfo(pb.workTaskHelpers)

	PlayerInst.pbFriendHelpTimeReset = pb.workTaskHelperTime

	ChatMgr:SetData()
	WorkTaskManager:SetWorkTaskState(pb.workTasks)
	LiveManager:SetSupportRecord(pb.supportRecords)
	VoteDatasManager:GetList()

	PlayerInst.giveGiftFriends = pb.giveGiftFriends
	PlayerInst.giveGiftTime = pb.giveGiftTime
	PlayerInst.giveGiftCount = pb.giveGiftCount
	PlayerInst.loadSongRoleIds = pb.loadSongRoleIds

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	fun(pb)
end

function ReloadGameData(cb)
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess or vPBMessage.result.code == 2 then
			cb()
		else
			ReloadGameData(cb)
		end
	end

	NetManager:RequestGetPlayerInfo(wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function NetManager:RequestGetPlayerInfo(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P11_Request")

	SetCallback(vGroup, callback, "P11_Request")
end

function OnRecvGetPlayerInfo(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P11_Response()
	local fun = GetCallback(pb, vMsg)

	PlayerInst.InfoPlayer:SetData(pb.player)
	BackTraceKcSupport.SetUserIdAndVer(pb.player.playerId)

	PlayerInst.InfoPlayer.billingState = pb.billingState

	local roleCards = pb.roleCards

	for i = 1, #roleCards do
		local pbRoleCard = roleCards[i]
		local infoRoleCard = RoleCardMgr:GetRoleCard(pbRoleCard.id)

		infoRoleCard:SetData(pbRoleCard)
	end

	local roles = pb.roles

	for i = 1, #roles do
		local pbRole = roles[i]
		local infoRole = RoleMgr:GetRole(pbRole.id)

		if pbRole.id and pbRole.id > 0 then
			infoRole:SetData(pbRole)
		end
	end

	if pb.clubRefresh ~= nil then
		local state = false

		if pb.clubRefresh.wishStatus == 1 then
			state = true
		end

		UnionWishRecvMgr:ChangeCanReceiveState(state)
	end

	InfoGameInst:SetData(pb.gameInfo)
	InfoGameInst:SetRefreshData(pb.gameRefresh)
	ItemManager:SetData(pb.items)
	PowerMgr.Instance:SetPowerTime(pb.player.powerAt)

	for i = 1, #pb.themes do
		local pbTheme = pb.themes[i]
		local infoTheme = ThemeManager:Get(pbTheme.id)

		infoTheme:SetData(pbTheme)
	end

	InfoGameInst:SetOpenServerTime(pb.gameInfo.openServerTime)
	InfoGameInst:SetFriendHelpTimes(pb.gameRefresh.friendHelpTimes)
	InfoGameInst:SetOnlineTime(pb.player.onlineTime)

	local adslist = {}

	for i = 1, #pb.ads do
		table.insert(adslist, pb.ads[i])
	end

	InfoGameInst:TipWindowAdsListSort()
	InstructionMgr:SetData(pb.gameInfo.guides)
	PassMgr:Init()
	OptionDownMgr:Init()
	ActiveMgr:SetTimeLimitItemData()
	require("Info/InfoCardPool")
	CardPoolManager:SetTimeLimitItemData()
	fun(pb)

	if not NetStateFobidReconnect and NetStateLogin then
		NetManager:RequestHeartDump()
	end

	RedDotSystemMgr:Init()
	ReTimeMgr:Init()
end

function NetManager:RequestModifyPlayerInfo(vals, callback)
	local vPBMessage = protocol_pb.P13_Request()

	for k, v in pairs(vals) do
		if k == "roleCards" then
			for i = 1, #v do
				table.insert(vPBMessage.roleCards, v[i])
			end
		elseif k == "favoriteRoles" then
			for i = 1, #v do
				table.insert(vPBMessage.favoriteRoles, v[i])
			end
		else
			vPBMessage[k] = v
		end
	end

	NetManager.params = vals

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvModifyPlayerInfo(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P13_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()

		if NetManager.params then
			if NetManager.params.nickname ~= nil then
				InfoGameInst:ChangeRenameNum(1)
				PlayerInst:ChangeNickName(NetManager.params.nickname)
			elseif NetManager.params.signature ~= nil then
				PlayerInst:ChangeSignature(NetManager.params.signature)
			elseif NetManager.params.showRole ~= nil then
				PlayerInst:SetShowRole(NetManager.params.showRole)
			elseif NetManager.params.birthday ~= nil then
				PlayerInst:ChangeBirthday(NetManager.params.birthday)
			end
		end
	end

	NetManager.params = nil

	fun(pb)
end

function NetManager:RequestTalentUpLevel(roleCardId, starTalentId, callback)
	local vPBMessage = protocol_pb.P16_Request()

	vPBMessage.roleCardId = roleCardId
	vPBMessage.starTalentId = starTalentId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvTalentUpLevel(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P16_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function PrintSetter(setter, descContent)
	if setter == nil then
		return
	end

	for i = 1, #setter do
		local s = setter[i]

		print(string.format("<color=yellow> [%s] from[%s] asset[%d] id[%d] num[%d] </color>", descContent, tostring(s.from), s.asset, s.id, s.num))
	end
end

function NetManager:RequestOperateItem(roleCardId, listCostItem, callback)
	local vPBMessage = protocol_pb.P14_Request()

	vPBMessage.roleCardId = roleCardId

	for i = 1, #listCostItem do
		table.insert(vPBMessage.costItems, listCostItem[i])
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvOperateItem(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P14_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestUpgradeRoleStar(nRoleCardID, callback)
	local vPBMessage = protocol_pb.P15_Request()

	vPBMessage.roleCardId = nRoleCardID

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvUpgradeRoleStar(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P15_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestRoleCardStarAward(roleCardId, starLevel, callback)
	local vPBMessage = protocol_pb.P17_Request()

	vPBMessage.roleCardId = roleCardId
	vPBMessage.starLevel = starLevel

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvRoleCardStarAward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P17_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		DealWithGetAward(pb.setter)
	end

	fun(pb)
end

function NetManager:RequestDevelopAll(roleId, type, callback)
	local vPBMessage = protocol_pb.P19_Request()

	for i = 1, #type do
		table.insert(vPBMessage.type, type[i])
	end

	vPBMessage.roleId = roleId
	NetManager.P19_RoleId = roleId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvDevelopAll(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P19_Response()
	local fun = GetCallback(pb, vMsg)
	local cb

	if pb.result.code == 0 then
		function cb()
			local setter = SetterData.GetSetterData(pb.setter)

			setter:Parse()
			ManualRDL.NotesRDL.DealTask(NetManager.P19_RoleId)
			CharacterThinMgr.ResetInterface(THIN_SYSTEM_TYPE.Role, nil, nil, nil, nil, true)
		end
	end

	fun(pb)

	if cb then
		cb()
	end

	NetManager.P19_RoleId = nil

	Event.Instance:Fire("UpdateEquipAfterDevelop")
end

function NetManager:RequestEquipIntense(_type, roleId, slot, upLevel, callback)
	local vPBMessage = protocol_pb.P20_Request()

	vPBMessage.type = _type
	vPBMessage.roleId = roleId
	vPBMessage.slot = slot
	vPBMessage.upLevel = upLevel
	NetManager.P20_RoleId = roleId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvEquipIntense(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P20_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local role = RoleMgr:GetRole(NetManager.P20_RoleId)

		if role ~= nil then
			role:UpdateEquipData(pb.slot)
			ManualRDL.NotesRDL.DealTask(role.id)
		end

		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	NetManager.P20_RoleId = nil

	fun(pb)
end

function NetManager:RequestEquipWeaponAvatar(roleId, avatarId, callback)
	local vPBMessage = protocol_pb.P21_Request()

	vPBMessage.roleId = roleId
	vPBMessage.avatarId = avatarId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvEquipWeaponAvatar(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P21_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestEquip(option, roleId, serialId, slot, callback)
	local vPBMessage = protocol_pb.P20_Request()

	vPBMessage.option = option
	vPBMessage.roleId = roleId
	vPBMessage.serialId = serialId
	vPBMessage.cell = slot

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvEquip(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P20_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		EquipmentManager:ChangeEquip(pb.changes)
	end

	fun(pb)
end

function NetManager:RequestIntentify(roleId, slot, num, isOneKey, callback)
	local vPBMessage = protocol_pb.P18_Request()

	vPBMessage.roleId = roleId
	vPBMessage.cell = slot
	vPBMessage.num = num
	vPBMessage.isOneKey = isOneKey

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvIntentify(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P18_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()

		local info = CharacterMgr:GetCharacter(pb.roleId)

		info.pb.slotLv = pb.levels
		info.tlistEquipAttri = info:UpdateEquipmentAttri(info.pb.equips)

		info:UpdateAttri()
		PersistentStoreUtil.SetTaskState(eTaskType.SlotUpdate, 1)
	end

	fun(pb)
end

function NetManager:RequestEquipEnchant(roleId, slot, scroll, callback)
	local vPBMessage = protocol_pb.P22_Request()

	vPBMessage.roleId = roleId
	vPBMessage.slot = slot
	vPBMessage.scroll = scroll

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvEquipEnchant(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P22_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestEquipEnchantResult(roleId, slot, stype, callback)
	local vPBMessage = protocol_pb.P23_Request()

	vPBMessage.roleId = roleId
	vPBMessage.slot = slot
	vPBMessage.type = stype

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvEquipEnchantResult(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P23_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestGetStageBullet(stageId, startTime, callback)
	local vPBMessage = protocol_pb.P22_Request()

	vPBMessage.stageId = stageId
	vPBMessage.time = startTime

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetStageBullet(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P22_Response()
	local fun = GetCallback(pb, vMsg)
	local data

	if pb.result.code == 0 then
		data = {
			listMsg = pb.msg,
			startTime = pb.startTime,
			endTime = pb.endTime
		}
	end

	fun(pb, data)
end

function NetManager:RequestSendStageBullet(stageId, startTime, strMsg, callback)
	local vPBMessage = protocol_pb.P23_Request()

	vPBMessage.stageId = stageId
	vPBMessage.time = startTime
	vPBMessage.msg = strMsg

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSendStageBullet(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P23_Response()
	local fun = GetCallback(pb, vMsg)
	local setter

	if pb.result.code == 0 then
		setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb, setter)
end

function NetManager:RequestGetCharSkill(roleId, nodeId, callback)
	local vPBMessage = protocol_pb.P36_Request()

	vPBMessage.roleId = roleId
	vPBMessage.nodeId = nodeId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetCharSkill(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P36_Response()
	local fun = GetCallback(pb, vMsg)
	local setter
	local data = {}

	if pb.result.code == 0 then
		setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
		InfoGameInst:SetPbEntry(pb.entry)

		local node = pb.node

		data.setter = setter
		data.node = node

		if pb.changeTasks ~= nil then
			for i = 1, #pb.changeTasks do
				local pbitem = pb.changeTasks[i]
				local infoTask = TaskMgr:Get(pbitem.id)

				infoTask:SetData(pbitem)
			end
		end
	end

	fun(pb, data)
end

function NetManager:RequestSendRoleBallage(roleID, msg, callback)
	local vPBMessage = protocol_pb.P21_Request()

	vPBMessage.cardId = roleID
	vPBMessage.msg = msg

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSendRoleBallage(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P21_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:RequestEquipCard(roleCardId, callback)
	local vPBMessage = protocol_pb.P18_Request()

	vPBMessage.roleCardId = roleCardId
	NetManager.tempCardId = roleCardId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvEquipCard(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P18_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess and NetManager.tempCardId then
		local infoRole = RoleCardMgr:GetRole(NetManager.tempCardId)

		if infoRole then
			infoRole:SetRoleCardId(NetManager.tempCardId)
			infoRole:SetEquipStatus()
		end
	end

	NetManager.tempCardId = nil

	fun(pb)
end

function NetManager:RequestGetRoleBallage(cardID, time, callback)
	local vPBMessage = protocol_pb.P20_Request()

	vPBMessage.cardId = cardID
	vPBMessage.time = time

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetRoleBallage(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P20_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestGetWorks(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P25_Request")

	SetCallback(vGroup, callback, "P25_Request")
end

function OnRecvGetWorks(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P25_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		WorkMgr:SetData(pb)

		WorkMgr.Requested = true
	end

	fun(pb)
end

function NetManager:RequestPickWork(id, roleCardIds, awardMultiple, callback)
	local vPBMessage = protocol_pb.P26_Request()

	vPBMessage.id = id

	for i = 1, #roleCardIds do
		table.insert(vPBMessage.roleCardIds, roleCardIds[i])
	end

	vPBMessage.awardMultiple = awardMultiple

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvPickWork(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P26_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		WorkMgr:ConverWork(pb.work)

		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
		ReTimeMgr:GetWorkNextRefreshTime()
	end

	fun(pb)
end

function NetManager:RequestCompleteWork(serialId, quickly, callback, panelCb)
	local vPBMessage = protocol_pb.P27_Request()

	vPBMessage.id = serialId
	vPBMessage.quickly = quickly
	NetManager.removeId = serialId
	NetManager.panelCb = panelCb

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvCompleteWork(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P27_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()

		local infoWork = WorkMgr:GetWorkBySerialId(NetManager.removeId)

		if infoWork ~= nil then
			local createTime = infoWork.pb.beginTime
			local pickTime = infoWork.pb.endTime - infoWork.data.WorkTime * DateUtil.SecsPerMinute

			if TimeIsToday(createTime * DateUtil.MillsPerSecond) and TimeIsToday(pickTime * DateUtil.MillsPerSecond) then
				WorkMgr:ChangeWorkState(NetManager.removeId, eWorkStateType.Completed)
			else
				WorkMgr:RemoveWork(NetManager.removeId)

				if pb.newWork.workId ~= 0 then
					WorkMgr:AddWork(pb.newWork)
				end
			end
		end

		WorkRDL.RemoveReceived(NetManager.removeId)
		ReTimeMgr:GetWorkNextRefreshTime()
	end

	NetManager.removeId = nil
	NetManager.panelCb = nil

	fun(pb)
end

function NetManager:RequestBuyWork(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P28_Request")

	SetCallback(vGroup, callback, "P28_Request")
end

function OnRecvBuyWork(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P28_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		WorkMgr:ChangeWorkState(tonumber(pb.id), eWorkStateType.Normal)

		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestTalentNode(roleID, talentID, callback)
	local vPBMessage = protocol_pb.P30_Request()

	vPBMessage.roleId = roleID
	vPBMessage.nodeId = talentID
	NetManager.roleId = roleID

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvTalentNode(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P30_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local setterCost = SetterData.GetSetterData(pb.costSetter)

		setterCost:Parse()
		DealWithGetAward(pb.setter)

		local infoRole = RoleMgr:GetRole(NetManager.roleId)

		infoRole:UpdateTalentNodeData(pb.node)

		if pb.nodeSkill and pb.nodeSkill.id and pb.nodeSkill.id ~= 0 then
			infoRole:UpdateTalentSkillData(pb.nodeSkill)
		end
	end

	NetManager.roleId = nil

	fun(pb)
end

function NetManager:RequestUpCardPetal(roleCardId, petal, list, callback)
	local vPBMessage = protocol_pb.P31_Request()

	vPBMessage.roleCardId = roleCardId
	vPBMessage.petal = petal

	if list then
		for i = 1, #list do
			table.insert(vPBMessage.costSouls, list[i])
		end
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvUpCardPetal(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P31_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestReceivePetalAward(roleCardId, petal, callback)
	local vPBMessage = protocol_pb.P32_Request()

	vPBMessage.roleCardId = roleCardId
	vPBMessage.petal = petal

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvPetalAward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P32_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		DealWithGetAward(pb.setter)
	end

	fun(pb)
end

function NetManager:RequestExchangeCardStarStone(roleCardId, num, callback)
	local vPBMessage = protocol_pb.P33_Request()

	vPBMessage.roleCardId = roleCardId
	vPBMessage.num = num

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvExchangeCardStarSton(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P33_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		DealWithGetAward(pb.setter)
	end

	fun(pb)
end

function NetManager:RequestExchangeRoleCard(roleCardId, callback)
	local vPBMessage = protocol_pb.P34_Request()

	vPBMessage.roleCardId = roleCardId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvExchangeRoleCard(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P34_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestEquipAvatar(vars, callback)
	local vPBMessage = protocol_pb.P35_Request()

	vPBMessage.roleId = vars.roleId

	if vars.modeId then
		vPBMessage.template = vars.modeId
	end

	if vars.avatarIds then
		for i = 1, #vars.avatarIds do
			table.insert(vPBMessage.avatarIds, vars.avatarIds[i])
		end
	end

	if vars.name then
		vPBMessage.name = vars.name
	end

	if vars.defaultId then
		vPBMessage.current = vars.defaultId
	end

	NetManager.varsRecord = vars

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvEquipAvatar(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P35_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess and NetManager.varsRecord then
		local infoRole = RoleMgr:GetRole(NetManager.varsRecord.roleId)

		infoRole:UpdateAvatarMode(NetManager.varsRecord.modeId, NetManager.varsRecord.avatarIds, NetManager.varsRecord.name)
	end

	NetManager.varsRecord = nil

	fun(pb, data)
end

function NetManager:RequestBuyAvatar(roleId, avatarIds, callback)
	local vPBMessage = protocol_pb.P36_Request()

	vPBMessage.roleId = roleId

	if avatarIds then
		for i = 1, #avatarIds do
			table.insert(vPBMessage.avatarIds, avatarIds[i])
		end
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvBuyAvatar(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P36_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb, data)
end

function NetManager:RequestBindBPAvatar(roleId, avatarId, callback)
	local vPBMessage = protocol_pb.P37_Request()

	vPBMessage.roleId = roleId
	vPBMessage.avatarId = avatarId
	NetManager.roleId = roleId
	NetManager.avatarId = avatarId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvBindBPAvatar(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P37_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()

		if NetManager.avatarId and NetManager.roleId then
			PlayerInst:ChangeBPAvatarBind(NetManager.avatarId, NetManager.roleId)
			CharacterThinMgr.ResetInterface(THIN_SYSTEM_TYPE.Role, nil, nil, nil, nil, true)
		end
	end

	NetManager.avatarId = nil
	NetManager.roleId = nil

	fun(pb)
end

function NetManager:RequestGetChapterAward(chapterId, cupIndexs, callback)
	local vPBMessage = protocol_pb.P40_Request()

	vPBMessage.chapterId = chapterId

	for i = 1, #cupIndexs do
		table.insert(vPBMessage.indexs, cupIndexs[i])
	end

	NetManager.chapterId = chapterId
	NetManager.cupIndexs = cupIndexs

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetChapterAward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P40_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		DealWithGetAward(pb.setter)
		ChapterRDL.DealSubStarAward(NetManager.chapterId, NetManager.cupIndexs)
	end

	NetManager.chapterId = nil
	NetManager.cupIndexs = nil

	fun(pb)
end

function NetManager:RequestSetFormation(id, name, ids, fetterId, callback)
	local vPBMessage = protocol_pb.P41_Request()

	vPBMessage.teamId = id
	vPBMessage.teamName = name

	if ids then
		for i, v in ipairs(ids) do
			table.insert(vPBMessage.roleCardTeams, v)
		end
	end

	if fetterId then
		vPBMessage.fetterTeamId = fetterId
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSetFormation(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P41_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:RequestStartStage(stageId, chapterTeam, isRelive, callback, helperId, raidBossId, clubMirrorId)
	local vPBMessage = protocol_pb.P42_Request()

	vPBMessage.stageId = stageId
	vPBMessage.relive = isRelive

	if chapterTeam.roleCardTeams == nil then
		for i = 1, 10 do
			table.insert(vPBMessage.roleCardTeams, 0)
		end
	else
		for i, v in ipairs(chapterTeam.roleCardTeams) do
			table.insert(vPBMessage.roleCardTeams, v)
		end

		if chapterTeam.id ~= nil then
			vPBMessage.teamId = chapterTeam.id
		end

		if chapterTeam.fetterTeamId ~= nil then
			vPBMessage.fetterId = chapterTeam.fetterTeamId
		end

		if helperId ~= nil then
			vPBMessage.helperId = tonumber(helperId)
		end
	end

	if raidBossId ~= nil then
		vPBMessage.raidBossId = raidBossId
	end

	if clubMirrorId ~= nil then
		vPBMessage.clubMirrorId = clubMirrorId
	end

	vPBMessage.clickType = PageCombatReadinessJP.clickType

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvStartStage(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P42_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestEndStage(boutId, isDone, values, battleLog, oltime, whipNum, bloodCost, bloodTeam, killMonsters, chaos, callback, blood)
	local vPBMessage = protocol_pb.P43_Request()

	vPBMessage.boutId = boutId
	vPBMessage.isDone = isDone

	for i = 1, #values do
		table.insert(vPBMessage.values, values[i])
	end

	vPBMessage.battleLog = battleLog
	vPBMessage.oltime = oltime
	vPBMessage.whipNum = whipNum

	if chaos then
		vPBMessage.norce = chaos.norce
		vPBMessage.ut = chaos.ut
		vPBMessage.signature = chaos.signature
	end

	if bloodCost then
		for i = 1, #bloodCost do
			table.insert(vPBMessage.bloodCost, bloodCost[i])
		end
	end

	if bloodTeam then
		for i = 1, #bloodTeam do
			table.insert(vPBMessage.bloodTeam, bloodTeam[i])
		end
	end

	if killMonsters then
		for i = 1, #killMonsters do
			table.insert(vPBMessage.killMonsters, killMonsters[i])
		end
	end

	if blood then
		vPBMessage.blood = blood
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function JPSendFirstTimeStoryClear(chapterID, stageId)
	AppsFlyerService.SendStoryFirstTimeClear(tostring(chapterID), stageId)
end

function OnRecvEndStage(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P43_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		InstructionMgr:TriggerWait("PassStage")

		local pbStageIdList = {}

		for i = 1, #pb.stages do
			local pbStage = pb.stages[i]
			local infoStage = ChapterMgr:GetStage(pbStage.id)

			table.insert(pbStageIdList, tonumber(pbStage.id))

			local prePass = infoStage:IsPass()

			infoStage:SetData(pbStage)

			if infoStage.pb.isPass then
				TopicManager:NotifyNewCall(tonumber(pbStage.id))
				PhoneCallManager:NotifyNewCall(tonumber(pbStage.id))

				if prePass == false then
					if infoStage.data.FavorStorySkill ~= 0 then
						local infoChapter = ChapterMgr:GetChapter(infoStage.data.ChapterID)
						local infoRole = RoleMgr:GetRole(infoChapter.data.Role)

						infoRole.NewUnlockSkill = true

						infoRole:AddExtraSkillData({
							level = 1,
							id = infoStage.data.FavorStorySkill
						})
					end

					ByStageUtil.Deal(infoStage, RD_STAGE_PASS_TYPE.First_Time)

					if infoStage.data.ChapterType == ChapterFromType.main then
						if infoStage.data.Type == StageFromType.story then
							JPSendFirstTimeStoryClear(infoStage.data.ChapterID, infoStage.id)
						end

						if InstructionMgr:GetNewBieStageID(infoStage.id) then
							ChapterMgr.justUnLockStage = infoStage.id

							TutorialMgr:DealStageOpenSystem()
						end
					end
				else
					ByStageUtil.Deal(infoStage, RD_STAGE_PASS_TYPE.NotFirst_Time)
				end
			end

			if infoStage.data.ChapterType == ChapterFromType.card then
				if infoStage.pb.playNum ~= 0 then
					ChapterRDL.CardRDL.ChangeChallengeNum(-1)
					CardRDL.StageRDL.ResetCardStageFight()
				else
					local infoChapter = ChapterMgr:GetChapter(infoStage.data.ChapterID)

					CardRDL.StageRDL.RunCardStageFight(RoleCardMgr:GetRoleCard(infoChapter.data.Card))
				end
			end
		end

		if pb.chapter and pb.chapter.id > 0 then
			local infoChapter = ChapterMgr:GetChapter(pb.chapter.id)

			infoChapter.pb = pb.chapter

			if infoChapter.data.Type == ChapterFromType.tower or infoChapter.data.Type == ChapterFromType.towerhard then
				local unlockList = {}

				local function isInArray(t, val)
					for _, v in pairs(t) do
						if v.id == val then
							return true
						end
					end

					return false
				end

				for _, value in pairs(pbStageIdList) do
					if not isInArray(infoChapter.listStage, value) then
						local chapter = TowerChapterMgr:GetTowerChapter(value)

						table.insert(unlockList, chapter.id)
					end
				end

				if #unlockList ~= 0 then
					PersistentStoreUtil.SetList("UnLockTower", unlockList)
				end

				ChapterRDL.TowerRDL.AddPassAward()
			end

			if infoChapter.data.Type == ChapterFromType.activity then
				local unlockStory = {}

				for _, value in pairs(pbStageIdList) do
					local stage = ChapterMgr:GetStage(value)

					if stage.data.Type == StageFromType.story and not stage:IsPass() then
						table.insert(unlockStory, value)
					end

					if stage.data.Type == StageFromType.activeBoss and not stage:IsPass() then
						local chapter = ChapterMgr:GetChapter(stage.data.ChapterID)

						if stage.data.ID == chapter.data.StageID[1] then
							ActiveMgr.NewOpenBossStage = value
						end

						ChapterRDL.PartyRDL.DealBoss()
					end
				end

				if #unlockStory ~= 0 then
					ActiveMgr.NewOpenStory = unlockStory

					PersistentStoreUtil.SetBool("UnLockActiveStoryBool", true)
				end
			end
		end

		ChapterMgr:UpdateProcess()

		if pb.dropRaidBossTime and pb.dropRaidBossTime > 0 then
			ActivityBossRaidMgr.selfBossEndTime = pb.dropRaidBossTime
		end

		if pb.whipAwardBoxNum and pb.whipAwardBoxNum > 0 then
			InfoGameInst:SetWhipAwardBoxNum(pb.whipAwardBoxNum)
		end
	elseif pb.result.code == 1 or pb.result.code == 2 then
		local function wrap_cb(...)
			Restart()
		end

		UIMgr.ShowDialog("再接続に失敗しました。ログイン画面に戻ります。", wrap_cb)
	end

	fun(pb)
	OperationActiveMgr:CheckReGetOperation()
end

function NetManager:RequestWipeStage(stageId, number, roleCardTeams, callback)
	local vPBMessage = protocol_pb.P44_Request()

	vPBMessage.stageId = stageId
	vPBMessage.number = number

	for i = 1, #roleCardTeams do
		table.insert(vPBMessage.roleCardTeams, roleCardTeams[i])
	end

	NetManager.P44_SweepNum = number

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvWipeStage(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P44_Response()
	local fun = GetCallback(pb, vMsg)
	local listWave = {}

	if pb.result.code == 0 then
		local infoStage = ChapterMgr:GetStage(pb.stage.id)

		infoStage:SetData(pb.stage)

		if infoStage.data.ChapterType == ChapterFromType.card then
			if infoStage.pb.playNum ~= 0 then
				ChapterRDL.CardRDL.ChangeChallengeNum(-(NetManager.P44_SweepNum or 0))
				CardRDL.StageRDL.ResetCardStageFight()
			else
				local infoChapter = ChapterMgr:GetChapter(infoStage.data.ChapterID)

				CardRDL.StageRDL.RunCardStageFight(RoleCardMgr:GetRoleCard(infoChapter.data.Card))
			end
		end

		listWave = pb.waves

		if pb.chapter and pb.chapter.id > 0 then
			local infoChapter = ChapterMgr:GetChapter(pb.chapter.id)

			infoChapter.pb = pb.chapter
		end

		if pb.dropRaidBossTime and pb.dropRaidBossTime > 0 then
			ActivityBossRaidMgr.selfBossEndTime = pb.dropRaidBossTime
		end

		ChapterMgr:UpdateProcess()
	end

	NetManager.P44_SweepNum = nil

	fun(pb, listWave)
end

function NetManager:RequestUpdateActive(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P46_Request")

	SetCallback(vGroup, callback, "P46_Request")
end

function OnRecvUpdateActive(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P46_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		ChapterMgr:SetData(pb.chapters)
		ActiveMgr:SetData(pb.activeNextTime, pb.activePlayNums)
	end
end

function NetManager:RequestOpenPerform(performID, quickFinished, callback)
	local vPBMessage = protocol_pb.P46_Request()

	vPBMessage.performId = performID
	vPBMessage.quickFinished = quickFinished
	LiveManager.curInfoLive = LiveManager:Get(performID)

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvOpenPerform(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P46_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:RequestHelpFight(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P47_Request")

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvHelpFight(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P47_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:RequestGvgHelpFight(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P50_Request")

	SetCallback(vGroup, callback)
end

function OnRecvGvgHelpFight(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P50_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:RequestAddStageTypeNum(type, times, callback)
	local vPBMessage = protocol_pb.P48_Request()

	vPBMessage.type = type
	vPBMessage.times = times

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvAddStageTypeNum(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P48_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestBuyPower(times, callback)
	local vPBMessage = protocol_pb.P49_Request()

	vPBMessage.times = times or 1

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvBuyPower(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P49_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
		InfoGameInst:ChangePowerBoughtTimes()
	end

	fun(pb)
end

function NetManager:RequestPerformOver(performId, quickFinished, rolesId, rhythmStatistics, callback)
	local vPBMessage = protocol_pb.P50_Request()

	vPBMessage.performId = performId
	vPBMessage.quickFinished = quickFinished
	LiveManager.curInfoLive = LiveManager:Get(performId)
	LiveManager.isSweeping = quickFinished

	for i = 1, #rolesId do
		table.insert(vPBMessage.song.roleIds, rolesId[i].id)
	end

	table.insert(vPBMessage.song.data, rhythmStatistics.Score)
	table.insert(vPBMessage.song.data, rhythmStatistics.HitCount)
	table.insert(vPBMessage.song.data, rhythmStatistics.MissCount)
	table.insert(vPBMessage.song.data, rhythmStatistics.MaxCombo)

	for j = 1, #rhythmStatistics.HitInfos do
		local info = rhythmStatistics.HitInfos[j]

		for k = 1, #info do
			table.insert(vPBMessage.song.plays, info[k])
		end
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvPerformOver(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P50_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		if LiveManager.curInfoLive ~= nil then
			local enterNum = LiveManager.curInfoLive:GetLiveEntCnt()

			LiveManager.curInfoLive:SetLiveEnterNum(enterNum + 1)
		end

		if not LiveManager.isSweeping then
			-- block empty
		end
	else
		UIMgr.ShowMsg(pb.result.desc, pb)
	end

	fun(pb)
end

function NetManager:RequestGetFavor(roleId, callback)
	local vPBMessage = protocol_pb.P54_Request()

	vPBMessage.roleId = roleId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetFavor(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P54_Response()
	local fun = GetCallback(pb, vMsg)
	local setter

	if pb.result.code == 0 then
		setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
		InfoGameInst:SetTouchCnt(pb.touchCnt)
		InfoGameInst:SetTouchTimeStep(pb.touchTime)
		FavorMgr.Instance:SetPowerTime(pb.touchTime)

		if setter.IsFavorLevelup then
			require("UI/Page/PageInteraction/DlgFavorUp")

			local data = {}

			data.listItem = {}
			data.preFavorLevel = setter.preFavorLevel
			data.curFavorLevel = setter.curFavorLevel
			data.infoRole = setter.infoRole

			data.infoRole:UpdateAllFavorAni()
			UIMgr.AddPanel(DlgFavorUp(), data)
		end

		local listTouchAward = {}
		local listNormal = {}

		for _, s in pairs(pb.setter) do
			if s.from == protocol_pb.AF_TOUCH_EXTRA and s.num > 0 then
				table.insert(listTouchAward, s)
			end
		end

		if #listTouchAward > 0 then
			require("UI/Dlg/Common/DlgStoryAward")
			UIMgr.AddPanel(DlgStoryAward(), {
				offset = -500,
				setter = listTouchAward
			})
		end
	end

	fun(pb, setter)
end

function NetManager:RequestResetFavorTouchCount(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P55_Request")

	SetCallback(vGroup, callback, "P55_Request")
end

function OnRecvResetFavorTouchCount(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P55_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()

		InfoGameInst.gameInfo.touchCnt = GetConfigArgInt("TouchMaxNumber")

		UIMgr.ShowMsg(_("ResetFavorTouchCount_success"))
	end

	fun(pb)
end

function NetManager:RequestSendGift(roleId, item, callback)
	local vPBMessage = protocol_pb.P56_Request()

	vPBMessage.roleId = roleId

	for i = 1, #item do
		table.insert(vPBMessage.item, item[i].id)
		table.insert(vPBMessage.item, item[i].num)
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSendGift(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P56_Response()
	local fun = GetCallback(pb, vMsg)
	local setter
	local data = {}

	if pb.result.code == 0 then
		setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()

		if setter.IsFavorLevelup then
			require("UI/Page/PageInteraction/DlgFavorUp")

			data.listItem = {}
			data.preFavorLevel = setter.preFavorLevel
			data.curFavorLevel = setter.curFavorLevel
			data.infoRole = setter.infoRole

			data.infoRole:UpdateAllFavorAni()
		end
	end

	fun(pb, setter)

	if pb.result.code == 0 then
		Event.Instance:Fire("ChangeFavor", data)
	end
end

function NetManager:RequestGetFavorAward(roleId, callback)
	local vPBMessage = protocol_pb.P57_Request()

	vPBMessage.roleId = roleId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetFavorAward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P57_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()

		local listNormal = setter:Getlist(protocol_pb.AF_NORMAL)
		local data = {}

		data.list = listNormal

		CreateDlgInScene(DlgGetAward.GetInstance(), data)
	end

	fun(pb)
end

function NetManager:RequestGetRoleGift(roleId, callback, panelCB)
	local vPBMessage = protocol_pb.P58_Request()

	vPBMessage.roleId = roleId
	NetManager.panelCb = panelCB

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetRoleGift(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P58_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		DealWithGetAward(pb.setter, false, NetManager.panelCb)
	end

	NetManager.panelCb = nil

	fun(pb)
end

function NetManager:RequestExploreLiveEnd(boutId, roleIds, pbSong, callback)
	local vPBMessage = protocol_pb.P39_Request()

	vPBMessage.boutId = boutId
	vPBMessage.song.supportId = pbSong.supportId

	for i = 1, #roleIds do
		table.insert(vPBMessage.roleIds, roleIds[i])
	end

	for i = 1, #pbSong.data do
		table.insert(vPBMessage.song.data, pbSong.data[i])
	end

	for i = 1, #pbSong.plays do
		table.insert(vPBMessage.song.plays, pbSong.plays[i])
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvExploreLiveEnd(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P39_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		if pb.supportData ~= nil then
			local supportID = pb.supportData.supportId
			local pbStage = pb.changeStage
			local infoStage = ChapterMgr:GetStage(pbStage.id)

			infoStage:SetData(pbStage)

			local allSupportRecord = LiveManager:GetSupportRecordByID(supportID)

			if allSupportRecord ~= nil then
				LiveManager:TryRefreshSupportRecord(pb.supportData, allSupportRecord, true)
			else
				LiveManager:AddSupportNewRecord(pb.supportData, SupportRecordType.All)
			end
		end
	elseif pb.result.code == 2 then
		local function wrap_cb(...)
			MxLauncher.Instance:Quit()
		end

		DlgCommon.Instance:Show("", Localization.Get("Prompt_data_error"), wrap_cb, Localization.Get("UI_OK"))
	end

	fun(pb)
end

function NetManager:RequestGiveUpTask(serialId, workTaskId, callback)
	local vPBMessage = protocol_pb.P51_Request()

	vPBMessage.serialId = serialId
	vPBMessage.workTaskId = workTaskId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGiveUpTask(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P51_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestGetTaskReward(serialId, workTaskId, callback)
	local vPBMessage = protocol_pb.P52_Request()

	vPBMessage.serialId = serialId
	vPBMessage.workTaskId = workTaskId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetTaskReward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P52_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
		PersistentStoreUtil.SetTaskStateNum(eTaskType.WorkTaskNum)

		if pb.changeTasks ~= nil then
			for i = 1, #pb.changeTasks do
				local pbitem = pb.changeTasks[i]
				local infoTask = TaskMgr:Get(pbitem.id)

				infoTask:SetData(pbitem)
			end
		end

		if pb.workTasks ~= nil then
			for i = 1, #pb.workTasks do
				local data = pb.workTasks[i]

				WorkTaskManager:AddPBWorkTask(data)
			end
		end
	end

	fun(pb)
end

function NetManager:RequestStartTask(serialId, workTaskId, infos, double, callback)
	local vPBMessage = protocol_pb.P53_Request()

	vPBMessage.serialId = serialId
	vPBMessage.workTaskId = workTaskId

	for i = 1, #infos.ids do
		table.insert(vPBMessage.roleIds, infos.ids[i])
	end

	for i = 1, #infos.playerIds do
		table.insert(vPBMessage.playerIds, infos.playerIds[i])
	end

	vPBMessage.multiple = double

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvStartTask(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P53_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()

		if pb.changeTasks ~= nil then
			for i = 1, #pb.changeTasks do
				local pbitem = pb.changeTasks[i]
				local infoTask = TaskMgr:Get(pbitem.id)

				infoTask:SetData(pbitem)
			end
		end
	end

	fun(pb)
end

function NetManager:RequestBattlePassAddLevel(taskListId, score, callback)
	local vPBMessage = protocol_pb.P59_Request()

	vPBMessage.taskListId = taskListId
	vPBMessage.score = score
	NetManager.taskListId = taskListId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvBattlePassAddLevel(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P59_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)

	local pbScore = TaskManager.listTaskLineScore[NetManager.taskListId]

	pbScore.taskListId = NetManager.taskListId

	TaskRDL.DealTaskScore({
		pbScore
	})

	NetManager.taskListId = nil
end

function NetManager:RequestTaskList(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P60_Request")

	SetCallback(vGroup, callback, "P60_Request")
end

function OnRecvTaskList(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P60_Response()
	local fun = GetCallback(pb, vMsg)
	local tasks = TaskManager:GetList(eTaskListType.cosume)

	if #tasks > 0 then
		local function wrap_cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if pb.result.code == 0 then
				TaskManager:SetData(pb)
			end

			fun(pb)
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:GetSpeicalTaskInfo(wrap_cb)
	else
		if pb.result.code == 0 then
			TaskManager:SetData(pb)
		end

		fun(pb)
	end
end

function NetManager:RequestTaskChange(taskIds, callback, panelCb)
	local vPBMessage = protocol_pb.P61_Request()

	for i = 1, #taskIds do
		table.insert(vPBMessage.taskIds, taskIds[i])
	end

	NetManager.listTaskId = taskIds
	NetManager.panelCb = panelCb

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvTaskChange(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P61_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		for i = 1, #pb.changeTasks do
			local pbTask = pb.changeTasks[i]
			local info = TaskManager:Get(pbTask.id)

			info:SetData(pbTask)
		end

		TaskManager:SetScoreData(pb.scores)
		DealWithGetAward(pb.setter, false, NetManager.panelCb)

		NetManager.panelCb = nil

		if NetManager.listTaskId and #NetManager.listTaskId > 0 then
			for _, v in pairs(NetManager.listTaskId) do
				local infoTask = TaskManager:Get(v)

				if UnionMgr.HasUnion() and (infoTask.data.ClubSelfPoint > 0 or infoTask.data.ClubPoint > 0) then
					UnionMgr.releUnion:ChangeUnionLiveness(infoTask.data.ClubPoint)
					UnionMemberMgr:ChangeMemberLiveness(PlayerInst.InfoPlayer.pid, infoTask.data.ClubSelfPoint)
				end
			end

			TaskRDL.RemoveReceivedTask(NetManager.listTaskId)

			NetManager.listTaskId = nil
		end

		TaskRDL.AddCanReceiveTask(pb.changeTasks)
		TaskRDL.DealTaskScore(pb.scores)
		OperationRDL.RunGrowthFund()
	end

	fun(pb)
end

function NetManager:RequestTaskLineScoreReward(taskListId, rewardIndex, callback, pay)
	local vPBMessage = protocol_pb.P62_Request()

	vPBMessage.taskListId = taskListId
	vPBMessage.rewardIndex = rewardIndex

	if pay == nil then
		vPBMessage.pay = false
	else
		vPBMessage.pay = pay
	end

	NetManager.taskListId = taskListId
	NetManager.rewardIndex = rewardIndex
	NetManager.pay = pay

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvTaskLineScoreReward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P62_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		DealWithGetAward(pb.setter)
		TaskManager:UpdateScoreAwardData(NetManager.taskListId, NetManager.rewardIndex, NetManager.pay)

		if NetManager.pay and NetManager.rewardIndex ~= -1 then
			OperationRDL.RunBattlePass()
		else
			TaskRDL.RemoveReceivedTaskScore(NetManager.taskListId, NetManager.rewardIndex + 1)
			OperationRDL.RunBattlePass()
		end

		NetManager.taskListId = nil
		NetManager.rewardIndex = nil
		NetManager.pay = nil
	end

	fun(pb)
end

function OnRecvChangeTasks(vMsg)
	local pb = protocol_pb.P63_Response()

	pb:ParseFromString(vMsg.BodyString)
	TaskManager:CoverTaskData(pb.changeTasks)
	OperationRDL.RunGrowthFund()
	TaskRDL.AddCanReceiveTask(pb.changeTasks)
end

function NetManager:RequestReceiveCompleteTasksOneKey(taskListId, taskIds, callback)
	local vPBMessage = protocol_pb.P64_Request()

	vPBMessage.taskListId = taskListId
	taskIds = taskIds or {}

	for _, taskId in ipairs(taskIds) do
		table.insert(vPBMessage.taskIds, taskId)
	end

	NetManager.taskIds = taskIds

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvCompleteTasksOneKey(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P64_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		for _, pbTask in ipairs(pb.changeTasks) do
			local info = TaskManager:Get(pbTask.id)

			info:SetData(pbTask)
		end

		TaskManager:SetScoreData(pb.scores)
		DealWithGetAward(pb.setter, false)
		TaskRDL.RemoveReceivedTask(NetManager.taskIds or {})
		TaskRDL.AddCanReceiveTask(pb.changeTasks)
		TaskRDL.DealTaskScore(pb.scores)
	end

	NetManager.taskIds = nil

	fun(pb)
end

function NetManager:RequestBuyTheme(themeId, callback)
	local vPBMessage = protocol_pb.P65_Request()

	vPBMessage.themeId = themeId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvBuyTheme(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P65_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()

		local infoTheme = ThemeManager:Get(pb.theme.id)

		infoTheme:SetData(pb.theme)
		ThemeRDL.AddNewPlayerPrefs(pb.theme.id)
	end

	fun(pb)
end

function NetManager:RequestGetThemeAward(themeId, callback)
	local vPBMessage = protocol_pb.P66_Request()

	vPBMessage.themeId = themeId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetThemeAward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P66_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		for i = 1, #pb.theme do
			local infoTheme = ThemeManager:Get(pb.theme[i].id)

			infoTheme:SetData(pb.theme[i])

			ThemeManager.surplus[i] = 0

			ThemeRDL.RemoveThemeAward(pb.theme[i].id)
		end

		DealWithGetAward(pb.setter)
		Event.Instance:Fire("PageThemeUpdateInfoEvent", nil, PersistentStoreUtil.GetInt(ePSKey.SceneId))
	end

	fun(pb)
end

function NetManager:RequestSetThemePosition(themeId, seats, type, callback)
	local vPBMessage = protocol_pb.P67_Request()

	vPBMessage.themeId = themeId
	vPBMessage.type = type

	for i = 1, #seats do
		table.insert(vPBMessage.seats, seats[i])
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSetThemePosition(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P67_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		for i = 1, #pb.themes do
			local pbTheme = pb.themes[i]
			local infoTheme = ThemeManager:Get(pbTheme.id)

			infoTheme:SetData(pbTheme)
		end
	end

	fun(pb)
end

function NetManager:RequestRemoveFriend(playerId, callback)
	local vPBMessage = protocol_pb.P68_Request()

	vPBMessage.playerId = playerId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvRemoveFriend(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P68_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestAgreeFriend(playerId, callback)
	local vPBMessage = protocol_pb.P70_Request()

	vPBMessage.playerId = playerId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvAgreeFriend(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P70_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		table.insert(PlayerInst.pbFriendList, pb.player)
	end

	fun(pb)
end

function NetManager:RequestDenyFriend(playerId, callback)
	local vPBMessage = protocol_pb.P71_Request()

	vPBMessage.playerId = playerId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvDenyFriend(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P71_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestSendFriendGift(playerId, giftIds, callback)
	local vPBMessage = protocol_pb.P74_Request()

	vPBMessage.playerId = playerId

	if giftIds ~= nil then
		for i = 1, #giftIds do
			table.insert(vPBMessage.giftIds, giftIds[i])
		end
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvFriendGift(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P74_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()

		if pb.changeTasks ~= nil then
			for i = 1, #pb.changeTasks do
				local pbitem = pb.changeTasks[i]
				local infoTask = TaskMgr:Get(pbitem.id)

				infoTask:SetData(pbitem)
			end
		end
	end

	fun(pb)
end

function NetManager:RequestGetWorkFriData(playerIds, callback)
	local vPBMessage = protocol_pb.P77_Request()

	for i = 1, #playerIds do
		table.insert(vPBMessage.friendPlayerIds, playerIds[i])
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetWorkFriData(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P77_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		PlayerInst:SetFriendPbRole(pb.roles)
	end

	fun(pb)
end

function NetManager:RequestGetMails(mailType, lastId, callback)
	local vPBMessage = protocol_pb.P80_Request()

	vPBMessage.type = mailType
	vPBMessage.lastId = lastId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetMails(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P80_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		if pb.mails ~= nil then
			MailMgr:AddMails(pb.mails)
		end

		MailMgr.Requested = true
	end

	fun(pb)
end

function NetManager:RequestMailsGift(ids, callback)
	local vPBMessage = protocol_pb.P81_Request()

	for i = 1, #ids do
		table.insert(vPBMessage.ids, ids[i])
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvMailsGift(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P81_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		DealWithGetAward(pb.setter, true)
	end

	fun(pb)
end

function NetManager:RequestDeleteMail(ids, callback)
	local vPBMessage = protocol_pb.P82_Request()

	for i = 1, #ids do
		table.insert(vPBMessage.ids, ids[i])
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvDeleteMail(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P82_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	fun(pb)
end

local function RequestAfterPush()
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			local listMail = pb.mails

			if listMail and #listMail > 0 then
				local id = tonumber(listMail[1].id)

				PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. "LastMailId", id)
			end
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestGetMails(1, 0, wrap_cb)
end

function OnRecvPushMail(vMsg)
	local pb = protocol_pb.P83_Response()

	pb:ParseFromString(vMsg.BodyString)
	RequestAfterPush()
end

function NetManager:RequestWebviewReward(id, callback)
	local vPBMessage = protocol_pb.P84_Request()

	vPBMessage.noticeId = id

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvWebviewReward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P84_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

local RequestAnswerRewardGroupId

function NetManager:RequestAnswerReward(groupId, awardId, callback)
	local vPBMessage = protocol_pb.P90_Request()

	vPBMessage.groupId = groupId
	vPBMessage.awardId = awardId
	RequestAnswerRewardGroupId = groupId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvAnswerReward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P90_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 and RequestAnswerRewardGroupId then
		InfoGameInst:SetScenarioReward(RequestAnswerRewardGroupId)

		RequestAnswerRewardGroupId = nil

		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestEndTopic(topicId, isEnd, type, record, callback)
	local vPBMessage = protocol_pb.P91_Request()

	vPBMessage.id = topicId
	vPBMessage.isEnd = isEnd
	vPBMessage.type = type
	NetManager.topicId = topicId
	NetManager.isEnd = isEnd
	NetManager.type = type

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvEndTopic(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P91_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 and NetManager.isEnd == 1 then
		if NetManager.type == 1 then
			CommunicationRDL.RemoveNews(NetManager.topicId)
		elseif NetManager.type == 2 then
			CommunicationRDL.RemoevCall(NetManager.topicId)
		end
	end

	NetManager.topicId = nil
	NetManager.isEnd = nil
	NetManager.type = nil

	fun(pb)
end

function NetManager:RequestModifyTopicName(roleId, nickName, callback)
	local vPBMessage = protocol_pb.P92_Request()

	vPBMessage.roleId = roleId
	vPBMessage.nickName = nickName

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvModifyTopicName(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P92_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestGetCardPoolInfo(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P95_Request")

	SetCallback(vGroup, callback, "P95_Request")
end

function OnRecvGetCardPoolInfo(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P95_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		CardPoolManager.coodTimes = pb.coodTimes
		CardPoolManager.timeData = pb.timeData
	end

	fun(pb)
end

function NetManager:RequestPurchaseCard(cardPoolId, drawNum, callback)
	local vPBMessage = protocol_pb.P96_Request()

	vPBMessage.cardPoolId = cardPoolId
	vPBMessage.drawNum = drawNum

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvPurchaseCard(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P96_Response()
	local fun = GetCallback(pb, vMsg)
	local setter

	if pb.result.code == 0 then
		setter = SetterData.GetSetterData(pb.setter)
	end

	fun(pb, setter)

	if pb.result.code == 0 then
		setter:Parse()

		if pb.changeTasks ~= nil then
			for i = 1, #pb.changeTasks do
				local pbitem = pb.changeTasks[i]
				local infoTask = TaskMgr:Get(pbitem.id)

				infoTask:SetData(pbitem)
			end
		end
	end
end

function NetManager:RequestGetWeekRolePoolInfo(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P97_Request")

	SetCallback(vGroup, callback, "P97_Request")
end

function OnRecvGetWeekRolePoolInfo(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P97_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		CardPoolManager.listWeekRole = pb.weekRoles
		CardPoolManager.listNextWeekRole = pb.nextweekRoles
	end

	fun(pb)
end

function NetManager:RequestGetWeekRole(roleId, callback)
	local vPBMessage = protocol_pb.P98_Request()

	vPBMessage.roleId = roleId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetWeekRole(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P98_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
		InfoGameInst:SetPbEntry(pb.entry)
		PersistentStoreUtil.SetTaskState(eTaskType.Sign, 1)
	end

	fun(pb)
end

function NetManager:RequestDrawCardPool(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P100_Response")

	SetCallback(vGroup, callback, "P100_Response")
end

function OnRecvDrawCardPool(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P100_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestDrawCard(poolId, type, callback)
	local vPBMessage = protocol_pb.P101_Request()

	vPBMessage.poolId = poolId
	vPBMessage.type = type

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvDrawCard(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P101_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestDrawCardRecord(poolId, callback)
	local vPBMessage = protocol_pb.P102_Request()

	vPBMessage.poolId = poolId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvDrawCardRecord(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P102_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestChargeCardPoolCost(poolId, _type, callback)
	local vPBMessage = protocol_pb.P103_Request()

	vPBMessage.poolId = poolId
	vPBMessage.type = _type

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvChargeCardPoolCost(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P103_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestGetActityPool(activeId, callback)
	local vPBMessage = protocol_pb.P105_Request()

	vPBMessage.activeId = activeId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetActityPool(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P105_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		for n = 1, #pb.pools do
			local pbPool = pb.pools[n]
			local infoPool = ActiveCardPoolMgr:Get(pbPool.poolId)

			infoPool:SetData(pbPool)
		end
	end

	fun(pb)
end

function NetManager:RequestDrawActityPool(poolId, times, callback)
	local vPBMessage = protocol_pb.P106_Request()

	vPBMessage.poolId = poolId
	vPBMessage.times = times

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvDrawActityPool(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P106_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local pbPool = pb.pool

		for i, v in ipairs(pbPool) do
			local infoPool = ActiveCardPoolMgr:Get(v.poolId)

			infoPool:SetData(v)
		end

		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()

		local listNormal = setter:Getlist(protocol_pb.AF_ACTIVE_DRAW_CARD)
		local data = {}

		data.list = listNormal
		data.listValue = #listNormal
		ActiveCardPoolMgr.poolListNormal = data
	end

	fun(pb)
end

function NetManager:RequestOpenActityPool(poolId, callback)
	local vPBMessage = protocol_pb.P107_Request()

	vPBMessage.poolId = poolId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvOpenActityPool(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P107_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestCardPoolInfo(poolId, callback)
	local vPBMessage = protocol_pb.P108_Request()

	vPBMessage.poolId = poolId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvCardPoolInfo(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P108_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestPlayerInfo(playerId, callback)
	local vPBMessage = protocol_pb.P110_Request()

	vPBMessage.playerId = playerId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvPlayerInfo(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P110_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestFriendList(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P111_Request")

	SetCallback(vGroup, callback, "P111_Request")
end

function OnRecvFriendList(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P111_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		InfoGameInst.todayRecvFriendCoinNum = pb.dailyReceive
		InfoGameInst.todayRequestFriendNum = pb.applyNum

		FriendMgr:SetData(pb)

		FriendMgr.Requested = true
	end

	fun(pb)
end

function NetManager:RequestRecommendList(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P112_Request")

	SetCallback(vGroup, callback, "P112_Request")
end

function OnRecvRecommendList(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P112_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		FriendMgr:ChangeRecommendList(pb.recommends)
	end

	fun(pb)
end

function NetManager:RequestSearchFriend(keyword, remark, callback)
	local vPBMessage = protocol_pb.P113_Request()

	vPBMessage.keyword = keyword
	vPBMessage.remark = remark
	NetManager.P113_remark = remark

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSearchFriend(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P113_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		if NetManager.P113_remark == 0 then
			FriendMgr:SetSearchData(pb.player)
		else
			FriendMgr:AddSearchData(pb.player)
		end
	end

	NetManager.P113_remark = nil

	fun(pb)
end

function NetManager:RequestAddFriend(listPlayerId, callback)
	local vPBMessage = protocol_pb.P114_Request()

	for i = 1, #listPlayerId do
		table.insert(vPBMessage.playerId, listPlayerId[i])
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvAddFriend(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P114_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestDealWithFriendRequest(style, listPlayerId, callback)
	local vPBMessage = protocol_pb.P115_Request()

	vPBMessage.type = style

	for i = 1, #listPlayerId do
		table.insert(vPBMessage.playerId, listPlayerId[i])
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvDealWithFriendRequest(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P115_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestDealWithFriendCoin(style, playerId, callback)
	local vPBMessage = protocol_pb.P116_Request()

	vPBMessage.type = style
	vPBMessage.playerId = playerId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvDealWithFriendCoin(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P116_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		DealWithGetAward(pb.setter)
	else
		for i = 1, #pb.playerId do
			if pb.playerId[i] then
				FriendMgr:DeleteFromListFriend(pb.playerId[i])
			end
		end

		Event.Instance:Fire("RefreshFriendPanel")
	end

	fun(pb)
end

function NetManager:RequestDealWithFriendRelation(style, playerId, callback)
	local vPBMessage = protocol_pb.P117_Request()

	vPBMessage.type = style
	vPBMessage.playerId = playerId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvDealWithFriendRelation(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P117_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	fun(pb)
end

function OnRecvPlayerApplyAndAgree(vMsg)
	local pb = protocol_pb.P118_Response()

	pb:ParseFromString(vMsg.BodyString)

	if pb.type == 1 then
		FriendMgr:AddPlayerToList(FriendMgr.listApply, pb.player)
		Event.Instance:Fire("RefreshFriendRequestPanel")
		FriendRDL.AddFriendApply()
	elseif pb.type == 2 then
		local function wrap_cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vMsg.result.code == NetManager.Result_Sucess then
				Event.Instance:Fire("RefreshFriendPanel")
				Event.Instance:Fire("RefreshFriendSearchPanel")
			end
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestFriendList(wrap_cb)
	end
end

function OnRecvFriendGiftCoin(vMsg)
	local pb = protocol_pb.P119_Response()

	pb:ParseFromString(vMsg.BodyString)

	local infoFriend = FriendMgr:GetInfoFriend(pb.playerId)

	if infoFriend then
		infoFriend:ChangeReceiveCoinState(2)
		Event.Instance:Fire("RefreshFriendPanel")
		FriendRDL.AddFriendGift()
	end
end

function OnRecvDeleteFriend(vMsg)
	local pb = protocol_pb.P340_Response()

	pb:ParseFromString(vMsg.BodyString)

	local infoFriend = FriendMgr:GetInfoFriend(pb.playerId)

	if infoFriend then
		FriendMgr:DeleteFromListFriend(infoFriend.id)
		Event.Instance:Fire("RefreshFriendPanel")
		Event.Instance:Fire("RefreshFriendSearchPanel")
	end
end

function NetManager:RequestTaskData(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P110_Response")

	SetCallback(vGroup, callback, "P110_Response")
end

function OnRecvTaskData(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P110_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		TaskMgr.dailyUpdateAt = pb.dailyUpdateAt
		TaskMgr.dailyScore = pb.dailyScore
		TaskMgr.dailyRewardMarks = pb.dailyRewardMarks
		TaskMgr.dailyScoreUpdateTime = pb.dailyUpdateAt

		for i = 1, #pb.mainTasks do
			local pbTask = pb.mainTasks[i]
			local infoTask = TaskMgr:Get(pbTask.id)

			infoTask:SetData(pbTask)
		end

		for i = 1, #pb.dailyTasks do
			local pbTask = pb.dailyTasks[i]
			local infoTask = TaskMgr:Get(pbTask.id)

			infoTask:SetData(pbTask)
		end

		for i = 1, #pb.dailyTicketTasks do
			local pbTask = pb.dailyTicketTasks[i]
			local infoTask = TaskMgr:Get(pbTask.id)

			infoTask:SetData(pbTask)

			infoTask.getTime = pb.dailyUpdateAt
		end

		for i = 1, #pb.achieveTasks do
			local pbTask = pb.achieveTasks[i]
			local infoTask = ReputationTaskManager:Get(pbTask.id)

			infoTask:SetData(pbTask)
		end
	end

	fun(pb)
end

function NetManager:RequestTaskState(pbTask, callback)
	local vPBMessage = protocol_pb.P111_Request()

	vPBMessage.task.id = pbTask.id
	vPBMessage.task.status = pbTask.status
	vPBMessage.task.num = pbTask.num

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvTaskState(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P111_Response()
	local fun = GetCallback(pb, vMsg)
	local setter

	if pb.result.code == 0 then
		setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()

		TaskMgr.dailyScore = pb.dailyScore
		TaskMgr.dailyScoreUpdateTime = NetData:GetCurServerTime()
	end

	fun(pb, setter)
end

function NetManager:RequestScoreReward(rewardIndex, callback)
	local vPBMessage = protocol_pb.P112_Request()

	vPBMessage.rewardIndex = rewardIndex

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvScoreReward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P112_Response()
	local fun = GetCallback(pb, vMsg)
	local setter

	if pb.result.code == 0 then
		setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb, setter)
end

function NetManager:RequestSignSeven(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P116_Response")

	SetCallback(vGroup, callback, "P116_Response")
end

function OnRecvSignSeven(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P116_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestSignFifteen(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P117_Response")

	SetCallback(vGroup, callback, "P117_Response")
end

function OnRecvSignFifteen(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P117_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestBuyMounthSpring(cardType, callback)
	local vPBMessage = protocol_pb.P118_Request()

	vPBMessage.cardType = cardType

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvBuyMounthSpring(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P118_Response()
	local fun = GetCallback(pb, vMsg)
	local setter

	if pb.result.code == 0 then
		setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
		ChapterRDL.TowerRDL.Add()
	end

	fun(pb, setter)
end

function NetManager:RequestGetMounthCard(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P119_Response")

	SetCallback(vGroup, callback, "P119_Response")
end

function OnRecvGetMounthCard(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P119_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestGetActivePower(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P122_Response")

	SetCallback(vGroup, callback, "P122_Response")
end

function OnRecvGetActivePower(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P122_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestGetAcitveLevelR(level, callback)
	local vPBMessage = protocol_pb.P123_Request()

	vPBMessage.level = level

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetGoodsInfo(vMsg)
	local pb = protocol_pb.P124_Response()

	pb:ParseFromString(vMsg.BodyString)
	GoodsInfoListMgr:AddData(pb)
end

function OnRecvGetAcitveLevelR(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P123_Response()
	local fun = GetCallback(pb, vMsg)
	local setter

	if pb.result.code == 0 then
		setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb, setter)
end

function NetManager:RequestTotalSign(rewardIndex, callback)
	local vPBMessage = protocol_pb.P125_Request()

	vPBMessage.rewardIndex = rewardIndex

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvTotalSign(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P125_Response()
	local fun = GetCallback(pb, vMsg)
	local setter

	if pb.result.code == 0 then
		setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb, setter)
end

function NetManager:RequestOperationActiveAward(activeId, activeIndex, callback, panelCb)
	local vPBMessage = protocol_pb.P131_Request()

	vPBMessage.activeId = activeId

	local list = {}

	if type(activeIndex) ~= "table" then
		table.insert(list, activeIndex - 1)
	else
		list = activeIndex
	end

	if list then
		for i = 1, #list do
			table.insert(vPBMessage.activeIndex, list[i])
		end
	end

	NetManager.activeId = activeId
	NetManager.activeIndex = activeIndex
	NetManager.PanelCb = panelCb

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvOperationActiveAward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P131_Response()
	local fun = GetCallback(pb, vMsg)
	local setter

	if pb.result.code == NetManager.Result_Sucess then
		DealWithGetAward(pb.setter, false, NetManager.PanelCb)
	end

	fun(pb, setter)
	OperationRDL.DealNodeDot(NetManager.activeId, NetManager.activeIndex)

	NetManager.activeId = nil
	NetManager.activeIndex = nil
	NetManager.PanelCb = nil
	OperationActiveMgr.isAuto = false
end

function NetManager:RequestOnRestRecharge(activeId, callback)
	local vPBMessage = protocol_pb.P134_Request()

	vPBMessage.activeId = activeId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvRestRecharge(vMsg)
	local pb = protocol_pb.P134_Response()
	local fun = GetCallback(pb, vMsg)
	local setter

	fun(pb, setter)
end

function NetManager:RequestUnionList(name, listId, callback, _type)
	local vPBMessage = protocol_pb.P160_Request()

	name = name or ""
	_type = name ~= "" and UnionListMgr.UnionListType.Search or _type or UnionListMgr.UnionListType.Common
	vPBMessage.keyword = name

	if listId ~= nil then
		for _, v in ipairs(listId) do
			table.insert(vPBMessage.clubIds, v)
		end
	end

	NetManager._last = listId ~= nil
	NetManager._type = _type

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvUnionList(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P160_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		if not NetManager._last then
			UnionListMgr:SetUnionList(pb.clubs, NetManager._type)
		else
			UnionListMgr:CoverUnionList(pb.clubs, NetManager._type)
		end
	end

	NetManager._last = nil
	NetManager._type = nil

	fun(pb)
end

function NetManager:RequestCreateUnion(typeId, name, notice, callback)
	local vPBMessage = protocol_pb.P161_Request()

	vPBMessage.type = typeId
	vPBMessage.name = name
	vPBMessage.notice = notice

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvCreateUnion(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P161_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
		UnionMgr:SetData(pb.club)
	end

	fun(pb)
end

function NetManager:RequestApplyJoinUnion(option, clubId, callback)
	local vPBMessage = protocol_pb.P162_Request()

	vPBMessage.option = option

	if clubId then
		vPBMessage.clubId = clubId
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvApplyJoinUnion(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P162_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess and pb.club and pb.club.id ~= 0 then
		if UnionMgr.HasUnion() then
			UnionMgr.releUnion:SetData(pb.club)
		else
			UnionMgr:SetData(pb.club)
		end
	end

	fun(pb)
end

function NetManager:RequestUnionMembers(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P163_Request")

	SetCallback(vGroup, callback, "P163_Request")
end

function OnRecvUnionMembers(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P163_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess and #pb.players ~= 0 then
		UnionApplyMgr:SetData(pb.players)
	end

	fun(pb)
end

function NetManager:RequestUnionMembersAndLogs(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P164_Request")

	SetCallback(vGroup, callback, "P164_Request")
end

function OnRecvMembersAndLogs(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P164_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		if pb.players ~= nil then
			UnionMemberMgr:SetData(pb.players)
		end

		if pb.logs ~= nil then
			UnionLogMgr:SetData(pb.logs)
		end
	end

	fun(pb)
end

function NetManager:RequestQuitUnion(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P165_Request")

	SetCallback(vGroup, callback, "P165_Request")
end

function OnRecvQuitUnion(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P165_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		UnionMgr:QuitUnion()
	end

	fun(pb)
end

function NetManager:RequestUnionSetting(notice, applyType, applyLevel, callback)
	local vPBMessage = protocol_pb.P166_Request()

	if notice ~= nil then
		vPBMessage.notice = notice
	end

	if applyType then
		vPBMessage.applyType = applyType
	end

	if applyLevel then
		vPBMessage.applyLevel = applyLevel
	end

	NetManager.notice = notice

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvUnionSetting(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P166_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess and NetManager.notice ~= nil then
		UnionMgr.releUnion:ChangeNotice(NetManager.notice)
		Event.Instance:Fire("UpdateUnionNotice")
	end

	NetManager.notice = nil

	fun(pb)
end

function NetManager:RequestOperateUnionOrMember(vals, callback)
	local vPBMessage = protocol_pb.P167_Request()

	for k, v in pairs(vals) do
		vPBMessage[k] = v
	end

	NetManager.cmd = vals.cmd
	NetManager.targetId = vals.targetId
	NetManager.targetJob = vals.targetJob

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvOperateUnionOrMember(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P167_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		if NetManager.cmd == 0 then
			-- block empty
		elseif NetManager.cmd == 1 then
			UnionApplyMgr:DealWithApplyPlayer({
				NetManager.targetId
			}, 1)
		elseif NetManager.cmd == 2 then
			UnionApplyMgr:DealWithApplyPlayer({
				NetManager.targetId
			}, 2)
		elseif NetManager.cmd == 3 then
			UnionMemberMgr:KickMember(NetManager.targetId)
		elseif NetManager.cmd == 4 then
			-- block empty
		elseif NetManager.cmd == 5 then
			UnionMemberMgr:ModifyMemberPosition(NetManager.targetId, NetManager.targetJob)
		elseif NetManager.cmd == 6 then
			UnionMgr:DisbandUnion()
		elseif NetManager.cmd == 7 then
			-- block empty
		elseif NetManager.cmd == 8 then
			UnionMgr:UpdateLevel()
		end

		NetManager.cmd = nil
		NetManager.targetId = nil
		NetManager.targetJob = nil
	end

	fun(pb)
end

function OnRecvPushUnionOrLog(vMsg)
	local pb = protocol_pb.P168_Response()

	pb:ParseFromString(vMsg.BodyString)

	if pb.club and pb.club.id ~= 0 then
		if UnionMgr.HasUnion() then
			UnionMgr.releUnion:SetData(pb.club)
		else
			UnionMgr:SetData(pb.club)
		end

		UnionRDL.MemberRDL.Reset()
	end

	if pb.type == 1 then
		Event.Instance:Fire("RequestMemberList")
	elseif pb.type == 2 then
		-- block empty
	elseif pb.type == 3 then
		if pb.club and pb.club.id ~= 0 then
			local kicked = true

			for i = 1, #pb.club.members do
				if pb.club.members[i].playerId == PlayerInst.InfoPlayer.pid then
					kicked = false
				end
			end

			if kicked then
				UnionMgr:KickedUnion()
			end

			UnionMemberMgr:ResetMembers()
			Event.Instance:Fire("UpdateMemberList")
		end
	elseif pb.type == 4 or pb.type == 5 then
		UnionMemberMgr:SetMemberExtraData()
	elseif pb.type == 6 then
		UnionMgr:DisbandUnion()
	elseif pb.type == 7 then
		UnionMemberMgr:ResetMembers()
		Event.Instance:Fire("UpdateMemberList")
	elseif pb.type == 8 then
		-- block empty
	elseif pb.type == 9 then
		Event.Instance:Fire("UpdateUnionApply")
	end

	if pb.log and pb.log.type ~= 0 then
		UnionLogMgr:AddLog(pb.log)
		Event.Instance:Fire("UpdateUnionLog")
	end

	Event.Instance:Fire("UpdateReleUnion")
end

function OnReceiveWishSend(vMsg)
	local pb = protocol_pb.P169_Response()

	pb:ParseFromString(vMsg.BodyString or {})
	UnionWishRecvMgr:ChangeCanReceiveState(true)
	UnionRDL.WishRDL.AddRD()
	Event.Instance:Fire("UpdateWishData")
end

function NetManager:RequestUnionWishList(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P170_Request")

	SetCallback(vGroup, callback, "P170_Request")
end

function OnRecvUnionWishList(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P170_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		UnionWishMgr:SetData(pb.wishs)
	end

	fun(pb)
end

function NetManager:RequestGetWish(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P171_Request")

	SetCallback(vGroup, callback, "P171_Request")
end

function OnRecvGetWish(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P171_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		if pb.players ~= nil then
			UnionWishRecvMgr:SetData(pb.players)
		end

		if pb.setter ~= nil then
			DealWithGetAward(pb.setter)
		end

		UnionWishRecvMgr.Requested = true
	end

	fun(pb)
end

function NetManager:RequestThankPlayer(playerId, callback)
	local vPBMessage = protocol_pb.P172_Request()

	vPBMessage.playerId = playerId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvThankPlayer(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P172_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestReleaseWish(roleCardId, need, callback)
	local vPBMessage = protocol_pb.P173_Request()

	vPBMessage.roleCardId = roleCardId
	vPBMessage.need = need

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvReleaseWish(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P173_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestReachPlayerWish(playerId, grant, callback)
	local vPBMessage = protocol_pb.P174_Request()

	vPBMessage.playerId = playerId
	vPBMessage.grant = grant

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvReachPlayerWish(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P174_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestMineWishRecords(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P175_Request")

	SetCallback(vGroup, callback, "P175_Request")
end

function OnRecvMineWishRecords(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P175_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		UnionWishRecordMgr:SetData(pb.logs)
	end

	fun(pb)
end

function NetManager:RequestUnionSkill(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P176_Request")

	SetCallback(vGroup, callback, "P176_Request")
end

function OnRecvUnionSkill(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P176_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		UnionSkillMgr:SetData(pb.skills)
	end

	fun(pb)
end

function NetManager:RequestProvideUnionSkillExp(clubSkillId, costItems, callback)
	local vPBMessage = protocol_pb.P177_Request()

	vPBMessage.clubSkillId = clubSkillId

	for _, v in pairs(costItems) do
		table.insert(vPBMessage.costItems, v)
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvProvideUnionSkillExp(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P177_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()

		if pb.skills then
			UnionSkillMgr:SetData(pb.skills)
		end
	end

	fun(pb)
end

function NetManager:RequestSetUnionSkillHotSpot(clubSkillId, selfHot, callback)
	local vPBMessage = protocol_pb.P178_Request()

	vPBMessage.clubSkillId = clubSkillId
	vPBMessage.selfHot = selfHot

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSetUnionSkillHotSpot(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P178_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:RequestUpUnionSkillLevel(clubSkillId, callback)
	local vPBMessage = protocol_pb.P179_Request()

	vPBMessage.clubSkillId = clubSkillId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvUpUnionSkillLevel(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P179_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		UnionSkillMgr:ResetSkill(pb.skill)
	end

	fun(pb)
end

function NetManager:RequestUnionRaidData(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P180_Request")

	SetCallback(vGroup, callback, "P180_Request")
end

function OnRecvUnionRaidData(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P180_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		UnionRaidMgr:SetData(pb)
	end

	fun(pb)
end

function NetManager:RequestSelectEvent(mirrorId, eventId, callback)
	local vPBMessage = protocol_pb.P182_Request()

	vPBMessage.mirrorId = mirrorId
	vPBMessage.eventId = eventId
	NetManager.eventId = tonumber(eventId)

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSelectEvent(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P182_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess and UnionRaidMgr.beingCommRaid ~= nil then
		UnionRaidMgr.beingCommRaid:SetProgress(tonumber(pb.progress))

		local pbevent = {
			eventFinish = false,
			eventId = NetManager.eventId,
			eventValue = pb.eventValue,
			eventParams = pb.eventParams
		}

		UnionRaidMgr.beingCommRaid:ResetSelEvent(pbevent)
		UnionRaidMgr.ChangePlayNum(eRaidType.Common)
		UnionRaidMgr.beingCommRaid:ChangeEventRound()
		UnionRaidMgr.beingCommRaid:ClearEvents()
	end

	NetManager.eventId = nil

	fun(pb)
end

function NetManager:RequestReceiveRaidAward(mirrorId, eventId, buffId, callback, panelCb)
	local vPBMessage = protocol_pb.P183_Request()

	vPBMessage.mirrorId = mirrorId
	vPBMessage.eventId = eventId or 0

	if buffId ~= nil then
		vPBMessage.buffId = buffId or 0
	end

	NetManager.panelCb = panelCb

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvRaidAward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P183_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		DealWithGetAward(pb.setter, false, NetManager.panelCb)
	end

	NetManager.panelCb = nil

	fun(pb)
end

function NetManager:RequestRaidAwardRecord(mirrorId, callback)
	local vPBMessage = protocol_pb.P184_Request()

	vPBMessage.mirrorId = mirrorId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvRaidAwardRecord(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P184_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		UnionRaidMgr.beingCommRaid:ResetAwardRecord(pb.assets)
	end

	fun(pb)
end

function NetManager:RequestRestoreCardHp(itemId, roleCardIds, callback)
	local vPBMessage = protocol_pb.P185_Request()

	vPBMessage.itemId = itemId

	if roleCardIds ~= nil then
		for i = 1, #roleCardIds do
			table.insert(vPBMessage.roleCard, roleCardIds[i])
		end
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, "P185_Request")
end

function OnRecvRestoreCardHp(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P185_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestChangeMirrorTeam(mirrorTeams, bossTeams, mirrorFetterId, bossFetterId, callback)
	local vPBMessage = protocol_pb.P186_Request()

	if mirrorTeams then
		for i = 1, #mirrorTeams do
			table.insert(vPBMessage.mirrorTeams, mirrorTeams[i])
		end
	end

	if bossTeams then
		for i = 1, #bossTeams do
			table.insert(vPBMessage.bossTeams, bossTeams[i])
		end
	end

	if mirrorFetterId then
		vPBMessage.mirrorTeamsFetter = mirrorFetterId
	end

	if bossFetterId then
		vPBMessage.bossTeamsFetter = bossFetterId
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvChangeMirrorTeam(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P186_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestReleUnionData(callback, notNeedClubData)
	local vPBMessage = protocol_pb.P187_Request()

	vPBMessage.clubMember = TenaryOp(notNeedClubData, 2, 1)

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvReleUnionData(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P187_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		if UnionMgr.HasUnion() then
			UnionMgr.releUnion:SetData(pb.clubs)
		else
			UnionMgr:SetData(pb.clubs)
		end
	end

	fun(pb)
end

function NetManager:RequestUnionRaidBreakAward(mirrorId, callback)
	local vPBMessage = protocol_pb.P188_Request()

	vPBMessage.mirrorId = mirrorId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvUnionRaidReakAward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P188_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestUnionRaidcontributionAward(index, callback)
	local vPBMessage = protocol_pb.P189_Request()

	vPBMessage.index = index

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvUnionRaidcontributionAward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P189_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		DealWithGetAward(pb.setter)
	end

	fun(pb)
end

function NetManager:RequestBondageSkillUpgrade(teamId, skillId, costSouls, callback)
	local vPBMessage = protocol_pb.P240_Request()

	vPBMessage.teamId = teamId
	vPBMessage.skillId = skillId

	if costSouls then
		for i = 1, #costSouls do
			table.insert(vPBMessage.costSouls, costSouls[i])
		end
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvBondageSkillUpgrade(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P240_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestActiveOperates(activeId, callback)
	local vPBMessage = protocol_pb.P132_Request()

	if activeId then
		for i = 1, #activeId do
			table.insert(vPBMessage.activeId, activeId[i])
		end
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvActiveOperates(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P132_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestGetShareReward(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P133_Request")

	SetCallback(vGroup, callback, "P133_Request")
end

function OnRecvGetShareReward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P133_Response()
	local fun = GetCallback(pb, vMsg)
	local setter

	if pb.result.code == 0 then
		DealWithGetAward(pb.setter)

		InfoGameInst.shareNum = InfoGameInst.shareNum + 1
	end

	fun(pb)
end

function NetManager:RequestGetRechargeReward(gradeId, callback)
	local vPBMessage = protocol_pb.P135_Request()

	vPBMessage.gradeId = gradeId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetRechargeReward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P135_Response()
	local fun = GetCallback(pb, vMsg)
	local setter

	if pb.result.code == 0 then
		setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb, setter)
end

function NetManager:RequestUseItemChest(itemId, subItemId, itemNum, callback)
	local vPBMessage = protocol_pb.P150_Request()

	vPBMessage.itemId = itemId
	vPBMessage.subItemId = subItemId
	vPBMessage.itemNum = itemNum

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvUseItemChest(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P150_Response()
	local fun = GetCallback(pb, vMsg)
	local setter

	if pb.result.code == 0 then
		if pb.type == 1 or pb.type == 2 then
			require("UI/Page/PageCardShop/DlgDrawCard")

			setter = SetterData.GetSetterData(pb.setter)

			setter:Parse()
			UIMgr.AddPanel(DlgDrawCard(), {
				costItemNum = 0,
				isInfinit = false,
				leftTime = 0,
				type = 3,
				costItemId = 0,
				infoId = 0,
				setter = setter,
				callback = function()
					Event.Instance:Fire("ShowBag", false)
				end
			})
		else
			DealWithGetAward(pb.setter)
		end
	end

	fun(pb, setter)
end

function NetManager:RequestExpireItemExchange(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P151_Request")

	SetCallback(vGroup, callback, "P151_Request")
end

function OnRecvExpireItemExchange(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P151_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		-- block empty
	end

	fun(pb)
end

function OnRecvFriendAdd(vMsg)
	local pb = protocol_pb.P152_Response()

	pb:ParseFromString(vMsg.BodyString)

	local player = pb.player

	if player ~= nil then
		if PlayerInst.pbFriendList == nil then
			PlayerInst.pbFriendList = {}
		end

		table.insert(PlayerInst.pbFriendList, player)
		PlayerInst:SortingOnline(PlayerInst.pbFriendList)
	end
end

function OnRecvFriendApply(vMsg)
	local pb = protocol_pb.P153_Response()

	pb:ParseFromString(vMsg.BodyString)

	local player = pb.player

	if player ~= nil then
		if PlayerInst.pbFriendApply == nil then
			PlayerInst.pbFriendApply = {}
		end

		table.insert(PlayerInst.pbFriendApply, player)

		PlayerInst.hasNewFriend = true
	end
end

function OnRecvSystemCmd(vMsg)
	local pb = protocol_pb.P155_Response()

	pb:ParseFromString(vMsg.BodyString)

	if pb.type == 0 then
		-- block empty
	elseif pb.type == 1 or pb.type == 2 then
		local function wrap_cb(...)
			MxLauncher.Instance:Quit()
		end

		DlgCommon.Instance:Show("", pb.cmdDetail, wrap_cb, Localization.Get("UI_OK"))
	end
end

function OnRecvGvg(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P190_Response()

	if pb.result.code == 0 then
		local fun = GetCallback(pb, vMsg)

		fun(pb)
	else
		UIMgr.ShowMsg(pb.result.desc)
	end
end

function NetManager:RequestGvg(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P190_Request")

	SetCallback(vGroup, callback)
end

function OnRecvGvgBuyGoods(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P195_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:RequestGvgBuyGoods(goodsId, callback)
	local vPBMessage = protocol_pb.P195_Request()

	vPBMessage.goodsId = goodsId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback)
end

function NetManager:RequestGvgSetter(phases, stageIds, callback)
	local vPBMessage = protocol_pb.P191_Request()

	for i, val in ipairs(phases) do
		table.insert(vPBMessage.phase, val)
	end

	for i, val in ipairs(stageIds) do
		table.insert(vPBMessage.stageId, val)
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback)
end

function OnRecvGvgSetter(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P191_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function OnRecvGvgState(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P192_Response()

	if pb.result.code == 0 then
		local fun = GetCallback(pb, vMsg)

		fun(pb)
	end
end

function OnRecvGvgContribution(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P193_Response()

	if pb.result.code == 0 then
		local fun = GetCallback(pb, vMsg)

		fun(pb)
	end
end

function NetManager:RequestGvgContribution(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P193_Request")

	SetCallback(vGroup, callback)
end

function OnRecvGvgLogs(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P197_Response()

	if pb.result.code == 0 then
		local fun = GetCallback(pb, vMsg)

		fun(pb)
	end
end

function NetManager:RequestGvgLogs(clubId, activeId, callback)
	local vPBMessage = protocol_pb.P197_Request()

	vPBMessage.clubId = clubId
	vPBMessage.activeId = activeId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback)
end

function OnRecvRepeatedBattle(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P198_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:RequestRepeatedBattle(stageId, callback)
	local vPBMessage = protocol_pb.P198_Request()

	vPBMessage.stageId = stageId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback)
end

function OnRecvGvgHelpAward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P199_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:RequestGvgHelpAward(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P199_Request")

	SetCallback(vGroup, callback)
end

function NetManager:RequestGetChatRoomList(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P200_Request")

	SetCallback(vGroup, callback, "P200_Request")
end

function OnRecvGetChatRoomList(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P200_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 or pb.result.code == 1 then
		if pb.result.code == 0 then
			for i = 1, #pb.roomConfigs do
				ChatMgr:AddRoomConfig(pb.roomConfigs[i])
			end
		end

		local incNum = #pb.autoIncInfo / 2

		for i = 1, incNum do
			local index = 1 + 2 * (i - 1)
			local configId = pb.autoIncInfo[index]
			local incRoomNum = pb.autoIncInfo[index + 1]
			local infoChat = ChatMgr:GetRoomConfig(configId)

			if infoChat ~= nil then
				infoChat.incRoomNum = incRoomNum
			end
		end

		ChatMgr.roomPlayerNumList = {}

		local roomPlayerNum = #pb.roomsPlayerCnt / 2

		for i = 1, roomPlayerNum do
			local index = 1 + 2 * (i - 1)
			local roomId = pb.roomsPlayerCnt[index]
			local roomNum = pb.roomsPlayerCnt[index + 1]
			local data = {}

			data.roomId = roomId
			data.playerNum = roomNum

			table.insert(ChatMgr.roomPlayerNumList, data)
		end
	end

	fun(pb)
end

function NetManager:RequestEnterChatRoom(roomId, callback)
	local vPBMessage = protocol_pb.P201_Request()

	vPBMessage.roomId = roomId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvEnterChatRoom(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P201_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestSendChat(pbChat, callback)
	local vPBMessage = protocol_pb.P202_Request()

	vPBMessage.chatInfo.channel = pbChat.channel
	vPBMessage.chatInfo.from = pbChat.from
	vPBMessage.chatInfo.to = pbChat.to
	vPBMessage.chatInfo.chatMsg = pbChat.chatMsg

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSendChat(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P202_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		-- block empty
	end

	fun(pb)
end

function OnRecvGetChat(vMsg)
	local pb = protocol_pb.P203_Response()

	pb:ParseFromString(vMsg.BodyString)
end

function NetManager:SubmitClientAction(action, params, callback)
	local vPBMessage = protocol_pb.P130_Request()

	vPBMessage.action = action

	for i = 1, #params do
		table.insert(vPBMessage.params, params[i])
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvClientAction(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	if vMsg == nil then
		return
	end

	local pb = protocol_pb.P130_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end
end

NetManager.playStoryDuration = 0

function NetManager:RecordPlayStory(stageId)
	local duration = (NetData:GetCurServerTime() - NetManager.playStoryDuration) / DateUtil.MillsPerSecond

	NetManager:SubmitClientAction(protocol_pb.P130_Request.STORY, {
		tostring(duration),
		tostring(stageId)
	}, nil)
end

function NetManager:RecordTakePhoto(roleId)
	NetManager:SubmitClientAction(protocol_pb.P130_Request.PHOTO, {
		tostring(roleId)
	}, nil)
end

function NetManager:RecordGuide(guideId, isFinished, listStepId)
	local list = {
		tostring(guideId),
		tostring(isFinished)
	}

	for i = 1, #listStepId do
		table.insert(list, tostring(listStepId[i]))
	end

	NetManager:SubmitClientAction(protocol_pb.P130_Request.NEWBIE, list, nil)
end

function NetManager:RequestGetPurchaseList(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P120_Response")

	SetCallback(vGroup, callback, "P120_Response")
end

function OnRecvGetPurchaseList(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P120_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		ShopManager.listAllHoldMonth = {}

		if pb.months then
			for i = #ShopManager.listAllHoldMonth, 1, -1 do
				local gId = ShopManager.listAllHoldMonth[i].goodsId

				for n = 1, #pb.months do
					if gId == pb.months[n].goodsId then
						table.remove(ShopManager.listAllHoldMonth, i)
					end
				end
			end

			for i = 1, #pb.months do
				table.insert(ShopManager.listAllHoldMonth, pb.months[i])
			end
		end

		ShopManager:SetData(pb)
	end

	fun(pb)
end

function NetManager:RequestPurchasePruduct(productId, goodsNum, extra, soulCost, callback)
	local vPBMessage = protocol_pb.P121_Request()

	vPBMessage.goodsId = productId
	vPBMessage.goodsNum = goodsNum
	vPBMessage.extra = extra

	for i = 1, #soulCost do
		table.insert(vPBMessage.soulCost, soulCost[i])
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvPurchasePruduct(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P121_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local ret = NetEncapManager.dictData:GetValue("P121")

		if ret then
			if pb.setter then
				if not ret.noShowAward then
					DealWithGetAward(pb.setter)
				else
					local setter = SetterData.GetSetterData(pb.setter)

					setter:Parse()
				end
			end

			local info = ShopManager:GetProduct(ret.id)

			if info.data.CostType == 1 then
				print("need cost pay")

				local data = {}

				data.total_fee = info.data.CostValue[1]
				data.game_money = info.data.Diamond
				data.out_trade_no = pb.payInfo.gameOrderId
				data.subject = Lang(info.data.Name)
				data.body = Lang(info.data.InfoPay)
				data.extension_info = pb.payInfo.origin
				data.notify_url = pb.payInfo.notifyUrl
				data.order_sign = pb.payInfo.sign
				data.productId = info.data.ProductID

				print(data.game_money)
				print(data.total_fee)
				print(data.subject)
				print(data.body)
				SDKMgr:Pay(OnPayCallback, data)
				LoadingMgr.Show(eLoadingType.RepeatPay)
			else
				local infoProduct = ShopManager:GetProduct(info.id)

				infoProduct.pb.firsted = false

				if infoProduct.pb.myCount then
					infoProduct.pb.myCount = infoProduct.pb.myCount + ret.num
				end

				ShopRDL.RemoveGood(infoProduct.data.ID)
				Event.Instance:Fire("UpdateShop")
				Event.Instance:Fire("DlgLuckyBackAwardBuyEvent")
				Event.Instance:Fire("DlgRoleBirthdayAwardBuyEvent")
			end

			NetEncapManager.dictData:Set("P121", nil)
		end
	end

	NetEncapManager.goodsItemList = {}

	fun(pb)
end

function OnRecvPurchaseActivePruduct(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P129_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		if pb.setter then
			DealWithGetAward(pb.setter)
		end

		Event.Instance:Fire("UpdateShop")
		Event.Instance:Fire("DlgLuckyBackAwardBuyEvent")
		Event.Instance:Fire("DlgRoleBirthdayAwardBuyEvent")
	end

	fun(pb)
end

function OnPayCallback(str)
	print("OnPayCallback:" .. str)
	LoadingMgr.Hide(eLoadingType.RepeatPay)

	local json = require("GameLogic/Util/json4lua")
	local dict = json.decode(str)
	local code = dict.code
	local callbackType = dict.callbackType

	if callbackType == "Pay" and tonumber(code) == 0 then
		UIMgr.ShowMsg(_("Desc_PayFail"))
	end
end

function OnRecvPurchaseReward(vMsg)
	local pb = protocol_pb.P122_Response()

	pb:ParseFromString(vMsg.BodyString)
	ServerMsgRecv.Instance:HandlePBMessage(pb, vMsg.Group)
	print("gameOrderId:" .. pb.gameOrderId)
	ShopManager:SetMonthDatas(pb.card)

	if pb.card then
		for i = #ShopManager.listAllHoldMonth, 1, -1 do
			local gId = ShopManager.listAllHoldMonth[i].goodsId

			for n = 1, #pb.card do
				if gId == pb.card[n].goodsId then
					table.remove(ShopManager.listAllHoldMonth, i)
				end
			end
		end

		for i = 1, #pb.card do
			table.insert(ShopManager.listAllHoldMonth, pb.card[i])
		end

		for i = 1, #ShopManager.listAllHoldMonth do
			local GoodsId, State = OperationActiveMgr:GetBattlePassMonthIdState()

			if ShopManager.listAllHoldMonth[i].goodsId == GoodsId then
				Event.Instance:Fire(EventEnum.UpdateItemDataNotify)
			end
		end
	end

	DealWithGetAward(pb.setter)

	if pb.orderGoods and pb.orderGoods.id ~= 0 then
		local infoProduct = ShopManager:GetProduct(pb.orderGoods.id)

		infoProduct:SetData(pb.orderGoods)

		if infoProduct.endAt and infoProduct.data.ID == 40002 then
			UIMgr.ShowMsg(_("PageShop_buy_success"))
		end

		ShopRDL.Init()
		OperationActiveMgr:RequestChargeActiveData(infoProduct)
		Event.Instance:Fire("UpdateShop", pb)
		Event.Instance:Fire("DlgLuckyBackAwardBuyEvent")
		Event.Instance:Fire("DlgRoleBirthdayAwardBuyEvent")
		OperationRDL.FirstRechargeRDL.AddFirstRechargeAward()
		OperationRDL.RunBattlePass()
	end
end

function NetManager:RequestPurchaseActivePruduct(activeId, callback)
	local vPBMessage = protocol_pb.P129_Request()

	vPBMessage.activeId = activeId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function NetManager:RequestGetPurchaseReward(goodsId, callback)
	local vPBMessage = protocol_pb.P123_Request()

	vPBMessage.goodsId = goodsId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetPurchaseReward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P123_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		DealWithGetAward(pb.setter)
	end

	fun(pb)
end

function NetManager:RequestGetFirstPurchaseReward(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P145_Request")

	SetCallback(vGroup, callback, "P145_Request")
end

function OnRecvGetFirstPurchaseReward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P145_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()

		local pageClass = _G.PageClassroom
		local page = pageClass.curInst

		if page ~= nil then
			page.ButtonFirst.gameObject:SetActive(false)
		end

		local data = {}

		data.setter = setter
		data.pbItems = nil
		data.funcDesc = Localization.Get("DESC_ItemView")

		CreateDlgInPage(DlgGetItem.GetInstance(), data)
	end

	fun(pb)
end

function NetManager:RequestDrawReward(nDrawNum, callback)
	local vPBMessage = protocol_pb.P146_Request()

	vPBMessage.useCount = nDrawNum

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvDrawReward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P146_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
		InfoGameInst:SetSlotMachineLuck(pb.luckValue)

		if pb.changeTasks ~= nil then
			for i = 1, #pb.changeTasks do
				local pbitem = pb.changeTasks[i]
				local infoTask = TaskMgr:Get(pbitem.id)

				infoTask:SetData(pbitem)
			end
		end
	end

	fun(pb)
end

function NetManager:RequestActiveLoginReward(configId, callback)
	local vPBMessage = protocol_pb.P147_Request()

	vPBMessage.configId = configId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvActiveLoginReward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P147_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestCharChapterData(roleId, callback)
	local vPBMessage = protocol_pb.P301_Request()

	vPBMessage.roleId = roleId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvCharChapterData(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P301_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		ChapterMgr:SetData(pb.chapters)

		local roleId = pb.request.roleId
		local infoChar = CharacterMgr:GetCharacter(roleId)

		infoChar.formation = {}

		for i = 1, #pb.formation do
			table.insert(infoChar.formation, pb.formation[i])
		end
	end

	fun(pb)
end

function NetManager:RequestShopGoods(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P311_Request")

	SetCallback(vGroup, callback, "P311_Request")
end

function OnRecvShopGoods(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P311_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestDownloadVoiceReward(roleId, callback)
	local vPBMessage = protocol_pb.P316_Request()

	vPBMessage.roleId = roleId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvDownloadVoiceReward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P316_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestGetActiveTaskReward(configId, taskId, callback)
	local vPBMessage = protocol_pb.P325_Request()

	vPBMessage.activeConsumeId = configId
	vPBMessage.taskId = taskId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetActiveTaskReward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P325_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
		ActiveManager:ChangeActiveTask(pb.taskInfo)
	end

	fun(pb)
end

function NetManager:RequestRefreshData(param, callback)
	local vPBMessage = protocol_pb.P10_Request()

	vPBMessage.param = param

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, "P10_Request")
end

function OnRecvRefreshData(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P10_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		InfoGameInst:SetRefreshData(pb.gameRefresh)

		if pb.items ~= nil and #pb.items > 0 then
			ItemManager:SetData(pb.items)
		end

		if pb.player ~= nil and pb.player.playerId ~= 0 then
			PlayerInst.InfoPlayer:SetData(pb.player)
		end

		if pb.roleCards ~= nil and #pb.roleCards > 0 then
			for i = 1, #pb.roleCards do
				local pbRoleCard = pb.roleCards[i]
				local infoRoleCard = RoleCardMgr:GetRoleCard(pbRoleCard.id)

				infoRoleCard:SetData(pbRoleCard)
			end
		end

		if pb.roles ~= nil and #pb.roles > 0 then
			for i = 1, #pb.roles do
				local pbRole = pb.roles[i]
				local infoRole = RoleMgr:GetRole(pbRole.id)

				if pbRole.id and pbRole.id > 0 then
					infoRole:SetData(pbRole)
				end
			end
		end
	end

	fun(pb)
end

function OnRecvRollingNotice(vMsg)
	local pb = protocol_pb.P140_Response()

	pb:ParseFromString(vMsg.BodyString)

	if not pb.id or not pb.params then
		return
	end

	Event.Instance:Fire(EventEnum.AddRollingNotice, pb.id, pb.params)
end

function OnRecvRollingNoticeTime(vMsg)
	local pb = protocol_pb.P141_Response()

	pb:ParseFromString(vMsg.BodyString)
	Event.Instance:Fire(EventEnum.AddRollingNoticeTime, pb.notice)
end

function NetManager:RequestSeasonData(seasonid, subSeasonNum, mark, callback)
	local vPBMessage = protocol_pb.P200_Request()

	vPBMessage.seasonId = seasonid
	vPBMessage.subSeasonNum = subSeasonNum
	vPBMessage.mark = mark

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSeasonData(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P200_Response()

	if pb.result.code == 0 then
		local fun = GetCallback(pb, vMsg)

		fun(pb)
	end
end

function NetManager:RequestSetTeam(seasonid, subseasonnum, attackteam, defensiveteam, attackingFetterTeamId, defensiveFetterTeamId, callback)
	local vPBMessage = protocol_pb.P201_Request()

	vPBMessage.seasonId = seasonid
	vPBMessage.subSeasonNum = subseasonnum

	if attackingFetterTeamId then
		vPBMessage.attackingFetterTeamId = attackingFetterTeamId
	end

	if defensiveFetterTeamId then
		vPBMessage.defensiveFetterTeamId = defensiveFetterTeamId
	end

	if attackteam ~= nil then
		for i, v in ipairs(attackteam) do
			table.insert(vPBMessage.attackingTeamRoleCards, v)
		end
	end

	if defensiveteam ~= nil then
		for i, v in ipairs(defensiveteam) do
			table.insert(vPBMessage.defensiveTeamRoleCards, v)
		end
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSetTeam(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P201_Response()

	if pb.result.code == 0 then
		local fun = GetCallback(pb, vMsg)

		fun(pb)
	end
end

function NetManager:RequestRefashopponent(seasonid, subseasonid, callback)
	local vPBMessage = protocol_pb.P202_Request()

	vPBMessage.seasonId = seasonid
	vPBMessage.subSeasonNum = subseasonid

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvRefashopponent(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P202_Response()

	if pb.result.code == 0 then
		local fun = GetCallback(pb, vMsg)

		fun(pb)
	end
end

function NetManager:RequestBeginBattle(seasonid, subseasonid, PlayerId, attackingFetterTeamId, callback)
	local vPBMessage = protocol_pb.P203_Request()

	vPBMessage.seasonId = seasonid
	vPBMessage.subSeasonNum = subseasonid
	vPBMessage.attackingFetterTeamId = attackingFetterTeamId
	vPBMessage.opponentPlayerId = tonumber(PlayerId)

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvBeginbBattle(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P203_Response()

	if pb.result.code == 0 then
		local fun = GetCallback(pb, vMsg)

		fun(pb)
	end
end

function NetManager:RequestBattleEnd(seasonId, subSeasonNum, battleid, battleWin, battleSeconds, battleRandoms, battleLogsLite, battlelogs, callback)
	local vPBMessage = protocol_pb.P204_Request()

	vPBMessage.battleId = battleid
	vPBMessage.battleLogs = battlelogs
	vPBMessage.battleWin = battleWin
	vPBMessage.battleSeconds = battleSeconds
	vPBMessage.seasonId = seasonId
	vPBMessage.subSeasonNum = subSeasonNum

	for i, v in ipairs(battleRandoms) do
		table.insert(vPBMessage.battleRandoms, v)
	end

	for i, v in ipairs(battleLogsLite) do
		table.insert(vPBMessage.battleLogsLite, v)
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvBattleEnd(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P204_Response()

	if pb.result.code == 0 then
		local fun = GetCallback(pb, vMsg)

		fun(pb)
	end
end

function NetManager:RequestSubRankList(rankingNo, rankingCount, callback)
	local vPBMessage = protocol_pb.P205_Request()

	vPBMessage.seasonId = 0
	vPBMessage.subSeasonNum = 0
	vPBMessage.rankingNo = rankingNo
	vPBMessage.rankingCount = rankingCount

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSubRankList(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P205_Response()

	if pb.result.code == 0 then
		-- block empty
	end
end

function NetManager:RequestPvPRecord(seasonid, subseasonnum, callback)
	local vPBMessage = protocol_pb.P206_Request()

	vPBMessage.seasonId = seasonid
	vPBMessage.subSeasonNum = subseasonnum

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvPVPRecord(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P206_Response()

	if pb.result.code == 0 then
		local fun = GetCallback(pb, vMsg)

		fun(pb)
	end
end

function NetManager:RequestPVPReward(seasonid, seasonnum, rankingId, callback)
	local vPBMessage = protocol_pb.P207_Request()

	vPBMessage.seasonId = seasonid
	vPBMessage.subSeasonNum = seasonnum
	vPBMessage.rankingId = rankingId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvPVPReward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P207_Response()

	if pb.result.code == 0 then
		-- block empty
	end

	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:RequestBuyPVPBattleNum(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P208_Request")

	SetCallback(vGroup, callback, "P208_Request")
end

function OnRecvBuyPVPBattleNum(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P208_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestTowerDailyGift(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P210_Request")

	SetCallback(vGroup, callback, "P210_Request")
end

function OnRecvTowerDailyGift(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P210_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		DealWithGetAward(pb.setter)

		TowerChapterMgr.dailyTimes = TowerChapterMgr.dailyTimes + 1

		ChapterRDL.TowerRDL.Sub()
	end

	fun(pb)
end

function NetManager:RequestRank(rankType, callback)
	local vPBMessage = protocol_pb.P220_Request()

	vPBMessage.rankType = rankType

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvRank(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P220_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		RankMgr:SetData(pb)
	end

	fun(pb)
end

function NetManager:RequestPvpShowTeam(playerId, callback)
	local vPBMessage = protocol_pb.P221_Request()

	vPBMessage.playerId = playerId
	vPBMessage.type = 1

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback)
end

function NetManager:RequestGvgShowTeam(playerId, callback)
	local vPBMessage = protocol_pb.P221_Request()

	vPBMessage.playerId = playerId
	vPBMessage.type = 2

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvPvpShowTeam(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P221_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestSynthetize(targetItem, num, callback)
	local vPBMessage = protocol_pb.P230_Request()

	vPBMessage.item = targetItem
	vPBMessage.num = num

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSynthetize(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P230_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestSynthetize2(targetItem, num, useItems, callback)
	local vPBMessage = protocol_pb.P1027_Request()

	vPBMessage.item = targetItem
	vPBMessage.num = num

	for _, e in pairs(useItems) do
		local useItem = protocol_pb.PBItem()

		useItem.id = e.id
		useItem.num = e.num

		table.insert(vPBMessage.costScrolls, useItem)
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSynthetize2(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1027_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
	end

	fun(pb)
end

function NetManager:RequestUnionBossRaidHarmRank(mirrorId, callback)
	local vPBMessage = protocol_pb.P225_Request()

	vPBMessage.mirrorId = mirrorId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback)
end

function OnRecvUnionBossRaidHarmRank(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P225_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestUnionBossRaidTeam(playerId, _type, callback)
	local vPBMessage = protocol_pb.P226_Request()

	vPBMessage.playerId = playerId
	vPBMessage.type = _type

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback)
end

function OnRecvUnionBossRaidTeam(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P226_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestBossRaidData(option, callback)
	local vPBMessage = protocol_pb.P250_Request()

	vPBMessage.option = option

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvBossRaidData(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P250_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		ActivityBossRaidMgr:SetData(pb, false)
	end

	fun(pb)
end

function NetManager:RequestBossRaidRecord(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P251_Request")

	SetCallback(vGroup, callback, "P251_Request")
end

function OnRecvBossRaidRecord(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P251_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		ActivityBossRaidMgr:SetData(pb, true)
		ChapterRDL.BossRaidRDL.Deal()
	end

	fun(pb)
end

function NetManager:RequestGetBossRaidReward(raidBossId, callback)
	local vPBMessage = protocol_pb.P252_Request()

	vPBMessage.raidBossId = raidBossId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetBossRaidReward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P252_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	fun(pb)
	ChapterRDL.BossRaidRDL.Deal()
end

function NetManager:RequestBossRaidDamage(raidBossId, callback)
	local vPBMessage = protocol_pb.P253_Request()

	print(raidBossId)

	vPBMessage.raidBossId = raidBossId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvBossRaidDamage(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P253_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestBossRaidPlayNum(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P254_Request")

	SetCallback(vGroup, callback, "P254_Request")
end

function OnRecvBossRaidPlayNum(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P254_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()
		ActivityBossRaidMgr:ResetPlayNum()
	end

	fun(pb)
end

function NetManager:RequestBossRaidShared(raidBossId, callback)
	local vPBMessage = protocol_pb.P255_Request()

	print(raidBossId)

	vPBMessage.raidBossId = raidBossId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvBossRaidShared(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P255_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		-- block empty
	end

	fun(pb)
end

function NetManager:RequestFinishIllustratedTask(figureId, callback)
	local vPBMessage = protocol_pb.P310_Request()

	vPBMessage.figureId = figureId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvFinishIllustratedTask(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P310_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		DealWithGetAward(pb.setter)
	end

	fun(pb)
end

function NetManager:RequestGetCollectionAward(lockType, awardId, callback, roleId)
	local vPBMessage = protocol_pb.P312_Request()

	vPBMessage.lockType = lockType

	if awardId then
		for i = 1, #awardId do
			table.insert(vPBMessage.awardId, awardId[i])
		end
	end

	NetManager.P312_type = lockType
	NetManager.P312_awardId = awardId
	NetManager.P312_roleId = roleId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetCollectionAward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P312_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		DealWithGetAward(pb.setter)

		for i = 1, #NetManager.P312_awardId do
			if NetManager.P312_type == eCollectionAwardType.FINALSKILL then
				ManualRDL.VideoRDL.SubNirvana(NetManager.P312_roleId[i], NetManager.P312_awardId[i])
			elseif NetManager.P312_type == eCollectionAwardType.PICTURE then
				ManualRDL.VideoRDL.SubIllustration(NetManager.P312_roleId[i], NetManager.P312_awardId[i])
			elseif NetManager.P312_type == eCollectionAwardType.SONG then
				ManualRDL.StoryRDL.SubSong(NetManager.P312_awardId[i])
			elseif NetManager.P312_type == eCollectionAwardType.VIDEO then
				ManualRDL.StoryRDL.SubVideo(NetManager.P312_awardId[i])
			end
		end
	end

	NetManager.P312_type = nil
	NetManager.P312_awardId = nil
	NetManager.P312_roleId = nil

	fun(pb)
end

function OnRecvBossRaidFinish(vMsg)
	local pb = protocol_pb.P320_Response()

	pb:ParseFromString(vMsg.BodyString)

	if pb.func == 1 then
		ActivityBossRaidMgr.selfBossEndTime = 0

		Event.Instance:Fire("UpdateBossRaidTime")
	end
end

function NetManager:RequestQuestionnaire(callback)
	local vPBMessage = protocol_pb.P330_Request()
	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvQuestionnaire(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P330_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:RequestGetQuestionReward(callback)
	local vPBMessage = protocol_pb.P331_Request()
	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetQuestionReward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P331_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		DealWithGetAward(pb.setter)
		InfoGameInst:ChangeQuestionAwardState(1)
		QuestionnaireRDL.SubQuestionnaireAward()
	end

	fun(pb)
end

function NetManager.GetConnectPBMsg()
	local vPBMessage = protocol_pb.P999_Request()

	vPBMessage.deviceOs = SystemInfoUtil.operatingSystem
	vPBMessage.deviceName = SystemInfoUtil.deviceModel
	vPBMessage.deviceId = SystemInfoUtil.deviceUniqueIdentifier
	vPBMessage.netType = tostring(Application.internetReachability)
	vPBMessage.platform = Application.platform:ToInt() == RuntimePlatform.Android and protocol_pb.google or protocol_pb.apple

	return vPBMessage:SerializeToString()
end

function NetManager:RequestBuyHistory(type, page, callback)
	local vPBMessage = protocol_pb.P1007_Request()

	vPBMessage.type = type
	vPBMessage.page = page

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvBuyHistoryRes(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1007_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:RequestOldSetter(year, month, callback)
	local vPBMessage = protocol_pb.P1008_Request()

	vPBMessage.year = year
	vPBMessage.month = month

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvOlderSetterRes(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1008_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		PlayerInst.InfoPlayer.billingState = pb.billingStateInfo
	end

	fun(pb)
end

function NetManager:RequestSaveOperationLog(type, productId, status, callback)
	local vPBMessage = protocol_pb.P1009_Request()

	vPBMessage.productType = type
	vPBMessage.productId = productId
	vPBMessage.status = status

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSaveOperationLogRes(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1009_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:RequestPrepurchase(productId, callback)
	local vPBMessage = protocol_pb.P1010_Request()

	vPBMessage.platformProductId = productId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnPrepurchaseRes(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1010_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:RequestShopPack(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P1011_Request")

	SetCallback(vGroup, callback, "P1011_Request")
end

function OnShopPackRes(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1011_Response()
	local fun = GetCallback(pb, vMsg, nil)

	PlayerInst.InfoPlayer.billingState = pb.billingStateInfo

	fun(pb)
end

function NetManager:RequestShopSnsCoin(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P1012_Request")

	SetCallback(vGroup, callback, "P1012_Request")
end

function OnShopSnsCoinRes(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1012_Response()
	local fun = GetCallback(pb, vMsg)

	PlayerInst.InfoPlayer.billingState = pb.billingStateInfo

	fun(pb)
end

function NetManager:RequestBillTask(receipt, transactionId, price, formattedPrice, platform, callback)
	local vPBMessage = protocol_pb.P1006_Request()

	vPBMessage.platform = platform
	vPBMessage.receipt = receipt
	vPBMessage.transactionId = transactionId
	vPBMessage.price = price
	vPBMessage.formattedPrice = formattedPrice

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function NetManager:RequestDebugBillTask(proId, callback)
	local vPBMessage = protocol_pb.P1017_Request()

	vPBMessage.platformProductId = proId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvDebugBilling(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1017_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		DealWithGetAwardKc(pb.setter)
	end

	fun(pb)
end

function OnRecvFormalBillRes(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1006_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		DealWithGetAwardKc(pb.setter)
	end

	fun(pb)
end

function NetManager:RequestStartUp(callback)
	OzBillingJackPot.GetResemaraDetectionIdentifier(function(remid)
		local vPBMessage = protocol_pb.P1000_Request()
		local randomKey = CryptographyUtil.RandomBytes(32)

		vPBMessage.mask = CryptographyUtil.GetMakData(randomKey)
		vPBMessage.resemaraDetectionIdentifier = remid
		vPBMessage.timeDifference = DateTimeUtil.TimeDifference

		local vGroup = ServerMsgSend.Instance:Send(vPBMessage, nil, nil, nil, true)

		vGroup.extra = randomKey

		SetCallback(vGroup, callback, vPBMessage)
	end)
end

function OnRecvStartup(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1000_Response()
	local fun, extra = GetCallback(pb, vMsg)

	fun(pb, extra)
end

function NetManager:DebugLogin(id, callback)
	OzBillingJackPot.GetResemaraDetectionIdentifier(function(remid)
		local vPBMessage = protocol_pb.P1020_Request()
		local randomKey = CryptographyUtil.RandomBytes(32)

		vPBMessage.mask = CryptographyUtil.GetMakData(randomKey)
		vPBMessage.playerId = id

		local vGroup = ServerMsgSend.Instance:Send(vPBMessage, nil, nil, nil, true)

		vGroup.extra = randomKey

		SetCallback(vGroup, callback, vPBMessage)
	end)
end

function OnRecvDebugLogin(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1020_Response()
	local fun, extra = GetCallback(pb, vMsg)

	fun(pb, extra)
end

function NetManager:StartLogin(token, pushToken, callback, setTop)
	local vPBMessage = protocol_pb.P1001_Request()

	vPBMessage.authToken = token

	local randomKey = CryptographyUtil.RandomBytes(32)

	vPBMessage.mask = CryptographyUtil.GetMakData(randomKey)
	vPBMessage.binary_hash = OzBillingJackPot.GenerateAssetStateLog(randomKey)
	vPBMessage.debugSysTime = NetManager.DebugSysTime
	vPBMessage.device = SystemInfoUtil.deviceModel
	vPBMessage.os = SystemInfoUtil.operatingSystem

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage, nil, nil, setTop)

	vGroup.extra = randomKey

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvNewLogin(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1001_Response()
	local fun, extra = GetCallback(pb, vMsg)

	NetData:SetServerTime(tonumber(pb.sysTime))

	PlayerInst.InfoPlayer.cautions = pb.cautions
	PlayerInst.InfoPlayer.showHomeCaution = pb.showHomeCaution
	PlayerInst.InfoPlayer.pid = pb.playerId

	if PlayerInst.InfoPlayer.pid ~= 0 then
		PlayerPrefs.SetString("PRE_USER_ID", tostring(PlayerInst.InfoPlayer.pid))
	end

	AppsFlyerService.SetCustomerUserID(pb.playerId)

	DateUtil.ServerTimeZone = pb.logicZoneOffset

	if pb.result.code == NetManager.Result_Sucess then
		NetworkManager.ConnectorGate:SaveSessionKey(pb.sessionKey, extra, false)
		NetworkManager.ConnectorGate:SetAsLogin(PlayerInst.InfoPlayer.pid)
	elseif pb.result.code == 4 then
		local function wrap_cb(...)
			Restart()
		end

		require("UI/Page/PageCaution/CautionBuilder")
		CautionBuilder.OpenPopForeverBan(pb.result.desc, wrap_cb)
	elseif pb.result.code == 5 then
		local function wrap_cb(index)
			PlayerPrefs.SetInt("GuidePassed", 1)
			Restart()
		end

		UIMgr.ShowDialog("更新の必要なデータを確認しました\nダウンロード後、タイトル画面に戻ります", wrap_cb)
	elseif pb.result.code == 6 then
		require("UI/Page/PageOtherMenu/PageAccountDel")
		UIMgr.AddPanel(PageAccountDel(), {
			blockSure = true,
			okText = _("Account_ApplyBeingButton"),
			title = _("Account_ApplyBeingTitle"),
			content = _("Account_ApplyBeingText")
		})
		LoadingMgr.Hide(eLoadingType.Repeat)
	elseif pb.result.code == 7 then
		require("UI/Page/PageOtherMenu/PageAccountDel")
		UIMgr.AddPanel(PageAccountDel(), {
			noClose = true,
			okText = _("UI_confirm"),
			title = _("Account_ApplyEndTitle"),
			content = _("Account_ApplyEndText"),
			cb = function()
				Launcher.Instance:Restart()
			end
		})
		LoadingMgr.Hide(eLoadingType.Repeat)
	end

	fun(pb)
end

function NetManager:GetPlatformUserData(token, pType, fbSerId, twId, twSecret, callback)
	local vPBMessage = protocol_pb.P1005_Request()

	vPBMessage.authToken = token
	vPBMessage.serviceType = pType

	if fbSerId then
		vPBMessage.fbServiceId = fbSerId
	end

	if twId then
		vPBMessage.twId = twId
	end

	if twSecret then
		vPBMessage.twSecret = twSecret
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvGetPlatformUser(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1005_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:PlatfromDataRecover(platformToken, pType, fbSerId, twId, twSecret, userToken, callback)
	local vPBMessage = protocol_pb.P1002_Request()
	local randomKey = CryptographyUtil.RandomBytes(32)

	vPBMessage.mask = CryptographyUtil.GetMakData(randomKey)
	vPBMessage.authToken = platformToken

	if userToken then
		vPBMessage.playerAuthToken = userToken
	end

	vPBMessage.serviceType = pType

	if fbSerId then
		vPBMessage.fbServiceId = fbSerId
	end

	if twId then
		vPBMessage.twId = twId
	end

	if twSecret then
		vPBMessage.twSecret = twSecret
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage, nil, nil, nil, true)

	vGroup.extra = randomKey

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvPlatfromRecover(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1002_Response()
	local fun, extra = GetCallback(pb, vMsg)

	fun(pb, extra)
end

function NetManager:StartLink(ctrl, pType, callback)
	local vPBMessage = protocol_pb.P1003_Request()

	vPBMessage.authToken = ctrl.AccessToken
	vPBMessage.serviceType = pType

	if vPBMessage.serviceType == protocol_pb.facebook then
		vPBMessage.fbServiceId = ctrl.EncryptedServiceId
	end

	if vPBMessage.serviceType == protocol_pb.twitter then
		vPBMessage.twId = ctrl.EncryptedTwitterId
		vPBMessage.twSecret = ctrl.EncryptedTwitterSecret
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvPlatformLink(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1003_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:UnLink(accessToken, pType, callback)
	local vPBMessage = protocol_pb.P1004_Request()

	vPBMessage.serviceType = pType
	vPBMessage.unlinkAuth = accessToken

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	vGroup.extra = pType

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvPlatformUnLink(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1004_Response()
	local fun, extra = GetCallback(pb, vMsg)

	fun(pb, extra)
end

function NetManager:FetchLinkState(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P1013_Request")

	SetCallback(vGroup, callback, "P1013_Request")
end

function OnRecvFetchLinkState(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1013_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:SendTermsVersion(callback)
	local vPBMessage = protocol_pb.P1014_Request()

	vPBMessage.termsVersion = GetConfigArgInt("TermsOfUseVersion")

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSendTermsVersion(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1014_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:GetClearedPlatformAchievement(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P1015_Request")

	SetCallback(vGroup, callback, "P1015_Request")
end

function OnRecvGetClearedPlatformAchievement(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1015_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:ReadCaution(id, callback)
	local vPBMessage = protocol_pb.P1016_Request()

	vPBMessage.cautionId = id

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvCaution(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1016_Response()
	local fun = GetCallback(pb, vMsg)

	PlayerInst.InfoPlayer.showHomeCaution = false
	PlayerInst.InfoPlayer.cautions = pb.cautions

	fun(pb)
end

function NetManager:GetRequestReview(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P1018_Request")

	SetCallback(vGroup, callback, "P1018_Request")
end

function OnRecvGetRequestReview(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1018_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:SendRequestReviewStatus(requestReviewId, status, callback)
	local vPBMessage = protocol_pb.P1019_Request()

	vPBMessage.requestReviewId = requestReviewId
	vPBMessage.status = status

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSendRequestReviewStatus(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1019_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:SendRequestGetProductRate(goodsId, callback)
	local vPBMessage = protocol_pb.P1023_Request()

	vPBMessage.goodsId = goodsId

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSendRequestGetProductRate(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1023_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:GetSyncResource(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P1024_Request")

	SetCallback(vGroup, callback, "P1024_Request")
end

function OnRecvSyncResource(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1024_Response()
	local fun = GetCallback(pb, vMsg)

	PlayerInst.InfoPlayer:SetPlayerRes(pb.player)
	PlayerInst.InfoPlayer:SetFreeDraw(pb.freeTenDrawCount, pb.curFreeTenDrawActivityId, pb.usedTenDrawCount, pb.todayTenDrawCount)
	ItemManager:SetData(pb.items)
	fun(pb)
end

function OnRecvSyncResourcePush(vMsg)
	local pb = protocol_pb.P1025_Response()

	pb:ParseFromString(vMsg.BodyString)

	local currScene = SceneMgr.GetCurrentScene()

	if currScene and (currScene.className == "SceneFightNormal" or currScene.className == "SceneFightBoss") then
		CACHED_PLAYER = pb.player
	else
		TimerMgr.AddTimer(eTimerType.RealTime, 0.2, function()
			PlayerInst.InfoPlayer:SetPlayerRes(pb.player)
			ItemManager:SetData(pb.items)
			Event.Instance:Fire(EventEnum.UpdatePlayerInfo)
		end, nil)
		TimerMgr.AddTimer(eTimerType.RealTime, 0.5, function()
			PlayerInst.InfoPlayer:SetPlayerRes(pb.player)
			Event.Instance:Fire(EventEnum.UpdatePlayerInfo)
		end, nil)
	end
end

function NetManager:RequestSpeicalTaskAward(taskIds, callback)
	local vPBMessage = protocol_pb.P1026_Request()

	for i = 1, #taskIds do
		table.insert(vPBMessage.taskIds, taskIds[i])
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvSpeicalTaskAward(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1026_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		DealWithGetAward(pb.setter, false)
		TaskManager:SetSpeicalData(pb.changeTasks)

		local removedTasks = {}

		for k, v in pairs(pb.changeTasks) do
			table.insert(removedTasks, v.id)
		end

		TaskRDL.RemoveReceivedTask(removedTasks)
		TaskRDL.AddCanReceiveTask(pb.changeTasks)
	end

	fun(pb)
end

function NetManager:GetSpeicalTaskInfo(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P1028_Request")

	SetCallback(vGroup, callback, "P1028_Request")
end

function OnRecvTaskInfo(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1028_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		TaskManager:SetSpeicalData(pb.tasks)
	end

	fun(pb)
end

function NetManager:GetTimeSpaceData(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P1100_Request")

	SetCallback(vGroup, callback, "P1100_Request")
end

function OnRecvTimeSpaceData(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1100_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		TimeSpaceChapterMgr:SetData(pb.chapter, pb.freezedCardList)

		if pb.items then
			ItemManager:SetData(pb.items)
		end

		local InfoTsTeam = require("Info/InfoTeamTimespace")

		InfoTsTeam:SetData(pb.chapterTeams)

		TimeSpaceChapterMgr.StartTime = pb.startTime
		TimeSpaceChapterMgr.EndTime = pb.endTime
	end

	fun(pb)
end

function NetManager:ResetTimespaceChapter(callback)
	local vGroup = ServerMsgSend.Instance:SendByName("P1101_Request")

	SetCallback(vGroup, callback, "P1101_Request")
end

function OnRecvResetChapter(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1101_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == NetManager.Result_Sucess then
		TimeSpaceChapterMgr:SetRoleCardFreeze(false)
		TimeSpaceChapterMgr:SetData(pb.chapter)
		TimeSpaceChapterMgr:Refresh()
		fun(true)
	else
		fun(false)
	end
end

function NetManager:RequestTimeSpaceTeam(id, name, ids, fetterId, callback)
	local vPBMessage = protocol_pb.P1103_Request()

	vPBMessage.teamId = id
	vPBMessage.teamName = name

	if ids then
		for i, v in ipairs(ids) do
			table.insert(vPBMessage.roleCardTeams, v)
		end
	end

	if fetterId then
		vPBMessage.fetterTeamId = fetterId
	end

	local vGroup = ServerMsgSend.Instance:Send(vPBMessage)

	SetCallback(vGroup, callback, vPBMessage)
end

function OnRecvTimeSpaceTeam(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1103_Response()
	local fun = GetCallback(pb, vMsg)

	fun(pb)
end

function NetManager:RequestACDel(cb)
	local vGroup = ServerMsgSend.Instance:SendByName("P1104_Request")

	SetCallback(vGroup, cb, "P1104_Request")
end

function OnRecvACDelete(vMsg)
	if DealWithTimeout(vMsg) then
		return
	end

	local pb = protocol_pb.P1104_Response()
	local fun = GetCallback(pb, vMsg)

	if pb.result.code == 0 then
		fun(pb)
		Launcher.Instance:Restart()
	end
end

function NetManager:RegisterEvent()
	Dispatcher.Instance:AddObserver(0, OnRecvHandShackRes)
	Dispatcher.Instance:AddObserver(1, OnRecvCheckVersionRes)
	Dispatcher.Instance:AddObserver(2, OnRecvLogin)
	Dispatcher.Instance:AddObserver(3, OnRecvLogout)
	Dispatcher.Instance:AddObserver(4, OnRecvCommand)
	Dispatcher.Instance:AddObserver(9, OnRecvGetBasePlayerInfo)
	Dispatcher.Instance:AddObserver(10, OnRecvRefreshData)
	Dispatcher.Instance:AddObserver(11, OnRecvGetPlayerInfo)
	Dispatcher.Instance:AddObserver(12, OnRecvSubmitPlayerInfo)
	Dispatcher.Instance:AddObserver(13, OnRecvModifyPlayerInfo)
	Dispatcher.Instance:AddObserver(16, OnRecvTalentUpLevel)
	Dispatcher.Instance:AddObserver(17, OnRecvRoleCardStarAward)
	Dispatcher.Instance:AddObserver(14, OnRecvOperateItem)
	Dispatcher.Instance:AddObserver(15, OnRecvUpgradeRoleStar)
	Dispatcher.Instance:AddObserver(18, OnRecvEquipCard)
	Dispatcher.Instance:AddObserver(19, OnRecvDevelopAll)
	Dispatcher.Instance:AddObserver(20, OnRecvEquipIntense)
	Dispatcher.Instance:AddObserver(21, OnRecvEquipWeaponAvatar)
	Dispatcher.Instance:AddObserver(22, OnRecvEquipEnchant)
	Dispatcher.Instance:AddObserver(23, OnRecvEquipEnchantResult)
	Dispatcher.Instance:AddObserver(25, OnRecvGetWorks)
	Dispatcher.Instance:AddObserver(26, OnRecvPickWork)
	Dispatcher.Instance:AddObserver(27, OnRecvCompleteWork)
	Dispatcher.Instance:AddObserver(28, OnRecvBuyWork)
	Dispatcher.Instance:AddObserver(30, OnRecvTalentNode)
	Dispatcher.Instance:AddObserver(31, OnRecvUpCardPetal)
	Dispatcher.Instance:AddObserver(32, OnRecvPetalAward)
	Dispatcher.Instance:AddObserver(33, OnRecvExchangeCardStarSton)
	Dispatcher.Instance:AddObserver(34, OnRecvExchangeRoleCard)
	Dispatcher.Instance:AddObserver(35, OnRecvEquipAvatar)
	Dispatcher.Instance:AddObserver(36, OnRecvBuyAvatar)
	Dispatcher.Instance:AddObserver(37, OnRecvBindBPAvatar)
	Dispatcher.Instance:AddObserver(39, OnRecvExploreLiveEnd)
	Dispatcher.Instance:AddObserver(40, OnRecvGetChapterAward)
	Dispatcher.Instance:AddObserver(41, OnRecvSetFormation)
	Dispatcher.Instance:AddObserver(42, OnRecvStartStage)
	Dispatcher.Instance:AddObserver(43, OnRecvEndStage)
	Dispatcher.Instance:AddObserver(44, OnRecvWipeStage)
	Dispatcher.Instance:AddObserver(46, OnRecvUpdateActive)
	Dispatcher.Instance:AddObserver(47, OnRecvHelpFight)
	Dispatcher.Instance:AddObserver(48, OnRecvAddStageTypeNum)
	Dispatcher.Instance:AddObserver(49, OnRecvBuyPower)
	Dispatcher.Instance:AddObserver(50, OnRecvGvgHelpFight)
	Dispatcher.Instance:AddObserver(51, OnRecvGiveUpTask)
	Dispatcher.Instance:AddObserver(52, OnRecvGetTaskReward)
	Dispatcher.Instance:AddObserver(53, OnRecvStartTask)
	Dispatcher.Instance:AddObserver(54, OnRecvGetFavor)
	Dispatcher.Instance:AddObserver(55, OnRecvResetFavorTouchCount)
	Dispatcher.Instance:AddObserver(56, OnRecvSendGift)
	Dispatcher.Instance:AddObserver(57, OnRecvGetFavorAward)
	Dispatcher.Instance:AddObserver(58, OnRecvGetRoleGift)
	Dispatcher.Instance:AddObserver(59, OnRecvBattlePassAddLevel)
	Dispatcher.Instance:AddObserver(60, OnRecvTaskList)
	Dispatcher.Instance:AddObserver(61, OnRecvTaskChange)
	Dispatcher.Instance:AddObserver(62, OnRecvTaskLineScoreReward)
	Dispatcher.Instance:AddObserver(63, OnRecvChangeTasks)
	Dispatcher.Instance:AddObserver(64, OnRecvCompleteTasksOneKey)
	Dispatcher.Instance:AddObserver(65, OnRecvBuyTheme)
	Dispatcher.Instance:AddObserver(66, OnRecvGetThemeAward)
	Dispatcher.Instance:AddObserver(67, OnRecvSetThemePosition)
	Dispatcher.Instance:AddObserver(68, OnRecvRemoveFriend)
	Dispatcher.Instance:AddObserver(69, OnRecvAddFriend)
	Dispatcher.Instance:AddObserver(70, OnRecvAgreeFriend)
	Dispatcher.Instance:AddObserver(71, OnRecvDenyFriend)
	Dispatcher.Instance:AddObserver(74, OnRecvFriendGift)
	Dispatcher.Instance:AddObserver(77, OnRecvGetWorkFriData)
	Dispatcher.Instance:AddObserver(80, OnRecvGetMails)
	Dispatcher.Instance:AddObserver(81, OnRecvMailsGift)
	Dispatcher.Instance:AddObserver(82, OnRecvDeleteMail)
	Dispatcher.Instance:AddObserver(83, OnRecvPushMail)
	Dispatcher.Instance:AddObserver(84, OnRecvWebviewReward)
	Dispatcher.Instance:AddObserver(90, OnRecvAnswerReward)
	Dispatcher.Instance:AddObserver(91, OnRecvEndTopic)
	Dispatcher.Instance:AddObserver(92, OnRecvModifyTopicName)
	Dispatcher.Instance:AddObserver(95, OnRecvGetCardPoolInfo)
	Dispatcher.Instance:AddObserver(96, OnRecvPurchaseCard)
	Dispatcher.Instance:AddObserver(97, OnRecvGetWeekRolePoolInfo)
	Dispatcher.Instance:AddObserver(98, OnRecvGetWeekRole)
	Dispatcher.Instance:AddObserver(100, OnRecvDrawCardPool)
	Dispatcher.Instance:AddObserver(101, OnRecvDrawCard)
	Dispatcher.Instance:AddObserver(102, OnRecvDrawCardRecord)
	Dispatcher.Instance:AddObserver(103, OnRecvChargeCardPoolCost)
	Dispatcher.Instance:AddObserver(105, OnRecvGetActityPool)
	Dispatcher.Instance:AddObserver(106, OnRecvDrawActityPool)
	Dispatcher.Instance:AddObserver(107, OnRecvOpenActityPool)
	Dispatcher.Instance:AddObserver(108, OnRecvCardPoolInfo)
	Dispatcher.Instance:AddObserver(110, OnRecvPlayerInfo)
	Dispatcher.Instance:AddObserver(111, OnRecvFriendList)
	Dispatcher.Instance:AddObserver(112, OnRecvRecommendList)
	Dispatcher.Instance:AddObserver(113, OnRecvSearchFriend)
	Dispatcher.Instance:AddObserver(114, OnRecvAddFriend)
	Dispatcher.Instance:AddObserver(115, OnRecvDealWithFriendRequest)
	Dispatcher.Instance:AddObserver(116, OnRecvDealWithFriendCoin)
	Dispatcher.Instance:AddObserver(117, OnRecvDealWithFriendRelation)
	Dispatcher.Instance:AddObserver(118, OnRecvPlayerApplyAndAgree)
	Dispatcher.Instance:AddObserver(119, OnRecvFriendGiftCoin)
	Dispatcher.Instance:AddObserver(340, OnRecvDeleteFriend)
	Dispatcher.Instance:AddObserver(120, OnRecvGetPurchaseList)
	Dispatcher.Instance:AddObserver(121, OnRecvPurchasePruduct)
	Dispatcher.Instance:AddObserver(122, OnRecvPurchaseReward)
	Dispatcher.Instance:AddObserver(123, OnRecvGetPurchaseReward)
	Dispatcher.Instance:AddObserver(124, OnRecvGetGoodsInfo)
	Dispatcher.Instance:AddObserver(129, OnRecvPurchaseActivePruduct)
	Dispatcher.Instance:AddObserver(130, OnRecvClientAction)
	Dispatcher.Instance:AddObserver(131, OnRecvOperationActiveAward)
	Dispatcher.Instance:AddObserver(132, OnRecvActiveOperates)
	Dispatcher.Instance:AddObserver(133, OnRecvGetShareReward)
	Dispatcher.Instance:AddObserver(134, OnRecvRestRecharge)
	Dispatcher.Instance:AddObserver(135, OnRecvGetRechargeReward)
	Dispatcher.Instance:AddObserver(145, OnRecvGetFirstPurchaseReward)
	Dispatcher.Instance:AddObserver(150, OnRecvUseItemChest)
	Dispatcher.Instance:AddObserver(151, OnRecvExpireItemExchange)
	Dispatcher.Instance:AddObserver(160, OnRecvUnionList)
	Dispatcher.Instance:AddObserver(161, OnRecvCreateUnion)
	Dispatcher.Instance:AddObserver(162, OnRecvApplyJoinUnion)
	Dispatcher.Instance:AddObserver(163, OnRecvUnionMembers)
	Dispatcher.Instance:AddObserver(164, OnRecvMembersAndLogs)
	Dispatcher.Instance:AddObserver(165, OnRecvQuitUnion)
	Dispatcher.Instance:AddObserver(166, OnRecvUnionSetting)
	Dispatcher.Instance:AddObserver(167, OnRecvOperateUnionOrMember)
	Dispatcher.Instance:AddObserver(168, OnRecvPushUnionOrLog)
	Dispatcher.Instance:AddObserver(187, OnRecvReleUnionData)
	Dispatcher.Instance:AddObserver(169, OnReceiveWishSend)
	Dispatcher.Instance:AddObserver(170, OnRecvUnionWishList)
	Dispatcher.Instance:AddObserver(171, OnRecvGetWish)
	Dispatcher.Instance:AddObserver(172, OnRecvThankPlayer)
	Dispatcher.Instance:AddObserver(173, OnRecvReleaseWish)
	Dispatcher.Instance:AddObserver(174, OnRecvReachPlayerWish)
	Dispatcher.Instance:AddObserver(175, OnRecvMineWishRecords)
	Dispatcher.Instance:AddObserver(176, OnRecvUnionSkill)
	Dispatcher.Instance:AddObserver(177, OnRecvProvideUnionSkillExp)
	Dispatcher.Instance:AddObserver(178, OnRecvSetUnionSkillHotSpot)
	Dispatcher.Instance:AddObserver(179, OnRecvUpUnionSkillLevel)
	Dispatcher.Instance:AddObserver(180, OnRecvUnionRaidData)
	Dispatcher.Instance:AddObserver(182, OnRecvSelectEvent)
	Dispatcher.Instance:AddObserver(183, OnRecvRaidAward)
	Dispatcher.Instance:AddObserver(184, OnRecvRaidAwardRecord)
	Dispatcher.Instance:AddObserver(185, OnRecvRestoreCardHp)
	Dispatcher.Instance:AddObserver(186, OnRecvChangeMirrorTeam)
	Dispatcher.Instance:AddObserver(188, OnRecvUnionRaidReakAward)
	Dispatcher.Instance:AddObserver(189, OnRecvUnionRaidcontributionAward)
	Dispatcher.Instance:AddObserver(190, OnRecvGvg)
	Dispatcher.Instance:AddObserver(191, OnRecvGvgSetter)
	Dispatcher.Instance:AddObserver(192, OnRecvGvgState)
	Dispatcher.Instance:AddObserver(193, OnRecvGvgContribution)
	Dispatcher.Instance:AddObserver(195, OnRecvGvgBuyGoods)
	Dispatcher.Instance:AddObserver(197, OnRecvGvgLogs)
	Dispatcher.Instance:AddObserver(198, OnRecvRepeatedBattle)
	Dispatcher.Instance:AddObserver(199, OnRecvGvgHelpAward)
	Dispatcher.Instance:AddObserver(240, OnRecvBondageSkillUpgrade)
	Dispatcher.Instance:AddObserver(146, OnRecvDrawReward)
	Dispatcher.Instance:AddObserver(147, OnRecvActiveLoginReward)
	Dispatcher.Instance:AddObserver(190, OnRecvFinishGuide)
	Dispatcher.Instance:AddObserver(301, OnRecvCharChapterData)
	Dispatcher.Instance:AddObserver(311, OnRecvShopGoods)
	Dispatcher.Instance:AddObserver(316, OnRecvDownloadVoiceReward)
	Dispatcher.Instance:AddObserver(325, OnRecvGetActiveTaskReward)
	Dispatcher.Instance:AddObserver(140, OnRecvRollingNotice)
	Dispatcher.Instance:AddObserver(141, OnRecvRollingNoticeTime)
	Dispatcher.Instance:AddObserver(200, OnRecvSeasonData)
	Dispatcher.Instance:AddObserver(201, OnRecvSetTeam)
	Dispatcher.Instance:AddObserver(202, OnRecvRefashopponent)
	Dispatcher.Instance:AddObserver(203, OnRecvBeginbBattle)
	Dispatcher.Instance:AddObserver(204, OnRecvBattleEnd)
	Dispatcher.Instance:AddObserver(205, OnRecvSubRankList)
	Dispatcher.Instance:AddObserver(206, OnRecvPVPRecord)
	Dispatcher.Instance:AddObserver(207, OnRecvPVPReward)
	Dispatcher.Instance:AddObserver(208, OnRecvBuyPVPBattleNum)
	Dispatcher.Instance:AddObserver(210, OnRecvTowerDailyGift)
	Dispatcher.Instance:AddObserver(220, OnRecvRank)
	Dispatcher.Instance:AddObserver(221, OnRecvPvpShowTeam)
	Dispatcher.Instance:AddObserver(225, OnRecvUnionBossRaidHarmRank)
	Dispatcher.Instance:AddObserver(226, OnRecvUnionBossRaidTeam)
	Dispatcher.Instance:AddObserver(230, OnRecvSynthetize)
	Dispatcher.Instance:AddObserver(250, OnRecvBossRaidData)
	Dispatcher.Instance:AddObserver(251, OnRecvBossRaidRecord)
	Dispatcher.Instance:AddObserver(252, OnRecvGetBossRaidReward)
	Dispatcher.Instance:AddObserver(253, OnRecvBossRaidDamage)
	Dispatcher.Instance:AddObserver(254, OnRecvBossRaidPlayNum)
	Dispatcher.Instance:AddObserver(255, OnRecvBossRaidShared)
	Dispatcher.Instance:AddObserver(320, OnRecvBossRaidFinish)
	Dispatcher.Instance:AddObserver(310, OnRecvFinishIllustratedTask)
	Dispatcher.Instance:AddObserver(312, OnRecvGetCollectionAward)
	Dispatcher.Instance:AddObserver(1000, OnRecvStartup)
	Dispatcher.Instance:AddObserver(1001, OnRecvNewLogin)
	Dispatcher.Instance:AddObserver(1002, OnRecvPlatfromRecover)
	Dispatcher.Instance:AddObserver(1003, OnRecvPlatformLink)
	Dispatcher.Instance:AddObserver(1004, OnRecvPlatformUnLink)
	Dispatcher.Instance:AddObserver(1005, OnRecvGetPlatformUser)
	Dispatcher.Instance:AddObserver(1006, OnRecvFormalBillRes)
	Dispatcher.Instance:AddObserver(1007, OnRecvBuyHistoryRes)
	Dispatcher.Instance:AddObserver(1008, OnRecvOlderSetterRes)
	Dispatcher.Instance:AddObserver(1009, OnRecvSaveOperationLogRes)
	Dispatcher.Instance:AddObserver(1010, OnPrepurchaseRes)
	Dispatcher.Instance:AddObserver(1011, OnShopPackRes)
	Dispatcher.Instance:AddObserver(1012, OnShopSnsCoinRes)
	Dispatcher.Instance:AddObserver(1013, OnRecvFetchLinkState)
	Dispatcher.Instance:AddObserver(1014, OnRecvSendTermsVersion)
	Dispatcher.Instance:AddObserver(1015, OnRecvGetClearedPlatformAchievement)
	Dispatcher.Instance:AddObserver(330, OnRecvQuestionnaire)
	Dispatcher.Instance:AddObserver(331, OnRecvGetQuestionReward)
	Dispatcher.Instance:AddObserver(1018, OnRecvGetRequestReview)
	Dispatcher.Instance:AddObserver(1016, OnRecvCaution)
	Dispatcher.Instance:AddObserver(1017, OnRecvDebugBilling)
	Dispatcher.Instance:AddObserver(1019, OnRecvSendRequestReviewStatus)
	Dispatcher.Instance:AddObserver(1020, OnRecvDebugLogin)
	Dispatcher.Instance:AddObserver(1023, OnRecvSendRequestGetProductRate)
	Dispatcher.Instance:AddObserver(1024, OnRecvSyncResource)
	Dispatcher.Instance:AddObserver(1025, OnRecvSyncResourcePush)
	Dispatcher.Instance:AddObserver(1026, OnRecvSpeicalTaskAward)
	Dispatcher.Instance:AddObserver(1027, OnRecvSynthetize2)
	Dispatcher.Instance:AddObserver(1028, OnRecvTaskInfo)
	Dispatcher.Instance:AddObserver(1100, OnRecvTimeSpaceData)
	Dispatcher.Instance:AddObserver(1101, OnRecvResetChapter)
	Dispatcher.Instance:AddObserver(1103, OnRecvTimeSpaceTeam)
	Dispatcher.Instance:AddObserver(1104, OnRecvACDelete)
end
