-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionFunction/PageUnionTask.lua

require("UI/Item/CellScoreItem")
require("UI/Page/PageUnionFunction/CellUnionTask")

PageUnionTask = class("PageUnionTask", UIPanel)

function PageUnionTask:ctor()
	self.UIPrefabPath = "UI/PanelUnionFunction/PanelUnionTask"

	self:AddChildPanel(DlgExit(), {
		title = _("Item_From_19_1"),
		callback = self.OnBack,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PageUnionTask:PreLoad()
	self:LoadResAsync("UI/PanelTask/CellTask", "PrefabCellTask", GameObject)
	self:LoadResAsync("UI/Item/CellScoreItem", "PrefabCellScoreItem", GameObject)

	if UnionMgr.releUnion then
		self.characterId = UnionTypeMgr:GetUnionTypeCharacter(UnionMgr.releUnion.pb.type)
		self.defaultCard = RoleMgr:GetRoleDefaultCard(self.characterId)

		if self.defaultCard then
			self:LoadAssetsAsync(self.defaultCard.data.FullIcon, Texture)
		end
	end
end

function PageUnionTask:OnBack()
	local prePanel = UIMgr.GetPrePanel()

	if prePanel.className == "PageUnion" then
		UIMgr.PopPanel({
			isShowBank = true,
			needRequestUnion = true
		})
	else
		UIMgr.PopPanel()
	end
end

function PageUnionTask:Purge()
	self.base.Purge(self)
	UITweenUtil.RemoveTween(self.content)
	UITweenUtil.RemoveTween(self.cellGroup.transform)
	self:OnLeave()
end

function PageUnionTask:OnLeave()
	ResourceMgr.Unload(self.PrefabCellTask)
	ResourceMgr.Unload(self.PrefabCellScoreItem)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.listCellItem then
		for _, v in pairs(self.listCellItem) do
			if v.OnLeave ~= nil then
				v:OnLeave()
			end
		end

		self.listCellItem = nil
	end

	InfoSoundEventMgr:OnBack()
end

function PageUnionTask:OnRegisterEvent()
	Event.Instance:Add("TaskCompleteUpdate", self.UpdatePanel, self)
	Event.Instance:Add("TaskResetUpdate", self.UpdatePanel, self)
	Event.Instance:Add("RequestScoreAward", self.RequestScoreAward, self)
	Event.Instance:Add("UpdateNetData", self.UpdatePanel, self)
	self:AddClick(self.BtnOneKey, self.OnClickedBtnOneKey)
end

function PageUnionTask:OnUnRegisterEvent()
	Event.Instance:Remove("TaskCompleteUpdate", self.UpdatePanel, self)
	Event.Instance:Remove("TaskResetUpdate", self.UpdatePanel, self)
	Event.Instance:Remove("RequestScoreAward", self.RequestScoreAward, self)
	Event.Instance:Remove("UpdateNetData", self.UpdatePanel, self)
	self:RemoveClick(self.BtnOneKey, self.OnClickedBtnOneKey)
end

function PageUnionTask.RequestData(cb, notNeedLeave)
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			if cb then
				cb()
			end
		elseif vMsg.result.code == 6 then
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
	NetManager:RequestReleUnionData(wrap_cb, true)
end

function PageUnionTask:OnEnter()
	self:DealWithLocalization()

	self.GoCard = self:GetChildGameObject("CardBg/Card")
	self.CardIcon = self:GetChildComponent("CardBg/Card/Icon", "RawImage")
	self.ImgName = self:GetChildComponent("Panel/BgName/Name", "Image")
	self.TxtScore = self:GetChildComponent("Panel/Integral/BgValue/TxtValue", "Text")
	self.ImgScoreBar = self:GetChildComponent("Panel/Integral/Rate/Bar", "Image")
	self.ImgOneKey = self:GetChildComponent("Panel/Integral/BtnOneKey", "Image")
	self.BtnOneKey = self:GetChildGameObject("Panel/Integral/BtnOneKey")
	self.Fx_UI_009_2 = self:GetChildGameObject("Panel/Integral/BtnOneKey/Fx_UI_009_2")

	local cardGra = self:GetChildComponent("CardBg/Image", "GradientImage")
	local color1 = getColorFromString("51B1BC")
	local color2 = getColorFromString("C7E0E7")

	DealWithListRef(self, UIUtil.SetGradientImageMaterial(cardGra, "UI/PanelBondage/CharacterGradient", color1, color2, 1))
	self:InitUnionData()
	self:UpdatePanel()
end

function PageUnionTask:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/Integral/BgValue/Text", "Text")
	txt.text = _("UnionTask_MedalNum")
end

function PageUnionTask:InitUnionData()
	if self.defaultCard then
		UIUtil.SetRawImageTexture(self.CardIcon, self.assetsTable[self.defaultCard.data.FullIcon])

		local infoRole = RoleCardMgr:GetRole(self.defaultCard.id)

		UIUtil.SetImageSprite(self.ImgName, "UIDyAtlas/SignName/IC_SIGN_" .. infoRole.data.Enname .. "_01", self, true)

		if infoRole.data.ClubTaskSet and infoRole.data.ClubTaskSet[1] and infoRole.data.ClubTaskSet[2] then
			GOUtil.SetRectTransformAnchoredPosition(self.GoCard, infoRole.data.ClubTaskSet[1], infoRole.data.ClubTaskSet[2])
		end
	end
end

function PageUnionTask:InitIntegralPanel()
	self.maxIntegral = self.taskListData.ScoreSection[#self.taskListData.ScoreSection][2]
	self.cellGroup = self:GetChildGameObject("Panel/Integral/Rate")

	local width = GOUtil.GetRectTransformSizeDeltaWidth(self.cellGroup)

	self.listCellItem = {}

	local count = #self.taskListData.ScoreSection

	for i = 1, count do
		local cell = CellScoreItem(self.PrefabCellScoreItem, self.cellGroup, self)

		cell:Create()
		GOUtil.SetRectTransformOffsetType(cell.UIRootObject, 3, self.taskListData.ScoreSection[i][2] / self.maxIntegral * width, -10)

		local id = self.taskListData.ScoreSectionReward[i][1][1]
		local num = self.taskListData.ScoreSectionReward[i][1][2]
		local infoItem = ItemManager:GetValueItem(id, num)
		local data = {
			infoItem = infoItem,
			index = i,
			strValue = string.format(_("X_Score"), self.taskListData.ScoreSection[i][2])
		}

		cell:UpdateData(data)
		table.insert(self.listCellItem, cell)
	end

	UITweenUtil.OrderAlphaAnim(self.cellGroup.transform, 0.2)
end

function PageUnionTask:UpdatePanel()
	self:UpdateIntegral()
	self:UpdateTaskPanel()
	self:UpdateUIShowOrHide()
end

function PageUnionTask:UpdateIntegral()
	self.taskListData = UnionTaskMgr:GetUnionTaskListData()

	if not self.initIntegral then
		self:InitIntegralPanel()

		self.initIntegral = true
	end

	local curIntegral = TaskManager:GetTaskListScore(self.taskListData.ID)

	self.TxtScore.text = curIntegral
	self.ImgScoreBar.fillAmount = curIntegral / self.maxIntegral

	for k, cell in ipairs(self.listCellItem) do
		local isReced = TaskManager:IsRecvedScoreAward(self.taskListData.ID, k - 1)
		local targetScore = self.taskListData.ScoreSection[k] and self.taskListData.ScoreSection[k][2] or 0
		local curScore = TaskManager:GetTaskListScore(self.taskListData.ID)

		cell:UpdateState(isReced, targetScore <= curScore)
	end
end

function PageUnionTask:UpdateTaskPanel()
	self.listTask = TaskManager:SortTaskList(TaskManager:GetList(eTaskListType.union))

	if not self.UIScrollTool then
		self:InitScrollView()
	else
		self.UIScrollTool:UpdateListData(self.listTask)
	end
end

function PageUnionTask:InitScrollView()
	local scrollArea = self:GetChildGameObject("Panel/BgScroll/ScrollArea")

	self.content = self:GetChildComponent("Panel/BgScroll/ScrollArea/Content", "RectTransform")

	local count = #self.listTask

	local function cellCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCellTask)
	end

	local function updateCallback(item, index)
		item:UpdateData(self.listTask[index])
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, self.content, count, self.PrefabCellTask, CellUnionTask, self, false, cellCallback, updateCallback)
	UITweenUtil.DoListAnimationUp(self.content, 300, 0.3, nil, nil)
end

function PageUnionTask:RequestScoreAward(data)
	local index = data.index
	local cb = data.callback
	local rewardIndex = index - 1
	local cb = function(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			if cb then
				cb()
			end

			self:UpdateUIShowOrHide()

			local role = RoleMgr:GetRole(self.characterId)

			if role then
				InfoSoundEventMgr:LoadBank(role.data.VocalBank)

				if math.random(2) == 1 then
					InfoSoundEventMgr:Play("VocalCommon10", role.data.VocalCommon10)
				else
					InfoSoundEventMgr:Play("VocalCommon6", role.data.VocalCommon6)
				end
			end
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestTaskLineScoreReward(self.taskListData.ID, rewardIndex, cb)
end

function PageUnionTask:OnClickedBtnOneKey()
	local list = self.listTask
	local listCanRecv = {}

	for _, v in pairs(list) do
		if v:IsComplete() and not v:IsGetAward() then
			table.insert(listCanRecv, v.id)

			local reward = v.data.Reward

			for _, n in ipairs(reward) do
				if n[1] == 514 or n[1] == 515 or n[1] == 519 or n[1] == 562 then
					table.insert(TaskManager.integralList, n)
				end
			end
		end
	end

	local function CheckScore()
		local taskListData = self.taskListData

		if not TaskManager.listTaskLineScore[taskListData.ID] then
			return false
		end

		local sumScore = TaskManager.listTaskLineScore[taskListData.ID].score
		local isHave = false

		for i = 1, #taskListData.ScoreSection do
			if not TaskManager:IsRecvedScoreAward(taskListData.ID, i - 1) and sumScore >= taskListData.ScoreSection[i][2] then
				isHave = true

				break
			end
		end

		return isHave
	end

	if #listCanRecv == 0 and not CheckScore() then
		UIMgr.ShowMsg(_("Msg_Award_Can_Receive_None"))

		return
	end

	local function wrap_cb(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Sucess then
			self:UpdatePanel()

			local infoUnion = UnionMgr.releUnion
			local characterId = UnionTypeMgr:GetUnionTypeCharacter(infoUnion.pb.type)

			InfoSoundEventMgr:LoadBank(RoleMgr:GetRole(characterId).data.VocalBank)

			local num = math.random(1, 3)

			if num == 1 then
				InfoSoundEventMgr:Play("VocalCommon10", RoleMgr:GetRole(characterId).data.VocalCommon10)
			elseif num == 2 then
				InfoSoundEventMgr:Play("VocalCommon6", RoleMgr:GetRole(characterId).data.VocalCommon6)
			elseif num == 3 then
				InfoSoundEventMgr:Play("VocalCustomsclearance3", RoleMgr:GetRole(characterId).data.VocalCustomsclearance3)
			end
		elseif pb.result.code == NetManager.Result_Timeout then
			self.DealTimeOut()
		else
			TaskManager.integralList = {}

			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestReceiveCompleteTasksOneKey(self.taskListData.ID, listCanRecv, wrap_cb)
end

function PageUnionTask:UpdateUIShowOrHide()
	local tasks = self.listTask
	local hasTask = next(tasks) ~= nil

	if not hasTask then
		UIUtil.SetImageSprite(self.ImgOneKey, "UI/PanelTask/AtlasTask/BTN_square_pink_02", self)
		self.Fx_UI_009_2:SetActive(false)

		return
	end

	local listCanRecv = {}

	for _, task in ipairs(tasks) do
		if task:IsComplete() and not task:IsGetAward() then
			table.insert(listCanRecv, task)
		end
	end

	local hasCanRecvScore = false

	if TaskManager:IsHaveTaskListScore(eTaskListType.union) then
		local taskListData = self.taskListData
		local sumScore = TaskManager.listTaskLineScore[taskListData.ID].score

		for i = 1, #taskListData.ScoreSection do
			if not TaskManager:IsRecvedScoreAward(taskListData.ID, i - 1) and sumScore >= taskListData.ScoreSection[i][2] then
				hasCanRecvScore = true

				break
			end
		end
	end

	if next(listCanRecv) ~= nil or hasCanRecvScore then
		UIUtil.SetImageSprite(self.ImgOneKey, "UI/PanelTask/AtlasTask/BTN_square_pink_01", self)
		self.Fx_UI_009_2:SetActive(true)
	else
		UIUtil.SetImageSprite(self.ImgOneKey, "UI/PanelTask/AtlasTask/BTN_square_pink_02", self)
		self.Fx_UI_009_2:SetActive(false)
	end
end

function PageUnionTask.DealTimeOut()
	local strContent = _("Desc_NoNetwork")

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), strContent, function()
		Restart()
	end, _("UI_OK"), nil, false)
end
