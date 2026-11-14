-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/FriendRDL.lua

FriendRDL = {}

local RD_Friend_Branch_Path = {
	Apply = "Arrow/Friend/Apply",
	Gift = "Arrow/Friend/Gift"
}
local KEY_RD_FRIEND_APPLY = "KEY_RD_FRIEND_APPLY"
local IsViewedApply = false
local PreApplyNum = 0
local maxRecvFriendCoinNum = GetConfigArgInt("FriendGiftMax")
local simulateRecvNum = 0

function FriendRDL.InitRD()
	PreApplyNum = table.getn(FriendMgr.listApply)

	if PreApplyNum > 0 then
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Friend_Branch_Path.Apply, 1)
	else
		IsViewedApply = true
	end

	FriendRDL.InitGiftRD()
end

function FriendRDL.InitGiftRD()
	simulateRecvNum = 0

	local t = FriendMgr.listFriend or {}
	local recvNum = InfoGameInst.todayRecvFriendCoinNum

	for _, friend in pairs(t) do
		if friend.coinState == Friend_Gift_State.Have and recvNum + simulateRecvNum < maxRecvFriendCoinNum then
			simulateRecvNum = simulateRecvNum + 1
		end
	end

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Friend_Branch_Path.Gift, simulateRecvNum)
end

function FriendRDL.AddFriendGift()
	if InfoGameInst.todayRecvFriendCoinNum + simulateRecvNum >= maxRecvFriendCoinNum then
		return
	end

	simulateRecvNum = simulateRecvNum + 1

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Friend_Branch_Path.Gift, simulateRecvNum)
end

function FriendRDL.RemoveFriendGift(value)
	value = value or 1
	simulateRecvNum = simulateRecvNum - value
	simulateRecvNum = simulateRecvNum < 0 and 0 or simulateRecvNum

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Friend_Branch_Path.Gift, simulateRecvNum)
end

function FriendRDL.AddFriendApply()
	local CurApplyNum = table.getn(FriendMgr.listApply)

	if PreApplyNum == CurApplyNum then
		return
	end

	PreApplyNum = CurApplyNum
	IsViewedApply = false

	FriendRDL.SetPlayerPrefs(true)
	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Friend_Branch_Path.Apply, 1)
end

function FriendRDL.RemoveFriendApply()
	PreApplyNum = table.getn(FriendMgr.listApply)

	if IsViewedApply then
		return
	end

	IsViewedApply = true

	FriendRDL.SetPlayerPrefs(false)
	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Friend_Branch_Path.Apply, 0)
end

function FriendRDL.SetPlayerPrefs(vbool)
	PersistentStoreUtil.SetBool(KEY_RD_FRIEND_APPLY, vbool)
end

return FriendRDL
