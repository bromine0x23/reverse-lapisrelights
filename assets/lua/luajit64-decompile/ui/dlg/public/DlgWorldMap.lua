-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Public/DlgWorldMap.lua

require("UI/Page/PageRole/PageRole")
require("UI/Page/PageInteraction/PageInteraction")
require("UI/Page/PageFittingroom/PageFittingroom")
require("UI/Page/PageRole/PageTalentTree")
require("UI/Page/PageRoleCard/Page/PageRoleCardList")
require("UI/Page/PageTask/PageTask")
require("UI/Page/PageWork/PageWork")
require("UI/Page/PageBag/PageBag")
require("UI/Page/PageFriend/PageFriendMain")
require("UI/Page/PageCardShop/PageCardShop")
require("UI/Page/PageUnion/PageUnion")
require("UI/Page/PageUnion/PageUnionJoin")
require("UI/Page/PageShop/PageShop")
require("UI/Page/PageOperation/PageOperationActiveNew")
require("UI/Page/PageChapter/PageChapter")
require("UI/Page/PageClassroom/PageMainStage")
require("UI/Page/PageCommunication/PageAddressBookNew")
require("UI/Page/PageBondage/PageBondage")
require("UI/Page/PageManual/PageManualMain")
require("UI/Page/PageTheme/PageTheme")

DlgWorldMap = class("DlgWorldMap", UIPanel)
DlgWorldMap.SceneMainBankStr = nil

function DlgWorldMap:ctor()
	self.UIPrefabPath = "UI/Common/DlgWorldMap/DlgWorldMap"
end

function DlgWorldMap:OnRegisterEvent()
	self:AddClick(self.BgNotice, self.OnClickedButton)
	self:AddClick(self.BtnPageRole, self.OnClickedPageRole)
	self:AddClick(self.BtnPageInteraction, self.OnClickedPageInteraction)
	self:AddClick(self.BtnPageFittingroom, self.OnClickedPageFittingroom)
	self:AddClick(self.BtnPageTalentTree, self.OnClickedPageTalentTree)
	self:AddClick(self.BtnPageRoleCardList, self.OnClickedPageRoleCardList)
	self:AddClick(self.BtnPageTask, self.OnClickedPageTask)
	self:AddClick(self.BtnPageWork, self.OnClickedPageWork)
	self:AddClick(self.BtnPageBag, self.OnClickedPageBag)
	self:AddClick(self.BtnPageFriend, self.OnClickedPageFriend)
	self:AddClick(self.BtnPageCardShop, self.OnClickedPageCardShop)
	self:AddClick(self.BtnPageUnion, self.OnClickedPageUnion)
	self:AddClick(self.BtnPageShop, self.OnClickedPageShop)
	self:AddClick(self.BtnPageOperationActive, self.OnClickedPageOperationActive)
	self:AddClick(self.BtnPageMainStage, self.OnClickedPageMainStage)
	self:AddClick(self.BtnPageChapter, self.OnClickedPageChapter)
	self:AddClick(self.BtnPagePVPMain, self.OnClickedPagePVPMain)
	self:AddClick(self.BtnPageAddressBook, self.OnClickedPageAddressBook)
	self:AddClick(self.BtnPageBondage, self.OnClickedPageBondage)
	self:AddClick(self.BtnPageManualMain, self.OnClickedPageManualMain)
	self:AddClick(self.BtnPageTheme, self.OnClickedPageTheme)
	Event.Instance:Add("DlgWorldMapEventClose", self.DlgWorldMapEventClose, self)
end

function DlgWorldMap:OnUnRegisterEvent()
	self:RemoveClick(self.BgNotice, self.OnClickedButton)
	self:RemoveClick(self.BtnPageRole, self.OnClickedPageRole)
	self:RemoveClick(self.BtnPageInteraction, self.OnClickedPageInteraction)
	self:RemoveClick(self.BtnPageFittingroom, self.OnClickedPageFittingroom)
	self:RemoveClick(self.BtnPageTalentTree, self.OnClickedPageTalentTree)
	self:RemoveClick(self.BtnPageRoleCardList, self.OnClickedPageRoleCardList)
	self:RemoveClick(self.BtnPageTask, self.OnClickedPageTask)
	self:RemoveClick(self.BtnPageWork, self.OnClickedPageWork)
	self:RemoveClick(self.BtnPageBag, self.OnClickedPageBag)
	self:RemoveClick(self.BtnPageFriend, self.OnClickedPageFriend)
	self:RemoveClick(self.BtnPageCardShop, self.OnClickedPageCardShop)
	self:RemoveClick(self.BtnPageUnion, self.OnClickedPageUnion)
	self:RemoveClick(self.BtnPageShop, self.OnClickedPageShop)
	self:RemoveClick(self.BtnPageOperationActive, self.OnClickedPageOperationActive)
	self:RemoveClick(self.BtnPageMainStage, self.OnClickedPageMainStage)
	self:RemoveClick(self.BtnPageChapter, self.OnClickedPageChapter)
	self:RemoveClick(self.BtnPagePVPMain, self.OnClickedPagePVPMain)
	self:RemoveClick(self.BtnPageAddressBook, self.OnClickedPageAddressBook)
	self:RemoveClick(self.BtnPageBondage, self.OnClickedPageBondage)
	self:RemoveClick(self.BtnPageTheme, self.OnClickedPageTheme)
	self:RemoveClick(self.BtnPageManualMain, self.OnClickedPageManualMain)
	Event.Instance:Remove("DlgWorldMapEventClose", self.DlgWorldMapEventClose, self)

	if not self.OnClickClose then
		FriendMgr.IsExitOnPageFriend = false
		FriendMgr.PlayerInfoData = nil
	end
