-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGvg/DlgGvgChallenge.lua

local _color_img_bk_a = "E6F6F6"
local _color_img_bk_b = "EEEEEE"
local _color_img_line_a = "64B7C5"
local _color_img_line_b = "B4B4B4"
local _color_img_bk_self = "E6F6F6"
local _color_img_line_self = "D3A488"

DlgGvgChallenge = class("DlgGvgChallenge", UIPanel)

function DlgGvgChallenge:ctor()
	self.UIPrefabPath = "UI/PageGvg/DlgGvgChallenge"
end

function DlgGvgChallenge:Purge()
	self.base.Purge(self)
end

function DlgGvgChallenge:OnRegisterEvent()
	self:AddClick(self.BtnClose, self.OnClickedBtnClose, PATH_SFX_UI_CANCEL)
	Event.Instance:Add("EVENT_GVG_MEMBER_AND_LOG", self.OnRecvMsg, self)
end

function DlgGvgChallenge:OnUnRegisterEvent()
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
	Event.Instance:Remove("EVENT_GVG_MEMBER_AND_LOG", self.OnRecvMsg, self)
end

function DlgGvgChallenge:OnEnter(vParam)
	self.isInit = false
	self.BtnClose = self:GetChildGameObject("Panel/Button")
	self.Att = self:GetChildGameObject("Panel/Att")

	self:Item(self.Att, PlayerInst.InfoPlayer, -1)
	Infogvg.net:RequestMembersAndLogs()
end

function DlgGvgChallenge:OnRecvMsg()
	if self.isInit then
		return
	end

	self.isInit = true

	local scrollArea = self:GetChildGameObject("Panel/Attr/ScrollArea")

	GOUtil.AddMissingComponent(scrollArea, "UIScrollView")

	local content = self:GetChildGameObject("Panel/Attr/ScrollArea/Content")
	local list = UnionMemberMgr.listMember

	table.sort(list, function(a, b)
		if a.extras[1] and a.extras[1] then
			return a.extras[1] > b.extras[1]
		else
			return true
		end
	end)

	for i, infoMember in ipairs(list) do
		if infoMember.pid == PlayerInst.InfoPlayer.pid then
			self:Item(self.Att, infoMember, -1)
		end

		local go = GOUtil.Instantiate(self.Att, content)

		self:Item(go, infoMember, i)
	end
end

function DlgGvgChallenge:Item(go, infoMember, idx)
	if not infoMember.pb then
		return
	end

	local imgIcon = GOUtil.FindChildComponent(go, "Icon", "Image")
	local imgFrame = GOUtil.FindChildComponent(go, "Frame", "Image")
	local infoItem = ItemManager:Get(infoMember.pb.headId)

	UIUtil.SetImageSprite(imgIcon, infoItem:GetIcon(), self)

	infoItem = ItemManager:Get(infoMember.pb.headFrame)

	UIUtil.SetImageSprite(imgFrame, infoItem:GetIcon(), self)

	local txtName = GOUtil.FindChildComponent(go, "Image/Text", "Text")
	local txtTimes = GOUtil.FindChildComponent(go, "Text2", "Text")
	local name = infoMember.name
	local max = GetConfigArgInt("GVGDailyTimes")
	local cur = max

	if infoMember.extras and infoMember.extras[1] then
		cur = max - infoMember.extras[1]
	end

	local str = cur .. "/" .. max

	UIUtil.SetTextString(txtName, name)
	UIUtil.SetTextString(txtTimes, str)

	local img_line = GOUtil.FindChildComponent(go, "Image", "Image")
	local img_bk = GOUtil.FindChildComponent(go, "bk", "Image")
	local img = GOUtil.FindChildComponent(go, "Line", "Image")

	if idx == -1 then
		img_bk.color = getColorFromString(_color_img_bk_self)
		img_line.color = getColorFromString(_color_img_line_self)
		img.enabled = false
	elseif idx % 2 == 1 then
		img_bk.color = getColorFromString(_color_img_bk_a)
		img_line.color = getColorFromString(_color_img_line_a)
		img.enabled = true
	else
		img_bk.color = getColorFromString(_color_img_bk_b)
		img_line.color = getColorFromString(_color_img_line_b)
		img.enabled = true
	end
end

function DlgGvgChallenge:OnClickedBtnClose()
	self:Close()
end
