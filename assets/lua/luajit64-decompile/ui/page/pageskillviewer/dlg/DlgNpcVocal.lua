-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageSkillViewer/Dlg/DlgNpcVocal.lua

DlgNpcVocal = class("DlgNpcVocal", UIPanel)

function DlgNpcVocal:ctor()
	DlgNpcVocal.base.ctor(self, "UI/PageSkillViewer/Dlg/DlgNpcAnim")
end

function DlgNpcVocal:Cache()
	DlgNpcVocal.base.Cache(self)
end

function DlgNpcVocal:Close(tParam)
	DlgNpcVocal.base.Close(self, tParam)
end

function DlgNpcVocal:Purge()
	DlgNpcVocal.base.Purge(self)

	self.list = {}
end

function DlgNpcVocal:OnRegisterEvent()
	self:AddClick(self.btn_close, self.OnBtnClose, PATH_SFX_UI_CANCEL)
	self:AddClick(self.touch_close, self.OnBtnClose, PATH_SFX_UI_CANCEL)
end

function DlgNpcVocal:OnUnRegisterEvent()
	self:RemoveClick(self.touch_close, self.OnBtnClose)
	self:RemoveClick(self.btn_close, self.OnBtnClose)

	for i, cell in ipairs(self.list) do
		self:RemoveClick(cell.gameObject, cell.onClick)
	end
end

function DlgNpcVocal:OnBtnClose()
	self:Show(false)
end

function DlgNpcVocal:OnEnter(vParam)
	self.list = {}
	self.touch_close = self:GetChildGameObject("panel")
	self.btn_close = self:GetChildGameObject("panel/btn_close")

	self:Show(false)
end

function DlgNpcVocal:Open()
	self:Show(true)
	self:Refresh()
end

local idx = 1

function DlgNpcVocal:Refresh()
	if SV.Npc == nil then
		self:Show(false)

		return
	end

	if SV.Npc.UnitClass ~= EnumFight.UnitClass.PLAYER then
		self:Show(false)

		return
	end

	local itemT = self:GetChildGameObject("panel/scroll/viewport/content/ItemT")
	local itemRoot = itemT.transform.parent.gameObject
	local vocals = {
		SV.Npc.UnitData.data.VocalCutin,
		SV.Npc.UnitData.data.VocalStart,
		SV.Npc.UnitData.data.VocalLose,
		SV.Npc.UnitData.data.VocalWin,
		SV.Npc.UnitData.data.VocalHit,
		SV.Npc.UnitData.data.VocalRecover,
		SV.Npc.UnitData.data.VocalAtk
	}

	for i, cell in ipairs(self.list) do
		GOUtil.SetActive(cell.gameObject, false)
	end

	for k, anim in ipairs(vocals) do
		local cell = {}

		if self.list[idx] then
			cell = self.list[idx]
		end

		if not cell.gameObject then
			cell.gameObject = GOUtil.InstantiateUI(itemT, itemRoot)

			local labelObj = GOUtil.FindGameObjectByName("txt_info", cell.gameObject)

			cell.txt = GOUtil.GetComponent(labelObj, "Text")

			table.insert(self.list, cell)

			idx = idx + 1
		end

		cell.animName = anim

		function cell.onClick()
			SoundMgr.PostEvent(cell.animName, UIMgr.UICamera.gameObject)

			local ActorLipSync = GOUtil.AddMissingComponent(UIMgr.UICamera.gameObject, "ActorLipSync")

			ActorLipSync:Init(SV.Npc.UnitData.data.Lips)
			ActorLipSync:Play(SV.Npc.Actor, cell.animName)
		end

		cell.txt.text = anim

		GOUtil.SetActive(cell.gameObject, true)
		self:AddClick(cell.gameObject, cell.onClick)
	end

	GOUtil.SetActive(itemT, false)
end
