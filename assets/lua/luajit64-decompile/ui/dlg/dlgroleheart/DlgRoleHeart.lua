require("UI/Page/PageTheme/CellSeatTeam")
require("UI/Dlg/DlgRoleHeart/CellRoleHead")
require("UI/Dlg/DlgRoleHeart/CellHeartTab")
require("UI/Dlg/DlgRoleHeart/CellDefaultTeam")
require("UI/Dlg/DlgRoleHeart/CellJob")
require("Info/InfoRole")
require("Util.EasyFilter")

local var_0_0 = require("Info/InfoTeam")
local var_0_1 = require("luaData/CharacterTeam")
local var_0_2 = require("luaData/CharacterCard")

DlgRoleHeart = class("DlgRoleHeart", UIPanel)
HeartPanelSelInfoRole = nil

function DlgRoleHeart.ctor(arg_1_0)
	arg_1_0.UIPrefabPath = "UI/Common/DlgRoleHeart/DlgRoleHeart"
end

function DlgRoleHeart.PreLoad(arg_2_0)
	arg_2_0:LoadResAsync("UI/Item/CellItem", "PrefabCell")
	arg_2_0:LoadResAsync("UI/Common/DlgRoleHeart/CellHeartTab", "PrefabCell")
	arg_2_0:LoadResAsync("UI/Common/DlgRoleHeart/CellTeam", "PrefabCellHeartTab")
	arg_2_0:LoadResAsync("UI/Common/DlgRoleHeart/CellJob", "PrefabCellTeam")
	arg_2_0:LoadResAsync("UI/Common/DlgRoleHeart/CellDefaultTeam", "PrefabCellDefaultTeam")
	arg_2_0:LoadResAsync("UI/Common/DlgRoleHeart/CellRoleHead", "PrefabCellPanel")
end

function DlgRoleHeart.Purge(arg_3_0)
	DlgRoleHeart.base.Purge(arg_3_0)

	if arg_3_0.CellSeatTeamUIScrollTool then
		arg_3_0.CellSeatTeamUIScrollTool:Purge()
	end

	if arg_3_0.CellDefaultTeamUIScrollTool then
		arg_3_0.CellDefaultTeamUIScrollTool:Purge()
	end

	if arg_3_0.CellJobUIScrollTool then
		arg_3_0.CellJobUIScrollTool:Purge()
	end

	if arg_3_0.UIScrollToolPanel then
		arg_3_0.UIScrollToolPanel:Purge()
	end

	ResourceMgr.Unload(arg_3_0.PrefabCell)
	ResourceMgr.Unload(arg_3_0.PrefabCellHeartTab)
	ResourceMgr.Unload(arg_3_0.PrefabCellTeam)
	ResourceMgr.Unload(arg_3_0.PrefabCellJob)
	ResourceMgr.Unload(arg_3_0.PrefabCellDefaultTeam)
	ResourceMgr.Unload(arg_3_0.PrefabCellPanel)
end

function DlgRoleHeart.OnRegisterEvent(arg_4_0)
	arg_4_0:AddClick(arg_4_0.ButtonExit, arg_4_0.OnClickedButtonExit)
	arg_4_0:AddClick(arg_4_0.ButtonOK, arg_4_0.OnClickedButtonOK)
end

function DlgRoleHeart.OnUnRegisterEvent(arg_5_0)
	arg_5_0:RemoveClick(arg_5_0.ButtonExit, arg_5_0.OnClickedButtonExit)
	arg_5_0:RemoveClick(arg_5_0.ButtonOK, arg_5_0.OnClickedButtonOK)
end

