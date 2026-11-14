-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/OperationRDL/FirstRechargeRDL.lua

local FirstRechargeRDL = {}
local RD_FirstRecharge_Branch_Path = {
	FirstRecharge = "FirstRecharge"
}
local KEY_RD_FIRST_CHARGE = "KEY_RD_FIRST_CHARGE"
local INFO_RECHARGE
local IS_EXIST = false
local IS_OPENED = false

function FirstRechargeRDL.Init()
	if NoPay then
		return
	end

	if not IS_EXIST and not INFO_RECHARGE then
		IS_EXIST, INFO_RECHARGE = OperationActiveMgr:CheckFirstRechargeExist()
	end

	if not IS_EXIST then
		return
	end

	local value = 0

	IS_OPENED = PersistentStoreUtil.GetBool(KEY_RD_FIRST_CHARGE, false)

	if not IS_OPENED then
		value = value + 1
	end

	local needMoney = INFO_RECHARGE.data.DailyTime[1][#INFO_RECHARGE.pb.awardRecords + 1]

	if needMoney <= INFO_RECHARGE.pb.record then
		value = value + 1
	end

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_FirstRecharge_Branch_Path.FirstRecharge, value)
end

function FirstRechargeRDL.SubOpenedPlayerPrefs()
	if not IS_OPENED then
		IS_OPENED = true

		PersistentStoreUtil.SetBool(KEY_RD_FIRST_CHARGE, true)
		RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_FirstRecharge_Branch_Path.FirstRecharge, -1)
	end
end

function FirstRechargeRDL.AddFirstRechargeAward()
	if not IS_EXIST then
		return
	end

	if INFO_RECHARGE then
		local needMoney = INFO_RECHARGE.data.DailyTime[1][#INFO_RECHARGE.pb.awardRecords + 1]

		if needMoney <= INFO_RECHARGE.pb.record then
			RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_FirstRecharge_Branch_Path.FirstRecharge, 1)
		end
	end
end

function FirstRechargeRDL.SubFirstRechargeAward()
	if not IS_EXIST then
		return
	end

	IS_EXIST = false

	RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_FirstRecharge_Branch_Path.FirstRecharge, -1)
end

return FirstRechargeRDL
