-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Cells/CellHpBar.lua

CellHpBar = class("CellHpBar", UIPanel_sync)

local SPEED = 0.25

function CellHpBar:Reset()
	self.gameObject = nil
	self.transform = nil
	self.img_fill = nil
	self.trans_fill = nil
	self.img_headIcon = nil
	self.txt_label = nil
	self.curVal = 0
	self.maxVal = 0
	self.trans_effRoot = nil
end

function CellHpBar:ctor(obj)
	self.curOnly = false
	self.gameObject = obj
	self.transform = self.gameObject.transform
	self.img_fill = GOUtil.FindChildComponent(self.gameObject, "img_fill", "Image")
	self.trans_fill = self.img_fill.transform
	self.img_headIcon = GOUtil.FindChildComponent(self.gameObject, "Icon/img_headIcon", "Image")
	self.txt_label = GOUtil.FindChildComponent(self.gameObject, "txt_label", "Text")
	self.curVal = 0
	self.maxVal = 0
	self.trans_effRoot = GOUtil.FindChildGameObject(self.gameObject, "bg_bar")
end

function CellHpBar:CurOnly(val)
	self.curOnly = val
end

function CellHpBar:PlayEffect(fxPath)
	if not self.trans_effRoot then
		self.trans_effRoot = self.img_fill.gameObject
	end

	if fxPath and fxPath ~= "" then
		EffectMgr:Alloc(fxPath, self.trans_effRoot, true, 1)
	end
end

function CellHpBar:SetBarParent(root)
	if IsNil(root) then
		return
	end

	if IsNil(self.gameObject) then
		return
	end

	GOUtil.AttachGameObject(self.gameObject, root, true)
end

function CellHpBar:SetCur(cur)
	if cur > 0 and cur < 1 then
		cur = 1
	end

	self.curVal = cur

	if self.curOnly == false then
		self.txt_label.text = string.format("%d / %d", self.curVal, self.maxVal)
	else
		self.txt_label.text = string.format("%d", self.curVal)
	end

	self.img_fill.fillAmount = self.curVal / self.maxVal
end

function CellHpBar:SetMax(max)
	if max > 0 and max < 1 then
		max = 1
	end

	self.maxVal = max

	if self.curOnly == false then
		self.txt_label.text = string.format("%d / %d", self.curVal, self.maxVal)
	end

	self.img_fill.fillAmount = self.curVal / self.maxVal
end

function CellHpBar:Refresh(cur, max)
	if max == 0 then
		print("CellHpBar ERROR , max = 0")

		return
	end

	GOUtil.DOScale(self.trans_fill, cur / max, SPEED)

	self.txt_label.text = string.format("%d / %d", cur, max)

	local tween = GOUtil.DOScaleAll(self.txt_label.transform, 2, SPEED)

	GOUtil.SetTweenerCallback(tween, function()
		GOUtil.DOScaleAll(self.txt_label.transform, 1, SPEED)
	end)
end

function CellHpBar:Minus(val)
	self.curVal = self.curVal - val

	if self.curVal < 0 then
		self.curVal = 0
	end

	self:Refresh(self.curVal, self.maxVal)
end

function CellHpBar:RefreshHeadIcon(path)
	UIUtil.SetImageSprite(self.img_headIcon, path)
end
