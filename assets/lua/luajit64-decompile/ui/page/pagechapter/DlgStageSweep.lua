-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageChapter/DlgStageSweep.lua

require("UI/Page/PageChapter/CellSweep")
require("UI/Page/PageChapter/DlgGetSweepAward")
require("UI/Dlg/Public/DlgProducerLevelUp")

local InfoTeam = require("Info/InfoTeam")
local DropGroup = require("luaData/DropGroup")
local battleStageData = require("luaData/BattleStage")
local SceneData = require("luaData/SceneData")

DlgStageSweep = class("DlgStageSweep", UIPanel)

function DlgStageSweep:ctor()
	self.UIPrefabPath = "UI/PageChapter/DlgStageSweep"
end

function DlgStageSweep:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
	self:LoadResAsync("UI/PageChapter/CellSweep", "PrefabCellSweep")
	self:LoadResAsync("UI/Common/CellCard/CellCardUp", "PrefabCellCardUp")
	self:LoadResAsync("UI/Paper/PaperCutIn", "PrefabPaperCutIn")
	self:LoadResAsync("UI/Paper/actor_loop", "PrefabActorLoop")

	self.normalTxtColor = Color.New(0.3215686274509804, 0.3176470588235294, 0.3215686274509804)
	self.redTxtColor = Color.New(1, 0, 0)
end

function DlgStageSweep:OnRegisterEvent()
	self:AddClick(self.ButtonSweep, self.OnClickedButtonSweep)
	self:AddClick(self.ButtonQuit, self.OnClickedButtonQuit, PATH_SFX_UI_CANCEL)
	self:AddClick(self.buttonSub, self.OnClickedButtonSub)
	self:AddClick(self.buttonAdd, self.OnClickedButtonAdd)
	self:AddClick(self.buttonMax, self.OnClickedButtonMax)
	self:AddClick(self.Btn_jump, self.OnClickedButJump)
	Event.Instance:Add(EventEnum.UpdateStage, self.UpdateCost, self)
end

function DlgStageSweep:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonSweep, self.OnClickedButtonSweep)
	self:RemoveClick(self.ButtonQuit, self.OnClickedButtonQuit)
	self:RemoveClick(self.buttonSub, self.OnClickedButtonSub)
	self:RemoveClick(self.buttonAdd, self.OnClickedButtonAdd)
	self:RemoveClick(self.buttonMax, self.OnClickedButtonMax)
	self:RemoveClick(self.Btn_jump, self.OnClickedButJump)
	Event.Instance:Remove(EventEnum.UpdateStage, self.UpdateCost, self)
end

function DlgStageSweep:Purge()
	Event.Instance:Fire("UpdateItemNumBySweep")
	DlgStageSweep.base.Purge(self)
	self:OnLeave()
	ResourceMgr.Unload(self.PrefabCellItem)
	ResourceMgr.Unload(self.PrefabCellSweep)
	ResourceMgr.Unload(self.PrefabCellCardUp)
	ResourceMgr.Unload(self.PrefabPaperCutIn)
	ResourceMgr.Unload(self.PrefabActorLoop)

	if self.skeletonDataAssetRef then
		ResourceMgr.Unload(self.skeletonDataAssetRef)

		self.skeletonDataAssetRef = nil
	end

	if self.skeletonMaterialRef then
		ResourceMgr.Unload(self.skeletonMaterialRef)

		self.skeletonMaterialRef = nil
	end

	if self.itemGoList then
		for i = 1, #self.itemGoList do
			if self.itemGoList[i] then
				self.itemGoList[i]:OnLeave()
			end
		end

		self.itemGoList = nil
	end
end

function DlgStageSweep:OnLeave()
	if self.listCell then
		for i = 1, #self.listCell do
			self.listCell[i]:OnLeave()
		end

		self.listCell = nil
	end

	if self.Timer then
		TimerMgr.RemoveTimer(self.Timer)

		self.Timer = nil
	end

	if self.Timer2 then
		TimerMgr.RemoveTimer(self.Timer2)

		self.Timer2 = nil
	end

	if self.timer then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end

	InfoSoundEventMgr:OnBack()
end

