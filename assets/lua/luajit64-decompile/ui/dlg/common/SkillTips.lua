-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/SkillTips.lua

SkillTips = class("SkillTips", UIPanel)

function SkillTips:ctor()
	SkillTips.base.ctor(self, "UI/CommonTip/SkillTip/ListSkillTip")

	self.closed = true
end

function SkillTips:OnEnter(vParam)
	self.itemSource = self:GetChildGameObject("Item")

	GOUtil.SetActive(self.itemSource, false)

	self.items = {}

	self:Open(unpack(vParam))
end

function SkillTips:Open(buffs, scenePos, offset)
	if #buffs == 0 then
		return
	end

	self.buffs = buffs or {}

	local createCount = #buffs - #self.items

	if createCount > 0 then
		for i = 1, createCount do
			self:CreateItem()
		end
	end

	self:UpdateAllItem()

	self.UIRootObject.transform.localPosition = Vector3(0, 1000, 0)

	BattleConfig.DelayFrameCount(1, function()
		if not self.UIRootObject then
			return
		end

		local parentGo = self.UIRootObject.transform.parent.gameObject

		if offset ~= nil then
			self.UIRootObject.transform.localPosition = UIUtil.GetTipsPos(parentGo, scenePos, self.UIRootObject, offset)
		else
			self.UIRootObject.transform.localPosition = UIUtil.GetTipsPos(parentGo, scenePos, self.UIRootObject)
		end
	end)
end

function SkillTips:CreateItem()
	local DlgSkillTip = SkillTip()

	DlgSkillTip.UIPrefabPath = "UI/CommonTip/SkillTip/ListSkillTip_Item"
	DlgSkillTip.isSyncLoad = true

	self:AddChildPanelImmediately(DlgSkillTip)
	table.insert(self.items, DlgSkillTip)
end

function SkillTips:UpdateAllItem()
	for i, item in ipairs(self.items) do
		if i <= #self.buffs then
			item:Open(self.buffs[i])
		else
			item:Hide()
		end
	end
end

function SkillTips:Hide()
	if self.items then
		for i, item in ipairs(self.items) do
			item:Hide()
		end
	end

	self.items = nil
	self.buffs = nil

	self:Close()
end
