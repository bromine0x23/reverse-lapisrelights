-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Cells/CellAutoBtn.lua

local autoBtnImgPath = {
	"UI/PageFight/AtlasBattleInfo/ui_hd_button_cn_auto",
	"UI/PageFight/AtlasBattleInfo/BTN_auto_02_cn",
	"UI/PageFight/AtlasBattleInfo/ui_hd_button_cn_auto_02"
}

CellAutoBtn = class("CellAutoBtn", UIPanel_sync)

function CellAutoBtn:ctor(isOperatorCard)
	CellAutoBtn.base.ctor(self, "UI/PageFight/Cells/CellAutoBtn")
end

function CellAutoBtn:Cache()
	CellAutoBtn.base.Cache(self)

	for i, path in ipairs(autoBtnImgPath) do
		ResourceMgr.SubmitCache(path, self, "autoBtnImg_" .. i, Sprite)
	end
end

function CellAutoBtn:SetParent(root)
	GOUtil.AttachGameObject(self.UIRootObject, root, true)
end

function CellAutoBtn:OnEnter(vParam)
	self.img_btnAuto = self:GetChildComponent("panel/btn_auto", "Image")
	self.btn_auto = self.img_btnAuto.gameObject
	self.isInstructionOpen = true

	local isReplay = GP.GameStartData.playMode == EnumFight.PlayMode.Replay

	GOUtil.SetActive(self.btn_auto, not isReplay)

	local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.AutoFight)
	local gray = TenaryOp(isOpen, 0, 1)

	UIUtil.SetImageGray(self.img_btnAuto, gray)
end

function CellAutoBtn:Close()
	for i, path in ipairs(autoBtnImgPath) do
		self["autoBtnImg_" .. i] = nil
	end
end

function CellAutoBtn:OnRegisterEvent()
	CellAutoBtn.base.OnRegisterEvent(self)
	self:AddClick(self.btn_auto, self.OnBtnAutoClick)
	Event.Instance:Add("SetGuideBtn", self.OnSetGuideBtn, self)
	Event.Instance:Add("SwitchAutoOperator", self.SetBtnAutoImg, self)
end

function CellAutoBtn:OnUnRegisterEvent()
	CellAutoBtn.base.OnUnRegisterEvent(self)
	self:RemoveClick(self.btn_auto, self.OnBtnAutoClick)
	Event.Instance:Remove("SetGuideBtn", self.OnSetGuideBtn, self)
	Event.Instance:Remove("SwitchAutoOperator", self.SetBtnAutoImg, self)
end

function CellAutoBtn:OnSetGuideBtn(isShow)
	self.isInstructionOpen = isShow

	if isShow == false then
		local idx = 3
		local iconPath = autoBtnImgPath[idx]

		if iconPath then
			GP.SpriteUtil:SetSprite(self.img_btnAuto, iconPath)
		end
	else
		self:SetBtnAutoImg(GP.AutoMode)
		GOUtil.SetActive(self.btn_auto, true)
	end

	if GP.GameStartData.playMode == EnumFight.PlayMode.Replay then
		GOUtil.SetActive(self.btn_auto, false)
	end
end

function CellAutoBtn:SetBtnAutoImg(isAutoMode)
	local idx = TenaryOp(isAutoMode == false, 1, 2)
	local iconPath = self["autoBtnImg_" .. idx]

	if iconPath then
		GP.SpriteUtil:SetSprite(self.img_btnAuto, iconPath)
	end
end

function CellAutoBtn:OnBtnAutoClick()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.AutoFight) then
		return
	end

	if self.isInstructionOpen == false then
		return
	end

	GP:SwitchAutoMode()

	local idx = TenaryOp(GP.AutoMode == false, 1, 2)
	local arr = {
		_("TipAutoOff"),
		_("TipAutoOn")
	}

	UIMgr.ShowMsg(arr[idx])
end