function DlgRoleHeart.OnEnter(arg_6_0, arg_6_1)
	arg_6_0.roleId = arg_6_1.roleId
	arg_6_0.typeId = arg_6_1.typeId
	arg_6_0.Content = arg_6_0:GetChildGameObject("Main/Group/ScrollArea/Viewport/Content")
	arg_6_0.ButtonExit = arg_6_0:GetChildGameObject("Main/ButtonExit")
	arg_6_0.ButtonOK = arg_6_0:GetChildGameObject("Main/Button")
	arg_6_0.IsCellSeatTeam = false
	arg_6_0.IsCellDefaultTeam = false
	arg_6_0.IsCellJob = false
	arg_6_0.tabValue = 0
	arg_6_0.curIndex = 1
	arg_6_0.CellSeatTeamValue = 1
	arg_6_0.CellJobValue = 1
	arg_6_0.CellDefaultTeamValue = 1
	arg_6_0.heartPanelSelValue = 1
	arg_6_0:GetChildComponent("Main/bg_title/tex_title", "Text").text = _("Desc_StudentList")
	arg_6_0:GetChildComponent("Main/Button/Text", "Text").text = _("UI_OK")

	local var_6_0 = string.split(RoleCardMgr:GetRoleCardSelect(), "_")

	if tonumber(var_6_0[1]) == 1 then
		arg_6_0.curIndex = 1
	elseif tonumber(var_6_0[1]) == 2 then
		arg_6_0.curIndex = 2
		arg_6_0.CellSeatTeamValue = tonumber(var_6_0[2])
	elseif tonumber(var_6_0[1]) == 3 then
		arg_6_0.curIndex = 3
		arg_6_0.CellJobValue = tonumber(var_6_0[2])
	elseif tonumber(var_6_0[1]) == 4 then
		arg_6_0.curIndex = 4
		arg_6_0.CellDefaultTeamValue = tonumber(var_6_0[2])
	end

	arg_6_0.heartPanelSelValue = tonumber(var_6_0[3])
	arg_6_0.tabValueList = {}
	arg_6_0.CellSeatTeamUIScrollTool = UIScrollTool()
	arg_6_0.CellDefaultTeamUIScrollTool = UIScrollTool()
	arg_6_0.CellJobUIScrollTool = UIScrollTool()
	arg_6_0.UIScrollToolPanel = UIScrollTool()

	arg_6_0:UpdateTabScroll()

	arg_6_0.listTeamPanel = RoleMgr:GetAllRole()
	arg_6_0.sameList = arg_6_0.listTeamPanel

	local var_6_1 = var_0_0.stageTeams[tonumber(RoleCardMgr:GetTeamListIndex())]

	arg_6_0.defaultTeamIdlist = {}

	for iter_6_0 = 1, 10 do
		if tonumber(var_6_1.roleCardTeams[iter_6_0]) ~= 0 then
			table.insert(arg_6_0.defaultTeamIdlist, RoleCardMgr:GetRole(var_6_1.roleCardTeams[iter_6_0]).id)
		end
	end

	arg_6_0:InitScrollViewPanel()
	arg_6_0:OnClickedCellHeartTab(nil, arg_6_0.curIndex)
end

function DlgRoleHeart.OnClickedButtonExit(arg_7_0)
	arg_7_0:Close()
end

function DlgRoleHeart.OnClickedButtonOK(arg_8_0)
	if RoleMgr:IsNewRole(arg_8_0.roleId) then
		RoleMgr:RemovePlayerPrefsViewdRole(arg_8_0.roleId)
	end

	if not arg_8_0.heartPanelSelValue then
		UIMgr.ShowMsg("魔女未選択")

		return
	end

	if arg_8_0.typeId == 1 then
		if arg_8_0.curIndex == 1 then
			RoleCardMgr:SetRoleCardSelect("1_1_" .. arg_8_0.heartPanelSelValue)
		elseif arg_8_0.curIndex == 2 then
			RoleCardMgr:SetRoleCardSelect("2_" .. arg_8_0.CellSeatTeamValue .. "_" .. arg_8_0.heartPanelSelValue)
		elseif arg_8_0.curIndex == 3 then
			RoleCardMgr:SetRoleCardSelect("3_" .. arg_8_0.CellJobValue .. "_" .. arg_8_0.heartPanelSelValue)
		elseif arg_8_0.curIndex == 4 then
			RoleCardMgr:SetRoleCardSelect("4_" .. arg_8_0.CellDefaultTeamValue .. "_" .. arg_8_0.heartPanelSelValue)
		end

		Event.Instance:Fire("DlgRoleHeartUpdatePanel")
		arg_8_0:Close()
	else
		Event.Instance:Fire("RefreshShowRole", arg_8_0.roleId)
		arg_8_0:Close()
	end

	HeartPanelSelInfoRole = nil
end

function DlgRoleHeart.UpdateTabScroll(arg_9_0)
	local var_9_0 = 4
	local var_9_1 = -60
	local var_9_2 = 0

	arg_9_0.tabListItem = {}
	arg_9_0.tabListPosY = {}

	for iter_9_0 = 1, var_9_0 do
		local var_9_3
		local var_9_4 = CellHeartTab(arg_9_0.PrefabCellHeartTab, arg_9_0.Content, arg_9_0)

		var_9_4:Create()

		var_9_4.UIRootObject.name = iter_9_0

		var_9_4:UpdateData(tonumber(arg_9_0.curIndex) == iter_9_0, arg_9_0.tabValue)
		arg_9_0:AddClick(var_9_4.UIRootObject, arg_9_0.OnClickedCellHeartTab)

		arg_9_0.tabListItem[iter_9_0] = var_9_4

		local var_9_5 = 110

		if var_9_4 then
			GOUtil.SetRectTransformAnchoredPosition(var_9_4.UIRootObject, 0, var_9_1)

			arg_9_0.tabListPosY[iter_9_0] = var_9_1
		else
			var_9_5 = -110
		end

		var_9_1 = var_9_1 - var_9_5
		var_9_2 = var_9_2 + var_9_5
	end

	GOUtil.SetRectTransformSizeDelta(arg_9_0.Content, 292, 110 * var_9_0)
