-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgFightGuide.lua

DlgFightGuide = class("DlgFightGuide", UIPanel_sync)

function DlgFightGuide:ctor()
	DlgFightGuide.base.ctor(self, "UI/PageFight/Dlg/DlgFightGuide")
end

function DlgFightGuide:Cache()
	DlgFightGuide.base.Cache(self)
end

function DlgFightGuide:Close()
	DlgFightGuide.base.Close(self)
end

function DlgFightGuide:Purge()
	DlgFightGuide.base.Purge(self)
end

function DlgFightGuide:OnEnter(vParam)
	self.Btnclose = self:GetChildGameObject("Btnclose")
	self.Btn = {}
	self.Sel = {}

	for i = 1, 5 do
		self.Btn[i] = self:GetChildGameObject("Group/" .. i .. "/Btn")
		self.Sel[i] = self:GetChildGameObject("Group/" .. i .. "/Sel")
	end

	self.txt_title = self:GetChildComponent("bg1/txt_title", "Text")
	self.Image = self:GetChildComponent("Image", "RawImage")
	self.Btn_Left = self:GetChildGameObject("Arrow/Left")
	self.Btn_Right = self:GetChildGameObject("Arrow/Right")
	self.groupIdx = 1
	self.tabIdx = 1

	self:UpdateData(self.tabIdx)
	self:UpdateArrow()
end

function DlgFightGuide:OnRegisterEvent()
	self:AddClick(self.Btnclose, self.OnBtnClose)

	for i = 1, 5 do
		self:AddClick(self.Btn[i], self.OnClickTabList)
		self:AddClick(self.Sel[i], self.OnClickTabList)
	end

	self:AddClick(self.Btn_Left, self.OnClickLeft)
	self:AddClick(self.Btn_Right, self.OnClickRight)
end

function DlgFightGuide:OnUnRegisterEvent()
	self:RemoveClick(self.Btnclose, self.OnBtnClose)

	for i = 1, 5 do
		self:RemoveClick(self.Btn[i], self.OnClickTabList)
		self:RemoveClick(self.Sel[i], self.OnClickTabList)
	end

	self:RemoveClick(self.Btn_Left, self.OnClickLeft)
	self:RemoveClick(self.Btn_Right, self.OnClickRight)
end

function DlgFightGuide:OnBtnClose()
	DlgFightGuide.base.Close(self)
end

function DlgFightGuide:OnClickTabList(data)
	local go = data.pointerPress.transform.parent.gameObject
	local index = tonumber(go.name)

	self.tabIdx = index

	self:UpdateData(index)
	self:UpdateArrow()
end

function DlgFightGuide:UpdateData(index)
	for i = 1, 5 do
		self:GetChildGameObject("Group/" .. i .. "/Btn"):SetActive(true)
		self:GetChildGameObject("Group/" .. i .. "/Sel"):SetActive(false)
	end

	self:GetChildGameObject("Group/" .. index .. "/Btn"):SetActive(false)
	self:GetChildGameObject("Group/" .. index .. "/Sel"):SetActive(true)

	self.groupIdx = 1
end

function DlgFightGuide:OnClickLeft()
	self.groupIdx = math.max(1, self.groupIdx - 1)

	self:UpdateArrow()
end

function DlgFightGuide:OnClickRight()
	self.groupIdx = math.min(self.groupIdx + 1, 8)

	self:UpdateArrow()
end

