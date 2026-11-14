-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/PageOperationActiveNew.lua

require("UI/Page/PageOperation/CellSpecialItem")
require("UI/Page/PageOperation/CellOpenServiceAward")
require("UI/Page/PageOperation/CellRegisterAward")
require("UI/Page/PageOperation/CellOnLineAward")
require("UI/Page/PageOperation/CellTotalOnLineAward")
require("UI/Page/PageOperation/DlgOperationActiveLogin")
require("UI/Page/PageOperation/DlgOperationActiveLevel")
require("UI/Page/PageOperation/DlgOperationActiveHour")
require("UI/Page/PageOperation/DlgOperationActiveCard")
require("UI/Page/PageOperation/DlgOperationActiveSign")
require("UI/Page/PageOperation/DlgOperationActiveBattlePass")
require("UI/Page/PageOperation/DlgOperationActiveSamllClass")
require("UI/Page/PageOperation/DlgOperationActiveRechargeRebate")
require("UI/Page/PageOperation/DlgOperationActiveBirthday")
require("UI/Page/PageOperation/DlgOperationActivePlayerBirthday")
require("UI/Page/PageOperation/DlgLuckyBackAward")
require("UI/Page/PageOperation/DlgOperationActiveBossActivity")
require("UI/Page/PageOperation/DlgOperationActiveJigsaw")
require("UI/Page/PageOperation/DlgOperationActiveGrowthFund")
require("UI/Page/PageOperation/DlgOperationActiveCommonOne")
require("UI/Page/PageOperation/DlgRoleBirthdayAward")
require("UI/Page/PageOperation/DlgOperationActiveURCardPool")
require("UI/Page/PageCardShop/CellRoleSign")
require("UI/Page/PageRoleCard/Page/PageRoleCard")

PageOperationActiveNew = class("PageOperationActiveNew", UIPanel)

function PageOperationActiveNew:ctor()
	if OperationActiveMgr.PageOperationActiveType == 1 then
		self.UIPrefabPath = "UI/PanelOperation/New/PanelOperationActiveNew"

		self:AddChildPanel(DlgExit(), {
			title = _("eReturn_Operation"),
			callback = self.OnBack,
			panel = self
		})
		self:AddChildPanel(DlgAssetsInfo())
	else
		self.UIPrefabPath = "UI/PanelOperation/New/DlgTipWindowAward"
	end
end

function PageOperationActiveNew:PreLoad()
	self:LoadResAsync("UI/PanelOperation/New/ModelDlg/CellModelType1", "GoCellModelType1", GameObject)
	self:LoadResAsync("UI/PanelOperation/New/ModelDlg/CellSignAward", "GoCellSignAward", GameObject)
	self:LoadResAsync("UI/PanelOperation/New/ModelDlg/CellModelType2", "GoCellModelType2", GameObject)
	self:LoadResAsync("UI/PanelOperation/New/ModelDlg/CellPlayerBirthday", "GoCellPlayerBirthday", GameObject)
	self:LoadResAsync("UI/PanelOperation/New/ModelDlg/CellCommon1", "GoCellCommon1", GameObject)
	self:LoadResAsync("UI/PanelOperation/New/ModelDlg/CellCommon2", "GoCellCommon2", GameObject)
	self:LoadResAsync("UI/PanelOperation/New/ModelDlg/CellCommon3", "GoCellCommon3", GameObject)
	self:LoadResAsync("UI/PanelOperation/New/ModelDlg/CellCommon4", "GoCellCommon4", GameObject)
	self:LoadResAsync("UI/PanelOperation/New/ModelDlg/CellURCardPool", "GoCellURCardPool", GameObject)

	if OperationActiveMgr.PageOperationActiveType == 1 then
		self:LoadResAsync("UI/PanelOperation/New/ModelDlg/CellHourAward", "GoCellHourAward", GameObject)
		self:LoadResAsync("UI/PanelOperation/New/ModelDlg/CellSmallClassTask", "GoCellSmallClassTask", GameObject)
		self:LoadResAsync("UI/PanelOperation/New/ModelDlg/CellBattlePassAwardNew", "GoCellBattlePassAwardNew", GameObject)
		self:LoadResAsync("UI/PanelOperation/New/ModelDlg/CellBattlePassTask", "GoCellBattlePassTask", GameObject)
	end
end

function PageOperationActiveNew:Purge()
	if self.timer ~= nil then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end

	if IsNil(self.UIRootObject) then
		return
	end

	self.base.Purge(self)

	if self.panelList then
		for k, v in pairsByKeys(self.panelList) do
			v:Purge()

			self.panelList[k] = nil
		end
	end

	if self.GoCellModelType1 then
		ResourceMgr.Unload(self.GoCellModelType1)

		self.GoCellModelType1 = nil
	end

	if self.GoCellModelType2 then
		ResourceMgr.Unload(self.GoCellModelType2)

		self.GoCellModelType2 = nil
	end

	if self.GoCellSignAward then
		ResourceMgr.Unload(self.GoCellSignAward)

		self.GoCellSignAward = nil
	end

	if self.GoCellHourAward then
		ResourceMgr.Unload(self.GoCellHourAward)

		self.GoCellHourAward = nil
	end

	if self.GoCellSmallClassTask then
		ResourceMgr.Unload(self.GoCellSmallClassTask)

		self.GoCellSmallClassTask = nil
	end

	if self.GoCellBattlePassAwardNew then
		ResourceMgr.Unload(self.GoCellBattlePassAwardNew)

		self.GoCellBattlePassAwardNew = nil
	end

	if self.GoCellBattlePassTask then
		ResourceMgr.Unload(self.GoCellBattlePassTask)

		self.GoCellBattlePassTask = nil
	end

	if self.GoCellPlayerBirthday then
		ResourceMgr.Unload(self.GoCellPlayerBirthday)

		self.GoCellPlayerBirthday = nil
	end

	if self.listGoTap then
		for _, v in pairsByKeys(self.listGoTap) do
			local btn = GOUtil.FindChildGameObject(v.obj, "Button")

			self:RemoveClick(btn, self.OnClickedTap)
		end

		GOUtil.DestroyAllChildren(self.TapGroup)

		self.listGoTap = nil
	end

	if self.listGoModel then
		GOUtil.DestroyAllChildren(self.ModelGroup)

		self.listGoModel = nil
	end

	TaskManager.battlePassPayList = {}
	TaskManager.signAwardDouble = false

	InfoSoundEventMgr:OnBack()
