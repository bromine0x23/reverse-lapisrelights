-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUIPVPSession.lua

local imgTypeArrowBk = {}

imgTypeArrowBk[1] = "UIDyAtlas/Battle/ui_hd_word_sing5"
imgTypeArrowBk[2] = "UIDyAtlas/Battle/ui_hd_word_charge5"
imgTypeArrowBk[3] = "UIDyAtlas/Battle/ui_hd_word_dance5"
DlgUIPVPSession = class("DlgUIPVPSession", UIPanel_sync)

function DlgUIPVPSession:ctor()
	DlgUIPVPSession.base.ctor(self, "UI/PageFight/Dlg/DlgUIPVPSession")
end

function DlgUIPVPSession:Cache()
	DlgUIPVPSession.base.Cache(self)
end

function DlgUIPVPSession:Purge()
	DlgUIPVPSession.base.Purge(self)
end

function DlgUIPVPSession:Close()
	DlgUIPVPSession.base.Close(self)
end

function DlgUIPVPSession:OnEnter()
	self:Hide()

	self.role1 = {}
	self.role2 = {}
	self.role3 = {}

	self:InitUI(self.role1, 1)
	self:InitUI(self.role2, 2)
	self:InitUI(self.role3, 3)
end

function DlgUIPVPSession:InitUI(tb, count)
	tb.root = self:GetChildGameObject(count .. "")
	tb.title = self:GetChildComponent(count .. "/showName", "Image")
	tb.role = {}

	for i = 1, count do
		local data = {}

		data.head = self:GetChildComponent(count .. "/cell" .. i .. "/headIcon", "RawImage")
		data.num = self:GetChildComponent(count .. "/num" .. i .. "/text", "Text")
		data.ball = self:GetChildComponent(count .. "/ball" .. i .. "/icon", "Image")
		data.eff1 = self:GetChildGameObject(count .. "/ball" .. i .. "/eff/1")

		table.insert(tb.role, data)
	end
end

function DlgUIPVPSession:Hide()
	self.UIRootObject:SetActive(false)
end

function DlgUIPVPSession:Open(msg, callback)
	if msg.sessionType == 0 then
		if callback then
			callback()
		end

		return
	end

	self:Show(true)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator", false)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", false)

	local showCount = #msg.uniqueIds

	if showCount > 3 then
		showCount = 3
	end

	self:Refresh(showCount, msg.sessionType, msg.uniqueIds)
	BattleConfig.Delay(1, function()
		self:Show(false)
		Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", true)
		Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator", true)

		if callback then
			callback()
		end
	end)
end

function DlgUIPVPSession:Refresh(showCount, type, uniqueIds)
	for i = 1, 3 do
		local role = self["role" .. i]

		role.root:SetActive(false)
	end

	local role = self["role" .. showCount]

	role.root:SetActive(true)

	local path = imgTypeArrowBk[type]

	GP.SpriteUtil:SetSprite(role.title, path)

	for i = 1, showCount do
		local uid = uniqueIds[i]
		local attackUnitActor = UnitActor.FindUnitById(uid)
		local data = role.role[i]

		UIUtil.SetRawImageTexture(data.head, attackUnitActor.UnitData.data.PVPSessionCutInPath)

		data.num.text = i
		path = EnumBattle.GetSecctionShowIcon(type, attackUnitActor.CurRoundSessionType > 3)

		GP.SpriteUtil:SetSprite(data.ball, path)
	end
end
