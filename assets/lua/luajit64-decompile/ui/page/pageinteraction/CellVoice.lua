-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageInteraction/CellVoice.lua

require("UI/Item/UIItemBase")

CellVoice = class("CellVoice", UIItemBase)

function CellVoice:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellVoice:OnEnter()
	local g = self.UIRootObject

	self.GLock = GOUtil.FindChildGameObject(g, "ImageLock")
	self.GLockText = GOUtil.FindChildComponent(g, "ImageLock/Text", "Text")
	self.Text = GOUtil.FindChildComponent(g, "Text", "Text")
	self.Text = GOUtil.FindChildComponent(g, "Text", "Text")
	self.Animator = GOUtil.FindChildComponent(g, "Voice", "Animator")
	self.GoDot = GOUtil.FindChildGameObject(g, "Dot")
end

function CellVoice:UpdateData(voiceData, infoRole, curbehaviourData)
	self.voiceData = voiceData
	self.infoRole = infoRole

	local nameId = voiceData.name
	local favorLevel = voiceData.behaviourData.Level

	if curbehaviourData == voiceData.behaviourData then
		self.Animator:Play("Voice_Loop", 0, 0)
	else
		self.Animator:Play("Empty", 0, 0)
	end

	self.Text.text = nameId

	if favorLevel > infoRole.curFavorLevel then
		SetActiveFunc(self.Text.gameObject, false)
		SetActiveFunc(self.GLock, true)

		self.GLockText.text = string.format(_("PageTalentTree_Unlock_favor_1"), favorLevel)
	else
		SetActiveFunc(self.Text.gameObject, true)
		SetActiveFunc(self.GLock, false)
	end

	self:UpdateDot()
end

function CellVoice:UpdateDot()
	local isNew = RoleRDL.InteractRDL.IsNewVoice(self.infoRole, self.voiceData.behaviourData.VoiceName)

	GOUtil.SetActive(self.GoDot, isNew)
end
