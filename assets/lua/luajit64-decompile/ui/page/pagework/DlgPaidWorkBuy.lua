-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageWork/DlgPaidWorkBuy.lua

DlgPaidWorkBuy = class("DlgPaidWorkBuy", UIPanel)

function DlgPaidWorkBuy:ctor()
	self.UIPrefabPath = "UI/PanelWork/DlgPaidWorkBuy"
end

function DlgPaidWorkBuy:PreLoad()
	return
end

function DlgPaidWorkBuy:Purge()
	self.base.Purge(self)

	if self.timer1 then
		TimerMgr.RemoveTimer(self.timer1)

		self.timer1 = nil
	end

	if self.timer2 then
		TimerMgr.RemoveTimer(self.timer2)

		self.timer2 = nil
	end

	self:OnLeave()
end

function DlgPaidWorkBuy:OnLeave()
	if self.listWorkItem ~= nil then
		for _, item in ipairs(self.listWorkItem) do
			if item.OnLeave then
				item:OnLeave()
			end
		end

		self.listWorkItem = nil
	end

	EffectMgr:UnLoadEffect("Fx/UI/FX_UI_Welfare/FX_CellWork_Start")
	EffectMgr:UnLoadEffect("Fx/UI/FX_UI_Welfare/FX_CellWork_End")
end

function DlgPaidWorkBuy:OnRegisterEvent()
	self:AddClick(self.BtnBuy, self.OnClickedBtnBuy)
	self:AddClick(self.BtnClose, self.OnClickedBtnClose)
	Event.Instance:Add("UpdateBoughtWork", self.Close, self)
	EventListenerMgr.AddAnimListener(self.UIRootObject, self.EventAnimEnd, self, eAnimEventType.OnAnimationEnd)
end

function DlgPaidWorkBuy:OnUnRegisterEvent()
	self:RemoveClick(self.BtnBuy, self.OnClickedBtnBuy)
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
	Event.Instance:Remove("UpdateBoughtWork", self.Close, self)
	EventListenerMgr.RemoveAnimListener(self.UIRootObject, self.EventAnimEnd, self, eAnimEventType.OnAnimationEnd)
end

function DlgPaidWorkBuy:OnEnter(vParam)
	self:DealWithLocalization()

	self.AnimRoot = GOUtil.GetComponent(self.UIRootObject, "Animator")
	self.GoPoint = self:GetChildGameObject("Point")
	self.GoWindow = self:GetChildGameObject("Panel/Scroll/Window")
	self.listWorkItem = {}

	for i = 1, 3 do
		self["GoWork" .. i] = self:GetChildGameObject("Panel/Scroll/" .. i)

		local item = CellWork(self["GoWork" .. i])

		item:InitItemByRoot(self["GoWork" .. i])
		table.insert(self.listWorkItem, item)
	end

	self.BtnBuy = self:GetChildGameObject("Panel/BtnBuy")
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")
	self.pos = vParam.pos

	self:Init()

	local icon = self:GetChildComponent("Panel/BtnBuy/Cost/Icon", "Image")
	local text = self:GetChildComponent("Panel/BtnBuy/Cost/Text", "Text")
	local cost = GetConfigArgJson("WorkCost")

	SetImageSprite(icon, ItemManager:GetIcon(cost[1]), self)

	text.text = cost[2]
end

function DlgPaidWorkBuy:DealWithLocalization()
	local txt = self:GetChildComponent("Panel/Prompt/Text", "Text")

	txt.text = _("Desc_Work_Buy_Prompt")
end

function DlgPaidWorkBuy:Init()
	self.listPaidWork = WorkMgr:GetPaidWorksToday()

	for k, item in ipairs(self.listWorkItem) do
		if k <= table.getCount(self.listPaidWork) then
			item:UpdateData({
				info = self.listPaidWork[k]
			})
		else
			GOUtil.SetActive(item.UIRootObject, false)
		end
	end
end

