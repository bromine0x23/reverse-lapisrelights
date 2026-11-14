-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageWork/PageWork.lua

require("UI/Page/PageWork/CellWork")
require("UI/Page/PageWork/CellWorkCard")
require("UI/Page/PageWork/PageConditionCard")
require("UI/Page/PageWork/DlgGetWorkAward")

PageWork = class("PageWork", UIPanel)

local eVocalType = {
	SendWork = 1,
	ExtraNone = 3,
	SelectCard = 2
}

function PageWork:ctor()
	self.UIPrefabPath = "UI/PanelWork/PanelWork"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_work"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())

	self.notResetTempData = false
end

function PageWork:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem", GameObject)
	self:LoadResAsync("UI/PanelWork/CellWork", "PrefabCellWork", GameObject)
	self:LoadResAsync("UI/PanelWork/CellWorkCard", "PrefabCellWorkCard", GameObject)
	self:LoadResAsync("UI/PanelWork/PerfectComplete", "PrefabPerfectComplete", GameObject)
end

function PageWork:OnBack()
	UIMgr.PopPanel()
end

function PageWork:Purge()
	self.base.Purge(self)
	self:OnLeave()

	if self.infoWork and not self.notResetTempData then
		self.infoWork:ResetTempData()

		WorkMgr.WorkIdx = 0
	end

	self.RTEffCamera.targetTexture = nil

	UnityEngine.RenderTexture.ReleaseTemporary(self.RTEffTexture)

	self.RTEffTexture = nil
end

function PageWork:OnLeave()
	ResourceMgr.Unload(self.PrefabCellItem)
	ResourceMgr.Unload(self.PrefabCellWork)
	ResourceMgr.Unload(self.PrefabCellWorkCard)
	ResourceMgr.Unload(self.PrefabPerfectComplete)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	self:ClearOther()
	self:ClearTimer()

	if self.listLoadedBankRoleId then
		for _, v in ipairs(self.listLoadedBankRoleId) do
			local role = RoleMgr:GetRole(v)

			if role then
				SoundMgr.UnloadBank(role.data.VocalBank)
			end
		end

		self.listLoadedBankRoleId = nil
	end

	if self.lastRole and self.lastPath then
		SoundMgr.Stop(self.lastPath)

		self.lastRole = nil
		self.lastPath = nil
	end

	if not IsNil(self.GoPerfectComplete) then
		Object.Destroy(self.GoPerfectComplete)
	end
end

function PageWork:ClearOther()
	local function fun(list, goParent)
		if list ~= nil then
			for _, item in ipairs(list) do
				if item.OnLeave then
					item:OnLeave()
				end
			end
		end
	end

	fun(self.listMissedWorkAward, self.GoMissedContent)
	fun(self.listPickedWorkAward, self.GoPickedContent)
	fun(self.listGoCard, self.GoCardGroup)

	if self.listGoCond then
		for _, v in ipairs(self.listGoCond) do
			self:RemoveClick(go, self.OnClickCondition)
		end

		self.listGoCond = nil
	end
end

function PageWork:ClearTimer()
	UITweenUtil.RemoveTween(self.content)

	if self.timer1 ~= nil then
		TimerMgr.RemoveTimer(self.timer1)

		self.timer1 = nil
	end

	if self.timer2 ~= nil then
		TimerMgr.RemoveTimer(self.timer2)

		self.timer2 = nil
	end
end

function PageWork:OnRegisterEvent()
	for i = 1, 2 do
		self:AddClick(self["BtnTap" .. i], self.OnClickedBtnTap)
	end

	Event.Instance:Add("UpdateAfterBuyWork", self.UpdateWorkList, self)
	Event.Instance:Add("ResetWorks", self.ResetWorks, self)
	Event.Instance:Add("UpdateNetData", self.UpdateNetData, self)
	Event.Instance:Add("UpdateDotNotify", self.UpdateDot, self)
end

function PageWork:OnUnRegisterEvent()
	for i = 1, 2 do
		self:RemoveClick(self["BtnTap" .. i], self.OnClickedBtnTap)
	end

	Event.Instance:Remove("UpdateAfterBuyWork", self.UpdateWorkList, self)
	Event.Instance:Remove("ResetWorks", self.ResetWorks, self)
	Event.Instance:Remove("UpdateNetData", self.UpdateNetData, self)
	Event.Instance:Remove("UpdateDotNotify", self.UpdateDot, self)

	if self.BtnDouble ~= nil then
		self:RemoveClick(self.BtnDouble, self.OnClickedBtnDouble)
	end

	if self.BtnSend ~= nil then
		self:RemoveClick(self.BtnSend, self.OnClickedBtnQuickSend)
	end

	if self.BtnBegin ~= nil then
		self:RemoveClick(self.BtnBegin, self.OnClickedBtnBegin)
	end

	if self.BtnDirComplete ~= nil then
		self:RemoveClick(self.BtnDirComplete, self.OnClickedBtnDirComplete)
	end

	if self.BtnComplete ~= nil then
		self:RemoveClick(self.BtnComplete, self.OnClickedBtnComplete)
	end

	if not IsNil(self.GoPerfectComplete) then
		EventListenerMgr.RemoveAnimListener(self.GoPerfectComplete, self.ShowGetAward, self, eAnimEventType.OnAnimationEnd)
	end
