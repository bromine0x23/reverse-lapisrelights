-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/PageDistrict.lua

require("UI/Page/PageLogin/PageConnect")

PageDistrict = class("PageDistrict", UIPanel)

function PageDistrict:ctor()
	self.serData = nil

	PageDistrict.base.ctor(self, "UI/PageLogin/PanelSelDistrict")
end

function PageDistrict:Purge()
	PageDistrict.base.Purge(self)
end

function PageDistrict:OnPageLoaded()
	return
end

function PageDistrict:OnEnter()
	self.PanelList = GOUtil.FindChildGameObject(self.UIRootObject, "PanelList")
	self.BtnShowList = GOUtil.FindChildComponent(self.UIRootObject, "PanelSet/BtnShowList", "Button")
	self.BtnStart = self:GetChildComponent("BtnStart", "Button")
	self.PanelSet = self:GetChildGameObject("PanelSet")
	self.PanelRecommend = self:GetChildGameObject("PanelList/PanelServers/Image/PanelRecommend")
	self.Bg = GOUtil.FindChildGameObject(self.UIRootObject, "Bg")
	self.PanelSet = self:GetChildGameObject("PanelSet")
	self.PanelTip = self:GetChildGameObject("PanelTip")
	self.PanelNotice = self:GetChildGameObject("PanelNotice")
	self.TextNotice = self:GetChildComponent("PanelNotice/Panel/Text", "Text")
	self.BgNotice = self:GetChildGameObject("PanelNotice/Bg")

	self.PanelNotice:SetActive(false)

	self.PanelNoticeTop = self:GetChildGameObject("PanelNoticeTop")
	self.TextNoticeTop = self:GetChildComponent("PanelNoticeTop/Panel/Text", "Text")
	self.BgNoticeTop = self:GetChildGameObject("PanelNoticeTop/Bg")

	self.PanelNoticeTop:SetActive(false)
	self.PanelList:SetActive(false)
	self:RequestServerList()
	self:InitList()
end

function PageDistrict:OnLeave()
	self.PanelList = nill
	self.BtnShowList = nil
	self.BtnStart = nil
	self.PanelSet = nil
	self.PanelRecommend = nil
	self.Bg = nil
	self.ScrollArea = nil
	self.ScrollView = nil
	self.ScrollServers = nil
	self.ScrollServersView = nil
	self.YInitPos = nil
end

function PageDistrict:InitList()
	self.ScrollArea = self:GetChildGameObject("PanelList/PanelArea/ScrollArea")
	self.ScrollView = GOUtil.AddMissingComponent(self.ScrollArea, "UIScrollView")
	self.ScrollView.vertical = true
	self.ScrollView.content = self:GetChildComponent("PanelList/PanelArea/ScrollArea/Content", "Transform")
	self.ScrollServers = self:GetChildGameObject("PanelList/PanelServers/ScrollServers")
	self.ScrollServersView = GOUtil.AddMissingComponent(self.ScrollServers, "UIScrollView")
	self.ScrollServersView.vertical = true
	self.ScrollServersView.content = self:GetChildComponent("PanelList/PanelServers/ScrollServers/Content", "Transform")
end

function PageDistrict:UpdateScrollAreaData()
	GOUtil.DestroyAllChildren(self.ScrollView.content.gameObject)

	self.serData = self.serInfo.data

	local list = self.serData.list

	for i = 0, list.Count - 1 do
		local g = GOUtil.InstantiatePrefab(ResourceMgr:LoadSyncLua("UI/PageLogin/CellServer"), self.ScrollView.content.gameObject)
		local img = GOUtil.AddMissingComponent(g, "Image")

		if i == self.serData.selfArea then
			UIUtil.SetImageSprite(img, "UIDyAtlas/Login/ui_btn_bluebg03@2x", false)
		else
			UIUtil.SetImageSprite(img, "UIDyAtlas/Login/ui_btn_bluebg02@2x", false)
		end

		local serverText = GOUtil.FindChildComponent(g, "Text", "Text")

		serverText.text = list:get_Item(i).name
		g.name = i

		local scrollviewContent = GOUtil.AddMissingComponent(g, "UIScrollViewContent")

		scrollviewContent.scrollView = self.ScrollView

		self:AddClick(g, self.OnClickSelDistrict)
	end
end

function PageDistrict:UpdateScrollServerData(selIndex)
	GOUtil.DestroyAllChildren(self.ScrollServersView.content.gameObject)

	self.serData = self.serInfo.data

	local list = self.serData.list
	local dist = list:get_Item(selIndex)
	local listData = dist.listData

	for i = 0, listData.Count - 1 do
		local info = listData:get_Item(i)
		local g = GOUtil.InstantiatePrefab(ResourceMgr:LoadSyncLua("UI/PageLogin/CellServerInfo"), self.ScrollServersView.content.gameObject)

		g.name = tostring(info.id)

		local panelSet = GOUtil.FindChildGameObject(g, "PanelSet")
		local textAera = GOUtil.FindChildComponent(panelSet, "TextAera", "Text")
		local textServer = GOUtil.FindChildComponent(panelSet, "TextServer", "Text")

		textAera.text = dist.name
		textServer.text = info.name

		local imageStatus = GOUtil.FindChildComponent(panelSet, "ImageStatus", "Image")

		UIUtil.SetImageSprite(imageStatus, "UIDyAtlas/Login/ui_word_server_" .. info.status .. "@2x", false)

		local imageNew = GOUtil.FindChildComponent(panelSet, "ImageNew", "Image")

		imageNew.gameObject:SetActive(info.isNew ~= 0)

		local scrollviewContent = GOUtil.AddMissingComponent(g, "UIScrollViewContent")

		scrollviewContent.scrollView = self.ScrollServersView

		self:AddClick(g, self.OnClickSelServer)
	end
