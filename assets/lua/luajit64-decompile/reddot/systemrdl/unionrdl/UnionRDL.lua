-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/UnionRDL/UnionRDL.lua

UnionRDL = {}
RD_Union_Branch_Path = {
	Raid = "Union/Raid",
	Task = "Union/Task",
	Union_Score = "Union/Task/%d",
	Wish = "Union/Wish",
	Member = "Union/Member"
}
UnionRDL.MemberRDL = require("RedDot/SystemRDL/UnionRDL/UnionMemberRDL")
UnionRDL.RaidRDL = require("RedDot/SystemRDL/UnionRDL/UnionRaidRDL")
UnionRDL.WishRDL = require("RedDot/SystemRDL/UnionRDL/UnionWishRDL")
UnionRDL.TaskRDL = require("RedDot/SystemRDL/UnionRDL/UnionTaskRDL")

function UnionRDL.Init()
	UnionRDL.MemberRDL.Init()
	UnionRDL.WishRDL.Init()
	UnionRDL.TaskRDL.Init()
end

function UnionRDL.ResetRDAfterJoinUnion()
	UnionRDL.TaskRDL.ResetTaskRDAfterJoinUnion()
end

function UnionRDL.ResetRDAfterLeaveUnion()
	UnionRDL.MemberRDL.ResetMemberRDAfterLeaveUnion()
	UnionRDL.TaskRDL.ResetTaskRDAfterLeaveUnion()
	UnionRDL.WishRDL.ResetWishRDAfterLeaveUnion()
end

return UnionRDL
