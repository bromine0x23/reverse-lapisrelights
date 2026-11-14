-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFriend/DlgBlackPanel.lua

DlgBlackPanel = class("DlgBlackPanel", UIPanel)

function DlgBlackPanel:ctor()
	self.UIPrefabPath = "UI/PanelFriend/PanelBlack"
end

function DlgBlackPanel:PreLoad()
	self.PrefabCell = ResourceMgr.LoadSync("UI/PanelFriend/CellFriend")
end

function DlgBlackPanel:Purge()
	self.base.Purge(self)
	self:OnLeave()
end

function DlgBlackPanel:OnLeave()
	ResourceMgr.Unload(self.PrefabCell)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end
end

function DlgBlackPanel:OnRegisterEvent()
	return
end

function DlgBlackPanel:OnUnRegisterEvent()
	return
end

function DlgBlackPanel:OnEnter(vParam)
	local Text = self:GetChildComponent("Panel/Title/Text", "Text")

	Text.text = Lang(12500)
	self.TextBlackCnt = self:GetChildComponent("Panel/Title/TextCount", "Text")
end

function DlgBlackPanel:Show()
	SetActiveFunc(self.UIRootObject, true)
	self:UpdatePanel()
end

function DlgBlackPanel:Hide()
	SetActiveFunc(self.UIRootObject, false)
end

function DlgBlackPanel:UpdatePanel()
	self.listBlack = FriendMgr:GetBlackList()
	self.TextBlackCnt.text = "(" .. #self.listBlack .. "/" .. FriendMgr.maxBlackNum .. ")"

	if not self.inited then
		self:InitBlackList()

		self.inited = true
	else
		self.UIScrollTool:UpdateListDataKeepPos(self.listBlack)
	end
end

function DlgBlackPanel:InitBlackList()
	local scrollArea = self:GetChildGameObject("Panel/Result/BgScroll/ScrollArea")
	local content = self:GetChildComponent("Panel/Result/BgScroll/ScrollArea/Content", "RectTransform")
	local count = #self.listBlack

	local function cb()
		self:UpdatePanel()
	end

	local function addCallback(item)
		self:AddClick(item.UIRootObject, nil)
	end

	local function updateCallback(item, index)
		local infoPlayer = self.listBlack[index]

		item:UpdateData(infoPlayer, eFLType.black, cb)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCell, CellFriend, self, false, addCallback, updateCallback)
end
