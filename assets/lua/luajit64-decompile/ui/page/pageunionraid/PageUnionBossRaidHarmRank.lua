-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionRaid/PageUnionBossRaidHarmRank.lua

require("UI/Page/PageUnionRaid/CellUnionBossRaidHarm")

PageUnionBossRaidHarmRank = class("PageUnionBossRaidHarmRank", UIPanel)

function PageUnionBossRaidHarmRank:ctor()
	self.UIPrefabPath = "UI/PanelUnionRaid/PanelUnionBossRaidHarmRank"

	self:AddChildPanel(DlgExit(), {
		title = _("Desc_From_19_5"),
		callback = self.OnBack,
		helpCallback = self.OnClickedBtnGuide,
		panel = self
	})

	self.ListHarmRank = {}
	self.IsMaintain = false
end

function PageUnionBossRaidHarmRank:PreLoad()
	self:LoadResAsync("UI/PanelUnionRaid/CellUnionBossRaidHarm", "PrefabCell", GameObject)
end

function PageUnionBossRaidHarmRank:OnBack()
	UIMgr.PopPanel()
end

function PageUnionBossRaidHarmRank:Purge()
	self.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function PageUnionBossRaidHarmRank:OnRegisterEvent()
	return
end

function PageUnionBossRaidHarmRank:OnUnRegisterEvent()
	for i = 1, #UnionRaidMgr.listBossRaid do
		self:RemoveClick(self["BtnTab" .. i], self.OnClickedTab)
	end
end

function PageUnionBossRaidHarmRank:OnEnter(index)
	local safeArea = self:GetChildGameObject("SafeArea")

	self:SetSafeArea(safeArea)

	self.preTabIdx = index or 1
	self.curTabIdx = index or 1
	self.GoRank = self:GetChildGameObject("SafeArea/Rank")
	self.GoMine = self:GetChildGameObject("SafeArea/Mine")
	self.GoMaintain = self:GetChildGameObject("SafeArea/Maintain")
	self.TextNone = self:GetChildComponent("SafeArea/TextNone", "Text")
	self.TextNone.text = _("Desc_Union_Boss_Harm_Rank_None")

	self:InitTab()
	self:InitMine()
	self:InitScroll()
	self:UpdatePanel()
end

function PageUnionBossRaidHarmRank:InitTab()
	local content = self:GetChildGameObject("SafeArea/TabGroup/Content")
	local obj = self:GetChildGameObject("SafeArea/TabGroup/Content/1")
	local txt, lock, open

	for i = 1, #UnionRaidMgr.listBossRaid do
		if i ~= 1 then
			obj = GOUtil.InstantiateUI(obj, content)
			obj.name = i
		end

		self["BtnTab" .. i] = obj
		self["SelTab" .. i] = GOUtil.FindChildGameObject(obj, "Sel")
		txt = GOUtil.FindChildComponent(obj, "Text", "Text")
		txt.text = string.format(_("Mirror_report_1"), _("ecNum_" .. i))
		lock = GOUtil.FindChildGameObject(obj, "Lock")
		open = UnionRaidMgr.IsBossOpenOfFloor(i)

		GOUtil.SetActive(lock, not open)
		self:AddClick(self["BtnTab" .. i], self.OnClickedTab)
	end
end

function PageUnionBossRaidHarmRank:OnClickedTab(eventData)
	local index = tonumber(eventData.pointerPress.name)
	local isOpen = UnionRaidMgr.IsBossOpenOfFloor(index)

	if not isOpen then
		UIMgr.ShowMsg(_("Tip_Mirror_close"))

		return
	end

	if self.curTabIdx == index then
		return
	end

	self.preTabIdx = self.curTabIdx
	self.curTabIdx = index

	self:UpdatePanel()
end

function PageUnionBossRaidHarmRank:InitMine()
	local txt = self:GetChildComponent("SafeArea/Mine/Text", "Text")

	txt.text = _("Desc_MyInfo")

	local cell = self:GetChildGameObject("SafeArea/Mine/Cell")

	self.CellMine = CellUnionBossRaidHarm()

	self.CellMine:InitItemByRoot(cell)
end

function PageUnionBossRaidHarmRank:InitScroll()
	local scrollArea = self:GetChildGameObject("SafeArea/Rank/ScrollArea")
	local content = self:GetChildComponent("SafeArea/Rank/ScrollArea/Content", "Transform")

	local function addCellCallback(item)
		return
	end

	local function updateCellCallback(item, index)
		local data = self.ListHarmRank[self.curTabIdx].list[index]

		item:UpdateData(data)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, 0, self.PrefabCell, CellUnionBossRaidHarm, self, false, addCellCallback, updateCellCallback)
end

function PageUnionBossRaidHarmRank:UpdatePanel()
	self:UpdateTab()
	self:DealRankData()
end

function PageUnionBossRaidHarmRank:UpdateTab()
	GOUtil.SetActive(self["SelTab" .. self.preTabIdx], false)
	GOUtil.SetActive(self["SelTab" .. self.curTabIdx], true)
end

function PageUnionBossRaidHarmRank:DealRankData()
	if self.ListHarmRank[self.curTabIdx] then
		local curServerTime = NetData:GetCurServerTime()

		if (curServerTime - self.ListHarmRank[self.curTabIdx].time) / DateUtil.MillsPerSecond < 60 then
			self:UpdateRankList()

			return
		end
	end

	local raidId = UnionRaidMgr.listBossRaid[self.curTabIdx].id

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			local t, temp = {}, {}

			for k, v in ipairs(vMsg.ranks) do
				temp = {
					index = k,
					player = v
				}

				table.insert(t, temp)
			end

			local data = {}

			data.time = NetData:GetCurServerTime()
			data.list = t
			self.ListHarmRank[self.curTabIdx] = data
			self.IsMaintain = false
		elseif vMsg.result.code == NetManager.Result_Maintain then
			self.IsMaintain = true
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end

		self:UpdateRankList()
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestUnionBossRaidHarmRank(raidId, wrap_cb)
end

function PageUnionBossRaidHarmRank:UpdateRankList()
	if self.IsMaintain then
		if not self.IsSetMaintain then
			GOUtil.SetActive(self.GoMine, false)
			GOUtil.SetActive(self.GoMaintain, true)

			self.GoRank.offsetMin = Vector2.New(self.GoRank.offsetMin.x, 48)

			self.UIScrollTool:UpdateListData({})

			self.IsSetMaintain = true
		end

		return
	elseif self.IsSetMaintain then
		GOUtil.SetActive(self.GoMine, true)
		GOUtil.SetActive(self.GoMaintain, false)

		self.GoRank.offsetMin = Vector2.New(self.GoRank.offsetMin.x, 245)

		self.UIScrollTool.ScrollView.SetViewBounds()

		self.IsSetMaintain = false
	end

	local list = self.ListHarmRank[self.curTabIdx] and self.ListHarmRank[self.curTabIdx].list or {}

	if next(list) == nil then
		GOUtil.SetActive(self.TextNone, true)
		self.UIScrollTool:UpdateListData({})
		self.CellMine:UpdateData(nil, true)

		return
	end

	GOUtil.SetActive(self.TextNone, false)
	self.UIScrollTool:UpdateListData(list)

	local data

	for _, v in ipairs(list) do
		if v.player.playerId == PlayerInst.InfoPlayer.pid then
			data = v

			break
		end
	end

	self.CellMine:UpdateData(data, true)
end

function PageUnionBossRaidHarmRank:OnClickedBtnGuide()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.UnionRaid)
end
