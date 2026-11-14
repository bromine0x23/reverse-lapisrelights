-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Cells/CellSlotIcon.lua

local SESSION_IMG_PATH = {
	"UIDyAtlas/Battle/ui_hd_icon_sing_line",
	"UIDyAtlas/Battle/ui_hd_icon_charge_line",
	"UIDyAtlas/Battle/ui_hd_icon_dance_line"
}

CellSlotIcon = class("CellSlotIcon", UIPanel_sync)

function CellSlotIcon:ctor()
	CellSlotIcon.base.ctor(self, "UI/PageFight/Cells/CellSlotIcon")
end

function CellSlotIcon:Cache()
	CellSlotIcon.base.Cache(self)

	for i, path in ipairs(SESSION_IMG_PATH) do
		ResourceMgr.SubmitCache(path, self, "SessionImgPath" .. i, Sprite)
	end
end

function CellSlotIcon:OnEnter(vParam)
	self.unitId = nil
	self.sessionType = nil
	self.index = vParam.index
	self.img_icon = self:GetChildComponent("img_icon", "Image")
	self.obj_effs = {}
	self.obj_effsRoot = self:GetChildGameObject("eff")

	for i = EnumBattle.SeccionType.attack, EnumBattle.SeccionType.recover do
		table.insert(self.obj_effs, self.obj_effsRoot.transform:GetChild(i - 1))
	end
end

function CellSlotIcon:Close()
	CellSlotIcon.base.Close(self)

	self.unitId = nil
	self.sessionType = nil
	self.index = -1
	self.img_icon = nil
end

function CellSlotIcon:Purge()
	CellSlotIcon.base.Purge(self)

	for i, path in ipairs(SESSION_IMG_PATH) do
		self["SessionImgPath" .. i] = nil
	end
end

function CellSlotIcon:OnRegisterEvent()
	return
end

function CellSlotIcon:OnUnRegisterEvent()
	return
end

function CellSlotIcon:SetParent(root)
	GOUtil.AttachGameObject(self.UIRootObject, root, true)
end

function CellSlotIcon:Reset()
	self.img_icon.enabled = false
	self.unitId = nil
	self.sessionType = nil

	for _sessionType, effobj in ipairs(self.obj_effs) do
		GOUtil.SetActive(effobj, false)
	end
end

function CellSlotIcon:Refresh(unitId, sessionType)
	self.unitId = unitId
	self.sessionType = sessionType

	local sprite = self["SessionImgPath" .. sessionType]

	UIUtil.SetImageSprite(self.img_icon, sprite)

	self.img_icon.enabled = true

	for _sessionType, effobj in ipairs(self.obj_effs) do
		GOUtil.SetActive(effobj, _sessionType == sessionType)
	end
end

function CellSlotIcon:RefreshEffect(val)
	GOUtil.SetActive(self.obj_effsRoot, val)
end
