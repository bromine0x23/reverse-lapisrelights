-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellBattlePassAwardNew.lua

require("UI/Item/UIItemBase")

CellBattlePassAwardNew = class("CellBattlePassAwardNew", UIItemBase)

function CellBattlePassAwardNew:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellBattlePassAwardNew:OnEnter()
	local g = self.UIRootObject

	require("UI/Page/PageOperation/CellBattlePassAward")

	self.CellBattlePassAward1 = self:GetChildGameObject("CellBattlePassAward1")
	self.CellBattlePassAward2 = self:GetChildGameObject("CellBattlePassAward2")
	self.obj = {}
	self.obj.img_start = self:GetChildGameObject("Bar/img_start")
	self.obj.img_end = self:GetChildGameObject("Bar/img_end")
	self.obj.fill = self:GetChildComponent("Bar/fill", "Image")
	self.obj.fill_start = self:GetChildComponent("Bar/fill_start", "Image")
	self.obj.fill_end = self:GetChildComponent("Bar/fill_end", "Image")
	self.obj.icon = self:GetChildComponent("Bar/btn_icon/icon", "Image")
	self.obj.btn_icon = self:GetChildGameObject("Bar/btn_icon")
	self.obj.img_bar = self:GetChildComponent("Bar", "Image")
	self.obj.tex_level = self:GetChildComponent("Bar/btn_icon/icon/tex_level", "Text")

	local grade = tonumber(string.split(BattlePassTaskMgr:GetBattlePassGrade(), "/")[2])
	local cost = grade * GetConfigArgInt("BPLevelBuyUnitPrice")

	self.obj.tex_level.text = cost .. ""
	self.obj.img_complete = self:GetChildGameObject("Bar/img_complete")
	self.obj.img_uncomplete = self:GetChildGameObject("Bar/img_uncomplete")
	self.obj.img_complete_end = self:GetChildGameObject("Bar/img_complete_end")
	self.obj.img_uncomplete_end = self:GetChildGameObject("Bar/img_uncomplete_end")

	self:AddClick(self.obj.btn_icon, self.OnClickedAddLevel)
end

function CellBattlePassAwardNew:OnLeave()
	if self.cell1 then
		self.cell1:OnLeave()
	end

	if self.cell2 then
		self.cell2:OnLeave()
	end

	self:RemoveClick(self.obj.btn_icon, self.OnClickedAddLevel)
end

function CellBattlePassAwardNew:UpdateData(data1, data2, infoActive, endValue, day, TaskID)
	if not self.cell1 then
		self.cell1 = CellBattlePassAward(self.CellBattlePassAward1)

		self.cell1:InitItemByRoot(self.CellBattlePassAward1, 1)
		self.cell1:UpdateData(data1, infoActive, 1, self.obj, endValue, day, TaskID)

		self.data1 = data1
	else
		self.cell1:UpdateData(data1, infoActive, 1, self.obj, endValue, day, TaskID)
	end

	if not self.cell2 then
		self.cell2 = CellBattlePassAward(self.CellBattlePassAward2)

		self.cell2:InitItemByRoot(self.CellBattlePassAward2, 1)
		self.cell2:UpdateData(data2, infoActive, 2, self.obj, endValue, day, TaskID)

		self.data2 = data2
	else
		self.cell2:UpdateData(data2, infoActive, 2, self.obj, endValue, day, TaskID)
	end

	local grade = tonumber(string.split(BattlePassTaskMgr:GetBattlePassGrade(), "/")[2])
	local cost = grade * GetConfigArgInt("BPLevelBuyUnitPrice")

	self.obj.tex_level.text = cost .. ""
end

function CellBattlePassAwardNew:OnClickedBtnRecv(data)
	return
end

function CellBattlePassAwardNew:OnClickedAddLevel(data)
	local grade = tonumber(string.split(BattlePassTaskMgr:GetBattlePassGrade(), "/")[2])
	local cost = grade * GetConfigArgInt("BPLevelBuyUnitPrice")

	if cost > PlayerInst:GetDiamond() + PlayerInst:GetDiamondPay() then
		UIMgr.ShowMsg(_("Desc_DrawCardNotEnoughRes"))

		return
	end

	local function func(...)
		local function wrap_cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vMsg.result.code == NetManager.Result_Sucess then
				BattlePassTaskMgr:SetBattlePassScore(grade)
				Event.Instance:Fire("SaveBattlePass1ViewPos")
				Event.Instance:Fire("TaskCompleteUpdate")
				Event.Instance:Fire("UpdateTapDot")
				Event.Instance:Fire("EventAnimBattlePassLevelStart")
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestBattlePassAddLevel(BattlePassTaskMgr:GetBattlePassTaskID(), grade, wrap_cb)
	end

	if OperationActiveMgr.needTips then
		local str = string.format(Lang(811), cost)
		local leftNum = cost - PlayerInst:GetDiamond()
		local strAlert

		local function vCallBack(index2)
			if index2 == DlgCommonEvent.ButtonType.OkNoMoreTips then
				OperationActiveMgr.needTips = false
			end

			if index2 == DlgCommonEvent.ButtonType.Ok or index2 == DlgCommonEvent.ButtonType.OkNoMoreTips then
				func()
			end
		end

		UIMgr.ShowCommon(DlgCommonEvent.Type.TodayNoMoreTips, _("Desc_Award_Unlock"), {
			str,
			strAlert
		}, vCallBack, nil, nil, nil, true)
	else
		func()
	end
end
