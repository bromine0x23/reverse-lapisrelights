-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoBase.lua

InfoBase = class("InfoBase")

function InfoBase:ctor(id)
	self.pb = {}
	self.id = id
end

function InfoBase:GetName()
	return Lang(self.data.Name)
end

function InfoBase:GetDesc()
	if self.data.Info then
		return Lang(self.data.Info)
	end

	return Lang(self.data.Desc)
end

function InfoBase:GetDescTitle()
	local title = Lang(self.data.Info)

	if self.data.ArgInt then
		title = string.gsub(title, "{ArgInt}", tostring(self.data.ArgInt))

		if string.find(title, "{ArgInt_Character_Name}") ~= nil then
			local Data = require("luaData/CharacterRole")

			if Data[self.data.ArgInt] then
				title = string.gsub(title, "{ArgInt_Character_Name}", Lang(Data[self.data.ArgInt].Name))
			end
		elseif string.find(title, "{ArgInt_CharacterCard_Name}") ~= nil then
			local Data = require("luaData/CharacterCard")

			if Data[self.data.ArgInt] then
				title = string.gsub(title, "{ArgInt_CharacterCard_Name}", Lang(Data[self.data.ArgInt].Name))
			end
		elseif string.find(title, "{ArgInt_ItemData_Name}") ~= nil then
			local Data = require("luaData/ItemData")

			if Data[self.data.ArgInt] then
				title = string.gsub(title, "{ArgInt_ItemData_Name}", Lang(Data[self.data.ArgInt].Name))
			end
		elseif string.find(title, "{ArgInt_AvatarData_Name}") ~= nil then
			local Data = require("luaData/AvatarData")

			if Data[self.data.ArgInt] then
				title = string.gsub(title, "{ArgInt_AvatarData_Name}", Lang(Data[self.data.ArgInt].Name))
			end
		end
	end

	if self.data.ArgJson then
		for i = 1, #self.data.ArgJson do
			title = string.gsub(title, "{ArgJson" .. i .. "}", tostring(self.data.ArgJson[i]))

			if string.find(title, "{ArgJson" .. i .. "_Character_Name}") ~= nil then
				local Data = require("luaData/CharacterRole")

				if Data[self.data.ArgJson[i]] then
					title = string.gsub(title, "{ArgJson" .. i .. "_Character_Name}", Lang(Data[self.data.ArgJson[i]].Name))
				end
			elseif string.find(title, "{ArgJson" .. i .. "_CharacterCard_Name}") ~= nil then
				local Data = require("luaData/CharacterCard")

				if Data[self.data.ArgJson[i]] then
					title = string.gsub(title, "{ArgJson" .. i .. "_CharacterCard_Name}", Lang(Data[self.data.ArgJson[i]].Name))
				end
			elseif string.find(title, "{ArgJson" .. i .. "_ItemData_Name}") ~= nil then
				local Data = require("luaData/ItemData")

				if Data[self.data.ArgJson[i]] then
					title = string.gsub(title, "{ArgJson" .. i .. "_ItemData_Name}", Lang(Data[self.data.ArgJson[i]].Name))
				end
			elseif string.find(title, "{ArgJson" .. i .. "_AvatarData_Name}") ~= nil then
				local Data = require("luaData/AvatarData")

				if Data[self.data.ArgJson[i]] then
					title = string.gsub(title, "{ArgJson" .. i .. "_AvatarData_Name}", Lang(Data[self.data.ArgJson[i]].Name))
				end
			end
		end
	end

	if self.data.Info then
		return title
	end

	return Lang(self.data.Desc)
end
