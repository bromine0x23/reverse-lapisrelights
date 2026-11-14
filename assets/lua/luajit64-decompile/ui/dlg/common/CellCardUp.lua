-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/CellCardUp.lua

require("UI/Item/UIItemBase")

CellCardUp = class("CellCardUp", UIItemBase)

function CellCardUp:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellCardUp:Create(vParam)
	CellCardUp.base.Create(self, vParam)
end

function CellCardUp:OnEnter(vParam)
	local g = self.UIRootObject

	self.IsLimit = false
	self.GoEffect = GOUtil.FindChildGameObject(g, "Effect")
	self.TxtCardLevel = GOUtil.FindChildComponent(g, "Panel/battleGo/txt_level", "Text")
	self.TxtStarLevel = GOUtil.FindChildComponent(g, "Panel/battleGo/star_lv/txt", "Text")
	self.TxtRoleName = GOUtil.FindChildComponent(g, "Panel/battleGo/bg_role/Text", "Text")
	self.CardIcon = GOUtil.FindChildComponent(g, "Panel/bg_mask/img_card", "Image")
	self.CardRank = GOUtil.FindChildComponent(g, "Panel/img_rank", "Image")
	self.RoleJob = GOUtil.FindChildComponent(g, "Panel/img_job", "Image")
	self.ImgExpBar = GOUtil.FindChildComponent(g, "Panel/battleGo/bg_bar/img_fill", "Image")
	self.CardExp = self.ImgExpBar.transform
	self.battleGo = GOUtil.FindChildGameObject(g, "Panel/battleGo")
	self.Go_help_battle = GOUtil.FindChildGameObject(g, "Panel/Go_help_battle")
	self.Tex_help_battle = GOUtil.FindChildComponent(g, "Panel/Go_help_battle/Tex_help_battle", "Text")
	self.GoFrame = self:GetChildGameObject("Panel/battleGo/StarLevel/Frame")
	self.GoStar1 = self:GetChildGameObject("Panel/battleGo/StarLevel/Star1")
	self.GoStar2 = self:GetChildGameObject("Panel/battleGo/StarLevel/Star2")

	for i = 1, 5 do
		self["ImageStarFrame" .. i] = GOUtil.FindChildGameObject(g, "Panel/battleGo/StarLevel/Frame/" .. i)
		self["ImageStar" .. i] = GOUtil.FindChildGameObject(g, "Panel/battleGo/StarLevel/Star2/" .. i)
	end

	self.TxtAddExp = GOUtil.FindChildComponent(g, "TxtAddExp", "Text")
	self.TxtAddExp.text = ""
	self.AddExpValue = 0
	self.TxtCardLevel.fontSize = 18
end

function CellCardUpEventAnim()
	return
end

function CellCardUp:SetAddExpText(val)
	if not val or type(val) ~= "number" then
		return
	end

	if self.IsLimit == true then
		self.TxtAddExp.text = ""
	else
		self.AddExpValue = val

		if val ~= 0 then
			self.TxtAddExp.text = string.format("+%d", val)
		end
	end
end

function CellCardUp:OnLeave()
	if self.Timer then
		TimerMgr.RemoveTimer(self.Timer)
	end

	if self.Timer2 then
		TimerMgr.RemoveTimer(self.Timer2)

		self.Timer2 = nil
	end

	if self.Timer3 then
		TimerMgr.RemoveTimer(self.Timer3)

		self.Timer3 = nil
	end

	if self.Timer4 then
		TimerMgr.RemoveTimer(self.Timer4)

		self.Timer4 = nil
	end

	UnloadAllImageSprite(self)

	self.TxtCardLevel = nil
	self.TxtStarLevel = nil
	self.TxtRoleName = nil
	self.CardIcon = nil
	self.CardRank = nil
	self.RoleJob = nil
	self.CardExp = nil

	EffectMgr:UnLoadEffect("Fx/UI/FX_UI_LevelUp/FX_UI_LevelUp")
end