end

function PageOperationActiveNew:OnBack()
	UIMgr.PopPanel()
	UITweenUtil.RemoveTween(self.TapGroup.transform)
end

function PageOperationActiveNew:OnRegisterEvent()
	if OperationActiveMgr.PageOperationActiveType == 2 then
		self:AddClick(self.btn_day_show, self.OnClickedDayShow)
	end

	self:AddClick(self.Btn_close, self.OnClickedClose)
	Event.Instance:Add("ReceiveOperationActiveAward", self.ReceiveOperationActiveAward, self)
	Event.Instance:Add("ReceiveOperationActiveAwardList", self.ReceiveOperationActiveAwardList, self)
	Event.Instance:Add("UpdateOperationActive", self.UpdateOperation, self)
	Event.Instance:Add("OperationActiveSignRetroactive", self.OperationActiveSignRetroactive, self)
	Event.Instance:Add("TaskCompleteUpdate", self.UpdatePanelAfterTaskComplete, self)
	Event.Instance:Add("DealWithCompleteTask", self.RequestReceiveTaskAward, self)
	Event.Instance:Add("OperationActiveJump", self.JumpTap, self)
	Event.Instance:Add(EventEnum.UpdateItemDataNotify, self.UpdateItemDataNotify, self)
end

function PageOperationActiveNew:OnUnRegisterEvent()
	self:RemoveClick(self.Btn_close, self.OnClickedClose)

	if OperationActiveMgr.PageOperationActiveType == 2 then
		self:RemoveClick(self.btn_day_show, self.OnClickedDayShow)
	end

	Event.Instance:Remove("ReceiveOperationActiveAward", self.ReceiveOperationActiveAward, self)
	Event.Instance:Remove("ReceiveOperationActiveAwardList", self.ReceiveOperationActiveAwardList, self)
	Event.Instance:Remove("UpdateOperationActive", self.UpdateOperation, self)
	Event.Instance:Remove("OperationActiveSignRetroactive", self.OperationActiveSignRetroactive, self)
	Event.Instance:Remove("TaskCompleteUpdate", self.UpdatePanelAfterTaskComplete, self)
	Event.Instance:Remove("DealWithCompleteTask", self.RequestReceiveTaskAward, self)
	Event.Instance:Remove("OperationActiveJump", self.JumpTap, self)
	Event.Instance:Remove(EventEnum.UpdateItemDataNotify, self.UpdateItemDataNotify, self)
end

function PageOperationActiveNew:JPNotShowSiginThatCurrDSmallThanGameServerStartDay()
	local keys = {}

	for k, v in pairsByKeys(self.listOpenActive) do
		if tonumber(v.data.Type) == eOperationActiveType.Sign and OperationActiveMgr:JPIsCurrDaySmallThanGameStartDay() then
			table.insert(keys, k)
		end
	end

	for k, v in pairsByKeys(keys) do
		table.remove(self.listOpenActive, v)
	end
end

function PageOperationActiveNew:OnEnter(vParam)
	self:Init(vParam)

	self.listOpenActive = OperationActiveMgr:GetListOpenActive()

	if OperationActiveMgr.PageOperationActiveType == 2 then
		self.listOpenActive = OperationActiveMgr:AllLoginPopupList()

		SetActiveFunc(self.UIRootObject.gameObject, false)

		self.btn_day_show = self:GetChildGameObject("btn_day_show")

		local AotuText = self:GetChildComponent("btn_day_show/Text", "Text")

		AotuText.text = _("Desc_ToDay_No_Tips")
		self.go_day_show_sel = self:GetChildGameObject("btn_day_show/go_sel")

		SetActiveFunc(self.go_day_show_sel, RoleCardMgr:GetTipWindowPatFaceState() == "0")
	else
		self:SetSafeArea(self:GetChildGameObject("SafeArea"))

		local list = {}

		for k, v in pairsByKeys(self.listOpenActive) do
			if v and tonumber(v.data.UIType) ~= eOperationActive.BossActivity then
				table.insert(list, v)
			end
		end

		self.listOpenActive = list
		self.timer = TimerMgr.AddTimer(eTimerType.RealTime, 1, function()
			self:OnUpdateSecond()
		end, {}, -1)
	end

	self:JPNotShowSiginThatCurrDSmallThanGameServerStartDay()

	if #self.listOpenActive == 0 then
		return
	end

	self.BGRaw = self:GetChildComponent("BG", "Image")
	self.GoTap = self:GetChildGameObject("SafeArea/TapGroup")
	self.TapGroup = self:GetChildGameObject("SafeArea/TapGroup/ScrollArea/Content")
	self.Tap = self:GetChildGameObject("SafeArea/TapGroup/Tap")

	local Model = self:GetChildComponent("SafeArea/Model/ModelList", "Transform")

	for i = 1, 99 do
		if not IsNil(self:GetChildGameObject("SafeArea/Model/ModelList/Model" .. i)) then
			self["ModelType" .. i] = self:GetChildGameObject("SafeArea/Model/ModelList/Model" .. i)

			SetActiveFunc(self["ModelType" .. i], false)
		end
	end

	self.Btn_close = self:GetChildGameObject("Btn_close")
	self.ModelGroup = self:GetChildGameObject("SafeArea/Model/ModelGroup")
	self.tagIndex = 0

	local findTag = false
	local tag = eOperationActive.Login

	if OperationActiveMgr.PageOperationActiveType == 2 then
		for k, v in pairsByKeys(self.listOpenActive) do
			tag = k
			findTag = true

			break
		end
	elseif vParam == nil or vParam.tag == nil then
		for k, v in pairsByKeys(self.listOpenActive) do
			self.tagIndex = self.tagIndex + 1

			if v.data.UIType == OperationActiveMgr.Tag then
				tag = k
				findTag = true

				break
			end
		end
	end

	if findTag == false then
		self.tagIndex = 1
	end

	if vParam and vParam.tag then
		self.tagIndex = 0

		for k, v in pairsByKeys(self.listOpenActive) do
			self.tagIndex = self.tagIndex + 1

			if v.data.UIType == vParam.tag then
				tag = k

				break
			end
		end
	end

	if #self.listOpenActive == 0 then
		return
	end

	self.curActiveIndex = tag
	self.curActiveID = self.listOpenActive[tag].data.ID
	self.curActivePage = self.listOpenActive[tag].data.PageOrder
	self.curActiveType = self.listOpenActive[tag].data.UIType
	self.listGoTap = {}
	self.listGoModel = {}
	self.panelList = {}

	self:InitTap()
