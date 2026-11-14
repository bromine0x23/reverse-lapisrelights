-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/ItemRDL.lua

require("luaData/ItemData")

ItemRDL = {}
SETTER_ITEM_TYPE = {
	I_SOUL = "I_SOUL",
	I_ACTIVE_DRAW = "I_ACTIVE_DRAW",
	I_STAR = "I_STAR",
	P_GOLD = "P_GOLD",
	I_SOUL_COMMON = "I_SOUL_COMMON",
	I_SCROLL = "I_SCROLL",
	I_NORMAL = "I_NORMAL",
	R_AVATAR = "R_AVATAR",
	I_FAVOR = "I_FAVOR",
	I_GROW = "I_GROW",
	I_EXP = "I_EXP"
}
ItemRDL.NewScrollIds = {}
ItemRDL.NewFavorIds = {}
ItemRDL.NewAvatarIds = {}

function ItemRDL.Push(tab, id)
	if tab == nil then
		error(string.format("The first element [%s] is nil", tab))
	end

	if not table.contains(tab, id) then
		table.insert(tab, id)
	end
end

function ItemRDL.Pop(tab, id)
	if tab == nil then
		error(string.format("The first element [%s] is nil", tab))
	end

	table.removeByValue(tab, id)
end

local dirtyNewTypes = {}
local dirtyGrowTypes = {}

local function AddDirtyType(tab, strType)
	tab = tab or {}

	if not table.contains(tab, strType) then
		table.insert(tab, strType)
	end
end

local function DealNewDirtyType(strType)
	AddDirtyType(dirtyNewTypes, strType)
end

local function DealGrowDirtyType(strType)
	AddDirtyType(dirtyGrowTypes, strType)
end

function ItemRDL:New(setters)
	dirtyNewTypes = {}
	self.NewScrollIds = {}
	self.NewFavorIds = {}
	self.NewAvatarIds = {}
	setters = setters or {}

	for _, s in ipairs(setters) do
		if s.asset == protocol_pb.R_AVATAR or s.asset == protocol_pb.P_AVATAR then
			DealNewDirtyType(SETTER_ITEM_TYPE.R_AVATAR)

			if s.id ~= 0 then
				self.NewAvatarIds[s.id] = self.NewAvatarIds[s.id] or {}

				self.Push(self.NewAvatarIds[s.id], s.num)
			else
				self.NewAvatarIds[PUBLIC_AVATAR_GROUPID] = self.NewAvatarIds[PUBLIC_AVATAR_GROUPID] or {}

				self.Push(self.NewAvatarIds[PUBLIC_AVATAR_GROUPID], s.num)
			end
		elseif s.asset == protocol_pb.I_SOUL then
			-- block empty
		elseif s.asset ~= protocol_pb.RC_RECEIVE and s.num > 0 then
			local item = ItemManager:Get(s.id)

			if item.pb.num == 0 then
				if s.asset == protocol_pb.I_SCROLL then
					DealNewDirtyType(SETTER_ITEM_TYPE.I_SCROLL)
					self.Push(self.NewScrollIds, s.id)
				elseif s.asset == protocol_pb.I_FAVOR then
					DealNewDirtyType(SETTER_ITEM_TYPE.I_FAVOR)
					self.Push(self.NewFavorIds, s.id)
				end
			end
		end
	end

	self.RunSystemLogic()
end

function ItemRDL.RunSystemLogic()
	local function Has(setter_item_type)
		return table.contains(dirtyNewTypes, setter_item_type)
	end

	if Has(SETTER_ITEM_TYPE.I_SCROLL) then
		RoleRDL.EquipRDL.AddEquipNewEnchant()
	end

	if Has(SETTER_ITEM_TYPE.I_FAVOR) then
		-- block empty
	end

	if Has(SETTER_ITEM_TYPE.R_AVATAR) then
		RoleRDL.FittingRDL.AddFittingAvatarId()
	end
end

