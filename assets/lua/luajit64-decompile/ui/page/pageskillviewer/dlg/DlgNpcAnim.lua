-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageSkillViewer/Dlg/DlgNpcAnim.lua

DlgNpcAnim = class("DlgNpcAnim", UIPanel)

function DlgNpcAnim:ctor()
	DlgNpcAnim.base.ctor(self, "UI/PageSkillViewer/Dlg/DlgNpcAnim")
end

function DlgNpcAnim:Cache()
	DlgNpcAnim.base.Cache(self)
end

function DlgNpcAnim:Close(tParam)
	DlgNpcAnim.base.Close(self, tParam)
end

function DlgNpcAnim:Purge()
	DlgNpcAnim.base.Purge(self)

	self.list = {}
end

function DlgNpcAnim:OnRegisterEvent()
	self:AddClick(self.btn_close, self.OnBtnClose, PATH_SFX_UI_CANCEL)
	self:AddClick(self.touch_close, self.OnBtnClose, PATH_SFX_UI_CANCEL)
end

function DlgNpcAnim:OnUnRegisterEvent()
	self:RemoveClick(self.touch_close, self.OnBtnClose)
	self:RemoveClick(self.btn_close, self.OnBtnClose)

	for i, cell in ipairs(self.list) do
		self:RemoveClick(cell.gameObject, cell.onClick)
	end
end

function DlgNpcAnim:OnBtnClose()
	self:Show(false)
end

function DlgNpcAnim:OnEnter(vParam)
	self.list = {}
	self.touch_close = self:GetChildGameObject("panel")
	self.btn_close = self:GetChildGameObject("panel/btn_close")

	self:Show(false)
end

function DlgNpcAnim:Open()
	self:Show(true)
	self:Refresh()
end

local idx = 1

function DlgNpcAnim:Refresh()
	if SV.Npc == nil then
		self:Show(false)

		return
	end

	local itemT = self:GetChildGameObject("panel/scroll/viewport/content/ItemT")
	local itemRoot = itemT.transform.parent.gameObject
	local anims = SV.Npc.Actor.MotionSystem:GetAllStateName()

	for i, cell in ipairs(self.list) do
		GOUtil.SetActive(cell.gameObject, false)
	end

	for k, anim in ipairs(anims) do
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
			if cell.animName == "Die" then
				SV.Npc:PlayDie()
			else
				SV.Npc:Play(cell.animName)
			end
		end

		cell.txt.text = anim

		GOUtil.SetActive(cell.gameObject, true)
		self:AddClick(cell.gameObject, cell.onClick)
	end

	GOUtil.SetActive(itemT, false)
end
