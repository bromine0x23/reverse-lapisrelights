-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Dlg/DlgCardUpPreview.lua

require("UI/Page/PageRoleCard/Dlg/DlgUnlockSkill")

local skillTip = require("UI/Dlg/Common/SkillTipDesc")

DlgCardUpPreview = class("DlgCardUpPreview", UIPanel)

function DlgCardUpPreview:ctor()
	self.UIPrefabPath = "UI/PanelRoleCard/DlgCardUpPreview"
end

function DlgCardUpPreview:Purge()
	self.base.Purge(self)
	InfoSoundEventMgr:OnBack()
end

function DlgCardUpPreview:OnRegisterEvent()
	self:AddClick(self.BtnSure, self.OnClickedBtnSure)
	self:AddClick(self.BtnClose, self.OnClickedBtnClose)
end

function DlgCardUpPreview:OnUnRegisterEvent()
	self:RemoveClick(self.BtnSure, self.OnClickedBtnSure)
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
end

function DlgCardUpPreview:OnEnter(vParam)
	if not vParam then
		return
	end

	self:DealWithLocalization(vParam.title, vParam.type)

	self.GoPanel = self:GetChildGameObject("Panel")
	self.GoSkill = self:GetChildGameObject("Panel/Skill")
	self.GoAttr = self:GetChildGameObject("Panel/Attr")
	self.TxtSkillName = GOUtil.FindChildComponent(self.GoSkill, "BgInfo/TxtName", "Text")
	self.TxtSkillInfo = GOUtil.FindChildComponent(self.GoSkill, "BgInfo/TxtInfo", "Text")
	self.TxtSkillDesc = GOUtil.FindChildComponent(self.GoSkill, "Scroll/TxtContent", "Text")
	self.ImgSkillIcon = GOUtil.FindChildComponent(self.GoSkill, "Icon", "Image")
	self.GoS = self:GetChildGameObject("Panel/Skill/ImgS")
	self.BtnSure = self:GetChildGameObject("Panel/BtnSure")
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")
	self.TxtAssetLess = self:GetChildComponent("Panel/TxtAssetLess", "Text")
	self.GoPrompt = self:GetChildGameObject("Panel/Prompt")
	self.TxtPrompt1 = self:GetChildComponent("Panel/Prompt/Text1", "Text")
	self.TxtPrompt2 = self:GetChildComponent("Panel/Prompt/Text2", "Text")

	self:Init(vParam)
end

function DlgCardUpPreview:DealWithLocalization(title, type)
	local txt

	txt = self:GetChildComponent("Panel/Title/Text", "Text")
	txt.text = title or ""
	txt = self:GetChildComponent("Panel/BtnSure/Text", "Text")
	txt.text = TenaryOp(type == 1, Lang(12046), Lang(20014))
end

function DlgCardUpPreview:Init(data)
	self.type = data.type
	self.infoRoleCard = data.infoRoleCard
	self.canUp = data.canUp
	self.LessItemId = data.lessItemId
	self.costList = {}

	if data and data.costList then
		self.costList = data.costList
	end

	if self.type == 2 then
		self.extraCommNum = data.extraCommNum or 0
	end

	self:InitPanel()
end

