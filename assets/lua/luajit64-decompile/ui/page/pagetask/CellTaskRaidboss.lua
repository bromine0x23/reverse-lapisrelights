-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTask/CellTaskRaidboss.lua

require("UI/Item/UIItemBase")

CellTaskRaidboss = class("CellTaskRaidboss", UIItemBase)

function CellTaskRaidboss:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellTaskRaidboss:OnEnter(vParam)
	local g = self.UIRootObject

	self:DealWithLocalization(g)

	self.TextFrom = GOUtil.FindChildComponent(g, "Title/Text", "Text")
	self.TextInfo = GOUtil.FindChildComponent(g, "Title/TextInfo", "Text")

	GOUtil.SetFont(self.TextInfo, UIMgr.JPFonts.W5)

	self.ImageFill = GOUtil.FindChildComponent(g, "ImageBar/ImageFill", "Image")
	self.TextNum = GOUtil.FindChildComponent(g, "ImageBar/TextNum", "Text")
	self.TextNum.fontSize = 23
	self.ButtonGet = GOUtil.FindChildGameObject(g, "ButtonGet")
	self.ButtonGo = GOUtil.FindChildGameObject(g, "ButtonGo")
	self.GoGeted = GOUtil.FindChildGameObject(g, "GoGeted")
	self.taskSection = GOUtil.FindChildGameObject(g, "taskSection")
	self.taskSection1 = GOUtil.FindChildGameObject(g, "taskSection/taskSection1")
	self.taskSection2 = GOUtil.FindChildGameObject(g, "taskSection/taskSection2")
	self.taskSection3 = GOUtil.FindChildGameObject(g, "taskSection/taskSection3")

	self:AddClick(self.ButtonGet, self.OnClickedGet)
	self:AddClick(self.ButtonGo, self.OnClickedGo)

	self.listItem = {}

	for i = 1, 6 do
		local gItem = GOUtil.FindChildGameObject(g, "ItemGroup/Viewport/Tag/" .. i)
		local item = CellItem(gItem)

		item:InitItemByRoot(gItem)
		table.insert(self.listItem, item)
	end
end

function CellTaskRaidboss:DealWithLocalization(g)
	local txt

	txt = GOUtil.FindChildComponent(g, "ButtonGet/Text", "Text")
	txt.text = _("Desc_Get")
	txt = GOUtil.FindChildComponent(g, "ButtonGo/Text", "Text")
	txt.text = _("UI_Go")
end

function CellTaskRaidboss:OnLeave()
	if self.listItem then
		for _, item in ipairs(self.listItem) do
			if item.OnLeave then
				item:OnLeave()
			end
		end

		self.listItem = nil
	end

	self:RemoveClick(self.ButtonGet, self.OnClickedGet)
	self:RemoveClick(self.ButtonGo, self.OnClickedGo)
end

function CellTaskRaidboss:OnClickedGet()
	OperationActiveMgr.BattlePassTag = "Tab2"

	Event.Instance:Fire("DealWithCompleteTask", {
		self.info
	})
end

function CellTaskRaidboss:OnClickedGo()
	if self.info and #self.info.data.FromWhere > 0 then
		if self.callback then
			self.callback()
		end

		OperationActiveMgr.BattlePassTag = "Tab2"

		DlgItemTip.GoToFrom(self.info.data.FromWhere[1])
	end
end

function CellTaskRaidboss:FormatJPText(text)
	local s = string.gsub(text, "<[^>]*>", "")

	return s
end

function CellTaskRaidboss:UpdateData(info, isBattlePass, roleID, callback)
	self.info = info
	self.roleID = roleID
	self.TextFrom.text = info:GetName()
	self.TextInfo.text = self:FormatJPText(info:GetDescTitle())
	self.callback = callback

	if isBattlePass == nil then
		isBattlePass = false
	end

	GOUtil.SetActive(self.TextInfo, not isBattlePass)

	if isBattlePass then
		self.TextFrom.text = string.format("<color=#0D9799>[%s] </color>", info:GetName()) .. info:GetDesc()
	end

	local curNum = info:GetCurNum()
	local needNum = info:GetNeedNum()

	self.TextNum.text = "<color=#29c4c4>" .. NumMagnitudeConversion(curNum) .. "</color>/" .. NumMagnitudeConversion(needNum)
	self.ImageFill.gameObject.transform.localScale = Vector3(TenaryOp(curNum / needNum > 1, 1, curNum / needNum), 1, 1)

	local isComple = info:IsComplete()
	local isGeted = info:IsGetAward()

	GOUtil.SetActive(self.ButtonGet, not isGeted and isComple)
	GOUtil.SetActive(self.ButtonGo, not isComple and next(self.info.data.FromWhere) ~= nil)
	GOUtil.SetActive(self.GoGeted, isGeted)

	self.listAward = info.data.Reward

	for i = 1, 6 do
		local item = self.listItem[i]
		local listAward = info.data.Reward[i]

		if listAward then
			local infoItem = ItemManager:GetValueItem(listAward[1], listAward[2])

			item:UpdateWithNumType(infoItem)
			GOUtil.SetActive(item.UIRootObject, true)
		else
			GOUtil.SetActive(item.UIRootObject, false)
		end
	end

	if not IsNil(self.taskSection) then
		SetActiveFunc(self.taskSection, info.sectionType)
		SetActiveFunc(self.taskSection1, info.sectionType and info.sectionType == 1)
		SetActiveFunc(self.taskSection2, info.sectionType and info.sectionType == 2)
		SetActiveFunc(self.taskSection3, info.sectionType and info.sectionType == 3)
	end
end
