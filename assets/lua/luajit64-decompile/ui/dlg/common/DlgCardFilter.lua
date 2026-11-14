-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgCardFilter.lua

DlgCardFilter = class("DlgCardFilter", UIPanel, true)

function DlgCardFilter:ctor()
	self.UIPrefabPath = "UI/Common/PanelCardFilter/PanelCardFilter"
	self.listBtn = {}
end

function DlgCardFilter:OnRegisterEvent()
	self:AddClick(self.BtnQuit, self.OnClickedBtnQuit)
	self:AddClick(self.ButtonOk, self.OnClickedButtonOk)
	self:AddClick(self.ButtonDefault, self.OnClickedButtonDefault)
end

function DlgCardFilter:OnUnRegisterEvent()
	self:RemoveClick(self.BtnQuit, self.OnClickedBtnQuit)
	self:RemoveClick(self.ButtonOk, self.OnClickedButtonOk)
	self:RemoveClick(self.ButtonDefault, self.OnClickedButtonDefault)

	for i = 1, #self.listBtn do
		for j = 1, #self.listBtn[i] do
			self:RemoveClick(self.listBtn[i][j], self.OnClickedBtn)
		end
	end
end

function DlgCardFilter:OnEnter(vParam)
	self:DealWithLocalization()

	self.data = vParam
	self.panel = vParam.panel
	self.callback = vParam.callback
	self.listRealState = vParam.listState
	self.listSimuState = {}

	for i = 1, #vParam.listState do
		self.listSimuState[i] = {}

		for j = 1, #vParam.listState[i] do
			self.listSimuState[i][j] = vParam.listState[i][j]
		end
	end

	self.Panel = self:GetChildGameObject("Panel")
	self.ButtonOk = self:GetChildGameObject("Panel/ButtonOk")
	self.ButtonDefault = self:GetChildGameObject("Panel/ButtonDefault")
	self.BtnQuit = self:GetChildGameObject("Panel/BtnQuit")
	self.Content = self:GetChildGameObject("Panel/Content")
	self.Cell = self:GetChildGameObject("Panel/Cell")
	self.Button = self:GetChildGameObject("Panel/Button")

	local cellWidth = GOUtil.GetRectTransformSizeDeltaWidth(self.Cell)
	local cellHeight = GOUtil.GetRectTransformSizeDeltaHeight(self.Cell)
	local offy = 0

	self.listBtn = {}

	local listTeamOrder = {}
	local listComb = CombinationMgr:GetCombinationSortByTeamOder()

	for i = 1, #listComb do
		table.insert(listTeamOrder, listComb[i].id)
	end

	for i = 1, #self.data do
		local v = self.data[i]
		local title = v.title
		local list = v.list
		local g = GOUtil.InstantiateUI(self.Cell, self.Content)
		local txtTitle = GOUtil.FindChildComponent(g, "Title/Text", "Text")

		txtTitle.text = title

		local txtMoreSel = GOUtil.FindChildComponent(g, "SelMode/Text", "Text")

		txtMoreSel.text = _("Desc_Sel_Multiple")

		local imgMoreSel = GOUtil.FindChildGameObject(g, "SelMode")

		SetActiveFunc(imgMoreSel, self.data[i].filterType == eChoiceType.Multiple)

		local num = math.ceil(#list / 4)

		GOUtil.SetRectTransformSizeDelta(g, cellWidth, cellHeight)

		offy = offy + (num - 2) * 110
		self.listBtn[i] = {}

		for j = 1, #list do
			local group = GOUtil.FindChildGameObject(g, "ScrollArea/mask/Group")
			local btn = GOUtil.InstantiateUI(self.Button, group)
			local goSel = GOUtil.FindChildGameObject(btn, "Select")
			local txt1 = GOUtil.FindChildComponent(btn, "Text", "Text")
			local txt2 = GOUtil.FindChildComponent(btn, "Select/Text", "Text")
			local Icon = GOUtil.FindChildComponent(btn, "Icon", "Image")

			txt1.text = list[j]
			txt2.text = list[j]

			local s = self.listSimuState[i][j]

			SetActiveFunc(goSel, s == 1)

			if title == _("eBattleType_2") then
				SetActiveFunc(txt1.gameObject, false)
				SetActiveFunc(txt2.gameObject, false)
				SetActiveFunc(Icon.gameObject, true)
				UIUtil.SetImageSprite(Icon, "UIDyAtlas/Team/IC_IDH_" .. listTeamOrder[j] .. "00", self)
			end

			self:AddClick(btn, self.OnClickedBtn)
			table.insert(self.listBtn[i], btn)
		end

		local group = GOUtil.FindChildGameObject(g, "ScrollArea/mask/Group")
		local widthGroup = GOUtil.GetRectTransformSizeDeltaWidth(group)
		local heightGroup = GOUtil.GetRectTransformSizeDeltaHeight(group)

		GOUtil.SetRectTransformSizeDelta(group, #list * 255, heightGroup)
	end

	local width = GOUtil.GetRectTransformSizeDeltaWidth(self.Panel)
	local height = GOUtil.GetRectTransformSizeDeltaHeight(self.Panel)

	height = height + (#self.data - 2) * cellHeight + offy

	GOUtil.SetRectTransformSizeDelta(self.Panel, width, 845)
	SetActiveFunc(self.Cell, false)
	SetActiveFunc(self.Button, false)
end

function DlgCardFilter:DealWithLocalization()
	local Text = self:GetChildComponent("Panel/ImgTitle/Text", "Text")

	Text.text = _("Filter")
	Text = self:GetChildComponent("Panel/ButtonOk/Text", "Text")
	Text.text = _("UI_OK")
	Text = self:GetChildComponent("Panel/ButtonDefault/Text", "Text")
	Text.text = _("UI_Recover")
end

function DlgCardFilter:OnClickedBtn(data)
	local g = data.pointerPress.gameObject
	local goSel = GOUtil.FindChildGameObject(g, "Select")

	for i = 1, #self.listBtn do
		for j = 1, #self.listBtn[i] do
			if self.listBtn[i][j] == g then
				local state = self.listSimuState[i][j]
				local filterType = self.data[i].filterType

				if filterType == eChoiceType.Single then
					for n = 1, #self.listBtn[i] do
						self.listSimuState[i][n] = 0

						local go = GOUtil.FindChildGameObject(self.listBtn[i][n], "Select")

						SetActiveFunc(go, false)
					end
				end

				state = state == 0 and 1 or 0
				self.listSimuState[i][j] = state

				SetActiveFunc(goSel, state == 1)

				return
			end
		end
	end
end

function DlgCardFilter:OnClickedBtnQuit()
	local data = {}

	data.hasChange = false
	data.listState = self.listRealState

	if self.callback then
		self.callback(self.panel, data)
	end

	self:Close()
end

function DlgCardFilter:OnClickedButtonOk()
	local data = {}

	data.hasChange = true
	data.listState = self.listSimuState

	if self.callback then
		self.callback(self.panel, data)
	end

	self:Close()
end

function DlgCardFilter:OnClickedButtonDefault()
	for i = 1, #self.data do
		local v = self.data[i]
		local list = v.list

		for j = 1, #list do
			self.listSimuState[i][j] = 0

			local go = GOUtil.FindChildGameObject(self.listBtn[i][j], "Select")

			SetActiveFunc(go, false)
		end
	end
end