function CellCardUp:UpdateData(id, pbPlayer, listFirst, CharacterFavor, index)
	if pbPlayer then
		self.battleGo:SetActive(false)
		self.Go_help_battle:SetActive(true)

		self.Tex_help_battle.text = pbPlayer.nickname
		self.infoRoleCard = RoleCardMgr:GetRoleCard(id)

		UIUtil.SetImageSprite(self.CardIcon, self.infoRoleCard.data.MidIcon)
		UIUtil.SetImageSprite(self.CardRank, "UIDyAtlas/RoleCardRank/BG_card_back_" .. self.infoRoleCard.rank .. "_11")

		local roleId = RoleCardMgr:GetRoleId(id)
		local infoRole = RoleMgr:GetRole(roleId)

		UIUtil.SetImageSprite(self.RoleJob, "UIDyAtlas/RoleJob/ICO_" .. infoRole.data.Job .. "_01_S")

		return
	end

	self.roleCardId = id

	if index == 3 then
		self.roleCardCid = id
	end

	self.infoRoleCard = RoleCardMgr:GetRoleCard(id)

	self.infoRoleCard:UpdateAll()
	UIUtil.SetImageSprite(self.CardIcon, self.infoRoleCard.data.MidIcon)
	UIUtil.SetImageSprite(self.CardRank, "UIDyAtlas/RoleCardRank/BG_card_back_" .. self.infoRoleCard.rank .. "_11")

	local roleId = RoleCardMgr:GetRoleId(id)
	local infoRole = RoleMgr:GetRole(roleId)

	UIUtil.SetImageSprite(self.RoleJob, "UIDyAtlas/RoleJob/ICO_" .. infoRole.data.Job .. "_01_S")

	self.TxtRoleName.text = infoRole:GetName()

	RoleCardMgr:SetStar(self.infoRoleCard, self)

	self.TxtStarLevel.text = self.infoRoleCard.curStarLevel
	self.TxtCardLevel.text = self.infoRoleCard.preLevel

	local limitLv = self.infoRoleCard.curLimitLevel

	if limitLv and type(limitLv) == "number" then
		self.IsLimit = limitLv <= self.infoRoleCard.preLevel
	end

	self:UpdateExpBar(self.infoRoleCard, listFirst, CharacterFavor)
end

function CellCardUp:DoTweenCardExp(preRate, duration)
	if preRate and type(preRate) == "number" then
		if preRate > 1 then
			preRate = 1
		end

		return GOUtil.DOScale(self.CardExp, preRate, duration)
	end

	return nil
end