end

function DlgRoleHeart.InitScrollView(arg_10_0, arg_10_1)
	local var_10_0 = arg_10_0:GetChildGameObject("Main/Group/ScrollArea")
	local var_10_1 = arg_10_0:GetChildComponent("Main/Group/ScrollArea/Viewport/Content", "Transform")
	local var_10_2 = 4

	local function var_10_3(arg_11_0)
		arg_10_0:AddClick(arg_11_0.UIRootObject, arg_10_0.OnClickedCellHeartTab)
	end

	local function var_10_4(arg_12_0, arg_12_1)
		arg_12_0:UpdateData(arg_12_1)
	end

	arg_10_0.CellSeatTeamUIScrollTool:InitList(var_10_0, var_10_1, var_10_2, arg_10_0.PrefabCellHeartTab, CellHeartTab, arg_10_0, false, var_10_3, var_10_4)
end

function DlgRoleHeart.InitCellSeatTeam(arg_13_0, arg_13_1)
	local var_13_0 = arg_13_0:GetChildGameObject("Main/Group/ScrollArea/Viewport/Content/" .. arg_13_1 .. "/ScrollArea")
	local var_13_1 = arg_13_0:GetChildComponent("Main/Group/ScrollArea/Viewport/Content/" .. arg_13_1 .. "/ScrollArea/Content", "Transform")

	arg_13_0.listTeam = RoleMgr:GetTeamList()

	local var_13_2 = #arg_13_0.listTeam - 1

	local function var_13_3(arg_14_0)
		arg_13_0:AddClick(arg_14_0.UIRootObject, arg_13_0.OnClickedCellSeatTeam)
	end

	local function var_13_4(arg_15_0, arg_15_1)
		local var_15_0 = arg_13_0.listTeam[arg_15_1]

		arg_15_0:UpdateData(var_15_0, arg_15_1, arg_13_0.CellSeatTeamValue)
	end

	arg_13_0.tabValueList = {}
	arg_13_0.sameList = {}

	local var_13_5 = arg_13_0.listTeam[arg_13_0.CellSeatTeamValue].ID
	local var_13_6 = var_0_1[var_13_5].MemberList

	for iter_13_0 = 1, #var_13_6 do
		local var_13_7 = RoleMgr:GetRole(var_13_6[iter_13_0])

		table.insert(arg_13_0.sameList, var_13_7)
	end

	arg_13_0:ScrollViewPanelSort()

	arg_13_0.heartPanelSelValue = nil

	arg_13_0.UIScrollToolPanel:UpdateListData(arg_13_0.sameList)
	arg_13_0.CellSeatTeamUIScrollTool:InitList(var_13_0, var_13_1, var_13_2, arg_13_0.PrefabCellTeam, CellSeatTeam, arg_13_0, false, var_13_3, var_13_4)
	arg_13_0.CellSeatTeamUIScrollTool:SetContentPosImmediate(Vector2.New(0, 110 * (arg_13_0.CellSeatTeamValue - 1)), arg_13_0.listTeam)
end

function DlgRoleHeart.OnClickedCellSeatTeam(arg_16_0, arg_16_1)
	local var_16_0 = arg_16_1.pointerPress
	local var_16_1 = arg_16_0.CellSeatTeamUIScrollTool.ItemRoot2ItemDict:GetValue(var_16_0)
	local var_16_2 = tonumber(var_16_1.Item.Index)
	local var_16_3 = arg_16_0.listTeam[var_16_2].ID
	local var_16_4 = var_0_1[var_16_3].MemberList
	local var_16_5 = 0

	for iter_16_0 = 1, #var_16_4 do
		if TenaryOp(RoleMgr:GetRole(var_16_4[iter_16_0]).hold, 0, 1) == 0 then
			var_16_5 = 1
		end
	end

	if var_16_5 == 0 then
		UIMgr.ShowMsg(_("Msg_TeamLock"))

		return
	end

	arg_16_0.tabValueList = {}
	arg_16_0.sameList = {}
	arg_16_0.CellSeatTeamValue = var_16_2

	for iter_16_1 = 1, #var_16_4 do
		local var_16_6 = RoleMgr:GetRole(var_16_4[iter_16_1])

		table.insert(arg_16_0.sameList, var_16_6)
	end

	arg_16_0.CellSeatTeamUIScrollTool:UpdateListDataKeepPos(arg_16_0.listTeam)
	arg_16_0:ScrollViewPanelSort()

	arg_16_0.heartPanelSelValue = nil

	arg_16_0.UIScrollToolPanel:UpdateListData(arg_16_0.sameList)
