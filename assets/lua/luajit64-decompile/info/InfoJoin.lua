-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoJoin.lua

local JoinData = require("luaData/CharacterJoin")

InfoJoin = class("InfoJoin", InfoBase)

function InfoJoin:ctor(id)
	self.id = id
	self.data = JoinData[id]
	self.attrs = AttributeOwner()

	self:SetAttr()
end

function InfoJoin:SetAttr()
	local tab = self.data.AttList

	for k, v in pairs(GetMapTab({
		tab
	})) do
		self.attrs:SetBase(k, v)
	end
end

function InfoJoin:GetAtt(attType)
	return self.attrs:Get(attType)
end

function InfoJoin:IsHold()
	local cardList = self.data.CardList

	for i = 1, #cardList do
		if not self:OneOfAllIsHold(i) then
			return false
		end
	end

	return true
end

function InfoJoin:OneOfAllIsHold(index)
	local cardList = self.data.CardList
	local cardId = cardList[index][1]

	if not cardId then
		return false
	end

	local infoRoleCard = RoleCardMgr:GetRoleCard(cardId)
	local needStar = cardList[index][2]
	local needLevel = cardList[index][3]

	if infoRoleCard:IsHold() and needStar <= infoRoleCard.curStarLevel and needLevel <= infoRoleCard.curLevel then
		return true
	end

	return false
end

JoinMgr = {}
JoinMgr.dict = JoinMgr.dict or Record()

function JoinMgr:Get(id)
	local ret = self.dict:GetValue(id)

	if not ret then
		ret = InfoJoin(id)

		self.dict:Set(id, ret)
	end

	if ret.data == nil then
		print("检查CharacterJoin表!!!" .. id)
	end

	return ret
end

function JoinMgr:GetRoleId(joinId)
	local infoJoin = self:Get(joinId)

	return infoJoin.data.CharacterID
end

function JoinMgr:GetRoleAllJoin(roleId)
	local list = {}
	local keys = {}

	for k, _ in pairs(JoinData) do
		table.insert(keys, k)
	end

	table.sort(keys)

	for i = 1, #keys do
		local infoJoin = self:Get(keys[i])

		if infoJoin.data.CharacterID == roleId then
			table.insert(list, infoJoin)
		end
	end

	return list
end

function JoinMgr:GetRoleAllHoldJoin(roleId)
	local infoRole = RoleMgr:GetRole(roleId)
	local listJoin = infoRole.listRoleJoin
	local list = {}

	for i = 1, #listJoin do
		local infoJoin = listJoin[i]

		if infoJoin:IsHold() then
			table.insert(list, infoJoin)
		end
	end

	return list
end

function JoinMgr:GetJoinAttachCardIds(mainCardId)
	local listJoin = {}

	for _, v in pairs(JoinData) do
		if v.CardList[1][1] == mainCardId then
			local list = {}

			for n = 2, #v.CardList do
				local cardId = v.CardList[n][1]

				if cardId ~= nil then
					table.insert(list, cardId)
				end
			end

			local temp = {
				v.Type,
				list
			}

			table.insert(listJoin, temp)
		end
	end

	return listJoin
end