function CellCardUp:UpdateExpBar(infoRoleCard, listFirst, CharacterFavor)
	local timer2 = 0

	if infoRoleCard.curLevel > infoRoleCard.preLevel then
		timer2 = 0.5
	end

	local function favorFunc(...)
		local timer3 = 0

		if listFirst or #listFirst > 0 then
			timer3 = 0.5
		end

		self.Timer2 = TimerMgr.AddTimer(eTimerType.RealTime, timer2 + 0.5, function()
			if (listFirst or #listFirst > 0) and #listFirst > 0 and CharacterFavor > 0 and not IsNil(self.UIRootObject) then
				if not IsNil(self:GetChildGameObject("Panel/img_Favor")) then
					self:GetChildGameObject("Panel/img_Favor"):SetActive(true)
				end

				local IntValue = 0
				local info, count = ShopManager:GetGoodsMonthPrivilegeFuncInfo(13)

				if #info ~= 0 then
					IntValue = count / 100
				end

				self:GetChildComponent("Panel/img_Favor/Text", "Text").text = _("Friendliness") .. " +" .. CharacterFavor + IntValue * CharacterFavor
			end
		end, nil)

		local timer4 = 3

		self.Timer3 = TimerMgr.AddTimer(eTimerType.RealTime, timer3 + timer2 + 0.5, function()
			if listFirst and #listFirst > 0 then
				local giftItemValue = {}

				giftItemValue.id = 99999
				giftItemValue.count = 1
				giftItemValue.expOne = tonumber(CharacterFavor)

				local addLevelList = LevelManager:GetPreviewProgress(RoleCardMgr:GetRole(self.roleCardId), {
					giftItemValue
				}, RoleCardMgr:GetRole(self.roleCardId).preFavorLevel)

				if addLevelList and addLevelList[3] > 0 and not IsNil(self.UIRootObject) then
					if not IsNil(self:GetChildGameObject("Panel/img_Favor")) then
						self:GetChildGameObject("Panel/img_Favor"):SetActive(false)
					end

					if not IsNil(self:GetChildGameObject("Panel/img_FavorLevel")) then
						self:GetChildGameObject("Panel/img_FavorLevel"):SetActive(true)
					end
				end
			end
		end, nil)
		self.Timer4 = TimerMgr.AddTimer(eTimerType.RealTime, timer3 + timer2 + timer4 + 0.5, function()
			if not IsNil(self.UIRootObject) then
				if not IsNil(self:GetChildGameObject("Panel/img_Favor")) then
					self:GetChildGameObject("Panel/img_Favor"):SetActive(false)
				end

				if not IsNil(self:GetChildGameObject("Panel/img_FavorLevel")) then
					self:GetChildGameObject("Panel/img_FavorLevel"):SetActive(false)
				end
			end
		end, nil)
	end

	if self.IsLimit == true then
		self:DoTweenCardExp(0, 0)

		local timer2 = 0

		favorFunc()

		return
	end

	local preRate = infoRoleCard.preExp / infoRoleCard.preNextExp

	if infoRoleCard.preNextExp == 0 then
		preRate = 0
	end

	local curRate = infoRoleCard.curExp / infoRoleCard.nextExp

	if self.AddExpValue ~= 0 then
		self:DoTweenCardExp(preRate, 0)
	else
		self.CardExp.localScale = Vector3(curRate, 1, 1)
	end

	if self.AddExpValue == 0 then
		self.TxtCardLevel.text = infoRoleCard.curLevel
	end

	self.Timer = TimerMgr.AddTimer(eTimerType.RealTime, 0.5, function()
		if infoRoleCard.curLevel > infoRoleCard.preLevel and self.AddExpValue ~= 0 then
			local tween = self:DoTweenCardExp(1, 1)

			local function wrap_cb(...)
				self:DoTweenCardExp(0, 0)
				self:DoTweenCardExp(curRate, 0.5)

				self.TxtCardLevel.text = infoRoleCard.curLevel

				EffectMgr:Alloc("Fx/UI/FX_UI_LevelUp/FX_UI_LevelUp", self.GoEffect, true, 1)
			end

			GOUtil.SetTweenerCallback(tween, wrap_cb)
		elseif self.AddExpValue ~= 0 then
			GOUtil.DOScale(self.CardExp, curRate, 1)
		end
	end, nil)

	favorFunc()
end

function CellCardUp:UpdateExpBarNow()
	local id = self.roleCardId

	if not id then
		return
	end

	if self.Timer then
		TimerMgr.RemoveTimer(self.Timer)

		self.Timer = nil
	end

	if self.Timer2 then
		TimerMgr.RemoveTimer(self.Timer2)

		self.Timer2 = nil
	end

	if self.Timer3 then
		TimerMgr.RemoveTimer(self.Timer3)

		self.Timer3 = nil
	end

	if self.Timer4 then
		TimerMgr.RemoveTimer(self.Timer4)

		self.Timer4 = nil
	end

	GOUtil.DestroyAllChildren(self.GoEffect)

	local infoRoleCard = RoleCardMgr:GetRoleCard(id)

	UIUtil.SetImageSprite(self.CardIcon, infoRoleCard.data.MidIcon)
	UIUtil.SetImageSprite(self.CardRank, "UIDyAtlas/RoleCardRank/BG_card_back_" .. infoRoleCard.rank .. "_11")

	local roleId = RoleCardMgr:GetRoleId(id)
	local infoRole = RoleMgr:GetRole(roleId)

	UIUtil.SetImageSprite(self.RoleJob, "UIDyAtlas/RoleJob/ICO_" .. infoRole.data.Job .. "_01_S")

	self.TxtRoleName.text = infoRole:GetName()

	RoleCardMgr:SetStarPanel(infoRoleCard, self, self)

	self.TxtStarLevel.text = infoRoleCard.curStarLevel
	self.TxtCardLevel.text = infoRoleCard.curLevel

	local curNum = Tenary(infoRoleCard.curExp, 0)
	local nextExp = Tenary(infoRoleCard.nextExp, 0)

	if nextExp ~= 0 then
		self.ImgExpBar.fillAmount = curNum / infoRoleCard.nextExp
	else
		self.ImgExpBar.fillAmount = 0
	end
end
