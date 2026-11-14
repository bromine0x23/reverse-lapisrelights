-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/AttributeAgent.lua

ATTRIBUTE_NAME = {
	"Stamina",
	"Defend",
	"Song",
	"Will",
	"Speed",
	"Hit",
	"Duck",
	"Crit",
	"Bruise",
	"CritResist",
	"BruiseDamage"
}
ATTRIBUTE_NAME_CN = {
	"HP",
	"防御",
	"物理",
	"魔法",
	"速度",
	"命中",
	"回避",
	"会心率",
	"会心ダメージ",
	"会心抵抗率",
	"会心ダメージ軽減"
}
ATTRIBUTE_USE_CNT = 4

function GetAttKeyByIndex(index)
	return ATTRIBUTE_NAME[index] or "Stamina"
end

local function GetAttKeyByStr(str)
	for k, v in pairs(ATTRIBUTE_NAME_CN) do
		if str == v then
			return ATTRIBUTE_NAME[k]
		end
	end

	return str
end

function GetAttENKey(v)
	if type(v) == "number" then
		return GetAttKeyByIndex(v)
	elseif type(v) == "string" then
		return GetAttKeyByStr(v)
	end

	return "Stamina"
end

function GetAttValueType(key)
	if key == "Stamina" or key == "Defend" or key == "Song" or key == "Will" or key == "Speed" then
		return eValueType.Abs
	end

	return eValueType.Per
end

function ExchangeAttValue(name, value)
	local t = GetAttValueType(name)

	if t == eValueType.Abs then
		return math.floor(value + 0.5)
	end

	return value
end

ATTRIBUTE_MAP = {
	{
		"Stamina",
		"Defend",
		"Song",
		"Will"
	},
	{
		"Speed",
		"Hit",
		"Duck"
	},
	{
		"Crit",
		"Bruise",
		"CritResist",
		"BruiseDamage"
	}
}

local function GetMapKey(tabIdx, index)
	local key = "Stamina"

	if ATTRIBUTE_MAP[tabIdx] and ATTRIBUTE_MAP[tabIdx][index] then
		key = ATTRIBUTE_MAP[tabIdx][index]
	else
		PrintWithColor("tabIdx [%s], index [%s] が存在しません！！！", "red", tostring(tabIdx), tostring(index))
	end

	return key
end