end

function PageOperationActiveNew:JumpTap(UIType)
	local tag = 1

	self.tagIndex = 0

	for k, v in pairsByKeys(self.listOpenActive) do
		self.tagIndex = self.tagIndex + 1

		if v.data.UIType == UIType then
			tag = k

			break
		end
	end

	self.curActiveIndex = tag
	self.curActiveID = self.listOpenActive[tag].data.ID
	self.curActivePage = self.listOpenActive[tag].data.PageOrder
	self.curActiveType = self.listOpenActive[tag].data.UIType
	TaskManager.battlePassPayList = {}
	TaskManager.signAwardDouble = false

	if self.curActiveType ~= eOperationActive.BattlePass and self.curActiveType ~= eOperationActive.BattlePass2 or self.panelList[self.curActiveID] == nil then
		-- block empty
	elseif OperationActiveMgr.BattlePassTag == "Tab1" then
		self.panelList[self.curActiveID]:SignBattlePassnAward("Tab1")
	end

	self:InitTap()
end

function PageOperationActiveNew:Init(vParam)
	self.data = vParam
end

function PageOperationActiveNew:InitTap()
	local function fun(id, txtTap1, txtTap2)
		local txtTap = Lang(id)

		txtTap1.text = txtTap
		txtTap2.text = txtTap
	end

	SetActiveFunc(self.Tap, true)

	for k, v in pairsByKeys(self.listOpenActive) do
		if self.listOpenActive[k].data.UIType ~= 0 then
			local function funCreate(...)
				if self["ModelType" .. self.listOpenActive[k].data.UIType] then
					local tap = GOUtil.Instantiate(self.Tap, self.TapGroup)
					local model = GOUtil.Instantiate(self["ModelType" .. self.listOpenActive[k].data.UIType], self.ModelGroup)

					tap.name = self.listOpenActive[k].data.UIType .. "_" .. self.listOpenActive[k].data.PageOrder .. "_" .. k .. "_" .. self.listOpenActive[k].data.ID
					model.name = self.listOpenActive[k].data.UIType .. "_" .. self.listOpenActive[k].data.PageOrder .. "_" .. k .. "_" .. self.listOpenActive[k].data.ID

					local text1 = GOUtil.FindChildComponent(tap, "Button/Text", "Text")
					local text2 = GOUtil.FindChildComponent(tap, "Select/Text", "Text")
					local icon1 = GOUtil.FindChildComponent(tap, "Button/Image", "Image")
					local icon2 = GOUtil.FindChildComponent(tap, "Select/Image", "Image")

					text1.fontSize = 30
					text2.fontSize = 30

					local pageOrder = {
						id = self.listOpenActive[k].data.ID,
						index = k,
						type = self.listOpenActive[k].data.UIType,
						value = self.listOpenActive[k].data.PageOrder
					}

					fun(self.listOpenActive[k].data.Name, text1, text2)

					local btn = GOUtil.FindChildGameObject(tap, "Button")

					self:AddClick(btn, self.OnClickedTap)
					table.insert(self.listGoTap, pageOrder.id, {
						obj = tap,
						pageOrder = pageOrder
					})
					table.insert(self.listGoModel, pageOrder.id, {
						obj = model,
						pageOrder = pageOrder
					})
					RedDotSystemMgr.SetUIRedDot(tap, OperationRDL.DealOperationPath(self.listOpenActive[k].data.ID))
				end
			end

			if not self.listGoTap[v.data.ID] then
				funCreate()
			end
		end
	end

	local rect = GOUtil.GetComponent(self.TapGroup, "RectTransform")

	if self.tagIndex > 6 then
		rect.anchoredPosition = Vector2.New(0, (self.tagIndex - 1) * 120)
	else
		rect.anchoredPosition = Vector2.New(0, 0)
	end

	SetActiveFunc(self.Tap, false)

	if OperationActiveMgr.PageOperationActiveType == 2 then
		self.CurValue = 0

		self:OnClickedClose()

		local Text = GOUtil.FindChildComponent(self.UIRootObject, "Btn_close/Text", "Text")

		Text.text = _("Common_Click_Continue")
	else
		self:UpdatePanel()
	end
end

function PageOperationActiveNew:InitPanel()
	SetActiveFunc(self.UIRootObject.gameObject, true)
	Event.Instance:Fire("ShowOperationActive")

	if self.needClose then
		self.needClose = false

		self:OnClickedClose()
	end
end