function DlgFightGuide:UpdateArrow()
	if self.tabIdx == 1 then
		self.Btn_Left:SetActive(false)
		self.Btn_Right:SetActive(false)
		UIUtil.SetRawImageTexture(self.Image, "Texture/Guide/guid_021", self)

		self.txt_title.text = _("Desc_FightGuide") .. "(1/1)"
	elseif self.tabIdx == 2 then
		self.Btn_Left:SetActive(false)
		self.Btn_Right:SetActive(false)

		if self.groupIdx == 1 then
			self.Btn_Right:SetActive(true)
		elseif self.groupIdx == 3 then
			self.Btn_Left:SetActive(true)
		else
			self.Btn_Left:SetActive(true)
			self.Btn_Right:SetActive(true)
		end

		if self.groupIdx == 1 then
			UIUtil.SetRawImageTexture(self.Image, "Texture/Guide/guid_022", self)

			self.txt_title.text = _("Desc_FightGuide") .. "(" .. self.groupIdx .. "/3)"
		elseif self.groupIdx == 2 then
			UIUtil.SetRawImageTexture(self.Image, "Texture/Guide/guid_023", self)

			self.txt_title.text = _("Desc_FightGuide") .. "(" .. self.groupIdx .. "/3)"
		else
			UIUtil.SetRawImageTexture(self.Image, "Texture/Guide/guid_024", self)

			self.txt_title.text = _("Desc_FightGuide") .. "(" .. self.groupIdx .. "/3)"
		end
	elseif self.tabIdx == 3 then
		self.Btn_Left:SetActive(false)
		self.Btn_Right:SetActive(false)

		if self.groupIdx == 1 then
			self.Btn_Right:SetActive(true)
		elseif self.groupIdx == 2 then
			self.Btn_Left:SetActive(true)
		end

		if self.groupIdx == 1 then
			UIUtil.SetRawImageTexture(self.Image, "Texture/Guide/guid_1202", self)

			self.txt_title.text = _("Desc_FightGuide") .. "(" .. self.groupIdx .. "/2)"
		elseif self.groupIdx == 2 then
			UIUtil.SetRawImageTexture(self.Image, "Texture/Guide/guid_1201", self)

			self.txt_title.text = _("Desc_FightGuide") .. "(" .. self.groupIdx .. "/2)"
		end
	elseif self.tabIdx == 4 then
		self.Btn_Left:SetActive(false)
		self.Btn_Right:SetActive(false)
		UIUtil.SetRawImageTexture(self.Image, "Texture/Guide/guid_1501", self)

		self.txt_title.text = _("Desc_FightGuide") .. "(1/1)"
	elseif self.tabIdx == 5 then
		self.Btn_Left:SetActive(false)
		self.Btn_Right:SetActive(false)

		if self.groupIdx == 1 then
			self.Btn_Right:SetActive(true)
		elseif self.groupIdx == 8 then
			self.Btn_Left:SetActive(true)
		else
			self.Btn_Left:SetActive(true)
			self.Btn_Right:SetActive(true)
		end

		if self.groupIdx == 1 then
			UIUtil.SetRawImageTexture(self.Image, "Texture/Guide/guid_1301", self)

			self.txt_title.text = _("Desc_FightGuide") .. "(" .. self.groupIdx .. "/8)"
		elseif self.groupIdx == 2 then
			UIUtil.SetRawImageTexture(self.Image, "Texture/Guide/guid_1302", self)

			self.txt_title.text = _("Desc_FightGuide") .. "(" .. self.groupIdx .. "/8)"
		elseif self.groupIdx == 3 then
			UIUtil.SetRawImageTexture(self.Image, "Texture/Guide/guid_1303", self)

			self.txt_title.text = _("Desc_FightGuide") .. "(" .. self.groupIdx .. "/8)"
		elseif self.groupIdx == 4 then
			UIUtil.SetRawImageTexture(self.Image, "Texture/Guide/guid_1304", self)

			self.txt_title.text = _("Desc_FightGuide") .. "(" .. self.groupIdx .. "/8)"
		elseif self.groupIdx == 5 then
			UIUtil.SetRawImageTexture(self.Image, "Texture/Guide/guid_1601", self)

			self.txt_title.text = _("Desc_FightGuide") .. "(" .. self.groupIdx .. "/8)"
		elseif self.groupIdx == 6 then
			UIUtil.SetRawImageTexture(self.Image, "Texture/Guide/guid_1602", self)

			self.txt_title.text = _("Desc_FightGuide") .. "(" .. self.groupIdx .. "/8)"
		elseif self.groupIdx == 7 then
			UIUtil.SetRawImageTexture(self.Image, "Texture/Guide/guid_1603", self)

			self.txt_title.text = _("Desc_FightGuide") .. "(" .. self.groupIdx .. "/8)"
		else
			UIUtil.SetRawImageTexture(self.Image, "Texture/Guide/guid_1604", self)

			self.txt_title.text = _("Desc_FightGuide") .. "(" .. self.groupIdx .. "/8)"
		end
	end
end