local function CheckTab(tab, index)
	if index == 1 and (not tab or #tab ~= 4) then
		tab = {
			0,
			0,
			0,
			0
		}
	elseif index == 2 and (not tab or #tab ~= 3) then
		tab = {
			0,
			0,
			0
		}
	elseif index == 3 and (not tab or #tab ~= 4) then
		tab = {
			0,
			0,
			0,
			0
		}
	end

	return tab
end

function GetMapTab(listTab)
	local mapTab = {}

	for i = 1, 3 do
		local tab = CheckTab(listTab[i], i)

		for j = 1, #tab do
			local key = GetMapKey(i, j)

			mapTab[key] = tab[j]
		end
	end

	return mapTab
end

ATTRIBUTE_LEVEL = {
	FIRST = 1,
	SECOND = 2,
	THIRD = 3
}
AttributeOwner = class("AttributeOwner")

function AttributeOwner:ctor()
	self:Reset()
end

function AttributeOwner:Reset()
	self.attcomponent = AttributeAgent()
end

function AttributeOwner:SetBase(attName, value)
	attName = GetAttENKey(attName)

	self.attcomponent:SetBaseValue(attName, value)
end

function AttributeOwner:ModBase(attName, value)
	attName = GetAttENKey(attName)

	self.attcomponent:ModBaseValue(attName, value)
end

function AttributeOwner:ModMul(attName, value, level)
	attName = GetAttENKey(attName)

	self.attcomponent:ModMulValue(attName, value, level)
end

function AttributeOwner:ModAdd(attName, value, level)
	attName = GetAttENKey(attName)

	self.attcomponent:ModAddValue(attName, value, level)
end

function AttributeOwner:ModExtraMul(attName, value)
	attName = GetAttENKey(attName)

	self.attcomponent:ModExtraMulValue(attName, value, level)
end

function AttributeOwner:ModExtraAdd(attName, value)
	attName = GetAttENKey(attName)

	self.attcomponent:ModExtraAddValue(attName, value, level)
end

function AttributeOwner:Get(attName)
	attName = GetAttENKey(attName)

	return ExchangeAttValue(attName, self.attcomponent:GetTotalValue(attName))
end

function AttributeOwner:GetLevelGain(attName, level)
	attName = GetAttENKey(attName)

	return self.attcomponent:GetLevelGain(attName, level)
end

function AttributeOwner:GetBase(attName)
	attName = GetAttENKey(attName)

	return self.attcomponent:GetBase(attName)
end

function AttributeOwner:GetExtraMul(attName)
	attName = GetAttENKey(attName)

	return self.attcomponent:GetExtraMul(attName)
end

function AttributeOwner:GetExtraAdd(attName)
	attName = GetAttENKey(attName)

	return self.attcomponent:GetExtraAdd(attName)
end

local mt = class("AttributeAgent")

AttributeAgent = mt

local ATTRIBUTES = {
	Song = 1002,
	Stamina = 1000,
	Bruise = 1008,
	CritResist = 1009,
	Crit = 1007,
	BruiseDamage = 1010,
	Defend = 1001,
	Will = 1003,
	Duck = 1006,
	Speed = 1004,
	Hit = 1005
}

function mt:ctor()
	self:Reset()
end

function mt:Reset()
	self.map = {}
	self.dirtyMap = {}
end

function mt:Purge()
	self:Reset()
end

function mt:_Set(nt, val)
	local v = self:_Get(nt)

	self.map[nt] = v + val

	local final = nt * 0.01

	final = math.floor(final)
	self.dirtyMap[final] = true
end

function mt:_Get(nt)
	if self.map[nt] then
		return self.map[nt]
	end

	return 0
end

function mt:_Calculate(nt)
	local final = nt
	local BaseValue = self:_Get(final * 100 + 1)
	local BaseAdd = self:_Get(final * 100 + 11)
	local FirstAddValue = self:_Get(final * 100 + 2)
	local FirstMulValue = self:_Get(final * 100 + 3)
	local SecondAddValue = self:_Get(final * 100 + 4)
	local SecondMulValue = self:_Get(final * 100 + 5)
	local ThirdAddValue = self:_Get(final * 100 + 6)
	local ThirdMulValue = self:_Get(final * 100 + 7)
	local ret = (((BaseValue + BaseAdd) * (1 + FirstMulValue) + FirstAddValue) * (1 + SecondMulValue) + SecondAddValue) * (1 + ThirdMulValue) + ThirdAddValue

	self.map[final] = ret
	final = nt * 0.01
	final = math.floor(final)
	self.dirtyMap[final] = nil
end

function mt:GetBase(attrName)
	local nt = ATTRIBUTES[attrName]

	if nt then
		return self:_Get(nt * 100 + 1) + self:_Get(nt * 100 + 11)
	end

	return 0
end

function mt:GetExtraMul(attrName)
	local nt = ATTRIBUTES[attrName]

	if nt then
		return self:_Get(nt * 100 + 9)
	end

	return 0
end

function mt:GetExtraAdd(attrName)
	local nt = ATTRIBUTES[attrName]

	if nt then
		return self:_Get(nt * 100 + 8)
	end

	return 0
end

function mt:GetTotalValue(attrName)
	local nt = ATTRIBUTES[attrName]

	if nt then
		if self.dirtyMap[nt] then
			self:_Calculate(nt)
		end

		return self:_Get(nt)
	end
end

function mt:SetBaseValue(attrName, value)
	if not value then
		return
	end

	local nt = ATTRIBUTES[attrName]

	if not nt then
		return
	end

	self:_Set(nt * 100 + 1, value)
end

function mt:ModBaseValue(attrName, value)
	if not value then
		return
	end

	local nt = ATTRIBUTES[attrName]

	if not nt then
		return
	end

	self:_Set(nt * 100 + 11, value)
end

function mt:ModMulValue(attrName, v, l)
	if not v then
		return
	end

	local nt = ATTRIBUTES[attrName]

	if not nt then
		return
	end

	l = l or ATTRIBUTE_LEVEL.FIRST

	if l == ATTRIBUTE_LEVEL.FIRST then
		self:_Set(nt * 100 + 3, v)
	elseif l == ATTRIBUTE_LEVEL.SECOND then
		self:_Set(nt * 100 + 5, v)
	elseif l == ATTRIBUTE_LEVEL.THIRD then
		self:_Set(nt * 100 + 7, v)
	end
end

function mt:ModAddValue(attrName, v, l)
	if not v then
		return
	end

	local nt = ATTRIBUTES[attrName]

	if not nt then
		return
	end

	l = l or ATTRIBUTE_LEVEL.FIRST

	if l == ATTRIBUTE_LEVEL.FIRST then
		self:_Set(nt * 100 + 2, v)
	elseif l == ATTRIBUTE_LEVEL.SECOND then
		self:_Set(nt * 100 + 4, v)
	elseif l == ATTRIBUTE_LEVEL.THIRD then
		self:_Set(nt * 100 + 6, v)
	end
end

function mt:ModExtraMulValue(attrName, v)
	if not v then
		return
	end

	local nt = ATTRIBUTES[attrName]

	if not nt then
		return
	end

	self:_Set(nt * 100 + 9, v)
end

function mt:ModExtraAddValue(attrName, v)
	if not v then
		return
	end

	local nt = ATTRIBUTES[attrName]

	if not nt then
		return
	end

	self:_Set(nt * 100 + 8, v)
end

function mt:CalculateLevelGain(attrName, l)
	local nt = ATTRIBUTES[attrName]

	if not nt then
		return
	end

	local BaseValue = self:_Get(nt * 100 + 1)
	local BaseAdd = self:_Get(nt * 100 + 11)
	local FirstAddValue = self:_Get(nt * 100 + 2)
	local FirstMulValue = self:_Get(nt * 100 + 3)
	local SecondAddValue = self:_Get(nt * 100 + 4)
	local SecondMulValue = self:_Get(nt * 100 + 5)
	local ThirdAddValue = self:_Get(nt * 100 + 6)
	local ThirdMulValue = self:_Get(nt * 100 + 7)

	if l == ATTRIBUTE_LEVEL.SECOND then
		return ((BaseValue + BaseAdd) * (1 + FirstMulValue) + FirstAddValue) * SecondMulValue + SecondAddValue
	elseif l == ATTRIBUTE_LEVEL.THIRD then
		return (((BaseValue + BaseAdd) * (1 + FirstMulValue) + FirstAddValue) * (1 + SecondMulValue) + SecondAddValue) * ThirdMulValue + ThirdAddValue
	end

	return (BaseValue + BaseAdd) * FirstMulValue + FirstAddValue
end

function mt:GetLevelGain(attrName, l)
	return self:CalculateLevelGain(attrName, l)
end