end

function DlgRoleHeart.InitCellJob(arg_17_0, arg_17_1)
	local var_17_0 = arg_17_0:GetChildGameObject("Main/Group/ScrollArea/Viewport/Content/" .. arg_17_1 .. "/ScrollArea")
	local var_17_1 = arg_17_0:GetChildComponent("Main/Group/ScrollArea/Viewport/Content/" .. arg_17_1 .. "/ScrollArea/Content", "Transform")
	local var_17_2 = 5

	local function var_17_3(arg_18_0)
		arg_17_0:AddClick(arg_18_0.UIRootObject, arg_17_0.OnClickedCellJob)
	end

	local function var_17_4(arg_19_0, arg_19_1)
		arg_19_0:UpdateData(arg_19_1, arg_17_0.CellJobValue)
	end

	arg_17_0.tabValueList = {}
	arg_17_0.sameList = {}

	for iter_17_0 = 1, #arg_17_0.listTeamPanel do
		local var_17_5 = arg_17_0.listTeamPanel[iter_17_0].data.ID
		local var_17_6 = RoleMgr:GetRole(var_17_5)

		if arg_17_0.CellJobValue == var_17_6.job then
			table.insert(arg_17_0.sameList, RoleMgr:GetRole(var_17_5))
		end
	end

	arg_17_0:ScrollViewPanelSort()

	arg_17_0.heartPanelSelValue = nil

	arg_17_0.UIScrollToolPanel:UpdateListData(arg_17_0.sameList)
	arg_17_0.CellJobUIScrollTool:InitList(var_17_0, var_17_1, var_17_2, arg_17_0.PrefabCellJob, CellJob, arg_17_0, false, var_17_3, var_17_4)

	local var_17_7 = {}

	for iter_17_1 = 1, 5 do
		var_17_7[iter_17_1] = iter_17_1
	end

	arg_17_0.CellJobUIScrollTool:SetContentPosImmediate(Vector2.New(0, 110 * (arg_17_0.CellJobValue - 1)), var_17_7)
end

function DlgRoleHeart.OnClickedCellJob(arg_20_0, arg_20_1)
	arg_20_0.tabValueList = {}

	local var_20_0 = arg_20_1.pointerPress
	local var_20_1 = arg_20_0.CellJobUIScrollTool.ItemRoot2ItemDict:GetValue(var_20_0)
	local var_20_2 = tonumber(var_20_1.Item.Index)

	arg_20_0.CellJobValue = var_20_2
	arg_20_0.sameList = {}

	for iter_20_0 = 1, #arg_20_0.listTeamPanel do
		local var_20_3 = arg_20_0.listTeamPanel[iter_20_0].data.ID

		if var_20_2 == RoleMgr:GetRole(var_20_3).job then
			table.insert(arg_20_0.sameList, RoleMgr:GetRole(var_20_3))
		end
	end

	local var_20_4 = {}

	for iter_20_1 = 1, 5 do
		var_20_4[iter_20_1] = iter_20_1
	end

	arg_20_0.CellJobUIScrollTool:UpdateListDataKeepPos(var_20_4)
	arg_20_0:ScrollViewPanelSort()

	arg_20_0.heartPanelSelValue = nil

	arg_20_0.UIScrollToolPanel:UpdateListData(arg_20_0.sameList)
end

