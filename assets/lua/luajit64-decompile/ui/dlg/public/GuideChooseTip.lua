-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Public/GuideChooseTip.lua

GuideChooseTip = class("GuideChooseTip", UIPanel)

local CardGuide = {
	GuideFunctionType.CardAttribute,
	GuideFunctionType.CardLevel,
	GuideFunctionType.CardStar,
	GuideFunctionType.CardPetal
}
local EquipGuide = {
	GuideFunctionType.Equip,
	GuideFunctionType.EquipIntense,
	GuideFunctionType.EquipEnchant,
	GuideFunctionType.EquipSynthetize
}
local UnionGuide = {
	GuideFunctionType.Union,
	GuideFunctionType.UnionWish,
	GuideFunctionType.UnionSkill,
	GuideFunctionType.UnionRaid
}
local TeaPartyGuide = {
	GuideFunctionType.EventStage,
	GuideFunctionType.GiftBag
}
local InteractionGuide = {
	GuideFunctionType.Interaction,
	GuideFunctionType.SendGIft,
	GuideFunctionType.AR
}
local FightGuide = {
	GuideFunctionType.FightGuide1,
	GuideFunctionType.FightGuide2,
	GuideFunctionType.FightGuide3,
	GuideFunctionType.FightGuide4,
	GuideFunctionType.FightGuide5,
	GuideFunctionType.TimeSpace
}

function GuideChooseTip:ctor()
	self.UIPrefabPath = "UI/CommonTip/GuideChooseTip/GuideChooseTip"
end

function GuideChooseTip:Purge()
	self.base.Purge(self)
end

function GuideChooseTip:OnRegisterEvent()
	self:AddClick(self.BtnClose, self.OnClickedBtnClose)

	for i = 1, 6 do
		self:AddClick(self.GuideBtnList[i].go, self.OnClickedBtnChoose)
	end
end

function GuideChooseTip:OnUnRegisterEvent()
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)

	for i = 1, 6 do
		self:RemoveClick(self.GuideBtnList[i].go, self.OnClickedBtnChoose)
	end
end

function GuideChooseTip:OnEnter(vParam)
	self.BtnClose = self:GetChildGameObject("Main/Button")
	self.GuideBtnList = {}

	for i = 1, 6 do
		local GuideBtn = {}

		GuideBtn.go = self:GetChildGameObject("Main/Group/" .. i)
		GuideBtn.name = GOUtil.FindChildComponent(GuideBtn.go, "Text", "Text")

		table.insert(self.GuideBtnList, GuideBtn)
	end

	self:Init(vParam)
end

function GuideChooseTip:Init(vParam)
	self.guideType = vParam.guideType

	if self.guideType == "CardGuide" then
		self.guide = CardGuide
	elseif self.guideType == "EquipGuide" then
		self.guide = EquipGuide
	elseif self.guideType == "UnionGuide" then
		if Infogvg:IsPlayOpen() and not table.contains(UnionGuide, GuideFunctionType.Gvg) then
			table.insert(UnionGuide, GuideFunctionType.Gvg)
		end

		self.guide = UnionGuide
	elseif self.guideType == "TeaPartyGuide" then
		self.guide = TeaPartyGuide
	elseif self.guideType == "InteractionGuide" then
		self.guide = InteractionGuide
	elseif self.guideType == "FightGuide" then
		self.guide = FightGuide
	end

	self:UpdatePanel()
end

function GuideChooseTip:UpdatePanel()
	for i = 1, 6 do
		if i <= #self.guide then
			self.GuideBtnList[i].go:SetActive(true)

			self.GuideBtnList[i].name.text = Lang(GuideMgr:GetGuidName(self.guide[i]))
		else
			self.GuideBtnList[i].go:SetActive(false)
		end
	end
end

function GuideChooseTip:OnClickedBtnChoose(data)
	local guideIndex = tonumber(data.pointerPress.gameObject.name)

	UIMgr.AddPanel(PGuide(), self.guide[guideIndex])
end

function GuideChooseTip:OnClickedBtnClose()
	self:Close()
end