function DlgCardUpPreview:InitPanel()
	if not self.canUp then
		GOUtil.SetActive(self.BtnSure, false)
	end

	if not self.canUp then
		GOUtil.SetActive(self.TxtAssetLess, true)

		if self.LessItemId then
			self.TxtAssetLess.text = string.format(_("Develop_Cost_Not_Enough"), ItemManager:Get(self.LessItemId):GetName())
		elseif self.type == 1 then
			self.TxtAssetLess.text = Lang(42180)
		else
			self.TxtAssetLess.text = Lang(8111003)
		end
	end

	if self.type ~= 2 or not self.canUp then
		GOUtil.SetActive(self.GoPrompt, false)
	end

	local list = {}

	if self.type == 1 then
		local curStarLevel = self.infoRoleCard.curStarLevel
		local listSkill = self.infoRoleCard.data.StarTalent

		list = listSkill[curStarLevel + 1 + 1]
	elseif self.type == 2 then
		local curPetal = self.infoRoleCard.curPetal
		local listSkill = self.infoRoleCard.data.FlowerSkill

		list = listSkill[curPetal + 1]
	end

	if not list or #list == 0 then
		GOUtil.SetActive(self.GoSkill, false)
		GOUtil.SetRectTransformAnchoredPosition(self.GoAttr, 0, -66)

		if self.type == 2 and self.canUp then
			GOUtil.SetRectTransformSizeDelta(self.GoAttr, 1036, 566)
		else
			GOUtil.SetRectTransformSizeDelta(self.GoAttr, 1036, 638)
		end
	else
		if self.type == 1 or not self.canUp then
			GOUtil.SetRectTransformSizeDelta(self.GoAttr, 1036, 398)
		end

		local skillId = list[1]
		local info = TalentManager:Get(skillId)

		self.TxtSkillName.text = Lang(info.data.Name)

		UIUtil.SetImageSprite(self.ImgSkillIcon, "UIDyAtlas/Skill/" .. info.data.Icon, self)

		local curLevel = self.infoRoleCard:GetTalentLevel(skillId)

		if self.type == 1 then
			self.TxtSkillInfo.text = _("Desc_Unlock_After_Break")
			self.TxtSkillDesc.text = "<color=#585E62>" .. _("Desc_After_Break") .. "</color>" .. skillTip.GetDesc(info.id, curLevel, 0)
		elseif self.type == 2 then
			self.TxtSkillInfo.text = string.format(_("Desc_Level"), curLevel) .. "→" .. string.format(_("Desc_Level"), list[2])
			self.TxtSkillDesc.text = "<color=#585E62>" .. _("Desc_After_Bloom") .. "</color>" .. skillTip.GetDesc(info.id, list[2], 0)
		end
	end

	self.DlgCommMsg = nil

	if self.type == 2 and self.canUp then
		local cost = self.infoRoleCard.data.FlowerCost[self.infoRoleCard.curPetal + 1]
		local soulId = cost[1][1]
		local infoRoleCard = RoleCardMgr:GetRoleCard(ItemManager:Get(soulId).data.Value)
		local hold = 0
		local need = 0

		if cost and next(cost) ~= nil then
			need = cost[1][2] or 0
		end

		if infoRoleCard then
			hold = infoRoleCard.pb.soul
		end

		self.TxtPrompt1.text = string.format(Lang(42484), need, hold)

		if self.infoRoleCard.cardRank == eRankType.UR and self.extraCommNum and self.extraCommNum >= 0 then
			GOUtil.SetActive(self.TxtPrompt2, true)

			local commonSoul = ItemManager:GetItemByType("I_SOUL_COMMON")

			if commonSoul then
				local holdCommSoul = commonSoul:GetCurResNum()

				self.TxtPrompt2.text = string.format(Lang(42485), self.extraCommNum, holdCommSoul)
			end
		end
	end

	self:InitAtt()
end

function DlgCardUpPreview:InitAtt()
	local scrollArea = self:GetChildGameObject("Panel/Attr/ScrollArea")

	GOUtil.AddMissingComponent(scrollArea, "UIScrollView")

	local content = self:GetChildGameObject("Panel/Attr/ScrollArea/Content")
	local att = self:GetChildGameObject("Panel/Attr/Att")
	local curAttr = self.infoRoleCard.attrs
	local nextAttr = self.infoRoleCard:UpdateAtt(self.infoRoleCard.curLevel, self.infoRoleCard.curStarLevel + 1, self.infoRoleCard.curPetal)

	if self.type == 2 then
		nextAttr = self.infoRoleCard:UpdateAtt(self.infoRoleCard.curLevel, self.infoRoleCard.curStarLevel, self.infoRoleCard.curPetal + 1)
	end

	local function SetAtt(go, idx)
		local txtAtt = GOUtil.FindChildComponent(go, "Name/Text", "Text")

		txtAtt.text = _("eAttType_" .. idx)

		local txtCur = GOUtil.FindChildComponent(go, "TxtCur", "Text")

		txtCur.text = math.floor(curAttr:Get(idx) + 0.5)

		local txtNext = GOUtil.FindChildComponent(go, "TxtNext", "Text")

		txtNext.text = math.floor(nextAttr:Get(idx) + 0.5)

		local txtAdd = GOUtil.FindChildComponent(go, "TxtAdd", "Text")

		txtAdd.text = "(+" .. math.floor(nextAttr:Get(idx) + 0.5) - math.floor(curAttr:Get(idx) + 0.5) .. ")"
	end

	for k in ipairs(ATTRIBUTE_NAME) do
		local go

		if self.type == 2 then
			if k <= #ATTRIBUTE_MAP[1] then
				go = GOUtil.Instantiate(att, content)

				SetAtt(go, k)
			end
		else
			go = GOUtil.Instantiate(att, content)

			SetAtt(go, k)
		end
	end

	GOUtil.SetActive(att, false)
end

