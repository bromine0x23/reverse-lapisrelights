-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Page/DlgCardBloomPanel.lua

require("UI/Page/PageRoleCard/Dlg/DlgCardPetal")

local skillTip = require("UI/Dlg/Common/SkillTipDesc")

DlgCardBloomPanel = class("DlgCardBloomPanel", UIPanel)

function DlgCardBloomPanel:ctor()
	self.UIPrefabPath = "UI/PanelRoleCard/PanelCardBloom"
end

function DlgCardBloomPanel:PreLoad()
	self.PrefabCellCostItem = ResourceMgr.LoadSync("UI/PanelRoleCard/CellCostItem")
end

function DlgCardBloomPanel:Purge()
	self.base.Purge(self)
	self:OnLeave()
end

function DlgCardBloomPanel:OnLeave()
	if self.Item then
		self.Item:OnLeave()
	end

	ResourceMgr.Unload(self.PrefabCellCostItem)
	EffectMgr:UnLoadEffect("Fx/UI/Eff_Ui_PanelRoleCard/FX_DiamondImage")
end

function DlgCardBloomPanel:OnRegisterEvent()
	self:AddClick(self.BtnAward, self.OnClickedBtnAward)
	self:AddClick(self.BtnBloom, self.OnClickedBtnBloom)
	self:AddClick(self.BtnDetail, self.OnClickedBtnDetail)
end

function DlgCardBloomPanel:OnUnRegisterEvent()
	self:RemoveClick(self.BtnAward, self.OnClickedBtnAward)
	self:RemoveClick(self.BtnBloom, self.OnClickedBtnBloom)
	self:RemoveClick(self.BtnDetail, self.OnClickedBtnDetail)
	self:UnRegisterOther()
end

function DlgCardBloomPanel:UnRegisterOther()
	if self.listCellCostItem then
		for i = 1, #self.listCellCostItem do
			self.listCellCostItem[i]:OnLeave()
		end
	end
end

function DlgCardBloomPanel:OnEnter(vParam)
	self:SetSafeArea(self.UIRootObject)
	self:DealWithLocalization()

	self.rankCnt = table.getCount(eRankType)

	for i = 1, self.rankCnt do
		self["State" .. i] = self:GetChildGameObject("Panel/Petal/State/State" .. i)
	end

	self.GoPrompt = self:GetChildGameObject("Panel/Petal/Avatar")
	self.TxtPrompt = GOUtil.FindChildComponent(self.GoPrompt, "Go/Text", "Text")
	self.GoCost = self:GetChildGameObject("Panel/Petal/Cost")
	self.GoCoin = GOUtil.FindChildGameObject(self.GoCost, "BtnUp/Coin")
	self.ImgCoin = GOUtil.FindChildComponent(self.GoCost, "BtnUp/Coin/Icon", "Image")
	self.TxtCoin = GOUtil.FindChildComponent(self.GoCost, "BtnUp/Coin/Text", "Text")
	self.TxtNeed = GOUtil.FindChildComponent(self.GoCost, "TxtNeed", "Text")
	self.TxtLess = GOUtil.FindChildComponent(self.GoCost, "Text", "Text")
	self.GoBloom = self:GetChildGameObject("Panel/Bloom/Bloom")
	self.GoTypeP = GOUtil.FindChildGameObject(self.GoBloom, "Skill/Icon/TypeP")
	self.GoTypeC = GOUtil.FindChildGameObject(self.GoBloom, "Skill/Icon/TypeC")
	self.ImgSkillIcon = GOUtil.FindChildComponent(self.GoBloom, "Skill/Icon/Icon", "Image")
	self.TxtUnlockInfo = GOUtil.FindChildComponent(self.GoBloom, "Skill/Icon/TxtInfo", "Text")
	self.TxtSkillName = GOUtil.FindChildComponent(self.GoBloom, "Skill/TxtName", "Text")
	self.TxtSkillDesc = GOUtil.FindChildComponent(self.GoBloom, "Skill/Scroll/TxtDesc", "Text")
	self.GoFull = self:GetChildGameObject("Panel/Bloom/Full")
	self.BtnAward = self:GetChildGameObject("Panel/Petal/Button")
	self.BtnBloom = self:GetChildGameObject("Panel/Petal/Cost/BtnUp")
	self.ImgBtnBloom = GOUtil.GetComponent(self.BtnBloom, "Image")
	self.BtnDetail = self:GetChildGameObject("Panel/Bloom/Bloom/BtnDetail")

	GOUtil.SetFont(self.TxtSkillDesc, UIMgr.JPFonts.W5)
	self:Init()
	self:InitPanel(vParam)