function DlgStageSweep:OnEnter(vParam)
	self.AniPanelCut = GOUtil.InstantiatePrefab(self.PrefabPaperCutIn, nil)

	SetActiveFunc(self.AniPanelCut, false)

	self.AniActorLoop = GOUtil.InstantiatePrefab(self.PrefabActorLoop, nil)

	SetActiveFunc(self.AniActorLoop, false)
	self:DealWithLocalization()

	self.infoStage = vParam.infoStage
	self.needItem = vParam.needItem

	if vParam and vParam.callback then
		vParam.callback()
	end

	self.isOpen = true
	self.canLeave = true
	self.listCardId = InfoTeam:GetUpRoleCardList()
	self.ButtonQuit = self:GetChildGameObject("Panel/ButtonQuit")
	self.ButtonSweep = self:GetChildGameObject("Panel/SweepGroup/ButtonSweep")
	self.ImgBtnSweep = GOUtil.GetComponent(self.ButtonSweep, "Image")
	self.ImgMax = self:GetChildComponent("Panel/SweepGroup/ButtonMax", "Image")
	self.ImgAdd = self:GetChildComponent("Panel/SweepGroup/ButtonAdd", "Image")
	self.ImgSub = self:GetChildComponent("Panel/SweepGroup/ButtonSub", "Image")
	self.perLevel = PlayerInst:GetCurLv()
	self.itemGoList = {}

	local listItem = self.infoStage.data.ItemList
	local gPanelItem = self:GetChildGameObject("Panel/StageAward/Group")

	for i = 1, #listItem do
		if i > #listItem or listItem[i][1] == nil then
			-- block empty
		else
			local id = listItem[i][1]
			local num = listItem[i][2]
			local award = ItemManager:GetValueItem(id, num, listItem[i][3])
			local item = CellItem(self.PrefabCellItem, gPanelItem, self)

			item:Create()

			if award.randomNum then
				item:UpdateWithNumType(award, nil, award.randomNum)
			else
				item:UpdateWithNumType(award)
			end

			table.insert(self.itemGoList, item)
		end
	end

	local listExtraItem = self.infoStage.data.RushExtraDropgroupList
	local gPanelExtraItem = self:GetChildGameObject("Panel/StageExtraAward/Group")

	if listExtraItem then
		for i = 1, #listExtraItem do
			if i > #listExtraItem or listExtraItem[i] == nil then
				-- block empty
			else
				local id = listExtraItem[i]

				for _, v in ipairs(DropGroup) do
					if v.GroupID == id then
						local infoItem = ItemManager:Get(v.ItemID)
						local item = CellItem(self.PrefabCellItem, gPanelExtraItem, self)

						item:Create()
						item:UpdateNoNumType(infoItem)
						item:SetExtra(true)
						table.insert(self.itemGoList, item)
					end
				end
			end
		end
	end

	local mainSceneId = battleStageData[self.infoStage.data.BattleStageID].MainSceneId
	local skeletonDataAssetPath = "UISpine/Ui_Sweep/" .. SceneData[mainSceneId].SweepPic .. "/" .. SceneData[mainSceneId].SweepPic .. "_SkeletonData"
	local materialPath = "UISpine/Ui_Sweep/" .. SceneData[mainSceneId].SweepPic .. "/" .. SceneData[mainSceneId].SweepPic .. "_Material"

	self.GoStageSweepBG = self:GetChildGameObject("Panel/StageIconBG/StageIconBG")
	self.skeletonDataAssetRef, self.skeletonMaterialRef = UIUtil.SetSpineSkeletonDataAsset(self.GoStageSweepBG, skeletonDataAssetPath, materialPath, skeletonDataAssetRef, materialRef)

	UIUtil.SetSpineAnimationState(self.GoStageSweepBG, "none", false, false)
	GOUtil.AttachGameObject(self.AniPanelCut, self.GoStageSweepBG)
	GOUtil.AttachGameObject(self.AniActorLoop, self.GoStageSweepBG)

	self.ActorGroup = GOUtil.FindChildGameObject(self.AniPanelCut, "actor")
	self.EnemyGroup = GOUtil.FindChildGameObject(self.AniPanelCut, "boss")

	local listInfoRole = {}
	local listRoleId = InfoTeam:GetUpRoleList()

	for i = 1, #listRoleId do
		if listRoleId[i] > 0 then
			table.insert(listInfoRole, RoleMgr:GetRole(listRoleId[i]))
		end
	end

	self.listRoleId = listRoleId

	for i = 1, 5 do
		local img1 = GOUtil.FindChildComponent(self.AniPanelCut, "actor/" .. i, "Image")
		local img2 = GOUtil.FindChildComponent(self.AniPanelCut, "boss/" .. i, "Image")
		local img3 = GOUtil.FindChildComponent(self.AniActorLoop, i, "Image")

		SetActiveFunc(img1.gameObject, false)
		SetActiveFunc(img2.gameObject, false)
		SetActiveFunc(img3.gameObject, false)
	end

	for i = 1, #listInfoRole do
		local img1 = GOUtil.FindChildComponent(self.AniPanelCut, "actor/" .. i, "Image")
		local img3 = GOUtil.FindChildComponent(self.AniActorLoop, i, "Image")
		local infoRole = listInfoRole[i]
		local strPath = infoRole.actorData.PaperIcon

		UIUtil.SetImageOverrideSprite(img1, strPath, self)
		UIUtil.SetImageOverrideSprite(img3, strPath, self)
		SetActiveFunc(img1.gameObject, true)
		SetActiveFunc(img3.gameObject, true)
	end

	local listMonster = self.infoStage.listMonster

	for i = 1, #listMonster do
		local infoEnemy = EnemyManager:Get(listMonster[i])
		local strPath = infoEnemy.actorData.PaperIcon
		local img2 = GOUtil.FindChildComponent(self.AniPanelCut, "boss/" .. i, "Image")

		if not IsNil(img2) then
			SetActiveFunc(img2.gameObject, true)
			UIUtil.SetImageSprite(img2, strPath, self)
		end
	end

	self.panelStageAward = self:GetChildGameObject("Panel/StageAward")
	self.panelStageExtraAward = self:GetChildGameObject("Panel/StageExtraAward")
	self.PanelAward = self:GetChildGameObject("Panel/PanelAward")

	local ScrollArea = self:GetChildGameObject("Panel/PanelAward/ScrollArea")
	local ScrollView = GOUtil.AddMissingComponent(ScrollArea, "UIScrollView")

	ScrollView.vertical = true
	ScrollView.content = self:GetChildComponent("Panel/PanelAward/ScrollArea/Content", "Transform")
	ScrollView.verticalScrollbar = self:GetChildComponent("Panel/PanelAward/Scrollbar", "Scrollbar")
	self.ScrollView = ScrollView
	self.GoRoleCards = self:GetChildGameObject("Panel/RoleUp")

	SetActiveFunc(self.GoRoleCards, false)

	self.processIndex = 0

	SetActiveFunc(self.panelStageAward, true)
	SetActiveFunc(self.panelStageExtraAward, true)
	SetActiveFunc(self.PanelAward, false)

	self.sweepGroup = self:GetChildGameObject("Panel/SweepGroup")
	self.buttonSub = self:GetChildGameObject("Panel/SweepGroup/ButtonSub")
	self.buttonAdd = self:GetChildGameObject("Panel/SweepGroup/ButtonAdd")
	self.buttonMax = self:GetChildGameObject("Panel/SweepGroup/ButtonMax")
	self.ImgTicketIcon = self:GetChildComponent("Panel/SweepGroup/CostTicket/Icon", "Image")
	self.ImgPowerIcon = self:GetChildComponent("Panel/SweepGroup/CostStamina/Icon", "Image")
	self.txtCostTicket = self:GetChildComponent("Panel/SweepGroup/CostTicket/TxtNum", "Text")
	self.txtCostStamina = self:GetChildComponent("Panel/SweepGroup/CostStamina/TxtNum", "Text")
	self.txtSweepNum = self:GetChildComponent("Panel/SweepGroup/ButtonSweep/Text/TxtNum", "Text")
	self.requireNum = 0
	self.requireGroup = self:GetChildGameObject("Panel/RequireGroup")
	self.cellItemParent = self:GetChildGameObject("Panel/RequireGroup/CellItemParent")
	self.txtRequireName = self:GetChildComponent("Panel/RequireGroup/TxtItem", "Text")
	self.txtRequireNum = self:GetChildComponent("Panel/RequireGroup/TxtNeedNum", "Text")
	self.Btn_jump = self:GetChildGameObject("Panel/Btn_jump")
	self.IsBtnJump = false
	self.imgChallengeNum = self:GetChildGameObject("Panel/img_leftnum")

	self:InitSweepCost()
