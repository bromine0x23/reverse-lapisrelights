-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Page/DlgCardBreakoutPanel.lua

local skillTip = require("UI/Dlg/Common/SkillTipDesc")

DlgCardBreakoutPanel = class("DlgCardBreakoutPanel", UIPanel)

function DlgCardBreakoutPanel:ctor()
	self.UIPrefabPath = "UI/PanelRoleCard/PanelCardBreakout"
	self.playEnd = true
end

function DlgCardBreakoutPanel:PreLoad()
	self:LoadResAsync("UI/PanelRoleCard/CellCostItem", "PrefabCellCostItem", GameObject)

	self.EffGlowPath = "Fx/UI/FX_RectMask_Glow/FX_RectMask_Glow01"
end

function DlgCardBreakoutPanel:Purge()
	self.base.Purge(self)
	self:OnLeave()
end

function DlgCardBreakoutPanel:OnLeave()
	ResourceMgr.Unload(self.PrefabCellCostItem)

	if self.listCellCostItem then
		for i = 1, #self.listCellCostItem do
			self.listCellCostItem[i]:OnLeave()
		end

		self.listCellCostItem = nil
	end

	self:ClearTimer()
	EffectMgr:UnLoadEffect(self.EffGlowPath)
end

function DlgCardBreakoutPanel:ClearTimer()
	if self.timer then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end

	if self.timer2 then
		TimerMgr.RemoveTimer(self.timer2)

		self.timer2 = nil
	end
end

function DlgCardBreakoutPanel:OnRegisterEvent()
	self:AddClick(self.BtnAward, self.OnClickedBtnAward)
	self:AddClick(self.BtnBreak, self.OnClickedBtnBreak)
	self:AddClick(self.GoUnlockSkill, self.OnLongPressUnlockSkill)
	Event.Instance:Add("CardStarLevelUp", self.UpdatePanel, self)
end

function DlgCardBreakoutPanel:OnUnRegisterEvent()
	self:RemoveClick(self.BtnAward, self.OnClickedBtnAward)
	self:RemoveClick(self.BtnBreak, self.OnClickedBtnBreak)
	self:RemoveClick(self.GoUnlockSkill, self.OnLongPressUnlockSkill)
	Event.Instance:Remove("CardStarLevelUp", self.UpdatePanel, self)
end

function DlgCardBreakoutPanel:UnRegisterOther()
	if self.listCellCostItem then
		for i = 1, #self.listCellCostItem do
			self.listCellCostItem[i]:OnLeave()
		end

		GOUtil.DestroyAllChildren(self.ScrollView.content.gameObject)
	end
end

function DlgCardBreakoutPanel:OnEnter(vParam)
	self:SetSafeArea(self.UIRootObject)
	self:DealWithLocalization()

	self.GoComGroup = self:GetChildGameObject("Panel/Star/RectMask/Group1")
	self.GoAdvGroup = self:GetChildGameObject("Panel/Star/RectMask/Group2")

	for i = 1, 5 do
		self["ImgComBgStar" .. i] = self:GetChildComponent("Panel/Star/RectMask/Group1/Group/" .. i, "Image")
		self["ImgAdvBgStar" .. i] = self:GetChildComponent("Panel/Star/RectMask/Group2/Group/" .. i, "Image")
		self["GoComFrame" .. i] = self:GetChildGameObject("Panel/Star/RectMask/Group1/Group/" .. i .. "/Image1")
		self["GoAdvFrame" .. i] = self:GetChildGameObject("Panel/Star/RectMask/Group2/Group/" .. i .. "/Image1")
		self["GoComStar" .. i] = self:GetChildGameObject("Panel/Star/RectMask/Group1/Group/" .. i .. "/Image2")
		self["GoAdvStar" .. i] = self:GetChildGameObject("Panel/Star/RectMask/Group2/Group/" .. i .. "/Image2")
	end

	self.GoUnlockSkill = self:GetChildGameObject("Panel/Star/Skill")
	self.GoCost = self:GetChildGameObject("Panel/Break/Cost")
	self.GoCoin = GOUtil.FindChildGameObject(self.GoCost, "GoCost/Coin")
	self.GoMatLess = GOUtil.FindChildGameObject(self.GoCost, "GoCost/Text")
	self.GoFull = self:GetChildGameObject("Panel/Break/Full")
	self.FX_Glow = self:GetChildGameObject("Panel/Star/RectMask/Group1/FX_Glow")
	self.Anim = self:GetChildComponent("Panel/Star/RectMask/Group1", "Animator")
	self.BtnAward = self:GetChildGameObject("Panel/Star/BtnAward")
	self.BtnBreak = GOUtil.FindChildGameObject(self.GoCost, "GoCost/BtnUp")
	self.ImgBtnBreak = GOUtil.GetComponent(self.BtnBreak, "Image")

	self:Init()
	self:InitPanel(vParam)
