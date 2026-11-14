-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Manager/UIMgr.lua

require("UI/Dlg/Common/DlgMessage")
require("UI/Dlg/Common/DlgMessage2")
require("UI/Dlg/Common/DlgCommon")
require("UI/Dlg/Common/DlgCommonEvent")
require("UI/Dlg/Public/PreviewActor")
require("Manager/SoundMgr")
require("Manager/ResourceMgr")

ePageType = {
	PageUnionRaid = 46,
	PageAsset = 13,
	PageUnionWish = 45,
	PageBossRaid = 39,
	PageTeam = 7,
	PageWork = 25,
	PageCard = 10,
	PageTower = 34,
	PageBossLive = 37,
	PagePVP = 33,
	PageBossActivity = 24,
	PageDifficult = 36,
	PageChapter = 1
}

local listPanel = {}
local listPanelChild = {}
local listPanelKeep = {}
local rootPanel
local updatePanel = {}
local focusPanel = {}
local listCachedPrefab = {}
local DlgMessageInst = DlgMessage()
local DlgMessage2Inst = DlgMessage2()
local listSwitchData

UIMgr = {
	UIRootObject = UIManager.GetLayerNode("DEFAULT"),
	UIPopupObject = UIManager.GetLayerNode("POPUP"),
	UIOverLayObject = UIManager.GetLayerNode("OVERLAY"),
	UILoadingObject = UIManager.GetLayerNode("LOADING"),
	UIGuideObject = UIManager.GetLayerNode("GUIDE"),
	RootCanvasTransform = UIManager.RootCanvasTransform,
	RootCanvas = UIManager.RootCanvas,
	RootCanvasScaler = UIManager.RootCanvasScaler,
	RootGraphicRaycaster = UIManager.RootGraphicRaycaster,
	UIEvetSystem = UIManager.UIEvetSystem,
	InputModule = UIManager.InputModule,
	UICamera = UIManager.UICamera,
	JPFonts = {
		W5 = "Font/DFHSGothicStdN-W5",
		YukiB = "Font/DFROMANYUKIBSTDN-W9"
	}
}

function UIMgr.Init()
	GOUtil.DestroyAllChildren(UIMgr.UIRootObject)
	GOUtil.DestroyAllChildren(UIMgr.UIPopupObject)
	GOUtil.DestroyAllChildren(UIMgr.UIOverLayObject)
	GOUtil.DestroyAllChildren(UIMgr.UIGuideObject)

	listPanelKeep = {}

	UIMgr.CustomInit()
	UIMgr.SetDontDisposeOnUnloadAll()
end

function UIMgr.SetDontDisposeOnUnloadAll()
	for i = 1, #listPanelKeep do
		local panel = listPanelKeep[i]

		if panel then
			panel.UIPrefabCache.DontDisposeOnUnloadAll = true
		end
	end
end

function UIMgr.ShowDialogWithTitle(title, msg, callback)
	local args = {
		DlgCommonEvent.Type.Msg,
		title,
		msg,
		callback
	}
	local dialog = DlgCommonEvent()

	UIMgr.AddPanel(dialog, args, UIMgr.UIGuideObject)
end

function UIMgr.ShowWithText(vCallBack, vMsg, vTitle, vOkBtn)
	DlgCommonInst:ShowWithText(vCallBack, vMsg, vTitle, vOkBtn)
end

function UIMgr.ShowCommonKc(_type, strTitle, _data, vCallBack, strOkText, strCancelText, needQuit, forceBack)
	local args = {
		_type,
		strTitle,
		_data,
		vCallBack,
		strOkText,
		strCancelText,
		needQuit,
		[9] = forceBack
	}
	local dialog = DlgCommonEvent()

	UIMgr.AddPanel(dialog, args, UIMgr.UIGuideObject)

	return dialog
end