end

function DlgStageSweep:DealWithLocalization()
	local Text

	Text = self:GetChildComponent("Panel/BgTitle/TxtPrompt", "Text")
	Text.text = _("Stage_Sweep")
	Text = self:GetChildComponent("Panel/SweepGroup/ButtonSweep/Text/Text", "Text")
	Text.text = _("Btn_Sweep")
	Text = self:GetChildComponent("Panel/SweepGroup/TxtCost", "Text")
	Text.text = Lang(5000010)
	Text = self:GetChildComponent("Panel/StageAward/Text", "Text")
	Text.text = Lang(12417)
	Text = self:GetChildComponent("Panel/StageExtraAward/Text", "Text")
	Text.text = _("Drop_Award_Extra")
	Text = self:GetChildComponent("Panel/RequireGroup/Txt1", "Text")
	Text.text = _("Material_Taget")
end

function DlgStageSweep:InitSweepCost()
	local info1 = ItemManager:Get(self.infoStage.data.SweepCost[1][1])

	UIUtil.SetImageSprite(self.ImgTicketIcon, info1:GetIcon(), self)

	if self.infoStage.data.Stamina == 0 and #self.infoStage.data.SweepCost == 2 then
		local info2 = ItemManager:Get(self.infoStage.data.SweepCost[2][1])

		UIUtil.SetImageSprite(self.ImgPowerIcon, info2:GetIcon(), self)
	else
		local info2 = ItemManager:Get(503)

		UIUtil.SetImageSprite(self.ImgPowerIcon, info2:GetIcon(), self)
	end

	self.sweepCount = 1

	self:UpdateCost()
	self:UpdateRequire()
