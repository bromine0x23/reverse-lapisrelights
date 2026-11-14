-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/MoveCurveHelper.lua

MoveCurveHelper = class("MoveCurveHelper")

function MoveCurveHelper:ctor(_path)
	self.path = _path
	self.moveCurve = nil
end

function MoveCurveHelper:Cache()
	ResourceMgr.SubmitCache(self.path, self, "moveCurve", Object)
end

function MoveCurveHelper:Purge()
	ResourceMgr.Unload(self.moveCurve)
end

function MoveCurveHelper:UpdateMove(Pos, MovePos, timer)
	return MoveCurve.Move(self.moveCurve, Pos, MovePos, timer)
end

function MoveCurveHelper:GetDuration()
	return MoveCurve.Duration(self.moveCurve)
end
