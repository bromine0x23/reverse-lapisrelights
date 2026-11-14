-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/DataBuilder/Attribute.lua

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

function GetKeyByIndex(index)
	return ATTRIBUTE_NAME[index] or "Stamina"
end

local function GetKeyByStr(str)
	for k, v in pairs(ATTRIBUTE_NAME) do
		if str == v then
			return ATTRIBUTE_NAME[k]
		end
	end

	return "Stamina"
end

local function GetValueType(key)
	if key == "Stamina" or key == "Defend" or key == "Song" or key == "Will" or key == "Speed" then
		return eValueType.Abs
	end

	return eValueType.Per
end

local function GetENKey(v)
	if type(v) == "number" then
		return GetKeyByIndex(v)
	elseif type(v) == "string" then
		return GetKeyByStr(v)
	end

	return "Stamina"
end

function ExchangeAttrValue(name, value)
	local t = GetValueType(GetENKey(name))

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
		print("tabIdx [%s], index [%s] not exist！！！", "red", tostring(tabIdx), tostring(index))
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

Attribute = Attribute or {}

function Attribute:Init()
	self.attAbsTab = {}
	self.attPerTab = {}
	self.attExtraTab = {}

	self:Reset()
end

function Attribute:Reset()
	for _, v in pairs(ATTRIBUTE_NAME) do
		self.attAbsTab[v] = 0
		self.attPerTab[v] = 0
		self.attExtraTab[v] = 0
	end
end

function Attribute:ModifyAbsValue(key, value)
	self.attAbsTab[key] = self.attAbsTab[key] + value
end

function Attribute:ModifyPerValue(key, value)
	self.attPerTab[key] = self.attPerTab[key] + value
end

function Attribute:ModeExtraValue(key, value)
	self.attExtraTab[key] = self.attExtraTab[key] + value
end

function Attribute:GetAttr()
	local att = {}

	for _, v in pairsByKeys(ATTRIBUTE_NAME) do
		att[v] = self.attAbsTab[v] * (1 + self.attPerTab[v]) + self.attExtraTab[v]
	end

	return att
end

return Attribute