end

function DlgStageSweep:UpdateCost()
	local infoStage = self.infoStage
	local holdPower = PlayerInst:GetPower()
	local costPower = infoStage.data.Stamina

	self.costItem = 503

	if costPower == 0 and next(infoStage.data.CostItem) then
		holdPower = ItemManager:GetItemCount(infoStage.data.CostItem[1])
		costPower = infoStage.data.CostItem[2]
		self.costItem = infoStage.data.CostItem[1]
	end

	local holdTicket = ItemManager:GetItemCount(infoStage.data.SweepCost[1][1])
	local costTicket = infoStage.data.SweepCost[1][2]
	local curMaxCount = GetConfigArgInt("SweepMaxNum")

	if costPower ~= 0 then
		curMaxCount = math.min(curMaxCount, math.floor(holdPower / costPower))
	end

	if costTicket ~= 0 then
		curMaxCount = math.min(curMaxCount, math.floor(holdTicket / costTicket))
	end

	self.sweepCount = math.max(1, math.min(self.sweepCount, curMaxCount))

	local leftNum = ChapterMgr:GetStageLeftPlayNumWithLimit(infoStage.id)

	if leftNum ~= -1 and leftNum >= 0 then
		self.sweepCount = math.min(self.sweepCount, leftNum) == 0 and 1 or math.min(self.sweepCount, leftNum)
	end

	if self.sweepCount > GetConfigArgInt("SingleSweepMaxNum") then
		self.sweepCount = GetConfigArgInt("SingleSweepMaxNum")

		UIMgr.ShowMsg(_("Msg_SingleSweepMax"))
	end

	local txtChallengeNum = self:GetChildComponent("Panel/img_leftnum/Text", "Text")

	if leftNum == -1 then
		txtChallengeNum.text = _("Desc_Last_Num") .. "∞/∞"
	else
		local limitNum = 0

		if self.infoStage.data.ChapterType == ChapterFromType.activity and self.infoStage.data.Type == 1 then
			local listActive = PassMgr:GetBranchActiveList(3, ActiveMgr.branchId)
			local activeId = listActive[ActiveMgr.TabIndex].ID
			local infoActive = ActiveMgr:GetActive(activeId)

			limitNum = infoActive:GetMaxArgJson(nil, self.infoStage.data.ActType)
			curMaxCount = math.min(curMaxCount, leftNum)
		elseif self.infoStage.data.ChapterType == ChapterFromType.card then
			limitNum = ChapterMgr.GetStageMaxPlayNum(self.infoStage.id)
		else
			limitNum = self.infoStage:GetMaxLeftPlayNum()
		end

		if leftNum > 0 then
			txtChallengeNum.text = _("Desc_Last_Num") .. "<color=#29c4c4>" .. leftNum .. "</color>/" .. limitNum
		else
			txtChallengeNum.text = _("Desc_Last_Num") .. "<color=#e22929>" .. leftNum .. "</color>/" .. limitNum

			DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnSweep, 1))
		end
	end

	self.powerNotEnough = holdPower < costPower

	if self.powerNotEnough then
		self.txtCostStamina.color = self.redTxtColor
	else
		self.txtCostStamina.color = self.normalTxtColor
	end

	self.ticketNotEnough = holdTicket < costTicket

	if self.ticketNotEnough then
		self.txtCostTicket.color = self.redTxtColor
	else
		self.txtCostTicket.color = self.normalTxtColor
	end

	self.txtCostTicket.text = self.sweepCount * costTicket .. "/" .. holdTicket
	self.txtCostStamina.text = self.sweepCount * costPower .. "/" .. holdPower
	self.txtSweepNum.text = "x" .. self.sweepCount

	local gray = TenaryOp(leftNum <= self.sweepCount, 1, 0)
	local isFirstAddMax = false

	if self.addGary ~= gray then
		isFirstAddMax = true
		self.addGary = gray
	end

	if leftNum == -1 then
		gray = 0
	end

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgAdd, gray))
	DealWithListRef(self, UIUtil.SetImageGray(self.ImgMax, gray))

	gray = TenaryOp(self.sweepCount == 1, 1, 0)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgSub, gray))