end

function PageDistrict:InitRecommend(go)
	local TextAera = GOUtil.FindChildComponent(go, "TextAera", "Text")
	local TextServer = GOUtil.FindChildComponent(go, "TextServer", "Text")
	local ImageStatus = GOUtil.FindChildComponent(go, "ImageStatus", "Image")

	if self.serInfo == nil then
		return
	end

	self.serData = self.serInfo.data
	self.serDis = self.serData.list:get_Item(self.serData.selfArea)
	self.serList = self.serDis:GetSerList(self.serData.self)
	TextAera.text = self.serDis.name
	TextServer.text = self.serList.name

	UIUtil.SetImageSprite(ImageStatus, "UIDyAtlas/Login/ui_word_server_" .. self.serList.status .. "@2x", false)
end

function PageDistrict:OnClickSelServer(pointEventData)
	local key = pointEventData.pointerPress.name

	self.serDis = self.serData.list:get_Item(self.serData.selfArea)

	local ser = self.serDis:GetSerList(key)

	if ser.status == 4 then
		return
	end

	self.serData.self = key

	self:OnQuitPanelList()
end

function PageDistrict:OnClickSelDistrict(pointEventData)
	local index = tonumber(pointEventData.pointerPress.name)

	self.serData.selfArea = index

	self:UpdateScrollAreaData()
	self:UpdateScrollServerData(index)
end

function PageDistrict:RequestServerList()
	LoadingMgr.Show(eLoadingType.Repeat)

	local function wrap(obj)
		self:OnGetServerList(obj)
	end

	if NetManager.SDKToken == nil then
		NetManager.SDKToken = ""
	end

	NetManager:GetServerList(wrap)
end

function PageDistrict:OnGetServerList(obj)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if obj == nil then
		print("OnGetServerList null")
		self:RequestServerList()
	else
		self:MoveLogo()
		print("OnGetServerList:" .. obj.code .. " d:" .. obj.desc)

		if obj.code == 0 then
			self.PanelSet:SetActive(true)
			self.PanelTip:SetActive(false)
			self.BtnStart.gameObject:SetActive(true)

			self.serInfo = obj

			self:UpdateScrollAreaData()
			self:UpdateScrollServerData(0)
			self:InitRecommend(self.PanelSet)

			NetManager.certify = obj.certify

			if obj.news == nil or obj.news == "" then
				-- block empty
			else
				self.TextNoticeTop.text = obj.news

				self.PanelNoticeTop:SetActive(true)
			end
		else
			print("obj.desc:" .. obj.desc)

			self.TextNotice.text = obj.desc

			self.PanelNotice:SetActive(true)
		end
	end
end

function PageDistrict:OnQuitNoticeTop()
	print("OnQuitNoticeTop")
	self.PanelNoticeTop:SetActive(false)
end

function PageDistrict:OnQuitNotice()
	print("OnQuitNotice")
	self.PanelNotice:SetActive(false)
	self:RequestServerList()
end

function PageDistrict:OnLoginClicked()
	return
end

function PageDistrict:OnRegisterEvent()
	self:AddClick(self.BtnShowList.gameObject, self.OnBtnShowList)
	self:AddClick(self.BtnStart.gameObject, self.OnBtnStart)
	self:AddClick(self.Bg, self.OnQuitPanelList)
	self:AddClick(self.BgNotice, self.OnQuitNotice)
	self:AddClick(self.BgNoticeTop, self.OnQuitNoticeTop)
end

function PageDistrict:OnUnRegisterEvent()
	self:RemoveClick(self.BtnShowList.gameObject, self.OnBtnShowList)
	self:RemoveClick(self.BtnStart.gameObject, self.OnBtnStart)
	self:RemoveClick(self.Bg, self.OnQuitPanelList)
	self:RemoveClick(self.BgNotice, self.OnQuitNotice)
	self:RemoveClick(self.BgNoticeTop, self.OnQuitNoticeTop)
end

function PageDistrict:OnBtnShowList()
	self.PanelList:SetActive(true)
	self.PanelSet:SetActive(false)
	self.BtnStart.gameObject:SetActive(false)
	self:UpdateScrollAreaData()
	self:UpdateScrollServerData(self.serData.selfArea)
	self:InitRecommend(self.PanelRecommend)
end

function PageDistrict:OnQuitPanelList()
	self.PanelList:SetActive(false)
	self.PanelSet:SetActive(true)
	self.BtnStart.gameObject:SetActive(true)
	self:InitRecommend(self.PanelSet)
end

function PageDistrict:OnBtnStart()
	if self.serData == nil or self.serData.list == nil or self.serData.list.Count < 1 then
		self:RequestServerList()

		return
	end

	self.serDis = self.serData.list:get_Item(self.serData.selfArea)
	self.serList = self.serDis:GetSerList(self.serData.self)
	NetManager.Host = self.serList.host
	NetManager.Port = self.serList.port
	NetData.ServerName = self.serList.name
	NetData.ServerID = self.serData.self

	UIMgr.SwitchPanel(PageConnect)
end

function PageDistrict:MoveLogo()
	local logoRT = self:GetChildComponent("Eff_UI_Loading_Temp/Tuceng/Logo", "RectTransform")

	if logoRT == nil then
		return
	end
end