function PageOperationActiveNew:OnClickedDayShow()
	if RoleCardMgr:GetTipWindowPatFaceState() == "1" then
		RoleCardMgr:SetTipWindowPatFaceState("0")
	else
		RoleCardMgr:SetTipWindowPatFaceState("1")
	end

	SetActiveFunc(self.go_day_show_sel, RoleCardMgr:GetTipWindowPatFaceState() == "0")
end

function PageOperationActiveNew:OnClickedClose()
	local index = 0
	local count = 0

	for _, v in pairsByKeys(self.listOpenActive) do
		if v then
			count = count + 1
		end
	end

	local function callback(...)
		self:OnClickedClose()
	end

	self.CurValue = self.CurValue + 1

	if count >= self.CurValue then
		for k, v in pairsByKeys(self.listOpenActive) do
			if v then
				index = index + 1

				if self.CurValue == index then
					self.curActiveIndex = k
					self.curActiveID = tonumber(v.data.ID)
					self.curActivePage = tonumber(v.data.PageOrder)
					self.curActiveType = tonumber(v.data.UIType)

					if self.DlgLuckyBackAward then
						self.DlgLuckyBackAward:Purge()

						self.DlgLuckyBackAward = nil
					end

					local isOpenLuckyBack = false

					if v.data.Type == eOperationActiveType.LimitTime then
						for k, v in pairsByKeys(self.listGoModel) do
							SetActiveFunc(v.obj, false)
						end

						isOpenLuckyBack = true
						self.DlgLuckyBackAward = DlgLuckyBackAward()

						local info = GoodsInfoListMgr:GetLuckyList()[v.CycleType]

						if info ~= nil then
							UIMgr.AddPanel(self.DlgLuckyBackAward, {
								callBack = callback,
								info = info
							}, self.ModelGroup)
						end
					elseif v.data.Type ~= eOperationActiveType.LimitTime then
						if self.listGoModel and not self.listGoModel[self.curActiveID] then
							if self["ModelType" .. v.data.UIType] then
								local pageOrder = {
									id = v.data.ID,
									index = k,
									type = v.data.UIType,
									value = v.data.PageOrder
								}
								local model = GOUtil.Instantiate(self["ModelType" .. v.data.UIType], self.ModelGroup)

								table.insert(self.listGoModel, pageOrder.id, {
									obj = model,
									pageOrder = pageOrder
								})
							else
								self:OnClickedClose()

								return
							end
						end

						self:UpdatePanel()

						break
					end
				end
			end
		end
	else
		if self.listGoModel then
			for k, v in pairsByKeys(self.listGoModel) do
				SetActiveFunc(v.obj, false)
			end
		end

		RoleCardMgr:SetTipWindowAwardState("0")
		RoleCardMgr:SetTipWindowAwardSignState("0")

		if self.UIRootObject then
			SetActiveFunc(self.UIRootObject.gameObject, false)
		end

		if self.DlgLuckyBackAward then
			self.DlgLuckyBackAward:Purge()

			self.DlgLuckyBackAward = nil
		end

		self:Purge()
		Event.Instance:Fire("UpdateWebViwe")
	end
end

function PageOperationActiveNew:OnClickedTap(data)
	local strList = string.split(data.pointerPress.transform.parent.name, "_")

	self.curActiveType = tonumber(strList[1])
	self.curActivePage = tonumber(strList[2])
	self.curActiveIndex = tonumber(strList[3])
	self.curActiveID = tonumber(strList[4])
	TaskManager.battlePassPayList = {}
	TaskManager.signAwardDouble = false

	if self.curActiveType ~= eOperationActive.BattlePass and self.curActiveType ~= eOperationActive.BattlePass2 or self.panelList[self.curActiveID] == nil then
		-- block empty
	elseif OperationActiveMgr.BattlePassTag == "Tab1" then
		self.panelList[self.curActiveID]:SignBattlePassnAward("Tab1")
	end

	self:UpdatePanel()
end

function PageOperationActiveNew:UpdateItemDataNotify()
	self:UpdatePanel()
end

