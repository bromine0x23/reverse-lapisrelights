-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionFunction/PageUnionSkill.lua

local skillTip = require("UI/Dlg/Common/SkillTipDesc")

require("UI/Page/PageUnionFunction/CellUnionSkill")

PageUnionSkill = class("PageUnionSkill", UIPanel)

function PageUnionSkill:ctor()
	self.UIPrefabPath = "UI/PanelUnionFunction/PanelUnionSkill"

	self:AddChildPanel(DlgExit(), {
		title = _("Item_From_19_2"),
		callback = self.OnBack,
		helpCallback = self.OnClickedBtnGuide,
		panel = self
	})

	self.DlgAssetsInfo = DlgAssetsInfo()

	self:AddChildPanel(self.DlgAssetsInfo)
end

function PageUnionSkill:PreLoad()
	self:LoadResAsync("UI/PanelUnionFunction/CellUnionSkill", "PrefabCellUnionSkill", GameObject)
end

function PageUnionSkill:OnBack()
	local prePanel = UIMgr.GetPrePanel()

	if prePanel.className == "PageUnion" then
		UIMgr.PopPanel({
			isShowBank = true,
			needRequestUnion = true
		})
	else
		UIMgr.PopPanel()
	end
end

function PageUnionSkill:Purge()
	self.base.Purge(self)
	self:OnLeave()
end

function PageUnionSkill:OnLeave()
	ResourceMgr.Unload(self.PrefabCellUnionSkill)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.CellItem and self.CellItem.OnLeave ~= nil then
		self.CellItem:OnLeave()
	end

	InfoSoundEventMgr:OnBack()
end

function PageUnionSkill:OnRegisterEvent()
	self:AddClick(self.BtnUp, self.OnClickedBtnUp)
	self:AddClick(self.BtnPut, self.OnClickedBtnPut)
	self:AddListener(self.BtnLess, self.OnPointBtnLessDown, EventTriggerType.PointerDown)
	self:AddListener(self.BtnLess, self.OnPointBtnLessUp, EventTriggerType.PointerUp)
	self:AddListener(self.BtnLess, self.OnPointBtnLessRepeat, EventTriggerType.PointerRepeat)
	self:AddListener(self.BtnPlus, self.OnPointBtnPlusDown, EventTriggerType.PointerDown)
	self:AddListener(self.BtnPlus, self.OnPointBtnPlusUp, EventTriggerType.PointerUp)
	self:AddListener(self.BtnPlus, self.OnPointBtnPlusRepeat, EventTriggerType.PointerRepeat)
	Event.Instance:Add("UpdateUsableSpot", self.UpdateUsableSpot, self)
	Event.Instance:Add("UpdateNetData", self.UpdateNetData, self)
end

function PageUnionSkill:OnUnRegisterEvent()
	self:RemoveClick(self.BtnUp, self.OnClickedBtnUp)
	self:RemoveClick(self.BtnPut, self.OnClickedBtnPut)
	self:RemoveListener(self.BtnLess, self.OnPointBtnLessDown, EventTriggerType.PointerDown)
	self:RemoveListener(self.BtnLess, self.OnPointBtnLessUp, EventTriggerType.PointerUp)
	self:RemoveListener(self.BtnLess, self.OnPointBtnLessRepeat, EventTriggerType.PointerRepeat)
	self:RemoveListener(self.BtnPlus, self.OnPointBtnPlusDown, EventTriggerType.PointerDown)
	self:RemoveListener(self.BtnPlus, self.OnPointBtnPlusUp, EventTriggerType.PointerUp)
	self:RemoveListener(self.BtnPlus, self.OnPointBtnPlusRepeat, EventTriggerType.PointerRepeat)
	Event.Instance:Remove("UpdateUsableSpot", self.UpdateUsableSpot, self)
	Event.Instance:Remove("UpdateNetData", self.UpdateNetData, self)
end

function PageUnionSkill:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/Panel1/Popular/Text", "Text")
	txt.text = Lang(42125)
	txt = self:GetChildComponent("Panel/Panel1/Text", "Text")
	txt.text = _("Desc_CanUp_Point_Skill")
	txt = self:GetChildComponent("Panel/Panel2/Title/Text", "Text")
	txt.text = Lang(42124)
	txt = self:GetChildComponent("Panel/Panel2/CurrDesc/Image/Text", "Text")
	txt.text = Lang(42131)
	txt = self:GetChildComponent("Panel/Panel2/NextDesc/Image/Text", "Text")
	txt.text = Lang(42132)
	txt = self:GetChildComponent("Panel/Panel2/PutCost/BtnPut/Text", "Text")
	txt.text = Lang(42127)
	txt = self:GetChildComponent("Panel/Panel2/UpCost/Button/Text", "Text")
	txt.text = Lang(12061)