end

function PageWork.RequestGetWorks(forcedRequest, cb)
	if forcedRequest or not WorkMgr.Requested then
		local function wrap_cb(pb)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if pb.result.code == NetManager.Result_Sucess then
				if cb then
					cb()
				end
			else
				UIMgr.ShowMsg(pb.result.desc, pb)
			end
		end

		NetManager:RequestGetWorks(wrap_cb)
		LoadingMgr.Show(eLoadingType.Repeat)
	end
end

function PageWork:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel1/Detail/Title/Text", "Text")
	txt.text = Lang(12318)
	txt = self:GetChildComponent("Panel1/Detail/BgCard/Condition/Text", "Text")
	txt.text = Lang(12320)
	txt = self:GetChildComponent("Panel1/BtnSend/Text", "Text")
	txt.text = Lang(12322)
	txt = self:GetChildComponent("Panel1/BtnBegin/Text", "Text")
	txt.text = Lang(12321)
	txt = self:GetChildComponent("Panel2/Detail/Title/Text", "Text")
	txt.text = Lang(12318)
	txt = self:GetChildComponent("Panel2/BtnCom/Go/Text", "Text")
	txt.text = Lang(12351)
	txt = self:GetChildComponent("Panel2/BtnOver/Text", "Text")
	txt.text = Lang(12350)
	txt = self:GetChildComponent("Panel3/Prompt/Text", "Text")
	txt.text = Lang(12330)

	for i = 1, 2 do
		txt = self:GetChildComponent("PanelList/BtnGroup/" .. i .. "/Button/Text", "Text")
		txt.text = TenaryOp(i == 1, Lang(12323), Lang(12324))
		txt = self:GetChildComponent("PanelList/BtnGroup/" .. i .. "/Select/Text", "Text")
		txt.text = TenaryOp(i == 1, Lang(12323), Lang(12324))
	end

	txt = self:GetChildComponent("Panel3/Prompt/TxtRefresh", "Text")
	txt.text = string.format(Lang(12340), tostring(InfoGameInst.RefreshTime))
end

function PageWork:ResetWorks()
	self:InitData()
end

function PageWork:OnEnter(vParam)
	if not GuideMgr:IsGuided(GuideFunctionType.Work) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.Work)
	end

	self:DealWithLocalization()

	self.AnimRoot = GOUtil.GetComponent(self.UIRootObject, "Animator")
	self.RTEffCamera = self:GetChildComponent("RTEffCamera", "Camera")
	self.RTEffTexture = UnityEngine.RenderTexture.GetTemporary(64, 64)
	self.RTEffCamera.targetTexture = self.RTEffTexture
	self.ImgDoll = self:GetChildComponent("Panel3/ImgDoll", "Image")

	for i = 1, 2 do
		self["BtnTap" .. i] = self:GetChildGameObject("PanelList/BtnGroup/" .. i .. "/Button")
		self["SelTap" .. i] = self:GetChildGameObject("PanelList/BtnGroup/" .. i .. "/Select")
		self["TxtTab" .. i] = self:GetChildComponent("PanelList/BtnGroup/" .. i .. "/Button/Text", "Text")
	end

	self.TxtNone = self:GetChildComponent("PanelList/GoNone", "Text")

	self:InitData()

	self.listLoadedBankRoleId = {}

	if vParam and vParam.loadBankRole then
		self:PlayRoleVoice(vParam.loadBankRole, eVocalType.SelectCard)
	end
end

function PageWork:InitPanel1UI()
	if self.initUI1 then
		return
	end

	self.initUI1 = true
	self.listMissedWorkAward = {}

	local workDetail = self:GetChildGameObject("Panel1/Detail")

	self.TxtDesc1 = GOUtil.FindChildComponent(workDetail, "TxtDesc", "Text")
	self.TxtProba1 = GOUtil.FindChildComponent(workDetail, "GoProba/TxtPro", "Text")
	self.ImgRank1 = GOUtil.FindChildComponent(workDetail, "Title/ImgRank", "Image")
	self.ImgType1 = GOUtil.FindChildComponent(workDetail, "Title/ImgType", "Image")
	self.ImgCardBg = GOUtil.FindChildComponent(workDetail, "BgCard", "Image")
	self.ImgCondBg = GOUtil.FindChildComponent(workDetail, "BgCard/Condition", "Image")
	self.ImgGroup1 = GOUtil.FindChildComponent(workDetail, "Bg", "Image")
	self.GoMissedContent = GOUtil.FindChildGameObject(workDetail, "Group/Content")
	self.GoCardGroup = GOUtil.FindChildGameObject(workDetail, "BgCard/Group")
	self.GoConGroup = GOUtil.FindChildGameObject(workDetail, "BgCard/Condition/Group")
	self.GoCellCon = GOUtil.FindChildGameObject(workDetail, "BgCard/Condition/CellCon")
	self.BtnDouble = GOUtil.FindChildGameObject(workDetail, "Prompt/BtnDouble")
	self.GoDoubleAct = GOUtil.FindChildGameObject(workDetail, "Prompt/ImgActive")
	self.TxtDouble = GOUtil.FindChildComponent(workDetail, "Prompt/Text", "Text")
	self.BtnSend = self:GetChildGameObject("Panel1/BtnSend")
	self.BtnBegin = self:GetChildGameObject("Panel1/BtnBegin")
	self.ImgBegin = self:GetChildComponent("Panel1/BtnBegin", "Image")

	self:AddClick(self.BtnDouble, self.OnClickedBtnDouble)
	self:AddClick(self.BtnSend, self.OnClickedBtnQuickSend)
	self:AddClick(self.BtnBegin, self.OnClickedBtnBegin)
