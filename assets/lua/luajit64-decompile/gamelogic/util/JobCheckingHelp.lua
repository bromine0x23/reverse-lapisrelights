-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Util/JobCheckingHelp.lua

JobCheckingHelp = {}

local jobArrayMul = {}
local bInit = false

function JobCheckingHelp.Init(datas)
	if bInit == true then
		return
	end

	for k, data in pairs(datas) do
		local job1 = data.Job[1]
		local job2 = data.Job[2]

		if not jobArrayMul[job1] then
			jobArrayMul[job1] = {}
		end

		jobArrayMul[job1][job2] = data.Mul
	end
end

function JobCheckingHelp.GetMul(job1, job2)
	if not jobArrayMul[job1] then
		return 1
	end

	if not jobArrayMul[job1][job2] then
		return 1
	end

	return jobArrayMul[job1][job2]
end
