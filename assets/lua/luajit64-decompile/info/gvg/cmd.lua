-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/gvg/cmd.lua

local mt = {}
local TIME = 0

function mt:GetAllReward(step)
	local steps = {}

	for i = 1, Infogvg.stage.awardStatus[step] do
		table.insert(steps, step)
	end

	local stageIds = {}

	for i, stage in Infogvg.stage:Filter():IsStep(step):Ipairs() do
		for j = 1, stage.leftAwardTimes do
			table.insert(stageIds, stage.stageId)
		end
	end

	Infogvg:Table(steps, "報酬受け取りsteps:")
	Infogvg:Table(stageIds, "報酬受け取りstageIds:")
	Infogvg.net:RequestReward(steps, stageIds)
end

function mt:Fight(stageId)
	local cardHpRates = {
		100,
		100,
		100,
		100,
		100
	}
	local bloodCost = {}
	local blood = 0

	for i = 1, #Infogvg.stage:Get(stageId).monsters do
		table.insert(bloodCost, Infogvg.stage:Get(stageId).monsters[i].hp)

		blood = blood + Infogvg.stage:Get(stageId).monsters[i].hp
	end

	local function end_fight_callback(pb)
		self:OnFightResult(pb)
	end

	local function start_fight_callback(pb)
		if pb.result.code ~= NetManager.Result_Sucess then
			Infogvg:Log("戦闘開始失敗 " .. pb.result.desc .. " code:" .. pb.result.code)

			return
		end

		local boutId = pb.boutId
		local battlelogs = "            [{\"Type\":1,\"CardIds\":[102001104,105001104,104001104]}]\n        "
		local chaos = {
			norce = pb.chaos.norce,
			ut = pb.chaos.ut,
			signature = pb.chaos.signature
		}

		Infogvg:Log("ready to req end stage ,blood:" .. blood)
		TimerMgr.AddTimer(eTimerType.ScaleTime, TIME, function()
			NetManager:RequestEndStage(boutId, true, {
				1,
				5,
				100,
				0,
				0
			}, battlelogs, 8, 0, bloodCost, cardHpRates, {}, chaos, end_fight_callback, blood)
		end, nil)
	end

	NetManager:RequestStartStage(stageId, {}, false, start_fight_callback)
end

function mt:AutoFight()
	for i, stage in ipairs(Infogvg.stage.stages) do
		if stage:IsComplete() == false and stage:IsLock() == false then
			self:Fight(stage.stageId)

			break
		end
	end
end

function mt:OnFightResult(pb)
	if pb.result.code ~= NetManager.Result_Sucess then
		Infogvg:Log("リザルト失敗 " .. pb.result.desc .. " code:" .. pb.result.code)

		return
	end

	local s = SetterData.GetSetterData(pb.setter)

	s:Parse()

	for i, setter in ipairs(s.list) do
		Infogvg:Log("from:" .. setter.from)
	end

	Infogvg.net:RequestGvg()
end

function mt:OfflineMode()
	require("Info/InfoShop")
	require("Info/InfoUnion")

	Infogvg.offline = true

	Infogvg:Refresh(true)
end

return mt
