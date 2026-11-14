-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Manager/SDKMgr.lua

SDKPlatform = {
	Sb = 4,
	Other = 3,
	Dream = 1,
	Quick = 2
}
ShareType = {
	WB = 5,
	WXFriendCircle = 2,
	QQZone = 4,
	WXFavorite = 6,
	WXFrend = 1,
	QQ = 3
}
SDKMgr = class("SDKMgr")

function SDKMgr:ctor()
	self.CurPlatform = SDKPlatform.Dream
end

function SDKMgr:GetSDKLoginDomin()
	local strDomin = NetManager:GetDominOuter()

	if NetManager.channel == 10 then
		return strDomin .. "/dream/verify.do"
	elseif NetManager.channel == 11 then
		return strDomin .. "/dream48/verify.do"
	else
		return strDomin .. "/" .. NetManager.channel .. "/verify.do"
	end

	return ""
end

function SDKMgr:Init()
	return
end

function SDKMgr:Login(callback)
	OzSDKManager.Instance:LoginSDK(callback)
end

function SDKMgr:GetLoginInfo(strToken, callback)
	if self.CurPlatform == SDKPlatform.Quick then
		if QuickSDKMgr.Instance ~= nil then
			QuickSDKMgr.Instance:GetLoginInfo(self:GetSDKLoginDomin(), strToken, callback)
		end
	elseif SDKInterface.Instance ~= nil then
		SDKInterface.Instance:GetLoginInfo(self:GetSDKLoginDomin(), self:GetChannelUserID(), "1", strToken, callback)
	end
end

function SDKMgr:GetChannelUserID()
	if self.CurPlatform == SDKPlatform.Quick then
		if QuickSDKMgr.Instance ~= nil then
			return QuickSDKMgr.Instance:GetUserId()
		end
	elseif Application.platform == UnityEngine.RuntimePlatform.Android then
		return "103000"
	else
		return "100000"
	end

	return "0"
end

function SDKMgr:Logout(callback)
	OzSDKManager.Instance:LoginOutSDK(callback)
end

function SDKMgr:Pay(callback, data)
	OzSDKManager.Instance.role = PlayerInst.InfoPlayer.name
	OzSDKManager.Instance.total_fee = data.total_fee
	OzSDKManager.Instance.game_money = data.game_money
	OzSDKManager.Instance.out_trade_no = data.out_trade_no or ""
	OzSDKManager.Instance.subject = data.subject or ""
	OzSDKManager.Instance.body = data.body or ""
	OzSDKManager.Instance.extension_info = data.extension_info or ""
	OzSDKManager.Instance.notify_url = data.notify_url or ""
	OzSDKManager.Instance.order_sign = data.order_sign or ""
	OzSDKManager.Instance.productId = data.productId or ""

	print("SDKMgr:PaySDKMgr:PaySDKMgr:Pay")
	OzSDKManager.Instance:Pay(callback)
end

function SDKMgr:GetUserInfo(callback)
	OzSDKManager.Instance:GetUserInfo(callback)
end

function SDKMgr:LoginArea(areaId)
	if NetManager.IsUseSDK then
		OzSDKManager.Instance:LoginArea(areaId)
	end
end

function SDKMgr:NotifyZone(roleId, roleName)
	if NetManager.IsUseSDK then
		OzSDKManager.Instance:NotifyZone(roleId, roleName)
	end
end

function SDKMgr:CreateRole(roleId, roleName)
	if NetManager.IsUseSDK then
		OzSDKManager.Instance:CreateRole(roleId, roleName)
	end
end

function SDKMgr:GetIsRealName()
	if NetManager.IsUseSDK then
		OzSDKManager.Instance:GetIsRealName()
	end
end

function SDKMgr:GetShareContent(shareType, imgPath)
	local shareType = tostring(shareType)
	local title = Localization.Get("DESC_Share")
	local summary = Localization.Get("DESC_ShareSummary")
	local url = ""

	return shareType, title, summary, url, imgPath
end

function SDKMgr:Share(shareType, imgPath, callback)
	if shareType == nil then
		return
	end

	if self.CurPlatform == SDKPlatform.Quick then
		if ShareSDKMgr.Instance ~= nil then
			ShareSDKMgr.Instance:SetShareCallback(callback)
			ShareSDKMgr.Instance:Share(self:GetShareContent(shareType, imgPath))
		end
	elseif SDKInterface.Instance ~= nil then
		SDKInterface.Instance:SetShareCallback(callback)
		SDKInterface.Share(self:GetShareContent(shareType, imgPath))
	end
end

function SDKMgr:OnUpdateRoleInfo()
	return
end

function SDKMgr:OnEnterGame()
	return
end

function SDKMgr:OnCreatRole()
	return
end

function SDKMgr:GoToComment()
	OzSDKManager.Instance:GoToComment()
end

SDKMgr.CMDID = {
	EXIT_PAGE = 3,
	SUBMIT_EXTEND_DATA = 1,
	PAUSE_PAGE = 2,
	ENTER_GAME = 4,
	GUEST_UPGRADE = 5
}
SDKMgr.SUBTYPE = {
	exitServer = 5,
	selectServer = 2,
	levelUp = 4,
	createRole = 1,
	enterServer = 3
}

function SDKMgr:OnExtendData(commondId, subType)
	if commondId == SDKMgr.CMDID.SUBMIT_EXTEND_DATA then
		local extendData = OzSDKManager.Instance.extendData

		extendData.roleId = tostring(PlayerInst.InfoPlayer.pid)
		extendData.roleName = PlayerInst.InfoPlayer.name
		extendData.roleLevel = PlayerInst:GetCurLv()
		extendData.roleCreateTime = tonumber(PlayerInst.InfoPlayer.regTime)
		extendData.roleLevelUpdateTime = tonumber(PlayerInst.InfoPlayer.levelTime)
		extendData.zoneId = tonumber(NetData.ServerID)
		extendData.zoneName = NetData.ServerName
		extendData.payTotal = 0
		extendData.remainCoinNum = 0
		extendData.power = PlayerInst.InfoPlayer.power
		extendData.experience = PlayerInst.InfoPlayer.exp
	end

	OzSDKManager.Instance:DoExtend(commondId, subType)
end

function SDKMgr.GetInstance()
	SDKMgr.Instance = SDKMgr.Instance or SDKMgr()

	return SDKMgr.Instance
end