end

function DlgCardBloomPanel:Init()
	local gItem = self:GetChildGameObject("Panel/Petal/Avatar/Go/Cell")

	self.Item = CellItem(gItem)

	self.Item:InitItemByRoot(gItem)

	local scrollArea = GOUtil.FindChildGameObject(self.GoCost, "ScrollArea")

	self.ScrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")
	self.ScrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "Transform")
	self.ScrollView.horizontal = true
end

function DlgCardBloomPanel:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/Petal/Cost/BtnUp/Text", "Text")
	txt.text = Lang(20014)
	txt = self:GetChildComponent("Panel/Petal/Cost/Text", "Text")
	txt.text = Lang(42180)
	txt = self:GetChildComponent("Panel/Bloom/Bloom/BtnDetail/Text", "Text")
	txt.text = Lang(12345)
	txt = self:GetChildComponent("Panel/Bloom/Full/Text", "Text")
	txt.text = _("Desc_Petal_Full")
end

function DlgCardBloomPanel:InitPanel(data)
	if self.infoRoleCard then
		for i = 1, self.infoRoleCard.maxPetal do
			if self["EffPetal" .. i] then
				EffectMgr:Free(self["EffPetal" .. i])

				self["EffPetal" .. i] = nil
			end
		end
	end

	if not data or not data.infoRoleCard then
		return
	end

	self.infoRoleCard = data.infoRoleCard
	self.maxPetal = self.infoRoleCard.maxPetal

	for i = 1, self.rankCnt do
		GOUtil.SetActive(self["State" .. i], i == self.infoRoleCard.cardRank)
	end

	self.GoState = self["State" .. self.infoRoleCard.cardRank]

	self:UpdatePanel()
	self:UpdateDot()
end

function DlgCardBloomPanel:Show()
	GOUtil.SetActive(self.UIRootObject, true)
end

function DlgCardBloomPanel:Hide()
	GOUtil.SetActive(self.UIRootObject, false)
end

function DlgCardBloomPanel:UpdatePanel()
	self.curPetal = self.infoRoleCard.curPetal
	self.isMaxPetal = self.curPetal >= self.maxPetal

	for i = 1, self.maxPetal do
		local imgPetal = GOUtil.FindChildComponent(self.GoState, "" .. i, "Image")

		if i <= self.curPetal then
			imgPetal.enabled = false

			if not self["EffPetal" .. i] then
				local actPetal = GOUtil.FindChildComponent(self.GoState, "" .. i .. "/Image", "Image")

				self["EffPetal" .. i] = EffectMgr:Alloc("Fx/UI/Eff_Ui_PanelRoleCard/FX_DiamondImage", actPetal, true)
			end
		else
			imgPetal.enabled = true
		end
	end

	GOUtil.SetActive(self.GoFull, self.isMaxPetal)
	GOUtil.SetActive(self.GoCost, not self.isMaxPetal)
	GOUtil.SetActive(self.GoBloom, not self.isMaxPetal)

	if not self.isMaxPetal then
		self:UpdateUpCost()
		self:UpdateUpSkill()
	end

	self:UpdateSpecial()
end

