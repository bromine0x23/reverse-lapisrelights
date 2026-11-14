-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoStageCondition.lua

local InfoStageCondition = {}

local function GetJobWord(idxJob)
	if idxJob == eJobType.Strength then
		return _("eJobWord_Strength")
	elseif idxJob == eJobType.Artifice then
		return _("eJobWord_Artifice")
	elseif idxJob == eJobType.Speed then
		return _("eJobWord_Speed")
	elseif idxJob == eJobType.Intelligence then
		return _("eJobWord_Intelligence")
	elseif idxJob == eJobType.Assistance then
		return _("eJobWord_Assistance")
	end

	return eJobType.Strength
end

function InfoStageCondition.GradeText(TextComponent, CurGradeCfg)
	if not TextComponent or not TextComponent.text or not CurGradeCfg then
		print("InfoStageCondition ERROR !!!!! ")

		return
	end

	local grade = CurGradeCfg
	local txt = TextComponent

	for k, v in pairs(grade) do
		if k == "Win" then
			txt.text = _("eStageCondition_pass")
		elseif k == "LimitTurn" then
			txt.text = string.format(_("eStageCondition_limitTurn"), v)
		elseif k == "HpRatio" then
			txt.text = string.format(_("eStageCondition_hp"), v)
		elseif k == "TeamMember" then
			txt.text = string.format(_("eStageCondition_team"), v[1], v[2])
		elseif k == "NoSkillType" then
			txt.text = string.format(_("eStageCondition_skill"), v)
		elseif k == "SumCardStar" then
			txt.text = string.format(_("eStageCondition_cardStar"), v)
		elseif k == "DieNum" then
			if v == 0 then
				txt.text = _("eStageCondition_DieNum_0")
			else
				txt.text = string.format(_("eStageCondition_DieNum"), v)
			end
		elseif k == "JobExclude" then
			local job = GetJobWord(v)

			txt.text = string.format(_("eStageCondition_JobExclude"), job)
		elseif k == "SelfDestructLimit" then
			if v == 0 then
				txt.text = _("eStageCondition_SelfDestructLimit_0")
			else
				txt.text = string.format(_("eStageCondition_SelfDestructLimit"), v)
			end
		else
			txt.text = ""
		end
	end
end

return InfoStageCondition
