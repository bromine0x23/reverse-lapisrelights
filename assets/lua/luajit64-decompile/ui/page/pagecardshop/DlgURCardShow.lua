-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCardShop/DlgURCardShow.lua

DlgURCardShow = class("DlgURCardShow", UIPanel)

function DlgURCardShow:ctor()
	self.UIPrefabPath = "UI/PageCardShop/DlgURCardShow"
end

function DlgURCardShow:Purge()
	InfoSoundEventMgr:UnloadBank(PATH_BANK_DRAWCARDUR)
	DlgURCardShow.base.Purge(self)
end

function DlgURCardShow:PreLoad()
	return
end

function DlgURCardShow:OnEnter(vParam)
	self.infoRole = vParam.infoRole
	self.infoRoleCard = vParam.infoRoleCard
	self.callback = vParam.callback
	self.endback = vParam.endback

	if vParam.enterback then
		vParam.enterback()

		vParam.enterback = nil
	end

	self.Text = self:GetChildComponent("TextMask/Text", "Text")
	self.Icon = self:GetChildComponent("TextMask/Icon", "Image")
	self.isDone = false
	self.isPlayAnim = true
	self.isPlaySound = true
	self.soundStr = self.infoRoleCard.data.VocalGet

	InfoSoundEventMgr:LoadBank(PATH_BANK_DRAWCARDUR)
	SoundMgr.PlayWithCallback(self.soundStr, AkCallbackType.AK_EndOfEvent, AkCallbackManager.EventCallback(function()
		self:EventSound()
	end))

	self.Text.text = Lang(self.infoRoleCard.data.TextGet)

	if self.infoRoleCard.data.ColorGet ~= "" then
		self.Text.color = getColorFromString(self.infoRoleCard.data.ColorGet)
	end

	UIUtil.SetImageSprite(self.Icon, self.infoRoleCard.data.PicGet, self)
end

function DlgURCardShow:OnRegisterEvent()
	Event.Instance:Add("CloseURCardShow", self.DoEvent, self)
	EventListenerMgr.AddAnimListener(self.UIRootObject, self.EventAnim, self, eAnimEventType.OnAnimationEnd)
end

function DlgURCardShow:OnUnRegisterEvent()
	Event.Instance:Remove("CloseURCardShow", self.DoEvent, self)
	EventListenerMgr.RemoveAnimListener(self.UIRootObject, self.EventAnim, self, eAnimEventType.OnAnimationEnd)
end

function DlgURCardShow:EventAnim()
	self.isPlayAnim = false

	if not self.isPlaySound then
		self:DoEvent()
	end
end

function DlgURCardShow:EventSound()
	self.isPlaySound = false

	if not self.isPlayAnim then
		self:DoEvent()
	end
end

function DlgURCardShow:DoEvent()
	if self.endback then
		self.endback()

		self.endback = nil

		return
	end

	if self.callback then
		self.callback(self.soundStr)

		self.callback = nil
	end

	self:Close()
end

function DlgURCardShow:OnBackAndroid()
	self:DoEvent()

	return true
end
