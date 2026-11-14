-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgItemAccess.lua

require("UI/Page/PagePass/PageAssetPass")
require("UI/Page/PageShop/PageShop")

DlgItemAccess = class("DlgItemAccess", UIPanel)

function DlgItemAccess:ctor()
	DlgItemAccess.base.ctor(self, "UI/Common/DlgItemAccess/DlgItemAccess")
end

function DlgItemAccess:PreLoad()
	self:LoadResAsync("UI/Common/DlgItemAccess/CellAccess", "PrefabCell")
end

function DlgItemAccess:Purge()
	DlgItemAccess.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCell)
end

function DlgItemAccess:OnRegisterEvent()
	self:AddClick(self.BtnQuit, self.OnClickBtnQuit)
end

function DlgItemAccess:OnUnRegisterEvent()
	self:RemoveClick(self.BtnQuit, self.OnClickBtnQuit)

	for i = 1, self.count do
		self:RemoveClick(self["BtnGo" .. i], self.OnClcikBtnGo)
	end
end

function DlgItemAccess:OnEnter(vParam)
	local Text = self:GetChildComponent("Panel/Title/Text", "Text")

	Text.text = _("42319")
	Text = self:GetChildComponent("Panel/Access/Text", "Text")
	Text.text = _("42319")
	Text = self:GetChildComponent("Panel/TxtNotAcc", "Text")
	Text.text = _("42320")
	self.BtnQuit = self:GetChildGameObject("Panel/Button")
	self.GoNotAcc = self:GetChildGameObject("Panel/TxtNotAcc")

	local itemId = vParam
	local infoItem = ItemManager:Get(itemId)

	self.listFromWhere = infoItem.data.FromWhere

	local itemIcon = self:GetChildComponent("Panel/Item/Icon", "Image")
	local rank1 = self:GetChildComponent("Panel/Item/Rank1", "Image")
	local rank2 = self:GetChildComponent("Panel/Item/Rank2", "Image")
	local txtName = self:GetChildComponent("Panel/Item/TxtName", "Text")
	local txtDesc = self:GetChildComponent("Panel/Item/TxtDesc", "Text")

	ItemManager:SetItemInfo(infoItem, itemIcon, rank1, rank2)

	txtName.text = Lang(infoItem.data.Name)
	txtDesc.text = Lang(infoItem.data.Info)

	self:InitAccess()
end

function DlgItemAccess:InitAccess()
	local ScrollArea = self:GetChildGameObject("Panel/BgScroll/ScrollArea")
	local ScrollView = GOUtil.AddMissingComponent(ScrollArea, "UIScrollView")

	ScrollView.vertical = true
	ScrollView.content = self:GetChildComponent("Panel/BgScroll/ScrollArea/Content", "Transform")
	self.count = #self.listFromWhere

	if self.count == 0 then
		self.GoNotAcc:SetActive(true)

		return
	end

	for i = 1, self.count do
		local goCell = GOUtil.InstantiatePrefab(self.PrefabCell, ScrollView.content.gameObject)
		local textBtn = GOUtil.FindChildComponent(goCell, "Button/Text", "Text")

		textBtn.text = _("UI_Click_Go")

		local res = i % 2

		if res == 0 then
			local bg = GOUtil.FindChildGameObject(goCell, "Bg")

			bg:SetActive(false)
		end

		local fromType = self.listFromWhere[i][1]
		local fromIndex = 1

		if self.listFromWhere[i][2] and self.listFromWhere[i][2] > 0 then
			fromIndex = self.listFromWhere[i][2]

			if fromIndex == 0 then
				fromIndex = 1
			end
		end

		if fromType == 11 or fromType == 16 then
			fromIndex = 1
		end

		if fromType == 18 then
			fromIndex = self.listFromWhere[i][3] and 1 or 0
		end

		local txtAccess = GOUtil.FindChildComponent(goCell, "Text", "Text")

		txtAccess.text = _("Item_From_" .. fromType .. "_" .. fromIndex)

		if fromType == 8 and fromIndex > 1 then
			local id = fromIndex
			local infoStage = ChapterMgr:GetStage(id)

			if infoStage and infoStage.data then
				txtAccess.text = infoStage:GetName()
			end
		end

		self["BtnGo" .. i] = GOUtil.FindChildGameObject(goCell, "Button")

		self:AddClick(self["BtnGo" .. i], self.OnClcikBtnGo)

		goCell.name = i
	end