end

function DlgCardBreakoutPanel:Init()
	local scrollArea = self:GetChildGameObject("Panel/Break/Cost/GoCost/ScrollArea")

	self.ScrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")
	self.ScrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "Transform")
	self.ScrollView.horizontal = true
end

function DlgCardBreakoutPanel:DealWithLocalization()
	local Text

	Text = self:GetChildComponent("Panel/Break/Cost/Title/Text", "Text")
	Text.text = Lang(42179)
	Text = self:GetChildComponent("Panel/Break/Cost/GoCost/BtnUp/Text", "Text")
	Text.text = Lang(12261)
	Text = self:GetChildComponent("Panel/Break/Cost/GoCost/Text", "Text")
	Text.text = Lang(42180)
	self.TextFull = self:GetChildComponent("Panel/Break/Full/Text", "Text")
	self.TextFull.text = _("Desc_Star_Full")
end

function DlgCardBreakoutPanel:Show()
	if not self.playEnd then
		self:UpdateCardStarInfo(true)
	end

	GOUtil.SetActive(self.UIRootObject, true)
end

function DlgCardBreakoutPanel:Hide()
	self:ClearTimer()
	GOUtil.SetActive(self.UIRootObject, false)
end

function DlgCardBreakoutPanel:InitPanel(data)
	if not data or not data.infoRoleCard then
		return
	end

	self.infoRoleCard = data.infoRoleCard
	self.maxStarLevel = self.infoRoleCard.maxStarLevel

	if self.Anim.isActiveAndEnabled then
		self.Anim:Play("Group1_Ani_Idle")
	end

	self:UpdateDot()
	self:UpdatePanel(true)
end

function DlgCardBreakoutPanel:UpdatePanel(isInit)
	self.curStarLevel = self.infoRoleCard.curStarLevel
	self.isMaxStar = self.curStarLevel >= self.maxStarLevel

	self:UpdateCardStarInfo(isInit)

	if not self.isMaxStar then
		self:UpdateUpCost()
		self:UpdateUnlock()
	else
		GOUtil.SetActive(self.GoUnlockSkill, false)
	end
end

