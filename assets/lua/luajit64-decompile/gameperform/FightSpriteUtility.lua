-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/FightSpriteUtility.lua

FightSpriteUtility = class("FightSpriteUtility")

function FightSpriteUtility:ctor(GP)
	self.GP = GP

	self:Reset()
end

function FightSpriteUtility:Reset()
	self.Sprites = self.GP.PrewarmUtil.Sprites
end

function FightSpriteUtility:Purge()
	self.Sprites = nil
end

function FightSpriteUtility:GetSprite(path)
	local sp = self.Sprites[path]

	if not sp then
		print("<color=green>sprite not submitCache , path:" .. tostring(path) .. "</color>")
	end

	return sp
end

function FightSpriteUtility:SetSprite(img, path)
	local sp = self:GetSprite(path)

	if not sp then
		UIUtil.SetImageSprite(img, path)
	else
		UIUtil.SetImageSprite(img, sp)
	end
end
