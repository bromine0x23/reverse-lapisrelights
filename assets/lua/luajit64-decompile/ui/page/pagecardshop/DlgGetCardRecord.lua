-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCardShop/DlgGetCardRecord.lua

DlgGetCardRecord = class("DlgGetCardRecord", UIPanel)

function DlgGetCardRecord:ctor()
	self.UIPrefabPath = "UI/PageCardShop/DlgGetCardRecord"
end

function DlgGetCardRecord:Purge()
	DlgGetCardRecord.base.Purge(self)
end

function DlgGetCardRecord:PreLoad()
	return
end

function DlgGetCardRecord:OnEnter(vParam)
	self.vParam = vParam.records
	self.listPbRecords = vParam.records
	self.info = vParam.info
	self.ButtonExit = self:GetChildGameObject("Main/ButtonQuit")
	self.TextListObj = self:GetChildGameObject("Main/TextList")

	local Text = self:GetChildComponent("Main/bg_title/Text", "Text")

	Text.text = Lang(self.info.data.Name)
	Text = self:GetChildComponent("Main/Text1", "Text")
	Text.text = _("DlgCardShopInfo_record")
	self.rankList = {}
	self.timeList = {}
	self.cardNameList = {}

	for i = 1, 10 do
		self.rankList[i] = self:GetChildComponent("Main/TextList/line" .. i .. "/Icon", "Image")
		self.timeList[i] = self:GetChildComponent("Main/TextList/line" .. i .. "/Time", "Text")
		self.cardNameList[i] = self:GetChildComponent("Main/TextList/line" .. i .. "/CardName", "Text")
	end

	for i = 1, #self.listPbRecords do
		local data = self.listPbRecords[i]
		local infoCard = RoleCardMgr:GetRoleCard(data.cardId)
		local infoRole = RoleMgr:GetRole(infoCard.data.CharacterID)
		local time = DateTimeUtil.GetCurrentDay(data.OccurTime * DateUtil.MillsPerSecond)
		local strColor = "5f5f5f"

		if infoCard.rank == "ur" then
			strColor = "ff6ebc"

			UIUtil.SetImageOverrideSprite(self.rankList[i], "UIDyAtlas/RoleCardRank/IC_card_logo_UR", self)
			self.rankList[i].gameObject:SetActive(true)
		elseif infoCard.rank == "ssr" then
			strColor = "eeb508"

			UIUtil.SetImageOverrideSprite(self.rankList[i], "UIDyAtlas/RoleCardRank/IC_card_logo_SSR", self)
			self.rankList[i].gameObject:SetActive(true)
		elseif infoCard.rank == "sr" then
			UIUtil.SetImageOverrideSprite(self.rankList[i], "UIDyAtlas/RoleCardRank/IC_card_logo_SR", self)
			self.rankList[i].gameObject:SetActive(true)
		elseif infoCard.rank == "r" then
			UIUtil.SetImageOverrideSprite(self.rankList[i], "UIDyAtlas/RoleCardRank/IC_card_logo_R", self)
			self.rankList[i].gameObject:SetActive(true)
		end

		local strName = "<color=#" .. strColor .. ">" .. infoCard:GetName() .. " - " .. infoRole:GetName() .. "</color>"

		if infoCard.rank == "r" then
			strName = "<color=#" .. strColor .. ">" .. infoCard:GetName() .. "</color>"
		end

		self.cardNameList[i].text = strName
		self.timeList[i].text = time
	end

	if #self.listPbRecords == 0 then
		self.TextListObj:SetActive(false)
	else
		self.TextListObj:SetActive(true)
	end
end

function DlgGetCardRecord:OnRegisterEvent()
	self:AddClick(self.ButtonExit, self.OnButtonExit, PATH_SFX_UI_CANCEL)
end

function DlgGetCardRecord:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonExit, self.OnButtonExit)
end

function DlgGetCardRecord:OnButtonExit()
	self:Close()
end
