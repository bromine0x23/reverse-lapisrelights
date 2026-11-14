-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoSkill.lua

require("Info/InfoBase")

local TreeData = require("luaData/SkillTree")
local NodeData = require("luaData/SkillNode")

eSkillNodeType = {
	attri = 1,
	avatar = 3,
	item = 2,
	skill = 4
}
SkillState = numEnum({
	"Locked",
	"UnLock",
	"Geted"
})

local function GetMaxLevelByType(data)
	local nodeType = data.RewardType

	if nodeType == eSkillNodeType.attri then
		return #data.Attribute
	elseif nodeType == eSkillNodeType.item then
		return 1
	elseif nodeType == eSkillNodeType.avatar then
		return 1
	elseif nodeType == eSkillNodeType.skill then
		return 1
	end

	return 1
end

InfoSkillNode = class("InfoSkillNode", InfoBase)

function InfoSkillNode:ctor(id)
	self.id = id
	self.data = NodeData[id]
	self.parentId = 0
	self.level = 0
	self.maxLevel = GetMaxLevelByType(self.data)
	self.geted = false
	self.unlock = false
	self.canAct = false
	self.perfect = false
	self.failTimes = 0

	SkillManager.dictNode:Set(self.id, self)
end

function InfoSkillNode:GetAttrType()
	return self.data.AttributeType
end

function InfoSkillNode:GetAttr()
	return self.data.Attribute[self.level] or 0
end

function InfoSkillNode:UpdateData(infoRole)
	if not infoRole then
		return
	end

	local playerLv = PlayerInst:GetCurLv()
	local favorLv = infoRole.curFavorLevel

	if playerLv >= self.data.Level and favorLv >= self.data.Favor then
		self.unlock = true
	end

	if self.unlock then
		for _, pbNode in ipairs(infoRole.pb.skillNodes) do
			if self.id == pbNode.id then
				self.canAct = true
				self.geted = true
				self.level = pbNode.level
				self.perfect = pbNode.level == self.maxLevel
				self.failTimes = pbNode.failTimes

				return
			end
		end

		if self.parentId > 0 then
			if SkillManager:GetNode(self.parentId).geted then
				self.canAct = true
			end
		else
			self.canAct = true
		end
	end
end

InfoSkillTree = class("InfoSkillTree", InfoBase)

function InfoSkillTree:ctor(id)
	self.id = id
	self.data = TreeData[id]

	SkillManager.dictTree:Set(self.id, self)

	self.tlistMain = {}
	self.tlistMainIds = {}

	local listTrunk = self.data.Trunk

	for _, nodeId in ipairs(listTrunk) do
		local node = SkillManager:GetNode(nodeId)

		table.insert(self.tlistMain, node)
		table.insert(self.tlistMainIds, nodeId)
	end

	self.tlistBranch = {}

	for i = 1, 6 do
		local parentId = self.data["ParentID" .. i]

		if parentId > 0 then
			local listBranch = self.data["Branch" .. i]
			local dir = self.data["Direction" .. i]
			local tlistNode = {}
			local tlist = {}

			for n = 1, #listBranch do
				local node = SkillManager:GetNode(listBranch[n])

				table.insert(tlist, node)
			end

			tlistNode.list = tlist
			tlistNode.dir = GetDirType(dir)
			tlistNode.parentId = parentId

			table.insert(self.tlistBranch, tlistNode)
		end
	end
end

SkillManager = {}
SkillManager.dict = SkillManager.dict or Record()
SkillManager.dictNode = SkillManager.dictNode or Record()
SkillManager.dictTree = SkillManager.dictTree or Record()

local TabInitRecord = {}

function SkillManager:GetNode(id)
	local ret = self.dictNode:GetValue(id)

	ret = ret or InfoSkillNode(id)

	return ret
end

function SkillManager:GetTree(treeId)
	local infoTree = self.dictTree:GetValue(treeId)

	infoTree = infoTree or InfoSkillTree(treeId)

	return infoTree
end

function SkillManager:GetTreesByRoleId(roleId)
	local list = {}

	for _, v in pairsByKeys(TreeData) do
		if v.CharacterID == roleId then
			table.insert(list, v)
		end
	end

	local ret = {}

	for _, data in ipairs(list) do
		local infoTree = self:GetTree(data.ID)

		table.insert(ret, infoTree)
	end

	if not TabInitRecord[roleId] then
		self:InitAllNodeData(roleId, ret)

		TabInitRecord[roleId] = true
	end

	return ret
end