function DlgCardBreakoutPanel:UpdateCardStarInfo(isInit)
	local half = math.floor(self.infoRoleCard.maxStarLevel / 2 <= 5 and 5 or self.infoRoleCard.maxStarLevel / 2)

	local function fun1()
		GOUtil.SetActive(self.GoComGroup, self.curStarLevel <= half)
		GOUtil.SetActive(self.GoAdvGroup, self.curStarLevel > half)
	end

	local function fun2()
		for i = 1, half do
			if self.curStarLevel <= half then
				GOUtil.SetActive(self["GoComStar" .. i], i <= self.curStarLevel)
				GOUtil.SetActive(self["GoComFrame" .. i], i > self.curStarLevel)

				self["ImgComBgStar" .. i].enabled = i <= self.curStarLevel
			else
				GOUtil.SetActive(self["GoAdvStar" .. i], i <= self.curStarLevel - half)
				GOUtil.SetActive(self["GoAdvFrame" .. i], i > self.curStarLevel - half)

				self["ImgAdvBgStar" .. i].enabled = i <= self.curStarLevel - half
			end
		end
	end

	local function AllocEfect()
		local go

		if self.curStarLevel ~= 0 then
			if self.curStarLevel <= half then
				go = self["ImgComBgStar" .. self.curStarLevel].gameObject
			else
				go = self["ImgAdvBgStar" .. self.curStarLevel - half].gameObject
			end
		end

		if not IsNil(go) then
			EffectMgr:Alloc(self.EffGlowPath, go, false, 0.7)

			self.timer2 = TimerMgr.AddTimer(eTimerType.RealTime, 0.7, function()
				fun2()

				self.playEnd = true
			end, nil)
		end
	end

	if half < self.curStarLevel and half >= self.curStarLevel - 1 then
		if not isInit then
			self.playEnd = false

			if self.Anim.isActiveAndEnabled then
				self.Anim:Play("Group1_Ain")
			end

			self.timer = TimerMgr.AddTimer(eTimerType.RealTime, 0.6, function()
				fun1()
				AllocEfect()
			end, nil)
		else
			fun1()
			fun2()
		end
	else
		fun1()

		if not isInit then
			self.playEnd = false

			AllocEfect()
		else
			fun2()
		end
	end

	GOUtil.SetActive(self.GoCost, not self.isMaxStar)
	GOUtil.SetActive(self.GoFull, self.isMaxStar)

	if self.isMaxStar and self.curStarLevel ~= GetConfigArgInt("StarMaxLevel") then
		self.TextFull.text = _("Desc_Close_Follow_Up")
	end
end

function DlgCardBreakoutPanel:UpdateUpCost()
	self.listCellCostItem = self.listCellCostItem or {}
	self.listCostItem, self.listCostCoin = RoleCardMgr:GetNextUpCost(self.infoRoleCard, 1)

	local oldCnt = #self.listCellCostItem
	local newCnt = #self.listCostItem

	if oldCnt <= newCnt then
		for i = 1, newCnt do
			if i <= oldCnt then
				GOUtil.SetActive(self.listCellCostItem[i].UIRootObject, true)
			else
				local item = CellCostItem(self.PrefabCellCostItem, self.ScrollView.content.gameObject, self)

				item:Create()
				table.insert(self.listCellCostItem, item)
			end
		end
	else
		for i = 1, oldCnt do
			if newCnt < i then
				GOUtil.SetActive(self.listCellCostItem[i].UIRootObject, false)
			else
				GOUtil.SetActive(self.listCellCostItem[i].UIRootObject, true)
			end
		end
	end

	self.needCoin = self.listCostCoin[1] ~= nil and self.listCostCoin[1][1] ~= nil

	GOUtil.SetActive(self.GoCoin, self.needCoin)
	self:UpdateCostItem()
end

function DlgCardBreakoutPanel:UpdateCostItem()
	if self.isMaxStar then
		return
	end

	local isItemEnough = true

	for i = 1, #self.listCellCostItem do
		if i <= #self.listCostItem then
			local item = self.listCellCostItem[i]
			local num = ItemManager:GetItemCount(self.listCostItem[i][1])
			local info = ItemManager:GetValueItem(self.listCostItem[i][1], num)
			local data = {
				showPrompt = true,
				info = info,
				needNum = self.listCostItem[i][2]
			}

			item:UpdateData(data)

			isItemEnough = isItemEnough and ItemManager:IsItemHoldEnough(self.listCostItem[i][1], self.listCostItem[i][2], true)
		end
	end

	local isCoinEnough = true

	if self.needCoin then
		isCoinEnough = ItemManager:IsItemHoldEnough(self.listCostCoin[1][1], self.listCostCoin[1][2], true)

		local infoCoin = ItemManager:Get(self.listCostCoin[1][1])
		local imgCoin = self:GetChildComponent(self.GoCoin, "Icon", "Image")
		local txtCoin = self:GetChildComponent(self.GoCoin, "Text", "Text")

		SetImageSprite(imgCoin, infoCoin:GetIcon(), self)

		if not isCoinEnough then
			txtCoin.text = "<color=red>" .. costGold .. "</color>"
		else
			txtCoin.text = "<color=#3C3C3C>" .. costGold .. "</color>"
		end
	end

	local isEnough = isItemEnough and isCoinEnough

	GOUtil.SetActive(self.GoMatLess, not isEnough)

	local gray = TenaryOp(isEnough, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnBreak, gray))
