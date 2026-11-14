-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Manager/LanguageMgr.lua

LanguageMgr = {}

function LanguageMgr.Init()
	InitLocalLanguage()
end

local _LocaleText = require("luaData/Language")

function LanguageMgr.GetText(id)
	if _LocaleText[id] == nil or _LocaleText[id].Value == "nil" then
		return ""
	end

	return _LocaleText[id].Value
end

local _Locale = {}

function InitLocalLanguage()
	for _, v in pairs(_LocaleText) do
		if v.Key ~= "" then
			_Locale[v.Key] = v
		end
	end
end

function LanguageMgr.Localization(key)
	if _Locale[key] == nil then
		return key
	end

	return _Locale[key].Value
end