function DlgPaidWorkBuy:OnClickedBtnBuy()
	local cost = GetConfigArgJson("WorkCost")

	local function cb(cmd)
		if cmd == 1 then
			local isEnough = ItemManager:IsItemHoldEnough(cost[1], cost[2])

			if isEnough then
				GOUtil.SetActive(self.BtnBuy, false)
				GOUtil.SetActive(self.BtnClose, false)
				self:RequestBuyWork()
			end
		end
	end

	local info = ItemManager:Get(cost[1])
	local msg = string.format(_("Desc_Work_Buy"), cost[2])

	local function showTip()
		UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Tittle_Affirm"), {
			isDiamond = true,
			text = msg
		}, cb, _("Button_OK"), _("Button_Cancel"), false)
	end

	CheckPayDiamond(cost[2], msg, cb, showTip)
end

function DlgPaidWorkBuy:RequestBuyWork()
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self:SimulationRandom(tonumber(vMsg.id))
			WorkMgr.ChangeWorkCreateTime(vMsg.id, NetData:GetCurServerTime() / DateUtil.MillsPerSecond)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)

			if WorkMgr:CanBuyWork() then
				GOUtil.SetActive(self.BtnBuy, true)
				GOUtil.SetActive(self.BtnClose, true)
			else
				self:Close()
			end
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestBuyWork(wrap_cb)
end

function DlgPaidWorkBuy:SimulationRandom(selectId)
	local list = {}

	self.resultIdx = 1

	for k, v in ipairs(self.listPaidWork) do
		if v.pb.state == eWorkStateType.Unbuyed or v.pb.id == selectId then
			table.insert(list, k)
		end

		if selectId == v.pb.id then
			self.resultIdx = k
		end
	end

	local index = 1
	local count = 0
	local extra = 1

	for k, v in ipairs(list) do
		if v == self.resultIdx then
			extra = k
		end
	end

	local repeatCnt = #list * 3 + extra

	local function func()
		self.timer2 = nil

		if self.closed then
			return
		end

		self["GoWork" .. list[index]].transform:SetParent(self.GoPoint.transform)
		self.AnimRoot:Play("Anim_DlgPaidWorkBuy_Hide")
	end

	if #list == 1 then
		self["GoWork" .. list[extra]].transform:SetAsLastSibling()
		EffectMgr:Alloc("Fx/UI/FX_UI_Welfare/FX_CellWork_End", self["GoWork" .. list[extra]])

		self.timer2 = TimerMgr.AddTimer(eTimerType.ScaleTime, 1.1, func, nil)

		return
	end

	local function fun()
		self.timer1 = nil

		if self.closed then
			return
		end

		self.GoWindow.transform:SetAsLastSibling()
		self["GoWork" .. list[index]].transform:SetAsLastSibling()

		if count < repeatCnt - 1 then
			EffectMgr:Alloc("Fx/UI/FX_UI_Welfare/FX_CellWork_Start", self["GoWork" .. list[index]])
		end

		count = count + 1

		if count < repeatCnt then
			index = TenaryOp(index + 1 > #list, 1, index + 1)
		else
			EffectMgr:Alloc("Fx/UI/FX_UI_Welfare/FX_CellWork_End", self["GoWork" .. list[index]])

			self.timer2 = TimerMgr.AddTimer(eTimerType.ScaleTime, 1.1, func, nil)
		end
	end

	self.timer1 = TimerMgr.AddTimer(eTimerType.ScaleTime, 0.25, fun, nil, repeatCnt)
end

function DlgPaidWorkBuy:EventAnimEnd()
	local tweener = GOUtil.DoMoveX(self["GoWork" .. self.resultIdx].transform, self.pos.x, 0.6)

	GOUtil.DoMoveY(self["GoWork" .. self.resultIdx].transform, self.pos.y, 0.6)
	GOUtil.SetTweenerCallback(tweener, function()
		self:Close()
		Event.Instance:Fire("UpdateAfterBuyWork", {
			keepPos = true
		})
	end)
end

function DlgPaidWorkBuy:OnClickedBtnClose()
	self:Close()
end