function SkillManager:InitAllNodeData(roleId, trees)
	local infoRole = RoleMgr:GetRole(roleId)

	if infoRole then
		if not trees then
			trees = SkillManager:GetTreesByRoleId(roleId)
		end
	else
		return
	end

	for i, tree in ipairs(trees) do
		for k, node in ipairs(tree.tlistMain) do
			if k == 1 then
				if i > 1 then
					local _tlistMain = trees[i - 1].tlistMain

					node.parentId = _tlistMain[#_tlistMain].id
				end
			else
				node.parentId = tree.tlistMain[k - 1].id
			end

			node:UpdateData(infoRole)
		end

		for _, branch in ipairs(tree.tlistBranch) do
			for _, node in ipairs(branch.list) do
				node.parentId = branch.parentId

				node:UpdateData(infoRole)
			end
		end
	end
end

function SkillManager:UpdateTreeNodeData(treeId, roleId)
	local tree = self:GetTree(treeId)

	if not tree then
		return
	end

	local infoRole = RoleMgr:GetRole(roleId)

	for _, node in ipairs(tree.tlistMain or {}) do
		node:UpdateData(infoRole)
	end

	for _, branch in ipairs(tree.tlistBranch or {}) do
		for _, node in ipairs(branch.list) do
			node:UpdateData(infoRole)
		end
	end
end

function SkillManager:GetFavorUnlockNode(roleId, favorLv)
	local listAllSkill = SkillManager:GetTreesByRoleId(roleId)

	for i = 1, #listAllSkill do
		local infoTree = listAllSkill[i]

		for n = 1, #infoTree.tlistMain do
			local node = infoTree.tlistMain[n]

			if node.data.Favor == favorLv then
				return node
			end
		end

		for n = 1, #infoTree.tlistBranch do
			local td = infoTree.tlistBranch[n]

			for j = 1, #td.list do
				local node = td.list[j]

				if node.data.Favor == favorLv then
					return node
				end
			end
		end
	end

	return nil
end

function SkillManager.NextTreeIsUnlock(treeIdx, roleId)
	local trees = SkillManager:GetTreesByRoleId(roleId)
	local tlistMain = trees[treeIdx].tlistMain
	local maxStars = 0
	local curStars = 0

	for k, node in ipairs(tlistMain) do
		if node.data.RewardType == eSkillNodeType.attri then
			curStars = curStars + node.level
			maxStars = maxStars + node.maxLevel
		end
	end

	local lastGeted = tlistMain[#tlistMain].geted
	local temp = {
		starFull = maxStars <= curStars,
		actFull = lastGeted,
		curStars = curStars,
		maxStars = maxStars
	}

	return temp
end

function SkillManager:GetTalentLevelByTreeIdx(roleId, treeIdx, talentId)
	local listTree = self:GetTreesByRoleId(roleId)
	local level = 0

	for k, v in ipairs(listTree) do
		if k <= treeIdx then
			for _, n in ipairs(v.tlistMain) do
				if n.data.RewardType == eSkillNodeType.skill and n.data.Skill == talentId then
					level = level + 1
				end
			end
		end
	end

	return level
end

function SkillManager.GetUnlockInfo(node)
	local level = node.data.Level
	local favor = node.data.Favor
	local desc = ""

	if level == 0 then
		desc = string.format(_("PageTalentTree_Unlock_favor"), favor)
	elseif favor == 0 then
		desc = string.format(_("PageTalentTree_Unlock_level"), level)
	else
		desc = string.format(_("PageTalentTree_Unlock_level"), level) .. "," .. string.format(_("PageTalentTree_Unlock_favor"), favor)
	end

	return desc
end

function SkillManager:GetPageTalentTreeAttriDot(node)
	if node.perfect or not node.canAct then
		return false
	end

	for _, v in ipairs(node.data.CostGem) do
		local holdNum = ItemManager:GetItemCount(v[1] or 501)
		local costNum = v[2] or 0

		if holdNum < costNum then
			return false
		end
	end

	return true
end

function SkillManager:GetPageTalentTreeAllTrunkDot(infoRole, treeIdx)
	if not infoRole then
		return false
	end

	local trees = self:GetTreesByRoleId(infoRole.id)

	local function fun1(index)
		if index == 1 then
			return true
		elseif index > 1 then
			local temp = self.NextTreeIsUnlock(index - 1, infoRole.id)

			if temp.starFull and temp.actFull then
				return true
			end
		end

		return false
	end

	local function fun2(tlistMain, tlistBranch)
		for _, v in ipairs(tlistMain) do
			if self:GetPageTalentTreeAttriDot(v) then
				return true
			end
		end

		for _, v in ipairs(tlistBranch) do
			for _, n in ipairs(v.list) do
				if self:GetPageTalentTreeAttriDot(n) then
					return true
				end
			end
		end

		return false
	end

	if treeIdx then
		if fun1(treeIdx) then
			return fun2(trees[treeIdx].tlistMain, trees[treeIdx].tlistBranch)
		end
	else
		local hasDot = false

		for k, v in ipairs(trees) do
			if fun1(k) and fun2(v.tlistMain, v.tlistBranch) then
				hasDot = true

				break
			end
		end

		return hasDot
	end

	return false
end
