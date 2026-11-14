-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUIBossAppear.lua

DlgUIBossAppear = class("DlgUIBossAppear", UIPanel_sync)

function DlgUIBossAppear:ctor()
	DlgUIBossAppear.base.ctor(self, "UI/PageFight/Dlg/DlgUIBossAppear")
end

function DlgUIBossAppear:Cache()
	DlgUIBossAppear.base.Cache(self)
end

function DlgUIBossAppear:Close()
	DlgUIBossAppear.base.Close(self)
end

function DlgUIBossAppear:OnEnter()
	self.txt_bossName = self:GetChildComponent("panel/txt_bossName", "Text")
	self.tmp_bossName = self:GetChildComponent("panel/txt_bossName/tmp", "TMPro.TextMeshProUGUI")
	self.tmp_title = self:GetChildComponent("panel/txt/tmp", "TMPro.TextMeshProUGUI")

	self:Show(false)
end

function DlgUIBossAppear:Purge()
	DlgUIBossAppear.base.Purge(self)
end

function DlgUIBossAppear:OnRegisterEvent()
	return
end

function DlgUIBossAppear:OnUnRegisterEvent()
	return
end

function DlgUIBossAppear:Open()
	for i, unitBase in ipairs(SceneMgr.GetCurrentScene().GP.Team.EnemyTeam) do
		if unitBase.IsBoss == true then
			local text = self:GetChildComponent("panel/txt", "Text")
			local label = Lang(unitBase.UnitData.data.Name)

			self.tmp_bossName.text = label
			self.tmp_title.text = _("eDlgUIBossAppear")

			self:Show(true)
			Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator", false)
			Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", false)
			SoundMgr.PostEvent("Play_SE_020_0054", self.UIRootObject)

			break
		end
	end

	BattleConfig.Delay(5, function()
		self:Show(false)
	end)
end
