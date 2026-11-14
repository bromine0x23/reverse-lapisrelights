-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgTutorialView.lua

DlgTutorialView = class("DlgTutorialView", UIPanel)

function DlgTutorialView:ctor()
	return
end

function DlgTutorialView:Cache()
	self:SubmitUIPrefabCacheLua("UI/PanelTutorial/PanelTutorial")
end

function DlgTutorialView:Purge()
	self.list = nil
	self.ButtonLeft = nil
	self.ButtonRight = nil
	self.ButtonOk = nil
	self.ScrollArea = nil
	self.ScrollView = nil

	DlgTutorialView.base.Purge(self)
end

function DlgTutorialView:OnEnter(vParam)
	self.list = vParam.list
	self.callback = vParam.cb
	self.ButtonLeft = self:GetChildComponent("Panel/ButtonLeft", "Button")
	self.ButtonRight = self:GetChildComponent("Panel/ButtonRight", "Button")
	self.ButtonOk = self:GetChildComponent("Panel/ButtonOk", "Button")

	self:InitList()
	self:UpdateScroll()

	self.curIndex = 1

	self:UpdateBtn()
end

function DlgTutorialView:UpdateBtn()
	self.ButtonLeft.gameObject:SetActive(true)
	self.ButtonRight.gameObject:SetActive(true)
	self.ButtonOk.gameObject:SetActive(false)

	local count = #self.list

	if count == 1 then
		self.ButtonLeft.gameObject:SetActive(false)
		self.ButtonRight.gameObject:SetActive(false)
		self.ButtonOk.gameObject:SetActive(true)
	else
		if self.curIndex == 1 then
			self.ButtonLeft.gameObject:SetActive(false)
		end

		if self.curIndex == count then
			self.ButtonRight.gameObject:SetActive(false)
			self.ButtonOk.gameObject:SetActive(true)
		end
	end
end

function DlgTutorialView:InitList()
	self.ScrollArea = self:GetChildGameObject("Panel/ScrollArea")
	self.ScrollView = GOUtil.AddMissingComponent(self.ScrollArea, "UIScrollView")
	self.ScrollView.horizontal = true
	self.ScrollView.content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")

	function self.ScrollView.onSlippingComplete(...)
		self:OnRoll()
	end
end

function DlgTutorialView:UpdateScroll()
	MxUtil.DestroyChildTransform(self.ScrollView.content)

	for i = 1, #self.list do
		local g = GOUtil.InstantiatePrefab(ResourceMgr:LoadSyncLua("UI/PanelTutorial/CellTutorial"), self.ScrollView.content.gameObject)

		g.name = i

		local img = GOUtil.GetComponent(g, "Image")
		local id = self.list[i]

		UIUtility.SetSprite(img, "UIDyAtlas/Tutorial/" .. id, false)

		local scrollviewContent = GOUtil.AddMissingComponent(g, "UIScrollViewContent")

		scrollviewContent.scrollView = self.ScrollView
	end
end

function DlgTutorialView:OnLeave()
	return
end

function DlgTutorialView:OnRegisterEventForInstruction()
	self:OnRegisterEvent()
end

function DlgTutorialView:OnRegisterEvent()
	self:AutoRegistClick(self.ButtonLeft.gameObject, self.OnBtnLeft)
	self:AutoRegistClick(self.ButtonRight.gameObject, self.OnBtnRight)
	self:AutoRegistClick(self.ButtonOk.gameObject, self.OnBtnOk)
end

function DlgTutorialView:OnUnRegisterEvent()
	return
end

function DlgTutorialView:OnBtnOk()
	self:Close()

	if self.callback then
		self.callback()
	end

	self:Purge()
	TimerMgr.AddTimer(0.1, function()
		Launcher:ClearMemory()
	end)
end

function DlgTutorialView:OnRoll()
	local pos = self.ScrollView.content.transform.localPosition.x
	local curPos = -1024 * (self.curIndex - 1)

	if curPos < pos then
		self:OnBtnLeft()
	else
		self:OnBtnRight()
	end
end

function DlgTutorialView:OnBtnLeft()
	if self.curIndex - 1 < 1 then
		return
	end

	self.curIndex = self.curIndex - 1

	local offx = -1024 * (self.curIndex - 1)

	self.ScrollView:SetContentPosImmediate(Vector2.New(offx, 0))
	self:UpdateBtn()
end

function DlgTutorialView:OnBtnRight()
	if self.curIndex + 1 > #self.list then
		return
	end

	self.curIndex = self.curIndex + 1

	local offx = -1024 * (self.curIndex - 1)

	self.ScrollView:SetContentPosImmediate(Vector2.New(offx, 0))
	self:UpdateBtn()
