-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionRaid/PageUnionRaid.lua

require("UI/Item/CellScoreItem")
require("UI/Page/PageUnionRaid/CellUnionRaid")
require("UI/Page/PageUnionRaid/PageRaid")
require("UI/Page/PageUnionRaid/DlgRaidDetail")

local InfoTeamBossRaid = require("Info.InfoTeamBossRaid")

PageUnionRaid = class("PageUnionRaid", UIPanel)

function PageUnionRaid:ctor()
	self.UIPrefabPath = "UI/PanelUnionRaid/PanelUnionRaid"
	self.DlgExit = DlgExit()

	self:AddChildPanel(self.DlgExit, {
		title = _("Item_From_19_4"),
		callback = self.OnBack,
		helpCallback = self.OnClickedBtnGuide,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PageUnionRaid:PreLoad()
	self:LoadResAsync("UI/Item/CellScoreItem", "PrefabCellScoreItem", GameObject)
	self:LoadResAsync("UI/PanelUnionRaid/CellUnionRaid", "PrefabCellUnionRaid", GameObject)
	self:LoadResAsync("UISpine/UI_Club/UI_Bg_Raid/Bg_Club_02", "PrefabBgSpine", GameObject)
end

function PageUnionRaid:OnBack()
	UITweenUtil.RemoveAllTween()

	local prePanel = UIMgr.GetPrePanel()

	if prePanel.className == "PageUnion" then
		UIMgr.PopPanel({
			needRequestUnion = true
		})
	else
		UIMgr.PopPanel()
	end
end

function PageUnionRaid:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellScoreItem)
	ResourceMgr.Unload(self.PrefabCellUnionRaid)
	ResourceMgr.Unload(self.PrefabBgSpine)

	if self.listCellItem then
		for _, item in ipairs(self.listCellItem) do
			if item.OnLeave then
				item:OnLeave()
			end
		end

		self.listCellItem = nil
	end

	InfoSoundEventMgr:OnBack()
end

function PageUnionRaid:OnRegisterEvent()
	self:AddClick(self.GoBoss, self.OnClickedBossRaid)
	self:AddClick(self.GoBossAward, self.OnClickedBossAward)
	self:AddClick(self.BtnCardView, self.OnClickedBtnCardView)
	self:AddClick(self.BtnHpReply, self.OnClickedBtnHpReply)
	self:AddClick(self.BtnBuffView, self.OnClickedBtnBuffView)
	Event.Instance:Add("UpdateRaidSystem", self.UpdatePanel, self)
	EventListenerMgr.AddAnimListener(self.UIRootObject, self.OnEndRootAnim, self, eAnimEventType.OnAnimationEnd)
end

function PageUnionRaid:OnUnRegisterEvent()
	self:RemoveClick(self.GoBoss, self.OnClickedBossRaid)
	self:RemoveClick(self.GoBossAward, self.OnClickedBossAward)
	self:RemoveClick(self.BtnCardView, self.OnClickedBtnCardView)
	self:RemoveClick(self.BtnHpReply, self.OnClickedBtnHpReply)
	self:RemoveClick(self.BtnBuffView, self.OnClickedBtnBuffView)
	Event.Instance:Remove("UpdateRaidSystem", self.UpdatePanel, self)
	EventListenerMgr.RemoveAnimListener(self.UIRootObject, self.OnEndRootAnim, self, eAnimEventType.OnAnimationEnd)

	if self.listCellRaid then
		for i = 1, #self.listCellRaid do
			self:RemoveClick(self.listCellRaid[i], self.OnClickedCommRaid)
		end

		self.listCellRaid = nil
	end
end

function PageUnionRaid.RequestData(cb, notNeedLeave)
	if not UnionMgr.HasUnion() then
		return
	end

	if not UnionRaidMgr.IsRaidOpen() then
		UIMgr.ShowMsg(_("Desc_Not_Open"))

		return
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			if cb then
				cb()
			end

			UnionRaidMgr.LastRequestTime = NetData:GetCurServerTime()
		elseif vMsg.result.code == 2 then
			if not notNeedLeave then
				PageUnion.GoBackMainPage(vMsg)
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestUnionRaidData(wrap_cb)
end

function PageUnionRaid:OnEnter()
	if not GuideMgr:IsGuided(GuideFunctionType.UnionRaid) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.UnionRaid)
	end

	self:DealWithLocalization()

	self.Bg = self:GetChildGameObject("Bg")

	GOUtil.InstantiateUIPrefab(self.PrefabBgSpine, self.Bg)

	self.GoBossRaid = self:GetChildGameObject("Panel/Raid/Boss")
	self.GoBoss = self:GetChildGameObject("Panel/Raid/Boss/GoBoss")
	self.GoBossAward = self:GetChildGameObject("Panel/Raid/Boss/GoBossAward")
	self.GoComplete = self:GetChildGameObject("Panel/Raid/Boss/GoComplete")
	self.ImgBossAward = GOUtil.GetComponent(self.GoBossAward, "Image")
	self.GoRate = self:GetChildGameObject("Panel/Cheer/Rate")
	self.ImgRateBar = self:GetChildComponent("Panel/Cheer/Rate/Bar", "Image")
	self.TxtRateNum = self:GetChildComponent("Panel/Cheer/TxtNum", "Text")
	self.TxtPlayNum = self:GetChildComponent("Panel/Play/Text", "Text")
	self.TxtCountdown = self:GetChildComponent("Panel/Time/Text", "Text")
	self.BtnBuffView = self:GetChildGameObject("Panel/BtnBuffView")
	self.BtnHpReply = self:GetChildGameObject("Panel/BtnHpReply")
	self.BtnCardView = self:GetChildGameObject("Panel/BtnCardView")

	self:Init()
