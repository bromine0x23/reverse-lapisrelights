-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionRaid/DlgRaidDetail.lua

DlgRaidDetail = class("DlgRaidDetail", UIPanel)

function DlgRaidDetail:ctor()
	self.UIPrefabPath = "UI/PanelUnionRaid/DlgRaidDetail"
end

function DlgRaidDetail:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCell", GameObject)
end

function DlgRaidDetail:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCell)

	if self.listItem then
		for _, item in ipairs(self.listItem) do
			if item.OnLeave then
				item:OnLeave()
			end
		end

		self.listItem = nil
	end
end

function DlgRaidDetail:OnRegisterEvent()
	self:AddClick(self.BtnEnter, self.OnClickedBtnEnter)
	self:AddClick(self.BtnClose, self.OnClickedBtnClose)
	Event.Instance:Add("UpdateRaidSystem", self.Close, self)
end

function DlgRaidDetail:OnUnRegisterEvent()
	self:RemoveClick(self.BtnEnter, self.OnClickedBtnEnter)
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
	Event.Instance:Remove("UpdateRaidSystem", self.Close, self)
end

function DlgRaidDetail:OnEnter(vParam)
	self:DealWithlocalization()

	self.ImgType = self:GetChildComponent("Panel/Panel1/ImgType", "Image")
	self.ImgName = self:GetChildComponent("Panel/Panel1/ImgName", "Image")
	self.TxtRate = self:GetChildComponent("Panel/Panel1/Rate/TxtRate", "Text")
	self.ImgRate = self:GetChildComponent("Panel/Panel1/Rate/Bar", "Image")
	self.TxtCheer = self:GetChildComponent("Panel/Panel1/TxtCheer", "Text")
	self.TxtCombat = self:GetChildComponent("Panel/Panel2/Desc/Combat/Text", "Text")
	self.TxtDesc = self:GetChildComponent("Panel/Panel2/Desc/Content/Text", "TextView")
	self.BtnEnter = self:GetChildGameObject("Panel/Panel1/BtnEnter")
	self.ImgBtnEnter = GOUtil.GetComponent(self.BtnEnter, "Image")
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")

	self:InitData(vParam)
end

function DlgRaidDetail:DealWithlocalization()
	local txt = self:GetChildComponent("Panel/Title/Text", "Text")

	txt.text = Lang(42032)
	txt = self:GetChildComponent("Panel/Panel2/Desc/Title/Text", "Text")
	txt.text = _("Desc_Introduction_Raid")
	txt = self:GetChildComponent("Panel/Panel2/Reward/Title/Text", "Text")
	txt.text = _("Desc_Award_Raid_Break")
	txt = self:GetChildComponent("Panel/Panel1/Rate/Text", "Text")
	txt.text = _("Desc_Rate_Break_Raid")
end

function DlgRaidDetail:InitData(raid)
	self.infoRaid = raid

	self:UpdatePanel()
	self:InitRewardList()
end

function DlgRaidDetail:UpdatePanel()
	UIUtil.SetImageSprite(self.ImgName, "UI/PanelUnionRaid/AtlasDlgRaidDetail/BG_maze_door_word_0" .. self.infoRaid.data.ID, self)
	UIUtil.SetImageSprite(self.ImgType, "UI/PanelUnionRaid/AtlasDlgRaidDetail/BG_maze_door_frame_0" .. self.infoRaid.data.ID, self)

	self.ImgRate.fillAmount = self.infoRaid.progress / self.infoRaid.data.FinishPoint
	self.TxtRate.text = "<color=#DE5992>" .. self.infoRaid.progress .. "</color>/" .. self.infoRaid.data.FinishPoint
	self.TxtCheer.text = string.format(_("Desc_Raid_Cheer_Num_Today"), "<color=#DE5992>" .. UnionRaidMgr.maxCommPlayNum - UnionRaidMgr.GetPlayNum(eRaidType.Common) .. "</color>/" .. UnionRaidMgr.maxCommPlayNum)
	self.TxtDesc.Text = ModifyRichTextForTextView(Lang(self.infoRaid.data.Desc))

	local stageId = UnionRaidMgr.GetFirstStageId(self.infoRaid.id)

	if stageId then
		local infoStage = ChapterMgr:GetStage(stageId)
		local listSE = infoStage.data.SafeCE
		local safeCE = 0

		if listSE and listSE[1] and listSE[1][1] then
			safeCE = listSE[1][1]
		end

		self.TxtCombat.text = string.format(_("Desc_Union_Raid_Recom_Power"), tostring(safeCE))

		local listUpCardId, listAddCardId = {
			0,
			0,
			0,
			0,
			0
		}, {
			0,
			0,
			0,
			0,
			0
		}
		local infoteam = require("Info/InfoTeamRaid")

		listUpCardId = infoteam:GetUpRoleCardList()

		local teamCE = self:GetTeamCE(listUpCardId, listAddCardId)
		local strColor = teamCE <= safeCE and "F93030" or "24BF00"
		local color = sixNumToRGB(strColor)

		UIUtil.SetGraphicColorRGB(self.TxtCombat, color.r / 255, color.g / 255, color.b / 255)
	else
		self.TxtCombat.text = string.format(_("Desc_Union_Raid_Recom_Power", "0"))
	end
end

function DlgRaidDetail:GetTeamCE(listUpCardId, listAddCardId)
	local sum = 0

	for i = 1, #listUpCardId do
		if listUpCardId[i] ~= 0 then
			local upCard = RoleCardMgr:GetRoleCard(listUpCardId[i])
			local role = RoleMgr:GetRole(upCard.data.CharacterID)
			local addCard

			if listAddCardId[i] ~= nil and listAddCardId[i] ~= 0 then
				addCard = RoleCardMgr:GetRoleCard(listAddCardId[i])
			end

			sum = sum + RoleCardMgr:GetFightValue(role, upCard, addCard)
		end
	end

	return sum
end

function DlgRaidDetail:InitRewardList()
	self.listItem = {}

	local list = self.infoRaid.data.Award
	local content = self:GetChildGameObject("Panel/Panel2/Reward/ScrollArea/Content")

	for _, v in ipairs(list) do
		local item = CellItem(self.PrefabCell, content, self)

		item:Create()

		item.tipData = {
			showNum = true,
			initPanelIndex = 3,
			needFromBtn = false
		}

		GOUtil.SetTransformLocalScale(item.UIRootObject, 0.85)

		local infoItem = ItemManager:GetValueItem(v[1] or 501, v[2] or 0)

		item:UpdateWithNumType(infoItem)
		table.insert(self.listItem, item)
	end
end

function DlgRaidDetail:OnClickedBtnEnter()
	if not UnionMgr.HasUnion(true) then
		return
	end

	UnionRaidMgr:SetBeingCommRaid(self.infoRaid.id)
	UIMgr.SwitchPanel(PageRaid, self.infoRaid)
	self:Close()
end

function DlgRaidDetail:OnClickedBtnClose()
	self:Close()
end
