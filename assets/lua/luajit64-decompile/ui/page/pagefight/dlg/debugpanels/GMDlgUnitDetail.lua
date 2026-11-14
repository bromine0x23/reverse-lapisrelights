-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DebugPanels/GMDlgUnitDetail.lua

GMDlgUnitDetail = class("GMDlgUnitDetail", UIPanel_sync)

function GMDlgUnitDetail:ctor()
	GMDlgUnitDetail.base.ctor(self, "UI/PageFight/Dlg/GMDlgUnitDetail")
end

function GMDlgUnitDetail:Cache()
	GMDlgUnitDetail.base.Cache(self)
end

function GMDlgUnitDetail:Close(tParam)
	GMDlgUnitDetail.base.Close(self, tParam)
end

function GMDlgUnitDetail:Purge()
	GMDlgUnitDetail.base.Purge(self)

	self.list = {}
end

function GMDlgUnitDetail:OnRegisterEvent()
	self:AddClick(self.touch_close, self.OnBtnClose)
	self:AddClick(self.btn_mul, self.OnBtnMul)
	self:AddClick(self.btn_add, self.OnBtnAdd)
	self.dropDown.onValueChanged:AddListener(function(idx)
		self:OnDropdown(idx)
	end)
end

function GMDlgUnitDetail:OnUnRegisterEvent()
	self:RemoveClick(self.touch_close, self.OnBtnClose)
	self:RemoveClick(self.btn_mul, self.OnBtnMul)
	self:RemoveClick(self.btn_add, self.OnBtnAdd)
	self.dropDown.onValueChanged:RemoveListener(function(idx)
		self:OnDropdown(idx)
	end)
end

function GMDlgUnitDetail:OnBtnClose()
	self:Close()

	self.unit = nil
	self.curItem = nil
	self.list = {}
end

function GMDlgUnitDetail:OnEnter(unit)
	self.curItem = nil
	self.unit = unit
	self.list = {}
	self.dropDown = self:GetChildComponent("panel/info/Dropdown", "Dropdown")

	self.dropDown.options:Clear()

	self.dropDownLabel = self:GetChildComponent("panel/info/Text", "Text")
	self.inputField = self:GetChildComponent("panel/info/InputField", "InputField")
	self.touch_close = self:GetChildGameObject("panel")
	self.btn_mul = self:GetChildGameObject("panel/info/btn_mul")
	self.btn_add = self:GetChildGameObject("panel/info/btn_add")

	local itemT = self:GetChildGameObject("panel/Scroll View/Viewport/Content/itemT")
	local label = GOUtil.GetComponent(GOUtil.FindGameObjectByName("Text", itemT.gameObject), "Text")

	label.text = unit.UnitTitle

	local itemRoot = itemT.transform.parent.gameObject
	local idx = 0

	for k, item in pairs(unit.AttributeMap) do
		table.insert(self.list, {
			key = k
		})
	end

	for i, item in ipairs(self.list) do
		local key = item.key

		item.gameObject = GOUtil.InstantiateUI(itemT, itemRoot)

		local txt = GOUtil.FindGameObjectByName("Text", item.gameObject)

		item.txt = GOUtil.GetComponent(txt, "Text")

		GOUtil.SetActive(item.gameObject, true)

		item.txt.text = key .. ":\n" .. unit:Get(key)

		local tempData = UnityEngine.UI.Dropdown.OptionData()

		tempData.text = key

		self.dropDown.options:Add(tempData)
	end

	self:OnDropdown(0)
end

function GMDlgUnitDetail:OnDropdown(idx)
	local item = self.list[idx + 1]

	if not item then
		return
	end

	if not self.unit.AttributeMap[item.key] then
		return
	end

	self.curItem = item

	local modify = self.unit.AttributeMap[item.key]

	self.dropDownLabel.text = item.key .. ":" .. self.unit:Get(item.key) .. "\n倍率：" .. modify.BaseValue .. "\n絶対値：" .. modify.AddValue
end

function GMDlgUnitDetail:OnBtnMul()
	if self.curItem == nil then
		return
	end

	self.unit:AddMul(self.curItem.key, tonumber(self.inputField.text))

	local item = self.curItem
	local key = item.key

	item.txt.text = key .. ":\n" .. self.unit:Get(key)

	local modify = self.unit.AttributeMap[item.key]

	self.dropDownLabel.text = item.key .. ":" .. self.unit:Get(item.key) .. "\n倍率：" .. modify.BaseValue .. "\n絶対値：" .. modify.AddValue
end

function GMDlgUnitDetail:OnBtnAdd()
	if self.curItem == nil then
		return
	end

	self.unit:Add(self.curItem.key, tonumber(self.inputField.text))

	local item = self.curItem
	local key = item.key

	item.txt.text = key .. ":\n" .. self.unit:Get(key)

	local modify = self.unit.AttributeMap[item.key]

	self.dropDownLabel.text = item.key .. ":" .. self.unit:Get(item.key) .. "\n倍率：" .. modify.BaseValue .. "\n絶対値：" .. modify.AddValue
end
