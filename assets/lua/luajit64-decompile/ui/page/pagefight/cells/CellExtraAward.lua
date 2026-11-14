-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Cells/CellExtraAward.lua

require("UI/Item/UIItemBase")

CellExtraAward = class("CellExtraAward", UIItemBase)

function CellExtraAward:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellExtraAward:OnEnter()
	local g = self.UIRootObject

	self.Text = self:GetChildComponent("TexBg/Text", "Text")
	self.Image = self:GetChildComponent("Image", "Image")
end

function CellExtraAward:PlayEffect(fxPath)
	if not self.trans_effRoot then
		self.trans_effRoot = self.img_fill.transform
	end

	if fxPath and fxPath ~= "" then
		EffectMgr:Alloc(fxPath, self.trans_effRoot, true, 1)
	end
end

function CellExtraAward:UpdateData(value, typeId)
	self.Text.text = value .. ""

	if typeId == 1 then
		UIUtil.SetImageSprite(self.Image, "UI/PageFight/AtlasResult/FX_moneybag_02c_1")

		self.Eff_UI_Monster_Hit_money03_copper = self:GetChildGameObject("Eff_UI_Monster_Hit_money03_copper"):SetActive(true)
	elseif typeId == 2 then
		UIUtil.SetImageSprite(self.Image, "UI/PageFight/AtlasResult/FX_moneybag_02b_1")

		self.Eff_UI_Monster_Hit_money03_silver = self:GetChildGameObject("Eff_UI_Monster_Hit_money03_silver"):SetActive(true)
	elseif typeId == 3 then
		UIUtil.SetImageSprite(self.Image, "UI/PageFight/AtlasResult/FX_moneybag_02a_1")

		self.Eff_UI_Monster_Hit_money03_golden = self:GetChildGameObject("Eff_UI_Monster_Hit_money03_golden"):SetActive(true)
	end
end

function CellExtraAward:UpdateDataRaidBoss(value, typeId)
	self.Text.text = value .. ""

	if typeId == 1 then
		UIUtil.SetImageSprite(self.Image, "UI/PanelActivityBossRaid/AtlasBossPreview/Ic_Bossraidbox_01")

		self.Eff_UI_Monster_Hit_money03_copper = self:GetChildGameObject("Eff_UI_Monster_Hit_money03_copper"):SetActive(true)
	elseif typeId == 2 then
		UIUtil.SetImageSprite(self.Image, "UI/PanelActivityBossRaid/AtlasBossPreview/Ic_Bossraidbox_02")

		self.Eff_UI_Monster_Hit_money03_silver = self:GetChildGameObject("Eff_UI_Monster_Hit_money03_silver"):SetActive(true)
	elseif typeId == 3 then
		UIUtil.SetImageSprite(self.Image, "UI/PanelActivityBossRaid/AtlasBossPreview/Ic_Bossraidbox_03")

		self.Eff_UI_Monster_Hit_money03_golden = self:GetChildGameObject("Eff_UI_Monster_Hit_money03_golden"):SetActive(true)
	end
end
