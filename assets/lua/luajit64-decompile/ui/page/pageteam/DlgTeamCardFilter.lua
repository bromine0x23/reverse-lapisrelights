-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTeam/DlgTeamCardFilter.lua

DlgTeamCardFilter = class("DlgTeamCardFilter", UIPanel)

function DlgTeamCardFilter:ctor()
	self.UIPrefabPath = "UI/PanelChooseCard/PanelCardFilter"
	self.listBtn = {}
end

function DlgTeamCardFilter:OnRegisterEvent()
	self:AddClick(self.BtnQuit, self.OnClickedBtnQuit, PATH_SFX_UI_CANCEL)
	self:AddClick(self.ButtonOk, self.OnClickedButtonOk, PATH_SFX_UI_CONFIRM)
	self:AddClick(self.ButtonDefault, self.OnClickedButtonDefault)
end

function DlgTeamCardFilter:OnUnRegisterEvent()
	self:RemoveClick(self.BtnQuit, self.OnClickedBtnQuit)
	self:RemoveClick(self.ButtonOk, self.OnClickedButtonOk)
	self:RemoveClick(self.ButtonDefault, self.OnClickedButtonDefault)

	for i = 1, #self.listBtn do
		for j = 1, #self.listBtn[i] do
			self:RemoveClick(self.listBtn[i][j], self.OnClickedBtn)
		end
	end
end

function DlgTeamCardFilter:OnEnter(vParam)
	self:DealWithLocalization()

	self.data = vParam
	self.panel = vParam.panel
	self.callback = vParam.callback
	self.listState = vParam.listState
	self.preListState = {}

	for i = 1, #vParam.listState do
		self.preListState[i] = {}

		for j = 1, #vParam.listState[i] do
			self.preListState[i][j] = vParam.listState[i][j]
		end
	end

	self.ButtonOk = self:GetChildGameObject("panel/okBtn")
	self.ButtonDefault = self:GetChildGameObject("panel/resetBtn")
	self.BtnQuit = self:GetChildGameObject("panel/btn_close")
	self.cols = {
		5,
		4,
		4
	}
	self.types = {
		1,
		1,
		2
	}
	self.listBtn = {}

	for i = 1, 3 do
		self.listBtn[i] = {}

		local col = self.cols[i]

		for j = 1, col do
			local btn

			if i == 1 then
				btn = self:GetChildGameObject("panel/job/" .. j)
			elseif i == 2 then
				btn = self:GetChildGameObject("panel/group/" .. j)
			else
				btn = self:GetChildGameObject("panel/sort/" .. j)
			end

			local goSel = GOUtil.FindChildGameObject(btn, "Select")
			local s = self.listState[i][j]

			SetActiveFunc(goSel, s == 1)
			self:AddClick(btn, self.OnClickedBtn)
			table.insert(self.listBtn[i], btn)
		end
	end
end

function DlgTeamCardFilter:DealWithLocalization()
	local TextAuto

	TextAuto = self:GetChildComponent("panel/title/Text/", "Text")
	TextAuto.text = Lang(5000018)
	TextAuto = self:GetChildComponent("panel/okBtn/Text/", "Text")
	TextAuto.text = Lang(5000019)
	TextAuto = self:GetChildComponent("panel/resetBtn/Text/", "Text")
	TextAuto.text = Lang(5000020)
	TextAuto = self:GetChildComponent("panel/job/Text/", "Text")
	TextAuto.text = Lang(5000021)
	TextAuto = self:GetChildComponent("panel/group/Text/", "Text")
	TextAuto.text = Lang(5000022)
	TextAuto = self:GetChildComponent("panel/sort/3/Txt/", "Text")
	TextAuto.text = Lang(5000023)
	TextAuto = self:GetChildComponent("panel/sort/2/Txt/", "Text")
	TextAuto.text = Lang(5000024)
	TextAuto = self:GetChildComponent("panel/sort/1/Txt/", "Text")
	TextAuto.text = Lang(5000025)
	TextAuto = self:GetChildComponent("panel/sort/Text/", "Text")
	TextAuto.text = Lang(5000026)
end

function DlgTeamCardFilter:OnClickedBtn(data)
	local g = data.pointerPress.gameObject
	local goSel = GOUtil.FindChildGameObject(g, "Select")

	for i = 1, #self.listBtn do
		for j = 1, #self.listBtn[i] do
			if self.listBtn[i][j] == g then
				local state = self.listState[i][j]
				local filterType = self.types[i]

				if filterType == 2 then
					for n = 1, #self.listBtn[i] do
						self.listState[i][n] = 0

						local go = GOUtil.FindChildGameObject(self.listBtn[i][n], "Select")

						SetActiveFunc(go, false)
					end
				end

				state = state == 0 and 1 or 0
				self.listState[i][j] = state

				SetActiveFunc(goSel, state == 1)

				return
			end
		end
	end
end

function DlgTeamCardFilter:OnClickedBtnQuit()
	local data = {}

	data.hasChange = false
	data.listState = self.preListState

	if self.callback then
		self.callback(self.panel, data)
	end

	self:Close()
end

function DlgTeamCardFilter:OnClickedButtonOk()
	local data = {}

	data.hasChange = true
	data.listState = self.listState

	if self.callback then
		self.callback(self.panel, data)
	end

	self:Close()
end

function DlgTeamCardFilter:OnClickedButtonDefault()
	for i = 1, 3 do
		local col = self.cols[i]

		for j = 1, col do
			self.listState[i][j] = 0

			local go = GOUtil.FindChildGameObject(self.listBtn[i][j], "Select")

			SetActiveFunc(go, false)
		end
	end
end
