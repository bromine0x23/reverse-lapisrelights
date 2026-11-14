-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUICutInNSession.lua

DlgUICutInNSession = class("DlgUICutInNSession", UIPanel_sync)

function DlgUICutInNSession:ctor()
	DlgUICutInNSession.base.ctor(self, "UI/PageFight/Dlg/DlgUICutInNSession")
end

function DlgUICutInNSession:OnEnter(vParam)
	self:Show(false)

	self.roles = {}

	for i = 1, 4 do
		self.roles[i] = self:GetChildGameObject("roles/role" .. i)
	end

	self.cards = {}

	for i, role in ipairs(self.roles) do
		self.cards[i] = {}

		for j = 1, i do
			local con1 = "role" .. i .. "_Con" .. j
			local con2 = "role" .. i .. "_roleImg" .. j
			local roleImgPath = con1 .. "/" .. con2 .. "/roleImg"
			local obj = role.transform:Find(roleImgPath)

			self.cards[i][j] = GOUtil.GetComponent(obj.gameObject, "RawImage")
		end
	end

	local rolesObj = self:GetChildGameObject("roles")

	self.rolesAnimator = GOUtil.GetComponent(rolesObj, "Animator")
end

function DlgUICutInNSession:Open(unitActors, callback)
	self:Show(true)
	BattleConfig.PlaySound("Play_SE_020_0026")

	for _, v in ipairs(self.roles) do
		GOUtil.SetActive(v, false)
	end

	local index = #unitActors

	GOUtil.SetActive(self.roles[index], true)

	local cards = self.cards[index]

	for i, v in ipairs(unitActors) do
		UIUtil.SetRawImageTexture(cards[i], v.UnitData.data.FightNSessionCutInPath)
	end

	local _idx = math.random(1, #unitActors)

	Event.Instance:Fire("UnitVocalEvent", UnitVocal.enType.Cutin, unitActors[_idx])
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator", false)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", false)
	BattleConfig.Delay(1.5, function()
		self:Show(false)
		Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator")
		Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", true)

		if callback then
			callback()
		end
	end)
end
