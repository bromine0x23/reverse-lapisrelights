-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageInteraction/CellFavorUnlock.lua

require("UI/Item/UIItemBase")

CellFavorUnlock = class("CellFavorUnlock", UIItemBase)

function CellFavorUnlock:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.Page = page
end

function CellFavorUnlock:Create(vParam)
	CellFavorUnlock.base.Create(self, vParam)
end

function CellFavorUnlock:OnEnter()
	local g = self.UIRootObject

	self.TextTital = GOUtil.FindChildComponent(g, "Tital", "Text")
	self.TextLock = GOUtil.FindChildComponent(g, "Text", "Text")
	self.ImageLock = GOUtil.FindChildGameObject(g, "Lock")
	self.ImageBg = GOUtil.FindChildComponent(g, "", "Image")
	self.GotoBtn = GOUtil.FindChildGameObject(g, "GOTO")
	self.GotoText = GOUtil.FindChildComponent(g, "GOTO/Text", "Text")
	self.Play = GOUtil.FindChildGameObject(g, "GOTO/Play")
	self.line = GOUtil.FindChildGameObject(g, "GOTO/Image")
	self.voiceObj = GOUtil.FindChildGameObject(g, "Voice")
	self.Animator = GOUtil.FindChildComponent(g, "Voice", "Animator")
	self.GotoText.text = _("UI_Go")
end

function CellFavorUnlock:OnLeave()
	self.TextTital = nil
	self.TextLock = nil
	self.ImageLock = nil
	self.ImageBg = nil
end

function CellFavorUnlock:UpdateData(unlockInfo, curLevel, infoRole, curbehaviourData)
	self.infoRole = infoRole
	self.unlockInfo = unlockInfo

	SetActiveFunc(self.voiceObj, false)

	local isLock = curLevel < unlockInfo.level

	self.TextLock.text = string.format(_("Desc_LevelUnlock"), unlockInfo.level)

	SetActiveFunc(self.GotoBtn.gameObject, not isLock)
	SetActiveFunc(self.ImageLock.gameObject, isLock)
	SetActiveFunc(self.TextLock.gameObject, isLock)

	local gray = TenaryOp(isLock, 1, 0)

	UIUtil.SetImageGray(self.ImageBg, gray)
	SetActiveFunc(self.Play, false)
	SetActiveFunc(self.GotoText.gameObject, true)
	SetActiveFunc(self.line, true)

	local switch = {
		[eFavorUnlockType.vocal] = function()
			SetActiveFunc(self.voiceObj, true)

			if curbehaviourData == self.unlockInfo.data.behaviourData and curbehaviourData.SoundEvent ~= nil and curbehaviourData.SoundEvent ~= "" then
				self.Animator:Play("Voice_Loop", 0, 0)
			else
				self.Animator:Play("Empty", 0, 0)
			end

			self.TextTital.text = _("Desc_Voice") .. ":" .. unlockInfo.data.name

			SetActiveFunc(self.Play, true)
			SetActiveFunc(self.line, false)
			SetActiveFunc(self.GotoText.gameObject, false)
		end,
		[eFavorUnlockType.stage] = function()
			self.TextTital.text = _("PageChapter_title") .. ":" .. Lang(unlockInfo.data.data.Name)
		end,
		[eFavorUnlockType.equipment] = function()
			self.TextTital.text = _("Item_From_11_1") .. ":" .. _("Desc_NewEquip")
		end,
		[eFavorUnlockType.cost] = function()
			SetActiveFunc(self.GotoBtn.gameObject, false)

			self.TextTital.text = _("Filter_Card_3") .. ":" .. _("Desc_CostDown")
		end,
		[eFavorUnlockType.skillNode] = function()
			self.TextTital.text = Lang(490007) .. ":" .. _("Desc_NewTalent") .. " " .. Lang(unlockInfo.name)
		end,
		[eFavorUnlockType.ar] = function()
			self.TextTital.text = string.format(_("Desc_NewAction"), Lang(unlockInfo.data.Name))
		end,
		[eFavorUnlockType.topic] = function()
			self.TextTital.text = Lang(490016) .. " " .. Lang(5000060) .. ":" .. Lang(unlockInfo.data.Name)
		end,
		[eFavorUnlockType.phoneCall] = function()
			self.TextTital.text = Lang(490016) .. " " .. Lang(5000061) .. ":" .. Lang(unlockInfo.data.Name)
		end
	}
	local fSwitch = switch[unlockInfo.type]

	if fSwitch then
		fSwitch()
	end
end

function CellFavorUnlock:OnGoToClick(cb)
	local switch = {
		[eFavorUnlockType.vocal] = function()
			self.Page:PlayVoiceAndAnim(self.unlockInfo.data.behaviourData, self)
		end,
		[eFavorUnlockType.stage] = function()
			UIMgr.GetCurPanel():OnClickedButtonStory()
		end,
		[eFavorUnlockType.equipment] = function()
			local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Equipment)

			if not isOpen then
				return
			end

			require("UI/Page/PageEquipment/PageEquip")
			UIMgr.SwitchPanel(PageEquip)
		end,
		[eFavorUnlockType.cost] = function()
			return
		end,
		[eFavorUnlockType.skillNode] = function()
			local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Talent)

			if not isOpen then
				return
			end

			require("UI/Page/PageRole/PageTalentTree")
			UIMgr.SwitchPanel(PageTalentTree)
		end,
		[eFavorUnlockType.ar] = function()
			UIMgr.GetCurPanel():UpdateGroupBtn(4)
		end,
		[eFavorUnlockType.topic] = function()
			local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Communication)

			if not isOpen then
				return
			end

			require("UI/Page/PageCommunication/PageAddressBookNew")
			UIMgr.SwitchPanel(PageAddressBookNew, {
				tabType = 1,
				roleId = self.infoRole.id
			})
		end,
		[eFavorUnlockType.phoneCall] = function()
			local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Communication)

			if not isOpen then
				return
			end

			require("UI/Page/PageCommunication/PageAddressBookNew")
			UIMgr.SwitchPanel(PageAddressBookNew, {
				tabType = 2,
				roleId = self.infoRole.id
			})
		end
	}
	local fSwitch = switch[self.unlockInfo.type]

	if fSwitch then
		fSwitch()
	end
end
