-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivityBossRaid/DlgBossRaidRecord.lua

require("UI/Page/PageActivityBossRaid/CellBossRaidFinish")
require("UI/Page/PageActivityBossRaid/DlgBossRaidOver")

DlgBossRaidRecord = class("DlgBossRaidRecord", UIPanel)

function DlgBossRaidRecord:ctor()
	self.UIPrefabPath = "UI/PanelActivityBossRaid/DlgBossRaidRecord"
end

function DlgBossRaidRecord:Purge()
	DlgBossRaidRecord.base.Purge(self)

	UIMgr.GetCurPanel().DlgBossRaidRecord = nil

	if self.PrefabCellBossRaidFinish then
		ResourceMgr.Unload(self.PrefabCellBossRaidFinish)

		self.PrefabCellBossRaidFinish = nil
	end

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function DlgBossRaidRecord:PreLoad()
	self:LoadResAsync("UI/PanelActivityBossRaid/CellBossRaidFinish", "PrefabCellBossRaidFinish")
end

function DlgBossRaidRecord:OnEnter(vParam)
	self:Localization()

	self.tabGo = self:GetChildGameObject("Panel/Tab")
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")
	self.Preview = self:GetChildGameObject("Panel/Preview")
	self.GetAll = self:GetChildGameObject("Panel/GetAll")
	self.GetAllImage = self:GetChildComponent("Panel/GetAll", "Image")
	self.Empty = self:GetChildGameObject("Panel/Empty")

	self:InitScroll()
	self:TabClick()
end

function DlgBossRaidRecord:Localization(...)
	local TextAuto

	TextAuto = self:GetChildComponent("Panel/Tital/Text", "Text")
	TextAuto.text = _("RaidBoss_Notes")
	TextAuto = self:GetChildComponent("Panel/Preview/Text", "Text")
	TextAuto.text = _("RaidBoss_BoxPreview")
	TextAuto = self:GetChildComponent("Panel/GetAll/Text", "Text")
	TextAuto.text = _("Desc_OneKeyRec")
	TextAuto = self:GetChildComponent("Panel/Empty/Text", "Text")
	TextAuto.text = _("RaidBoss_RecordEmpty")
end

function DlgBossRaidRecord:RequestBossRaidRecord(callback)
	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestBossRaidRecord(function(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Sucess then
			callback()
		else
			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end)
end

function DlgBossRaidRecord:OnRegisterEvent()
	self:AddClick(self.BtnClose, self.OnButtonExit)
	self:AddClick(self.Preview, self.OnButtonPreview)
	self:AddClick(self.GetAll, self.OnButtonGetAll)
end

function DlgBossRaidRecord:OnUnRegisterEvent()
	self:RemoveClick(self.BtnClose, self.OnButtonExit)
	self:RemoveClick(self.Preview, self.OnButtonPreview)
	self:RemoveClick(self.GetAll, self.OnButtonGetAll)
end

function DlgBossRaidRecord:OnButtonExit()
	self:Close()
end

function DlgBossRaidRecord:InitScroll()
	local function ListUpdate(item, index)
		local data = {}

		data.info = self.listBossRaid[index]

		item:UpdateData(data)
	end

	self.ScrollArea = self:GetChildGameObject("Panel/ScrollAreaFinish")

	local content = self:GetChildComponent("Panel/ScrollAreaFinish/Content", "Transform")
	local count = 0

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.ScrollArea, content, count, self.PrefabCellBossRaidFinish, CellBossRaidFinish, self, false, nil, ListUpdate)
end

function DlgBossRaidRecord:TabClick()
	self:RequestBossRaidRecord(function()
		self.listBossRaid = ActivityBossRaidMgr:GetFinishedBossRaid()

		self.UIScrollTool:UpdateListData(self.listBossRaid)
		SetActiveFunc(self.Empty, #self.listBossRaid <= 0)

		local haveGetAll = true

		for i, v in ipairs(self.listBossRaid) do
			if v.curProgress == 0 and v.selfStatus == 0 then
				haveGetAll = false

				break
			end
		end

		local gray = TenaryOp(haveGetAll, 1, 0)

		DealWithListRef(self, UIUtil.SetImageGray(self.GetAllImage, gray))
	end)

	self.refresh = false
end

function DlgBossRaidRecord:AddCellClick(data)
	self:AddClick(data.Box.gameObject, self.GetBossRaidReward)
end

function DlgBossRaidRecord:GetBossRaidReward(data)
	local go = data.pointerPressRaycast.gameObject.transform.parent.parent.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local raidBossId = tonumber(self.listBossRaid[info.Item.Index].id)

	self.stageId = tonumber(self.listBossRaid[info.Item.Index].stageId)

	local boxLevel = info.Item.BoxIndex

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestGetBossRaidReward(raidBossId, function(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Sucess then
			self.setter = pb.setter

			if #self.setter == 0 then
				self:TabClick()

				return
			end

			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:RequestBossRaidDamage(raidBossId, function(pb)
				LoadingMgr.Hide(eLoadingType.Repeat)

				if pb.result.code == NetManager.Result_Sucess then
					local data = {}

					data.isBattleOver = false
					data.harms = pb.harms
					data.setter = self.setter
					data.stageId = self.stageId
					data.boxLevel = boxLevel

					function data.callBack()
						self:TabClick()
					end

					local InfoTeam = require("Info/InfoTeam")
					local listDefaultTeam = InfoTeam.stageTeams
					local defaultTeamData = listDefaultTeam[tonumber(RoleCardMgr:GetTeamListIndex())]
					local num = math.random(1, 5)

					if defaultTeamData.roleCardTeams[num] ~= 0 then
						InfoSoundEventMgr:LoadBank(RoleCardMgr:GetRole(defaultTeamData.roleCardTeams[num]).data.VocalBank)
						InfoSoundEventMgr:Play("VocalCustomsclearance2", RoleCardMgr:GetRole(defaultTeamData.roleCardTeams[num]).data.VocalCustomsclearance2)
					end

					UIMgr.AddPanel(DlgBossRaidOver(), data)
				else
					UIMgr.ShowMsg(pb.result.desc, pb)
				end
			end)
		else
			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end)
end

function DlgBossRaidRecord:OnButtonPreview()
	require("UI.Page.PageActivityBossRaid.DlgTreasureBoxtPreview")
	UIMgr.AddPanel(DlgTreasureBoxtPreview())
end

function DlgBossRaidRecord:OnButtonGetAll()
	local boxLevel = 1

	for i1, v1 in ipairs(self.listBossRaid) do
		for i2, v2 in ipairs(v1.raidBossData.FinishReward) do
			if v1.randomAward == v2[1] then
				if boxLevel < i2 then
					boxLevel = i2
				end

				break
			end
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestGetBossRaidReward(0, function(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Sucess then
			self.setter = pb.setter

			if #self.setter == 0 then
				self:TabClick()

				return
			end

			local data = {}

			data.isBattleOver = false
			data.setter = self.setter
			data.boxLevel = boxLevel

			function data.callBack()
				self:TabClick()
			end

			UIMgr.AddPanel(DlgBossRaidOver(), data)
		else
			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end)
end
