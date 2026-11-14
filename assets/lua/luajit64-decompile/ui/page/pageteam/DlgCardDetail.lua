-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTeam/DlgCardDetail.lua

require("UI/Page/PageTeam/SkillDetailItem")

DlgCardDetail = class("DlgCardDetail", UIPanel)

function DlgCardDetail:ctor()
	self.UIPrefabPath = "UI/PanelChooseCard/PanelCardDetail"
end

function DlgCardDetail:PreLoad()
	self.skillDetailItemPreLoad = ResourceMgr.LoadSync("UI/PanelChooseCard/SkillDetailItem")
	self.PrefabCellCardSkill = ResourceMgr.LoadSync("UI/PanelRoleCard/CellCardSkill")
end

function DlgCardDetail:Purge()
	DlgCardDetail.base.Purge(self)

	self.skillDetailItemPreLoad = nil
	self.PrefabCellCardSkill = nil

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end
end

function DlgCardDetail:OnRegisterEvent()
	self:AddClick(self.closeButton, self.OnClickCloseBtn, PATH_SFX_UI_CANCEL)
	self:AddClick(self.upButton, self.OnClickUpBtn)
end

function DlgCardDetail:OnUnRegisterEvent()
	self:RemoveClick(self.closeButton, self.OnClickCloseBtn)
	self:RemoveClick(self.upButton, self.OnClickUpBtn)
end

function DlgCardDetail:OnEnter(vParam)
	self:OnLocalText()

	self.call = vParam.call
	self.infoRoleCard = vParam.infoRoleCard
	self.closeButton = self:GetChildGameObject("panel/btn_close")
	self.upButton = self:GetChildGameObject("panel/upBtn")

	SetActiveFunc(self.upButton, self.call ~= nil)
	self:UpdateCard()

	local ScrollArea = self:GetChildGameObject("panel/scroll/ScrollArea")
	local content = self:GetChildComponent("panel/scroll/ScrollArea/Content", "Transform")
	local count = #self.infoRoleCard.listSkill

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.skillDetailItemPreLoad, SkillDetailItem, self, false)
end

function DlgCardDetail:OnLocalText()
	local TextAuto

	TextAuto = self:GetChildComponent("panel/title/Text/", "Text")
	TextAuto.text = Lang(5000016)
	TextAuto = self:GetChildComponent("panel/upBtn/Text/", "Text")
	TextAuto.text = Lang(5000017)
end

function DlgCardDetail:UpdateCard()
	local infoRole = RoleMgr:GetRole(self.infoRoleCard.data.CharacterID)

	self.CardBg = self:GetChildComponent("panel/cardItem/CardMask/Bg", "RawImage")
	self.CardIcon = self:GetChildComponent("panel/cardItem/CardMask/CardIcon", "RawImage")

	if self.infoRoleCard.data.SpineData ~= "" then
		SetActiveFunc(self.CardBg.gameObject, false)

		self.CardIcon.enabled = false

		local cardSpine = ResourceMgr.LoadSync(self.infoRoleCard.data.SpineData .. "_Anim")

		if cardSpine then
			local spine = GOUtil.InstantiateUIPrefab(cardSpine, self.CardIcon.gameObject)

			if GOUtil.GetComponent(spine, "SpineAspectRatioFitter") then
				GOUtil.GetComponent(spine, "SpineAspectRatioFitter").enabled = false
			end
		else
			SetActiveFunc(self.CardBg.gameObject, true)

			self.CardIcon.enabled = true

			RoleCardMgr:SetInfoPanel(self.infoRoleCard, self.CardIcon, self.CardBg)
		end
	else
		RoleCardMgr:SetInfoPanel(self.infoRoleCard, self.CardIcon, self.CardBg)
	end

	RoleCardMgr:SetCardLocation(self.infoRoleCard, self.CardIcon.gameObject, 2)

	local cardRank = self.infoRoleCard.cardRank

	for i = 1, 4 do
		self["State" .. i] = self:GetChildGameObject("panel/cardItem/Flower/State" .. i)

		SetActiveFunc(self["State" .. i], i == cardRank)
	end

	local flower = self["State" .. cardRank]
	local count = self.infoRoleCard.maxPetal
	local curNum = self.infoRoleCard.curPetal

	for i = 1, count do
		local imgF = GOUtil.FindChildComponent(flower, "" .. i, "Image")
		local isOk = i <= curNum
		local gray = TenaryOp(isOk, 0, 1)

		UIUtil.SetImageGray(imgF, gray)
	end

	self.CardRank = self:GetChildComponent("panel/cardItem/CardRank", "Image")

	UIUtil.SetImageSprite(self.CardRank, "UIDyAtlas/RoleCardRank/ui_hd_card_back_" .. self.infoRoleCard.rank .. "_6")

	self.CardName = self:GetChildComponent("panel/cardItem/CardName", "Text")
	self.CardName.text = self.infoRoleCard:GetName()
	self.CardJob = self:GetChildComponent("panel/cardItem/Job", "Image")

	UIUtil.SetImageSprite(self.CardJob, "UI/PanelChooseCard/AtlasPanelChooseCard/ICO_" .. infoRole.data.Job .. "_01_S")

	self.CardLevel = self:GetChildComponent("panel/cardItem/TxtValue", "Text")
	self.CardLevel.text = self.infoRoleCard.curLevel
	self.GoFrame = self:GetChildGameObject("panel/cardItem/CardStar/Frame")
	self.GoStar1 = self:GetChildGameObject("panel/cardItem/CardStar/Star1")
	self.GoStar2 = self:GetChildGameObject("panel/cardItem/CardStar/Star2")

	RoleCardMgr:SetStar(self.infoRoleCard, self)
end

function DlgCardDetail:OnClickCloseBtn()
	if self.call then
		self.call(0)
		self:Close()
	else
		self:Close()
	end
end

function DlgCardDetail:OnClickUpBtn()
	if self.call then
		self.call(1)
		self:Close()
		InfoSoundEventMgr:LoadBank(RoleMgr:GetRole(self.infoRoleCard.data.CharacterID).data.VocalBank)
		InfoSoundEventMgr:Play("VocalTeam", RoleMgr:GetRole(self.infoRoleCard.data.CharacterID).data.VocalTeam)
	end
end

function DlgCardDetail:UpdateCell(item, index)
	local infoSkill = self.infoRoleCard.listSkill[index]

	item:UpdateData(self.infoRoleCard, infoSkill, self.PrefabCellCardSkill)
end

function DlgCardDetail:AddCellClick(item)
	return
end
