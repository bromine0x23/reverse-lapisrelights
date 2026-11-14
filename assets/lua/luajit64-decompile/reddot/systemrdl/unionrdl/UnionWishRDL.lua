-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/UnionRDL/UnionWishRDL.lua

local UnionWishRDL = {}
local CanReceiveValue = 0

function UnionWishRDL.Init()
	if not UnionMgr.HasUnion() then
		return
	end

	CanReceiveValue = UnionWishRecvMgr.ExistCanReceive and 1 or 0

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Union_Branch_Path.Wish, CanReceiveValue)
end

function UnionWishRDL.AddRD()
	if not UnionMgr.HasUnion() then
		return
	end

	if CanReceiveValue == 1 then
		return
	end

	CanReceiveValue = 1

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Union_Branch_Path.Wish, CanReceiveValue)
end

function UnionWishRDL.SubRD()
	if CanReceiveValue == 0 then
		return
	end

	CanReceiveValue = 0

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Union_Branch_Path.Wish, 0)
end

function UnionWishRDL.ResetWishRDAfterLeaveUnion()
	UnionWishRDL.SubRD()
end

function UnionWishRDL.HasWishDot()
	return CanReceiveValue == 1
end

return UnionWishRDL