end

function DlgStageSweep:UpdateRequire()
	if self.needItem then
		SetActiveFunc(self.requireGroup, true)

		local item = CellItem(self.PrefabCellItem, self.cellItemParent, self)

		item:Create()

		local infoItem = ItemManager:GetValueItem(self.needItem.id, self.needItem.needNum)

		item:UpdateNoNumType(infoItem)
		table.insert(self.itemGoList, item)

		self.txtRequireName.text = Lang(infoItem.data.Name)

		local holdNum = ItemManager:GetItemCount(self.needItem.id)

		self.preHoldNum = holdNum
		self.txtRequireNum.text = GetItemShowStrNum2(self.needItem.needNum, holdNum)
	else
		SetActiveFunc(self.requireGroup, false)
	end
end

function DlgStageSweep:OnClickedButtonAdd()
	if self.sweepCount + 1 > GetConfigArgInt("SweepMaxNum") then
		UIMgr.ShowMsg(_("Msg_SweepMax"))

		return
	end

	local holdTicket = ItemManager:GetItemCount(self.infoStage.data.SweepCost[1][1])
	local costTicket = self.infoStage.data.SweepCost[1][2]

	if holdTicket < (self.sweepCount + 1) * costTicket then
		UIMgr.ShowMsg(_("Msg_NoSweepTicket"))

		return
	end

	if self.costItem == 503 then
		local holdPower = PlayerInst:GetPower()
		local costPower = self.infoStage.data.Stamina

		if holdPower < (self.sweepCount + 1) * costPower then
			require("UI/Dlg/Common/DlgPowerBuy")

			local function cb()
				self:UpdateCost()
			end

			UIMgr.AddPanel(DlgPowerBuy(), {
				cb = cb
			})

			return
		else
			self.sweepCount = self.sweepCount + 1
		end
	else
		local holdPower = ItemManager:GetItemCount(self.infoStage.data.CostItem[1])
		local costPower = self.infoStage.data.CostItem[2]

		if ItemManager:IsItemHoldEnough(self.costItem, (self.sweepCount + 1) * costPower) then
			self.sweepCount = self.sweepCount + 1
		end
	end

	self:UpdateCost()
end

function DlgStageSweep:OnClickedButtonSub()
	self.sweepCount = self.sweepCount - 1

	self:UpdateCost()
end

function DlgStageSweep:OnClickedButtonMax()
	self.sweepCount = GetConfigArgInt("SweepMaxNum")

	self:UpdateCost()