end

function DlgCardBreakoutPanel:UpdateUnlock()
	self.UnlockSkill = nil

	local idx = self.curStarLevel + 1 + 1

	for i = idx, self.maxStarLevel + 1 do
		local unlockIds = self.infoRoleCard.data.StarTalent[i] or {}

		if #unlockIds > 0 then
			local info = TalentManager:Get(unlockIds[1])
			local icon = GOUtil.FindChildComponent(self.GoUnlockSkill, "Icon", "Image")
			local name = GOUtil.FindChildComponent(self.GoUnlockSkill, "BgName/Text", "Text")

			name.text = string.format(Lang(12067), _("ecNum_" .. i - 1))

			UIUtil.SetImageSprite(icon, "UIDyAtlas/Skill/" .. info.data.Icon, self)

			local goSpecial = GOUtil.FindChildGameObject(self.GoUnlockSkill, "ImgS")

			GOUtil.SetActive(goSpecial, info.data.BattleSkillType == eBattleTalentType.SpecialBall)

			self.UnlockSkill = info

			break
		end
	end

	GOUtil.SetActive(self.GoUnlockSkill, self.UnlockSkill ~= nil)
end

function DlgCardBreakoutPanel:OnLongPressUnlockSkill(data)
	if self.UnlockSkill then
		local tipData

		if self.UnlockSkill.data.BattleSkillType == eBattleTalentType.SpecialBall then
			local _, ballType = RoleCardMgr:GetRoleCardSpecialBall(self.infoRoleCard)
			local posX = GOUtil.GetScreenPosX(self.GoUnlockSkill.gameObject)
			local posY = GOUtil.GetScreenPosY(self.GoUnlockSkill.gameObject)

			tipData = SkillTip.GetBallData(Vector3.New(posX, posY, 0), self.UnlockSkill.id, ballType, false)
		else
			local level = self.infoRoleCard:GetTalentLevel(self.UnlockSkill.id)
			local posX = GOUtil.GetScreenPosX(self.GoUnlockSkill.gameObject)
			local posY = GOUtil.GetScreenPosY(self.GoUnlockSkill.gameObject)

			tipData = SkillTip.GetHeroData(Vector3.New(posX, posY, 0), self.UnlockSkill.id, level, 0, false)
		end

		UIMgr.ShowSkillTip(tipData)
	end
end

function DlgCardBreakoutPanel:OnClickedBtnAward()
	local data = {
		type = 1,
		title = _("PanelCard_Star_Award"),
		infoRoleCard = self.infoRoleCard
	}

	UIMgr.AddPanel(DlgCardUpAward(), data)
end

function DlgCardBreakoutPanel:OnClickedBtnBreak()
	local canUp = RoleCardMgr:CanUpStar(self.infoRoleCard)
	local data = {
		type = 1,
		title = Lang(2003),
		infoRoleCard = self.infoRoleCard,
		canUp = canUp
	}

	UIMgr.AddPanel(DlgCardUpPreview(), data)
end

function DlgCardBreakoutPanel:UpdateDot()
	RedDotSystemMgr.SetUIRedDot(self.BtnBreak, "Break/" .. self.infoRoleCard.id)
end
