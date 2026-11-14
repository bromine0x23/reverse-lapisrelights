-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePass/PageTeamPass.lua

require("UI/Page/PagePass/CellTeamPass")

PageTeamPass = class("PageTeamPass", UIPanel)

function PageTeamPass:ctor()
	PageTeamPass.base.ctor(self, "UI/PanelPass/PanelTeamPass")
	self:AddChildPanel(DlgExit(), {
		title = _("TeamPass_UnitRequest"),
		callback = self.OnBack,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PageTeamPass:PreLoad()
	self:LoadResAsync("UI/PanelPass/CellTeamPass", "PrefabCell", GameObject)
end

function PageTeamPass:OnBack()
	UIMgr.PopPanel()
end

function PageTeamPass:Purge()
	PageTeamPass.base.Purge(self)
	UITweenUtil.RemoveTween(self.Content.transform)
	ResourceMgr.Unload(self.PrefabCell)

	if self.listCell then
		for i = 1, #self.listCell do
			self.listCell[i]:OnLeave()
			self:RemoveClick(self.listCell[i].UIRootObject, self.OnClickedCell)
		end

		self.listCell = nil
	end
end

function PageTeamPass:OnRegisterEvent()
	Event.Instance:Add("UpdateStageNum", self.UpdateStageNum, self)
end

function PageTeamPass:OnUnRegisterEvent()
	Event.Instance:Remove("UpdateStageNum", self.UpdateStageNum, self)
end

function PageTeamPass:OnEnter(vParam)
	self.GoBgNum = self:GetChildGameObject("Panel/BgNum")
	self.ChallengeNum = self:GetChildComponent("Panel/BgNum/Text", "Text")

	self:Init()
end

function PageTeamPass:Init()
	self.listComb = {}

	local list = GetConfigArgJson("TeamChapterUnlock")

	for _, v in ipairs(list) do
		if v and v[1] then
			local info = CombinationMgr:Get(v[1])

			if info.data.Version == 1 and info.data.StageVersion == 1 then
				table.insert(self.listComb, info)
			end
		end
	end

	self:UpdatePanel()
	self:InitList()
end

function PageTeamPass:UpdatePanel()
	local haveOpne = false
	local openTeamNum = #self.listComb

	for i = 1, openTeamNum do
		if CombChapterMgr.CombChapterIsUnLock(self.listComb[i].id) then
			haveOpne = true

			break
		end
	end

	local totalNum = CombChapterMgr.GetTotalLimitChallengeNum()

	SetActiveFunc(self.GoBgNum, haveOpne and totalNum ~= 0)

	if haveOpne and totalNum ~= 0 then
		local remainNum = CombChapterMgr.GetTotalRemainingChallengeNum()

		self.ChallengeNum.text = _("Desc_Last_Num") .. remainNum .. "/" .. totalNum
	end
end

function PageTeamPass:UpdateStageNum()
	self:UpdatePanel()
end

function PageTeamPass:InitList()
	local scrollArea = self:GetChildGameObject("Panel/ScrollArea")

	self.offX = GOUtil.GetRectTransformSizeDeltaWidth(scrollArea) / 2
	self.Content = self:GetChildGameObject("Panel/ScrollArea/Content")
	self.conW = GOUtil.GetRectTransformSizeDeltaWidth(self.Content)
	self.conH = GOUtil.GetRectTransformSizeDeltaHeight(self.Content)
	self.cw = GOUtil.GetRectTransformSizeDeltaWidth(self.PrefabCell)
	self.ch = GOUtil.GetRectTransformSizeDeltaHeight(self.PrefabCell)
	self.cl = 4
	self.cs = 5

	local count = #self.listComb + 1

	self.targetW = 2 * self.cl + count * self.cw + (count - 1) * self.cs
	self.targetW = TenaryOp(self.targetW < self.conW, self.conW, self.targetW)

	GOUtil.SetRectTransformSizeDelta(self.Content, self.targetW, self.conH)

	self.listCell = {}

	for i = 1, count do
		local item = CellTeamPass(self.PrefabCell, self.Content, self)

		item:Create()

		item.UIRootObject.name = i

		local infoComb = self.listComb[i]

		item:UpdateData(infoComb)
		GOUtil.SetRectTransformAnchoredPosition(item.UIRootObject, (i - 1) * (self.cw + self.cs) + self.cl, 0)
		table.insert(self.listCell, item)
		self:AddClick(item.UIRootObject, self.OnClickedCell)
	end

	UITweenUtil.PageTeamTween(self.Content.transform, 200, 0.2, true)
end

function PageTeamPass:OnClickedCell(data)
	local go = data.pointerPress
	local index = tonumber(go.name)

	if index == #self.listCell then
		return
	end

	PageTeamPass.EnterStage(index)
	ChapterRDL.CombRDL.RemoveUnlockPlayerPrefs(self.listComb[index].id)
end

function PageTeamPass.EnterStage(index)
	local list = GetConfigArgJson("TeamChapterUnlock")
	local listComb = {}

	for _, v in ipairs(list) do
		if v and v[1] then
			local info = CombinationMgr:Get(v[1])

			table.insert(listComb, info)
		end
	end

	infoComb = listComb[index]

	local isUnLock = CombChapterMgr.CombChapterIsUnLock(infoComb.data.ID)

	if isUnLock then
		ChapterMgr.teamIndex = infoComb.data.ID

		require("UI/Page/PagePass/PageStage")
		UIMgr.SwitchPanel(PageStage, {
			chapterType = 2,
			combId = infoComb.data.ID
		})
	else
		local str = ""

		for k, v in pairs(GetConfigArgJson("TeamChapterUnlock")) do
			if v[1] == infoComb.data.ID then
				local infoStage = ChapterMgr:GetStage(v[2])
				local _, i, j = ChapterMgr:GetChapterByStageID(v[2])
				local strStage = " <color=yellow>" .. i .. "-" .. j .. "</color> "

				str = strStage .. "<color=white>" .. Lang(infoStage.data.Name) .. "</color> " .. Localization("Prompt_TutorialLimitStage")
			end
		end

		UIMgr.ShowMsg(str)
	end
end

function PageTeamPass:OnClickedBtnLeft()
	local ax = self:GetAnchoredPositionX(1)

	GOUtil.SetRectTransformAnchoredPosition(self.Content, ax, 0)
end

function PageTeamPass:OnClickedBtnRight()
	local ax = self:GetAnchoredPositionX(2)

	GOUtil.SetRectTransformAnchoredPosition(self.Content, ax, 0)
end

function PageTeamPass:GetAnchoredPositionX(index)
	local xMax = 0
	local xMin = self.conW - self.targetW
	local dis = self.cw + self.cs
	local conX = GOUtil.GetTransformLocalPosition(self.Content, x, y, z)
	local anchX = conX + self.offX

	if index == 1 then
		local dl = math.abs(anchX)

		if dl <= dis then
			anchX = xMax
		else
			anchX = anchX + dis
		end
	else
		local dr = self.targetW - self.conW + anchX

		if dr <= dis then
			anchX = xMin
		else
			anchX = anchX - dis
		end
	end

	return anchX
end