function DlgRoleHeart.InitCellDefaultTeam(arg_21_0, arg_21_1)
	local var_21_0 = arg_21_0:GetChildGameObject("Main/Group/ScrollArea/Viewport/Content/" .. arg_21_1 .. "/ScrollArea")
	local var_21_1 = arg_21_0:GetChildComponent("Main/Group/ScrollArea/Viewport/Content/" .. arg_21_1 .. "/ScrollArea/Content", "Transform")
	local var_21_2 = var_0_0.stageTeams

	local function var_21_3(arg_22_0)
		arg_21_0:AddClick(arg_22_0.UIRootObject, arg_21_0.OnClickedCellDefaultTeam)
	end

	local var_21_4 = 0
	local var_21_5 = {}

	for iter_21_0 = 1, 5 do
		local var_21_6 = var_21_2[iter_21_0]
		local var_21_7 = 0

		for iter_21_1 = 1, 10 do
			if var_21_6.roleCardTeams[iter_21_1] ~= 0 then
				var_21_7 = 1
			end
		end

		if var_21_7 == 1 then
			var_21_4 = var_21_4 + 1

			table.insert(var_21_5, iter_21_0)
		end
	end

	local function var_21_8(arg_23_0, arg_23_1)
		local var_23_0 = var_21_2[var_21_5[arg_23_1]]

		arg_23_0:UpdateData(var_23_0, arg_23_1, roleCardTeamNum, arg_21_0.CellDefaultTeamValue)
	end

	arg_21_0.tabValueList = {}
	arg_21_0.sameList = {}

	local var_21_9 = var_21_2[var_21_5[arg_21_0.CellDefaultTeamValue]]

	for iter_21_2 = 1, 5 do
		if tonumber(var_21_9.roleCardTeams[iter_21_2]) ~= 0 then
			arg_21_0.tabValueList[iter_21_2] = var_21_9.roleCardTeams[iter_21_2]

			table.insert(arg_21_0.sameList, RoleCardMgr:GetRole(arg_21_0.tabValueList[iter_21_2]))
		end
	end

	arg_21_0:ScrollViewPanelSort()

	arg_21_0.heartPanelSelValue = nil

	arg_21_0.UIScrollToolPanel:UpdateListData(arg_21_0.sameList)
	arg_21_0.CellDefaultTeamUIScrollTool:InitList(var_21_0, var_21_1, var_21_4, arg_21_0.PrefabCellDefaultTeam, CellDefaultTeam, arg_21_0, false, var_21_3, var_21_8)
	arg_21_0.CellDefaultTeamUIScrollTool:SetContentPosImmediate(Vector2.New(0, 110 * (arg_21_0.CellDefaultTeamValue - 1)), var_21_5)
end

function DlgRoleHeart.OnClickedCellDefaultTeam(arg_24_0, arg_24_1)
	arg_24_0.tabValueList = {}

	local var_24_0 = arg_24_1.pointerPress
	local var_24_1 = arg_24_0.CellDefaultTeamUIScrollTool.ItemRoot2ItemDict:GetValue(var_24_0)
	local var_24_2 = tonumber(var_24_1.Item.Index)

	arg_24_0.CellDefaultTeamValue = var_24_2
	arg_24_0.sameList = {}

	local var_24_3 = 0
	local var_24_4 = var_0_0.stageTeams
	local var_24_5 = {}

	for iter_24_0 = 1, 5 do
		local var_24_6 = var_24_4[iter_24_0]
		local var_24_7 = 0

		for iter_24_1 = 1, 5 do
			if var_24_6.roleCardTeams[iter_24_1] ~= 0 then
				var_24_7 = 1
			end
		end

		if var_24_7 == 1 then
			var_24_3 = var_24_3 + 1

			table.insert(var_24_5, iter_24_0)
		end
	end

	local var_24_8 = var_24_4[var_24_5[var_24_2]]

	for iter_24_2 = 1, 5 do
		if var_24_8.roleCardTeams[iter_24_2] ~= 0 then
			arg_24_0.tabValueList[iter_24_2] = var_24_8.roleCardTeams[iter_24_2]

			table.insert(arg_24_0.sameList, RoleCardMgr:GetRole(arg_24_0.tabValueList[iter_24_2]))
		end
	end

	arg_24_0.CellDefaultTeamUIScrollTool:UpdateListDataKeepPos(var_24_5)
	arg_24_0:ScrollViewPanelSort()

	arg_24_0.heartPanelSelValue = nil

	arg_24_0.UIScrollToolPanel:UpdateListData(arg_24_0.sameList)
end

function DlgRoleHeart.UpdateDlgRoleHeartScrollViewPanel(arg_25_0)
	arg_25_0:ScrollViewPanelSort()
	arg_25_0.UIScrollToolPanel:UpdateListDataKeepPos(arg_25_0.sameList)
end

