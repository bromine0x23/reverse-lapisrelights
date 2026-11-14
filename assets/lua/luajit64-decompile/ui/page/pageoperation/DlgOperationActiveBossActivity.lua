-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgOperationActiveBossActivity.lua

require("UI/Item/UIItemBase")

DlgOperationActiveBossActivity = class("DlgOperationActiveBossActivity", UIItemBase)

function DlgOperationActiveBossActivity:ctor()
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function DlgOperationActiveBossActivity:Purge()
	self:UnloadRef()
end

function DlgOperationActiveBossActivity:UnloadRef()
	self:RemoveClick(self.btn_open, self.OnClickedOpen)
	self.infoActive:ClearOperationSpine()
	UnloadAllImageSprite(self)

	if self.cell1 then
		self.cell1:OnLeave()
	end
end

function DlgOperationActiveBossActivity:OnRegisterEvent()
	return
end

function DlgOperationActiveBossActivity:OnUnRegisterEvent()
	return
end

function DlgOperationActiveBossActivity:OnEnter(vParam)
	self.PrefabCell = vParam.PrefabCell

	local g = self.UIRootObject

	self.scrollArea = GOUtil.FindChildGameObject(g, "Panel/BgAward/ScrollArea")
	self.content = GOUtil.FindChildComponent(self.scrollArea, "Content", "RectTransform")
	self.btn_open = GOUtil.FindChildGameObject(g, "Panel/btn_open")

	local Text = GOUtil.FindChildComponent(g, "Panel/btn_open/Text", "Text")

	Text.text = _("UI_Go") .. _("eReturn_Operation")
	self.gCellItem = GOUtil.FindChildGameObject(g, "Panel/Model/Pic/Pic1/CellItem")

	self:AddClick(self.btn_open, self.OnClickedOpen)

	OperationActiveMgr.BossActivityPopupIndex = 0
end

function DlgOperationActiveBossActivity:DealWithLocalization(ActiveID)
	self.infoActive:SetOperationUIModel(ActiveID, self.BGRaw, self.UIRootObject)
end

function DlgOperationActiveBossActivity:Init(infoActive, BGRaw)
	self.BGRaw = BGRaw
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder
	self.infoActive = infoActive

	self:DealWithLocalization(self.ActiveID)

	local award = infoActive.data.Params[1]

	if award then
		local infoItem = ItemManager:GetValueItem(award[1], award[2])

		self.cell1 = CellItem(self.gCellItem)

		self.cell1:InitItemByRoot(self.gCellItem)

		if award[2] == 0 then
			self.cell1:UpdateNoNumType(infoItem)
		else
			self.cell1:UpdateWithNumType(infoItem)
		end
	end

	local startTime = infoActive.data.ShowStartTime
	local endTime = infoActive.data.ShowEndTime
	local strStar = string.split(startTime, " ")[1]
	local strEnd = string.split(endTime, " ")[1]
	local uiInfo = InfoOperationActive:GetOperationUIInfo(self.ActiveID)

	if uiInfo then
		for i = 1, 1 do
			local Text = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Text/Text" .. i, "Text")

			if uiInfo and uiInfo.Text and uiInfo.Text[i] and uiInfo.Text[i][1] and Text then
				local str = Lang(uiInfo.Text[i][1])

				Text.text = string.format(str, string.gsub(strStar, "-", ".") .. "-" .. string.gsub(strEnd, "-", "."))
			end
		end
	end
end

function DlgOperationActiveBossActivity:UpdateData(infoActive)
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder

	self:DealWithLocalization(self.ActiveID)

	local award = infoActive.data.Params[1]

	if award then
		local infoItem = ItemManager:GetValueItem(award[1], award[2])

		if not self.cell1 then
			self.cell1 = CellItem(self.gCellItem)

			self.cell1:InitItemByRoot(self.gCellItem)
		end

		if award[2] == 0 then
			self.cell1:UpdateNoNumType(infoItem)
		else
			self.cell1:UpdateWithNumType(infoItem)
		end
	end

	local Text = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Text/Text" .. 1, "Text")
	local startTime = infoActive.data.ShowStartTime
	local endTime = infoActive.data.ShowEndTime
	local strStar = string.split(startTime, " ")[1]
	local strEnd = string.split(endTime, " ")[1]
	local str = Text.text

	Text.text = string.format(str, string.gsub(strStar, "-", ".") .. "-" .. string.gsub(strEnd, "-", "."))
end

function DlgOperationActiveBossActivity:OnClickedOpen()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Boss)

	if not isOpen then
		return
	end

	local isShow, msg = ActiveMgr:IsBossActiveOpen()

	if not isShow then
		UIMgr.ShowMsg(msg)

		return
	end

	ChapterMgr.bossIndex = 0
	OperationActiveMgr.Tag = eOperationActive.BossActivity

	require("UI/Page/PageActivity/PageBossActivityBG")

	ChapterMgr.BossActivityStageType = nil

	PageBossActivityBG.OpenActivity()
	InfoSoundEventMgr:LoadBank(RoleMgr:GetRole(201).data.VocalBank)
	InfoSoundEventMgr:Play("VocalCommon6", RoleMgr:GetRole(201).data.VocalCommon6)
end