function UIMgr.HideCommon()
	print("Call HideCommon() " .. #listPanelChild)

	if #listPanelChild >= 1 then
		for i = #listPanelChild, 1, -1 do
			local panel = listPanelChild[i]

			if panel.className == "DlgCommonEvent" then
				if not panel.closed and panel.isOnEnter then
					print("kill common event")
					panel:Close()
					table.remove(listPanelChild, i)
				else
					panel.preClose = true
				end

				return
			end
		end
	end
end

function UIMgr.Clear()
	UIMgr.PurgeCurPanel()

	for i = #listPanelChild, 1, -1 do
		local panel = listPanelChild[i]

		if panel and not panel.closed then
			panel:Close()
		end
	end

	listPanelChild = {}
	listPanel = {}

	for _, v in pairs(listCachedPrefab) do
		ResourceMgr.Unload(v)
	end

	listCachedPrefab = {}

	UIMgr:ClearDot()
	UIMgr.HideMsg()
	UIMgr.HideMsg2()
end

function UIMgr.ClearMain()
	for i = 1, #listPanelChild do
		local panel = listPanelChild[i]

		if panel and not panel.closed then
			panel:Close()
		end
	end

	listPanelChild = {}
	listPanel = {}

	UIMgr.PurgeCurPanel()
	UIMgr:ClearDot()
end

function UIMgr.ClearAndSavePageMainStage()
	local pageMainStage

	for i = #listPanelChild, 1, -1 do
		local panel = listPanelChild[i]

		if panel and not panel.closed and panel.className ~= "PreviewActor" and panel.className ~= "PageShop" and panel.className ~= "DlgWorldMap" then
			panel:Close()
			table.remove(listPanelChild, i)
		end
	end

	for i = 1, #listPanel do
		local panel = listPanel[i]

		if panel and panel.className == "PageMainStage" then
			pageMainStage = panel

			break
		end
	end

	pageMainStage.loadedCount = 0
	listPanel = {
		pageMainStage
	}

	UIMgr:ClearDot()
end

function UIMgr.ClearChildAndSavePageMainStage()
	local pageMainStage

	for i = #listPanelChild, 1, -1 do
		local panel = listPanelChild[i]

		if panel and not panel.closed and panel.className ~= "PreviewActor" and panel.className ~= "DlgWorldMap" then
			panel:Close()
			table.remove(listPanelChild, i)
		end
	end
end

function UIMgr.PurgeCurPanel()
	if rootPanel then
		rootPanel:Close()
	end

	rootPanel = nil
end

function UIMgr.GetPanel(strPanelName)
	for _, v in pairs(listPanel) do
		if v and v.className == strPanelName then
			return v
		end
	end

	for _, v in pairs(listPanelChild) do
		if v and v.className == strPanelName and v.closed == false then
			return v
		end
	end

	return nil
end

function UIMgr.GetCurPanel()
	return rootPanel
end

function UIMgr.SetCurPanel(panel)
	rootPanel = panel
end

function UIMgr.SetUpdatePanel(panel)
	if panel == nil then
		PrintWithColor("=====現在の値はNullです=====更新の方法をUIMgr.RemoveUpdatePanel", "redへ修正します")

		return
	end

	updatePanel[panel.instance_key] = panel
end

function UIMgr.RemoveUpdatePanel(panel)
	if panel == nil then
		PrintWithColor("=====当前传值为空=====移除更新的方法改为UIMgr.RemoveUpdatePanel", "red")

		return
	end

	if updatePanel[panel.instance_key] then
		updatePanel[panel.instance_key] = nil
	end
end

function UIMgr.CachePrefab(strPath)
	if listCachedPrefab[strPath] == nil then
		ResourceMgr.SubmitCache(strPath, listCachedPrefab, strPath, GameObject)
	end
end

function UIMgr.AddCachedPrefab(strPath, prefab)
	if listCachedPrefab[strPath] == nil then
		listCachedPrefab[strPath] = prefab
	end
end

function UIMgr.GetCachedPrefab(strPath)
	return listCachedPrefab[strPath]
end

function UIMgr.InsertPanel(panelClass, vParam)
	local data = {}

	data.className = panelClass.className
	data.vParam = vParam

	InfoBGMEventMgr:LoadBank(panelClass.className)
	table.insert(listPanel, data)
end

local rootPanelName, waitPanelName

function UIMgr.SwitchPanel(panelClass, vParam, isRootPanel, isSyncLoad)
	local panel = UIMgr.GetCurPanel()

	if panel and panel.className == panelClass.className then
		Event.Instance:Fire("PageShopCloseEvent")

		return
	end

	local className

	if isRootPanel then
		if panelClass.isClass then
			rootPanel = panelClass()
		else
			rootPanel = panelClass
		end

		className = rootPanel.className
		rootPanelName = className

		rootPanel:Create(UIMgr.UIRootObject, vParam, true)
	else
		className = panelClass.className
		listSwitchData = {
			panelClass,
			vParam,
			isSyncLoad
		}
	end

	if isSyncLoad then
		rootPanelName = nil
		waitPanelName = className
	end

	local data = {}

	data.className = className
	data.vParam = vParam

	InfoBGMEventMgr:LoadBank(className)
	table.insert(listPanel, data)
	UIMgr.HideMsg()
	UIMgr.HideMsg2()
	UIMgr.RecordSwitchTimes()
end

function UIMgr.PopPanel(newParam, count)
	for i = 1, count or 1 do
		table.remove(listPanel)
	end

	local data = listPanel[#listPanel]

	if not data then
		return
	end

	local vParam = data.vParam

	if newParam then
		vParam = newParam
	end

	local panel = _G[data.className]

	if data.className == "PageInteraction" then
		SceneMainStage.Instance:OnEnterInteractionByRoleId(CharacterThinMgr.CurSwitchRole(), nil)
	else
		UIMgr.SwitchPanel(panel, vParam)
	end

	table.remove(listPanel)
end

function UIMgr.GetPrePanel()
	local data = listPanel[#listPanel - 1]

	return data
end

function UIMgr.AddPanel(panel, vParam, root, isKeep, noSound)
	if not isKeep and not noSound then
		SoundMgr.Play(PATH_SFX_UI_DIALOG)
	end

	local parentGo = UIMgr.UIRootObject

	if root then
		parentGo = root
	end

	panel.isKeep = isKeep

	panel:Create(parentGo, vParam, false)

	if not isKeep then
		table.insert(listPanelChild, panel)
	else
		table.insert(listPanelKeep, panel)
	end
end

function UIMgr.UpdateSecond()
	if rootPanel and rootPanel.OnUpdateSecond then
		rootPanel:OnUpdateSecond()
	end

	for _, value in pairs(updatePanel) do
		if value.OnUpdateSecond then
			value:OnUpdateSecond()
		end
	end

	UIMgr.CustomUpdateSecond()
end

function UIMgr.ClearRoot(panelName)
	if UIMgr.prePanel and not UIMgr.prePanel.closed then
		UIMgr.prePanel:Close()

		UIMgr.prePanel = nil
	end
end

function UIMgr.OnPanelEnter(className)
	if waitPanelName then
		if waitPanelName == className then
			waitPanelName = nil

			LoadingMgr.Hide(eLoadingType.Progress)
		end

		return
	end

	if rootPanelName == className then
		rootPanelName = nil

		LoadingMgr.Hide(eLoadingType.Progress)
	end
end

function UIMgr.Update()
	if listSwitchData then
		UIMgr.starttime = os.clock()
		UIMgr.prePanel = rootPanel

		if listSwitchData[3] then
			UIMgr.PurgeCurPanel()
		else
			FingerGesturesUtil.Disable()

			if rootPanel.isOnEnter then
				rootPanel:OnUnRegisterEvent()
			end
		end

		local panelClass = listSwitchData[1]

		if panelClass.isClass then
			rootPanel = panelClass()
		else
			rootPanel = panelClass
		end

		if listSwitchData[3] then
			rootPanel.needPrePurge = false
		else
			rootPanel.needPrePurge = true
		end

		rootPanel:Create(UIMgr.UIRootObject, listSwitchData[2], true)

		listSwitchData = nil

		Event.Instance:Fire(EventId.UIPanel.Loaded, rootPanel.className)
	end

	if rootPanel and rootPanel.OnUpdate then
		rootPanel:OnUpdate()
	end

	for _, value in pairs(updatePanel) do
		if value.OnUpdate then
			value:OnUpdate()
		end
	end

	UIMgr.CustomUpdate()
end

function UIMgr.GetResoulutionX()
	return UIManager.GetResoulutionX()
end

function UIMgr.GetResoulutionY()
	return UIManager.GetResoulutionY()
end

local backUiBlack = {
	"PageChildGift",
	"PreviewActor"
}
local igonePopList = {
	"RollingNotice",
	"DlgMessage",
	"DlgMessage2"
}

function UIMgr.PopChild()
	if #listPanelChild >= 1 then
		local panel = listPanelChild[#listPanelChild]

		if panel and table.contains(igonePopList, panel.className) then
			local idx_st = #listPanelChild - 1

			repeat
				panel = listPanelChild[idx_st]
				idx_st = idx_st - 1
			until panel ~= nil and not table.contains(igonePopList, panel.className) or idx_st < 1
		end

		if panel and not table.contains(backUiBlack, panel.className) and not panel.closed and panel.isOnEnter then
			if panel.OnBackAndroid then
				panel:OnBackAndroid()
			elseif panel.OnBack then
				panel:OnBack()
			else
				panel:Close()
			end

			return true
		end
	end

	return false
end

function UIMgr.PopChildByName(clsName)
	if #listPanelChild >= 1 then
		local panel = listPanelChild[#listPanelChild]

		if panel and panel.className == clsName and not panel.closed and panel.isOnEnter then
			table.remove(listPanelChild)
			panel:Close()

			return true
		end
	end

	return false
end

local systemList = {
	"DlgCommonEvent",
	"DlgGetAward",
	"DlgProducerLevelUp",
	"DlgUpResult",
	"PageBossRaidBattleEnd",
	"DlgBossRaidOver"
}

function UIMgr.PopSystem()
	if #listPanelChild >= 1 then
		local panel = listPanelChild[#listPanelChild]

		if panel and table.contains(systemList, panel.className) and not panel.closed and panel.isOnEnter then
			panel:OnBackAndroid()

			return true
		end
	end

	return false
end

function UIMgr.PopPanelInner()
	local currPanel = UIMgr.GetCurPanel()

	if currPanel and currPanel.OnBackAndroid then
		return currPanel:OnBackAndroid()
	end

	return false
end

function UIMgr.ClickDlgExit()
	local panel = rootPanel

	if not panel or not panel.UIRootObject or not panel.UIRootObject.activeSelf then
		return false
	end

	local exitPanel = panel:GetChildPanel("DlgExit")

	if exitPanel == nil then
		for i = #listPanelChild, 1, -1 do
			panel = listPanelChild[i]

			if not panel.closed then
				exitPanel = panel:GetChildPanel("DlgExit")

				break
			end
		end
	end

	if exitPanel and not panel.closed and panel.isOnEnter then
		exitPanel:OnClickedBtnReturn()

		return true
	end

	return false
end

function UIMgr.ClearClassStackData(className)
	local panel = UIMgr.GetPanel(className)

	if panel ~= nil then
		panel.vParam = nil
	end
end

function UIMgr.ShowMsg(str, tab)
	SoundMgr.Play(PATH_SFX_UI_PROMPT)

	if tab and tab._message_name and tab.result and tab.result.code then
		if tab.result.code == 1002 then
			ShowFuncForbidDialog()

			return
		end

		str = _(tostring(string.format("%s_%s", tab._message_name, tab.result.code)))

		if str == tostring(string.format("%s_%s", tab._message_name, tab.result.code)) then
			str = _("P_Com_Response_1000")
		end

		if tab.result.extra then
			for i = 1, #tab.result.extra do
				str = string.gsub(str, "{" .. i - 1 .. "}", tostring(tab.result.extra[i]))
			end

			if tab._message_name == "P167_Response" and tab.result.code == 11 then
				NetManagerTimeDownToLocal(tab._message_name .. "_" .. tab.result.code, tab.result.extra)
			elseif tab._message_name == "P167_Response" and tab.result.code == 13 then
				NetManagerTimeDownToLocal(tab._message_name .. "_" .. tab.result.code, tab.result.extra)
			elseif tab._message_name == "P161_Response" and tab.result.code == 7 then
				NetManagerTimeDownToLocal(tab._message_name .. "_" .. tab.result.code, tab.result.extra)
			elseif tab._message_name == "P162_Response" and tab.result.code == 5 then
				NetManagerTimeDownToLocal(tab._message_name .. "_" .. tab.result.code, tab.result.extra)
			end
		end
	end

	if DlgMessageInst == nil or DlgMessageInst.closed then
		UIMgr.AddPanel(DlgMessageInst, {
			str
		}, UIMgr.UIPopupObject)
	else
		DlgMessageInst:Show(str)
	end
end

function UIMgr.ShowMsgWithItem(id, num)
	if DlgMessageInst == nil or DlgMessageInst.closed then
		UIMgr.AddPanel(DlgMessageInst, {
			id,
			num
		}, UIMgr.UIPopupObject)
	else
		DlgMessageInst.ShowItem(id, num)
	end
end

function UIMgr.HideMsg()
	if not DlgMessageInst.closed then
		DlgMessageInst:OnEndMsg()
	end
end

function UIMgr.ShowMsg2(str, noTimer)
	if DlgMessage2Inst == nil or DlgMessage2Inst.closed then
		UIMgr.AddPanel(DlgMessage2Inst, {
			str,
			noTimer
		}, UIMgr.UIPopupObject)
	else
		DlgMessage2Inst:Show(str, noTimer)
	end
end

function UIMgr.HideMsg2()
	if not DlgMessage2Inst.closed then
		DlgMessage2Inst:OnEndMsg()
	end
end

function UIMgr.ResetMsg2Position()
	if not IsNil(DlgMessage2Inst.UIRootObject) and DlgMessage2Inst.UIRootObject.activeSelf then
		DlgMessage2Inst:ResetPosition()
	end
end

function UIMgr.ResetMsg2OffsetType(_type)
	DlgMessage2Inst.DlgMessage2Off = _type
end

function UIMgr.ShowDialog(str, callback, tab)
	if tab and tab._message_name and tab.result and tab.result.code then
		str = _(tostring(string.format("%s_%s", tab._message_name, tab.result.code)))

		for i = 1, #tab.result.extra do
			str = string.gsub(str, "{" .. i - 1 .. "}", tostring(tab.result.extra[i]))
		end
	end

	local args = {
		DlgCommonEvent.Type.Msg,
		_("Desc_Alert"),
		str,
		callback
	}

	UIMgr.AddPanel(DlgCommonEvent(), args, UIMgr.UIGuideObject)
end

function UIMgr.ShowCommon(_type, strTitle, _data, vCallBack, strOkText, strCancelText, needQuit, forceBack)
	local args = {
		_type,
		strTitle,
		_data,
		vCallBack,
		strOkText,
		strCancelText,
		needQuit,
		[9] = forceBack
	}

	UIMgr.AddPanel(DlgCommonEvent(), args, UIMgr.UIGuideObject)
end

require("UI/Dlg/Common/DlgItemTip")
require("UI/Dlg/Common/SkillTip")
require("UI/Dlg/Common/SkillTips")
require("UI/Dlg/Public/RollingNotice")
require("UI/Dlg/Common/BuffTip")
require("UI/Page/PageGuide/DlgGuide")

local DlgItemTipInst = DlgItemTip()
local DlgSkillTip = SkillTip()
local DlgSkillTips = SkillTips()
local DlgBuffTip = BuffTip()
local RollingNoticeInst = RollingNotice()

UIMgr.DlgGuide = DlgGuide()

function UIMgr.CustomInit()
	UIMgr.AddPanel(RollingNoticeInst, nil, UIMgr.UIPopupObject, true)

	UIMgr.listDot = {}
	UIMgr.DefaultDotOffset = Vector2(-30, -30)
end

function UIMgr:AddDot(parentGo, tag, posType, posOffset)
	local go

	if tag and UIMgr.listDot[tag] ~= nil then
		Object.Destroy(UIMgr.listDot[tag])
	end

	if go == nil then
		go = GOUtil.InstantiateUIPrefab(UIMgr.PrefabDot, parentGo)
		UIMgr.listDot[tag] = go
	end

	go.name = "ImgDot"

	local offset = Vector2.zero

	if posType == nil then
		posType = 1
		offset = UIMgr.DefaultDotOffset
	end

	if posOffset then
		offset = posOffset
	end

	GOUtil.SetRectTransformOffsetType(go, posType, offset.x, offset.y)

	return go
end

function UIMgr:RemoveDot(tag)
	if tag then
		local go = UIMgr.listDot[tag]

		if go then
			Object.Destroy(go)
		end

		UIMgr.listDot[tag] = nil
	end
end

function UIMgr:ShowDot(tag)
	if tag then
		local go = UIMgr.listDot[tag]

		if go then
			go:SetActive(true)
		end
	end
end

function UIMgr:HideDot(tag)
	if tag then
		local go = UIMgr.listDot[tag]

		if go then
			go:SetActive(false)
		end
	end
end

function UIMgr:ClearDot()
	for _, v in pairs(UIMgr.listDot) do
		if v then
			Object.Destroy(v)
		end
	end

	UIMgr.listDot = {}
end

function UIMgr.ShowItemTip(info, initPanelIndex, showNum, hideFromBtn, callback, needItem)
	if DlgItemTipInst.closed == true then
		local args = {
			info,
			initPanelIndex,
			showNum,
			hideFromBtn,
			callback,
			needItem
		}

		DlgItemTipInst.isSyncLoad = true

		UIMgr.AddPanel(DlgItemTipInst, args, UIMgr.UIPopupObject)
	end
end

function UIMgr.HideItemTip()
	DlgItemTipInst:Hide()
end

function UIMgr.ShowSkillTips(datas, position)
	if DlgSkillTips.closed == true then
		DlgSkillTips.isSyncLoad = true

		UIMgr.AddPanel(DlgSkillTips, {
			datas,
			position
		}, UIMgr.UIPopupObject)
	end
end

function UIMgr.HideSkillTips()
	DlgSkillTips:Hide()
end

function UIMgr.ShowSkillTip(data)
	if DlgSkillTip.closed == true then
		DlgSkillTip.isSyncLoad = true

		UIMgr.AddPanel(DlgSkillTip, data, UIMgr.UIPopupObject)
	end
end

function UIMgr.HideSkillTip()
	DlgSkillTip:Hide()
end

function UIMgr.ShowBuffTip(buffs, scenePos, offset)
	if DlgBuffTip.closed == true then
		DlgBuffTip.isSyncLoad = true

		UIMgr.AddPanel(DlgBuffTip, {
			buffs,
			scenePos,
			offset
		}, UIMgr.UIPopupObject)
	end
end

function UIMgr.HideBuffTip()
	DlgBuffTip:Hide()
end

function UIMgr.ShowGuide()
	if UIMgr.DlgGuide and IsNil(UIMgr.DlgGuide.UIRootObject) then
		UIMgr.DlgGuide:Close()

		UIMgr.DlgGuide = DlgGuide()
		UIMgr.DlgGuide.isSyncLoad = true

		UIMgr.AddPanel(UIMgr.DlgGuide, nil, UIMgr.UIGuideObject, nil, true)
	end
end

function UIMgr.HideGuide()
	if UIMgr.DlgGuide and not UIMgr.DlgGuide.closed then
		UIMgr.DlgGuide:Close()
	end
end

function UIMgr.CustomUpdate()
	RollingNoticeInst:Update()
end

function UIMgr.CustomUpdateSecond()
	RollingNoticeInst:UpdateSecond()
end

function UIMgr.BuildPreviewActor(systemType, parentPanel)
	if not UIMgr.PreviewActor then
		UIMgr.PreviewActor = PreviewActor(systemType)

		UIMgr.AddPanel(UIMgr.PreviewActor, nil, UIMgr.UIRootObject)
	end

	UIMgr.PreviewActor.parentPanel = parentPanel
end

function UIMgr.ClearPreviewActor()
	if UIMgr.PreviewActor then
		if not IsNil(UIMgr.PreviewActor.UIRootObject) then
			UIMgr.PreviewActor.UIRootObject:Destroy()
		end

		if not UIMgr.PreviewActor.closed then
			UIMgr.PreviewActor:Close()
		end

		UIMgr.PreviewActor = nil
	end

	for i = 1, #listPanelChild do
		local panel = listPanelChild[i]

		if panel and panel.className == "PreviewActor" then
			if not panel.closed then
				panel:Close()
			end

			table.remove(listPanelChild, i)

			break
		end
	end
end

function UIMgr.SwitchPreviewActor()
	if not UIMgr.PreviewActor then
		UIMgr.ClearPreviewActor()

		return
	end

	UIMgr.PreviewActor.systemType = nil

	local lastPanel = listPanel[#listPanel]

	if lastPanel then
		if lastPanel.className == "PageRole" then
			UIMgr.PreviewActor.systemType = eActorSystemType.ROLE
		elseif lastPanel.className == "PageEquip" then
			UIMgr.PreviewActor.systemType = eActorSystemType.EQUIP
		elseif lastPanel.className == "PageEquipAvatar" then
			UIMgr.PreviewActor.systemType = eActorSystemType.AVATAR
		end
	end

	if UIMgr.PreviewActor.systemType == nil then
		UIMgr.ClearPreviewActor()
	else
		UIMgr.PreviewActor:ChangeLens()
	end
end

function UIMgr:GetPageType()
	local panel = UIMgr.GetCurPanel()

	if panel ~= nil then
		if panel.className == "PageChapter" then
			if ChapterMgr:GetBatteleTypeEnumID() == 0 then
				return ePageType.PageChapter
			else
				return ePageType.PageDifficult
			end
		elseif panel.className == "PageTeamPass" then
			return ePageType.PageTeam
		elseif panel.className == "PageCardStage" then
			return ePageType.PageCard
		elseif panel.className == "PageAssetStage" then
			return ePageType.PageAsset
		elseif panel.className == "PageBossActivityBG" then
			return ePageType.PageBossActivity
		elseif panel.className == "PagePVPMain" then
			return ePageType.PagePVP
		elseif panel.className == "PageBosslive" then
			return ePageType.PageBossLive
		elseif panel.className == "PageStage" then
			if panel.chapterType == ChapterFromType.main then
				return ePageType.PageChapter
			elseif panel.chapterType == ChapterFromType.comb then
				return ePageType.PageTeam
			elseif panel.chapterType == ChapterFromType.mainhard then
				return ePageType.PageDifficult
			end
		end
	end

	return nil
end

function UIMgr.ListChildPurge(panel)
	for i = #listPanelChild, 1, -1 do
		if panel == listPanelChild[i] then
			table.remove(listPanelChild, i)
		end
	end
end

function UIMgr:GetUIManagerGo()
	if not self.UIManagerGo then
		local launcher = GameObject.Find("Launcher")

		self.UIManagerGo = GOUtil.GetComponent(launcher, "UIManager")
	end

	return self.UIManagerGo
end

function UIMgr.RecordSwitchTimes()
	if not AvatarManager.needPresave then
		return
	end

	local isExist = false

	for i = #listPanel, 1, -1 do
		if listPanel[i].className == "PageFittingroom" then
			if i + 2 <= #listPanel then
				AvatarManager.needPresave = false
			end

			isExist = true

			break
		end
	end

	if not isExist then
		AvatarManager.needPresave = fasle
	end
end

function UIMgr:SetSafeArea(class, safeAreaObj)
	if IsNil(safeAreaObj) or Application.isEditor then
		return
	end

	if self.safeList == nil then
		self.safeList = {}
	end

	for i = #self.safeList, 1, -1 do
		local data = self.safeList[i]

		if data.class == class then
			for i = #data.rt, 1, -1 do
				if data.rt[i].gameObject == safeAreaObj then
					DealWithSafeArea(data.rt[i])

					return
				end
			end

			local rt = GOUtil.GetComponent(safeAreaObj, "RectTransform")

			table.insert(data.rt, rt)
			DealWithSafeArea(rt)

			return
		end
	end

	local data = {}

	data.class = class
	data.rt = {
		GOUtil.GetComponent(safeAreaObj, "RectTransform")
	}

	table.insert(self.safeList, data)
	DealWithSafeArea(data.rt[1])

	if UIMgr:GetUIManagerGo().screenOrientationAction == nil then
		UIMgr:GetUIManagerGo().screenOrientationAction = function()
			if #listPanelChild >= 1 then
				local panel = listPanelChild[#listPanelChild]

				if panel and panel.className == "DlgWeb" then
					return
				end
			end

			for i = #self.safeList, 1, -1 do
				local data = self.safeList[i]

				if data.class == nil or #data.rt == 0 then
					table.remove(self.safeList, i)
				else
					for i = #data.rt, 1, -1 do
						DealWithSafeArea(data.rt[i])
					end
				end
			end
		end
	end
end

function UIMgr:RemoveSafeArea(class)
	if self.safeList ~= nil then
		for i = #self.safeList, 1, -1 do
			local data = self.safeList[i]

			if data.class == class then
				table.remove(self.safeList, i)

				return
			end
		end
	end
end

function UIMgr:RemoveAllSafeArea()
	self.safeList = {}
end

function UIMgr.ShowMessage(msg)
	UIMgr.ShowMsg(_(msg))
end

function UIMgr.CheckBlacklist(deviceModel)
	local list = GetConfigArgJson("ARBlacklist")

	for key, value in pairs(list) do
		if value == deviceModel then
			return true
		end
	end

	return false
end

function UIMgr.FireEvent(msg)
	Event.Instance:Fire(msg)
end

function UIMgr:ShowBlock()
	if self.BlockUI == nil then
		require("UI/Dlg/Public/DlgBlock")

		self.BlockUI = DlgBlock()
		DlgBlock.isSyncLoad = true

		UIMgr.AddPanel(self.BlockUI, nil, UIMgr.UIPopupObject)
	end
end

function UIMgr:HideBlock()
	if self.BlockUI then
		self.BlockUI:Close()

		self.BlockUI = nil
	end
end

function UIMgr.SetFocusChange(panel)
	if panel ~= nil then
		focusPanel[panel.instance_key] = panel
	end

	if UIMgr:GetUIManagerGo().focusChangeAction == nil then
		UIMgr:GetUIManagerGo().focusChangeAction = function(isFocus)
			for key, value in pairs(focusPanel) do
				if value.OnApplicationFocus then
					value:OnApplicationFocus(isFocus)
				end
			end
		end
	end
end

function UIMgr.RemoveFocusChange(panel)
	if focusPanel[panel.instance_key] then
		focusPanel[panel.instance_key] = nil
	end
end

function UIMgr.ShowArPremission(msgType, title, callback)
	if Application.platform:ToInt() == RuntimePlatform.IPhonePlayer then
		UIMgr.ShowCommon(msgType, title, _("Desc_NeedOpenCameraPermissions_IOS"), callback)
	else
		local androidFirst = PlayerPrefs.GetString("ANDROID_CAMERA_REQUIRED_FIRST", "0") == "0"

		if androidFirst then
			PlayerPrefs.SetString("ANDROID_CAMERA_REQUIRED_FIRST", "1")
			PlayerPrefs.Save()
		end

		UIMgr.ShowCommon(msgType, title, androidFirst and _("Desc_NeedOpenCameraPermissions_ANDROID") or _("Desc_NeedOpenCameraPermissions_ANDROID_SECOND"), callback)
	end
end

function UIMgr.ShowArPhotoSave()
	local androidFirst = PlayerPrefs.GetString("ANDROID_AR_SAVE_REQUIRED_FIRST", "0") == "0"

	if androidFirst then
		PlayerPrefs.SetString("ANDROID_AR_SAVE_REQUIRED_FIRST", "1")
		PlayerPrefs.Save()
	end

	UIMgr.ShowDialog(androidFirst and _("DESC_SAVE_PHOTO_NO_PERMISSION_ANDROID_FIRST") or _("DESC_SAVE_PHOTO_NO_PERMISSION_ANDROID"))
end