end

function DlgStageSweep:OnClickedButtonSweep()
	local function funSweep()
		self:RequestSweep(self.sweepCount)
	end

	local function funNum()
		return ChapterMgr:GetStageLeftPlayNumWithLimit(self.infoStage.id) ~= 0
	end

	local function funTicket()
		return not self.ticketNotEnough
	end

	local function funPower()
		if self.powerNotEnough then
			if self.costItem == 503 then
				require("UI/Dlg/Common/DlgPowerBuy")

				local function cb()
					self:UpdateCost()
				end

				UIMgr.AddPanel(DlgPowerBuy(), {
					cb = cb
				})
			else
				UIMgr.ShowMsg(string.format(Lang(12390), "<color=yellow>" .. ItemManager:Get(self.costItem):GetName() .. "</color>"))
			end

			return false
		end

		return true
	end

	if not funNum() then
		UIMgr.ShowMsg(_("Msg_SweepMax"))

		return
	elseif not funTicket() then
		UIMgr.ShowMsg(_("Msg_NoSweepTicket"))

		return
	elseif not funPower() then
		return
	end

	funSweep()
end

function DlgStageSweep:RequestSweep(num)
	if num < 1 then
		return
	end

	LoadingMgr.Show(eLoadingType.Repeat)

	local function wrap_cb(pb)
		self:ResponseWipeStage(pb, callback)
	end

	NetManager:RequestWipeStage(self.infoStage.id, num, self.listCardId, wrap_cb)
end

function DlgStageSweep:ResponseWipeStage(msg, callback)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if msg.result.code == 0 then
		self.sweeping = true
		self.IsBtnJump = false

		SetActiveFunc(self.Btn_jump, true)
		SetActiveFunc(self.imgChallengeNum, false)

		local data = {}

		data.infoStage = self.infoStage
		data.waves = {}
		data.extraWaves = {}

		local waves = msg.waves

		self.listSetter = {}

		if tonumber(msg.dropRaidBossId) > 0 then
			self.dropRaidBossId = tonumber(msg.dropRaidBossId)
			self.dropRaidBossStageId = tonumber(msg.dropRaidBossStageId)
		end

		for i = 1, #waves do
			local setter = SetterData.GetSetterData(waves[i].setter)

			table.insert(self.listSetter, setter)

			local listItem = setter:GetlistItem(protocol_pb.AF_NORMAL)

			table.insert(data.waves, listItem)
		end

		local listRoleCardId = InfoTeam:GetUpRoleCardList()

		for i = 1, 5 do
			local id = listRoleCardId[i]

			if id and id > 0 then
				local infoRoleCard = RoleCardMgr:GetRoleCard(id)
			end
		end

		for i = 1, #waves do
			local setter = self.listSetter[i]

			setter:Parse()
		end

		if self.infoStage.data.ChapterType == ChapterFromType.card then
			Event.Instance:Fire(EventEnum.UpdateItemDataNotify)
		end

		SetActiveFunc(self.panelStageAward, false)
		SetActiveFunc(self.panelStageExtraAward, false)

		self.canLeave = false

		SetActiveFunc(self.sweepGroup, false)
		SetActiveFunc(self.AniPanelCut, true)

		if not IsNil(self.EnemyGroup) and not self.IsBtnJump then
			SetActiveFunc(self.EnemyGroup, true)
		end

		UIUtil.SetSpineAnimationState(self.GoStageSweepBG, "none", true, false)
		SetActiveFunc(self.PanelAward, true)
		self:UpdateScroll(waves)

		self.waves = waves
		self.Timer = TimerMgr.AddTimer(eTimerType.RealTime, 4, function()
			if not IsNil(self.EnemyGroup) and not self.IsBtnJump then
				SetActiveFunc(self.EnemyGroup, false)

				self.canLeave = true
			end
		end, nil)
		self.Timer2 = TimerMgr.AddTimer(eTimerType.RealTime, 6, function()
			if not IsNil(self.AniActorLoop) then
				SetActiveFunc(self.AniActorLoop, false)

				if not self.IsBtnJump then
					self:OnClickedButtonSure()
				end
			end
		end, nil)

		Event.Instance:Fire("PageBossliveEvent")
		Event.Instance:Fire(EventEnum.UpdateStage, true)
		Event.Instance:Fire("UpdateStageNum")
	else
		UIMgr.ShowMsg(msg.result.desc, msg)
	end