end

function PageWork:InitPanel2UI()
	if self.initUI2 then
		return
	end

	self.initUI2 = true
	self.listPickedWorkAward = {}

	local workDetail = self:GetChildGameObject("Panel2/Detail")

	self.TxtDesc2 = GOUtil.FindChildComponent(workDetail, "TxtDesc", "Text")
	self.ImgWork = GOUtil.FindChildComponent(workDetail, "BgWork", "RawImage")
	self.Paper1 = GOUtil.FindChildGameObject(workDetail, "BgWork/Paper1")
	self.AnimPaper1 = GOUtil.FindChildComponent(workDetail, "BgWork/Paper1", "Animation")
	self.Paper2 = GOUtil.FindChildGameObject(workDetail, "BgWork/Paper2")
	self.AnimPaper2 = GOUtil.FindChildComponent(workDetail, "BgWork/Paper2", "Animation")
	self.TxtProba2 = GOUtil.FindChildComponent(workDetail, "GoProba/TxtPro", "Text")
	self.ImgRank2 = GOUtil.FindChildComponent(workDetail, "Title/ImgRank", "Image")
	self.ImgType2 = GOUtil.FindChildComponent(workDetail, "Title/ImgType", "Image")
	self.ImgGroup2 = GOUtil.FindChildComponent(workDetail, "Bg", "Image")
	self.GoPickedContent = GOUtil.FindChildGameObject(workDetail, "Group/Content")
	self.BtnComplete = self:GetChildGameObject("Panel2/BtnOver")
	self.BtnDirComplete = self:GetChildGameObject("Panel2/BtnCom")
	self.ImgBtnComplete = GOUtil.GetComponent(self.BtnComplete, "Image")
	self.GoCompDot = GOUtil.FindChildGameObject(self.BtnComplete, "Dot")
	self.ImgDirBtnComplete = GOUtil.GetComponent(self.BtnDirComplete, "Image")
	self.TxtComValue = GOUtil.FindChildComponent(self.BtnDirComplete, "Go/Item/Text", "Text")

	self:AddClick(self.BtnComplete, self.OnClickedBtnComplete)
	self:AddClick(self.BtnDirComplete, self.OnClickedBtnDirComplete)
end

function PageWork:PlayRoleVoice(role, vocalType)
	if not table.contains(self.listLoadedBankRoleId, role.id) then
		if #self.listLoadedBankRoleId > 10 then
			local lastRole = RoleMgr:GetRole(self.listLoadedBankRoleId[1])

			SoundMgr.UnloadBank(lastRole.data.VocalBank)
			table.remove(self.listLoadedBankRoleId, 1)
		end

		table.insert(self.listLoadedBankRoleId, role.id)
	end

	if self.lastRole and self.lastPath then
		SoundMgr.Stop(self.lastPath)

		self.lastRole = nil
		self.lastPath = nil
	end

	SoundMgr.LoadBank(role.data.VocalBank, false, false)

	local path

	if vocalType == eVocalType.SendWork then
		local result = math.random(3)

		path = role.data.VocalDispatch

		if result == 2 then
			path = role.data.VocalDispatch2
		elseif result == 3 then
			path = role.data.VocalDispatch3
		end
	elseif vocalType == eVocalType.SelectCard then
		path = role.data.VocalTeam
	elseif vocalType == eVocalType.ExtraNone then
		path = role.data.VocalCustomsclearance3
	end

	if path ~= nil and path ~= "" then
		SoundMgr.PostEvent(path, self.UIRootObject)

		self.lastPath = path
	end

	self.lastRole = role
end

function PageWork:InitData()
	self.tapIdx = 1

	if WorkMgr.WorkIdx == 0 then
		self.tapIdx = WorkRDL.HasComplete() and 2 or 1
	end

	self.listWork = {}
	self.workIdx = WorkMgr.WorkIdx or 0

	self:UpdatePanel()
	self:UpdateDot()
end

function PageWork:CheckPickedTab()
	if next(WorkMgr:GetWorkListByState(eWorkStateType.Picked)) == nil then
		UIUtil.SetGraphicColorRGB(self["TxtTab" .. 2], 0.7568627450980392, 0.8313725490196079, 0.8431372549019608)
	else
		UIUtil.SetGraphicColorRGB(self["TxtTab" .. 2], 1, 1, 1)
	end
end