function DlgRoleHeart.ScrollViewPanelSort(arg_26_0)
	local var_26_0 = {}
	local var_26_1 = {}
	local var_26_2 = {}
	local var_26_3 = {}
	local var_26_4 = {}

	for iter_26_0 = 1, #arg_26_0.sameList do
		var_26_0[iter_26_0] = {}
		var_26_0[iter_26_0].cellHeadData = {}
		var_26_0[iter_26_0].favoriteRoleId = {}
		var_26_0[iter_26_0].hold = {}
		var_26_0[iter_26_0].fightValue = {}
		var_26_0[iter_26_0].roleId = {}
		var_26_0[iter_26_0].cellHeadData = arg_26_0.sameList[iter_26_0]

		local var_26_5 = 0

		for iter_26_1 = 1, #PlayerInst.InfoPlayer.favoriteRoles do
			if arg_26_0.sameList[iter_26_0].id == PlayerInst.InfoPlayer.favoriteRoles[iter_26_1] then
				local var_26_6 = RoleMgr:GetRole(arg_26_0.sameList[iter_26_0].id)

				var_26_0[iter_26_0].fightValue = RoleMgr:GetRoleScore(var_26_6)
				var_26_0[iter_26_0].favoriteRoleId = 1
				var_26_5 = arg_26_0.sameList[iter_26_0].id
				var_26_0[iter_26_0].roleId = var_26_5

				table.insert(var_26_3, var_26_0[iter_26_0])
			end
		end

		if var_26_5 == 0 then
			var_26_0[iter_26_0].favoriteRoleId = 0
		end

		local var_26_7 = TenaryOp(arg_26_0.sameList[iter_26_0].hold, 0, 1)

		var_26_0[iter_26_0].hold = var_26_7

		local var_26_8 = RoleMgr:GetRole(arg_26_0.sameList[iter_26_0].id)

		if arg_26_0.sameList[iter_26_0].pb.roleCardId and var_26_0[iter_26_0].hold == 0 and var_26_0[iter_26_0].favoriteRoleId == 0 then
			var_26_0[iter_26_0].fightValue = RoleMgr:GetRoleScore(var_26_8)
			var_26_0[iter_26_0].roleId = var_26_8.id

			table.insert(var_26_2, var_26_0[iter_26_0])
		end
	end

	local var_26_9 = EasyFilter(var_26_3):AddSorter(function(arg_27_0, arg_27_1)
		if arg_27_0.fightValue == arg_27_1.fightValue then
			return arg_27_0.roleId > arg_27_1.roleId
		end

		return arg_27_0.fightValue > arg_27_1.fightValue
	end):Get()

	for iter_26_2, iter_26_3 in ipairs(var_26_9) do
		table.insert(var_26_1, var_26_9[iter_26_2].cellHeadData)
	end

	local var_26_10 = EasyFilter(var_26_2):AddSorter(function(arg_28_0, arg_28_1)
		if arg_28_0.fightValue == arg_28_1.fightValue then
			return arg_28_0.roleId > arg_28_1.roleId
		end

		return arg_28_0.fightValue > arg_28_1.fightValue
	end):Get()

	for iter_26_4, iter_26_5 in ipairs(var_26_10) do
		table.insert(var_26_1, var_26_10[iter_26_4].cellHeadData)
	end

	for iter_26_6 = 1, #arg_26_0.sameList do
		if var_26_0[iter_26_6].hold == 1 and var_26_0[iter_26_6].favoriteRoleId == 0 then
			table.insert(var_26_1, var_26_0[iter_26_6].cellHeadData)
		end
	end

	arg_26_0.sameList = var_26_1
end

function DlgRoleHeart.InitScrollViewPanel(arg_29_0)
	local var_29_0 = arg_29_0:GetChildGameObject("Main/Panel/ScrollArea")
	local var_29_1 = arg_29_0:GetChildComponent("Main/Panel/ScrollArea/Content", "Transform")
	local var_29_2 = #arg_29_0.sameList

	local function var_29_3(arg_30_0)
		arg_29_0:AddClick(arg_30_0.UIRootObject, arg_29_0.OnClickedCellRoleHead)
	end

	arg_29_0:ScrollViewPanelSort()

	local function var_29_4(arg_31_0, arg_31_1)
		local var_31_0 = {
			cellHeadData = arg_29_0.sameList[arg_31_1]
		}
		local var_31_1 = 0

		for iter_31_0 = 1, #PlayerInst.InfoPlayer.favoriteRoles do
			if arg_29_0.sameList[arg_31_1].id == PlayerInst.InfoPlayer.favoriteRoles[iter_31_0] then
				var_31_0.favoriteRoleId = 1
				var_31_1 = arg_29_0.sameList[arg_31_1].id
			end
		end

		if var_31_1 == 0 then
			var_31_0.favoriteRoleId = 0
		end

		if arg_29_0.roleId == arg_29_0.sameList[arg_31_1].id then
			var_31_0.roleId = 1
		end

		local var_31_2 = 0

		for iter_31_1 = 1, #arg_29_0.defaultTeamIdlist do
			if arg_29_0.sameList[arg_31_1].id == arg_29_0.defaultTeamIdlist[iter_31_1] then
				var_31_2 = 1
			end
		end

		if var_31_2 == 1 then
			var_31_0.jobValue = 1
		else
			var_31_0.jobValue = 0
		end

		if var_31_0.roleId == 1 then
			arg_29_0.heartPanelSelValue = arg_31_1
		end

		arg_31_0:UpdateData(var_31_0, arg_31_1)
	end

	arg_29_0.UIScrollToolPanel:InitList(var_29_0, var_29_1, var_29_2, arg_29_0.PrefabCellPanel, CellRoleHead, arg_29_0, false, var_29_3, var_29_4)
