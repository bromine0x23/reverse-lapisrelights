-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageEquipment/CellAvatarAttr.lua

require("UI/Item/UIItemBase")

CellAvatarAttr = class("CellAvatarAttr", UIItemBase)

function CellAvatarAttr:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellAvatarAttr:OnEnter(vParam)
	local g = self.UIRootObject

	self.Icon = GOUtil.FindChildComponent(g, "Avatar/Icon", "Image")
	self.Text = GOUtil.FindChildComponent(g, "Text", "Text")
	self.Att = GOUtil.FindChildGameObject(g, "Att")
	self.Lock = GOUtil.FindChildGameObject(g, "Avatar/Lock")
	self.UIScrollView = GOUtil.FindChildComponent(g, "ScrollArea", "UIScrollView")
end

function CellAvatarAttr:UpdateData(infoAvatar, isUnLock)
	self.Text.text = infoAvatar:GetName()

	UIUtil.SetImageOverrideSprite(self.Icon, infoAvatar.data.Icon, self)
	GOUtil.SetActive(self.Lock, not isUnLock)

	local list = {}

	for k, v in ipairs(ATTRIBUTE_MAP[1]) do
		local t = {}
		local add = infoAvatar:GetAddAtt(v)

		if add > 0 then
			t.idx = k
			t.value = add
			t.type = eValueType.Abs

			table.insert(list, t)
		end

		t = {}
		add = infoAvatar:GetMulAtt(v)

		if add > 0 then
			t.idx = k
			t.value = add
			t.type = eValueType.Per

			table.insert(list, t)
		end
	end

	self.listCell = self.listCell or {}

	local function Update(tbl, info)
		tbl.txtAttr.text = _("eAttType_" .. info.idx)

		SetImageSprite(tbl.icon, "UI/PanelEquipment/AtlasEquipAvatar/ICO_nature_0" .. info.idx .. "_C", self)

		if info.type == eValueType.Abs then
			tbl.txtValue.text = "+" .. info.value
		else
			tbl.txtValue.text = "+" .. info.value * 100 .. "%"
		end
	end

	local function Create(info)
		local t = {}

		GOUtil.SetActive(self.Att, true)

		t.obj = GOUtil.InstantiateUI(self.Att, self.UIScrollView.content.gameObject)
		t.icon = GOUtil.FindChildComponent(t.obj, "ImgAttr", "Image")
		t.txtAttr = GOUtil.FindChildComponent(t.obj, "Text", "Text")
		t.txtValue = GOUtil.FindChildComponent(t.obj, "TxtValue", "Text")

		Update(t, info)
		table.insert(self.listCell, t)
		GOUtil.SetActive(self.Att, false)
	end

	local oldCnt = #self.listCell
	local newCnt = #list

	if oldCnt < newCnt then
		for i = 1, newCnt do
			if i <= oldCnt then
				GOUtil.SetActive(self.listCell[i].obj, true)
				Update(self.listCell[i], list[i])
			else
				Create(list[i], i)
			end
		end
	else
		for i = 1, oldCnt do
			if i <= newCnt then
				GOUtil.SetActive(self.listCell[i].obj, true)
				Update(self.listCell[i], list[i])
			else
				GOUtil.SetActive(self.listCell[i].obj, false)
			end
		end
	end
end

function CellAvatarAttr:OnLeave()
	UnloadAllImageSprite(self)
end