function PageOperationActiveNew:UpdatePanel()
	if self.listGoTap then
		if not self:FindInfoByID(self.curActiveID) then
			SetActiveFunc(self.listGoTap[self.curActiveID].obj, false)

			if OperationActiveMgr.PageOperationActiveType == 2 then
				if not UIMgr.GetCurPanel().TipWindow and not UIMgr.GetCurPanel().TipWindowVideo then
					self:OnClickedClose()
				else
					self.needClose = true
				end

				return
			end
		end

		for _, v in pairsByKeys(self.listGoTap) do
			local btn = GOUtil.FindChildGameObject(v.obj, "Button")
			local sel = GOUtil.FindChildGameObject(v.obj, "Select")

			SetActiveFunc(btn, v.pageOrder.id ~= self.curActiveID)
			SetActiveFunc(sel, v.pageOrder.id == self.curActiveID)
		end
	end

	local infoActive = self:FindInfoByID(self.curActiveID)

	if infoActive == nil then
		for key, value in pairs(self.listOpenActive) do
			if self.listGoModel[value.data.ID] ~= nil then
				infoActive = value
				self.curActiveIndex = key
				self.curActiveID = infoActive.data.ID
				self.curActiveType = infoActive.data.UIType

				self:UpdatePanel()

				return
			end
		end
	end

	local tempPanel

	if self.listGoModel then
		for k, v in pairsByKeys(self.listGoModel) do
			if k == self.curActiveID then
				tempPanel = v.obj

				SetActiveFunc(v.obj, true)
			else
				SetActiveFunc(v.obj, false)
			end
		end
	end

	if tempPanel == nil then
		return
	end

	local infoActive1 = self.listOpenActive[self.curActiveIndex]

	if not infoActive1 or self.curActiveType ~= infoActive1.data.UIType then
		UIMgr.ClickDlgExit()

		return
	end

	if self.curActiveType == eOperationActive.Level then
		if self.panelList[self.curActiveID] == nil then
			self.panelList[self.curActiveID] = DlgOperationActiveLevel(tempPanel)

			self.panelList[self.curActiveID]:InitItemByRoot(tempPanel)
			self.panelList[self.curActiveID]:Init(infoActive, self.BGRaw)
		else
			self.panelList[self.curActiveID]:UpdateData(infoActive)
		end
	elseif self.curActiveType == eOperationActive.Login then
		if self.panelList[self.curActiveID] == nil then
			self.panelList[self.curActiveID] = DlgOperationActiveLogin(tempPanel)

			self.panelList[self.curActiveID]:InitItemByRoot(tempPanel, {
				PrefabCell = self.GoCellModelType1
			})
			self.panelList[self.curActiveID]:Init(infoActive, self.BGRaw, self.UIRootObject)
		else
			self.panelList[self.curActiveID]:UpdateData(infoActive)
		end
	elseif self.curActiveType == eOperationActive.Hour then
		if self.panelList[self.curActiveID] == nil then
			self.panelList[self.curActiveID] = DlgOperationActiveHour(tempPanel)

			self.panelList[self.curActiveID]:InitItemByRoot(tempPanel, {
				PrefabCell = self.GoCellHourAward
			})
			self.panelList[self.curActiveID]:Init(infoActive, self.BGRaw)
		else
			self.panelList[self.curActiveID]:UpdateData(infoActive)
		end
	elseif self.curActiveType == eOperationActive.Card then
		if self.panelList[self.curActiveID] == nil then
			self.panelList[self.curActiveID] = DlgOperationActiveCard(tempPanel)

			self.panelList[self.curActiveID]:InitItemByRoot(tempPanel)
			self.panelList[self.curActiveID]:Init(infoActive, self.BGRaw)
		else
			self.panelList[self.curActiveID]:UpdateData(infoActive)
		end
	elseif self.curActiveType == eOperationActive.Sign then
		if self.panelList[self.curActiveID] == nil then
			self.panelList[self.curActiveID] = DlgOperationActiveSign(tempPanel)

			self.panelList[self.curActiveID]:InitItemByRoot(tempPanel, {
				PrefabCell = self.GoCellSignAward
			})
			self.panelList[self.curActiveID]:Init(infoActive, self.BGRaw, self.UIRootObject)
		else
			self.panelList[self.curActiveID]:UpdateData(infoActive)
		end
	elseif self.curActiveType == eOperationActive.SmallClass then
		if self.panelList[self.curActiveID] == nil then
			self.panelList[self.curActiveID] = DlgOperationActiveSamllClass(tempPanel)

			self.panelList[self.curActiveID]:InitItemByRoot(tempPanel, {
				PrefabCell = self.GoCellSmallClassTask
			})
			self.panelList[self.curActiveID]:Init(infoActive, self.BGRaw)
		else
			self.panelList[self.curActiveID]:UpdateData(infoActive)
		end
	elseif self.curActiveType == eOperationActive.BattlePass or self.curActiveType == eOperationActive.BattlePass2 then
		if self.panelList[self.curActiveID] == nil then
			if not GuideMgr:IsGuided(GuideFunctionType.BattlePass) then
				UIMgr.AddPanel(PGuide(), GuideFunctionType.BattlePass)
			end

			self.panelList[self.curActiveID] = DlgOperationActiveBattlePass(tempPanel)

			self.panelList[self.curActiveID]:InitItemByRoot(tempPanel, {
				PrefabCell = self.GoCellBattlePassAwardNew,
				PrefabTaskCell = self.GoCellBattlePassTask
			})
			self.panelList[self.curActiveID]:Init(infoActive, self.BGRaw)
		else
			self.panelList[self.curActiveID]:UpdateData(infoActive)
		end
	elseif self.curActiveType == eOperationActive.RechargeRebate then
		if self.panelList[self.curActiveID] == nil then
			self.panelList[self.curActiveID] = DlgOperationActiveRechargeRebate(tempPanel)

			self.panelList[self.curActiveID]:InitItemByRoot(tempPanel, {
				PrefabCell = self.GoCellModelType1
			})
			self.panelList[self.curActiveID]:Init(infoActive, self.BGRaw)
		else
			self.panelList[self.curActiveID]:UpdateData(infoActive)
		end
	elseif self.curActiveType == eOperationActive.Birthday then
		if self.panelList[self.curActiveID] == nil then
			self.panelList[self.curActiveID] = DlgOperationActiveBirthday(tempPanel)

			self.panelList[self.curActiveID]:InitItemByRoot(tempPanel, {
				PrefabCell = self.GoCellModelType2
			})
			self.panelList[self.curActiveID]:Init(infoActive, self.BGRaw, self.UIRootObject)
		else
			self.panelList[self.curActiveID]:UpdateData(infoActive)
		end
	elseif self.curActiveType == eOperationActive.PlayerBirthday then
		if self.panelList[self.curActiveID] == nil then
			self.panelList[self.curActiveID] = DlgOperationActivePlayerBirthday(tempPanel)

			self.panelList[self.curActiveID]:InitItemByRoot(tempPanel, {
				PrefabCell = self.GoCellPlayerBirthday
			})
			self.panelList[self.curActiveID]:Init(infoActive, self.BGRaw)
		else
			self.panelList[self.curActiveID]:UpdateData(infoActive)
		end
	elseif self.curActiveType == eOperationActive.BossActivity then
		if self.panelList[self.curActiveID] == nil then
			if OperationActiveMgr:GetBossActivityDotState() == "1" and OperationActiveMgr.PageOperationActiveType == 1 then
				OperationActiveMgr:SetBossActivityDotState("0")
			end

			self.panelList[self.curActiveID] = DlgOperationActiveBossActivity(tempPanel)

			self.panelList[self.curActiveID]:InitItemByRoot(tempPanel, {
				PrefabCell = self.GoCellModelType1
			})
			self.panelList[self.curActiveID]:Init(infoActive, self.BGRaw)
		else
			self.panelList[self.curActiveID]:UpdateData(infoActive)
		end
	elseif self.curActiveType == eOperationActive.Jigsaw then
		if self.panelList[self.curActiveID] == nil then
			self.panelList[self.curActiveID] = DlgOperationActiveJigsaw(tempPanel)

			self.panelList[self.curActiveID]:InitItemByRoot(tempPanel, {})
			self.panelList[self.curActiveID]:Init(infoActive, self.BGRaw)
		else
			self.panelList[self.curActiveID]:UpdateData(infoActive)
		end
	elseif self.curActiveType == eOperationActive.GrowthFund then
		if self.panelList[self.curActiveID] == nil then
			self.panelList[self.curActiveID] = DlgOperationActiveGrowthFund(tempPanel)

			self.panelList[self.curActiveID]:InitItemByRoot(tempPanel, {})
			self.panelList[self.curActiveID]:Init(infoActive, self.BGRaw)
		else
			self.panelList[self.curActiveID]:UpdateData(infoActive)
		end
	elseif self.curActiveType == eOperationActive.CommonOne then
		if self.panelList[self.curActiveID] == nil then
			self.panelList[self.curActiveID] = DlgOperationActiveCommonOne(tempPanel)

			self.panelList[self.curActiveID]:InitItemByRoot(tempPanel, {
				PrefabCell = self.GoCellCommon1
			})
			self.panelList[self.curActiveID]:Init(infoActive, self.BGRaw, self.UIRootObject)
		else
			self.panelList[self.curActiveID]:UpdateData(infoActive)
		end
	elseif self.curActiveType == eOperationActive.CommonTwo then
		if self.panelList[self.curActiveID] == nil then
			self.panelList[self.curActiveID] = DlgOperationActiveCommonOne(tempPanel)

			self.panelList[self.curActiveID]:InitItemByRoot(tempPanel, {
				PrefabCell = self.GoCellCommon2
			})
			self.panelList[self.curActiveID]:Init(infoActive, self.BGRaw, self.UIRootObject)
		else
			self.panelList[self.curActiveID]:UpdateData(infoActive)
		end
	elseif self.curActiveType == eOperationActive.CommonThree then
		if self.panelList[self.curActiveID] == nil then
			self.panelList[self.curActiveID] = DlgOperationActiveCommonOne(tempPanel)

			self.panelList[self.curActiveID]:InitItemByRoot(tempPanel, {
				PrefabCell = self.GoCellCommon3
			})
			self.panelList[self.curActiveID]:Init(infoActive, self.BGRaw, self.UIRootObject)
		else
			self.panelList[self.curActiveID]:UpdateData(infoActive)
		end
	elseif self.curActiveType == eOperationActive.CommonFour then
		if self.panelList[self.curActiveID] == nil then
			self.panelList[self.curActiveID] = DlgOperationActiveCommonOne(tempPanel)

			self.panelList[self.curActiveID]:InitItemByRoot(tempPanel, {
				PrefabCell = self.GoCellCommon4
			})
			self.panelList[self.curActiveID]:Init(infoActive, self.BGRaw, self.UIRootObject)
		else
			self.panelList[self.curActiveID]:UpdateData(infoActive)
		end
	elseif self.curActiveType == eOperationActive.RoleBirthdayAward then
		if self.panelList[self.curActiveID] == nil then
			local function callback(...)
				self:OnClickedClose()
			end

			tempPanel = GOUtil.FindChildGameObject(tempPanel, "Panel")

			local uiInfo = InfoOperationActive:GetOperationUIInfo(infoActive.data.UIType .. "_" .. infoActive.data.PageOrder)

			for i = 1, 1 do
				if uiInfo and uiInfo.Video and uiInfo.Video[i] and uiInfo.Video[i][1] then
					OperationActiveMgr.RoleBirthdayVideoClip = uiInfo.Video[i][1]
				end
			end

			self.panelList[self.curActiveID] = DlgRoleBirthdayAward()

			self.panelList[self.curActiveID]:Create(tempPanel, {
				isShowBG = false,
				infoActive = infoActive,
				callback = callback
			})
		end
	elseif self.curActiveType == eOperationActive.URCardPool then
		if self.panelList[self.curActiveID] == nil then
			self.panelList[self.curActiveID] = DlgOperationActiveURCardPool(tempPanel)

			self.panelList[self.curActiveID]:InitItemByRoot(tempPanel, {
				PrefabCell = self.GoCellURCardPool
			})
			self.panelList[self.curActiveID]:Init(infoActive, self.BGRaw)
		else
			self.panelList[self.curActiveID]:UpdateData(infoActive)
		end
	end