end

TutorialViewType = numEnum({
	"Explore",
	"ExploreJob",
	"ExploreTempPerform",
	"ExploreVideo",
	"TouchStudent",
	"AdjustSeat",
	"CharInfo",
	"Work",
	"PerformPrepare",
	"Equip",
	"Support",
	"Fans",
	"PVP",
	"Quiz",
	"Cook"
})

function DlgTutorialView.GetList(type)
	local list = {}

	if type == TutorialViewType.Explore then
		list = {
			"ui_bg_newguide_01",
			"ui_bg_newguide_02"
		}
	elseif type == TutorialViewType.ExploreJob then
		list = {
			"ui_bg_newguide_gongzuo01",
			"ui_bg_newguide_gongzuo02"
		}
	elseif type == TutorialViewType.ExploreTempPerform then
		list = {
			"ui_bg_newguide_linshi01"
		}
	elseif type == TutorialViewType.ExploreVideo then
		list = {
			"ui_bg_newguide_shipin01"
		}
	elseif type == TutorialViewType.TouchStudent then
		list = {
			"ui_bg_newguide_hudong01",
			"ui_bg_newguide_hudong02",
			"ui_bg_newguide_hudong03"
		}
	elseif type == TutorialViewType.AdjustSeat then
		list = {
			"ui_bg_newguide_jiaoshi01",
			"ui_bg_newguide_jiaoshi02"
		}
	elseif type == TutorialViewType.CharInfo then
		list = {
			"ui_bg_newguide_qianghua01",
			"ui_bg_newguide_qianghua02"
		}
	elseif type == TutorialViewType.Work then
		list = {
			"ui_bg_newguide_waiwu01",
			"ui_bg_newguide_waiwu02"
		}
	elseif type == TutorialViewType.PerformPrepare then
		list = {
			"ui_bg_newguide_gongyan01",
			"ui_bg_newguide_gongyan02"
		}
	elseif type == TutorialViewType.Equip then
		list = {
			"ui_bg_newguide_zhuangbei01",
			"ui_bg_newguide_zhuangbei02"
		}
	elseif type == TutorialViewType.Support then
		list = {
			"ui_bg_newguide_yingyuan01",
			"ui_bg_newguide_yingyuan02",
			"ui_bg_newguide_yingyuan03",
			"ui_bg_newguide_yingyuan04",
			"ui_bg_newguide_yingyuan05",
			"ui_bg_newguide_yingyuan06",
			"ui_bg_newguide_yingyuan07"
		}
	elseif type == TutorialViewType.Fans then
		list = {
			"ui_bg_newguide_fensi01",
			"ui_bg_newguide_fensi02"
		}
	elseif type == TutorialViewType.PVP then
		list = {
			"ui_bg_newguide_pvp01",
			"ui_bg_newguide_pvp02",
			"ui_bg_newguide_pvp03",
			"ui_bg_newguide_pvp04",
			"ui_bg_newguide_pvp05",
			"ui_bg_newguide_pvp06"
		}
	elseif type == TutorialViewType.Quiz then
		list = {
			"ui_bg_newguide_wenda01",
			"ui_bg_newguide_wenda02",
			"ui_bg_newguide_wenda03"
		}
	elseif type == TutorialViewType.Cook then
		list = {
			"ui_bg_newguide_pengren01",
			"ui_bg_newguide_pengren02",
			"ui_bg_newguide_pengren03",
			"ui_bg_newguide_pengren04"
		}
	end

	return list
end

function DlgTutorialView.Show(tutViewType, callback)
	local id = PersistentStoreUtil.GetTutorialView(tutViewType)

	if id == 0 then
		PersistentStoreUtil.SetTutorialView(tutViewType)
	else
		if callback then
			callback()
		end

		return
	end

	if tutViewType == TutorialViewType.TouchStudent or tutViewType == TutorialViewType.Support or tutViewType == TutorialViewType.ExploreVideo or tutViewType == TutorialViewType.Explore or tutViewType == TutorialViewType.ExploreJob then
		if callback then
			callback()
		end

		return
	end

	local data = {}

	data.list = DlgTutorialView.GetList(tutViewType)
	data.cb = callback

	CreateDlgInScene(DlgTutorialView(), data)
end

function DlgTutorialView.ShowTip(tutViewType)
	local data = {}

	data.list = DlgTutorialView.GetList(tutViewType)

	CreateDlgInScene(DlgTutorialView(), data)
end
