-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageManual/DlgUnlockTask.lua

require("UI/Page/PageRoleCard/Cell/CellCostItem")

DlgUnlockTask = class("DlgUnlockTask", UIPanel)

function DlgUnlockTask:ctor()
	self.UIPrefabPath = "UI/PageManual/DlgUnlockTask"
end

function DlgUnlockTask:PreLoad()
	self:LoadResAsync("UI/PanelRoleCard/CellCostItem", "PrefabCellItem", GameObject)
end

function DlgUnlockTask:Purge()
	DlgUnlockTask.base.Purge(self)

	if self.callback then
		self.callback()

		self.callback = nil
	end

	ResourceMgr.Unload(self.PrefabCellItem)

	for i = 1, #self.itemGo do
		if self.itemGo[i] then
			self.itemGo[i]:OnLeave()
		end
	end

	self.itemGo = nil
end

function DlgUnlockTask:OnRegisterEvent()
	self:AddClick(self.Button_OK, self.OnClickGetAward)
	self:AddClick(self.Button_GO, self.GoToFrom)
	self:AddClick(self.CloseBtn, self.Close)
end

function DlgUnlockTask:OnUnRegisterEvent()
	self:RemoveClick(self.Button_OK, self.OnClickGetAward)
	self:RemoveClick(self.Button_GO, self.GoToFrom)
	self:RemoveClick(self.CloseBtn, self.Close)
end

function DlgUnlockTask:OnEnter(vParam)
	self.info = vParam.info
	self.callback = vParam.callback
	self.TaskText = self:GetChildComponent("TweenRoot/Main/Image/Text", "Text")
	self.Button_OK = self:GetChildGameObject("TweenRoot/Main/Button_OK")
	self.ImgOK = self:GetChildComponent("TweenRoot/Main/Button_OK", "Image")
	self.Button_GO = self:GetChildGameObject("TweenRoot/Main/Button_GO")
	self.Finish = self:GetChildGameObject("TweenRoot/Main/Image/Finish")
	self.NotFinish = self:GetChildComponent("TweenRoot/Main/Image/NotFinish", "Text")
	self.Items = self:GetChildGameObject("TweenRoot/Main/Items")
	self.CloseBtn = self:GetChildGameObject("TweenRoot/Button")
	self.EmptyItem = self:GetChildGameObject("TweenRoot/Main/EmptyItem")

	local TXT = self:GetChildComponent("TweenRoot/Main/bg_title/Text", "Text")

	TXT.text = _("Desc_UnlockLimit")
	TXT = self:GetChildComponent("TweenRoot/Main/Item/Text", "Text")
	TXT.text = _("Desc_UseItem")
	TXT = self:GetChildComponent("TweenRoot/Main/EmptyItem", "Text")
	TXT.text = _("Desc_EmptyItem")
	self.NotFinish.text = _("Desc_Not_Get")

	self:UpdateData()
end

function DlgUnlockTask:UpdateData()
	local itemList = self.info.data.ItemNeed

	self.itemGo = {}

	local isHave = true

	for i = 1, #itemList do
		local itemInfo = ItemManager:Get(itemList[i][1])
		local item = CellCostItem(self.PrefabCellItem, self.Items)

		item:Create()

		local data = {
			showPrompt = true,
			parent = self.Items,
			info = itemInfo,
			needNum = itemList[i][2],
			needPos = {
				0,
				24
			}
		}

		if itemInfo:GetCurResNum() < data.needNum then
			isHave = false
		end

		item:UpdateData(data)
		table.insert(self.itemGo, item)
		GOUtil.SetTransformLocalScale(item.UIRootObject, 1.3)
	end

	SetActiveFunc(self.EmptyItem, #itemList == 0)

	self.TaskText.text = self.info:GetTaskDesc()

	local cur, total = self.info:GetProgress()

	self.Finish:SetActive(total <= cur)
	self.NotFinish.gameObject:SetActive(cur < total)
	self.Button_GO:SetActive(cur < total)

	local gray = TenaryOp(total <= cur and isHave, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgOK, gray))
end

