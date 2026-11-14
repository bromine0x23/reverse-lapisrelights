-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePass/DlgCardStage.lua

require("UI/Page/PageChapter/DlgStageSweep")
require("UI/Page/PagePass/CellCommonStage")

local InfoTeam = require("Info/InfoTeam")

DlgCardStage = class("DlgCardStage", UIPanel)

function DlgCardStage:ctor()
	DlgCardStage.base.ctor(self, "UI/PanelPass/DlgCardStage")
end

function DlgCardStage:PreLoad()
	self:LoadResAsync("UI/PanelPass/CellStage", "PrefabCell", GameObject)
end

function DlgCardStage:Purge()
	DlgCardStage.base.Purge(self)

	if self.spineRef then
		ResourceMgr.Unload(self.spineRef)
	end

	ResourceMgr.Unload(self.PrefabCell)

	if self.listCell then
		for _, item in ipairs(self.listCell) do
			item:OnLeave()
		end

		self.listCell = nil
	end
end

function DlgCardStage:OnRegisterEvent()
	self:AddClick(self.Button, self.OnClickBtnClose, PATH_SFX_UI_CANCEL)
	Event.Instance:Add(EventEnum.UpdateStage, self.UpdatePanel, self)
	Event.Instance:Add("UpdateStageNum", self.UpdateStagePlayNum, self)
end

function DlgCardStage:OnUnRegisterEvent()
	self:RemoveClick(self.Button, self.OnClickBtnClose)
	Event.Instance:Remove(EventEnum.UpdateStage, self.UpdatePanel, self)
	Event.Instance:Remove("UpdateStageNum", self.UpdateStagePlayNum, self)
end

function DlgCardStage:OnEnter(vParam)
	self.CardBg = self:GetChildComponent("Panel/BgCard/CardBg", "RawImage")
	self.CardIcon = self:GetChildComponent("Panel/BgCard/Card", "RawImage")
	self.CardName = self:GetChildComponent("Panel/Info/TxtName", "Text")
	self.TxtRefresh = self:GetChildComponent("Panel/Info/TxtRefresh", "Text")
	self.TxtNum = self:GetChildComponent("Panel/BgNum/TxtNum", "Text")
	self.StoneIcon = self:GetChildComponent("Panel/Info/StoneIcon", "Image")
	self.ImgRate = self:GetChildGameObject("Panel/Info/Rate/Bar/Image")
	self.TxtRate = self:GetChildComponent("Panel/Info/Rate/Bar/Text", "Text")
	self.BtnExChange = self:GetChildGameObject("Panel/Info/Rate/Button")
	self.GoDot = self:GetChildGameObject("Panel/Info/Rate/Button/Dot")
	self.CardStory = self:GetChildGameObject("Panel/Stage/ScrollArea/Content/1")
	self.Button = self:GetChildGameObject("Panel/Button")
	self.cardId = vParam.cardId
	self.infoRoleCard = RoleCardMgr:GetRoleCard(self.cardId)
	self.spineRef = vParam.spineRef

	self:GetCardStage()
	self:InitStageList()
	self:UpdatePanel()
end

function DlgCardStage.Init(infoRoleCard)
	if not infoRoleCard then
		return
	end

	local tab = {}

	if infoRoleCard.data.SpineData ~= "" then
		local function wrap_cb()
			LoadingMgr.Hide(eLoadingType.Repeat)
			UIMgr.AddPanel(DlgCardStage(), {
				spineRef = tab.spineRef,
				cardId = infoRoleCard.id
			})
		end

		LoadingMgr.Show(eLoadingType.Repeat)

		tab.spineGroupHandle = ResourceMgr.BeginSubmit(wrap_cb)

		ResourceMgr.SubmitCache(infoRoleCard.data.SpineData .. "_Anim", tab, "spineRef", GameObject)
		ResourceMgr.EndSubmit()
	end
end

function DlgCardStage:GetCardStage()
	self.listStage = {}

	local chapterId = self.infoRoleCard.data.CardChapter

	if chapterId ~= 0 then
		local infoChapter = ChapterMgr:GetChapter(chapterId)

		self.listStage = infoChapter.listStage
	end
end

function DlgCardStage:InitStageList()
	local content = self:GetChildGameObject("Panel/Stage/ScrollArea/Content")

	self.listCell = {}

	local count = #self.listStage - 1
	local h = count * 282 - 12 + 4

	GOUtil.SetRectTransformSizeDelta(content, 786, h)

	for i = 1, count do
		local cell = CellCommonStage(self.PrefabCell, content, nil, self)

		cell:Create()
		table.insert(self.listCell, cell)
	end
end

function DlgCardStage:UpdatePanel()
	local infoRoleCard = self.infoRoleCard

	self.CardName.text = infoRoleCard:GetName()

	local function fun()
		self.CardBg.gameObject:SetActive(true)

		self.CardIcon.enabled = true

		RoleCardMgr:SetInfoPanel(infoRoleCard, self.CardIcon, self.CardBg, self)
	end

	if self.spineRef then
		local goSpine = GOUtil.InstantiateUIPrefab(self.spineRef, self.CardIcon.gameObject)

		GOUtil.UpdateSpineSkeleton(self.CardIcon.gameObject)

		if GOUtil.GetComponent(goSpine, "SpineAspectRatioFitter") then
			GOUtil.GetComponent(goSpine, "SpineAspectRatioFitter").enabled = false
		end
	else
		fun()
	end

	RoleCardMgr:SetCardLocation(infoRoleCard, self.CardIcon.gameObject, 4)

	local stoneId = ItemManager:GetCardSoulId(infoRoleCard.id)
	local infoItem = ItemManager:Get(stoneId)

	UIUtil.SetImageSprite(self.StoneIcon, infoItem:GetIcon(), self)

	self.TxtRefresh.text = string.format(Lang(8111005), tostring(InfoGameInst.RefreshTime))
	self.TxtNum.text = _("Desc_AllLastNum") .. CardChapterMgr.GetTotalRemainingChallengeNum() .. "/" .. CardChapterMgr.GetTotalLimitChallengeNum()

	self:UpdateStageList()
end

function DlgCardStage:UpdateCardStoneChip()
	local itemId = ItemManager:GetCardSoulShardId(self.infoRoleCard.id)
	local count = ItemManager:GetItemCount(itemId)
	local targetCnt = GetConfigArgJson("ExchangeDebrisSoul")[self.infoRoleCard.cardRank]

	self.TxtRate.text = count .. "/" .. targetCnt

	local rate = count / targetCnt

	if rate > 1 then
		rate = 1
	end

	self.ImgRate.transform.localScale = Vector3(rate, 1, 1)

	SetActiveFunc(self.GoDot, rate >= 1)
end

function DlgCardStage:UpdateStageList()
	for i = 1, #self.listCell do
		local cell = self.listCell[i]
		local infoStage = self.listStage[i + 1]
		local data = {
			infoStage = infoStage
		}

		cell:UpdateData(data)
	end
end

function DlgCardStage:OnClickBtnClose()
	ChapterMgr.cardIndex = 0

	self:Close()
end

function DlgCardStage:UpdateStagePlayNum()
	self:UpdatePanel()
end

function DlgCardStage:CloseSelf()
	self:Close()
end