function ItemRDL:Grow(setters)
	dirtyGrowTypes = {}

	for _, s in ipairs(setters) do
		if s.id and s.num then
			if s.asset == protocol_pb.I_GROW then
				DealGrowDirtyType(SETTER_ITEM_TYPE.I_GROW)
			elseif s.asset == protocol_pb.P_GOLD then
				DealGrowDirtyType(SETTER_ITEM_TYPE.P_GOLD)
			elseif s.asset == protocol_pb.I_STAR then
				DealGrowDirtyType(SETTER_ITEM_TYPE.I_STAR)
			elseif s.asset == protocol_pb.I_SOUL then
				DealGrowDirtyType(SETTER_ITEM_TYPE.I_SOUL)
			elseif s.asset == protocol_pb.I_SOUL_COMMON then
				DealGrowDirtyType(SETTER_ITEM_TYPE.I_SOUL_COMMON)
			elseif s.asset == protocol_pb.I_NORMAL then
				DealGrowDirtyType(SETTER_ITEM_TYPE.I_NORMAL)
			elseif s.asset == protocol_pb.I_ACTIVE_DRAW then
				DealGrowDirtyType(SETTER_ITEM_TYPE.I_ACTIVE_DRAW)
			elseif s.asset == protocol_pb.I_EXP then
				DealGrowDirtyType(SETTER_ITEM_TYPE.I_EXP)
			elseif s.asset == protocol_pb.I_SCROLL then
				DealGrowDirtyType(SETTER_ITEM_TYPE.I_SCROLL)
			end
		end
	end

	self.RunSystemGrowLogic()
end

function ItemRDL.RunSystemGrowLogic()
	local function Has(setter_item_type)
		return table.contains(dirtyGrowTypes, setter_item_type)
	end

	if Has(SETTER_ITEM_TYPE.P_GOLD) then
		if not ItemRDL.EquipRefreshed then
			RoleRDL.EquipRDL.ReCalculateEquipIntense()

			ItemRDL.EquipRefreshed = true
		end

		if not ItemRDL.CardLvUpRefreshed then
			CardRDL.LvUpRDL.ReCalculateCardLvUp()

			ItemRDL.CardLvUpRefreshed = true
		end

		if not ItemRDL.CardBloomRefreshed then
			CardRDL.BloomRDL.ReCalculateCardBloom()

			ItemRDL.CardBloomRefreshed = true
		end
	end

	if Has(SETTER_ITEM_TYPE.I_GROW) and not ItemRDL.EquipRefreshed then
		RoleRDL.EquipRDL.ReCalculateEquipIntense()

		ItemRDL.EquipRefreshed = true
	end

	if Has(SETTER_ITEM_TYPE.I_EXP) and not ItemRDL.CardLvUpRefreshed then
		CardRDL.LvUpRDL.ReCalculateCardLvUp()

		ItemRDL.CardLvUpRefreshed = true
	end

	if Has(SETTER_ITEM_TYPE.I_STAR) then
		CardRDL.BreakRDL.ReCalculateCardBreak()
	end

	if Has(SETTER_ITEM_TYPE.I_SOUL) then
		if not ItemRDL.CardBloomRefreshed then
			CardRDL.BloomRDL.ReCalculateCardBloom()

			ItemRDL.CardBloomRefreshed = true
		end

		CardRDL.ComposeRDL.ReCalculateCardCompose()
	end

	if Has(SETTER_ITEM_TYPE.I_SOUL_COMMON) and not ItemRDL.CardBloomRefreshed then
		CardRDL.BloomRDL.ReCalculateURCardBloom()
	end

	if Has(SETTER_ITEM_TYPE.I_NORMAL) then
		ManualRDL.NotesRDL.DealTask()
	end

	if Has(SETTER_ITEM_TYPE.I_ACTIVE_DRAW) then
		ChapterRDL.PartyRDL.DealDraw()
	end

	if Has(SETTER_ITEM_TYPE.I_SCROLL) then
		RoleRDL.EquipRDL.ReCalculateEquipEnchant()
	end

	ItemRDL.EquipRefreshed = false
	ItemRDL.CardLvUpRefreshed = false
	ItemRDL.CardBloomRefreshed = false
end