end

function PageUnionSkill:OnEnter()
	if not GuideMgr:IsGuided(GuideFunctionType.UnionSkill) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.UnionSkill)
	end

	self:DealWithLocalization()

	self.TxtPopValue = self:GetChildComponent("Panel/Panel1/Popular/Num/TxtValue", "Text")
	self.ImgSkillIcon = self:GetChildComponent("Panel/Panel2/ExpRate/Icon", "Image")
	self.ImgSkillExp = self:GetChildComponent("Panel/Panel2/ExpRate/Rate/Image", "Image")
	self.TxtSkillExp = self:GetChildComponent("Panel/Panel2/ExpRate/TxtExp", "Text")
	self.TxtSkillName = self:GetChildComponent("Panel/Panel2/ExpRate/TxtName", "Text")
	self.TxtSkillLevel = self:GetChildComponent("Panel/Panel2/ExpRate/TxtLevel", "Text")
	self.TxtCurrDesc = self:GetChildComponent("Panel/Panel2/CurrDesc/TxtRect/Text", "Text")
	self.TxtNextDesc = self:GetChildComponent("Panel/Panel2/NextDesc/TxtRect/Text", "Text")
	self.GoUp = self:GetChildGameObject("Panel/Panel2/UpCost")
	self.ImgAssetIcon = GOUtil.FindChildComponent(self.GoUp, "BgCost/Icon", "Image")
	self.TxtAssetCost = GOUtil.FindChildComponent(self.GoUp, "BgCost/Text", "Text")
	self.BtnUp = GOUtil.FindChildGameObject(self.GoUp, "Button")
	self.GoPut = self:GetChildGameObject("Panel/Panel2/PutCost")
	self.TxtPutNum = GOUtil.FindChildComponent(self.GoPut, "BgPutNum/Text", "Text")
	self.BtnLess = GOUtil.FindChildGameObject(self.GoPut, "BtnLess")
	self.BtnPlus = GOUtil.FindChildGameObject(self.GoPut, "BtnPlus")
	self.BtnPut = GOUtil.FindChildGameObject(self.GoPut, "BtnPut")
	self.ImgBtnPut = GOUtil.GetComponent(self.BtnPut, "Image")

	local gItem = GOUtil.FindChildGameObject(self.GoPut, "Cell")

	self.CellItem = CellItem(gItem)

	self.CellItem:InitItemByRoot(gItem)
	self:InitData()
end

function PageUnionSkill.RequestData(cb, notNeedLeave)
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			if cb then
				cb()
			end
		elseif vMsg.result.code == 2 then
			if not notNeedLeave then
				PageUnion.GoBackMainPage(vMsg)
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestUnionSkill(wrap_cb)
end

function PageUnionSkill:InitData()
	self.listUnionSkill = UnionSkillMgr.listUnionSkill or {}
	self.curSkillIdx = 1

	self:UpdatePanel()
	self:UpdateScrollView()
	self:UpdateUsableSpot()
end

function PageUnionSkill:UpdateScrollView()
	if self.UIScrollTool then
		self.UIScrollTool:UpdateListDataKeepPos(self.listUnionSkill)

		return
	end

	local scrollArea = self:GetChildGameObject("Panel/Panel1/ScrollArea")
	local content = self:GetChildComponent("Panel/Panel1/ScrollArea/Content", "RectTransform")
	local count = #self.listUnionSkill

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCell)
	end

	local function updateCallback(item, index)
		local infoUnionSkill = self.listUnionSkill[index]

		item:UpdateData(infoUnionSkill, self.curSkillIdx)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellUnionSkill, CellUnionSkill, self, false, addCallback, updateCallback)

	self.UIScrollTool.ScrollView.vertical = false
end

function PageUnionSkill:OnClickedCell(data)
	local go = data.pointerPress.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index

	if self.curSkillIdx == index then
		return
	end

	local preIdx = self.curSkillIdx

	self.curSkillIdx = index

	self.UIScrollTool:UpdateCellSelect(preIdx, index)
	self:UpdatePanel()
end