end

function DlgWorldMap:OnClickedButton()
	self.OnClickClose = true

	self:Close()
end

function DlgWorldMap:DlgWorldMapEventClose()
	self:Close()
end

function DlgWorldMap:Purge()
	DlgWorldMap.base.Purge(self)

	CardExtraMgr.tabIndex = 0
	EquipmentManager.LastDevelopTab = 0
end

function DlgWorldMap:OnEnter(vParam)
	self.UIRootObject.transform:SetAsFirstSibling()

	self.BgNotice = self:GetChildGameObject("Bg")
	self.BtnPageRole = self:GetChildGameObject("Image/BtnPageRole")
	self.BtnPageInteraction = self:GetChildGameObject("Image/BtnPageInteraction")
	self.BtnPageFittingroom = self:GetChildGameObject("Image/BtnPageFittingroom")
	self.BtnPageTalentTree = self:GetChildGameObject("Image/BtnPageTalentTree")
	self.BtnPageRoleCardList = self:GetChildGameObject("Image/BtnPageRoleCardList")
	self.BtnPageTask = self:GetChildGameObject("Image/BtnPageTask")
	self.BtnPageWork = self:GetChildGameObject("Image/BtnPageWork")
	self.BtnPageBag = self:GetChildGameObject("Image/BtnPageBag")
	self.BtnPageFriend = self:GetChildGameObject("Image/BtnPageFriend")
	self.BtnPageCardShop = self:GetChildGameObject("Image/BtnPageCardShop")
	self.BtnPageUnion = self:GetChildGameObject("Image/BtnPageUnion")
	self.BtnPageShop = self:GetChildGameObject("Image/BtnPageShop")
	self.BtnPageOperationActive = self:GetChildGameObject("Image/BtnPageOperationActive")
	self.BtnPageMainStage = self:GetChildGameObject("Image/BtnPageMainStage")
	self.BtnPageChapter = self:GetChildGameObject("Image/BtnPageChapter")
	self.BtnPagePVPMain = self:GetChildGameObject("Image/BtnPagePVPMain")
	self.BtnPageAddressBook = self:GetChildGameObject("Image/BtnPageAddressBook")
	self.BtnPageBondage = self:GetChildGameObject("Image/BtnPageBondage")
	self.BtnPageManualMain = self:GetChildGameObject("Image/BtnPageManualMain")
	self.BtnPageTheme = self:GetChildGameObject("Image/BtnPageTheme")
end