end

function DlgStageSweep:OnClickedButJump()
	SetActiveFunc(self.AniActorLoop, false)

	self.IsBtnJump = true

	SetActiveFunc(self.Btn_jump, false)
	SetActiveFunc(self.imgChallengeNum, true)
	self:OnClickedButtonSure()

	if self.Timer then
		TimerMgr.RemoveTimer(self.Timer)

		self.Timer = nil
	end

	if self.Timer2 then
		TimerMgr.RemoveTimer(self.Timer2)

		self.Timer2 = nil
	end
end

function DlgStageSweep:OnClickedButtonSure()
	SetActiveFunc(self.panelStageAward, true)
	SetActiveFunc(self.panelStageExtraAward, true)

	self.canLeave = true

	SetActiveFunc(self.AniPanelCut, false)
	SetActiveFunc(self.PanelAward, false)
	SetActiveFunc(self.sweepGroup, true)
	self:UpdateCost()

	if self.timer then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end

	self:UpdateRequire()

	local listNormal = {}
	local listExtra = {}
	local listHigh = {}
	local listActiveAward = {}

	if self.waves then
		for i = 1, #self.waves do
			local setter = self.listSetter[i]
			local listItem = setter:Getlist(protocol_pb.AF_NORMAL)

			for n = 1, #listItem do
				table.insert(listNormal, listItem[n])
			end

			local listItem = setter:Getlist(protocol_pb.AF_STAGE_SWEEP)

			for n = 1, #listItem do
				table.insert(listExtra, listItem[n])
			end

			local listItem = setter:Getlist(protocol_pb.AF_STAGE_HIGH_AWARD)

			for n = 1, #listItem do
				table.insert(listHigh, listItem[n])
			end

			local listItem = setter:Getlist(protocol_pb.AF_ACTIVE_AWARD)

			for n = 1, #listItem do
				table.insert(listActiveAward, listItem[n])
			end
		end
	end

	local function wrap_cb()
		if self.isOpen then
			-- block empty
		end
	end

	local data = {}

	data.list = listNormal
	data.listExtra = listExtra
	data.listHigh = listHigh
	data.listActiveAward = listActiveAward
	data.listRoleId = self.listRoleId

	if SetterData.showLevelup then
		function data.callback()
			wrap_cb()

			local data = {}

			data.perLevel = self.perLevel

			function data.callback()
				if self.dropRaidBossId then
					require("UI/Page/PageActivityBossRaid/DlgNewBossRaid")

					local data = {}

					function data.callback(...)
						require("UI/Page/PageActivityBossRaid/PageActivityBossRaid")

						ActivityBossRaidMgr.selectTab = nil

						if ActivityBossRaidMgr.bossRaidTimeData == nil then
							local activityList = ActiveMgr:GetActiveByType(eActiveType.bossraid)

							for i, v in ipairs(activityList) do
								if v:IsShowOpen() then
									ActivityBossRaidMgr.bossRaidTimeData = v

									break
								end
							end
						end

						if ActivityBossRaidMgr.bossRaidTimeData and ActivityBossRaidMgr.bossRaidTimeData:IsShowOpen() then
							UIMgr.SwitchPanel(PageActivityBossRaid())
						else
							UIMgr.ShowMsg(_("Msg_Active_Over"))
						end

						self:Close()
					end

					data.dropRaidBossStageId = self.dropRaidBossStageId
					data.dropRaidBossId = self.dropRaidBossId

					UIMgr.AddPanel(DlgNewBossRaid(), data, self.Parent)

					self.dropRaidBossId = nil
				end
			end

			UIMgr.AddPanel(DlgProducerLevelUp(), data)

			self.perLevel = PlayerInst:GetCurLv()
		end
	else
		function data.callback()
			wrap_cb()

			if self.dropRaidBossId then
				require("UI/Page/PageActivityBossRaid/DlgNewBossRaid")

				local data = {}

				function data.callback(...)
					require("UI/Page/PageActivityBossRaid/PageActivityBossRaid")

					ActivityBossRaidMgr.selectTab = nil

					if ActivityBossRaidMgr.bossRaidTimeData == nil then
						local activityList = ActiveMgr:GetActiveByType(eActiveType.bossraid)

						for i, v in ipairs(activityList) do
							if v:IsShowOpen() then
								ActivityBossRaidMgr.bossRaidTimeData = v

								break
							end
						end
					end

					if ActivityBossRaidMgr.bossRaidTimeData and ActivityBossRaidMgr.bossRaidTimeData:IsShowOpen() then
						UIMgr.SwitchPanel(PageActivityBossRaid())
					else
						UIMgr.ShowMsg(_("Msg_Active_Over"))
					end

					self:Close()
				end

				data.dropRaidBossStageId = self.dropRaidBossStageId
				data.dropRaidBossId = self.dropRaidBossId

				UIMgr.AddPanel(DlgNewBossRaid(), data, self.Parent)

				self.dropRaidBossId = nil
			end
		end
	end

	SetActiveFunc(self.Btn_jump, false)
	SetActiveFunc(self.imgChallengeNum, true)
	UIMgr.AddPanel(DlgGetSweepAward(), data)

	self.sweeping = false
