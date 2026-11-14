-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Const/EventId.lua

require("Util/Enum")

EventId = {
	UIPanel = {
		Loaded = 65536
	},
	Network = {
		Connected = 262144,
		DisConnected = 262145
	}
}
EventEnum = numEnumWithStartNum({
	"ReconnectTipShow",
	"HandleReconnect",
	"UpdateRoleAttri",
	"SendGiftDragItem",
	"UpdatePlayerInfo",
	"UpdatePlayerVipExp",
	"SelectedRole",
	"PlayerLevelup",
	"RoleLevelup",
	"RoleStarLevelup",
	"RoleExpChanged",
	"UpdateFavorTouch",
	"UpdateFavorTouchRecoverTime",
	"UpdateWorkCompleteTime",
	"PlayVoice",
	"UpdatePowerRecoverTime",
	"UpdatePlayerInfo",
	"UpdateSceneObjectShow",
	"UpdateTaskList",
	"EnterStage",
	"UpdateStage",
	"UpdateOperationActive",
	"UpdateItemDataNotify",
	"ResetCardHpPercent",
	"AddRollingNotice",
	"AddRollingNoticeTime",
	"InPageMain"
}, 16777216)
Dir = numEnum({
	"Left",
	"Right"
})
TLIST_ATTRITYPE = {
	0,
	1,
	2,
	3,
	4,
	5
}

function GetAttriIndex(type)
	for i = 1, #TLIST_ATTRITYPE do
		if type:Equals(TLIST_ATTRITYPE[i]) then
			return i - 1
		end
	end

	return 0
end

TLIST_JOBTYPE = {
	0,
	1,
	2,
	3,
	4
}

function GetJobIndex(type)
	for i = 1, #TLIST_JOBTYPE do
		if type:Equals(TLIST_JOBTYPE[i]) then
			return i - 1
		end
	end

	return 0
end

TLIST_AVATARSLOT = {
	0,
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8,
	9,
	10,
	11,
	12,
	13
}
