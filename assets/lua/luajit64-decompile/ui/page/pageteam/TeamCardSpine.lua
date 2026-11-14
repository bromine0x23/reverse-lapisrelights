-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTeam/TeamCardSpine.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageRoleCard/Cell/CellCardSkill")

local CharacterTeam = require("luaData.CharacterTeam")
local lev = require("luaData/LevelConfig")
local jobBottomFramePaths = {
	"BG_card_back_limit_05",
	"BG_card_back_limit_01",
	"BG_card_back_limit_03",
	"BG_card_back_limit_04",
	"BG_card_back_limit_02"
}

TeamCardSpine = class("TeamCardSpine", UIItemBase)

function TeamCardSpine:ctor(itemPrefabCache, parent, owerPage)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = owerPage
end

function TeamCardSpine:Create(vParam)
	TeamCardSpine.base.Create(self, vParam)
end

function TeamCardSpine:OnEnter()
	local g = self.UIRootObject

	self.ImgCardIcon = GOUtil.FindChildComponent(g, "CardInfo/Card/Icon", "RawImage")
	self.BG_helper = GOUtil.FindChildComponent(g, "BG_helper", "Image")
	self.BG_helper2 = GOUtil.FindChildComponent(g, "BG_helper2", "Image")
end

function TeamCardSpine:OnLocalText(g)
	return
end

function TeamCardSpine:OnLeave()
	if self.groupHandle then
		ResourceMgr.Cancel(self.groupHandle)
	end

	if self.spineObj then
		ResourceMgr.Unload(self.spineObj)
	end

	UnloadAllImageSprite(self)
end

function TeamCardSpine:RayCheck(show)
	SetActiveFunc(self.GoCardRayCheck, show)
end

function TeamCardSpine:IsSpineMove(isMove, idx)
	SetActiveFunc(self.BG_helper, not isMove and idx == 5)
	SetActiveFunc(self.BG_helper2, isMove and idx == 5)
end

function TeamCardSpine:UpdateData(teamSystemAgent, posIdx)
	self.teamSystemAgent = teamSystemAgent
	self.teamAgent = teamSystemAgent.teamList[teamSystemAgent.teamIndex]
	self.slotAgent = self.teamAgent.slotList[posIdx]
	self.posIdx = posIdx

	SetActiveFunc(self.BG_helper, true)
	SetActiveFunc(self.BG_helper2, false)
	SetActiveFunc(self.BG_helper.gameObject, self.slotAgent.isHelperSlot and type(self.slotAgent.upInfoRoleCard) == "table")

	local BG_helper_Path = TenaryOp(self.slotAgent.isHelperSlot and not self.slotAgent.isHelperCard, "UI/PanelBattleTeam/AtlasTeamCard/bg_card_back_helper_01", "UI/PanelBattleTeam/AtlasTeamCard/bg_card_back_helper_02")

	if self.teamSystemAgent.isGvg then
		BG_helper_Path = TenaryOp(self.slotAgent.isHelperSlot and not self.slotAgent.isHelperCard, "UI/PanelBattleTeam/AtlasTeamCard/bg_card_back_helper_03", "UI/PanelBattleTeam/AtlasTeamCard/bg_card_back_helper_04")
	end

	UIUtil.SetImageSprite(self.BG_helper, BG_helper_Path, self)
	UIUtil.SetImageSprite(self.BG_helper2, BG_helper_Path, self)

	if self.slotAgent.upInfoRoleCard ~= nil then
		self:UpdateCardInfo(self.slotAgent.upInfoRoleCard, true)
	else
		self.cardId = nil

		GOUtil.DestroyAllChildren(self.ImgCardIcon.gameObject)
	end
end

function TeamCardSpine:UpdateCardInfo(infoRoleCard, isOpen)
	if self.groupHandle then
		ResourceMgr.Cancel(self.groupHandle)
	end

	if self.cardId == infoRoleCard.id then
		return
	end

	local infoRole = InfoRole(infoRoleCard.data.CharacterID)

	GOUtil.DestroyAllChildren(self.ImgCardIcon.gameObject)

	if infoRoleCard.data.SpineData ~= "" then
		self.groupHandle = ResourceMgr.BeginSubmit(function(cardId)
			if infoRoleCard.id == cardId then
				self.cardId = infoRoleCard.id

				if self.spineObj then
					self.ImgCardIcon.enabled = false

					local spine = GOUtil.InstantiateUIPrefab(self.spineObj, self.ImgCardIcon.gameObject)

					GOUtil.UpdateSpineSkeleton(self.ImgCardIcon.gameObject)

					if GOUtil.GetComponent(spine, "SpineAspectRatioFitter") then
						GOUtil.GetComponent(spine, "SpineAspectRatioFitter").enabled = false
					end

					DealWithListSpineRef(self, self.spineObj)

					self.spineObj = nil
					self.groupHandle = nil

					Event.Instance:Fire("PageTeamCardAnimation", self.posIdx)

					if GOUtil.GetComponent(spine, "SkeletonGraphic") then
						GOUtil.GetComponent(spine, "SkeletonGraphic").raycastTarget = false
					end
				else
					self.ImgCardIcon.enabled = true

					RoleCardMgr:SetInfoPanel(infoRoleCard, self.ImgCardIcon)
					Event.Instance:Fire("PageTeamCardAnimation", self.posIdx)
				end
			end
		end, infoRoleCard.id)

		ResourceMgr.SubmitCache(infoRoleCard.data.SpineData .. "_Anim", self, "spineObj", GameObject)
		ResourceMgr.EndSubmit()
	else
		self.ImgCardIcon.enabled = true

		RoleCardMgr:SetInfoPanel(infoRoleCard, self.ImgCardIcon)
		Event.Instance:Fire("PageTeamCardAnimation", self.posIdx)
	end

	RoleCardMgr:SetCardLocation(infoRoleCard, self.ImgCardIcon.gameObject, 1)
end