end

function DlgItemAccess:OnClcikBtnGo(data)
	local go = data.pointerPress.transform.parent.gameObject
	local index = tonumber(go.name)
	local fromWhere = self.listFromWhere[index]

	DlgItemAccess.GoToFrom(fromWhere)
end

function DlgItemAccess:OnClickBtnQuit()
	self:Close()
end

function DlgItemAccess.GoToFrom(fromWhere)
	local fromType = fromWhere[1]

	if fromType == 1 then
		local index = fromWhere[2]

		if index == 1 or index == 2 then
			UIMgr.ShowMsg(_("Desc_Not_Open"))

			return
		end

		local mainindex = tabMainType.package

		if index == 4 then
			mainindex = tabMainType.item
		end

		PageShop.InitNetData({
			tagIndex = 1,
			tabMainIndex = mainindex
		})
	elseif fromType == 2 then
		require("UI/Page/PageCardShop/PageCardShop")
		PageCardShop.InitNetData()
	elseif fromType == 3 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Boss)

		if isOpen then
			local isShow, msg = ActiveMgr:IsBossActiveOpen()

			if not isShow then
				UIMgr.ShowMsg(msg)

				return
			end

			local fromIndex = fromWhere[2]

			if fromIndex == 1 then
				require("UI/Page/PageActivity/PageBossActivityBG")

				ChapterMgr.BossActivityStageType = nil

				PageBossActivityBG.OpenActivity()
			elseif fromIndex == 2 then
				require("UI/Page/PageActivity/PageBossActivityBG")

				ChapterMgr.BossActivityStageType = StageFromType.activeCommon

				PageBossActivityBG.OpenActivity()
			elseif fromIndex == 3 then
				local infoActive = PageBossActivity.GetCurBossActive()

				local function wrap_cb(vPBMessage)
					LoadingMgr.Hide(eLoadingType.Repeat)

					if vPBMessage.result.code == NetManager.Result_Sucess then
						require("UI/Page/PageActivity/PageBossActivityShop")
						UIMgr.SwitchPanel(PageBossActivityShop, {
							pools = vPBMessage.pools
						})
					else
						UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
					end
				end

				NetManager:RequestGetActityPool(infoActive.id, wrap_cb)
				LoadingMgr.Show(eLoadingType.Repeat)
			elseif fromIndex == 4 then
				require("UI/Page/PageActivity/PageBossActivityBG")

				ChapterMgr.BossActivityStageType = StageFromType.story

				PageBossActivityBG.OpenActivity()
			end
		end
	elseif fromType == 4 or fromType == 5 or fromType == 6 then
		local fromIndex = fromWhere[2]

		if fromType == 4 then
			ChapterMgr.resIndex = 1
		elseif fromType == 5 then
			ChapterMgr.resIndex = 2
		elseif fromType == 6 then
			ChapterMgr.resIndex = 3
		end

		local listActive = PassMgr:GetBranchActiveList(3, ChapterMgr.resIndex)
		local activeId = listActive[fromIndex].ID
		local info = ActiveMgr:GetActive(listActive[fromIndex].ID)

		if info:TodayIsOpen() then
			ChapterMgr.resTabIndex = fromIndex

			PageAssetPass.EnterStageList(ChapterMgr.resIndex)
		else
			UIMgr.ShowMsg(_("Desc_Not_Open"))
		end
	elseif fromType == 7 then
		require("UI/Page/PagePass/PageTeamPass")

		local fromIndex = fromWhere[2]

		if fromIndex == 0 then
			UIMgr.SwitchPanel(PageTeamPass)
		else
			PageTeamPass.EnterStage(fromIndex)
		end
	elseif fromType == 8 then
		local fromIndex = fromWhere[2]

		if fromIndex == 0 then
			require("UI/Page/PageChapter/PageChapter")
			UIMgr.SwitchPanel(PageChapter, 1)
		else
			local id = fromIndex
			local infoStage = ChapterMgr:GetStage(id)

			if not infoStage then
				UIMgr.ShowMsg(_("Desc_NoChapter"))

				return
			end

			if not infoStage:IsOpen() then
				UIMgr.ShowMsg(_("PageTalentTree_Locked"))

				return
			end

			local data = {}

			data.chapterType = infoStage.data.ChapterType
			data.chapterId = infoStage.data.ChapterID

			UIMgr.SwitchPanel(PageStage, data)
		end
	elseif fromType == 9 then
		-- block empty
	elseif fromType == 10 then
		require("UI/Page/PageRoleCard/Page/PageRoleCardList")

		local fromIndex = fromWhere[2]
		local id = fromWhere[3]

		if fromIndex == 1 then
			if id and id > 0 then
				local tag = fromWhere[4]

				if tag and tag > 0 then
					UIMgr.SwitchPanel(PageRoleCard, {
						cardId = id,
						tag = tag
					})
				else
					UIMgr.SwitchPanel(PageRoleCard, {
						cardId = id
					})
				end
			else
				UIMgr.SwitchPanel(PageRoleCardList, {
					entType = eEnterType.cardMain
				})
			end
		else
			if id and id > 0 then
				ChapterMgr.cardIndex = id
				CardExtraMgr.LastCardStageCardId = id
			end

			require("UI/Page/PagePass/PageCardStage")
			UIMgr.SwitchPanel(PageCardStage)
		end
	elseif fromType == 11 then
		require("UI/Page/PageEquipment/PageEquip")

		local roleId = fromWhere[2]
		local slotId = fromWhere[3]

		if slotId and slotId > 0 then
			if roleId <= 0 then
				local listRole = RoleMgr:GetAllHoldRole()

				roleId = listRole[1].id
			end

			require("UI/Page/PageEquipment/PageEnchant")

			if PageEquip.IsSlotUnlocked(roleId, slotId) then
				local tagIndex = fromWhere[4]

				if tagIndex and tagIndex > 0 then
					if PageEnchant.IsUnlock(tagIndex, true) then
						UIMgr.SwitchPanel(PageEnchant, {
							roleId = roleId,
							slotIdx = slotId,
							tag = tagIndex
						})
					end
				else
					UIMgr.SwitchPanel(PageEnchant, {
						roleId = roleId,
						slotIdx = slotId
					})
				end
			end
		elseif roleId > 0 then
			UIMgr.SwitchPanel(PageEquip, {
				roleId = roleId
			})
		else
			UIMgr.SwitchPanel(PageEquip)
		end
	elseif fromType == 12 then
		require("UI/Page/PageWork/PageWork")
		UIMgr.SwitchPanel(PageWork)
	elseif fromType == 13 then
		local fromIndex = fromWhere[2]

		require("UI/Page/PageFriend/PageFriend")
		PageFriend.InitData(fromIndex)
	elseif fromType == 14 then
		require("UI/Page/PageFittingroom/PageFittingroom")

		local roleId = fromWhere[2]
		local tag = fromWhere[3]

		if tag and tag > 0 then
			AvatarManager.curTabIndex = tag
		end

		local infoRole

		if roleId <= 0 then
			local listRole = RoleMgr:GetAllHoldRole()

			roleId = listRole[1].id
		end

		infoRole = RoleMgr:GetRole(roleId)

		UIMgr.SwitchPanel(PageFittingroom, {
			from = 4,
			infoRole = infoRole
		})
	elseif fromType == 15 then
		local roleId = fromWhere[2]

		require("UI/Page/PageRole/PageTalentTree")

		if roleId <= 0 then
			local listRole = RoleMgr:GetAllHoldRole()

			roleId = listRole[1].id
		end

		UIMgr.SwitchPanel(PageTalentTree, {
			roleId = roleId
		})
	elseif fromType == 16 then
		local tag = fromWhere[2]

		require("UI/Page/PageOperation/PageOperationActiveNew")

		OperationActiveMgr.PageOperationActiveType = 1

		UIMgr.SwitchPanel(PageOperationActiveNew, {
			tag = tag
		})
	elseif fromType == 17 then
		require("UI/Page/PageOperation/DlgTimeLimitTask")
		UIMgr.SwitchPanel(DlgTimeLimitTask())
	elseif fromType == 18 then
		local roleId = fromWhere[2]
		local tag = fromWhere[3]
		local infoRole

		if roleId <= 0 then
			local listRole = RoleMgr:GetAllHoldRole()

			roleId = listRole[1].id
		end

		infoRole = RoleMgr:GetRole(roleId)

		SceneMainStage.Instance:LoadActor(infoRole, false, nil, {
			from = 4,
			tag = tag
		})
	elseif fromType == 99 then
		UIMgr.AddPanel(PagePlatformSelect(), {
			useForLogin = false
		})
	end
end
