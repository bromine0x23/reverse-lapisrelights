-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionRaid/CellRaidEvent.lua

require("UI/Item/UIItemBase")

CellRaidEvent = class("CellRaidEvent", UIItemBase)

function CellRaidEvent:ctor(itemPrefabCache, parent, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellRaidEvent:Create(vParam)
	CellRaidEvent.base.Create(self, vParam)
end

function CellRaidEvent:OnEnter()
	local g = self.UIRootObject
	local txt = GOUtil.FindChildComponent(g, "Prompt/Text", "Text")

	txt.text = _("Desc_Breakout_Raid")
	self.GoSpinePoint = GOUtil.FindChildGameObject(g, "Point")
	self.TxtCheerValue = GOUtil.FindChildComponent(g, "Info/Cheer/TxtValue", "Text")
	self.TxtBreakValue = GOUtil.FindChildComponent(g, "Prompt/TxtValue", "Text")
	self.TxtLevelValue = GOUtil.FindChildComponent(g, "Info/Break/TxtValue", "Text")
	self.GoCheer = GOUtil.FindChildGameObject(g, "Info/Cheer")
	self.GoBreak = GOUtil.FindChildGameObject(g, "Info/Break")
	self.RaidIcon = GOUtil.FindChildComponent(g, "Prompt/Icon", "Image")
	self.Anim = GOUtil.FindChildComponent(g, "Prompt", "Animator")

	self:AddClick(g, self.OnClickEvent)
end

function CellRaidEvent:UpdateData(event, isRandomEvent)
	if event == nil then
		return
	end

	self.event = event
	self.isRandomEvent = isRandomEvent

	self.Anim:Play("Anim_CellRaidEvent_Idle")
	GOUtil.SetTransformLocalScale(self.UIRootObject, 1)

	local addRate = 0

	if event.data.Type == eRaidEventType.Battle then
		SetActiveFunc(self.GoBreak, true)

		local battleTimes = UnionRaidMgr.beingCommRaid:GetBattleEventIdx()

		addRate = event:GetAddRate(battleTimes)
		self.TxtLevelValue.text = string.format(_("UnionRaid_Diff"), battleTimes)

		SetImageSprite(self.RaidIcon, "UI/PanelUnionRaid/AtlasPanelRaid/bg_maze_door_s0" .. UnionRaidMgr.beingCommRaid.id, self)
	else
		SetActiveFunc(self.GoBreak, false)

		addRate = event:GetAddRate()
	end

	if UnionRaidMgr.beingCommRaid.battleSum >= UnionRaidMgr.beingCommRaid.data.BattleRound then
		self.TxtLevelValue.text = _("Desc_Raid_Pass_Today")
	end

	self.TxtBreakValue.text = "+" .. addRate or 0
	self.TxtCheerValue.text = "+" .. event:GetAddContribution()

	self:UpdateSpineRes()
end

function CellRaidEvent:UpdateSpineRes()
	local skeResPath = eEventSpinePath[self.event.data.Type or 1] .. "_SkeletonData"
	local matResPath = eEventSpinePath[self.event.data.Type or 1] .. "_Material"

	local function AsyncLoadFinish()
		LoadingMgr.Hide(eLoadingType.Repeat)

		if self.SkeletonRef ~= nil then
			local matRef = ResourceMgr.LoadSync(matResPath, Material)

			UIUtil.SetSpineSkeletonDataAsset(self.GoSpinePoint, self.SkeletonRef, matRef)

			if self.page ~= nil then
				DealWithListSpineRef(self.page, self.SkeletonRef)
				DealWithListSpineRef(self.page, matRef)

				if self.isRandomEvent then
					self.page.loadedCnt = self.page.loadedCnt + 1

					self.page:OnLoadedFinish()
				end

				self.SkeletonRef = nil
				self.Handle = nil
			end
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)

	self.Handle = ResourceMgr.BeginSubmit(AsyncLoadFinish)

	ResourceMgr.SubmitCache(skeResPath, self, "SkeletonRef", SkeletonDataAsset)
	ResourceMgr.EndSubmit()
end

function CellRaidEvent:PlayBubble()
	if self.event and self.event.data.Type == eRaidEventType.Battle then
		self.Anim:Play("Anim_CellRaidEvent_Bubble")
	end
end

function CellRaidEvent:OnLeave()
	UnloadAllImageSprite(self)

	if self.Handle then
		ResourceMgr.Cnacel(self.Handle)
	end

	self:RemoveClick(self.UIRootObject, self.OnClickEvent)
end

function CellRaidEvent:OnClickEvent()
	if self.page ~= nil then
		if self.isRandomEvent then
			if not UnionRaidMgr:IsPlayNumEnough(eRaidType.Common) then
				UIMgr.ShowMsg(_("Msg_Cnt_NotEnough"))

				return
			end

			self.page:SelectEvent(tonumber(self.UIRootObject.name))
		else
			self.page:DealSelectedEvent()
		end
	end
end
