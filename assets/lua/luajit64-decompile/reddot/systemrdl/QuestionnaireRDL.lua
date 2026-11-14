-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/QuestionnaireRDL.lua

QuestionnaireRDL = {}

local RD_Questionnaire_Branch_Path = {
	Questionnaire = "Setting/Questionnaire"
}

function QuestionnaireRDL.Init()
	if NetManager.SurveyUrl == nil then
		return
	end

	local serverTime = NetData:GetCurServerTime() / 1000

	if serverTime < NetManager.SurveyUrl.start_time or serverTime > NetManager.SurveyUrl.end_time then
		return
	end

	if InfoGameInst.gameInfo.questionAward == 0 then
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Questionnaire_Branch_Path.Questionnaire, 1)
	end
end

function QuestionnaireRDL.SubQuestionnaireAward()
	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Questionnaire_Branch_Path.Questionnaire, 0)
end

return QuestionnaireRDL
