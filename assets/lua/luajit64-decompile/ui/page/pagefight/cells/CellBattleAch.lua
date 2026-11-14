-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Cells/CellBattleAch.lua

require("UI/Item/UIItemBase")

CellBattleAch = class("CellBattleAch", UIItemBase)

function CellBattleAch:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellBattleAch:Create(vParam)
	CellBattleAch.base.Create(self, vParam)
end

function CellBattleAch:OnEnter()
	local g = self.UIRootObject

	self.GoImg = GOUtil.FindChildGameObject(g, "go_img")
	self.GoStar = GOUtil.FindChildGameObject(g, "go_star")
	self.TxtDesc = GOUtil.FindChildComponent(g, "txt_desc", "Text")
	self.TxtAward = GOUtil.FindChildComponent(g, "txt_award", "Text")
	self.ImgIcon = GOUtil.FindChildComponent(g, "go_icon", "Image")
	self.TxtNotAch = GOUtil.FindChildComponent(g, "txt_ach_not", "Text")
	self.TxtAch = GOUtil.FindChildComponent(g, "txt_ached", "Text")
	self.TxtNowAch = GOUtil.FindChildComponent(g, "txt_ach_now", "Text")
	self.ImgAchPro = GOUtil.FindChildComponent(g, "img_ach", "Image")
end

function CellBattleAch:OnLeave()
	EffectMgr:UnLoadEffect("Fx/UI/FX_UI_006/FX_UI_006")

	self.GoImg = nil
	self.GoStar = nil
	self.GoNotAch = nil
	self.GoAch = nil
	self.TxtDesc = nil
	self.TxtNotAch = nil
	self.TxtAch = nil
	self.TxtNowAch = nil
end

function CellBattleAch:UpdateData(index)
	self.GoImg:SetActive(index == 0)
	self.GoStar:SetActive(index ~= 0)
	self.TxtNotAch.gameObject:SetActive(index == 0)
	self.TxtNowAch.gameObject:SetActive(index == 1)
	self.TxtAch.gameObject:SetActive(index == 2)

	if index == 0 then
		UIUtil.SetGraphicColorRGBA(self.TxtDesc, 0.29411764705882354, 0.29411764705882354, 0.29411764705882354, 1)
		UIUtil.SetGraphicColorRGBA(self.ImgAchPro, 0, 0, 0, 0.7843137254901961)
		DealWithListRef(self, UIUtil.SetImageGray(self.ImgIcon, 1))
	end
end

function CellBattleAch:PlayAnim()
	if not IsNil(self.GoStar) then
		EffectMgr:Alloc("Fx/UI/FX_UI_006/FX_UI_006", self.GoStar, true, 1)
	end
end

function CellBattleAch:DestroyEffect()
	GOUtil.DestroyAllChildren(self.GoStar)
end