function PageWork:UpdatePanel()
	for i = 1, 2 do
		self["BtnTap" .. i]:SetActive(self.tapIdx ~= i)
		self["SelTap" .. i]:SetActive(self.tapIdx == i)
	end

	self:CheckPickedTab()
	self:UpdateWorkList()

	if WorkMgr.WorkIdx == 0 then
		self:ClearTimer()

		self.timer1 = TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
			self.timer1 = nil

			GOUtil.SetActive(self.content, false)
		end, nil)
		self.timer2 = TimerMgr.AddTimer(eTimerType.FrameCount, 2, function()
			self.timer2 = nil

			GOUtil.SetActive(self.content, true)
			UITweenUtil.DoNoUpdateAnimationUp(self.content, 300, 0.3)
		end, nil)
	end
end

function PageWork:UpdateWorkList(var)
	table.clear(self.listWork)

	local list = {}

	if self.tapIdx == 1 then
		list = WorkMgr:GetWorkListByState(eWorkStateType.Normal)

		local function fun(a, b)
			local function exchangeType(oType)
				if oType == 1 then
					return 2
				elseif oType == 2 then
					return 1
				end

				return oType
			end

			if exchangeType(a.data.Type) == exchangeType(b.data.Type) then
				return a.pb.id < b.pb.id
			else
				return exchangeType(a.data.Type) < exchangeType(b.data.Type)
			end
		end

		table.sort(list, fun)
	else
		list = WorkMgr:GetWorkListByState(eWorkStateType.Picked)

		local function fun(a, b)
			local aState = a:IsComplete() and 1 or 0
			local bState = b:IsComplete() and 1 or 0

			if aState == bState then
				return a.pb.id < b.pb.id
			else
				return bState < aState
			end
		end

		table.sort(list, fun)
	end

	for _, v in ipairs(list) do
		table.insert(self.listWork, {
			info = v
		})
	end

	local cnt = #self.listWork

	if WorkMgr:CanBuyWork() and self.tapIdx == 1 then
		table.insert(self.listWork, {})
	end

	self.workIdx = TenaryOp(cnt < self.workIdx, cnt, TenaryOp(self.workIdx < 1, 1, self.workIdx))

	self:UpdatePanelShow()
	self:UpdateWorkListPanel(var and var.keepPos)
	self:UpdateWorkInfo()
end

function PageWork:UpdatePanelShow()
	local haveWork = next(self.listWork) ~= nil and self.listWork[1].info ~= nil

	if not haveWork then
		self.AnimRoot:Play("Anim_Panel3")
	elseif self.tapIdx == 1 then
		self.AnimRoot:Play("Anim_Panel1")
	else
		self.AnimRoot:Play("Anim_Panel2")
	end

	local showNone = not haveWork

	if self.tapIdx == 1 then
		showNone = next(self.listWork) == nil
	end

	GOUtil.SetActive(self.TxtNone.gameObject, showNone)

	if showNone then
		self.TxtNone.text = self.tapIdx == 1 and _("Msg_Work_Complete_Today") or _("Msg_Work_None_Being")
	end
end

function PageWork:UpdateWorkListPanel(keepPos)
	if self.UIScrollTool then
		if keepPos then
			self.UIScrollTool:UpdateListDataKeepPos(self.listWork)
		else
			self.UIScrollTool:SetContentPosImmediate(Vector2(0, 0), self.listWork)
		end

		return
	end

	local scrollArea = self:GetChildGameObject("PanelList/BgScroll/ScrollArea")

	self.content = self:GetChildComponent("PanelList/BgScroll/ScrollArea/Content", "RectTransform")

	local count = #self.listWork

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCellWork)
	end

	local function updateCallback(item, index)
		local data = self.listWork[index]

		item:UpdateData(data, self.workIdx)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, self.content, count, self.PrefabCellWork, CellWork, self, false, addCallback, updateCallback)

	local pos = GetContentPos(self.UIScrollTool.ScrollView, count, self.workIdx, true)

	self.UIScrollTool:SetInitPos(Vector3(0, pos, 0))
end

function PageWork:UpdateWorkInfo()
	local workData = self.listWork[self.workIdx]

	if workData == nil or workData.info == nil then
		return
	end

	self.infoWork = workData.info

	if self.tapIdx == 1 then
		self:InitPanel1UI()
		self:UpdatePanel1()
	else
		self:InitPanel2UI()
		self:UpdatePanel2()
	end
end

local function FunUpdate1(cell, infoWork, idx)
	cell:UpdateData(infoWork, idx)
end

local function FunCreate1(infoWork, idx, page)
	local cell = CellWorkCard(page.PrefabCellWorkCard, page.GoCardGroup, page)

	cell:Create()
	FunUpdate1(cell, infoWork, idx)
	table.insert(page.listGoCard, cell)
end

local function FunUpdate2(go, info, page)
	local icon = GOUtil.FindChildComponent(go, "Icon", "Image")

	SetImageSprite(icon, info.info.Icon, page)

	local flag, num = WorkMgr:GetConditionIsMet(info.info, page.infoWork.tempData.cardIds)
	local text = GOUtil.FindChildComponent(go, "Image/Text", "Text")

	if flag then
		text.text = info.need .. "/" .. info.need

		UIUtil.SetGraphicColorRGB(text, 0, 0, 0)
	else
		text.text = num .. "/" .. info.need

		UIUtil.SetGraphicColorRGB(text, 1, 0, 0)
	end

	local rawImgEff = GOUtil.FindChildComponent(go, "Eff", "RawImage")

	if flag then
		rawImgEff.texture = page.RTEffTexture
	end

	UIUtil.SetGraphicEnabled(rawImgEff, flag)
