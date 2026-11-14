-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/JobCheckingUtil.lua

local datas = require("luaData/JobCheckingData")

JobCheckingUtil = {}

local jobArrayMul = {}
local jobStrong = {}
local jobWeak = {}
local bInit = false

function JobCheckingUtil.Init()
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

		if data.Mul > 1 then
			if not jobStrong[job1] then
				jobStrong[job1] = {}
			end

			table.insert(jobStrong[job1], job2)
		elseif data.Mul < 1 then
			if not jobWeak[job1] then
				jobWeak[job1] = {}
			end

			table.insert(jobWeak[job1], job2)
		end
	end
end

function JobCheckingUtil.GetMul(job1, job2)
	if not jobArrayMul[job1] then
		return 1
	end

	if not jobArrayMul[job1][job2] then
		return 1
	end

	return jobArrayMul[job1][job2]
end

function JobCheckingUtil.GetStrong(job)
	if jobWeak[job] then
		return jobWeak[job][1]
	else
		return ""
	end
end

function JobCheckingUtil.GetWeak(job)
	if jobStrong[job] then
		return jobStrong[job][1]
	else
		return ""
	end
end
