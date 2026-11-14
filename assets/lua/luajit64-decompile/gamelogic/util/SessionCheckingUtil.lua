-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Util/SessionCheckingUtil.lua

local Root = {}

Root.A = {
	Skill = "session_attack"
}
Root.A.A = {
	Skill = "double_attack"
}
Root.A.A.A = {
	Skill = "triple_attack"
}
Root.A.A.A.A = {
	Skill = "quadra_attack"
}
Root.B = {
	Skill = "session_force"
}
Root.B.B = {
	Skill = "double_force"
}
Root.B.B.B = {
	Skill = "triple_force"
}
Root.B.B.B.B = {
	Skill = "quadra_force"
}
Root.C = {
	Skill = "session_recover"
}
Root.C.C = {
	Skill = "double_recover"
}
Root.C.C.C = {
	Skill = "triple_recover"
}
Root.C.C.C.C = {
	Skill = "quadra_recover"
}

local Action = {}

Action["1111"] = {
	1,
	2,
	3,
	4
}
Action["112"] = {
	1,
	2,
	3
}
Action["121"] = {
	1,
	2,
	3
}
Action["13"] = {
	1,
	2
}
Action["211"] = {
	1,
	2,
	3
}
Action["22"] = {
	1,
	2
}
Action["31"] = {
	1,
	2
}
Action["4"] = {
	1
}
Action["1"] = {
	1
}
Action["11"] = {
	1,
	2
}
Action["111"] = {
	1,
	2,
	3
}
Action["2"] = {
	1
}
Action["12"] = {
	1,
	2
}
Action["21"] = {
	1,
	2
}
Action["3"] = {
	1
}

local Pop = {}

Pop["1111"] = {
	2,
	3,
	4
}
Pop["112"] = {
	1,
	2
}
Pop["121"] = {
	1,
	3
}
Pop["13"] = {
	1
}
Pop["211"] = {
	2,
	3
}
Pop["22"] = {}
Pop["31"] = {
	2
}
Pop["4"] = {}
Pop["1"] = {}
Pop["11"] = {
	2
}
Pop["111"] = {
	2,
	3
}
Pop["2"] = {}
Pop["12"] = {
	1
}
Pop["21"] = {
	2
}
Pop["3"] = {}
SessionCheckingUtil = {}

function SessionCheckingUtil.Check(sessionList)
	local recvList = sessionList
	local saveIndex = 1
	local saveList = {}

	Recursive(Root, recvList, saveList, saveIndex, Root)

	local key = ""

	for i = 1, #saveList do
		key = key .. #saveList[i]
	end

	print("key = " .. key)

	for i = 1, #Action[key] do
		print("ret = " .. Action[key][i])
	end
end

function SessionCheckingUtil:GetVaildSessionList(srcSessionList)
	local groupList = {}
	local groupDatas = {}

	for i = 1, #srcSessionList do
		local curtype = srcSessionList[i].SessionType
		local nextType

		if srcSessionList[i + 1] then
			nextType = srcSessionList[i + 1].SessionType
		end

		if nextType and nextType == curtype then
			table.insert(groupDatas, srcSessionList[i])
		else
			table.insert(groupDatas, srcSessionList[i])
			table.insert(groupList, groupDatas)

			groupDatas = {}
		end
	end

	return groupList
end

function Recursive(node, recvList, saveList, saveIndex, rootNode)
	for i, type in ipairs(recvList) do
		local curNode

		if type == 1 then
			curNode = node.A
		elseif type == 2 then
			curNode = node.B
		elseif type == 3 then
			curNode = node.C
		end

		if not curNode then
			saveIndex = saveIndex + 1

			Recursive(rootNode, recvList, saveList, saveIndex, rootNode)

			return
		else
			if not saveList[saveIndex] then
				saveList[saveIndex] = {}
			end

			table.insert(saveList[saveIndex], recvList[1])
			table.remove(recvList, 1)
			Recursive(curNode, recvList, saveList, saveIndex, rootNode)
		end
	end
end

function SessionCheckingUtil:GetDoSessionList(sessionList)
	local recvList = {}

	for i = 1, #sessionList do
		table.insert(recvList, sessionList[i].SessionType)
	end

	local saveIndex = 1
	local saveList = {}
	local root = Root
	local actionCfg = Action
	local popCfg = Pop

	Recursive(root, recvList, saveList, saveIndex, root)

	local key = ""

	for i = 1, #saveList do
		key = key .. #saveList[i]
	end

	if not actionCfg[key] then
		print("缺少此类组合 去BattleConfig添加 ，key:" .. key)

		return {}, {}
	end

	local dosessionList = {}
	local vaildList = self:GetVaildSessionList(sessionList)

	for i = 1, #actionCfg[key] do
		local _index = actionCfg[key][i]

		table.insert(dosessionList, vaildList[_index])
	end

	local popsessionList = {}

	for i = 1, #popCfg[key] do
		local _index = popCfg[key][i]

		table.insert(popsessionList, vaildList[_index])
	end

	return dosessionList, popsessionList
end

function SessionCheckingUtil:GetShowSessionList()
	local sessionList = self.GetDoSessionList()
	local cutinList = {}

	for i, group in ipairs(sessionList) do
		local ele = {}

		if #group >= 2 then
			for j, onesession in ipairs(group) do
				table.insert(ele, {
					unitId = onesession.unitId,
					sessionType = onesession.sessionType
				})
			end

			table.insert(cutinList, ele)
		end
	end

	return cutinList
end
