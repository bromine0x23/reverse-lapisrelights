-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/DlgCharacterThin/CellCharacterThin.lua

require("UI/Item/UIItemBase")

local InfoTeam = require("Info/InfoTeam")

CellCharacterThin = class("CellCharacterThin", UIItemBase)

function CellCharacterThin:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellCharacterThin:Create(vParam)
	CellCharacterThin.base.Create(self, vParam)
end

function CellCharacterThin:OnEnter()
	local g = self.UIRootObject

	self.ImgIcon = GOUtil.FindChildComponent(g, "Icon", "MaskableImage")
	self.TxtName = GOUtil.FindChildComponent(g, "TxtName", "Text")
	self.GoNew = GOUtil.FindChildGameObject(g, "New")
	self.GoDot = GOUtil.FindChildGameObject(g, "Dot")
	self.GoBat = GOUtil.FindChildGameObject(g, "Battle")
	self.GoFav = GOUtil.FindChildGameObject(g, "Favor")
	self.GoLock = GOUtil.FindChildGameObject(g, "Lock")
	self.GoSelect = GOUtil.FindChildGameObject(g, "Select")
end

function CellCharacterThin:OnLeave()
	UnloadAllImageSprite(self)
end

function CellCharacterThin:UpdateData(role, selectIdx, pageType)
	if not role then
		return
	end

	self.role = role
	self.pageType = pageType

	SetImageSprite(self.ImgIcon, role.actorData.CharacterIcon, self)
	self:UpdateFavState()
	self:UpdateBatState()
	self:UpdateDotState()
	self:UpdateNewState()
	self:UpdateLockState()
	self:UpdateSelectState(self.Index == selectIdx)
end

function CellCharacterThin:UpdateLockState()
	SetActiveWithState(self, "GoLock", not self.role.hold)
end

function CellCharacterThin:UpdateFavState()
	return
end

function CellCharacterThin:UpdateBatState()
	local team = InfoTeam.stageTeams[tonumber(RoleCardMgr:GetTeamListIndex())]
	local isBat = false

	for k, v in ipairs(team.roleCardTeams) do
		if k <= InfoTeam.slotCnt and v ~= 0 and RoleCardMgr:GetRole(v).id == self.role.id then
			isBat = true

			break
		end
	end

	SetActiveWithState(self, "GoLock", isBat)
end

function CellCharacterThin:UpdateDotState()
	if self.pageType == THIN_PAGE_TYPE.Fitting then
		local hasNewAvatar = RoleRDL.FittingRDL.IsHasNewAvatar(self.role)

		SetActiveWithState(self, "GoDot", hasNewAvatar)
	elseif self.pageType == THIN_PAGE_TYPE.Role then
		local isNew = RoleRDL.NewRDL.IsNewRole(self.role)

		SetActiveWithState(self, "GoNew", isNew)

		if not isNew then
			local hasDot = false

			if self.role.hold then
				hasDot = RoleRDL.IsShowDot(self.role.id)
			end

			SetActiveWithState(self, "GoDot", hasDot)
		end
	end
end

function CellCharacterThin:UpdateNewState()
	return
end

function CellCharacterThin:UpdateSelectState(state)
	SetActiveWithState(self, "GoSelect", state)
end
