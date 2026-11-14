-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionRaid/CellUnionRaid.lua

require("UI/Item/UIItemBase")

CellUnionRaid = class("CellUnionRaid", UIItemBase)

function CellUnionRaid:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellUnionRaid:OnEnter(vParam)
	local g = self.UIRootObject
	local txt = GOUtil.FindChildComponent(g, "Panel1/Info/Text", "Text")

	txt.text = string.format(Lang(5000005), "")
	self.Panel2 = GOUtil.FindChildGameObject(g, "Panel2")
	self.TxtName = GOUtil.FindChildComponent(g, "Panel1/Info/TxtName", "Text")
	self.ImgRate = GOUtil.FindChildComponent(g, "Panel1/Rate/Bar", "Image")
	self.TxtRate = GOUtil.FindChildComponent(g, "Panel1/Rate/TxtValue", "Text")
end

function CellUnionRaid:OnLeave()
	return
end

function CellUnionRaid:UpdateData(infoRaid)
	self.info = infoRaid

	GOUtil.SetActive(self.Panel2, infoRaid:IsFinished() and not infoRaid:IsReceived())

	self.TxtName.text = Lang(infoRaid.data.Name[1])
	infoRaid.progress = math.min(infoRaid.progress, infoRaid.data.FinishPoint)
	self.TxtRate.text = "<color=#52dcd6>" .. infoRaid.progress .. "</color>/" .. infoRaid.data.FinishPoint
	self.ImgRate.fillAmount = infoRaid.progress / infoRaid.data.FinishPoint
end
