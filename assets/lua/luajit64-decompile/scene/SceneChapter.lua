-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Scene/SceneChapter.lua

require("Scene/SceneBase")
require("UI/Page/PageChapter/PageChapter")
require("UI/Page/PagePass/PageStage")

SceneChapter = class("SceneChapter", SceneBase, true)

function SceneChapter.CreateInstance()
	if not SceneChapter.Instance then
		SceneChapter.Instance = SceneChapter()
	end

	return SceneChapter.Instance
end

function SceneChapter.DestroyInstance()
	SceneChapter.Instance = nil
end

function SceneChapter:OnInit(vParam)
	if vParam.stageId then
		self.stageId = vParam.stageId
	end

	self.SceneData = SceneMgr.data[12]
end

function SceneChapter:OnCache()
	return
end

function SceneChapter:OnCreate()
	if self.stageId then
		local infoStage = ChapterMgr:GetStage(self.stageId)
		local chapterId = infoStage.data.ChapterID
		local chapterType = infoStage.data.ChapterType
		local infoChapter = ChapterMgr:GetChapter(chapterId)
		local lastStageId = infoChapter:GetLastStageId()
		local chapNum = ChapterMgr:GetChapterIdx(infoChapter.data.ID)

		if type(chapNum) ~= "number" then
			chapNum = 0
		end

		if lastStageId ~= self.stageId or chapNum == 9 then
			local data = {}

			data.chapterType = chapterType
			data.chapterId = chapterId

			UIMgr.SwitchPanel(PageStage, data)
		else
			UIMgr.SwitchPanel(PageChapter, 1)
		end

		self.stageId = nil
	else
		UIMgr.SwitchPanel(PageChapter, 1)
	end
end

function SceneChapter:OnRegisterEvent()
	return
end

function SceneChapter:OnUnRegisterEvent()
	return
end

function SceneChapter:OnDestroy()
	return
end

function SceneChapter:OnPurge()
	return
end

function SceneChapter:OnEnd()
	return
end

return SceneChapter