function DlgCardBloomPanel:UpdateUpSkill()
	local listResult = self.infoRoleCard.data.FlowerSkill
	local skillId = listResult[self.curPetal + 1][1]
	local targetLv = listResult[self.curPetal + 1][2]

	if skillId then
		local infoSkill = TalentManager:Get(skillId)

		self.PetalSkill = infoSkill

		UIUtil.SetImageSprite(self.ImgSkillIcon, "UIDyAtlas/Skill/" .. infoSkill.data.Icon, self)

		self.TxtUnlockInfo.text = Lang(12004) .. targetLv
		self.TxtSkillName.text = Lang(infoSkill.data.Name)

		local upLevel = listResult[self.curPetal + 1][2]

		self.TxtSkillDesc.text = skillTip.GetDesc(infoSkill.id, upLevel, 0)

		local battleType = infoSkill.data.BattleSkillType

		GOUtil.SetActive(self.GoTypeP, battleType == 2)
		GOUtil.SetActive(self.GoTypeC, battleType == 3)
	end
end

function DlgCardBloomPanel:UpdateSpecial()
	local isNeed = false
	local listAward = RoleCardMgr:GetAward(self.infoRoleCard, 2)

	for k, v in ipairs(listAward) do
		local index = v.index
		local isGeted = self.infoRoleCard:IsGetPetalReward(index)

		if not isGeted then
			for n, info in ipairs(v.award) do
				if info.data.Type == "R_AVATAR" then
					self.Item:UpdateWithNumType(info)

					self.TxtPrompt.text = string.format(_("Desc_Petal_Get"), _("ecNum_" .. k))
					isNeed = true

					break
				end
			end
		end
	end

	GOUtil.SetActive(self.GoPrompt, isNeed)
end

function DlgCardBloomPanel:UpdateUpCost()
	self.listCostItem, self.listCostCoin = RoleCardMgr:GetNextUpCost(self.infoRoleCard, 2)

	if self.infoRoleCard.cardRank == eRankType.UR then
		local infoCommSoul = ItemManager:GetItemByType("I_SOUL_COMMON")

		table.insert(self.listCostItem, {
			infoCommSoul.id,
			0
		})
	end

	self.listCellCostItem = self.listCellCostItem or {}

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
	self:UpdateCost()
end

function DlgCardBloomPanel:UpdateCost()
	self:UpdateCostItem()
	self:UpdateCostCoin()

	if not self.isItemEnough then
		self.TxtLess.text = Lang(42180)
	elseif not isCoinEnough then
		local coinId = self.listCostCoin[1][1]

		self.TxtLess.text = string.format(_("Develop_Cost_Not_Enough"), ItemManager:Get(coinId):GetName())
	end

	local isEnough = self.isItemEnough and self.isCoinEnough

	GOUtil.SetActive(self.TxtLess, not isEnough)

	local gray = TenaryOp(isEnough, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnBloom, gray))
end