end

function DlgStageSweep:UpdateScroll(waves)
	if self.listCell then
		for i = 1, #self.listCell do
			self.listCell[i]:OnLeave()
		end

		self.listCell = nil
	end

	GOUtil.DestroyAllChildren(self.ScrollView.content.gameObject)

	self.listCell = {}

	for i = 1, #waves do
		local setter = self.listSetter[i]
		local listItem = setter:Getlist(protocol_pb.AF_NORMAL)
		local listHigh = setter:Getlist(protocol_pb.AF_STAGE_HIGH_AWARD)
		local listExtraItem = setter:Getlist(protocol_pb.AF_STAGE_SWEEP)
		local listActiveAward = setter:Getlist(protocol_pb.AF_ACTIVE_AWARD)
		local item = CellSweep(self.PrefabCellSweep, self.ScrollView.content.gameObject, self)

		item:Create()

		local data = {}

		data.index = i
		data.PrefabCellItem = self.PrefabCellItem
		data.infoStage = self.infoStage
		data.listItem = listItem
		data.listHigh = listHigh
		data.listExtraItem = listExtraItem
		data.listActiveAward = listActiveAward

		item:UpdateData(data)

		local scrollviewContent = GOUtil.AddMissingComponent(item.UIRootObject, "UIScrollViewContent")

		scrollviewContent.scrollView = self.ScrollView

		table.insert(self.listCell, item)
	end

	local count = 0

	local function wrap_cb(...)
		count = count + 1

		if count > #waves and self.timer then
			TimerMgr.RemoveTimer(self.timer)

			self.timer = nil

			return
		end

		local setter = self.listSetter[count]
		local listItem = setter:Getlist(protocol_pb.AF_NORMAL)

		for i = 1, #listItem do
			local s = listItem[i]

			if s == nil then
				return
			end

			if s.id == 504 then
				-- block empty
			else
				local infoItem = SetterData.GetItemFromAsset(s)

				if infoItem ~= nil and infoItem.pb.id == self.needItem.id then
					self.preHoldNum = infoItem.pb.num + self.preHoldNum
					self.txtRequireNum.text = GetItemShowStrNum2(self.needItem.needNum, self.preHoldNum)
				end
			end
		end
	end

	if self.needItem then
		self.timer = TimerMgr.AddTimer(eTimerType.ScaleTime, 0.7, wrap_cb, nil, #waves)
	end

	TimerMgr.AddTimer(eTimerType.FrameCount, 0.7, function()
		self.ScrollView:SetContentPosImmediate(Vector2.New(0, (#waves - 1) * 160))
		self.ScrollView:SetContentPos(Vector2.New(0, 0, 5), 1.8)
	end, nil)
end

function DlgStageSweep:OnClickedButtonQuit()
	if not self.canLeave or self.sweeping then
		UIMgr.ShowMsg(_("Msg_Sweeping"))

		return
	end

	self:Close()
end

function DlgStageSweep:OnBackAndroid()
	if self.Btn_jump and GOUtil.IsActiveSelf(self.Btn_jump) then
		self:OnClickedButJump()
	else
		self:OnClickedButtonQuit()
	end
end