end

local function FunCreate2(idx, info, page)
	page.GoCellCon:SetActive(true)

	local cell = GOUtil.Instantiate(page.GoCellCon, page.GoConGroup)

	cell.name = idx

	FunUpdate2(cell, info, page)
	page:AddClick(cell, page.OnClickCondition)
	table.insert(page.listGoCond, cell)
	page.GoCellCon:SetActive(false)
end

local function updateColor(graphic, str_color)
	local color = sixNumToRGB(str_color)

	UIUtil.SetGraphicColorRGB(graphic, color.r / 255, color.g / 255, color.b / 255)
end

function PageWork:UpdatePanel1(onlyUpdateCard)
	self.listGoCond = self.listGoCond or {}
	self.listGoCard = self.listGoCard or {}

	local listCardId = self.infoWork.tempData.cardIds
	local listSpe = self.infoWork.listSpecial

	local function fun(type)
		local oldCnt, newCnt = 0, 0

		if type == 1 then
			oldCnt = #self.listGoCard
			newCnt = self.infoWork.data.PlayerNumber
		else
			oldCnt = #self.listGoCond
			newCnt = #listSpe
		end

		if oldCnt < newCnt then
			for i = 1, newCnt do
				if i <= oldCnt then
					if type == 1 then
						FunUpdate1(self.listGoCard[i], self.infoWork, i)
					else
						FunUpdate2(self.listGoCond[i], listSpe[i], self)
					end
				elseif type == 1 then
					FunCreate1(self.infoWork, i, self)
				else
					FunCreate2(i, listSpe[i], self)
				end
			end
		else
			for i = 1, oldCnt do
				if type == 1 then
					GOUtil.SetActive(self.listGoCard[i].UIRootObject, i <= newCnt)

					if i <= newCnt then
						FunUpdate1(self.listGoCard[i], self.infoWork, i)
					end
				else
					GOUtil.SetActive(self.listGoCond[i], i <= newCnt)

					if i <= newCnt then
						FunUpdate2(self.listGoCond[i], listSpe[i], self)
					end
				end
			end
		end
	end

	fun(1)
	fun(2)

	local proba = WorkMgr:GetSumRate(self.infoWork, listCardId)

	self.TxtProba1.text = string.format(_("Desc_Proba_Get_Award"), "<color=#B28750><size=76>" .. proba .. "%</size></color>\n<color=#5F5F5F><size=35>") .. "</size></color>"

	if not onlyUpdateCard then
		self.TxtDesc1.text = self.infoWork:GetDesc()
		self.TxtDouble.text = string.format(_("Desc_Double_Buy"), self.infoWork.data.DoubleRewordCost[2])

		self:UpdateAward(1)
		UIUtil.SetImageSprite(self.ImgRank1, "UI/PanelWork/AtlasPanelWork/BG_missionline_a0" .. self.infoWork.data.Type, self)
		UIUtil.SetImageSprite(self.ImgType1, "UI/PanelWork/AtlasPanelWork/IC_MIS_0" .. self.infoWork.data.Type .. "_1", self)
		updateColor(self.ImgCardBg, eWorkTypeColor[self.infoWork.data.Type].Color1)
		updateColor(self.ImgCondBg, eWorkTypeColor[self.infoWork.data.Type].Color2)
		updateColor(self.ImgGroup1, eWorkTypeColor[self.infoWork.data.Type].Color1)
	end

	local list = {}

	for _, cardId in pairs(listCardId) do
		if cardId ~= 0 then
			table.insert(list, cardId)
		end
	end

	if self.ImgBegin ~= nil then
		local gray = TenaryOp(#list == 0, 1, 0)

		DealWithListRef(self, UIUtil.SetImageGray(self.ImgBegin, gray))
	end
end

function PageWork:UpdatePanel2()
	self.TxtDesc2.text = self.infoWork:GetDesc()

	UIUtil.SetRawImageTexture(self.ImgWork, "Texture/Work/" .. self.infoWork.data.BGIcon, self)

	local rate = self.infoWork.pb.successRatio or 0

	rate = TenaryOp(rate > 100, 100, TenaryOp(rate < 0, 0, rate))
	self.TxtProba2.text = string.format(_("Desc_Proba_Get_Award"), "<color=#B28750><size=76>" .. rate .. "%</size></color>\n<color=#5F5F5F><size=35>") .. "</size></color>"

	local listAbi = self.infoWork.listCardAbility or {}
	local listCardId = self.infoWork.pb.roleCardIds or {}

	for i = 1, 3 do
		local imgRolePaper = self:GetChildComponent("Panel2/Detail/BgWork/Paper1/Move_0" .. i .. "/" .. i, "Image")

		GOUtil.SetActive(imgRolePaper.gameObject, i <= #listCardId)

		local imgWinPaper = self:GetChildComponent("Panel2/Detail/BgWork/Paper2/" .. i, "Image")

		GOUtil.SetActive(imgWinPaper.gameObject, i <= #listCardId)

		if i <= #listCardId then
			local infoRole = RoleCardMgr:GetRole(listCardId[i])

			UIUtil.SetImageOverrideSprite(imgRolePaper, infoRole.actorData.PaperIcon, self)
			UIUtil.SetImageOverrideSprite(imgWinPaper, infoRole.actorData.PaperIcon, self)
		end

		local imgWorkPaper = self:GetChildComponent("Panel2/Detail/BgWork/Paper1/Move_0" .. i + 3 .. "/" .. i + 3, "Image")

		GOUtil.SetActive(imgWorkPaper.gameObject, i <= #listAbi)

		if i <= #listAbi then
			UIUtil.SetImageOverrideSprite(imgWorkPaper, listAbi[i].info.Npc, self)
		end
	end

	UIUtil.SetImageSprite(self.ImgRank2, "UI/PanelWork/AtlasPanelWork/BG_missionline_a0" .. self.infoWork.data.Type, self)
	UIUtil.SetImageSprite(self.ImgType2, "UI/PanelWork/AtlasPanelWork/IC_MIS_0" .. self.infoWork.data.Type .. "_1", self)
	updateColor(self.ImgGroup2, eWorkTypeColor[self.infoWork.data.Type].Color1)
	self:UpdateDot()
	self:UpdateAward(2)
end

function PageWork:UpdateAward(_type, onlyUpdateDouble)
	local function funUpdate(item, data, type, onlyNum)
		if not data or next(data) == nil then
			return
		end

		local id, num = data[1], data[2]
		local isDouble = type == 1 and self.infoWork.tempData.double or self.infoWork.pb.awardMultiple

		num = isDouble and num * 2 or num

		local info = ItemManager:GetValueItem(id, num)

		if onlyNum then
			item:UpdateNumOnly(num)
		else
			item:UpdateWithNumType(info)
		end

		item:SetExtra(not isDouble)
		item:SetDouble(isDouble)
	end

	local function funCreate(list, parent, data, type)
		local item = CellItem(self.PrefabCellItem, parent)

		item:Create()

		local localScale = TenaryOp(_type == 1, 0.8, 0.9)

		GOUtil.SetTransformLocalScale(item.UIRootObject, localScale)
		funUpdate(item, data, type)
		table.insert(list, item)
	end

	local listAward = self.infoWork.extraReward

	local function fun(listCell, parent, type)
		local oldCnt = #listCell
		local newCnt = #listAward

		if oldCnt < newCnt then
			for i = 1, oldCnt do
				funUpdate(listCell[i], listAward[i], type)
			end

			for i = oldCnt + 1, newCnt do
				funCreate(listCell, parent, listAward[i], type)
			end
		else
			for i = 1, oldCnt do
				GOUtil.SetActive(listCell[i].UIRootObject, i <= newCnt)

				if i <= newCnt then
					funUpdate(listCell[i], listAward[i], type)
				end
			end
		end
	end

	if _type == 1 then
		GOUtil.SetActive(self.GoDoubleAct, self.infoWork.tempData.double)

		if onlyUpdateDouble then
			if self.listMissedWorkAward then
				for k, item in ipairs(self.listMissedWorkAward) do
					funUpdate(item, listAward[k], 1, true)
				end
			end

			return
		end

		fun(self.listMissedWorkAward, self.GoMissedContent, 1)
	elseif _type == 2 then
		fun(self.listPickedWorkAward, self.GoPickedContent, 2)
	end
end

function PageWork:OnClickedBtnTap(data)
	local index = tonumber(data.pointerPress.transform.parent.gameObject.name)

	if index == self.tapIdx then
		return
	end

	if index == 2 and next(WorkMgr:GetWorkListByState(eWorkStateType.Picked)) == nil then
		UIMgr.ShowMsg(Lang(12528))

		return
	end

	self.tapIdx = index
	WorkMgr.WorkIdx = 0

	if self.infoWork then
		self.infoWork:ResetTempData()
	end

	self.workIdx = 1

	self:UpdatePanel()
end

function PageWork:OnClickedCellWork(data)
	local go = data.pointerPress.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index

	if self.tapIdx == 1 and self.listWork[index].info == nil then
		local x, y = GOUtil.GetTransformPosition(info.Item.UIRootObject, x, y, z)
		local pos = Vector2.New(x, y)

		require("UI/Page/PageWork/DlgPaidWorkBuy")
		UIMgr.AddPanel(DlgPaidWorkBuy(), {
			pos = pos
		})

		return
	end

	if self.workIdx == index then
		return
	end

	local function fun()
		local preIdx = self.workIdx

		self.workIdx = index

		self.infoWork:ResetTempData()
		self.UIScrollTool:UpdateCellSelect(preIdx, index)
		self:UpdateWorkInfo()
	end

	if self.infoWork:IsTempChange() then
		local function cb(type)
			if type == DlgCommonEvent.ButtonType.Ok then
				fun()
			end
		end

		UIMgr.ShowCommon(DlgCommonEvent.Type.Confirm, _("Desc_Alert"), _("Desc_ConfirmDispatch"), cb, _("UI_Yes"), _("UI_No"), false)
	else
		fun()
	end
end

function PageWork:OnClickedBtnQuickSend()
	local list = WorkMgr:SortCard(self.infoWork)

	if #list == 0 then
		UIMgr.ShowMsg(_("Msg_Work_Card_None_Temp"))

		return
	end

	local listCard = {}

	for i = 1, #list do
		local cardId = list[i].cardId
		local roleId = RoleCardMgr:GetRoleId(cardId)

		if #listCard < self.infoWork.data.PlayerNumber and WorkMgr:GetSumRate(self.infoWork, listCard) < 100 then
			local isFull = true

			for _, j in pairs(list[i].info) do
				if not WorkMgr:GetConditionIsMet(j, listCard) then
					isFull = false

					break
				end
			end

			if not isFull then
				if #listCard == 0 then
					table.insert(listCard, cardId)
				else
					local isHave = false

					for _, v in pairs(listCard) do
						local selRoleId = RoleCardMgr:GetRoleId(v)

						if selRoleId == roleId then
							isHave = true

							break
						end
					end

					if not isHave then
						table.insert(listCard, cardId)
					end
				end
			end
		end
	end

	local function fun(listCardId)
		local list = WorkMgr:GetListCanWorkCard()

		for _, v in ipairs(listCardId) do
			if v ~= 0 then
				local roleId = RoleCardMgr:GetRoleId(v)

				for i = #list, 1, -1 do
					if v == list[i].id or roleId == list[i].data.CharacterID then
						table.remove(list, i)
					end
				end
			end
		end

		return list
	end

	for i = 1, self.infoWork.data.PlayerNumber do
		if not listCard[i] then
			local cardId = 0
			local list = fun(listCard)

			if list[1] then
				cardId = list[1].id
			end

			table.insert(listCard, i, cardId)
		end
	end

	self.infoWork:SetTempData(listCard)
	self:UpdatePanel1(true)
end

function PageWork:OnClickedBtnDouble()
	if not self.infoWork.tempData.double then
		self.infoWork:SetTempData(nil, true)
		self:UpdateAward(1, true)
	else
		self.infoWork:SetTempData(nil, false)
		self:UpdateAward(1, true)
	end
end

function PageWork:OnClickCondition(data)
	local go = data.pointerPressRaycast.gameObject
	local info = self.infoWork.listSpecial[tonumber(go.name)].info

	if info then
		local tipData = SkillTip.GetWorkCondData(data.position, info)

		UIMgr.ShowSkillTip(tipData)
	end
end

function PageWork:OnClickedBtnBegin()
	local list = {}
	local cardIds = self.infoWork.tempData.cardIds

	for _, cardId in pairs(cardIds) do
		if cardId ~= 0 then
			table.insert(list, cardId)
		end
	end

	if #list == 0 then
		UIMgr.ShowMsg(_("Msg_Work_One_AtLeast"))

		return
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self:UpdateWorkList({
				keepPos = true
			})
			self:CheckPickedTab()

			if next(list) ~= nil then
				self:PlayRoleVoice(RoleCardMgr:GetRole(list[math.random(#list)]), eVocalType.SendWork)
			end

			UIMgr.ShowMsg(_("Msg_WorkSuccee"))
			NotificationMgr.Instance:ChangeSetting(eNotificationType.CompleteWork)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	local function sendRequest()
		NetManager:RequestPickWork(tonumber(self.infoWork.pb.id), list, self.infoWork.tempData.double, wrap_cb)
		LoadingMgr.Show(eLoadingType.Repeat)
	end

	if self.infoWork.tempData.double then
		local price = self.infoWork.data.DoubleRewordCost[2]

		local function cb(type)
			if type == DlgCommonEvent.ButtonType.Ok then
				sendRequest()
			end
		end

		local function GetMsg(formatMsg)
			local msg

			if WorkMgr:GetSumRate(self.infoWork, self.infoWork.tempData.cardIds) < 100 then
				msg = string.format(_("Desc_WorkDouble"), formatMsg) .. "\n(" .. _("Desc_FinishTaskNoExReward") .. ")"
			else
				msg = string.format(_("Desc_WorkDouble"), formatMsg)
			end

			return msg
		end

		local function fun()
			UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Tittle_Affirm"), {
				isDiamond = true,
				text = GetMsg(self.infoWork.data.DoubleRewordCost[2])
			}, cb, _("Button_OK"), _("Button_Cancel"), false)
		end

		local function default()
			local id = self.infoWork.data.DoubleRewordCost[1]

			ItemManager:IsItemHoldEnough(id, price)
		end

		if price > PlayerInst:GetDiamondAll() then
			CheckPayDiamond(price, GetMsg(price), fun, default)
		else
			fun()
		end
	else
		sendRequest()
	end
end

function PageWork:OnClickedBtnComplete()
	self.isDirComplete = false

	local function wrap_cb(vMsg)
		self:ResponseCompleteWork(vMsg, self.infoWork.pb.roleCardIds)
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestCompleteWork(self.infoWork.pb.id, false, wrap_cb)
end

function PageWork:OnClickedBtnDirComplete()
	local function cb(index)
		if index == 1 then
			self.isDirComplete = true

			local function wrap_cb(vMsg)
				NotificationMgr.Instance:ChangeSetting(eNotificationType.CompleteWork)
				self:ResponseCompleteWork(vMsg, self.infoWork.pb.roleCardIds)
			end

			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:RequestCompleteWork(self.infoWork.pb.id, true, wrap_cb)
		end
	end

	local function showTip()
		local txtTitle = _("Tittle_Affirm")
		local msg = string.format(_("Msg_Work_Cost_DirComplete"), self.dirCompCost)
		local txtYes = _("Button_OK")
		local txtNo = _("Button_Cancel")

		UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, txtTitle, {
			isDiamond = true,
			text = msg
		}, cb, txtYes, txtNo, false)
	end

	local function default()
		local item = ItemManager:GetItemByType("P_DIAMOND")

		ItemManager:IsItemHoldEnough(item.id, self.dirCompCost)
	end

	if PlayerInst:GetDiamondAll() < self.dirCompCost then
		CheckPayDiamond(self.dirCompCost, string.format(_("Msg_Work_Cost_DirComplete"), self.dirCompCost), showTip, default)
	else
		showTip()
	end
end

function PageWork:ResponseCompleteWork(vMsg, listCardId, panelCb)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if vMsg.result.code == NetManager.Result_Sucess then
		self.setter = vMsg.setter

		if SetterData.HaveAwards(vMsg.setter, protocol_pb.AF_EXTRA_AWARD) then
			listCardId = listCardId or {}

			if #listCardId > 0 then
				local role = RoleCardMgr:GetRole(listCardId[math.random(#listCardId)])

				self:PlayRoleVoice(role, eVocalType.ExtraNone)
			end

			if IsNil(self.GoPerfectComplete) then
				self.GoPerfectComplete = GOUtil.InstantiateUIPrefab(self.PrefabPerfectComplete, UIMgr.UIPopupObject)
				self.AnimPerfectComplete = GOUtil.GetComponent(self.GoPerfectComplete, "Animator")

				EventListenerMgr.AddAnimListener(self.GoPerfectComplete, self.ShowGetAward, self, eAnimEventType.OnAnimationEnd)
			else
				self.AnimPerfectComplete:Play("Anim_PerfectComplete", 0, 0)
			end
		else
			self:ShowGetAward()
		end
	elseif vMsg.result.code == NetManager.Result_Timeout then
		local strContent = _("Desc_NoNetwork")

		UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), strContent, function()
			Restart()
		end, _("UI_OK"), nil, false)
	else
		UIMgr.ShowMsg(vMsg.result.desc, vMsg)

		if panelCb then
			panelCb()
		end
	end
end

function PageWork:ShowGetAward()
	local function SetAnimatorEnable(vbool)
		if self.isDirComplete then
			self.AnimPaper1.enabled = vbool
		else
			self.AnimPaper2.enabled = vbool
		end
	end

	local function cb()
		SetAnimatorEnable(true)
		self:UpdateWorkList()
		self:CheckPickedTab()
	end

	SetAnimatorEnable(false)
	UIMgr.AddPanel(DlgGetWorkAward(), {
		self.infoWork,
		self.setter,
		cb
	})
end

function PageWork:OnUpdate()
	if not self.listWork then
		return
	end

	if self.tapIdx ~= 2 or #self.listWork == 0 or not self.UIScrollTool then
		return
	end

	local serverTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	for i = 1, self.UIScrollTool.ScrollView.CachedEntryObjects.Count do
		local go = self.UIScrollTool.ScrollView.CachedEntryObjects:get_Item(i - 1)
		local item = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go).Item
		local leftSec = 0

		if self.listWork[item.Index] then
			local endTime = tonumber(self.listWork[item.Index].info.pb.endTime)

			leftSec = Mathf.Floor(Mathf.Max(0, endTime - serverTime))

			item:UpdateTime(leftSec)
		end

		if item.Index == self.workIdx then
			self.dirCompCost = Mathf.Ceil(leftSec / GetConfigArgInt("WorkQuicklyTime"))
			self.TxtComValue.text = self.dirCompCost

			GOUtil.SetActive(self.BtnComplete, leftSec <= 0)
			GOUtil.SetActive(self.BtnDirComplete, leftSec > 0)
			GOUtil.SetActive(self.Paper1, leftSec > 0)
			GOUtil.SetActive(self.Paper2, leftSec <= 0)
		end
	end
end

function PageWork:UpdateDot()
	if self.tapIdx == 2 then
		GOUtil.SetActive(self.GoCompDot, self.infoWork:IsComplete())
	end
end

function PageWork:OnClickedGuideBtn()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.Work)
end

function PageWork:UpdateNetData()
	local function cb()
		self:UpdatePanel()
		Event.Instance:Fire("UpdateBoughtWork")
	end

	PageWork.RequestGetWorks(true, cb)
end

function PageWork:OnBackAndroid()
	if self.GoPerfectComplete and GOUtil.IsActiveSelf(self.GoPerfectComplete) then
		return true
	end

	return false
end
