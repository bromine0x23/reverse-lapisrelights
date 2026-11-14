-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionRaid/CellRaidBuff.lua

require("UI/Item/UIItemBase")

local skillTip = require("UI/Dlg/Common/SkillTipDesc")

CellRaidBuff = class("CellRaidBuff", UIItemBase)

function CellRaidBuff:ctor(itemPrefabCache, parent)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellRaidBuff:Create(vParam)
	CellRaidBuff.base.Create(self, vParam)
end

function CellRaidBuff:OnEnter()
	local g = self.UIRootObject

	self.TxtName = GOUtil.FindChildComponent(g, "Image/TxtName", "Text")
	self.TxtAdd = GOUtil.FindChildComponent(g, "Image/TxtAdd", "Text")
	self.ImgIcon = GOUtil.FindChildComponent(g, "BgIcon/Icon", "Image")
	self.TxtInfo = GOUtil.FindChildComponent(g, "Content/Text", "Text")
end

function CellRaidBuff:UpdateData(infoTalent)
	if infoTalent == nil then
		return
	end

	SetImageSprite(self.ImgIcon, "UIDyAtlas/Skill/" .. infoTalent.data.Icon, self)

	self.TxtName.text = Lang(infoTalent.data.Name)
	self.TxtInfo.text = skillTip.GetDesc(infoTalent.id, infoTalent.pb.level, 0)
end

function CellRaidBuff:OnLeave()
	UnloadAllImageSprite(self)
end