end

function PageUnionRaid:DealWithLocalization()
	local txt = self:GetChildComponent("Panel/Cheer/Text", "Text")

	txt.text = _("Desc_Cheer_Sum_Raid")
	txt = self:GetChildComponent("Panel/BtnCardView/Text", "Text")
	txt.text = _("Desc_Raid_Card_View")
	txt = self:GetChildComponent("Panel/BtnHpReply/Text", "Text")
	txt.text = Lang(42140)
	txt = self:GetChildComponent("Panel/BtnBuffView/Text", "Text")
	txt.text = Lang(42531)
end

function PageUnionRaid:Init()
	self.listScore = {}
	self.listAward = {}

	for _, config in ipairs(GetConfigArgJson("ClubMirrorContributionAward")) do
		if config[1] ~= nil then
			table.insert(self.listScore, config[1])
		end

		if config[2] ~= nil then
			table.insert(self.listAward, config[2])
		end
	end

	self:InitPanel()
end

function PageUnionRaid:InitPanel()
	self:InitCommRaid()
	self:InitBossRaid()
	self:InitContribution()
	self:UpdatePanel()
end

function PageUnionRaid:InitCommRaid()
	self.listCellRaid = {}

	for i = 1, UnionRaidMgr.commRaidCount do
		self["AnimatorRaid" .. i] = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Raid/Comm/" .. i, "Animator")
		self["GoBeingState" .. i] = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/Raid/Comm/" .. i .. "/Being")
		self["GoComplState" .. i] = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/Raid/Comm/" .. i .. "/Complete")

		local cell = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/Raid/Comm/" .. i .. "/" .. i)

		if cell ~= nil then
			self["TxtName" .. i] = GOUtil.FindChildComponent(cell, "Panel1/Info/TxtName", "Text")
			self["ImgRate" .. i] = GOUtil.FindChildComponent(cell, "Panel1/Rate/Bar", "Image")
			self["TxtRate" .. i] = GOUtil.FindChildComponent(cell, "Panel1/Rate/TxtValue", "Text")
			self["GoPanelAward" .. i] = GOUtil.FindChildGameObject(cell, "Panel2")
			self["HeadBG" .. i] = GOUtil.FindChildGameObject(cell, "Panel1/Info/HeadBg")
			self["HeadIcon" .. i] = GOUtil.FindChildComponent(cell, "Panel1/Info/HeadBg/HeadIcon", "Image")
			self["HeadFrame" .. i] = GOUtil.FindChildComponent(cell, "Panel1/Info/HeadBg/HeadIcon/ImageBox", "Image")
			self["GoLevelValue" .. i] = GOUtil.FindChildGameObject(cell, "Panel1/Prompt")
			self["TxtLevelValue" .. i] = GOUtil.FindChildComponent(cell, "Panel1/Prompt/TxtValue", "Text")

			self:AddClick(cell, self.OnClickedCommRaid)
			table.insert(self.listCellRaid, cell)
			UITweenUtil.AlphaTween(cell.transform, 0, 0, 0, 0)
			UITweenUtil.AlphaTween(cell.transform, 0, 1, 0.14, i * 0.14)
		end
	end