end

function DlgRoleHeart.OnClickedCellRoleHead(arg_32_0, arg_32_1)
	local var_32_0 = arg_32_1.pointerPress
	local var_32_1 = arg_32_0.UIScrollToolPanel.ItemRoot2ItemDict:GetValue(var_32_0)
	local var_32_2 = tonumber(var_32_1.Item.Index)

	if TenaryOp(arg_32_0.sameList[var_32_2].hold, 0, 1) == 1 then
		UIMgr.ShowMsg(_("Msg_IdolNotUnlock"))

		return
	end

	arg_32_0.heartPanelSelValue = var_32_2

	if arg_32_0.roleId == arg_32_0.sameList[var_32_2].id then
		return
	end

	arg_32_0.roleId = arg_32_0.sameList[var_32_2].id
	HeartPanelSelInfoRole = arg_32_0.sameList[var_32_2]

	arg_32_0:UpdateDlgRoleHeartScrollViewPanel()
end

function DlgRoleHeart.ClearTabUIScrollTool(arg_33_0, arg_33_1)
	if arg_33_1 == 2 and arg_33_0.IsCellSeatTeam then
		for iter_33_0 = 3, 4 do
			local var_33_0 = GOUtil.GetComponent(arg_33_0.tabListItem[iter_33_0].UIRootObject, "RectTransform").anchoredPosition.y

			GOUtil.SetRectTransformAnchoredPosition(arg_33_0.tabListItem[iter_33_0].UIRootObject, 0, 320 + var_33_0)
		end

		arg_33_0.IsCellSeatTeam = false

		GOUtil.SetRectTransformSizeDelta(arg_33_0.Content, 292, 440)
		arg_33_0.CellSeatTeamUIScrollTool:UpdateListData({})
	elseif arg_33_1 == 3 and arg_33_0.IsCellJob then
		local var_33_1 = GOUtil.GetComponent(arg_33_0.tabListItem[4].UIRootObject, "RectTransform").anchoredPosition.y

		GOUtil.SetRectTransformAnchoredPosition(arg_33_0.tabListItem[4].UIRootObject, 0, 320 + var_33_1)
		GOUtil.SetRectTransformSizeDelta(arg_33_0.Content, 292, 440)

		arg_33_0.IsCellJob = false

		arg_33_0.CellJobUIScrollTool:UpdateListData({})
	elseif arg_33_1 == 4 and arg_33_0.IsCellDefaultTeam then
		arg_33_0.IsCellDefaultTeam = false

		arg_33_0.CellDefaultTeamUIScrollTool:UpdateListData({})
	end
end