function PageUnionSkill:UpdateUsableSpot()
	local curSpots = UnionSkillMgr:GetMineSpots()
	local maxSpots = GetConfigArgInt("ClubSkillHotNum")

	if maxSpots - curSpots == 0 then
		self.TxtPopValue.text = "<color=red>" .. maxSpots - curSpots .. "</color>/" .. maxSpots
	else
		self.TxtPopValue.text = "<color=#29C4C4>" .. maxSpots - curSpots .. "</color>/" .. maxSpots
	end
end

function PageUnionSkill:UpdatePanel()
	self.infoUnionSkill = self.listUnionSkill[self.curSkillIdx]

	if not self.infoUnionSkill then
		return
	end

	local info = self.infoUnionSkill
	local isMaxLv = info:IsMaxLevel()

	self.curPutNum = 0
	self.TxtSkillName.text = Lang(info.data.Name)
	self.TxtSkillLevel.text = _("Player_Level") .. info.curLevel

	SetImageSprite(self.ImgSkillIcon, info:GetIconPath(), self)

	self.TxtCurrDesc.text = skillTip.GetDesc(info.id, info.curLevel, 0)

	if isMaxLv then
		self.TxtNextDesc.text = _("Desc_Role_Reach_MaxLv")
	else
		self.TxtNextDesc.text = skillTip.GetDesc(info.id, info.curLevel + 1, 0)
	end

	if isMaxLv then
		self.ImgSkillExp.fillAmount = 1

		local maxNeedExp = UnionSkillMgr:GetClubSkillNeedExp(info.id, info.maxLevel - 1)

		self.TxtSkillExp.text = maxNeedExp .. "/" .. maxNeedExp
	else
		self.ImgSkillExp.fillAmount = info.curExp / info.nextExp
		self.TxtSkillExp.text = info.curExp .. "/" .. info.nextExp
	end

	if isMaxLv then
		SetActiveWithState(self, "GoUp", false)
		SetActiveWithState(self, "GoPut", false)
	else
		local needUpLevel = self.infoUnionSkill:NeedUpLevel()
		local jobId = UnionMgr.releUnion:GetMemberJob(PlayerInst.InfoPlayer.pid)
		local hasPrem = UnionJobMgr:HavePremission(jobId, UnionJobPremissionType.upSkill)

		SetActiveWithState(self, "GoUp", needUpLevel and hasPrem)
		SetActiveWithState(self, "GoPut", not needUpLevel or not hasPrem)

		if needUpLevel and hasPrem then
			local infoItem = ItemManager:GetItemByType("CLUB_COIN")

			SetImageSprite(self.ImgAssetIcon, infoItem:GetIcon(), self)

			local _, costNum = UnionSkillMgr:GetUpCostAsset(self.infoUnionSkill)
			local holdNum = UnionMgr.releUnion ~= nil and UnionMgr.releUnion.pb.coin or 0

			self.TxtAssetCost.text = GetItemShowStrNum2(costNum, holdNum)
		else
			if self.putAssetItem == nil then
				self.putAssetItem = UnionSkillMgr.GetSkillUpCostItemData()

				self.CellItem:UpdateWithNumType(self.putAssetItem)
			end

			if self.putAssetItem ~= nil then
				self.putAssetHold = ItemManager:GetItemCount(self.putAssetItem.id)

				self:CheckPut()
			end
		end
	end
end

function PageUnionSkill:CheckPut()
	if not self.infoUnionSkill then
		return
	end

	local info = self.infoUnionSkill

	SetActiveWithState(self, "BtnLess", self.curPutNum > 0)

	local disExp = info.nextExp - info.curExp
	local disNum = math.ceil(disExp / self.putAssetItem.data.Value)

	SetActiveWithState(self, "BtnPlus", disNum > self.curPutNum)

	if self.curPutNum <= 1 then
		DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnPut, TenaryOp(self.curPutNum > 0, 0, 1)))
	end

	local leftNum = self.putAssetHold - self.curPutNum

	self.CellItem:UpdateNumOnly(leftNum, true)

	self.TxtPutNum.text = _("UI_Put") .. "：" .. self.curPutNum
	self.TxtSkillExp.text = info.curExp + self.curPutNum * self.putAssetItem.data.Value .. "/" .. info.nextExp
	self.ImgSkillExp.fillAmount = (info.curExp + self.curPutNum * self.putAssetItem.data.Value) / info.nextExp

	if self.DlgAssetsInfo then
		self.DlgAssetsInfo:UpdateAssetShowNum(self.putAssetItem.id, leftNum)
	end
end

function PageUnionSkill:OnPointBtnLessDown(data)
	self.longPress = false
