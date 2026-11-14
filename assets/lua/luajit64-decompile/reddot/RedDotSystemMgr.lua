-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/RedDotSystemMgr.lua

require("RedDot/SystemRDL/ItemRDL")
require("RedDot/SystemRDL/RoleRDL/RoleRDL")
require("RedDot/SystemRDL/CardRDL/CardRDL")
require("RedDot/SystemRDL/PVPRDL")
require("RedDot/SystemRDL/TaskRDL/TaskRDL")
require("RedDot/SystemRDL/CalendarRDL")
require("RedDot/SystemRDL/CommunicationRDL")
require("RedDot/SystemRDL/WorkRDL")
require("RedDot/SystemRDL/FriendRDL")
require("RedDot/SystemRDL/ManualRDL/ManualRDL")
require("RedDot/SystemRDL/ChapterRDL/ChapterRDL")
require("RedDot/SystemRDL/TitleRDL")
require("RedDot/SystemRDL/ThemeRDL")
require("RedDot/SystemRDL/BagRDL")
require("RedDot/SystemRDL/BondageRDL")
require("RedDot/SystemRDL/UnionRDL/UnionRDL")
require("RedDot/SystemRDL/OperationRDL/OperationRDL")
require("RedDot/SystemRDL/QuestionnaireRDL")
require("RedDot/SystemRDL/MailRDL")
require("RedDot/SystemRDL/HelpRDL")
require("RedDot/SystemRDL/ShopRDL")
require("RedDot/SystemRDL/WebNoticeRDL")
require("RedDot/Common/ByStageUtil")
require("RedDot/Common/SystemOpenMgr")
require("RedDot/Common/RDLRefresh")

RED_DOT_TYPE = numEnumWithStartNum({
	"A",
	"B",
	"C",
	"D"
}, 1)
RED_DOT_CHANGE_TYPE = {
	Add = 1,
	Sub = 2
}
RedDotSystemMgr = {}
SHOW_RED_DOT = true

local UIRedDotStateList = {}

function RedDotSystemMgr:Init()
	if not SHOW_RED_DOT then
		return
	end

	local version = PersistentStoreUtil.GetString("LapisResVersion")

	if version ~= Launcher.Instance:GetResVer() then
		PersistentStoreUtil.SetString("LapisResVersion", Launcher.Instance:GetResVer())
		RedDotSystemMgr.Clean()
	end

	self.InitAllLeafNode()
end

function RedDotSystemMgr.Clean()
	RoleRDL.FittingRDL.FixAndClearLocalCache()
	HelpRDL.FixAndClearLocalCache()
end

function RedDotSystemMgr.InitAllLeafNode()
	RoleRDL.Init()
	CardRDL.Init()
	ManualRDL.Init()
	ChapterRDL.Init()
	ThemeRDL.Init()
	BagRDL.Init()
	BondageRDL.Init()
	MailRDL.Init()
	QuestionnaireRDL.Init()
	HelpRDL.Init()
	WebNoticeRDL.Init()
	SystemOpenMgr.InitRedDotSystemOpenState()
end

function RedDotSystemMgr.GetNode(path)
	local node = RedDotManager.Instance.GetOrAddNode(path)

	return node
end

function RedDotSystemMgr.GetFormatPath(formatPath, ...)
	return string.format(formatPath, ...)
end

function RedDotSystemMgr.SetNodeValueByFormatPath(formatPath, value, ...)
	local path = string.format(formatPath, ...)

	RedDotManager.Instance.ChangeValue(path, value)
end

function RedDotSystemMgr.ChangeNodeValueByFormatPath(formatPath, value, ...)
	local path = string.format(formatPath, ...)

	RedDotManager.Instance.ModifyValue(path, value)
end

function RedDotSystemMgr.RemoveNode(formatPath, ...)
	local path = string.format(formatPath, ...)

	RedDotManager.Instance.RemoveTreeNode(path)
end

function RedDotSystemMgr.SetNodeLockState(path, lock)
	if not string.isNullOrEmpty(path) and lock ~= nil then
		RedDotManager.Instance.ChangeNodeLockState(path, lock)
	end
end

function RedDotSystemMgr.SetNodeViewState(path, view)
	if not string.isNullOrEmpty(path) and view ~= nil then
		RedDotManager.Instance.ChangeNodeViewState(path, view)
	end
end

function RedDotSystemMgr.SetUIRedDot(object, path)
	if IsNil(object) then
		return
	end

	local uireddot = GOUtil.GetComponent(object, "UIRedDot")

	if not IsNil(uireddot) then
		UIRedDotStateList[uireddot] = true

		if path ~= nil then
			uireddot:InitNode(path)
		end
	end
end

function RedDotSystemMgr.SetUIRedDotState(uireddot, isEnable)
	if not IsNil(uireddot) and UIRedDotStateList[uireddot] ~= isEnable then
		UIRedDotStateList[uireddot] = isEnable

		uireddot:SetDotEnable(isEnable)
	end
end

function RedDotSystemMgr.Refresh()
	RDLRefresh.DO()
end