end

function PageUnionRaid:OnEndRootAnim()
	for i = 1, UnionRaidMgr.commRaidCount do
		if self["AnimatorRaid" .. i] then
			self["AnimatorRaid" .. i].enabled = true
		end
	end
end

function PageUnionRaid:InitBossRaid()
	UIUtil.SetSpineAnimationState(self.GoBossRaid, "none", false, false)
end

function PageUnionRaid:InitContribution()
	self.listCellItem = {}

	local width = GOUtil.GetRectTransformSizeDeltaWidth(self.GoRate)

	for k, v in ipairs(self.listScore) do
		local cell = CellScoreItem(self.PrefabCellScoreItem, self.GoRate, nil, self)

		cell:Create()
		GOUtil.SetTransformLocalScale(cell.UIRootObject, 0.85)
		GOUtil.SetRectTransformOffsetType(cell.UIRootObject, 3, v / self.listScore[#self.listScore] * width, -10)

		local packData = ItemManager.GetRewardPackData(self.listAward[k])
		local id = packData.PackItem[1][1] or 501
		local num = packData.PackItem[1][2] or 0
		local infoItem = ItemManager:GetValueItem(id, num)
		local data = {
			infoItem = infoItem,
			index = k,
			strValue = tostring(v)
		}

		cell:UpdateData(data)
		table.insert(self.listCellItem, cell)
	end
end

function PageUnionRaid:UpdatePanel(refreshType)
	self:UpdateCommRaid()
	self:UpdateBossRaid()
	self:UpdateAwardState()
	self:UpdatePlayNum()

	local dis = UnionRaidMgr.GetNextRefreshTime() - NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local d, h, m, s = GetTimeFormatBySec(dis)

	self.TxtCountdown.text = string.format(_("Desc_Next_Reset_Time"), string.format(_("Desc_Time_Format_1"), d, h, m))
end

function PageUnionRaid:UpdateCommRaid()
	self.listCellRaid = self.listCellRaid or {}
	self.listCommRaid = UnionRaidMgr.listCommRaid

	for i = 1, UnionRaidMgr.commRaidCount do
		self:UpdateSingleCommRaid(i)
		self:UpdateSingleCommRaidAward(i)
	end
end

function PageUnionRaid:UpdateSingleCommRaid(index)
	local cell = self.listCellRaid[index]
	local info = self.listCommRaid[index]

	if cell and info then
		self["TxtName" .. index].text = Lang(info.data.Name[1])
		info.progress = math.min(info.progress, info.data.FinishPoint)
		self["TxtRate" .. index].text = "<color=#52dcd6>" .. info.progress .. "</color>/" .. info.data.FinishPoint
		self["ImgRate" .. index].fillAmount = info.progress / info.data.FinishPoint

		if UnionRaidMgr.beingCommRaid and info.id == UnionRaidMgr.beingCommRaid.id then
			local infoItem = ItemManager:Get(PlayerInst.InfoPlayer.headId)

			UIUtil.SetImageSprite(self["HeadIcon" .. index], infoItem:GetIcon(), self)

			local infoItem = ItemManager:Get(PlayerInst.InfoPlayer.headFrame)

			UIUtil.SetImageSprite(self["HeadFrame" .. index], infoItem:GetIcon(), self)
			SetActiveFunc(self["HeadBG" .. index].gameObject, true)
		else
			SetActiveFunc(self["HeadBG" .. index].gameObject, false)
		end

		if info.battleSum ~= 0 and not info:IsFinished() and UnionRaidMgr:IsPlayNumEnough(eRaidType.Common) then
			SetActiveFunc(self["GoLevelValue" .. index].gameObject, true)

			self["TxtLevelValue" .. index].text = string.format(_("Desc_UnionRaidDiff"), info:GetBattleEventIdx())
		else
			SetActiveFunc(self["GoLevelValue" .. index].gameObject, false)
		end

		if info.battleSum >= info.data.BattleRound then
			self["TxtLevelValue" .. index].text = _("Desc_Raid_Pass_Today")
		end

		GOUtil.SetActive(self["GoBeingState" .. index], not info:IsFinished())
		GOUtil.SetActive(self["GoComplState" .. index], info:IsFinished())
	end
end

function PageUnionRaid:UpdateSingleCommRaidAward(index)
	local info = self.listCommRaid[index]

	if info and self["GoPanelAward" .. index] then
		GOUtil.SetActive(self["GoPanelAward" .. index], info:IsFinished() and not info:IsReceived())
	end
end

function PageUnionRaid:UpdateBossRaid()
	local isOpen = UnionRaidMgr:IsBossRaidOpen()

	if isOpen then
		UIUtil.SetSpineAnimationState(self.GoBossRaid, "brkUnlock", false, true)
	else
		UIUtil.SetSpineAnimationState(self.GoBossRaid, "lock", false, true)
	end

	self:UpdateBossRaidAward()
end

function PageUnionRaid:UpdateBossRaidAward()
	local list = UnionRaidMgr:GetBossRaidsOfNotReceiveAward()
	local num = #list

	GOUtil.SetActive(self.GoBossAward, num > 0)

	if num > 0 then
		if num == 1 then
			UIUtil.SetImageOverrideSprite(self.ImgBossAward, "UI/PanelUnionRaid/AtlasPanelUnionRaid/BG_maze_treasure_01", self)
		elseif num == 2 then
			UIUtil.SetImageOverrideSprite(self.ImgBossAward, "UI/PanelUnionRaid/AtlasPanelUnionRaid/BG_maze_treasure_02", self)
		elseif num >= 3 then
			UIUtil.SetImageOverrideSprite(self.ImgBossAward, "UI/PanelUnionRaid/AtlasPanelUnionRaid/BG_maze_treasure_03", self)
		end
	end

	local isFinish = UnionRaidMgr:IsBossRaidFinish()

	GOUtil.SetActive(self.GoComplete, isFinish)
end

function PageUnionRaid:UpdateAwardState()
	local curContributionValue = UnionRaidMgr.GetContributionValue()

	if self.listCellItem then
		for k, item in ipairs(self.listCellItem) do
			local isReced = UnionRaidMgr.IsRecedContributionIdx(k)
			local tarContributionValue = self.listScore[k]
			local canRece = tarContributionValue <= curContributionValue

			item:UpdateState(isReced, canRece)
		end
	end

	self.TxtRateNum.text = "<color=#00FFE7>" .. curContributionValue .. "</color>/" .. self.listScore[#self.listScore]
	self.ImgRateBar.fillAmount = curContributionValue / self.listScore[#self.listScore]
end

function PageUnionRaid:UpdatePlayNum()
	self.TxtPlayNum.text = string.format(_("Desc_Raid_Cheer_Num_Today"), "<color=#00FFE7>" .. UnionRaidMgr.maxCommPlayNum - UnionRaidMgr.GetPlayNum(eRaidType.Common) .. "</color>/" .. UnionRaidMgr.maxCommPlayNum)
end

function PageUnionRaid:OnClickedCommRaid(data)
	if not UnionMgr.HasUnion(true) then
		return
	end

	local index = tonumber(data.pointerPress.name)

	local function panelCb()
		local infoRaid = self.listCommRaid[index]

		if not infoRaid then
			return
		end

		if infoRaid:IsFinished() then
			if not infoRaid:IsReceived() then
				local function cb()
					self:UpdateSingleCommRaidAward(index)
				end

				self:RequestRaidAward(infoRaid, cb)
			else
				UIMgr.ShowMsg(_("Desc_Current_Raid_End"))
			end
		else
			UIMgr.AddPanel(DlgRaidDetail(), infoRaid)
		end
	end

	if UnionRaidMgr.LastRequestTime == 0 or UnionRaidMgr.LastRequestTime ~= 0 and NetData:GetCurServerTime() - UnionRaidMgr.LastRequestTime >= DateUtil.MillsPerMinute then
		local function cb()
			self:UpdateCommRaid()
			self:UpdateBossRaid()
			panelCb()
		end

		PageUnionRaid.RequestData(cb)
	else
		panelCb()
	end
end

function PageUnionRaid:OnClickedBossRaid()
	if not UnionMgr.HasUnion(true) then
		return
	end

	local isFinish = UnionRaidMgr:IsBossRaidFinish()

	if isFinish then
		UIMgr.ShowMsg(_("Msg_Weekly_Boss_Raid_Over"))
	else
		local stageId = UnionRaidMgr:GetBeingBossRaid().data.BossStage

		require("UI/Page/PageCombatReadiness/PageCombatReadiness")

		ChapterMgr.PageCombatReadinessType = 2

		UIMgr.AddPanel(PageCombatReadiness(), {
			stageId = stageId
		})
	end

	self:PlayVoice(1)
end

function PageUnionRaid:OnClickedBossAward()
	if not UnionMgr.HasUnion(true) then
		return
	end

	local list = UnionRaidMgr:GetBossRaidsOfNotReceiveAward()

	if #list > 0 then
		local function cb()
			self:UpdateBossRaidAward()
			self:UpdateAwardState()
		end

		self:RequestRaidAward(list[1], cb)
	end
end

function PageUnionRaid:RequestRaidAward(infoRaid, cb)
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			local setter = SetterData.GetSetterData(vMsg.setter)

			setter:Parse()

			local list = {}

			for _, v in ipairs(setter.list) do
				table.insert(list, v)
			end

			local s = {}

			s.id = 401
			s.num = infoRaid.data.ContributionOfKill

			table.insert(list, s)
			UIMgr.AddPanel(DlgGetAward.GetInstance(), {
				list = list
			})
			UnionRaidMgr.ChangeContributionValue(infoRaid.data.ContributionOfKill)
			infoRaid:ChangeReceState(true)

			if cb then
				cb()
			end

			self:PlayVoice(2)
		elseif vMsg.result.code == 2 then
			PageUnion.GoBackMainPage(vMsg)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestUnionRaidBreakAward(infoRaid.id, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageUnionRaid:RequestScoreAward(data)
	local index = 0

	if data and data.index then
		index = data.index
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			if data and data.callback then
				data.callback()
			end
		elseif vMsg.result.code == 2 then
			PageUnion.GoBackMainPage(vMsg)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Show)
	NetManager:RequestUnionRaidcontributionAward(index, wrap_cb)
end

function PageUnionRaid:PlayVoice(type)
	if type == 1 then
		local listUpCardId = InfoTeamBossRaid:GetUpRoleCardList()
		local role

		if listUpCardId[3] ~= 0 then
			role = RoleCardMgr:GetRole(listUpCardId[3])
		else
			role = RoleMgr:GetMaxFavorRole()
		end

		InfoSoundEventMgr:LoadBank(role.data.VocalBank)
		InfoSoundEventMgr:Play("VocalCommon11", role.data.VocalCommon11)
	else
		local infoRole = UnionTypeMgr:GetUnionTypeRole(UnionMgr.releUnion.pb.type)

		InfoSoundEventMgr:LoadBank(infoRole.data.VocalBank)
		InfoSoundEventMgr:Play("VocalCommon10", infoRole.data.VocalCommon10)
	end
end

function PageUnionRaid:OnClickedBtnCardView()
	require("UI/Page/PageUnionRaid/DlgRaidCardView")
	UIMgr.AddPanel(DlgRaidCardView())
end

function PageUnionRaid:OnClickedBtnHpReply()
	require("UI/Page/PageUnionRaid/DlgCardHpReply")
	UIMgr.AddPanel(DlgCardHpReply())
end

function PageUnionRaid:OnClickedBtnBuffView()
	require("UI/Page/PageUnionRaid/DlgRaidBuff")
	UIMgr.AddPanel(DlgRaidBuff())
end

function PageUnionRaid:OnClickedBtnGuide()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.UnionRaid)
end