end

function PageUnionSkill:OnPointBtnLessRepeat(data)
	self.longPress = true
	self.curPutNum = self.curPutNum - 1

	self:CheckPut()
end

function PageUnionSkill:OnPointBtnLessUp(data)
	if self.longPress then
		-- block empty
	else
		self.curPutNum = self.curPutNum - 1

		self:CheckPut()
	end
end

function PageUnionSkill:OnPointBtnPlusDown(data)
	self.longPress = false

	if self.curPutNum >= self.putAssetHold then
		UIMgr.ShowMsg(_("UnionSkill_CoinNotEnough"))
	end
end

function PageUnionSkill:OnPointBtnPlusRepeat(data)
	if self.curPutNum >= self.putAssetHold then
		return
	end

	self.longPress = true
	self.curPutNum = self.curPutNum + 1

	self:CheckPut()
end

function PageUnionSkill:OnPointBtnPlusUp(data)
	if self.curPutNum >= self.putAssetHold then
		return
	end

	if not self.longPress then
		self.curPutNum = self.curPutNum + 1

		self:CheckPut()
	end
end

function PageUnionSkill:OnClickedBtnPut()
	local needUpLevel = self.infoUnionSkill:NeedUpLevel()

	if needUpLevel then
		UIMgr.ShowMsg(_("Msg_Wait_Admin_Up_SkillLevel"))

		return
	end

	if self.curPutNum <= 0 then
		UIMgr.ShowMsg(_("UnionSkill_CoinAddGreaterThanZero"))

		return
	end

	local function cb(_type)
		if _type == DlgCommonEvent.ButtonType.Ok then
			local function wrap_cb(vMsg)
				LoadingMgr.Hide(eLoadingType.Repeat)

				if vMsg.result.code == NetManager.Result_Sucess then
					self.listUnionSkill = UnionSkillMgr.listUnionSkill or {}

					self:UpdateScrollView()
					self:UpdatePanel()

					local infoRole = UnionTypeMgr:GetUnionTypeRole(UnionMgr.releUnion.pb.type)

					InfoSoundEventMgr:LoadBank(infoRole.data.VocalBank)
					InfoSoundEventMgr:Play("VocalCharaUp3", infoRole.data.VocalCharaUp3)

					if vMsg.flag == 1 then
						UIMgr.ShowMsg(_("Msg_Union_Skill_Put_Beyond"))
					else
						UIMgr.ShowMsg(_("Msg_Put_Success"))
					end
				elseif vMsg.result.code == 2 then
					PageUnion.GoBackMainPage(vMsg)
				elseif vMsg.result.code == 3 then
					UIMgr.ShowMsg(vMsg.result.desc, vMsg)

					local function cb()
						self:InitData()
					end

					self.RequestData(cb)
				else
					UIMgr.ShowMsg(vMsg.result.desc, vMsg)
				end
			end

			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:RequestProvideUnionSkillExp(self.infoUnionSkill.id, {
				self.putAssetItem.id,
				self.curPutNum
			}, wrap_cb)
		end
	end

	UIMgr.ShowCommon(DlgCommonEvent.Type.Confirm, _("Desc_Alert"), _("Desc_Union_SKill_Put_Prompt"), cb, _("UI_Yes"), _("UI_No"), false)
end

function PageUnionSkill:OnClickedBtnUp()
	local info = ItemManager:GetItemByType("CLUB_COIN")
	local costCoin = 0

	if info then
		local _, cost = UnionSkillMgr:GetUpCostAsset(self.infoUnionSkill)

		costCoin = cost or 0

		local isEnough = ItemManager:IsItemHoldEnough(info.id, costCoin)

		if not isEnough then
			return
		end
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			UIMgr.ShowMsg(_("PanelCard_SkillUp_Success"))
			self.infoUnionSkill:ChangeLevel()
			UnionMgr:ChangeCoin(costCoin)
			self:UpdateScrollView()
			self:UpdatePanel()
		elseif vMsg.result.code == 2 then
			PageUnion.GoBackMainPage(vMsg)
		elseif vMsg.result.code == 7 then
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)

			local function cb()
				self:InitData()
			end

			self.RequestData(cb)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestUpUnionSkillLevel(self.infoUnionSkill.id, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageUnionSkill:UpdateNetData()
	self:UpdateScrollView()
	self:UpdatePanel()
	self:UpdateUsableSpot()
end

function PageUnionSkill:OnClickedBtnGuide()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.UnionSkill)
end