function DlgRoleHeart.OnClickedCellHeartTab(arg_34_0, arg_34_1, arg_34_2)
	local var_34_0 = {}
	local var_34_1 = 1

	if arg_34_1 then
		local var_34_2 = arg_34_1.pointerPress.gameObject

		var_34_1 = tonumber(var_34_2.name)
	else
		var_34_1 = arg_34_2
	end

	if var_34_1 == 1 then
		arg_34_0:ClearTabUIScrollTool(arg_34_0.curIndex)

		arg_34_0.curIndex = var_34_1
		arg_34_0.tabValue = 0

		for iter_34_0 = 1, 4 do
			arg_34_0.tabListItem[iter_34_0]:UpdateData(tonumber(arg_34_0.tabListItem[iter_34_0].UIRootObject.name) == arg_34_0.curIndex, arg_34_0.tabValue)
		end

		arg_34_0.sameList = arg_34_0.listTeamPanel

		arg_34_0:ScrollViewPanelSort()

		arg_34_0.heartPanelSelValue = nil

		arg_34_0.UIScrollToolPanel:UpdateListData(arg_34_0.sameList)
	elseif var_34_1 == 2 then
		if arg_34_0.curIndex ~= 2 then
			arg_34_0:ClearTabUIScrollTool(arg_34_0.curIndex)
		end

		arg_34_0.curIndex = var_34_1

		if arg_34_0.IsCellSeatTeam == false then
			arg_34_0.tabValue = 2
			arg_34_0.IsCellSeatTeam = true

			arg_34_0:InitCellSeatTeam(var_34_1)

			for iter_34_1 = 3, 4 do
				local var_34_3 = GOUtil.GetComponent(arg_34_0.tabListItem[iter_34_1].UIRootObject, "RectTransform").anchoredPosition.y

				GOUtil.SetRectTransformAnchoredPosition(arg_34_0.tabListItem[iter_34_1].UIRootObject, 0, -320 + var_34_3)
			end

			GOUtil.SetRectTransformSizeDelta(arg_34_0.Content, 292, 760)
		else
			for iter_34_2 = 1, 4 do
				local var_34_4 = GOUtil.GetComponent(arg_34_0.tabListItem[iter_34_2].UIRootObject, "RectTransform").anchoredPosition.y
				local var_34_5 = arg_34_0.tabListPosY[iter_34_2]

				GOUtil.SetRectTransformAnchoredPosition(arg_34_0.tabListItem[iter_34_2].UIRootObject, 0, var_34_5)
			end

			arg_34_0.CellSeatTeamUIScrollTool:UpdateListData({})
			GOUtil.SetRectTransformSizeDelta(arg_34_0.Content, 292, 440)

			arg_34_0.tabValue = 0
			arg_34_0.IsCellSeatTeam = false
		end

		for iter_34_3 = 1, 4 do
			arg_34_0.tabListItem[iter_34_3]:UpdateData(tonumber(arg_34_0.tabListItem[iter_34_3].UIRootObject.name) == arg_34_0.curIndex, arg_34_0.tabValue)
		end
	elseif var_34_1 == 3 then
		if arg_34_0.curIndex ~= 3 then
			arg_34_0:ClearTabUIScrollTool(arg_34_0.curIndex)
		end

		arg_34_0.curIndex = var_34_1

		if arg_34_0.IsCellJob == false then
			arg_34_0.tabValue = 3
			arg_34_0.IsCellJob = true

			arg_34_0:InitCellJob(var_34_1)

			local var_34_6 = GOUtil.GetComponent(arg_34_0.tabListItem[4].UIRootObject, "RectTransform").anchoredPosition.y

			GOUtil.SetRectTransformAnchoredPosition(arg_34_0.tabListItem[4].UIRootObject, 0, -320 + var_34_6)
			GOUtil.SetRectTransformSizeDelta(arg_34_0.Content, 292, 760)
		else
			arg_34_0.CellJobUIScrollTool:UpdateListData({})

			for iter_34_4 = 1, 4 do
				local var_34_7 = GOUtil.GetComponent(arg_34_0.tabListItem[iter_34_4].UIRootObject, "RectTransform").anchoredPosition.y
				local var_34_8 = arg_34_0.tabListPosY[iter_34_4]

				GOUtil.SetRectTransformAnchoredPosition(arg_34_0.tabListItem[iter_34_4].UIRootObject, 0, var_34_8)
			end

			GOUtil.SetRectTransformSizeDelta(arg_34_0.Content, 292, 440)

			arg_34_0.tabValue = 0
			arg_34_0.IsCellJob = false
		end

		for iter_34_5 = 1, 4 do
			arg_34_0.tabListItem[iter_34_5]:UpdateData(tonumber(arg_34_0.tabListItem[iter_34_5].UIRootObject.name) == arg_34_0.curIndex, arg_34_0.tabValue)
		end
	elseif var_34_1 == 4 then
		if arg_34_0.curIndex ~= 4 then
			arg_34_0:ClearTabUIScrollTool(arg_34_0.curIndex)
		end

		arg_34_0.curIndex = var_34_1

		if arg_34_0.IsCellDefaultTeam == false then
			arg_34_0.tabValue = 4
			arg_34_0.IsCellDefaultTeam = true

			arg_34_0:InitCellDefaultTeam(var_34_1)
			GOUtil.SetRectTransformSizeDelta(arg_34_0.Content, 292, 760)
		else
			arg_34_0.CellDefaultTeamUIScrollTool:UpdateListData({})
			GOUtil.SetRectTransformSizeDelta(arg_34_0.Content, 292, 440)

			arg_34_0.tabValue = 0
			arg_34_0.IsCellDefaultTeam = false
		end

		for iter_34_6 = 1, 4 do
			arg_34_0.tabListItem[iter_34_6]:UpdateData(tonumber(arg_34_0.tabListItem[iter_34_6].UIRootObject.name) == arg_34_0.curIndex, arg_34_0.tabValue)
		end
	end

	HeartPanelSelInfoRole = nil
end

function DlgRoleHeart.UpdateCell(arg_35_0, arg_35_1, arg_35_2)
	local var_35_0 = arg_35_0.listTeam[arg_35_2]

	arg_35_1:UpdateData(var_35_0)
end

function DlgRoleHeart.AddCellClick(arg_36_0, arg_36_1)
	arg_36_0:AddClick(arg_36_1.UIRootObject, arg_36_0.OnClickedCell)
end

function DlgRoleHeart.OnClickedCell(arg_37_0, arg_37_1)
	return
end
