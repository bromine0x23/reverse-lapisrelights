-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFittingroom/DlgUnlock.lua

require("UI/Dlg/DlgBase")

DlgUnlock = class("DlgUnlock", DlgBase)

function DlgUnlock:ctor()
	self.nodeId = 0
	self.treeIndex = 1
	self.treeGroupIndex = 1
end

function DlgUnlock:Cache()
	self:SubmitUIPrefabCacheLua("UI/PageFittingroom/DlgUnlock")
end

function DlgUnlock:Purge()
	DlgUnlock.base.Purge(self)
end

function DlgUnlock:OnEnter(vParam)
	self.vParam = vParam
	self.ButtonQuit = self:GetChildGameObject("Image")
	self.ButtonGoto = self:GetChildGameObject("Panel/Image/Button")
	self.Text1 = self:GetChildComponent("Panel/ImageTitle/Text", "Text")
	self.Text1.text = Localization.Get("DESC_AVATAR_UNLOCKINFO")
	self.TextInfo = self:GetChildComponent("Panel/Image/Text", "Text")
	self.ImageCell = self:GetChildComponent("Panel/CellFitting/Image", "Image")
	self.TextCell = self:GetChildComponent("Panel/CellFitting/Text", "Text")

	local infoAvatar = self.vParam.InfoAvatar

	self.TextCell.text = infoAvatar.data.Name:ToLanguage()

	UIUtility.SetSprite(self.ImageCell, "UIDyAtlas/Cloth/" .. infoAvatar.data.Icon, false)

	self.TextInfo.text = Localization.Get("PATH_Singer") .. Localization.Get("DESC_UNLOCK")
	self.UnLockFuncType = PageFittingroom.GetUnLockFuncType(infoAvatar.id, self.vParam.InfoChar.id)

	if self.UnLockFuncType ~= FittingUnLockFuncType.Invalid then
		if self.UnLockFuncType == FittingUnLockFuncType.Vote then
			self.fromVote = true
		elseif self.UnLockFuncType == FittingUnLockFuncType.FG then
			local bg = self:GetChildComponent("Panel/CellFitting", "Image")

			UIUtility.SetSprite(bg, GetIconBkByItemType(eItemType.R_SOUL_AVATAR), false)
		elseif self.UnLockFuncType == FittingUnLockFuncType.AvatarConsume then
			-- block empty
		end

		self.TextInfo.text = PageFittingroom.GetUnLockDesc(infoAvatar.id, self.vParam.InfoChar.id)

		return
	end

	local infoChar = self.vParam.InfoChar
	local jobType = infoChar.data.Job
	local resultData = {}

	self.treeIndex = 1
	self.treeGroupIndex = 1
	resultData = self:GetNodeId(infoChar.skillTree1)

	if resultData.nodeId > 0 then
		jobType = infoChar.data.Job
		self.treeIndex = 1
	else
		resultData.nodeId = self:GetNodeId(infoChar.skillTree2)
		jobType = infoChar.data.SecondJob
		self.treeIndex = 2
	end

	self.treeGroupIndex = resultData.groupId
	self.nodeId = resultData.nodeId
	self.TextInfo.text = Localization.Get("PATH_" .. tostring(jobType)) .. Localization.Get("DESC_UNLOCK")
end

function DlgUnlock:GetNodeId(listSkillTree)
	local data = {}

	data.nodeId = 0
	data.groupId = 1

	for i = 1, #listSkillTree do
		local listTree = listSkillTree[i].tlistBranch

		nodeId = self:GetJobType(listTree)

		if nodeId > 0 then
			data.nodeId = nodeId
			data.groupId = i

			return data
		end
	end

	return data
end

function DlgUnlock:GetJobType(listTree)
	local infoAvatar = self.vParam.InfoAvatar

	for i = 1, #listTree do
		local td = listTree[i]
		local tlistNode = td.list
		local nb2 = #tlistNode - 1

		for j = 0, nb2 do
			local node = tlistNode[j + 1]

			if node.skillType == SkillType.Avatar and node.infoAvatar.id == infoAvatar.id then
				return node.id
			end
		end
	end

	return 0
end

function DlgUnlock:OnLeave()
	self.vParam = nil
	self.ButtonQuit = nil
	self.ButtonGoto = nil
	self.Text1 = nil
	self.TextInfo = nil
	self.ImageCell = nil
	self.TextCell = nil
	self.fromVote = nil
	self.treeIndex = nil
	self.treeGroupIndex = nil
	self.nodeId = nil
	self.UnLockFuncType = nil
end

function DlgUnlock:OnRegisterEvent()
	self:AutoRegistClick(self.ButtonQuit, self.OnNext, PATH_SFX_UI_CANCEL)
	self:AutoRegistClick(self.ButtonGoto, self.OnGoto)
end

function DlgUnlock:OnUnRegisterEvent()
	return
end

function DlgUnlock:OnGoto(...)
	if self.UnLockFuncType == FittingUnLockFuncType.AvatarConsume then
		local data = {}

		data.index = 1

		PageVoteActive.GetInstance():EnterActive(data)
		self:Close()
	elseif self.vParam.group == FittingTypeEnum.Activity then
		local data = {}

		SwitchToPage(PageVote.GetInstance(), data)
		self:Close()
	elseif self.UnLockFuncType == FittingUnLockFuncType.FG then
		SceneMgr.LoadScene("FingerGuessing", nil)
	else
		local data = {}

		data.infoChar = self.vParam.InfoChar
		data.nodeId = self.nodeId
		data.treeIndex = self.treeIndex
		data.treeGroupIndex = self.treeGroupIndex

		SwitchToPage(PageSkill.GetInstance(), data)
		self:Close()
	end
end

function DlgUnlock:OnNext(...)
	self:Close()
end