function DlgCardUpPreview:OnClickedBtnSure()
	if not self.canUp then
		return
	end

	if self.type == 1 then
		local function wrap_cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vMsg.result.code == NetManager.Result_Sucess then
				self:Close()

				local setter = SetterData.GetSetterData(vMsg.setter)

				setter:Parse()

				local function panelCb()
					Event.Instance:Fire("UpdateAfterCardDevelop", eTabType.Break)
					Event.Instance:Fire(EventEnum.UpdateItemDataNotify, eTabType.Bloom)
				end

				local finalCb

				if SetterData.HaveAwards(vMsg.setter) then
					function finalCb()
						UIMgr.AddPanel(DlgGetAward.GetInstance(), {
							fromMail = false,
							list = setter.list,
							callback = panelCb
						})
					end
				else
					finalCb = panelCb
				end

				local data = {
					type = 1,
					infoRoleCard = self.infoRoleCard,
					callback = finalCb
				}
				local listSkill = self.infoRoleCard.data.StarTalent[self.infoRoleCard.curStarLevel + 1] or {}

				if #listSkill > 0 then
					local temp = {
						skillId = listSkill[1],
						infoRoleCard = self.infoRoleCard,
						callback = finalCb
					}

					function data.callback()
						UIMgr.AddPanel(DlgUnlockSkill(), temp)
					end
				end

				UIMgr.AddPanel(DlgCardUpResult(), data)
				self:PlayVoice()
			elseif vMsg.result.code == NetManager.Result_Timeout then
				local strContent = _("Desc_NoNetwork")

				UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), strContent, function()
					Restart()
				end, _("UI_OK"), nil, false)
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		end

		NetManager:RequestUpgradeRoleStar(self.infoRoleCard.id, wrap_cb)
		LoadingMgr.Show(eLoadingType.Repeat)
	else
		local function cb()
			local function wrap_cb(vMsg)
				LoadingMgr.Hide(eLoadingType.Repeat)

				if vMsg.result.code == NetManager.Result_Sucess then
					self:Close()
					self.infoRoleCard:UpdatePetalLevel()
					self.infoRoleCard:UpdateTalentLevel(vMsg.change)
					self.infoRoleCard:SetGetPetalReward(self.infoRoleCard.curPetal)
					CardRDL.StageRDL.RunCardStageStory(self.infoRoleCard)
					ManualRDL.NotesRDL.DealTask(self.infoRoleCard.data.CharacterID)

					local setter = SetterData.GetSetterData(vMsg.setter)

					setter:Parse()

					local function panelCb()
						Event.Instance:Fire("UpdateAfterCardDevelop", eTabType.Bloom)
					end

					local finalCb

					if SetterData.HaveAwards(vMsg.setter) then
						function finalCb()
							UIMgr.AddPanel(DlgGetAward.GetInstance(), {
								fromMail = false,
								list = setter.list,
								callback = panelCb
							})
						end
					else
						finalCb = panelCb
					end

					local data = {
						type = 2,
						infoRoleCard = self.infoRoleCard,
						callback = finalCb
					}

					UIMgr.AddPanel(DlgCardUpResult(), data)
					self:PlayVoice()
				elseif vMsg.result.code == NetManager.Result_Timeout then
					local strContent = _("Desc_NoNetwork")

					UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), strContent, function()
						Restart()
					end, _("UI_OK"), nil, false)
				else
					UIMgr.ShowMsg(vMsg.result.desc, vMsg)
				end
			end

			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:RequestUpCardPetal(self.infoRoleCard.id, self.infoRoleCard.curPetal + 1, self.costList, wrap_cb)
		end

		if self.extraCommNum and self.extraCommNum ~= 0 then
			local function fun(type)
				if type == DlgCommonEvent.ButtonType.Ok then
					cb()
				end
			end

			local holdCommonSoul = ItemManager:GetItemByType("I_SOUL_COMMON"):GetCurResNum()

			UIMgr.ShowCommon(DlgCommonEvent.Type.Conform, _("Desc_Alert"), string.format(Lang(42486), self.extraCommNum, holdCommonSoul or 0), fun, _("UI_Yes"), _("UI_No"), false)
		else
			cb()
		end
	end
end

function DlgCardUpPreview:PlayVoice()
	local role = RoleCardMgr:GetRole(self.infoRoleCard.id)

	if role then
		InfoSoundEventMgr:LoadBank(role.data.VocalBank)

		if self.type == 1 then
			InfoSoundEventMgr:Play("VocalCharaUp2", role.data.VocalCharaUp2)
		else
			InfoSoundEventMgr:Play("VocalCharaUp3", role.data.VocalCharaUp3)
		end
	end
end

function DlgCardUpPreview:OnClickedBtnClose()
	self:Close()
end

function DlgCardUpPreview:DealWithSetterResult(setter, type)
	DealWithGetAward(setter)
end
