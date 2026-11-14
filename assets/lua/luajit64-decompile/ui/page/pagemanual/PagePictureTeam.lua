-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageManual/PagePictureTeam.lua

require("UI/Page/PageManual/CellPicTab")

PagePictureTeam = class("PagePictureTeam", UIPanel)

function PagePictureTeam:ctor()
	self.UIPrefabPath = "UI/PageManual/PagePictureTeam"

	self:AddChildPanel(DlgExit(), {
		title = _("Desc_Figure"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PagePictureTeam:PreLoad()
	self:LoadResAsync("UI/PageManual/CellPicTab", "PrefabCellTab", GameObject)
end

function PagePictureTeam:OnBack()
	UIMgr.PopPanel()

	CollectionManager.curSelectTeam = nil

	UITweenUtil.RemoveAllTween()
end

function PagePictureTeam:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellTab)

	if self.UITabScrollTool then
		self.UITabScrollTool:Purge()
	end

	self.UITabScrollTool = nil

	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end
end

function PagePictureTeam:OnRegisterEvent()
	Event.Instance:Add("ClickPoolTab", self.OnClickTab, self)
end

function PagePictureTeam:OnUnRegisterEvent()
	for i, v in ipairs(self.addClickList) do
		self:RemoveClick(v, self.OnClickRoleImage)
	end

	Event.Instance:Remove("ClickPoolTab", self.OnClickTab, self)
end

function PagePictureTeam:OnEnter(vParam)
	self:DealWithLocalization()
	ManualRDL.NotesRDL.ViewedNotes(true)

	self.listTeamData = TeamMgr.Instance:GetTeamList()
	self.listTab = {}

	for i = 1, #self.listTeamData do
		self["GoTeam" .. i] = self:GetChildGameObject("Panel/Team/" .. i)

		if self.listTeamData[i].ManualVersion == 1 then
			table.insert(self.listTab, self.listTeamData[i])
		end
	end

	if CollectionManager.curSelectTeam ~= nil then
		self.selectIndex = CollectionManager.curSelectTeam
	else
		self.selectIndex = 1
	end

	self.addClickList = {}

	self:UpdateNewUnlock()
	self:UpdateTaskCanFinish()
	self:InitTabScrollView()
	self:UpdatePanel()
end

function PagePictureTeam:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/Team/PointTip", "Text")
	txt.text = _("Desc_PicTeamPointTip")
end

function PagePictureTeam:UpdateNewUnlock()
	self.NewUnlockRole = PersistentStoreUtil.GetList(PersistentStoreUtil.KEY_PICTURE_ROLE)
	self.newPicTeam = {}

	for i, v in ipairs(self.NewUnlockRole) do
		if v ~= "" then
			local team = RoleMgr:GetRole(tonumber(v)).data.Team

			if not table.contains(self.newPicTeam, team) then
				table.insert(self.newPicTeam, team)
			end
		end
	end
end

function PagePictureTeam:UpdateTaskCanFinish()
	self.curOpenList = CollectionManager.curOpenList
	self.canFinishTeam = {}
	self.canFinishRole = {}

	for k, v in pairs(self.curOpenList) do
		for k, taskInfo in pairs(v) do
			local cur, total = taskInfo:GetProgress()

			if total <= cur and taskInfo:CheckItemEnough() then
				if not table.contains(self.canFinishRole, taskInfo.data.roleId) then
					table.insert(self.canFinishRole, taskInfo.data.roleId)
				end

				local infoRole = RoleMgr:GetRole(taskInfo.data.roleId)

				if not table.contains(self.canFinishTeam, infoRole.data.Team) then
					table.insert(self.canFinishTeam, infoRole.data.Team)
				end

				break
			end
		end
	end
end

function PagePictureTeam:UpdatePanel()
	UITweenUtil.RemoveAllTween()

	local curObj = self["GoTeam" .. self.listTab[self.selectIndex].ID]

	for i = 1, #self.listTab do
		local teamID = self.listTab[i].ID

		if i == self.selectIndex then
			self["GoTeam" .. teamID]:SetActive(true)
		else
			self["GoTeam" .. teamID]:SetActive(false)
		end

		for k, roleId in ipairs(self.listTab[i].MemberList) do
			local roleGo = GOUtil.FindChildGameObject(curObj, "Team/" .. roleId)

			if roleGo then
				if not table.contains(self.addClickList, roleGo) then
					table.insert(self.addClickList, roleGo)
					self:AddClick(roleGo, self.OnClickRoleImage)
				end

				local infoRole = RoleMgr:GetRole(roleId)
				local roleMask = GOUtil.FindChildGameObject(curObj, "Team/" .. roleId .. "/mask")
				local roleNotActive = GOUtil.FindChildGameObject(curObj, "Team/" .. roleId .. "/NotActive")
				local roleNotActiveImage = GOUtil.FindChildComponent(curObj, "Team/" .. roleId .. "/NotActive", "Image")
				local text = GOUtil.FindChildComponent(curObj, "Team/" .. roleId .. "/NotActive/Text", "Text")

				text.text = _("Pic_NotActive")

				if not infoRole.hold then
					roleMask:SetActive(true)
					roleNotActive:SetActive(false)
				else
					roleMask:SetActive(false)

					local role = GOUtil.FindChildGameObject(curObj, "Team/" .. roleId)

					UITweenUtil.SingleTween(role.transform, "y", 10, 0.2)

					local openInfo = CollectionManager:GetPicOpenInfo(roleId)

					if openInfo:IsGetAward() then
						roleNotActive:SetActive(false)
					else
						roleNotActive:SetActive(true)

						local cur, total = openInfo:GetProgress()

						if total <= cur and openInfo:CheckItemEnough() then
							roleNotActiveImage.color = getColorFromString("CC1C73")
						else
							roleNotActiveImage.color = getColorFromString("636363")
						end
					end
				end

				local roleNew = GOUtil.FindChildGameObject(curObj, "NewUnlock/" .. roleId)

				roleNew:SetActive(table.contains(self.NewUnlockRole, tostring(roleId)))
				RedDotSystemMgr.SetUIRedDot(roleGo, string.format(GetNodesPath(2), teamID, roleId))
			end
		end
	end
end

function PagePictureTeam:InitTabScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/ScrollArea2")
	local content = self:GetChildComponent("Panel/ScrollArea2/Content", "Transform")
	local count = #self.listTab

	local function addClick(item)
		item:OnRegisterEvent()
	end

	local function updateTab(item, index)
		item.Index = index

		local info = {}

		info.Path = self.listTab[index].ManualIcon

		item:UpdateImage(info, self.selectIndex)

		local path = string.format(GetNodesPath(1), self.listTab[index].ID)

		item:SetDot(path)
	end

	self.UITabScrollTool = UIScrollTool()

	self.UITabScrollTool:InitList(ScrollArea, content, count, self.PrefabCellTab, CellPicTab, self, false, addClick, updateTab)

	local pos = GetContentPos(self.UITabScrollTool.ScrollView, #self.listTab, self.selectIndex, true)

	self.UITabScrollTool:SetInitPos(Vector3(0, pos, 0))
	self.UITabScrollTool:SetContentPosImmediate(Vector2(0, -pos), self.listTab)
end

function PagePictureTeam:OnClickTab(index)
	if index == self.selectIndex then
		return
	end

	self.selectIndex = index

	self.UITabScrollTool:UpdateListDataKeepPos(self.listTab)
	self:UpdatePanel()

	if table.contains(self.newPicTeam, index) then
		table.removeByValue(self.newPicTeam, index)
	end

	for _, roleId in ipairs(self.listTab[index].MemberList) do
		if table.contains(self.NewUnlockRole, tostring(roleId)) then
			table.removeByValue(self.NewUnlockRole, tostring(roleId))
		end
	end

	PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_PICTURE_ROLE, self.NewUnlockRole)
end

function PagePictureTeam:OnClickRoleImage(data)
	UITweenUtil.RemoveAllTween()

	local go = data.pointerPressRaycast.gameObject.transform.parent
	local roleId = tonumber(go.name)

	if not RoleMgr:GetRole(roleId).hold then
		UIMgr.ShowMsg(_("TipsNoChara"))

		return
	end

	local openInfo = CollectionManager:GetPicOpenInfo(roleId)

	if openInfo:IsGetAward() then
		require("UI/Page/PageManual/PagePictureTask")
		UIMgr.SwitchPanel(PagePictureTask, {
			roleId = roleId
		})
	else
		require("UI/Page/PageManual/PagePictureAlbum")
		UIMgr.SwitchPanel(PagePictureAlbum, {
			roleId = roleId
		})
	end

	CollectionManager.curSelectTeam = self.selectIndex
end
