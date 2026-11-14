-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellPlayerBirthday.lua

require("UI/Item/UIItemBase")

CellPlayerBirthday = class("CellPlayerBirthday", UIItemBase)

function CellPlayerBirthday:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellPlayerBirthday:OnEnter()
	local g = self.UIRootObject

	self.btn_enter = GOUtil.FindChildComponent(g, "btn_enter", "Image")

	self:AddClick(self.btn_enter.gameObject, self.OnClickedBtnRecv)

	if OperationActiveMgr.PageOperationActiveType == 1 then
		GOUtil.SetTransformLocalScale(self.btn_enter.gameObject, 1)
	end
end

function CellPlayerBirthday:OnLeave()
	if not IsNil(self.btn_enter) then
		self:RemoveClick(self.btn_enter.gameObject, self.OnClickedBtnRecv)
	end

	UnloadAllImageSprite(self)
end

function CellPlayerBirthday:UpdateData(data, listOpenActive, callback)
	self.data = data
	self.callback = callback

	UIUtil.SetImageSprite(self.btn_enter, "UI/PanelOperation/New/Spine/PlayerBirthday/BG_exer_birth_team_0" .. data.index, self)
end

function CellPlayerBirthday:OnClickedBtnRecv(data)
	local function wrap_cb(index)
		if index == 1 then
			if self.callback then
				self.callback()
			end

			RoleCardMgr:SetTipWindowAwardState("0")
			RoleCardMgr:SetTipWindowAwardSignState("0")
			SceneMgr.LoadScene("PlayerBirthday", {
				combId = self.data.index,
				index = self.data.index
			})
		end
	end

	local strTitle = Lang(42701)
	local strOkText = _("UI_OK")
	local strCancelText = _("Quite_Cancel")
	local msg = Lang(42702)

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, strTitle, msg, wrap_cb, strOkText, strCancelText)
end
