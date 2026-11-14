-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageSkillViewer/PageSkillViewer.lua

require("UI/Page/PageSkillViewer/Dlg/DlgViewerMenu")
require("UI/Page/PageSkillViewer/Dlg/DlgPickModel")
require("UI/Page/PageSkillViewer/Dlg/DlgPickMonster")
require("UI/Page/PageSkillViewer/Dlg/DlgNpcSkill")
require("UI/Page/PageSkillViewer/Dlg/DlgNpcAnim")
require("UI/Page/PageSkillViewer/Dlg/DlgNpcVocal")

PageSkillViewer = class("PageSkillViewer", UIPanel)

function PageSkillViewer:RegisterDlg(ele)
	self:AddChildPanel(ele)

	self.DlgTable[ele.className] = ele
end

function PageSkillViewer:ctor()
	PageSkillViewer.base.ctor(self, "UI/PageSkillViewer/PageSkillViewer")

	self.DlgTable = {}
	self.DlgViewerMenu = DlgViewerMenu()

	self:RegisterDlg(self.DlgViewerMenu)

	self.DlgPickMonster = DlgPickMonster()

	self:RegisterDlg(self.DlgPickMonster)

	self.DlgPickModel = DlgPickModel()

	self:RegisterDlg(self.DlgPickModel)

	self.DlgNpcSkill = DlgNpcSkill()

	self:RegisterDlg(self.DlgNpcSkill)

	self.DlgNpcAnim = DlgNpcAnim()

	self:RegisterDlg(self.DlgNpcAnim)

	self.DlgNpcVocal = DlgNpcVocal()

	self:RegisterDlg(self.DlgNpcVocal)
end

function PageSkillViewer:Cache()
	PageSkillViewer.base.Cache(self)
end

function PageSkillViewer:Close(tParam)
	PageSkillViewer.base.Close(self, tParam)
end

function PageSkillViewer:Purge()
	for k, v in pairs(self.DlgTable) do
		v = nil
	end

	self.DlgTable = {}

	PageSkillViewer.base.Purge(self)
end

function PageSkillViewer:OnRegisterEvent()
	return
end

function PageSkillViewer:OnUnRegisterEvent()
	return
end

function PageSkillViewer:OnEnter(vParam)
	return
end

function PageSkillViewer:OpenDlg(dlgName, val, ...)
	local dlg = self.DlgTable[dlgName]

	if not dlg then
		print("OpenDlg failed !!! dlgName is null or not register!  dlgName = " .. dlgName)

		return
	end

	if val ~= nil and val == false then
		local hideFun = self.DlgTable[dlgName].Hide

		if hideFun then
			hideFun(self.DlgTable[dlgName])

			return
		end

		self.DlgTable[dlgName]:Show(false)

		return
	end

	local openFun = self.DlgTable[dlgName].Open

	if openFun then
		openFun(self.DlgTable[dlgName], ...)

		return
	end

	print("OpenDlg failed !!! have not define Open function = " .. dlgName)
	self.DlgTable[dlgName]:Show(true)
end