function DlgUnlockTask:OnClickGetAward()
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			self:Close()

			local info = CollectionManager:Get(self.info.data.ID)

			info:SetData(self.info.data.ID)

			if info.data.Reward[1] and info.data.Reward[1][1] == 2 then
				local infoRole = RoleMgr:GetRole(info.data.roleId)

				infoRole:AddExtraSkillData({
					level = 1,
					id = info.data.Reward[1][2]
				})
				require("UI.Page.PageRoleCard.Dlg.DlgUpResult")
				UIMgr.AddPanel(DlgUpResult(), {
					index = 6,
					addAttr = info.data.Reward[1][2],
					infoRole = infoRole
				})
			end

			CollectionManager:AddNewOpenTask(self.info.data.ID)
			Event.Instance:Fire("UpdatePicTask")
		elseif vPBMessage.result.code == NetManager.Result_Timeout then
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		else
			UIMgr.ShowMsg(_("TipsNoFactor"))
		end
	end

	NetManager:RequestFinishIllustratedTask(self.info.data.ID, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgUnlockTask:GoToFrom()
	local condition = self.info.data.condition[1]

	if condition[1][1] == eCollectionTaskType.ROLE_CARD_COLLECT then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.DrawCard)

		if not isOpen then
			return
		end

		require("UI/Page/PageCardShop/PageCardShop")
		PageCardShop.InitNetData()
	elseif condition[1][1] == eCollectionTaskType.ROLE_CARD_LEVEL then
		if condition[2][1] ~= 0 then
			if #condition[2] > 1 then
				require("UI/Page/PageRoleCard/Page/PageRoleCardList")
				UIMgr.SwitchPanel(PageRoleCardList, {
					entType = eEnterType.cardPass
				})
			else
				require("UI/Page/PageRoleCard/Page/PageRoleCard")
				UIMgr.SwitchPanel(PageRoleCard, {
					tag = 1,
					cardId = condition[2][1]
				})
			end
		else
			require("UI/Page/PageRoleCard/Page/PageRoleCardList")
			UIMgr.SwitchPanel(PageRoleCardList, {
				entType = eEnterType.cardPass
			})
		end
	elseif condition[1][1] == eCollectionTaskType.ROLE_CARD_STAR then
		if condition[2][1] ~= 0 then
			if #condition[2] > 1 then
				require("UI/Page/PageRoleCard/Page/PageRoleCardList")
				UIMgr.SwitchPanel(PageRoleCardList, {
					entType = eEnterType.cardPass
				})
			else
				require("UI/Page/PageRoleCard/Page/PageRoleCard")
				UIMgr.SwitchPanel(PageRoleCard, {
					tag = 2,
					cardId = condition[2][1]
				})
			end
		else
			require("UI/Page/PageRoleCard/Page/PageRoleCardList")
			UIMgr.SwitchPanel(PageRoleCardList, {
				entType = eEnterType.cardPass
			})
		end
	elseif condition[1][1] == eCollectionTaskType.ROLE_CARD_BLOOM then
		if condition[2][1] ~= 0 then
			if #condition[2] > 1 then
				require("UI/Page/PageRoleCard/Page/PageRoleCardList")
				UIMgr.SwitchPanel(PageRoleCardList, {
					entType = eEnterType.cardPass
				})
			else
				require("UI/Page/PageRoleCard/Page/PageRoleCard")
				UIMgr.SwitchPanel(PageRoleCard, {
					tag = 3,
					cardId = condition[2][1]
				})
			end
		else
			require("UI/Page/PageRoleCard/Page/PageRoleCardList")
			UIMgr.SwitchPanel(PageRoleCardList, {
				entType = eEnterType.cardPass
			})
		end
	elseif condition[1][1] == eCollectionTaskType.ROLE_EQUIPMENTDEVELOP then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Equipment)

		if not isOpen then
			return
		end

		require("UI/Page/PageEquipment/PageEquipDevelop")

		local roleId = self.info.data.roleId

		UIMgr.SwitchPanel(PageEquipDevelop, {
			roleId = roleId
		})
	elseif condition[1][1] == eCollectionTaskType.ROLE_LIKABILITY then
		local roleId = self.info.data.roleId
		local infoRole
		local infoRole = RoleMgr:GetRole(roleId)

		SceneMainStage.Instance:OnEnterInteractionByRoleId(roleId, {
			tag = 1
		})
	elseif condition[1][1] == eCollectionTaskType.ROLE_EQUIPMENTBREAK then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Equipment)

		if not isOpen then
			return
		end

		require("UI/Page/PageEquipment/PageEquipDevelop")

		local roleId = self.info.data.roleId

		UIMgr.SwitchPanel(PageEquipDevelop, {
			roleId = roleId
		})
	end
end
