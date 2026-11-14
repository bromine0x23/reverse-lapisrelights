-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOtherMenu/PageCopyright.lua

require("UI/UIScrollTool")
require("UI/Page/PagePay/RuleCell")

PageCopyright = class("PageCopyright", UIPanel)

function PageCopyright:ctor()
	PageCopyright.base.ctor(self, "UI/PageOtherMenu/PageCopyright")
end

function PageCopyright:PreLoad()
	return
end

function PageCopyright:Cache()
	PageCopyright.base.Cache(self)
end

function PageCopyright:Purge()
	PageCopyright.base.Purge(self)
end

function PageCopyright:OnPageLoaded()
	return
end

function PageCopyright:OnEnter()
	self.btnClose = self:GetChildGameObject("Panel/mode_2/close")
	self.btnBack = self:GetChildGameObject("Panel/Bg/content/btn_back")
	self.content_scollrect = self:GetChildGameObject("Panel/Bg/content/ScrollArea")
	self.content_txt = self:GetChildComponent("Panel/Bg/content/ScrollArea/Viewport/Content", "UILongScrollItem")
	self:GetChildComponent("Panel/title/text", "Text").text = _("PageOtherMenu_Copyright_Title")

	local copyRight = require("luaData/m_copyright")

	self.content_txt:Init()

	for k, v in pairs(copyRight) do
		strVal = v.value
		strVal = tostring(string.gsub(strVal, "\\n", "\n"))

		print(strVal)

		if v.type == "img" then
			self.content_txt:AddImage(strVal)
		elseif v.type == "text" then
			self.content_txt:AddText(strVal)
		end
	end

	local vlg = self:GetChildComponent("Panel/Bg/content/ScrollArea/Viewport/Content", "VerticalLayoutGroup")

	vlg:CalculateLayoutInputHorizontal()
end

function PageCopyright:OnClickTop()
	GOUtil.SetScrollPosInt(self.content_scollrect)
end

function PageCopyright:OnRegisterEvent()
	self:AddClick(self.btnClose, self.Close, PATH_SFX_UI_Click)
	self:AddClick(self.btnBack, self.OnClickTop, PATH_SFX_UI_Click)
end

function PageCopyright:OnUnRegisterEvent()
	self:RemoveClick(self.btnClose, self.Close)
	self:RemoveClick(self.btnBack, self.OnClickTop)
end

function PageCopyright:Close()
	PageCopyright.base.Close(self)
end

function PageCopyright:OnBackAndroid()
	self:Close()
end
