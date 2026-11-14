-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePlayerInfo/PageHead.lua

require("UI.Page.PagePlayerInfo.CellHead")

PageHead = class("PageHead", UIPanel)

local InfoTitle = require("Info/InfoTitle")

function PageHead:ctor()
	self.UIPrefabPath = "UI/PanelPlayerInfo/PanelHead"
end

function PageHead:PreLoad()
	self:LoadResAsync("UI/PanelPlayerInfo/CellHead", "cellHeadPreLoad", GameObject)
end

function PageHead:Purge()
	PageHead.base.Purge(self)

	if self.cellHeadPreLoad then
		ResourceMgr.Unload(self.cellHeadPreLoad)

		self.cellHeadPreLoad = nil
	end

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.uiTab then
		self.uiTab:Dispose()
	end
end

function PageHead:OnRegisterEvent()
	self:AddClick(self.BtnQuit, self.OnClickedBtnQuit)
	Event.Instance:Add(EventEnum.UpdatePlayerInfo, self.UpdatePlayerInfo, self)
end

function PageHead:OnUnRegisterEvent()
	self:RemoveClick(self.BtnQuit, self.OnClickedBtnQuit)
	Event.Instance:Remove(EventEnum.UpdatePlayerInfo, self.UpdatePlayerInfo, self)
end

function PageHead:UpdatePlayerInfo(_type)
	if _type == ePlayerInfoType.head then
		self:OnChangePlayerHead()
	elseif _type == ePlayerInfoType.headFrame then
		self:OnChangePlayerHeadFrame()
	end
end

function PageHead:OnChangePlayerHead()
	self.UIScrollTool:UpdateListDataKeepPos(self.listData[1])
end

function PageHead:OnChangePlayerHeadFrame()
	self.UIScrollTool:UpdateListDataKeepPos(self.listData[2])
end

function PageHead:OnEnter(vParam)
	self:DealWithLocalization()

	self.BtnQuit = self:GetChildGameObject("Panel/btn_close")
	self.tabGo = self:GetChildGameObject("Panel/Tab")

	if PlayerInst.tabIndex ~= 0 then
		self.uiTab = UITab(self.tabGo, 2, self.TabClick, self, PlayerInst.tabIndex)
	else
		self.uiTab = UITab(self.tabGo, 2, self.TabClick, self, 1)
	end

	if vParam and vParam.headId then
		self.headId = vParam.headId
	end

	self:InitData()
	self:InitScroll()
	self:HeadDot()

	PlayerInst.showHead = false
end

function PageHead:TabClick()
	PlayerInst.tabIndex = self.uiTab.index

	self.UIScrollTool:SetContentPosImmediate(Vector2.New(0, 0), self.listData[self.uiTab.index])
	self:HeadDot()
end

function PageHead:HeadDot()
	if self.uiTab.index == 1 then
		TitleRDL.RemovePlayerPrefs(PLAYER_TITLE_TYPE.Head)
	else
		TitleRDL.RemovePlayerPrefs(PLAYER_TITLE_TYPE.Frame)
	end
end

function PageHead:DealWithLocalization()
	local Text = self:GetChildComponent("Panel/Title/Text", "Text")

	Text.text = _("Head_Change_Exterior")
	Text = self:GetChildComponent("Panel/Tab/Btn1/Btn/Text", "Text")
	Text.text = _("Head_Avatar")
	Text = self:GetChildComponent("Panel/Tab/Btn1/Select/Text", "Text")
	Text.text = _("Head_Avatar")
	Text = self:GetChildComponent("Panel/Tab/Btn2/Btn/Text", "Text")
	Text.text = _("Head_Frame")
	Text = self:GetChildComponent("Panel/Tab/Btn2/Select/Text", "Text")
	Text.text = _("Head_Frame")
end

function PageHead:InitData()
	self.listData = {
		InfoTitle:GetHeadData(),
		(InfoTitle:GetHeadFrameData())
	}
end

function PageHead:InitScroll()
	local function ListUpdate(item, index)
		local data = self.listData[self.uiTab.index][index]

		item:UpdateData(data, self.uiTab.index, self)
	end

	self.ScrollArea = self:GetChildGameObject("Panel/ScrollArea")

	local content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")
	local count = #self.listData[self.uiTab.index]

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.ScrollArea, content, count, self.cellHeadPreLoad, CellHead, self, false, nil, ListUpdate)

	if self.headId then
		for i, v in ipairs(self.listData[self.uiTab.index]) do
			if v.cfg.ID == self.headId then
				local pos = GetContentPos(self.UIScrollTool.ScrollView, math.ceil(count / 4), math.ceil(i / 4), true)

				self.UIScrollTool:SetInitPos(Vector3(0, pos, 0))

				break
			end
		end
	end
end

function PageHead:AddCellClick(item)
	return
end

function PageHead:HeadCellClick()
	return
end

function PageHead:OnClickedBtnQuit()
	local isHave = false

	for i = 1, 2 do
		local _, has2 = DotMgr:HasDot(ePSKey.Dot_Player_Head, i)

		if has2 then
			isHave = true
		end
	end

	if not isHave then
		DotMgr:Update(ePSKey.Dot_Player_Head, {
			isNew = false
		})
	end

	self:Close()
end