function DlgCardBloomPanel:UpdateCostItem()
	if self.isMaxPetal then
		return
	end

	local infoCommSoul

	self.needCommSoul = 0

	local isUR = self.infoRoleCard.cardRank == eRankType.UR
	local hideNeed = false

	if isUR then
		hideNeed = true
		infoCommSoul = ItemManager:GetItemByType("I_SOUL_COMMON")
	end

	local needSumCnt = 0
	local isItemEnough = true

	for k, v in ipairs(self.listCellCostItem) do
		if k <= #self.listCostItem then
			local id = self.listCostItem[k][1]

			if id ~= nil then
				local holdCnt = ItemManager:GetItemCount(id)
				local data = {}

				data.info = ItemManager:GetValueItem(id, holdCnt)
				data.hideNeed = hideNeed
				data.showPrompt = true

				local needCnt = 0

				if isUR then
					if id == infoCommSoul.id then
						needCnt = self.needCommSoul
					else
						needCnt = self.listCostItem[k][2] or 0
						needSumCnt = needSumCnt + needCnt

						if holdCnt < needCnt then
							local extraNeed = needCnt - holdCnt
							local holdCommCnt = infoCommSoul:GetCurResNum() - self.needCommSoul

							if holdCommCnt > 0 and extraNeed <= holdCommCnt then
								needCnt = holdCnt
							else
								isItemEnough = false
							end

							self.needCommSoul = self.needCommSoul + extraNeed
						end
					end
				else
					needCnt = self.listCostItem[k][2] or 0

					if holdCnt < needCnt then
						isItemEnough = false
					end

					needSumCnt = needSumCnt + needCnt
				end

				data.needNum = needCnt

				v:UpdateData(data)
			end
		end
	end

	GOUtil.SetActive(self.TxtNeed, isUR)

	if isUR then
		if self.isItemEnough ~= isItemEnough then
			local strColor = "585E62"

			if not isItemEnough then
				strColor = "FF0000"
			end

			local col = sixNumToRGB(strColor)

			UIUtil.SetGraphicColorRGB(self.TxtNeed, col.r / 255, col.g / 255, col.b / 255)
		end

		self.TxtNeed.text = _("Desc_Need") .. "：" .. needSumCnt
	end

	self.isItemEnough = isItemEnough
end

function DlgCardBloomPanel:UpdateCostCoin()
	if self.isMaxPetal then
		return
	end

	self.isCoinEnough = true

	if self.needCoin then
		local coinId = self.listCostCoin[1][1]
		local needNum = self.listCostCoin[1][2]
		local infoCoin = ItemManager:Get(coinId)

		SetImageSprite(self.ImgCoin, infoCoin:GetIcon(), self)

		self.isCoinEnough = ItemManager:IsItemHoldEnough(coinId, needNum, true)

		if not self.isCoinEnough then
			self.TxtCoin.text = "<color=red>" .. needNum .. "</color>"
		else
			self.TxtCoin.text = "<color=#585E62>" .. needNum .. "</color>"
		end
	end
end

function DlgCardBloomPanel:OnClickedBtnAward()
	local data = {
		type = 2,
		title = _("Card_Bloom_Award"),
		infoRoleCard = self.infoRoleCard
	}

	UIMgr.AddPanel(DlgCardUpAward(), data)
end

function DlgCardBloomPanel:OnClickedBtnDetail()
	local data = {
		infoRoleCard = self.infoRoleCard
	}

	UIMgr.AddPanel(DlgCardPetal(), data)
end

function DlgCardBloomPanel:OnClickedBtnBloom()
	local canUp = false

	if self.isItemEnough and self.isCoinEnough then
		canUp = true
	end

	local lessItemId

	if self.isItemEnough and not self.isCoinEnough then
		lessItemId = self.listCostCoin[1][1]
	end

	local data = {
		type = 2,
		title = Lang(2004),
		infoRoleCard = self.infoRoleCard,
		canUp = canUp,
		lessItemId = lessItemId
	}

	if canUp then
		local list = {}
		local infoCommSoul = ItemManager:GetItemByType("I_SOUL_COMMON")

		for _, v in ipairs(self.listCostItem) do
			if v[1] ~= infoCommSoul.id then
				table.insert(list, v[1])

				local holdCnt = ItemManager:GetItemCount(v[1])
				local num = holdCnt > v[2] and v[2] or holdCnt

				table.insert(list, num)
			end
		end

		if self.needCommSoul > 0 then
			table.insert(list, infoCommSoul.id)
			table.insert(list, self.needCommSoul)
		end

		data.costList = list
		data.extraCommNum = self.needCommSoul
	end

	UIMgr.AddPanel(DlgCardUpPreview(), data)
end

function DlgCardBloomPanel:UpdateDot()
	RedDotSystemMgr.SetUIRedDot(self.BtnBloom, "Bloom/" .. self.infoRoleCard.id)
end