function DlgWorldMap:OnClickedPageTheme()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Theme)

	if not isOpen then
		return
	end

	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PageTheme" then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	local function DlgWorldMapEvent()
		UIMgr.ClearAndSavePageMainStage()

		ThemeManager.TypeID = 1

		UIMgr.SwitchPanel(PageTheme, {})
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPageAddressBook()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Communication)

	if not isOpen then
		return
	end

	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PageAddressBookNew" then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	local function DlgWorldMapEvent()
		UIMgr.ClearAndSavePageMainStage()
		UIMgr.SwitchPanel(PageAddressBookNew, nil)
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPageBondage()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Bondage)

	if not isOpen then
		return
	end

	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PageBondage" then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	local function DlgWorldMapEvent()
		UIMgr.ClearAndSavePageMainStage()
		UIMgr.SwitchPanel(PageBondage)
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPageManualMain()
	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PageManualMain" then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	local function DlgWorldMapEvent()
		UIMgr.ClearAndSavePageMainStage()
		UIMgr.SwitchPanel(PageManualMain())
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPageRole()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Role)

	if not isOpen then
		return
	end

	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PageRole" then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PageRole" then
		self:Close()

		return
	end

	local function DlgWorldMapEvent()
		UIMgr.ClearAndSavePageMainStage()
		UIMgr.ClearPreviewActor()

		UIMgr.needClear = false
		FavorMgr.ShowFavorUnlock = fals

		local panelName = UIMgr.GetCurPanel().className

		if panelName ~= "PageEquip" and panelName ~= "PageInteraction" and panelName ~= "PageEquipAvatar" and panelName ~= "PageFittingroom" then
			CharacterThinMgr.ResetInterface(THIN_SYSTEM_TYPE.Role, nil, nil, nil, 1)
		end

		UIMgr.SwitchPanel(PageRole)
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPageInteraction()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Role)

	if not isOpen then
		return
	end

	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PageInteraction" then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	local function DlgWorldMapEvent()
		FavorMgr.ShowFavorUnlock = false

		UIMgr.ClearAndSavePageMainStage()

		local panelName = UIMgr.GetCurPanel().className

		if panelName ~= "PageEquip" and panelName ~= "PageRole" and panelName ~= "PageEquipAvatar" and panelName ~= "PageFittingroom" then
			CharacterThinMgr.ResetInterface(THIN_SYSTEM_TYPE.Role, nil, nil, nil, 1)
		end

		local roleId = CharacterThinMgr.LastData(THIN_SYSTEM_TYPE.Role).id

		SceneMainStage.Instance:OnEnterInteractionByRoleId(roleId)
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPageFittingroom()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Role)

	if not isOpen then
		return
	end

	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Dress)

	if not isOpen then
		return
	end

	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PageFittingroom" then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	local function DlgWorldMapEvent()
		UIMgr.ClearAndSavePageMainStage()

		local panelName = UIMgr.GetCurPanel().className

		if panelName ~= "PageEquip" and panelName ~= "PageRole" and panelName ~= "PageEquipAvatar" and panelName ~= "PageInteraction" then
			CharacterThinMgr.ResetInterface(THIN_SYSTEM_TYPE.Role, nil, nil, nil, 1)
		end

		UIMgr.SwitchPanel(PageFittingroom)

		FavorMgr.ShowFavorUnlock = false
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPageTalentTree()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Role)

	if not isOpen then
		return
	end

	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Talent)

	if not isOpen then
		return
	end

	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PageTalentTree" then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	local function DlgWorldMapEvent()
		UIMgr.ClearAndSavePageMainStage()
		UIMgr.SwitchPanel(PageTalentTree)

		FavorMgr.ShowFavorUnlock = false
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPageRoleCardList()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Card)

	if not isOpen then
		return
	end

	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PageRoleCardList" then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	local function DlgWorldMapEvent()
		UIMgr.ClearAndSavePageMainStage()
		UIMgr.SwitchPanel(PageRoleCardList, {
			entType = 1
		})

		FavorMgr.ShowFavorUnlock = false
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPageTask()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Task)

	if not isOpen then
		return
	end

	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PageTask" then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	if SystemMaintainMgr:Deal(SystemMaintainType.task, false, true) then
		return
	end

	local function DlgWorldMapEvent()
		UIMgr.ClearAndSavePageMainStage()
		UIMgr.SwitchPanel(PageTask, {
			entType = 2
		})

		FavorMgr.ShowFavorUnlock = false
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPageWork()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Work)

	if not isOpen then
		return
	end

	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PageWork" then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	if SystemMaintainMgr:Deal(SystemMaintainType.work, false, true) then
		return
	end

	local function DlgWorldMapEvent()
		UIMgr.ClearAndSavePageMainStage()
		UIMgr.SwitchPanel(PageWork)

		FavorMgr.ShowFavorUnlock = false
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPageBag()
	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PageBag" then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	local function DlgWorldMapEvent()
		UIMgr.ClearAndSavePageMainStage()

		if ItemManager.tabIndex ~= 0 then
			ItemManager.tabIndex = 0
		end

		UIMgr.SwitchPanel(PageBag, {
			entType = 2
		})

		FavorMgr.ShowFavorUnlock = false
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPageFriend()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Friend)

	if not isOpen then
		return
	end

	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and GameObject.Find("PageFriendMain(Clone)") then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	local function DlgWorldMapEvent()
		PageFriendMain.RequestData()

		FavorMgr.ShowFavorUnlock = false
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPageCardShop()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.DrawCard)

	if not isOpen then
		return
	end

	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PageCardShop" then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	if SystemMaintainMgr:Deal(SystemMaintainType.recruit, false, true) then
		return
	end

	local function DlgWorldMapEvent()
		UIMgr.ClearAndSavePageMainStage()
		PageCardShop.InitNetData()

		FavorMgr.ShowFavorUnlock = false
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPageUnion()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Union)

	if not isOpen then
		return
	end

	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PageUnionJoin" or UIMgr.GetCurPanel().className == "PageUnion" then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	local function DlgWorldMapEvent()
		local canCreate, msg = FuncOperablity:CanCreateUnion()

		if not canCreate then
			UIMgr.ShowMsg(msg)

			return
		end

		UIMgr.ClearAndSavePageMainStage()

		if not UnionMgr.HasUnion() then
			local function cb()
				UIMgr.SwitchPanel(PageUnionJoin)
			end

			PageUnionJoin.RequestData(cb)
		else
			require("UI/Page/PageUnion/PageUnion")

			local function cb()
				UIMgr.SwitchPanel(PageUnion)
			end

			PageUnion.RequestData(cb)
		end

		FavorMgr.ShowFavorUnlock = false
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPageShop()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Shop)

	if not isOpen then
		return
	end

	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and GameObject.Find("PageShop(Clone)") then
		self:Close()

		return
	end

	local function DlgWorldMapEvent()
		self:Close()

		FavorMgr.ShowFavorUnlock = false

		PageShop.InitNetData({
			tagIndex = 1,
			tabMainIndex = 6
		})
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPageOperationActive()
	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PageOperationActiveNew" then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	local function DlgWorldMapEvent()
		UIMgr.ClearAndSavePageMainStage()

		OperationActiveMgr.Tag = 1
		OperationActiveMgr.PageOperationActiveType = 1

		UIMgr.SwitchPanel(PageOperationActiveNew, {
			entType = 2
		})

		FavorMgr.ShowFavorUnlock = false
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPageChapter()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Fight)

	if not isOpen then
		return
	end

	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PageChapter" then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	local function DlgWorldMapEvent()
		UIMgr.ClearAndSavePageMainStage()
		require("UI/Page/PageChapter/PageChapter")
		require("Info/InfoChapter")

		local chapterId = ChapterMgr:GetCurChapter(ChapterType.main).data.ID
		local data = {}

		data.chapterType = ChapterFromType.main
		data.chapterId = chapterId

		local pageChapter = PageChapter()

		pageChapter.isSyncLoad = true

		UIMgr.SwitchPanel(pageChapter, 1)

		FavorMgr.ShowFavorUnlock = false
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPagePVPMain()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.PVP)

	if not isOpen then
		return
	end

	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PagePVPMain" then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	if SystemMaintainMgr:Deal(SystemMaintainType.pvp, false, true) then
		return
	end

	local function DlgWorldMapEvent()
		UIMgr.ClearAndSavePageMainStage()

		local InfoPVP = require("Info/InfoPVP")
		local curtime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
		local endtiem = GetConfigArgInt("PVPSettleSeconds")

		local function pc(pb)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if pb.result.code == NetManager.Result_Maintain then
				UIMgr.ShowMsg(_("Desc_FuncFobid"))

				return
			end

			InfoPVP:SetData(pb)

			local time = InfoPVP:GetSeasondata().subSeasonEndTime - NetData:GetCurServerTime() / DateUtil.MillsPerSecond

			if InfoPVP.pb.season.seasonStatus ~= 1 then
				UIMgr.ShowMsg(_("PvPSeason"))
			elseif time < 0 then
				UIMgr.ShowMsg(_("PvPSeason"))
			elseif time <= endtiem or tonumber(curtime) < tonumber(InfoPVP:GetSeasondata().subSeasonBeginTime) then
				UIMgr.ShowMsg(_("PvPSeason"))
			else
				require("UI/Page/pagePVP/PagePVPMain")
				UIMgr.SwitchPanel(PagePVPMain, InfoPVP.pb)
			end
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestSeasonData(0, 0, 1, pc)

		FavorMgr.ShowFavorUnlock = false
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:OnClickedPageMainStage()
	if SceneMgr.GetCurrentScene().className == "SceneMainStage" and UIMgr.GetCurPanel().className == "PageMainStage" then
		Event.Instance:Fire("PageShopCloseEvent")
		self:Close()

		return
	end

	self.OnClickClose = true

	UIMgr.ClearPreviewActor()

	local function DlgWorldMapEvent()
		if UIMgr.GetCurPanel().className == "PageInteraction" then
			SceneMainStage.Instance.OpenFromRole = false
		end

		UIMgr.ClearAndSavePageMainStage()
		UIMgr.ClearChildAndSavePageMainStage()
		UIMgr.PopPanel(nil, 0)

		FavorMgr.ShowFavorUnlock = false
	end

	if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	else
		DlgWorldMapEvent()
	end
end

function DlgWorldMap:ReturnPageMainStageEvent()
	return
end
