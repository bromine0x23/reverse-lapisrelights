-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/DataBuilder/Builder/AvatarBuilder.lua

AvatarBuilder = BClass("AvatarBuilder")

function AvatarBuilder:ctor(avatarId)
	self.id = avatarId
	self.data = ConfigTable.AvatarData[self.id]
	self.attrs = {}

	self:UpdateAttr()
end

function AvatarBuilder:UpdateAttr()
	Attribute:Init()

	if self.data.SkinAttList and #self.data.SkinAttList > 0 then
		local tab = self.data.SkinAttList

		for k, v in pairs(GetMapTab({
			tab
		})) do
			Attribute:ModifyAbsValue(k, v)
		end
	end

	self.attrs = Attribute:GetAttr()
end