end

function PageOperationActiveNew:OperationActiveSignRetroactive(index)
	local config = GetConfigArgJson("SignInCost")

	if PlayerInst:GetDiamond() + PlayerInst:GetDiamondPay() < config[2] then
		UIMgr.ShowMsg(_("Calendar_DiamondNotEnough"))

		return
	end

	if OperationActiveMgr.needTips then
		local str = string.format(_("Desc_UseItemToSign"), config[2])
		local leftNum = config[2] - PlayerInst:GetDiamond()
		local strAlert

		local function vCallBack(index2)
			if index2 == DlgCommonEvent.ButtonType.OkNoMoreTips then
				OperationActiveMgr.needTips = false
			end

			if index2 == DlgCommonEvent.ButtonType.Ok or index2 == DlgCommonEvent.ButtonType.OkNoMoreTips then
				self:ReceiveOperationActiveAward(index)
			else
				TaskManager.signAwardDouble = false
			end
		end

		UIMgr.ShowCommon(DlgCommonEvent.Type.TodayNoMoreTips, _("Tittle_Affirm"), {
			str,
			strAlert,
			true
		}, vCallBack, nil, nil, nil, true)
	else
		self:ReceiveOperationActiveAward(index)
	end
end

function PageOperationActiveNew:ReceiveOperationActiveAward(index, isBattlePass, isPay, maskGo)
	local infoOperationActive = self:FindInfoByID(self.curActiveID)

	if not index then
		return
	end

	local activeIndex = index - 1

	if isBattlePass then
		TaskManager.battlePassPayList = {}

		local taskListData = TaskManager:GetTaskListData(eTaskListType.battlePass)

		if not ShopManager:GetMonthIdState(taskListData.ActivePayId) and infoOperationActive and infoOperationActive.data.Type == eOperationActiveType.BattlePass then
			local listBattlePassAward = OperationActiveMgr:GetActiveRewardItems(self.curActiveID)
			local index2 = BattlePassTaskMgr:GetBattlePassLevel()

			for i = 1, index2 do
				if TaskManager:IsRecvedPayScoreAward(taskListData.ID, i - 1) == false then
					local award = listBattlePassAward.PayScoreSectionReward[i].award

					if award then
						for i = 1, #award do
							table.insert(TaskManager.battlePassPayList, award[i])
						end
					end
				end
			end
		end

		local function cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat, 62)

			if vMsg.result.code == 0 then
				Event.Instance:Fire("TaskCompleteUpdate")

				local roleID = 301

				if roleID then
					InfoSoundEventMgr:LoadBank(RoleMgr:GetRole(roleID).data.VocalBank)
					InfoSoundEventMgr:Play("VocalCommon2", RoleMgr:GetRole(roleID).data.VocalCommon2)
				end
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		end

		local taskId = BattlePassTaskMgr:GetBattlePassTaskID()

		if self.curActiveType == eOperationActive.SmallClass then
			taskId = BattlePassTaskMgr:GetSmallClassTaskID()
		end

		NetManager:RequestTaskLineScoreReward(taskId, activeIndex, cb, isPay)
		LoadingMgr.Show(eLoadingType.Repeat, 62)

		return
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == 0 then
			infoOperationActive:ChangeAwardRecords(activeIndex)
			self:UpdatePanel()

			local num = math.random(1, 2)
			local roleID

			if self.curActiveType == eOperationActive.Login then
				self:PlayVocal()
			elseif self.curActiveType == eOperationActive.Hour then
				if num == 1 then
					roleID = 202

					InfoSoundEventMgr:LoadBank(RoleMgr:GetRole(roleID).data.VocalBank)
				else
					roleID = 503

					InfoSoundEventMgr:LoadBank(RoleMgr:GetRole(roleID).data.VocalBank)
				end

				InfoSoundEventMgr:Play("VocalCommon2", RoleMgr:GetRole(roleID).data.VocalCommon2)
			elseif self.curActiveType == eOperationActive.Sign then
				self:PlayVocal()
			elseif self.curActiveType == eOperationActive.Birthday then
				self:PlayVocal()
			elseif self.curActiveType == eOperationActive.SmallClass then
				roleID = 104

				InfoSoundEventMgr:LoadBank(RoleMgr:GetRole(roleID).data.VocalBank)

				local num = math.random(1, 2)

				if num == 1 then
					InfoSoundEventMgr:Play("VocalCommon10", RoleMgr:GetRole(roleID).data.VocalCommon10)
				else
					InfoSoundEventMgr:Play("VocalCommon6", RoleMgr:GetRole(roleID).data.VocalCommon6)
				end

				return
			end

			if maskGo then
				SetActiveFunc(maskGo, false)
			end
		else
			if maskGo then
				SetActiveFunc(maskGo, false)
			end

			if vMsg.result.code == 4 then
				infoOperationActive:ChangeAwardRecords(activeIndex)
				self:UpdatePanel()
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)

				if OperationActiveMgr.PageOperationActiveType == 2 then
					self:OnClickedClose()
				end
			end
		end
	end

	NetManager:RequestOperationActiveAward(self.curActiveID, index, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageOperationActiveNew:ReceiveOperationActiveAwardList(indexList, maskGo)
	local infoOperationActive = self:FindInfoByID(self.curActiveID)

	if not indexList then
		return
	end

	for i = 1, #indexList do
		indexList[i] = indexList[i] - 1
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == 0 then
			for i = 1, #indexList do
				infoOperationActive:ChangeAwardRecords(indexList[i])
			end

			self:UpdatePanel()

			local num = math.random(1, 2)
			local roleID

			if self.curActiveType == eOperationActive.Login then
				self:PlayVocal()
			elseif self.curActiveType == eOperationActive.Hour then
				if num == 1 then
					roleID = 202

					InfoSoundEventMgr:LoadBank(RoleMgr:GetRole(roleID).data.VocalBank)
				else
					roleID = 503

					InfoSoundEventMgr:LoadBank(RoleMgr:GetRole(roleID).data.VocalBank)
				end

				InfoSoundEventMgr:Play("VocalCommon2", RoleMgr:GetRole(roleID).data.VocalCommon2)
			elseif self.curActiveType == eOperationActive.Sign then
				self:PlayVocal()
			elseif self.curActiveType == eOperationActive.Birthday then
				self:PlayVocal()
			end

			if maskGo then
				SetActiveFunc(maskGo, false)
			end
		else
			if maskGo then
				SetActiveFunc(maskGo, false)
			end

			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestOperationActiveAward(self.curActiveID, indexList, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageOperationActiveNew:UpdatePanelAfterTaskComplete()
	self:UpdatePanel()
end

function PageOperationActiveNew:RequestReceiveTaskAward(listCompTask)
	local listCompId = {}

	for _, v in pairsByKeys(listCompTask) do
		table.insert(listCompId, v.pb.id)

		if v.data and v.data.Reward and v.data.Reward[1] and (v.data.Reward[1][1] == 514 or v.data.Reward[1][1] == 515 or v.data.Reward[1][1] == 520) then
			table.insert(TaskManager.integralList, v.data.Reward[1])
		end
	end

	local function fun()
		return
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat, 61)

		if vMsg.result.code == NetManager.Result_Sucess then
			self:UpdatePanelAfterTaskComplete()

			if self.curActiveType == eOperationActive.BattlePass or self.curActiveType == eOperationActive.BattlePass2 then
				local data = {}

				data.list = {}
				data.listValue = 0

				require("UI/Dlg/Common/DlgGetAward")
				UIMgr.AddPanel(DlgGetAward(), data)

				self.DlgGetAward = true

				self:PlayVocal()
			elseif self.curActiveType == eOperationActive.SmallClass then
				InfoSoundEventMgr:LoadBank(RoleMgr:GetRole(104).data.VocalBank)

				local num = math.random(1, 3)

				if num == 1 then
					InfoSoundEventMgr:Play("VocalCommon10", RoleMgr:GetRole(104).data.VocalCommon10)
				elseif num == 2 then
					InfoSoundEventMgr:Play("VocalCommon6", RoleMgr:GetRole(104).data.VocalCommon6)
				elseif num == 3 then
					InfoSoundEventMgr:Play("VocalCustomsclearance3", RoleMgr:GetRole(104).data.VocalCustomsclearance3)
				end
			end
		else
			TaskManager.integralList = {}

			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestTaskChange(listCompId, wrap_cb, fun)
	LoadingMgr.Show(eLoadingType.Repeat, 61)
end

function PageOperationActiveNew:GetOpenTime(strTime)
	local str = ""
	local a = string.split(strTime, " ")

	if #a > 0 then
		local date = string.split(a[1], "-")
		local yearT = tonumber(date[1])
		local monthT = tonumber(date[2])
		local dayT = tonumber(date[3])

		str = string.format(_("Desc_TimeShow"), monthT, dayT)
	end

	return str
end

function PageOperationActiveNew:UpdateOperation()
	if OperationActiveMgr.PageOperationActiveType == 1 then
		self.listOpenActive = OperationActiveMgr:GetListOpenActive()

		local list = {}

		for k, v in pairsByKeys(self.listOpenActive) do
			if v and tonumber(v.data.UIType) ~= eOperationActive.BossActivity then
				table.insert(list, v)
			end
		end

		self.listOpenActive = list

		self:InitTap()
	else
		local listOpenActive = OperationActiveMgr:AllLoginPopupList()
		local tempOpenActive = {}
		local oldValue = self.CurValue

		for k, v in pairsByKeys(self.listOpenActive) do
			local find = false

			for k2, v2 in pairsByKeys(listOpenActive) do
				if v.data.ID == v2.data.ID then
					find = true

					break
				end
			end

			if find then
				table.insert(tempOpenActive, v)
			elseif k <= oldValue then
				self.CurValue = self.CurValue - 1
			end
		end

		for k, v in pairsByKeys(listOpenActive) do
			local find = false

			for k2, v2 in pairsByKeys(self.listOpenActive) do
				if v.data.ID == v2.data.ID then
					find = true

					break
				end
			end

			if not find then
				table.insert(tempOpenActive, v)
			end
		end

		self.listOpenActive = tempOpenActive

		self:UpdatePanel()
	end
end

function PageOperationActiveNew:OnUpdateSecond()
	if self.listOpenActive and OperationActiveMgr.PageOperationActiveType == 1 then
		local isupdate = false
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

		self:GetExitTime()

		for key, value in pairs(self.ExitTime) do
			if value < curServerTime then
				isupdate = true

				SetActiveFunc(self.listGoTap[key].obj, false)
			end
		end

		if isupdate then
			self.ExitTime = nil

			self:UpdateOperation()
		end
	end
end

function PageOperationActiveNew:GetExitTime()
	if self.ExitTime == nil then
		self.ExitTime = {}

		for key, value in pairs(self.listOpenActive) do
			if value.data.UIType ~= 0 and value.data.UIType ~= eOperationActive.BossActivity and self["ModelType" .. value.data.UIType] then
				if value.data.UIType == eOperationActive.PlayerBirthday or value.data.UIType == eOperationActive.Birthday then
					local _, _, _, time = value:OnMonthAndDay()

					self.ExitTime[value.data.ID] = time
				else
					self.ExitTime[value.data.ID] = GetTimeTampByString(value.data.ShowEndTime)
				end
			end
		end
	end
end

function PageOperationActiveNew:FindInfoByID(ID)
	for key, value in pairs(self.listOpenActive) do
		if value.data.ID == ID then
			return value
		end
	end

	return nil
end

function PageOperationActiveNew:PlayVocal()
	local info = OperationActiveMgr:Get(self.curActiveID)
	local ActiveID = info.data.UIType .. "_" .. info.data.PageOrder
	local uiInfo = info:GetOperationUIInfo(ActiveID)
	local roleId, vocal

	if uiInfo and uiInfo.Vocal and #uiInfo.Vocal > 0 then
		local num = math.random(1, #uiInfo.Vocal)

		roleId = uiInfo.Vocal[num][1]
		vocal = uiInfo.Vocal[num][2]
	else
		print("=========播放人物音频失败，当前活动id为" .. self.curActiveID)
	end

	if roleId and vocal then
		InfoSoundEventMgr:LoadBank(RoleMgr:GetRole(roleId).data.VocalBank)
		InfoSoundEventMgr:Play(vocal, RoleMgr:GetRole(roleId).data[vocal])
	end
end

function PageOperationActiveNew:OnBackAndroid()
	if self.curActiveType == eOperationActive.BattlePass and self["Panel" .. self.curActiveIndex] then
		return self["Panel" .. self.curActiveIndex]:OnBackAndroid()
	end

	return false
end
